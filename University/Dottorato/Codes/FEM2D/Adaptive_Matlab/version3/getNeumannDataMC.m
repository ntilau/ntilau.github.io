function h=getNeumannDataMC(T,ux,uy,fnA)

% h=getNeumannDataMC(T,ux,uy,fnA)
%
%   This function assembles the Neumann data
%
%              h=(A*grad u).n
%
%   from the mesh T, the derivatives du/dx (ux) and
%   du/dy (uy) of u and the matrix-valued function
%   A (fnA).  If x,y are vectors of length n, then
%   fnA(x,y) returns a 2 by 2 by n array containing
%   the values of A.
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

   % Get the outward-pointing normal vectors:

   ll=find(abs(T.Elements(tri,:))==eptr);
   nv=getNormal(T,tri,ll);

   % Compute the Neumann data

   x=T.Nodes(e,1)';
   y=T.Nodes(e,2)';
   grads=[feval(ux,x,y);feval(uy,x,y)];
   Avals=feval(fnA,x,y);
   for i=1:d+1
      h(j,i)=dot(Avals(:,:,i)*grads(:,i),nv(:,i));
   end

end
