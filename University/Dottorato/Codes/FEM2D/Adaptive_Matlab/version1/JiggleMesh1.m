function nodes=JiggleMesh1(T,num)

% nodes=JiggleMesh1(T,num)
%
%   This function improves the quality of mesh T by moving
%   the interior nodes.  The coordinates of new nodes are
%   returned Nv by 2 array nodes.  T.Nodes(i,:) is moved
%   to nodes(i,:)
%
%   The optional input num is the number of times to jiggle
%   the mesh.  The default is num=1.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

%   Adapted from jigglemesh from the MATLAB PDE toolbox.

if nargin<2
   num=1;
end

% Find the interior nodes of the mesh:

Nv=length(T.NodePtrs);
bedges=find(T.EdgeEls(:,2)<=0);
e=sort([T.Edges(bedges,1);T.Edges(bedges,2)]);
bnodes=e(find([1;diff(e)]));
i=ones(Nv,1);
i(bnodes)=0;
inodes=find(i);

% Get the triangle-node list:

tris=getTriNodeIndices1(T);

for ii=1:num

   % Column j of X contains the x-coordinates of the nodes
   % adjacent to z_j; similarly for Y:

   X=sparse(tris(:),[tris(:,2);tris(:,3);tris(:,1)],T.Nodes(tris(:),1),Nv,Nv);
   Y=sparse(tris(:),[tris(:,2);tris(:,3);tris(:,1)],T.Nodes(tris(:),2),Nv,Nv);
   N=sparse(tris(:),[tris(:,2);tris(:,3);tris(:,1)],ones(size(tris(:))),Nv,Nv);

   % Compute the number of nodes adjacent to each node:

   m=sum(N);

   % Average the nodes adjacent to each node:

   X=(sum(X)./m)';
   Y=(sum(Y)./m)';

   % Now assign the new nodes (remember, boundary nodes do not
   % move:

   T.Nodes(inodes,:)=[X(inodes),Y(inodes)];

end

nodes=T.Nodes;
