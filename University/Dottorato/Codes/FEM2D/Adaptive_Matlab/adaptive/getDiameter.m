function h=getDiameter(T,j)

% h=getDiameter(T,j)
%
%   This function computes the diameter of triangle
%   j of mesh T.
%
%   See "help Mesh2" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

d=T.Degree;
h=-inf;
for i=1:3
   k=abs(T.Elements(j,i));
   h=max(h,norm(T.Nodes(T.Edges(k,1),:)-T.Nodes(T.Edges(k,d+1),:)));
end
