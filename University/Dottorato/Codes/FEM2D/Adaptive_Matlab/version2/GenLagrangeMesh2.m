function T=GenLagrangeMesh2(T0,d)

% T=GenLagrangeMesh2(T0,d)
%
%   This function takes a mesh consisting of linear
%   (degree 1) Lagrange triangles and creates from it
%   a mesh consisting of degree d Lagrange triangles
%   (d>1).
%
%   See "help Mesh2" for a description of the mesh
%   data structure.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if T0.Degree~=1
   error('Input mesh must have Degree 1');
end

if d<1
   error('Degree of output mesh must be at least 1');
end

if d==1
   T=T0;
   return
end

% Get various sizes of the original mesh:

Nt0=size(T0.Elements,1);
Ne0=size(T0.Edges,1);
Nv0=size(T0.Nodes,1);
Nf0=length(T0.FNodePtrs);
Nc0=length(T0.CNodePtrs);
Nb0=size(T0.FBndyEdges,1);

% Allocate the new mesh.

% Compute the number of nodes per triangle:

id=(d+1)*(d+2)/2;

% Set the degree of the new mesh:

T.Degree=d;

% The triangles and edges are the same, so copy the Elements,
% Edges, EdgeEls, EdgeCFlags, and FBndyEdges arrays:

T.Elements=T0.Elements;
T.Edges=[T0.Edges(:,1),zeros(Ne0,d-1),T0.Edges(:,2)];
T.EdgeEls=T0.EdgeEls;
T.EdgeCFlags=T0.EdgeCFlags;
T.FBndyEdges=T0.FBndyEdges;

% There are id-3*d interior nodes per triangle:

T.IntNodes=zeros(Nt0,id-3*d);

% The nodes in the new mesh will be the vertices in the
% original mesh, plus the edge nodes, plus the interior
% nodes:

Nv=Nv0+(d-1)*Ne0+(id-3*d)*Nt0;
T.Nodes=zeros(Nv,2);
T.Nodes(1:Nv0,:)=T0.Nodes;
T.NodePtrs=zeros(Nv,1);
T.NodePtrs(1:Nv0)=T0.NodePtrs;
Nv=Nv0;

% The free nodes in the new mesh will be the free node in
% the original mesh, plus the interior nodes and the new
% nodes from the free edges:

nec=length(find(T0.EdgeEls(:,2)==0));
Nf=Nf0+(id-3*d)*Nt0+(d-1)*(Ne0-nec);
T.FNodePtrs=zeros(Nf,1);
T.FNodePtrs(1:Nf0)=T0.FNodePtrs;
Nf=Nf0;
Nc=Nc0+(d-1)*nec;
T.CNodePtrs=zeros(Nc,1);
T.CNodePtrs(1:Nc0)=T0.CNodePtrs;
Nc=Nc0;

% Loop over the edges and add d-1 edge nodes to each:

for i=1:Ne0

   % Get the coordinates of the endpoints of the edge:

   v1=T0.Nodes(T0.Edges(i,1),1:2);
   v2=T0.Nodes(T0.Edges(i,2),1:2);

   % Compute the coordinates of the new edge nodes

   v=(1/d)*(v2-v1);
   T.Nodes(Nv+1:Nv+d-1,1)=linspace(v1(1)+v(1),v2(1)-v(1),d-1)';
   T.Nodes(Nv+1:Nv+d-1,2)=linspace(v1(2)+v(2),v2(2)-v(2),d-1)';

   % Update Edges:

   T.Edges(i,2:d)=Nv+1:Nv+d-1;

   % Update NodePtrs, FNodePtrs, CNodePtrs:

   if T0.EdgeEls(i,2)==0

      % This edge is constrained, and so are all of the
      % edge nodes:

      T.CNodePtrs(Nc+1:Nc+d-1)=(Nv+1:Nv+d-1)';
      T.NodePtrs(Nv+1:Nv+d-1)=-(Nc+1:Nc+d-1)';
      Nc=Nc+d-1;

   else

      % This edge is free, and so are all of the
      % edge nodes:

      T.FNodePtrs(Nf+1:Nf+d-1)=(Nv+1:Nv+d-1)';
      T.NodePtrs(Nv+1:Nv+d-1)=(Nf+1:Nf+d-1)';
      Nf=Nf+d-1;

   end

   % Update the number of nodes:

   Nv=Nv+d-1;

end

% Loop over the triangular elements to add the interior nodes:

for t=1:Nt0

   % There are (d-1)*(d-2)/2 interior nodes with barycentric
   % coordinates (i/d,j/d,k/d), i=1,2,...,d-2,j=1,2,...,d-i-1, k=d-i-j.

   T.IntNodes(t,:)=Nv+1:Nv+id-3*d;

   % Get the coordinates of the vertices of this triangle:

   c=getNodes(T0,t);

   % Create the interior nodes:

   for i=1:d-2

      for j=1:d-i-1

         k=d-i-j;
         Nv=Nv+1;
         T.Nodes(Nv,:)=(k/d)*c(1,:)+(j/d)*c(2,:)+(i/d)*c(3,:);
         Nf=Nf+1;
         T.NodePtrs(Nv)=Nf;
         T.FNodePtrs(Nf)=Nv;

      end

   end

end

% Now copy the free boundary edge pointers:

T.FBndyEdges=T0.FBndyEdges;
