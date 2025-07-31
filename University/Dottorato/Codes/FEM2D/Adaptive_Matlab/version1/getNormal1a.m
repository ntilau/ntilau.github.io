function n=getNormal1a(T,i,e)

% n=getNormal1(T,i,e)
%
%   This function computes the outward-pointing unit
%   normal to eth edge, which belongs to the ith
%   triangle of mesh T.  e and i are global indices.
%
%   See "help Mesh1" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

j=find(e==abs(T.Elements(i,:)));
if isempty(j)
   error(['Edge ',int2str(e),' does not belong to triangle ',int2str(i)])
end
e1=T.Elements(i,j);
c=T.Nodes(T.Edges(e,1:2),:);
if e1>0
   n=[c(2,2)-c(1,2);c(1,1)-c(2,1)];
else
   n=[c(1,2)-c(2,2);c(2,1)-c(1,1)];
end
n=n/norm(n);
