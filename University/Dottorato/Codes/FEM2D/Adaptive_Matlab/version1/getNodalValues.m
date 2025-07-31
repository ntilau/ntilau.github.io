function [U,g]=getNodalValues(T,u)

% [U,g]=getNodalValues(T,u)
%
%   This function computes the nodal values of the
%   function u on the mesh T.
%
%   The Nf by 1 array U contains the nodal values at
%   the free nodes, while the Nc by 1 array g contains
%   the nodal values at the constrained nodes.
%
%   See "help Mesh1" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

x=T.Nodes(T.FNodePtrs,1);
y=T.Nodes(T.FNodePtrs,2);
U=feval(u,x,y);

if nargout==2
   x=T.Nodes(T.CNodePtrs,1);
   y=T.Nodes(T.CNodePtrs,2);
   g=feval(u,x,y);
end

