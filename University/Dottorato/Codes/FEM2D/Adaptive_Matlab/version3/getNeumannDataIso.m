function h=getNeumannDataIso(T,u1x,u1y,u2x,u2y,fnmu,fnlam)

% h=getNeumannDataIso(T,u1x,u1y,u2x,u2y,fnmu,fnlam)
%
%   This function assembles the Neumann data
%
%              h=sig*n,
%
%   where sig is the stress tensor for the isotropic
%   elasticity model.
%
%   The inputs are the mesh T, the derivatives du1/dx (u1x),
%   du1/dy (u1y), du2/dx (u2x), and du2/dy (u2y) of
%   u and the functions mu and lam (fnmu and fnlam).
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

   % Get the outward-pointing normal vector:

   ll=find(abs(T.Elements(tri,:))==eptr);
   nv=getNormal(T,tri,ll);

   % Compute the Neumann data

   x=T.Nodes(e,1)';
   y=T.Nodes(e,2)';
   muvals=feval(fnmu,x,y);
   lamvals=feval(fnlam,x,y);
   u1xvals=feval(u1x,x,y);
   u1yvals=feval(u1y,x,y);
   u2xvals=feval(u2x,x,y);
   u2yvals=feval(u2y,x,y);
   twomulamvals=2*muvals+lamvals;
   s11vals=twomulamvals.*u1xvals+lamvals.*u2yvals;
   s22vals=twomulamvals.*u2yvals+lamvals.*u1xvals;
   s12vals=muvals.*(u1yvals+u2xvals);
   h(1,:,j)=s11vals.*nv(1,:)+s12vals.*nv(2,:);
   h(2,:,j)=s12vals.*nv(1,:)+s22vals.*nv(2,:);

end
