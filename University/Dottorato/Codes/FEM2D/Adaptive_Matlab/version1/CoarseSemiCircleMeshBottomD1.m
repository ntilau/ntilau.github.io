function T=CoarseSemiCircleMeshBottomD1

% T=CoarseSemiCircleMeshBottomD1
%
%   This function creates a coarse mesh (2 triangles) on
%   the upper half of the unit circle, assuming Dirichlet
%   conditions on the bottom edge and Neumann conditions
%   elsewhere.
%
%   See "help Mesh1" for a description of the mesh
%   data structure.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

T.Degree=1;
T.BndyFcn='Circlef';
T.Elements=[
1 2 3
-3 4 5];
T.Edges=[
1 2
2 3
3 1
3 4
4 1];
T.EdgeEls=[
1 0
1 -1
1 2
2 -2
2 0];
T.EdgeCFlags=[
0
1
0
1
0];
T.Nodes=[
0 0
1 0
0 1
-1 0];
T.NodePtrs=[-1;-2;1;-3];
T.FNodePtrs=3;
T.CNodePtrs=[1;2;4];
T.FBndyEdges=[2;4];
