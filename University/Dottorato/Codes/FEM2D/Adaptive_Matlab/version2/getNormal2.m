function n=getNormal2(T,i,j)

% n=getNormal2(T,i,j)
%
%   This function computes the outward-pointing unit
%   normal to the jth edge of triangle T_i.  j is a
%   local index (j=1,2,3).

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

d=T.Degree;

e=T.Elements(i,j);
c=T.Nodes(T.Edges(abs(e),[1,d+1]),:);
if e>0
   n=[c(2,2)-c(1,2);c(1,1)-c(2,1)];
else
   n=[c(1,2)-c(2,2);c(2,1)-c(1,1)];
end
n=n/norm(n);
