function m=L2NormErr1(T,fnu,U,g)

% m=L2NormErr1(T,fnu,U,g)
%
%   This function estimates the L2 norm of the
%   difference between the smooth function u(x,y)
%   and the piecewise linear function defined by the
%   mesh T and the nodal values U.  The function
%   fnu implements u(x,y).
%
%   The optional input g is a vector containing
%   the nodal values of the piecewise linear function
%   at the constrained nodes.  If g is not given, these
%   values are taken to be zero.
%
%   See "help Mesh1" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if nargin<4 | isempty(g)
   g=zeros(size(T.CNodePtrs));
end

m=0;

% Loop over the triangles in the mesh

Nt=size(T.Elements,1);
for k=1:Nt

   % Get the coordinates of the vertices and their indices
   % in FNodePtrs and CNodePtrs:

   [c,ll]=getNodes1(T,k);

   % Record the nodal values of u(x,y)

   u=zeros(3,1);
   for j=1:3
      if ll(j)>0
         u(j)=U(ll(j));
      else
         u(j)=g(-ll(j));
      end
   end

   % Compute the linear function representing U on this triangle.
   % The coordinates of the vertices are contained in c.

   gu=[ones(3,1),c]\u;

   % Now add the contribution to the integral

   m=m+QuadL2Err1(c,fnu,gu);

end

m=sqrt(m);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function I = QuadL2Err1(c,u,av)

%  I = QuadL2Err1(c,u,av)
%
%    Integrates (u-v)^2 over the triangle with vertices
%    given by the coordinates in the 3x2 matrix c.  The function u
%    must be a real-valued function of two variables.  The function
%    v is linear, of the form v(x,y)=av(1)+av(2)*x+av(3)*y.
%
%    QuadL2Err1 uses a three-point quadrature rule.

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

f=(feval(u,qpts(:,1),qpts(:,2))-[ones(3,1) qpts]*av).^2;

% Estimate the integral

I=j/6*sum(f);
