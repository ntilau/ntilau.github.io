function T=NGonMeshD1(n)

% T=NGonMeshD1(n)
%
%   This function generates a coarse mesh on a regular
%   n-gon of area one, centered at the origin.  Dirichlet
%   boundary conditions are assumed.
%
%   Note: The mesh quality decreases as n increases;
%   the quality is okay if n is not too large (say n<=10).

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

r=sqrt(2/(n*sin(2*pi/n)));

T.Degree=1;
T.Elements=zeros(n,3);
T.Edges=zeros(2*n,2);
T.Nodes=zeros(n+1,2);

% Create the nodes:

T.Nodes(1,:)=[0,0];
for i=1:n
   th=2*pi*(i-1)/n;
   T.Nodes(i+1,:)=[r*cos(th),r*sin(th)];
end
T.FNodePtrs=1;
T.CNodePtrs=(2:n+1)';
T.NodePtrs=[1;-(1:n)'];

% Create the edges:

for i=1:n
   T.Edges(i,:)=[1,i+1];
   if i>1
      T.EdgeEls(i,:)=[i-1,i];
   else
      T.EdgeEls(1,:)=[n,1];
   end
   if i<n
      T.Edges(n+i,:)=[i+1,i+2];
   else
      T.Edges(2*n,:)=[n+1,2];
   end
   T.EdgeEls(n+i,:)=[i,0];
end
T.EdgeCFlags=zeros(2*n,1);

% Create the triangles:

for i=1:n-1
   T.Elements(i,:)=[i,n+i,-(i+1)];
end
T.Elements(n,:)=[n,2*n,-1];

T.FBndyEdges=zeros(0,1);
