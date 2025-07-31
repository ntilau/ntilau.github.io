% Example2c
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
%   TestConv2 is invoked to illustrate the convergence of the
%   finite element method with quartic elements.  Note: Since
%   Omega has a curved boundary, it is not discretized exactly.
%   The error due to the inexact mesh is ignored (that is, the
%   code only computes the error on the domain covered by the
%   mesh).  Therefore, the reported error significantly
%   underestimates the actual error.
%
%   This example should be compared to Example3c, where the
%   same problem is solved using isoparametric elements.

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

% Invoke TestConv2 (see "help TestConv2" for the meaning of the
% inputs):

[T,U,g]=TestConv2(T0,N,4,1,f,1,1,u,ux,uy,1);
