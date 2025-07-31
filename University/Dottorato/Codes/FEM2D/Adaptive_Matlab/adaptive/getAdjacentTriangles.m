function t=getAdjacentTriangles(T,i)

% t=getAdjacentTriangles(T,i)
%
%   This function returns the indices of the triangles
%   adjacent to triangle i of mesh T.  Two triangles
%   are adjacent if they share an edge; if an edge of
%   triangle i is a boundary edge, then the
%   corresponding index is set to zero for a constrained
%   edge and the negative of its index, in the list of
%   free boundary edges, for a free edge.
%
%   See "help Mesh2" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Get the pointers to the edges:

e=abs(T.Elements(i,:));

% Loop over the edge and get the indices to the adjacent
% triangles:

t=zeros(3,1);
for j=1:3
   if T.EdgeEls(e(j),1)~=i
      t(j)=T.EdgeEls(e(j),1);
   else
      t(j)=T.EdgeEls(e(j),2);
   end
end
