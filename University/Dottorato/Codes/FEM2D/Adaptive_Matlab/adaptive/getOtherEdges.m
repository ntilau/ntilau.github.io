function [k1,k2,k3]=getOtherEdges(T,j,k1)

% [k1,k2,k3]=getOtherEdges(T,j,k1)
%
%   This function extracts the (indices of the )
%   other two edges of triangle j from mesh T,
%   given that the index of one edge is k1.  The
%   edges are then given in the order k1,k2,k3,
%   as they are traced in counterclockwise order.
%   k1, k2, k3 are negative or positive, according
%   as the corresponding edge is traversed forward
%   or backwards.  See "help Mesh2" for details.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

a=abs(k1);
if a==abs(T.Elements(j,1))
   k1=T.Elements(j,1);
   k2=T.Elements(j,2);
   k3=T.Elements(j,3);
elseif a==abs(T.Elements(j,2))
   k1=T.Elements(j,2);
   k2=T.Elements(j,3);
   k3=T.Elements(j,1);
elseif a==abs(T.Elements(j,3))
   k1=T.Elements(j,3);
   k2=T.Elements(j,1);
   k3=T.Elements(j,2);
else
   T.Elements(j,:)
   error(['Edge ',int2str(k1),' does not belong to triangle ',int2str(j)]);
end
