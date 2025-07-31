% Example3a
%
%   This script demonstrates the use of the Fem code to
%   solve the BVP
%
%          -div(k*grad u)=f in Omega,
%                       u=g on Bndy(Omega)
%
%   Here Omega is the unit circle.  The coefficient
%   is k(x,y)=1+x^2*y, and f and g are chosen so that the
%   exact solution is u(x,y)=1-x^2-y^2+x.
%
%   Isoparametric cubic finite elements are used.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Define the problem functions (note that u and its partial derivatives
% are used here to compute the boundary values; also, these functions
% are used to check the accuracy of the computed solution):

f=vectorize(inline('-2*x*y*(-2*x+1)+4+6*x^2*y','x','y'));
k=vectorize(inline('1+x^2*y','x','y'));

u=vectorize(inline('1-x^2-y^2+x','x','y'));
ux=vectorize(inline('1-2*x','x','y'));
uy=vectorize(inline('-2*y','x','y'));

% Establish a mesh of cubic Lagrange triangles on the domain:

T=CoarseCircleMeshD1;
for i=1:1
   T=Refine1(T);
end
T=GenLagrangeMesh(T,3);

% Assemble the stiffness matrix:

K=Stiffness(T,k);

% Create the boundary data:

g=getDirichletData(T,u);

% Assemble the load vector:

F=Load(T,f,k,g);

% Solve the finite element equations:

U=K\F;

% Display the computed solution:

figure(1)
clf
ShowPWPolyFcn(T,U,g)

% Compute the error (in the energy norm) in the computed
% solution.  Also compute the energy norm of the solution
% and display the relative error:

err=EnergyNormErr(T,k,ux,uy,U,g);
nrm=EnergyNorm(T,k,ux,uy);
disp(['Relative energy norm error in computed solution: ',num2str(err/nrm)])
