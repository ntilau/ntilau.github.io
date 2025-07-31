function ShowMesh1(T,t,flags,C)

% ShowMesh1(T,t,flags,C)
%
%   This function displays a triangular mesh T and shades
%   the support of the nodal basis function associated with
%   node t. For a description of the data structure T, see
%   "help Mesh1".
%
%   The optional argument flags is an array of flags
%   with the following effects:
%
%    flags(1)==1: the nodes are labeled by their indices
%              2: the nodes are labeled by their NodePtrs
%    flags(2): the edges are labeled by their indices
%    flags(3): the triangles are labeled by their indices
%    flags(4)==1: the nodes are indicated by '.'
%            ==2: the nodes are indicated by 'o' for free and
%                  a star for constrained
%
%   (Flags(2) and Flags(3) are simply zero (off) or nonzero (on).)
%
%   The optional input C is the color of the shading; the default
%   is 'y' (yellow).

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Assign the optional arguments, if necessary:

if nargin<4
   C='y';
end

if nargin<3|isempty(flags)
   flags=zeros(1,4);
elseif length(flags)<4
   flags=[flags(:)',zeros(1,4-length(flags))];
end

% Display the mesh:

X=T.Nodes(:,1);
Y=T.Nodes(:,2);
tris=getTriNodeIndices1(T);
trimesh(tris,X,Y,zeros(size(X)),'facecolor','none','edgecolor','k');
if flags(4)==1
   hold on
   plot3(X,Y,zeros(size(X)),'.','MarkerSize',10)
   hold off
end
view(2)
axis('equal','off')

hold on

% Extract the number of triangles, edges, and nodes

Nt=size(T.Elements,1);
Ne=size(T.Edges,1);
Nv=length(T.Nodes);

% Shade the desired support and also label the triangles,
% if desired.

for i=1:Nt

   [c,ll,mm]=getNodes1(T,i);
   if any(mm==t)
      fill([c(:,1);c(1,1)],[c(:,2);c(1,2)],C)
   end
   if flags(3)
      x=mean(X(tris(i,:)));
      y=mean(Y(tris(i,:)));
      text(x,y,int2str(i),'FontSize',14,'Color','green')
   end

end

% Display the nodes and label them, if desired.

% First, figure out by how much to offset the labels

del=(max(abs(T.Nodes(:,1)))-min(abs(T.Nodes(:,1))))/50;

if flags(1) | flags(4)==2

   for i=1:Nv

      if T.NodePtrs(i)>0 & flags(4)==2
         plot(T.Nodes(i,1),T.Nodes(i,2),['o','b'])
      elseif T.NodePtrs(i)<0 & flags(4)==2
         plot(T.Nodes(i,1),T.Nodes(i,2),['h','b'])
      end

      if flags(1)==1
         text(T.Nodes(i,1)+del,T.Nodes(i,2),int2str(i),...
              'FontSize',14,'Color','blue')
      end

      if flags(1)==2
         text(T.Nodes(i,1)+del,T.Nodes(i,2),int2str(T.NodePtrs(i)),...
              'FontSize',14,'Color','magenta')
      end

   end

end

% Label the edges, if desired.

if flags(2)

   for i=1:Ne
      c=0.5*sum(T.Nodes(T.Edges(i,:),:));
      text(c(1),c(2),int2str(i),'FontSize',14,'Color','red')
   end

end

hold off
