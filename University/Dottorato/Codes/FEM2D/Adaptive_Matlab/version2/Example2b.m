% Example2b
%
%   This script solves the same BVP as in Example2a;
%   however, the TestConv2 function is used to demonstrate
%   the convergence of the finite element method on a
%   sequence of uniformly-refined meshes.  TestConv2
%   requires the exact solution and displays the errrors
%   in the computed solutions.
%
%   Cubic elements are used, so the energy norm error should
%   go down like h^3; that is, when the mesh is refined
%   uniformly (h is divided by 2), the error should be reduced
%   by a factor of about 8.

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

T0=RectangleMeshTopLeftD1(2);

% N is the number of refinements:

N=4;

% Invoke TestConv2 (see "help TestConv2" for the meaning of the
% inputs):

[T,U,g]=TestConv2(T0,N,3,k,f,1,1,u,ux,uy,1);
