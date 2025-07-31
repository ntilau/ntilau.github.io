function T=MakeMesh1(Nodes,Triangles,Dir)

% T=MakeMesh1(Nodes,Triangles,Dir)
%
%   This function takes a list of nodes and a list
%   of triangles and generates the complete mesh
%   data structure.
%
%   The input Nodes is an Nv by 2 array, with each
%   row containing the (x,y) coordinates of a node.
%   The input Triangles is an Nt by 3 array, with each
%   row corresponding to one triangle and containing
%   the pointers into Nodes, identifying the three
%   vertices.  NOTE: The vertices must be listed in
%   counterclockwise order.
%
%   If the optional input Dir is included, it indicates
%   that some of the nodes are constrained.  If Dir is
%   the string 'Dirichlet', then all of the boundary nodes
%   are constrained.  If Dir is an array of integers, it
%   must define a subset of {1,2,...,Nv}, indicating the
%   set of constrained nodes.
%
%   The output is the mesh data structure T.  See "help Mesh1"
%   for a description of the mesh data structure.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Get the number of nodes and triangles:

Nv=size(Nodes,1);
Nt=size(Triangles,1);

% Check that the inputs are valid:

if size(Nodes,2)~=2
   error( 'Nodes array must have two columns' );
end
if size(Triangles,2)~=3
   error( 'Triangles array must have three columns' );
end
if Nv<3
   error( 'A mesh must have at least three nodes' );
end
if min(Triangles(:))<1 || max(Triangles(:))>Nv
   error( 'Illegal node index in Triangles array' );
end

if nargin==3
   if ischar(Dir) & (strcmp(Dir,'Dirichlet') || strcmp(Dir,'dirichlet'))
      dflag=2;
   else
      dflag=1;
   end
else
   dflag=0;
end

% Define the fields of T and assign the values if possible.
% If the final values of a field are unknown, at least
% pre-allocate the array.  If necessary, (over)estimate
% the final size.

T.Degree=1;
T.Elements=zeros(Nt,3);
T.Edges=zeros(3*Nv,2);      % (Estimated size)
T.EdgeEls=zeros(3*Nv,2);    % (Estimated size)
T.Nodes=Nodes;
if dflag==0
   T.NodePtrs=(1:Nv)';
   T.FNodePtrs=(1:Nv)';
   T.CNodePtrs=zeros(0,1);
elseif dflag==1
   T.CNodePtrs=Dir;
   Nc=length(Dir);
   T.NodePtrs=zeros(Nv,1);
   T.NodePtrs(Dir)=-(1:Nc)';
   i=find(T.NodePtrs==0);
   Nf=length(i);
   T.FNodePtrs=i;
   T.NodePtrs(i)=(1:Nf)';
else
   T.NodePtrs=zeros(Nv,1);
   T.FNodePtrs=zeros(0,1);
   T.CNodePtrs=zeros(0,1);
   T.FBndyEdges=zeros(0,1);
   Nc=0;
end
Ne=0;

% Loop over each triangle, identifying the edges and setting the
% EdgeEls flags:

for k=1:Nt

   % Define the three edges of triangle k:

   p=[1,2,3,1];
   for i=1:3

      % Define the edge:

      e=[Triangles(k,p(i)),Triangles(k,p(i+1))];
      e=[min(e),max(e)];

      % Search for it in the current list of edges:

      j=find( T.Edges(1:Ne,1)==e(1) & T.Edges(1:Ne,2)==e(2) );

      % This edge has already been encountered:

      if ~isempty(j)

         % Record the edge (sign indicates orientation):

         if e(1)==Triangles(k,p(i))
            T.Elements(k,i)=j;
         else
            T.Elements(k,i)=-j;
         end

         % Update EdgeEls:

         T.EdgeEls(j,2)=k;

      % This edge has not yet been encountered:

      else

         % Define the new edge:

         Ne=Ne+1;
         T.Edges(Ne,:)=e;

         % Record the edge (sign indicates orientation):

         if e(1)==Triangles(k,p(i))
            T.Elements(k,i)=Ne;
         else
            T.Elements(k,i)=-Ne;
         end

         % Update EdgeEls:

         T.EdgeEls(Ne,1)=k;

      end

   end

end

% Define all edges to be straight:

T.EdgeCFlags=zeros(Ne,1);

% Detemine the boundary edges:

ii=find(T.EdgeEls(1:Ne,2)==0);
Nb=length(ii);

if dflag==0

   % All boundary edges are free:

   T.EdgeEls(ii,2)=-(1:Nb)';
   T.FBndyEdges=ii;

elseif dflag==2

   % All boundary edges are constrained:

   T.FBndyEdges=zeros(0,1);

   % All boundary nodes are constrained:

   for i=1:Nb
      for j=1:2
         e=T.Edges(ii(i),j);
         if T.NodePtrs(e)==0
             Nc=Nc+1;
             T.CNodePtrs(Nc)=e;
             T.NodePtrs(e)=-Nc;
         end
      end
   end

   Nf=Nv-Nc;
   T.FNodePtrs=find(T.NodePtrs==0);
   T.NodePtrs(T.FNodePtrs)=(1:Nf)';

else

   % The node pointers have already been defined.
   % A boundary edge is free if it has a free
   % endpoint:

   nb=0;
   for i=1:Nb
      for j=1:2
         e=T.Edges(ii(i),j);
         if T.NodePtrs(e)>0
            nb=nb+1;
            T.FBndyEdges(nb)=ii(i);
            T.EdgeEls(ii(i),2)=-nb;
            break
         end
      end
   end

end

T.Edges=T.Edges(1:Ne,:);
T.EdgeEls=T.EdgeEls(1:Ne,:);
T.CNodePtrs=T.CNodePtrs(:);
