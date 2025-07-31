function n=getNormal1(T,i,j)

% n=getNormal1(T,i,j)
%
%   This function computes the outward-pointing
%   unit normal to the jth edge of the ith triangle
%   in the mesh T.  j is a local index (j=1,2,3).
%
%   See "help Mesh1" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

e=T.Elements(i,j);
c=T.Nodes(T.Edges(abs(e),1:2),:);
if e>0
   n=[c(2,2)-c(1,2);c(1,1)-c(2,1)];
else
   n=[c(1,2)-c(2,2);c(2,1)-c(1,1)];
end
n=n/norm(n);
