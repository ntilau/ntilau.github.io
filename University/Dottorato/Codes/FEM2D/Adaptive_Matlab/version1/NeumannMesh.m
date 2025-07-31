function T=NeumannMesh(T)

% T=NeumannMesh(T0)
%
%   This function converts a mesh T0 to the mesh T
%   in which every node is free.
%
%   See "help Mesh1" for details on the mesh data
%   structure.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

Nv=length(T.NodePtrs);

% All boundary edges are now free, so find them and mark them as
% such:

Nb0=length(T.FBndyEdges);
i1=find(T.EdgeEls(:,2)<0);
i2=find(T.EdgeEls(:,2)==0);
T.FBndyEdges=[T.FBndyEdges;i2];
Nb=length(T.FBndyEdges);
T.EdgeEls(i2,2)=-(Nb0+1:Nb)';

% All constrained nodes become free nodes:

Nf0=length(T.FNodePtrs);
i1=T.CNodePtrs;
T.FNodePtrs=[T.FNodePtrs;i1];
Nf=length(T.FNodePtrs);
T.NodePtrs(i1)=(Nf0+1:Nf)';
T.CNodePtrs=zeros(0,1);
