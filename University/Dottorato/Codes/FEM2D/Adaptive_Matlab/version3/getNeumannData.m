function h=getNeumannData(T,ux,uy,fnk)

% h=getNeumannData(T,ux,uy,fnk)
%
%   This function assembles the Neumann data
%
%              h=k*du/dn
%
%   from the mesh T, the derivatives du/dx (ux) and
%   du/dy (uy) of u and the function k (fnk).
%
%   The output is the Nb by d+1 array h, where Nb is
%   the number of free boundary edges and d is the
%   degree of the mesh.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if nargin<4
   fnk=1.0;
end

% Allocate the output array:

d=T.Degree;
Nb=length(T.FBndyEdges);
h=zeros(Nb,d+1);

for j=1:Nb

   % Get the indices of the triangle and the edge

   eptr=T.FBndyEdges(j);
   e=T.Edges(eptr,:);
   tri=T.EdgeEls(eptr,1);

   % Get the outward-pointing normal vectors:

   ll=find(abs(T.Elements(tri,:))==eptr);
   nv=getNormal(T,tri,ll);

   % Compute the Neumann data

   x=T.Nodes(e,1)';
   y=T.Nodes(e,2)';
   if isnumeric(fnk)
      kvals=fnk*ones(1,d+1);
   else
      kvals=feval(fnk,x,y);
   end
   grads=[feval(ux,x,y);feval(uy,x,y)];
   h(j,:)=kvals.*(nv(1,:).*grads(1,:)+nv(2,:).*grads(2,:));

end
