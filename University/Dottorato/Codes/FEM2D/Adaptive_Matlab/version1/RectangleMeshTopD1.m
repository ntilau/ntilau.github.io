function T=RectangleMeshTopD1(nx,ny,lx,ly)

% T=RectangleMeshTopD1(nx,ny,lx,ly)
%
%   This function creates a regular, nx by ny finite element mesh
%   on the rectangle [0,lx]x[0,ly].  Dirichlet conditions are assumed
%   on the top edge and Neumann conditions elsewhere.  
%
%   The last three arguments can be omitted; their default values are
%   ny=nx, lx=1, ly=lx.  Thus, the command "T=RectangleMeshTopD1(m)"
%   creates a regular mesh with 2m^2 triangles on the unit square.
%
%   For a description of the data structure describing T, see "help
%   Mesh1".

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Assign default arguments:

if nargin==3
   ly=lx;
elseif nargin<3
   lx=1;
   ly=1;
end
if nargin<2
   ny=nx;
end

T.Degree=1;

% Compute the number of nodes and allocate space for Nodes.
% Also define NodePtrs:

Nv=(nx+1)*(ny+1);
T.Nodes=zeros(Nv,2);

% Compute the number of free nodes and define T.FNodePtrs:

Nf=Nv-(nx+1);
T.FNodePtrs=(1:Nf)';

% Compute the number of constrained nodes and define CNodePtrs:

Nc=nx+1;
T.CNodePtrs=(Nf+1:Nv)';
T.NodePtrs=[(1:Nf)';-(1:Nc)'];

% Compute the number of triangles and allocate space for Elements:

Nt=2*nx*ny;
T.Elements=zeros(Nt,3);

% Compute the number of edges and allocate space for Edges, EdgeEls,
% and EdgeCFlags:

Ne=nx+ny*(3*nx+1);
T.Edges=zeros(Ne,2);
T.EdgeEls=zeros(Ne,2);
T.EdgeCFlags=zeros(Ne,1);

% Compute the number of boundary edges and define FBndyEdges:

Nb=nx+2*ny;
T.FBndyEdges=zeros(Nb,1);
for i=1:nx
   T.FBndyEdges(i)=i;
end
for j=1:ny
   T.FBndyEdges(nx+2*j-1)=nx+(j-1)*(3*nx+1)+1;
   T.FBndyEdges(nx+2*j)=nx+(j-1)*(3*nx+1)+2*nx+1;
end

% Loop over the rows and columns of the mesh, defining the nodes.
%
% k is the number of the node.

k=0;
dx=lx/nx;
dy=ly/ny;

% Loop over the rows of the grid

for j=0:ny

   y=j*dy; 

   % Loop over the columns of the grid

   for i=0:nx

      x=i*dx;
      k=k+1;

      % Insert the coordinates of the node

      T.Nodes(k,:)=[x,y];

   end

end

% Define the bottom row of edges:

for i=1:nx
   T.Edges(i,:)=[i,i+1];
   T.EdgeEls(i,:)=[2*i,-i];
end

% Loop over the rows and columns of the mesh, defining the edges and
% triangular elements.
%
% l is the number of the edge
% k is the number of the element

k=-1;
l=nx;

% Loop over the rows of the grid

for j=1:ny

   % Define the left-hand edge on this row:

   l=l+1;
   T.Edges(l,:)=[(j-1)*(nx+1)+1,j*(nx+1)+1];
   T.EdgeEls(l,:)=[2*nx*(j-1)+1,-(nx+2*j-1)];

   % Loop over the columns of the grid

   for i=1:nx

      % k is the number of the "upper left" triangle
      % k+1 is the number of the "lower right" triangle

      k=k+2;

      T.Elements(k,:)=[-l,l+1,-(l+2*(nx+1)-i)];
      T.Elements(k+1,:)=[l-nx-i+1,l+2,-(l+1)];

      T.Edges(l+1,:)=[(j-1)*(nx+1)+i,j*(nx+1)+i+1];
      T.EdgeEls(l+1,:)=[k,k+1];

      T.Edges(l+2,:)=[(j-1)*(nx+1)+i+1,j*(nx+1)+i+1];
      if i<nx
         T.EdgeEls(l+2,:)=[k+1,k+2];
      else
         T.EdgeEls(l+2,:)=[k+1,-(nx+2*j)];
      end
      l=l+2;

   end

   % Define the edges on the top of this row:

   for i=1:nx

      l=l+1;
      T.Edges(l,:)=[j*(nx+1)+i,j*(nx+1)+i+1];
      if j<ny
         T.EdgeEls(l,:)=[(j-1)*2*nx+2*i-1,j*2*nx+2*i];
      else
         T.EdgeEls(l,:)=[(j-1)*2*nx+2*i-1,0];
      end

   end

end
