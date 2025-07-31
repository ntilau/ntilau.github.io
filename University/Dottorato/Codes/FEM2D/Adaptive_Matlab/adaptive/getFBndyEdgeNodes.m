function c=getFBndyEdgeNodes(T,i)

% c=getFBndyEdgeNodes(T,i)
%
%   This function returns the coordinates of the
%   nodes on the ith free boundary edge of the mesh T.
%   The result is the d+1 by 2 array c; each row
%   contains the coordinates of one node (d is the
%   degree of the mesh).
%
%   See "help Mesh2" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

Nb=length(T.FBndyEdges);
if i>Nb
   error('Invalid edge')
end
d=T.Degree;

% Get the node pointers:

ptrs=T.Edges(T.FBndyEdges(i),:);

% Extract the coordinates:

c=T.Nodes(ptrs,1:2);
