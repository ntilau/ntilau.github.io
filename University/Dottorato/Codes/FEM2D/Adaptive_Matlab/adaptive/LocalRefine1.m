function [T,esterrs0,d0]=LocalRefine1(T,TList,hFrac,esterrs0,esterrs,d0,d)

% [T1,esterrs1,d1]=LocalRefine1(T,TList,hFrac,esterrs,d0,d)
%
%   This function performs a local refinement of the mesh
%   T, refining each triangle whose index belongs to TList.
%   Each T_i, i=TList(j), is refined until it is partitioned
%   into subtriangles whose diameters are all less than
%   hFrac(j) times the diameter of T_i (0<hFrac(j)<=1).
%
%   If hFrac is omitted, then hFrac(j) is taken to be 1 for
%   each j.
%
%   Certain data vectors are also updated for use with
%   local error estimation and adaptive refinement.
%   Input vectors are:
%           esterrs: (Nt by 1) The estimated errors on each
%                              triangle in the mesh T.
%           d0: (Nt by 1) The diameters of the supertriangles
%                         of the triangles in the mesh T.
%           d: (Nt by 1) The diameters of the triangles in T.
%
%   Output vectors:
%           esterrs1: (Nt1 by 1) The estimated errors from the
%                                supertriangles of the triangles
%                                in the output mesh T1.
%           d1: (Nt1 by 1) The diameters of the supertriangles
%                         of the triangles in the mesh T1.
%
%   The inputs esterrs, d0, and d are optional; if they are
%   not provided, then the outputs esterrs1, d1 are empty.
%
%   For a description of the mesh data structure, see
%   "help Mesh1".
%
%   The algorithm is the recursive newest node bisection.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if nargin<3 | isempty(hFrac)
   hFrac=ones(size(TList));
end

if nargin<6
   d0=[];
   esterrs=[];
end

% Automatically define bases if necessary.
% Notice that DefineBases uses a heuristic
% algorithm that is not guaranteed to produce
% an acceptable assignment of bases.

if ~isfield(T,'Bases')
   T=DefineBases(T);
end

% Get the number of triangles and set the limit:

Nt=size(T.Elements,1);
NtMax=8*Nt;
done=0;
while ~done

   % Refine the mesh:

   diams=getDiameters(T,TList);
   [T,params]=LocalRefine1a(T,TList);
   Nt1=size(T.Elements,1);

   % If requested, assign the old estimated errors
   % and the diameters of the parent triangles to
   % each triangle in the new mesh:

   if nargin==7 && nargout>=2

      % Identify the triangles that resulted from a bisection:

      j=find(params.SubTriangles(params.SuperTriangle,2)~=0);

      % The old error estimate for the subdivided triangles
      % must be updated:

      esterrs0=esterrs0(params.SuperTriangle);
      esterrs=esterrs(params.SuperTriangle);
      esterrs0(j)=esterrs(params.SuperTriangle(j));
      d0=d0(params.SuperTriangle);
      d=d(params.SuperTriangle);
      d0(j)=d(params.SuperTriangle(j));

   end

   % Stop if the maximum number of triangles has been reached:

   if Nt1>=NtMax
      done=1;
   else

      % Determine which triangles in T violate the bound:

      n=length(TList);
      TList1=[];
      hFrac1=[];
      for i=1:n
         j=1;
         k=abs(params.SubTriangles(TList(i),j));
         while j<=4 & k~=0
            l=getDiameter(T,k);
            if l>(1+1e-7)*hFrac(i)*diams(i)
               TList1=[TList1;k];
               hFrac1=[hFrac1;(diams(i)/l)*hFrac(i)];
            end
            j=j+1;
            if j<=4
               k=abs(params.SubTriangles(TList(i),j));
            end
         end
      end

      TList=TList1;
      hFrac=hFrac1;

      % Quit if all triangles are conforming:

      if isempty(TList)
         done=1;
      end

   end

end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [T,params]=LocalRefine1a(T,TList)

% [T1,params]=LocalRefine1a(T,TList)
%
%   This function performs a local refinement of the mesh T,
%   refining each triangle whose index belongs to TList.
%
%   params is a struct with the following fields:
%
%   SubTriangles (Nt1 by 4):
%      SubTriangles(i,:) lists the subtriangles of
%      the ith triangle in T, and also of the triangles
%      added to T to form T1 (a subtriangle of T can
%      itself be subdivided); the subtriangles are
%      triangles in T1.
%
%   SuperTriangle (Nt1 by 1):
%      SuperTriangle(i) is the triangle in T containing
%      triangle i from T1.
%
%   SubEdges (Ne by 3):
%      SubEdges(i,1:2) are the indices, in T1.Edges, of the two
%      subedges of T.Edges(i).  SubEdges(i,3) is the index, in
%      T1.Nodes, of the midpoint of T.Edges(i).

Nt=size(T.Elements,1);
Ne=size(T.Edges,1);
Nv=length(T.NodePtrs);

% Allocate the parameter arrays:

params.SubTriangles=[(1:Nt)',zeros(Nt,3)];
params.SuperTriangle=(1:Nt)';
params.SubEdges=zeros(Ne,3);

% The algorithm is simple: Bisect the triangles one by one
% by calling the recursive routine bisectTriangle.  No
% nonconforming triangles are ever created, but it may be
% that triangle TList(j) is bisected in the course of
% bisecting triangle TList(i), i<j.

n=length(TList);
for i=1:n
   if params.SubTriangles(TList(i),2)==0
      [T,params]=bisectTriangle(T,params,TList(i));
   end
end

% Define LevelNodes and NodeParents:

Nv1=length(T.NodePtrs);
if isfield(T,'LevelNodes')
   T.LevelNodes=[T.LevelNodes;Nv1];
   T.NodeParents=T.NodeParents;
else
   T.LevelNodes=[Nv;Nv1];
   T.NodeParents=[(1:Nv)',zeros(Nv,1)];
end

ii=find(params.SubEdges(:,1)~=0);
for i=1:length(ii)
   j=ii(i);
   T.NodeParents(params.SubEdges(j,3),:)=T.Edges(j,:);
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [T,params]=bisectTriangle(T,params,k)

% [T,params]=bisectTriangle(T,params,k)
%
%   This function bisects triangle k by its base,
%   provided triangle k and a neighbor share a base.
%   Otherwise, bisectTriangle is called recursively to
%   bisect the neighbor across the base.  No
%   nonconforming triangles are ever formed.

Nt=size(T.Elements,1);
Ne=size(T.Edges,1);
Nv=length(T.NodePtrs);
Nf=length(T.FNodePtrs);
Nc=length(T.CNodePtrs);
Nb=length(T.FBndyEdges);

% Get the index of the neighboring triangle (across the
% base):

b=T.Bases(k);
t1=getAdjacentTriangle(T,k,b);

% There are now three cases to consider (only the third
% case generates a recursive call to bisectTriangles):
%
%    1. The base of triangle k is a boundary edge.
%    2. A neighboring triangle has the same base
%       as triangle k.
%    3. The triangle on the other side of triangle
%       k has a different base.

if t1<=0

   % The base of triangle k is a boundary edge.

   % Get the edges of triangle k:

   [k1,k2,k3]=getOtherEdges(T,k,b);

   % Get the vertices of triangle k:

   i1=T.Edges(b,1);
   i2=T.Edges(b,2);
   i3=getOppositeVertex(T,k,i1,i2);

   % Create the midpoint of edge b:

   Nv=Nv+1;
   if T.EdgeCFlags(b)
      T.Nodes(Nv,:)=feval(T.BndyFcn,T.Nodes(i1,:),T.Nodes(i2,:));
   else
      T.Nodes(Nv,:)=0.5*(T.Nodes(i1,:)+T.Nodes(i2,:));
   end
   if t1==0
      Nc=Nc+1;
      T.NodePtrs(Nv)=-Nc;
      T.CNodePtrs(Nc)=Nv;
   else
      Nf=Nf+1;
      T.NodePtrs(Nv)=Nf;
      T.FNodePtrs(Nf)=Nv;
   end

   % Replace edge b by edges b and Ne+1 and update FBndyEdges:

   T.Edges(b,:)=[i1,Nv];
   T.Edges(Ne+1,:)=[Nv,i2];
   if t1<0
      T.FBndyEdges(Nb+1)=Ne+1;
      Nb=Nb+1;
   end
   T.EdgeCFlags(Ne+1)=T.EdgeCFlags(b);
   params.SubEdges(b,:)=[b,Ne+1,Nv];

   % Create a new edge to bisect triangle k:

   T.Edges(Ne+2,:)=[i3,Nv];
   T.EdgeEls(Ne+2,:)=[k,Nt+1];
   T.EdgeCFlags(Ne+2)=0;

   % Replace triangle k by triangles k and Nt+1 and update EdgeEls:

   if k1>0
      T.Elements(k,:)=[k1,-(Ne+2),k3];
      T.Elements(Nt+1,:)=[Ne+1,k2,Ne+2];
      if t1==0
         T.EdgeEls(Ne+1,:)=[Nt+1,0];
      else
         T.EdgeEls(Ne+1,:)=[Nt+1,-Nb];
      end
      if T.EdgeEls(abs(k2),1)==k
         T.EdgeEls(abs(k2),1)=Nt+1;
      else
         T.EdgeEls(abs(k2),2)=Nt+1;
      end
      T.Bases(k)=abs(k3);
      T.Bases(Nt+1)=abs(k2);
   else
      T.Elements(k,:)=[k1,k2,Ne+2];
      T.Elements(Nt+1,:)=[-(Ne+1),-(Ne+2),k3];
      if t1==0
         T.EdgeEls(Ne+1,:)=[Nt+1,0];
      else
         T.EdgeEls(Ne+1,:)=[Nt+1,-Nb];
      end
      if T.EdgeEls(abs(k3),1)==k
         T.EdgeEls(abs(k3),1)=Nt+1;
      else
         T.EdgeEls(abs(k3),2)=Nt+1;
      end
      T.Bases(k)=abs(k2);
      T.Bases(Nt+1)=abs(k3);
   end
   ii=min(find(params.SubTriangles(k,:)==0));
   params.SubTriangles(k,ii)=Nt+1;
   params.SubTriangles(Nt+1,1)=Nt+1;
   params.SuperTriangle(Nt+1)=params.SuperTriangle(k);

elseif T.Bases(t1)==b

   % An adjacent triangle shares the same base.

   % Get the edges of triangles k and t1:

   [k1,k2,k3]=getOtherEdges(T,k,b);
   [l1,k4,k5]=getOtherEdges(T,t1,b);

   % Get the vertices of triangles k and t1:

   i1=T.Edges(b,1);
   i2=T.Edges(b,2);
   i3=getOppositeVertex(T,k,i1,i2);
   i4=getOppositeVertex(T,t1,i1,i2);

   % Create the midpoint of edge b:

   Nv=Nv+1;
   T.Nodes(Nv,:)=0.5*(T.Nodes(i1,:)+T.Nodes(i2,:));
   Nf=Nf+1;
   T.NodePtrs(Nv)=Nf;
   T.FNodePtrs(Nf)=Nv;

   % Replace edge b by edges b and Ne+1:

   T.Edges(b,:)=[i1,Nv];
   T.Edges(Ne+1,:)=[Nv,i2];
   T.EdgeCFlags(Ne+1)=0;
   params.SubEdges(b,:)=[b,Ne+1,Nv];

   % Create a new edge to bisect triangle k:

   T.Edges(Ne+2,:)=[i3,Nv];
   T.EdgeEls(Ne+2,:)=[k,Nt+1];
   T.EdgeCFlags(Ne+2)=0;

   % Create a new edge to bisect triangle t1:

   T.Edges(Ne+3,:)=[i4,Nv];
   T.EdgeEls(Ne+3,:)=[t1,Nt+2];
   T.EdgeCFlags(Ne+3)=0;

   % Replace triangle k by triangles k and Nt+1 and triangle
   % t1 by t1 and Nt+2, and update EdgeEls:

   if k1>0
      T.Elements(k,:)=[k1,-(Ne+2),k3];
      T.Elements(Nt+1,:)=[Ne+1,k2,Ne+2];
      T.Elements(t1,:)=[-k1,k4,Ne+3];
      T.Elements(Nt+2,:)=[-(Ne+1),-(Ne+3),k5];
      T.EdgeEls(b,:)=[k,t1];
      T.EdgeEls(Ne+1,:)=[Nt+1,Nt+2];

      if T.EdgeEls(abs(k2),1)==k
         T.EdgeEls(abs(k2),1)=Nt+1;
      else
         T.EdgeEls(abs(k2),2)=Nt+1;
      end
      if T.EdgeEls(abs(k5),1)==t1
         T.EdgeEls(abs(k5),1)=Nt+2;
      else
         T.EdgeEls(abs(k5),2)=Nt+2;
      end
      T.Bases(k)=abs(k3);
      T.Bases(Nt+1)=abs(k2);
      T.Bases(t1)=abs(k4);
      T.Bases(Nt+2)=abs(k5);
   else
      T.Elements(k,:)=[k1,k2,Ne+2];
      T.Elements(Nt+1,:)=[-(Ne+1),-(Ne+2),k3];
      T.Elements(t1,:)=[-k1,-(Ne+3),k5];
      T.Elements(Nt+2,:)=[Ne+1,k4,Ne+3];
      T.EdgeEls(b,:)=[k,t1];
      T.EdgeEls(Ne+1,:)=[Nt+1,Nt+2];
      if T.EdgeEls(abs(k3),1)==k
         T.EdgeEls(abs(k3),1)=Nt+1;
      else
         T.EdgeEls(abs(k3),2)=Nt+1;
      end
      if T.EdgeEls(abs(k4),1)==t1
         T.EdgeEls(abs(k4),1)=Nt+2;
      else
         T.EdgeEls(abs(k4),2)=Nt+2;
      end
      T.Bases(k)=abs(k2);
      T.Bases(Nt+1)=abs(k3);
      T.Bases(t1)=abs(k5);
      T.Bases(Nt+2)=abs(k4);
   end
   ii=min(find(params.SubTriangles(k,:)==0));
   params.SubTriangles(k,ii)=Nt+1;
   params.SubTriangles(Nt+1,1)=Nt+1;
   params.SuperTriangle(Nt+1)=params.SuperTriangle(k);
   ii=min(find(params.SubTriangles(t1,:)==0));
   params.SubTriangles(t1,ii)=Nt+2;
   params.SubTriangles(Nt+2,1)=Nt+2;
   params.SuperTriangle(Nt+2)=params.SuperTriangle(t1);

else

   % The triangle on the other side of the base has a different
   % base.  Recursively refine that other triangle and then this
   % one.

   [T,params]=bisectTriangle(T,params,t1);
   [T,params]=bisectTriangle(T,params,k);
   
end
