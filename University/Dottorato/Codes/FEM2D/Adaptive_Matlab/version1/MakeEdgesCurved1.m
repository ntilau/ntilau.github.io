function T=MakeEdgesCurved1(T,BndyFcn)

% T=MakeEdgesCurved1(T,BndyFcn)
%
%   This function defines all boundary edges
%   in the input mesh to be curved and defines
%   BndyFcn to be the boundary function of the
%   mesh.
%
%   See "help Mesh1" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

T.EdgeCFlags=(T.EdgeEls(:,2)<=0);
T.BndyFcn=BndyFcn;
