function q=MeshQuality1(T,flag)

% q=MeshQuality1(T,flag)
%
%   This function computes, for each triangle in the
%   mesh T, a measure of its quality.  If flag==1,
%   the measure is
%          (2*sqrt(3))DT/diam(T),
%   where DT is the diameter of the inscribed circle
%   and diam(T) is the length of the longest side.
%
%   If flag==2, the measure is the ratio of twice the
%   radius of the inscribed circle to the radius of the
%   circumscribed circle.
%
%   If flag==3, the measure is the smallest angle of T
%   (in degrees).
%
%   For flag==1 or flag==2, the maximum ratio is 1, which
%   is achieved by an equilateral triangle.
%
%   flag is optional; the default is flag=1.
%
%   The ratios are returned in the Nt by 1 array q,
%   where Nt is the number of triangles in the mesh.
%
%   For a description of the data structure T, see
%   "help Mesh1".

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if nargin<2
   flag=1;
end

tris=getTriNodeIndices1(T);
b1=sqrt(sum((T.Nodes(tris(:,2),:)-T.Nodes(tris(:,1),:)).^2,2));
b2=sqrt(sum((T.Nodes(tris(:,3),:)-T.Nodes(tris(:,2),:)).^2,2));
b3=sqrt(sum((T.Nodes(tris(:,1),:)-T.Nodes(tris(:,3),:)).^2,2));

if flag==1
   x21=T.Nodes(tris(:,2),1)-T.Nodes(tris(:,1),1);
   y21=T.Nodes(tris(:,2),2)-T.Nodes(tris(:,1),2);
   x31=T.Nodes(tris(:,3),1)-T.Nodes(tris(:,1),1);
   y31=T.Nodes(tris(:,3),2)-T.Nodes(tris(:,1),2);
   vol=abs(x21.*y31-x31.*y21);
   q=(2*sqrt(3))*((vol./(b1+b2+b3))./max([b1,b2,b3],[],2));
elseif flag==2
   q=(b2+b3-b1).*(b3+b1-b2).*(b1+b2-b3)./(b1.*b2.*b3);
elseif flag==3
   a1=acos((b2.^2+b3.^2-b1.^2)./(2*b2.*b3));
   a2=acos((b1.^2+b3.^2-b2.^2)./(2*b1.*b3));
   a3=acos((b1.^2+b2.^2-b3.^2)./(2*b1.*b2));
   q=min([a1,a2,a3],[],2)*(180/pi);
else
   error('Unknown flag')
end
