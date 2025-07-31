function T1=ExtractLinearMesh(T)

% T1=ExtractLinearMesh(T)
%
%   This function extracts the mesh of linear Lagrange
%   triangles from a mesh T of higher degree.  The input
%   mesh T is assumed to have been created using
%   GenLagrangeMesh2.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

d=T.Degree;
if d==1
   T1=T;
   return
end

T1.Degree=1;
if isfield(T,'BndyFcn')
   T1.BndyFcn=T.BndyFcn;
end

% The elements are the same:

T1.Elements=T.Elements;

% The edges are the same, but there are now no edge nodes
% (only vertices):

T1.Edges=T.Edges(:,[1,d+1]);
T1.EdgeEls=T.EdgeEls;
T1.EdgeCFlags=T.EdgeCFlags;

% Since T was created by GenLagrangeMesh2, the first nonvertex
% node is the first edge node of the first edge:

Nv=T.Edges(1,2)-1;
T1.Nodes=T.Nodes(1:Nv,:);
T1.NodePtrs=T.NodePtrs(1:Nv);
Nf=max(T1.NodePtrs);
if Nf<0
   Nf=0;
end
T1.FNodePtrs=T.FNodePtrs(1:Nf);
Nc=-min(T1.NodePtrs);
if Nc<0
   Nc=0;
end
T1.CNodePtrs=T.CNodePtrs(1:Nc);

% The free boundary edges are unchanged:

T1.FBndyEdges=T.FBndyEdges;
