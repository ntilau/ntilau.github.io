function h=getNeumannData2a(T,fnh)

% h=getNeumannData2(T,fnh)
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
%   The output is the Nb by d+1 array h, where Nb is
%   the number of free boundary edges and d is the
%   degree of the mesh.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Allocate the output array:

d=T.Degree;
Nb=length(T.FBndyEdges);
h=zeros(Nb,d+1);

for j=1:Nb

   % Get the indices of the triangle and the edge

   eptr=T.FBndyEdges(j);
   e=T.Edges(eptr,:);
   tri=T.EdgeEls(eptr,1);

   % Get the outward-pointing normal vector:

   ll=find(abs(T.Elements(tri,:))==eptr);
   nv=getNormal2(T,tri,ll);

   % Compute the Neumann data

   x=T.Nodes(e,1)';
   y=T.Nodes(e,2)';
   for k=1:d+1
      h(j,k)=feval(fnh,x(k),y(k),nv(1),nv(2));
   end

end
