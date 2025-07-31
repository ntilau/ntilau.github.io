function [coords,ptrs,indices]=getNodes1(T,i)

% [coords,ptrs,indices]=getNodes1(T,i)
%
%   This function extracts the nodes (vertices) from
%   triangle i of mesh T.  The output is
%
%       coords: 3 by 2 array; coordinates of the vertices.
%       ptrs: Pointers into FNodePtrs and CNodePtrs of the
%             vertices (extracted from NodePtrs).
%       indices: Indices of the nodes in Nodes.
%
%   See "help Mesh1" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% First, get the edges of T_i:

eptrs=T.Elements(i,:);

% Get the indices of the endpoints of the edges:

j=T.Edges(abs(eptrs),1:2);

% Extract the indices of the vertices (avoid repetitions):

indices=zeros(3,1);
if eptrs(1)>0
   indices(1)=j(1,1);
   indices(2)=j(1,2);
else
   indices(1)=j(1,2);
   indices(2)=j(1,1);
end
if eptrs(2)>0
   indices(3)=j(2,2);
else
   indices(3)=j(2,1);
end

% Extract the coordinates and pointers:

coords=T.Nodes(indices,1:2);
ptrs=T.NodePtrs(indices);
