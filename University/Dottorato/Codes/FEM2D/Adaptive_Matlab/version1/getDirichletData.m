function g=getDirichletData(T,u)

% g=getDirichletData(T,u)
%
%   This function assembles the Dirichlet data from
%   the mesh T and function u; that is, it evaluates
%   u at the constrained nodes of T.
%
%   The output is the Nc by 1 array g, where Nc is the
%   number of constrained nodes.
%
%   For a description of the data structure T, see
%   "help Mesh1".


%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

x=T.Nodes(T.CNodePtrs,1);
y=T.Nodes(T.CNodePtrs,2);
g=feval(u,x,y);
