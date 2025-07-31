function T=RectangleMeshD1a(nx,ny,lx,ly)

% T=RectangleMeshD1a(nx,ny,lx,ly)
%
%   This function creates a regular, nx by ny finite element mesh for
%   a Dirichlet problem on the rectangle [0,lx]x[0,ly].  The mesh
%   differs from that produced by RectangleMeshD1 in that the
%   pattern of triangles is symmetric.
%
%   The last three arguments can be omitted; their default values are
%   ny=nx, lx=1, ly=lx.  Thus, the command "T=RectangleMeshD1a(m)"
%   creates a regular mesh with 4m^2 triangles on the unit square.
%
%   For a description of the data structure describing T, see "help Mesh1".

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

% First define the nodes:

dx=lx/nx;
dy=ly/ny;
nodes=zeros((nx+1)*(ny+1)+nx*ny,2);
k=0;
for j=0:ny
   for i=0:nx
      k=k+1;
      nodes(k,:)=[i*dx,j*dy];
   end
end
for j=1:ny
   for i=1:nx
      k=k+1;
      nodes(k,:)=[(i-0.5)*dx,(j-0.5)*dy];
   end
end

% Now define the triangles:

k=0;
p=(nx+1)*(ny+1);
tris=zeros(4*nx*ny,3);
for j=1:ny
   p1=(j-1)*(nx+1);
   p2=j*(nx+1);
   p3=p+(j-1)*nx;
   for i=1:nx
      tris(k+1,:)=[p1+i,p1+i+1,p3+i];
      tris(k+2,:)=[p1+i+1,p2+i+1,p3+i];
      tris(k+3,:)=[p2+i+1,p2+i,p3+i];
      tris(k+4,:)=[p1+i,p3+i,p2+i];
      k=k+4;
   end
end

% MakeMesh1 creates the mesh data structure from
% the triangle-node list:

T=MakeMesh1(nodes,tris,'Dirichlet');

