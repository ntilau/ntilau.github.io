% AdaptiveExample1
%
%   This script illustrates the adaptive solution of a BVP
%   with a known solution.  The BVP is
%
%               -lap u=f in Omega,
%                    u=0 on Bndy(Omega),
%
%   where Omega is the unit square and f is chosen so that
%   the exact solution is
%
%      u(x,y)=x*y*(1-x)*(1-y)*exp(-1000*((x-0.5)^2+(y-0.117)^2)).
%
%   The adaptive routine Solve is invoked.  The main user-defined
%   parameters are method (which chooses the error estimator)
%   and NtMax (the maximum number of triangles in the mesh).
%   The script chooses method=3 (the element residual method)
%   and NtMax=3000, but these choices can be changed below.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Define the solution, its partial derivatives, and the right-hand
% side of the PDE:

u=vectorize(inline('x*(x-1)*y*(y-1)*exp(-1000*(x-1/2)^2-1000*(y-117/1000)^2)','x','y'));
ux=vectorize(inline('y*(1-x)*(1-y)*exp(-1000*(x-1/2)^2-1000*(y-117/1000)^2)-x*y*(1-y)*exp(-1000*(x-1/2)^2-1000*(y-117/1000)^2)+x*y*(1-x)*(1-y)*(-2000*x+1000)*exp(-1000*(x-1/2)^2-1000*(y-117/1000)^2)','x','y'));
uy=vectorize(inline('x*(1-x)*(1-y)*exp(-1000*(x-1/2)^2-1000*(y-117/1000)^2)-x*y*(1-x)*exp(-1000*(x-1/2)^2-1000*(y-117/1000)^2)+x*y*(1-x)*(1-y)*(-2000*y+234)*exp(-1000*(x-1/2)^2-1000*(y-117/1000)^2)','x','y'));
sol.fnu=u;
sol.fnux=ux;
sol.fnuy=uy;
f=vectorize(inline('-2*y*(y-1)*exp(-1000*(x-1/2)^2-1000*(y-117/1000)^2)-2*(x-1)*y*(y-1)*(-2000*x+1000)*exp(-1000*(x-1/2)^2-1000*(y-117/1000)^2)-2*x*y*(y-1)*(-2000*x+1000)*exp(-1000*(x-1/2)^2-1000*(y-117/1000)^2)+4000*x*(x-1)*y*(y-1)*exp(-1000*(x-1/2)^2-1000*(y-117/1000)^2)-x*(x-1)*y*(y-1)*(-2000*x+1000)^2*exp(-1000*(x-1/2)^2-1000*(y-117/1000)^2)-2*x*(x-1)*exp(-1000*(x-1/2)^2-1000*(y-117/1000)^2)-2*x*(x-1)*(y-1)*(-2000*y+234)*exp(-1000*(x-1/2)^2-1000*(y-117/1000)^2)-2*x*(x-1)*y*(-2000*y+234)*exp(-1000*(x-1/2)^2-1000*(y-117/1000)^2)-x*(x-1)*y*(y-1)*(-2000*y+234)^2*exp(-1000*(x-1/2)^2-1000*(y-117/1000)^2)','x','y'));

% Establish an initial coarse mesh on the domain:

T0=RectangleMeshD1(2);
T0.Bases=[4;4;6;6;11;11;13;13];

% Choose the parameters and invoke Solve:

method=3;
NtMax=3000;
[U,g,T]=Solve(method,T0,1,f,[],[],1e-8,NtMax,2,sol);
