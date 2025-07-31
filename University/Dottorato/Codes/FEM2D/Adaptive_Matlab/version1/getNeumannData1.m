function h=getNeumannData1(T,ux,uy,fnk)

% h=getNeumannData1(T,ux,uy,fnk)
%
%   This function assembles the Neumann data
%
%              h=k*du/dn
%
%   from the mesh T, the derivatives du/dx (ux) and
%   du/dy (uy) of u and the function k (fnk).
%   fnk can be a positive scalar or omitted, in which
%   case it is taken to be the constant function 1.
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

if nargin<4
   fnk=1;
end

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

   k=T.EdgeEls(eptr,1);
   ll=find(abs(T.Elements(k,:))==eptr);
   nv=getNormal1(T,k,ll);

   % Compute the Neumann data

   if isnumeric(fnk)
      k1=fnk;
      k2=fnk;
   else
      k1=feval(fnk,e1(1),e1(2));
      k2=feval(fnk,e2(1),e2(2));
   end
   g1=[feval(ux,e1(1),e1(2));feval(uy,e1(1),e1(2))];
   g2=[feval(ux,e2(1),e2(2));feval(uy,e2(1),e2(2))];
   h(j,:)=[k1*dot(g1,nv),k2*dot(g2,nv)];

end
