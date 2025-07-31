% Example3c
%
%   This script demonstrates the use of the Fem code to
%   solve the BVP
%
%                  -lap u=f in Omega,
%                       u=g on Gamma_1,
%                 k*du/dn=h on Gamma_2.
%
%   where Omega is the upper half of the unit circle.
%   Gamma_1 is the bottom of the semicircle, while Gamma_2
%   is the rest of the boundary.  The problem functions
%   f, g, h are chosen so that the exact solution is
%   u(x,y)=x^3*cos(pi*y).
%
%   TestConv is invoked to illustrate the convergence of the
%   finite element method with isoparametric quartic elements.
%
%   This example should be compared to Example2c, where the same
%   problem is solved using non-isoparametric elements.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Define the problem functions (note that u and its partial derivatives
% are used here to compute the boundary values; also, these functions
% are used to check the accuracy of the computed solution):

f=vectorize(inline('-6*x*cos(pi*y)+x^3*cos(pi*y)*pi^2','x','y'));

u=vectorize(inline('x^3*cos(pi*y)','x','y'));
ux=vectorize(inline('3*x^2*cos(pi*y)','x','y'));
uy=vectorize(inline('-x^3*sin(pi*y)*pi','x','y'));

% Establish an initial mesh on the domain:

T0=CoarseSemiCircleMeshBottomD1;
T0=Refine1(T0);

% N is the number of refinements:

N=4;

% Invoke TestConv (see "help TestConv" for the meaning of the
% inputs):

[T,U,g]=TestConv(T0,N,4,1,f,1,1,u,ux,uy,1);
