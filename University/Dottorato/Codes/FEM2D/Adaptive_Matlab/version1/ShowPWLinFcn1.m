function ShowPWLinFcn1(T,U,g,lw)

% ShowPWLinFcn1(T,U,g,lw)
%
%   This function draws a surface plot of a piecewise
%   linear function defined on a triangular mesh.
%   The inputs are T, the mesh,  and the vector U, giving
%   the nodal values of the function at the free nodes of
%   the mesh.
%
%   The optional input g is a vector of nodal values at
%   the constrained nodes.  If g is not given, this vector
%   is taken to be zero.
%
%   The optional input lw is the line width for the plot;
%   the default is lw=1.
%
%   For a description of the data structure T, see "help Mesh1".

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if nargin<4
   lw=1;
end

if nargin<3 | isempty(g)
   g=zeros(length(T.CNodePtrs),1);
end

X=T.Nodes(:,1);
Y=T.Nodes(:,2);
Z=zeros(length(X),1);
Z(T.FNodePtrs)=U;
Z(T.CNodePtrs)=g;
tri=getTriNodeIndices1(T);

trimesh(tri,X,Y,Z,'LineWidth',lw)
