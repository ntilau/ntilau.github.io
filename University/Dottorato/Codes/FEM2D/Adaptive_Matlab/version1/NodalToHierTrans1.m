function [V,w]=NodalToHierTrans1(T,U,g)

% [V,w]=NodalToHierTrans1(T,U,g)
%
%   This function implements the transpose
%   of the linear operator implemented by
%   NodalToHier1.  See "help NodalToHier1"
%   for details.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if T.Degree~=1
   error('The mesh must be piecewise linear')
end

if ~isfield(T,'LevelNodes')
   error('T must have been created using Refine1')
end

nl=length(T.LevelNodes);

Nv=size(T.Nodes,1);
V=zeros(Nv,1);
V(T.FNodePtrs)=U;
if nargin>2
   V(T.CNodePtrs)=g;
end

for k=2:nl
   for i=T.LevelNodes(k-1)+1:T.LevelNodes(k)
      i1=T.NodeParents(i,1);
      i2=T.NodeParents(i,2);
      V(i1)=V(i1)-0.5*V(i);
      V(i2)=V(i2)-0.5*V(i);
   end
end

if nargout>1
   w=V(T.CNodePtrs);
end
V=V(T.FNodePtrs);
