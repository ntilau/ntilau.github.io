function T=unRefine1(T0)

% T=unRefine1(T0)
%
%   This function coarsens the input mesh T0, producing T.
%   The mesh T0 must be the output of Refine1.
%
%   For details about the mesh data structure, see
%   "help Mesh1".

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if T0.Degree~=1
   error('unRefine1 only accepts meshes of linear Lagrange triangles')
end

Nt0=size(T0.Elements,1);
Ne0=size(T0.Edges,1);
Nv0=size(T0.Nodes,1);
Nf0=length(T0.FNodePtrs);
Nc0=length(T0.CNodePtrs);
Nb0=size(T0.FBndyEdges,1);

T.Degree=1;
if isfield(T0,'BndyFcn')
   T.BndyFcn=T0.BndyFcn;
end

% Allocate storage for the coarsened mesh.

% The number of elements increases by a factor of 4

Nt=round(0.25*Nt0);
if Nt*4~=Nt0
   error('The input mesh must be the output from Refine1')
end
T.Elements=zeros(Nt,3);

% Calculate the number of edges in T and allocate T.Edges, T.EdgeEls

Ne1=Ne0-3*Nt;
Ne=round(Ne1/2);
if 2*Ne+3*Nt~=Ne0
   error('The input mesh must be the output from Refine1')
end
T.Edges=zeros(Ne,2);
T.EdgeEls=zeros(Ne,2);
T.EdgeCFlags=T0.EdgeCFlags(1:2:Ne1-1);
Ne=0;

% Extract the nodes belonging to the coarsened mesh:

if ~isfield(T0,'LevelNodes')
   error('The input mesh must be the output from Refine1')
end
nl=length(T0.LevelNodes);
if nl==1
   warning('Mesh cannot be unrefined')
   T=T0;
   return
end
Nv=T0.LevelNodes(nl-1);
T.Nodes=T0.Nodes(1:Nv,:);

% Extract the node pointers:

T.NodePtrs=T0.NodePtrs(1:Nv);
Nf=max(T.NodePtrs);
Nc=-min(T.NodePtrs);
T.CNodePtrs=T0.CNodePtrs(1:Nc);
T.FNodePtrs=T0.FNodePtrs(1:Nf);

% Extract the pointers to the free boundary edges:

T.FBndyEdges=ceil(T0.FBndyEdges(1:2:Nb0-1)/2);
Nb=length(T.FBndyEdges);

% Extract the LevelNodes and NodeParents arrays:

T.LevelNodes=T0.LevelNodes(1:nl-1);
T.NodeParents=T0.NodeParents(1:Nv,:);

% Define the edges in T:

T.Edges=[T0.Edges(1:2:Ne1-1,1),T0.Edges(2:2:Ne1,2)];

% Define EdgeEls in T:

T.EdgeEls(:,1)=ceil(T0.EdgeEls(1:2:Ne1-1,1)/4);
i1=find(T0.EdgeEls(1:Ne1,2)>0);i1=i1(2:2:end);
i2=find(T0.EdgeEls(1:Ne1,2)<0);i2=i2(2:2:end);
T.EdgeEls(i1/2,2)=ceil(T0.EdgeEls(i1,2)/4);
T.EdgeEls(i2/2,2)=-ceil(-T0.EdgeEls(i2,2)/2);

% Define the elements in T:

T.Elements=ceil(0.5*[T0.Elements(1:4:Nt0-3,1),T0.Elements(2:4:Nt0-2,2),...
                     T0.Elements(3:4:Nt0-1,3)]);
