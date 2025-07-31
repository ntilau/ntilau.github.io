function h=getNeumannDataIsoa(T,hfn)

% h=getNeumannDataIsoa(T,hfn)
%
%   This function assembles the Neumann data for
%   the system of elasticity, where the boundary
%   condition is
%
%              sig*n=h on Bndy Omega.
%
%   The inputs are the mesh T and the function
%   hfn=hfn(x,y,nx,ny), where (x,y) is a point on the
%   boundary of Omega and (nx,ny) is the normal
%   vector there.
%
%   The output is the 2 by (d+1) by Nb array h, where Nb
%   is the number of free boundary edges and d is
%   the degree of the mesh.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Allocate the output array:

d=T.Degree;
Nb=length(T.FBndyEdges);
h=zeros(2,d+1,Nb);

for j=1:Nb

   % Get the indices of the triangle and the edge

   eptr=T.FBndyEdges(j);
   e=T.Edges(eptr,:);
   tri=T.EdgeEls(eptr,1);

   % Get the outward-pointing normal vector and the coordinates
   % of the nodes:

   ll=find(abs(T.Elements(tri,:))==eptr);
   nv=getNormal(T,tri,ll);
   x=T.Nodes(e,1)';
   y=T.Nodes(e,2)';

   % Compute the Neumann data

   for i=1:d+1
      h(:,i,j)=feval(hfn,x(i),y(i),nv(1,i),nv(2,i));
   end

end
