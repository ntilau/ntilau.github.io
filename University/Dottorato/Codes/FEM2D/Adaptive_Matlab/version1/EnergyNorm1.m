function m=EnergyNorm1(T,fnk,fnux,fnuy)

% m=EnergyNorm1(T,fnk,fnux,fnuy)
%
%   This function estimates the energy norm of a
%   smooth function u by integrating over the triangles
%   in the mesh T.  Notice that the result might be
%   inaccurate if the mesh is too coarse.
%
%   The function fnk is the weight k(x,y) in the energy
%   inner product.  If k is constant, fnk can be a
%   positive scalar.
%
%   fnux and fnuy are the partial derivatives of u(x,y).
%   Each of these functions must  be a real-valued
%   function of two real variables.
%
%   See "help Mesh1" for a description of the mesh T. 

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if isempty(fnk)
   fnk=1.0;
end

m=0;

% Loop over the triangles in the mesh

Nt=size(T.Elements,1);
for k=1:Nt

   % Get the coordinates of the vertices

   c=getNodes1(T,k);

   % Now add the contribution to the integral

   m=m+QuadEnergy1(c,fnk,fnux,fnuy);

end

m=sqrt(m);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function I = QuadEnergy1(c,k,ux,uy)

%  I = QuadEnergy1(c,k,ux,uy)
%
%    Integrates the k*||grad u||^2 over the triangle with vertices
%    given by the coordinates in the 3x2 matrix c.  The gradient of u
%    is given directly by the functions ux, uy, which must be real-valued
%    functions of two variables.
%
%    QuadEnergy1 uses a three-point quadrature rule.

% Compute the Jacobian

x13=c(1,1)-c(3,1);
x23=c(2,1)-c(3,1);
y13=c(1,2)-c(3,2);
y23=c(2,2)-c(3,2);

J=abs(x13*y23-y13*x23);

% Compute the nodes (on the reference triangle with vertices (1,0),
% (0,1), (0,0), the nodes are (2/3,1/6), (1/6,2/3), (1/6,1/6))

c1=2/3;
c2=1/6;
T=[c1 c2 c2;c2 c1 c2;c2 c2 c1];
coords=T*c;

% Estimate the integral

if isnumeric(k)
   kvals=[k;k;k];
else
   kvals=feval(k,coords(:,1),coords(:,2));
end
uxvals=feval(ux,coords(:,1),coords(:,2));
uyvals=feval(uy,coords(:,1),coords(:,2));

I=(J/6)*(kvals'*(uxvals.^2+uyvals.^2));
