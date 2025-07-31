function t=getAdjacentTriangle(T,k,e)

% t=getAdjacentTriangle(T,k,e)
%
%   This function returns the index of the triangle
%   across edge e of triangle k.  (e is the global
%   index of the edge).  An error occurs if edge e
%   does not belong to triangle k.  If edge e is a
%   boundary edge, then the corresponding index is
%   0 for a constrained edge or the negative of its
%   index, in the list of free boundary edges, for
%   a free edge.
%
%   See "help Mesh2" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if T.EdgeEls(e,1)==k
   t=T.EdgeEls(e,2);
elseif T.EdgeEls(e,2)==k
   t=T.EdgeEls(e,1);
else
   error(['Edge ',int2str(e),' does not belong to triangle ',int2str(k)])
end
