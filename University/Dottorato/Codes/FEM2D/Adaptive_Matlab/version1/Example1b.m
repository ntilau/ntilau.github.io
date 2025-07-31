% Example1b
%
%   This script solves the same BVP as in Example1a;
%   however, the TestConv1 function is used to demonstrate
%   the convergence of the finite element method on a
%   sequence of uniformly-refined meshes.  TestConv1
%   requires the exact solution and displays the errrors
%   in the computed solutions.

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

% Establish an initial mesh on the domain:

T=RectangleMeshTopLeftD1(2);

% N is the number of refinements:

N=5;

% Invoke TestConv1 (see "help TestConv1" for the meaning of the
% inputs):

[T,U,g]=TestConv1(T,N,k,f,1,1,u,ux,uy,1);
