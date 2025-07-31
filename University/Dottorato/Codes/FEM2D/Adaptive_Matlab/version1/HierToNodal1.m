function [U,g]=HierToNodal1(T,V,w)

% [U,g]=HierToNodal1(T,V,w)
%
%   This function converts coefficients referring
%   to the hierarchical basis to nodal values.
%   The mesh T must have been created from an
%   initial mesh through one or more applications
%   of Refine1.  V stores the coefficients expressing
%   a continuous piecewise linear function in terms
%   of the hierarchical basis functions corresponding
%   to the free nodes in T.  Upon output, U holds the
%   values of the function at the free nodes.  Similarly,
%   w and g hold the input and output values corresponding
%   to the constrained nodes.
%
%   See "help Mesh1" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if T.Degree~=1
   error('The mesh must consist of linear triangles')
end

if ~isfield(T,'LevelNodes')
   error('T must have been created using Refine1')
end

Nv=size(T.Nodes,1);
U=zeros(Nv,1);
U(T.FNodePtrs)=V;
if nargin==3
   U(T.CNodePtrs)=w;
end

nl=length(T.LevelNodes);

for k=2:nl
   for i=T.LevelNodes(k-1)+1:T.LevelNodes(k)
      U(i)=U(i)+0.5*(U(T.NodeParents(i,1))+U(T.NodeParents(i,2)));
   end
end

if nargout==2
   g=U(T.CNodePtrs);
end
U=U(T.FNodePtrs);
