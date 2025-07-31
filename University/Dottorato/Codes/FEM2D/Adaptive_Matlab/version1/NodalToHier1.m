function [V,w]=NodalToHier1(T,U,g)

% [V,w]=NodalToHier1(T,U,g)
%
%   This function converts a vector of nodal
%   values to the coefficients referring to the
%   hierarchical basis.  The mesh T must have
%   been created from an initial mesh through
%   one or more applications of Refine1.  U
%   stores the coefficients expressing a
%   continuous piecewise linear function in
%   terms of the hierarchical basis functions
%   corresponding to the free nodes in T.  Upon
%   output, V holds the values of the function
%   at the free nodes.  Similarly, w and g hold
%   the input and output values corresponding
%   to the constrained nodes.
%
%   See "help Mesh1" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if T.Degree~=1
   error('The mesh must be piecewise linear')
end

if ~isfield(T,'LevelNodes')
   error('T must have been created using Refine1')
end

Nv=size(T.Nodes,1);
V=zeros(Nv,1);
V(T.FNodePtrs)=U;
if nargin==3
   V(T.CNodePtrs)=g;
end

nl=length(T.LevelNodes);

for k=nl:-1:2
   for i=T.LevelNodes(k-1)+1:T.LevelNodes(k)
      V(i)=V(i)-0.5*(V(T.NodeParents(i,1))+V(T.NodeParents(i,2)));
   end
end

if nargout==2
   w=V(T.CNodePtrs);
end
V=V(T.FNodePtrs);
