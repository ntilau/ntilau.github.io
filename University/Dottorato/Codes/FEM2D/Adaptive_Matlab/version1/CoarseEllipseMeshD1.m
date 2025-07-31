function T=CoarseEllipseMeshD1

% T=CoarseEllipseMeshD1
%
%   This function creates a coarse mesh (4 triangles) on the
%   ellipse x^2+y^2/4=1, assuming Dirichlet conditions.
%   See "help Mesh1" for a description of the mesh data
%   structure.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

T.Degree=1;
T.BndyFcn='Ellipsef';
T.Elements=[
1 2 3
-3 4 5
-5 6 7
-7 8 -1];
T.Edges=[
1 2
2 3
3 1
3 4
4 1
4 5
5 1
5 2];
T.EdgeEls=[
1 4
1 0
1 2
2 0
2 3
3 0
3 4
4 0];
T.EdgeCFlags=[
0
1
0
1
0
1
0
1];
T.Nodes=[
0 0
1 0
0 2
-1 0
0 -2];
T.NodePtrs=[1;-1;-2;-3;-4];
T.FNodePtrs=1;
T.CNodePtrs=(2:5)';
T.FBndyEdges=zeros(0,1);
