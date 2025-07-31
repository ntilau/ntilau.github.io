% AdaptiveExample2
%
%   This script illustrates the adaptive solution of a BVP
%   with an unknown solution.  The BVP is
%
%               -lap u=1 in Omega,
%                    u=0 on Gamma_1,
%                du/dn=0 on Gamma_2
%
%   where Omega is the unit square, Gamma_2 is the interval
%   on the y-axis with endpoints (0,0.25) and (0,0.75), and
%   Gamma_1 is the rest of the boundary of Omega.
%
%   The adaptive routine Solve is invoked.  The main user-defined
%   parameters are method (which chooses the error estimator)
%   and NtMax (the maximum number of triangles in the mesh).
%   The script chooses method=3 (the element residual method)
%   and NtMax=1000, but these choices can be changed below.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Define the right-hand side of the PDE:

f=inline('ones(size(x))','x','y');

% Establish an initial coarse mesh on the domain:

T0=RectangleMeshN1(4);
i=[1:5,6,10,15,16,20,21:25];
tris=getTriNodeIndices1(T0);
nodes=T0.Nodes;
T0=MakeMesh1(nodes,tris,i);
T0.Bases=[2;2;6;6;10;10;14;14;19;19;22;22;25;25;28;28;32;32;35;35;38;38;...
          41;41;45;45;48;48;51;51;54;54];

% Choose the parameters and invoke Solve:

method=3;
NtMax=4000;
[U,g,T]=Solve(method,T0,1,f,[],[],1e-8,NtMax,2);
return
% Display the final computed solution:

figure(2)
clf
ShowPWLinFcn1(T,U)
