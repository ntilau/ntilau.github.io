function [U1,g1]=Interpolate1(T,T1,U,g)

% [U1,g1]=Interpolate1(T,T1,U,g)
%
%   This function interpolates a piecewise linear
%   function, defined by nodal values (U,g) on mesh
%   T, onto the finer mesh T1.  T1 must be obtained
%   from T by one or more applications of Refine1 or
%   LocalRefine1.
%
%   See "help Mesh1" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if nargin<4 | isempty(g)
   g=zeros(length(T.CNodePtrs),1);
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

% Assign the nodal values from T to V:

Nv1=length(T1.NodePtrs);
U1=zeros(Nv1,1);
U1(T.FNodePtrs)=U;
U1(T.CNodePtrs)=g;

% Now perform the successive interpolations:

for k=nl:nl1-1
   for i=T1.LevelNodes(k)+1:T1.LevelNodes(k+1)
      U1(i)=0.5*(U1(T1.NodeParents(i,1))+U1(T1.NodeParents(i,2)));
   end
end

% Finally, extract the nodal values:

if nargout>1
   g1=U1(T1.CNodePtrs);
end
U1=U1(T1.FNodePtrs);
