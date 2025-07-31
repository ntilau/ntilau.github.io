function T=RefTri(d)

% T=RefTri(d)
%
%   This function create a the reference Lagrange
%   triangle of of degree d.  The vertices are (0,0),
%   (1,0), and (0,1).
%
%   For a description of the data structure T, see
%   "help Mesh2".

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

T0.Degree=1;
T0.Elements=[1 2 3];
T0.Edges=[
1 2
2 3
3 1];
T0.EdgeEls=[
1 -1
1 -2
1 -3];
T0.EdgeCFlags=zeros(3,1);
T0.Nodes=[
0 0
1 0
0 1];
T0.NodePtrs=[1;2;3];
T0.FNodePtrs=[1;2;3];
T0.CNodePtrs=zeros(0,1);
T0.FBndyEdges=[1;2;3];

T=GenLagrangeMesh2(T0,d);
