function m=EnergyNormErr1(T,fnk,fnux,fnuy,U,g)

% m=EnergyNormErr1(T,fnk,fnux,fnuy,U,g)
%
%   This function computes the energy norm of the
%   difference between the smooth function u(x,y)
%   and the piecewise linear function defined by
%   the mesh T and the nodal values U.  The
%   function fnk is the weight in the energy inner
%   product, while fnux and fnuy are the partial
%   derivatives of u(x,y).  fnux and fnuy must be
%   real-valued functions of two real variables,
%   while fnk can be a positive scalar or a function.
%
%   The optional input g is a vector containing the
%   nodal values of the piecewise linear function at
%   the constrained nodes.  If g is not given, these
%   values are taken to be zero.
%
%   See "help Mesh1" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if nargin<6 || isempty(g)
   g=zeros(size(T.CNodePtrs));
end

if isempty(fnk)
   fnk=1.0;
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

   % Compute the gradient of u(x,y) on this triangle.

   M=[ones(3,1),c];
   gu=M\u;

   % Now add the contribution to the integral

   m=m+QuadEnergyErr1(c,fnk,fnux,fnuy,gu);

end

m=sqrt(m);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function I = QuadEnergyErr1(c,k,ux,uy,av)

%  I = QuadEnergyErr1(c,k,ux,uy,av)
%
%    Integrates k*||grad u-grad v||^2 over the triangle with vertices
%    given by the coordinates in the 3x2 matrix c.  The gradient of u
%    is given directly by the functions ux, uy, which must be real-valued
%    functions of two variables.  The function v is linear, of the
%    form v(x,y)=av(1)+av(2)*x+av(3)*y.
%
%    QuadEnergyErr1 uses a three-point quadrature rule.

% Compute the Jacobian factor:

j=abs(det([c(2,1)-c(1,1) c(3,1)-c(1,1);c(2,2)-c(1,2) c(3,2)-c(1,2)]));

% Compute the nodes (the barycentric coordinates are
% (1/6,1/6,2/3), (1/6,2/3,1/6), (2/3,1/6,1/6)):

c1=1/6;c2=2/3;
qpts=[
c1 c1 c2
c1 c2 c1
c2 c1 c1]*c;

% Estimate the integral

if isnumeric(k)
   kvals=[k;k;k];
else
   kvals=feval(k,qpts(:,1),qpts(:,2));
end
uxvals=feval(ux,qpts(:,1),qpts(:,2));
uyvals=feval(uy,qpts(:,1),qpts(:,2));

I=(j/6)*(kvals'*((uxvals-av(2)).^2+(uyvals-av(3)).^2));
