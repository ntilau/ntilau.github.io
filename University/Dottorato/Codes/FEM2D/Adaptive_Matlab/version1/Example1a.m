% Example1a
%
%   This script demonstrates the use of the Fem code to
%   solve the BVP
%
%          -div(k*grad u)=f in Omega,
%                       u=g on Gamma_1,
%                 k*du/dn=h on Gamma_2.
%
%   Here Omega is the unit square, Gamma_1 consists of
%   the top and left edges of the square and Gamma_2 is
%   the remainder of the boundary (the bottom and right
%   edges).  The coefficient is k(x,y)=1+x^2*y, and
%   f, g, h are chosen so that the exact solution is
%   u(x,y)=exp(2*x)*(x^2+y^2).

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Define the problem functions (note that u and its partial derivatives
% are used here to compute the boundary values; also, these functions
% are used to check the accuracy of the computed solution):

f=vectorize(inline('-2*x*y*(2*exp(2*x)*(x^2+y^2)+2*exp(2*x)*x)-(1+x^2*y)*(4*exp(2*x)*(x^2+y^2)+8*exp(2*x)*x+2*exp(2*x))-2*x^2*exp(2*x)*y-2*(1+x^2*y)*exp(2*x)','x','y'));
k=vectorize(inline('1+x^2*y','x','y'));

u=vectorize(inline('exp(2*x)*(x^2+y^2)','x','y'));
ux=vectorize(inline('2*exp(2*x)*(x^2+y^2)+2*exp(2*x)*x','x','y'));
uy=vectorize(inline('2*exp(2*x)*y','x','y'));

% Establish a mesh on the domain:

T=RectangleMeshTopLeftD1(16);

% Assemble the stiffness matrix:

K=Stiffness1(T,k);

% Create the boundary data:

g=getDirichletData(T,u);
h=getNeumannData1(T,ux,uy,k);

% Assemble the load vector:

F=Load1(T,f,k,g,h);

% Solve the finite element equations:

U=K\F;

% Display the computed solution:

figure(1)
clf
ShowPWLinFcn1(T,U,g)

% Compute the error (in the energy norm) in the computed
% solution.  Also compute the energy norm of the solution
% and display the relative error:

err=EnergyNormErr1(T,k,ux,uy,U,g);
nrm=EnergyNorm1(T,k,ux,uy);
disp(['Relative energy norm error in computed solution: ',num2str(err/nrm)])
