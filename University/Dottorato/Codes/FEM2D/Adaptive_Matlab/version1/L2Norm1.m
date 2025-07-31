function m=L2Norm1(T,fnu)

% m=L2Norm1(T,fnu)
%
%   This function estimates the L2 norm of the smooth
%   function u(x,y) by integrating over the triangles
%   of the mesh T.  The input fnu implements u(x,y).
%   Notice that the result might be inaccurate if the
%   mesh is too coarse.
%
%   See "help Mesh1" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

m=0;

% Loop over the triangles in the mesh

Nt=size(T.Elements,1);
for k=1:Nt

   % Get the coordinates of the vertices of this triangle:

   c=getNodes1(T,k);

   % Now add the contribution to the integral

   m=m+QuadL21(c,fnu);

end

m=sqrt(m);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function I = QuadL21(c,u)

%  I = QuadL21(c,u)
%
%    Integrates u^2 over the triangle with vertices
%    given by the coordinates in the 3x2 matrix c.  The function u
%    must be a real-valued function of two variables.
%
%    QuadL21 uses a three-point quadrature rule.

% Compute the Jacobian factor:

j=abs(det([c(2,1)-c(1,1) c(3,1)-c(1,1);c(2,2)-c(1,2) c(3,2)-c(1,2)]));

% Compute the nodes (the barycentric coordinates are
% (1/6,1/6,2/3), (1/6,2/3,1/6), (2/3,1/6,1/6)):

c1=1/6;c2=2/3;
qpts=[
c1 c1 c2
c1 c2 c1
c2 c1 c1]*c;

% Evaluate the integrand at the quadrature nodes:

f=feval(u,qpts(:,1),qpts(:,2)).^2;

% Estimate the integral

I=j/6*sum(f);
