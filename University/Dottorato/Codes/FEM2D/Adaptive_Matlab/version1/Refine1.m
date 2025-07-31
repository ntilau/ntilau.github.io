function T=Refine1(T0)

% T=Refine1(T0)
%
%  This function takes a finite element mesh and applies
%  the standard refinement, subdividing each triangular
%  element into four by connecting the midpoints of the
%  edges.
%
%  Refine1 only accepts meshes consisting of linear
%  Lagrange triangles.
%
%  For a description of the data structures, see "help Mesh1".

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if T0.Degree~=1
   error('Refine1 only accepts meshes of linear Lagrange triangles')
end

Nt0=size(T0.Elements,1);
Ne0=size(T0.Edges,1);
Nv0=size(T0.Nodes,1);
Nf0=length(T0.FNodePtrs);
Nc0=length(T0.CNodePtrs);
Nb0=length(T0.FBndyEdges);

% Allocate storage for the refined mesh.
% Note: All the arrays must be pre-allocated if this routine
% is to perform satisfactorily when the mesh is large.

T.Degree=1;
if isfield(T0,'BndyFcn')
   T.BndyFcn=T0.BndyFcn;
end

% The number of elements increases by a factor of 4

Nt=4*Nt0;
T.Elements=zeros(Nt,3);

% Calculate the number of edges in T and allocate T.Edges, T.EdgeEls
% (Each existing edge is bisected and there are three new edges in
% the interior of each triangle).  T.EdgeCFlags can be assigned
% immediately:

Ne=2*Ne0+3*Nt0;
T.Edges=zeros(Ne,2);
T.EdgeEls=zeros(Ne,2);
T.EdgeCFlags=zeros(Ne,1);
T.EdgeCFlags(1:2:2*Ne0-1)=T0.EdgeCFlags;
T.EdgeCFlags(2:2:2*Ne0)=T0.EdgeCFlags;

% The number of the nodes in the new mesh is the number of
% nodes plus the number of edges in the original mesh:

T.Nodes=[T0.Nodes;zeros(Ne0,2)];
T.NodePtrs=[T0.NodePtrs;zeros(Ne0,1)];
Nv=Nv0;

% The number of constrained nodes increases by the number of
% constrained boundary edges; the rest of the new nodes are
% free:

Nc1=sum(T0.EdgeEls(:,2)==0);
T.CNodePtrs=[T0.CNodePtrs(:);zeros(Nc1,1)];
Nc=Nc0;
T.FNodePtrs=[T0.FNodePtrs(:);zeros(Nv0+Ne0-Nc0-Nc1-Nf0,1)];
Nf=Nf0;

% The number of free boundary edges increases by a factor of 2.
% These pointers can be assigned immediately:

Nb=2*Nb0;;
T.FBndyEdges=zeros(Nb,1);
T.FBndyEdges(1:2:Nb-1)=2*T0.FBndyEdges-1;
T.FBndyEdges(2:2:Nb)=2*T0.FBndyEdges;

% Copy or create the LevelNodes and NodeParents arrays:

if isfield(T0,'LevelNodes')
   T.LevelNodes=[T0.LevelNodes;Nv0+Ne0];
   T.NodeParents=[T0.NodeParents;zeros(Ne0,2)];
else
   T.LevelNodes=[Nv0;Nv0+Ne0];
   T.NodeParents=[(1:Nv0)',zeros(Nv0,1);zeros(Ne0,2)];
end

% Loop over the edges; create the midpoint nodes and bisect
% the edges.  The midpoint of e_i will be z_{Nv0+i}.
% The two new edges formed by bisecting e_i will be
% e_{2i-1} and e_{2i}.

for i=1:Ne0

   % The midpoint calculation depends on whether the edge
   % approximates a piece of a curved boundary or not:

   Nv=Nv+1;
   v1=T0.Edges(i,1);
   v2=T0.Edges(i,2);
   if T0.EdgeCFlags(i)==0
      T.Nodes(Nv,:)=0.5*(T.Nodes(v1,:)+T.Nodes(v2,:));
   else
      T.Nodes(Nv,:)=feval(T0.BndyFcn,T.Nodes(v1,:),T.Nodes(v2,:));
   end
   T.NodeParents(Nv,:)=[v1,v2];

   % Update the pointers:

   if T0.EdgeEls(i,2)==0
      Nc=Nc+1;
      T.CNodePtrs(Nc)=Nv;
      T.NodePtrs(Nv)=-Nc;
   else
      Nf=Nf+1;
      T.FNodePtrs(Nf)=Nv;
      T.NodePtrs(Nv)=Nf;
   end

   % Create the new edges:

   T.Edges(2*i-1,:)=[v1,Nv];
   T.Edges(2*i,:)=[Nv,v2];

end

% Loop over the triangular elements in the original mesh.
% Triangle T_i becomes triangles T_{4i-3}, T_{4i-2}, T_{4i-1}, T_{4i}.
% Update EdgeEls and Elements.  The new triangles are
% labeled as follows:
%
%                  /\
%                 /  \
%                / 3  \
%               /      \
%  (edge e(3)  /--------\  (edge e(2)
%   from T_i  / \      / \  from T_i)
%            /   \ 4  /   \
%           / 1   \  /  2  \
%          /_______\/_______\
%
%          (edge e(1) from T_i)

for i=1:Nt0

   % Get the edges of this triangle:

   eptr=T0.Elements(i,1:3);
   e=abs(eptr);
   s=sign(eptr);

   % Sort out the order of the new edges:

   newe=zeros(3,2);
   for j=1:3
      if s(j)>0
         newe(j,:)=[2*e(j)-1,2*e(j)];
      else
         newe(j,:)=-[2*e(j),2*e(j)-1];
      end
   end

   % Create the new triangles and assign EdgeEls:

   T.Elements(4*i-3,:)=[newe(1,1),2*Ne0+3*i-2,newe(3,2)];
   T.Elements(4*i-2,:)=[newe(1,2),newe(2,1),2*Ne0+3*i-1];
   T.Elements(4*i-1,:)=[2*Ne0+3*i,newe(2,2),newe(3,1)];
   T.Elements(4*i,:)=-[2*Ne0+3*i-2,2*Ne0+3*i-1,2*Ne0+3*i];
   newe=abs(newe);
   if T.EdgeEls(newe(1,1),1)==0
      T.EdgeEls(newe(1,1),1)=4*i-3;
      T.EdgeEls(newe(1,2),1)=4*i-2;
   else
      T.EdgeEls(newe(1,1),2)=4*i-3;
      T.EdgeEls(newe(1,2),2)=4*i-2;
   end
   if T.EdgeEls(newe(2,1),1)==0
      T.EdgeEls(newe(2,1),1)=4*i-2;
      T.EdgeEls(newe(2,2),1)=4*i-1;
   else
      T.EdgeEls(newe(2,1),2)=4*i-2;
      T.EdgeEls(newe(2,2),2)=4*i-1;
   end
   if T.EdgeEls(newe(3,1),1)==0
      T.EdgeEls(newe(3,1),1)=4*i-1;
      T.EdgeEls(newe(3,2),1)=4*i-3;
   else
      T.EdgeEls(newe(3,1),2)=4*i-1;
      T.EdgeEls(newe(3,2),2)=4*i-3;
   end

   % Create the new interior edges and assign EdgeEls:

   T.Edges(2*Ne0+3*i-2,:)=[T.Edges(2*e(1)-1,2),T.Edges(2*e(3)-1,2)];
   T.Edges(2*Ne0+3*i-1,:)=[T.Edges(2*e(2)-1,2),T.Edges(2*e(1)-1,2)];
   T.Edges(2*Ne0+3*i,:)=[T.Edges(2*e(3)-1,2),T.Edges(2*e(2)-1,2)];
   T.EdgeEls(2*Ne0+3*i-2,:)=[4*i-3,4*i];
   T.EdgeEls(2*Ne0+3*i-1,:)=[4*i-2,4*i];
   T.EdgeEls(2*Ne0+3*i,:)=[4*i-1,4*i];

end

T.EdgeEls(T.FBndyEdges,2)=-(1:Nb)';
