% Example1c
%
%    This script solves the BVP
%
%            -div(k*grad u)=0 in Omega,
%                         u=0 on Gamma_1,
%                   k*du/dn=h on Gamma_2,
%
%    where Omega is the upper half of the unit disk.
%    Gamma_1 is the bottom of the semicircle, while
%    Gamma_2 is the rest of the boundary.  The problem
%    functions are k(x,y)=2+y^2 and h(x,y)=x^2.  The exact
%    solution is unknown, so, after estimating the solution
%    once, the mesh is (uniformly) refined, the solution
%    estimated again, and the two solutions compared to
%    estimate the error.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Define the problem functions:

k=vectorize(inline('2+y^2','x','y'));
h=vectorize(inline('x^2','x','y','nx','ny'));

% Establish an initial coarse mesh (two triangles) on the
% domain:

T=CoarseSemiCircleMeshBottomD1;

% Refine the mesh four times to obtain a mesh with
% 2*4^4=512 triangles:

for i=1:4
   T=Refine1(T);
end

% Assemble the stiffness matrix:

K=Stiffness1(T,k);

% Create the boundary data:

h1=getNeumannData1a(T,h);

% Assemble the load vector:

F=Load1(T,[],[],[],h1);

% Solve the finite element equations:

U=K\F;

% Display the computed solution:

figure(1)
clf
ShowPWLinFcn1(T,U)

% Now refine the mesh once and compute a better estimate:

T1=Refine1(T);
K1=Stiffness1(T1,k);
h1=getNeumannData1a(T1,h);
F1=Load1(T1,[],[],[],h1);
U1=K1\F1;

% Display the computed solution:

figure(2)
clf
ShowPWLinFcn1(T1,U1)

% Interpolate the first solution onto the finer mesh:

V=Interpolate1(T,T1,U);

% Compute the energy norm of the difference:

R=U1-V;
err=sqrt(R'*(K1*R));

% Also compute the norm of the computed solution:

nrm=sqrt(U1'*F1);

% Display the estimated relative error in U1:

disp(['Estimated relative energy norm error in second solution: ',...
       num2str(err/nrm)])
