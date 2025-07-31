function m=L2Norm2(T,fnu,qo)

% m=L2Norm2(T,fnu,qo)
%
%   This function estimates the L2 norm of a smooth
%   function u by integrating over the triangles in
%   the mesh T. See "help Mesh2" for a description of
%   the mesh T.  Notice that the result might be
%   inaccurate if the mesh is too coarse.
%
%   qo is the (optional) quadrature order; the default
%   is qo=2*d+2, where d is the degree of the mesh.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

d=T.Degree;
if nargin<3
   qo=2*d+2;
end

m=0;

% Loop over the triangles in the mesh

Nt=size(T.Elements,1);
for i=1:Nt

   % Get the coordinate of the vertices

   [coords,ll]=getNodes(T,i);
   c=coords(1:d:3*d,1:2);

   % Get the quadrature nodes and weights on the triangle:

   [qpts,qwts]=DunavantData(qo,c);

   % Compute fnu at all the nodes:

   uvals=feval(fnu,qpts(:,1),qpts(:,2));

   % Now add the contribution to the integral

   m=m+qwts'*(uvals.^2);

end

m=sqrt(m);

