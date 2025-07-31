function h=getNeumannData1a(T,fnh)

% h=getNeumannData1a(T,fnh)
%
%   This function assembles the Neumann data
%
%              h=k*du/dn
%
%   from the mesh T and the function h.  h must
%   be of the form h(x,y,nx,ny) (the inputs
%   are the coordinates of the point (x,y) and
%   the normal vector (nx,ny)).
%
%   The output is the Nb by 2 array h, where Nb is the
%   number of free boundary edges, containing the
%   values of h at the endpoints of the free boundary
%   edges.
%
%   See "help Mesh1" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Allocate the output array:

Nb=length(T.FBndyEdges);
h=zeros(Nb,2);

for j=1:Nb

   % Get the indices of the triangle and the edge

   eptr=T.FBndyEdges(j);
   e=T.Edges(eptr,:);
   tri=T.EdgeEls(eptr,1);

   % Get the coordinates of the endpoints of
   % the free edge

   e1=T.Nodes(e(1),:);
   e2=T.Nodes(e(2),:);

   % Get the outward-pointing normal vector:

   ll=find(abs(T.Elements(tri,:))==eptr);
   nv=getNormal1(T,tri,ll);

   h(j,1)=feval(fnh,e1(1),e1(2),nv(1),nv(2));
   h(j,2)=feval(fnh,e2(1),e2(2),nv(1),nv(2));

end
