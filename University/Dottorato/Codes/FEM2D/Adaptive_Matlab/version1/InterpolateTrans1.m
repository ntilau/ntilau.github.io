function [U,g]=InterpolateTrans1(T1,T,U1,g1)

% [U,g]=InterpolateTrans1(T1,T,U1,g1)
%
%   This function implements the transpose
%   of the operator implemented in Interpolate1.
%   See "help Interpolate1" for details.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if nargin<4 | isempty(g1)
   g1=zeros(length(T1.CNodePtrs),1);
end

% Get the number of refinement levels in T and T1:

if isfield(T,'LevelNodes')
   nl=length(T.LevelNodes);
else
   nl=1;
end
if ~isfield(T1,'LevelNodes')
   error('Field LevelNodes not defined in T1')
else
   nl1=length(T1.LevelNodes);
end

% Assign the nodal values from T1 to V1:

Nv1=length(T1.NodePtrs);
V1=zeros(Nv1,1);
V1(T1.FNodePtrs)=U1;
V1(T1.CNodePtrs)=g1;

% Now perform the successive transformations:

for k=nl1-1:-1:nl
   for i=T1.LevelNodes(k)+1:T1.LevelNodes(k+1)
      t=0.5*V1(i);
      e1=T1.NodeParents(i,1);
      e2=T1.NodeParents(i,2);
      V1(e1)=V1(e1)+t;
      V1(e2)=V1(e2)+t;
   end
end

% Finally, extract the nodal values:

if nargout>1
   g=V1(T.CNodePtrs);
end
U=V1(T.FNodePtrs);
