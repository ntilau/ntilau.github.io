function [errs,T1,U1,g1]=QuadElementErrEst1(T,U,g,fnk,fnf,fng,fnh)

% [errs,T1,U1,g1]=QuadElementErrEst1(T,U,g,fnk,fnf,fng,fnh)
%
%   This function computes the piecewise quadratic finite
%   element solution to the BVP
%
%             -div(k*grad u)=f in Omega,
%                          u=g on Gamma,
%                    k*du/dn=h on Bndy(Omega)-Gamma.
%
%   It then interpolates the piecewise linear solution,
%   given by (U,g) on the mesh T, onto the quadratic mesh
%   and computes the energy norm difference between the two
%   solutions.  These differences are returned in the array
%   errs (which is Nt by 1).  The quadratic mesh T1 and the
%   corresponding solution (U1,g1) are also returned if
%   desired.
%
%   See "help Mesh1" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Generate the mesh of degree 2:

T1=GenLagrangeMesh2(T,2);

% Construct the Dirichlet data, if necessary:

if ~isempty(fng)
   x1=T1.Nodes(T1.CNodePtrs,1);
   y1=T1.Nodes(T1.CNodePtrs,2);
   g1=feval(fng,x1,y1);
else
   g1=[];
end

% Construct the Neumann data, if necessary:

if ~isempty(fnh)
   h1=getNeumannData2a(T1,fnh);
else
   h1=[];
end

% Compute the stiffness matrix and load vector, and solve the
% finite element equation:

[K1,K1s]=StiffnessE(T1,fnk);
F1=Load2(T1,fnf,fnk,g1,h1);
U1=K1\F1;

% Interpolate the piecewise linear function onto the quadratic mesh:

[U1a,g1a]=Interpolate2(T,T1,U,g);
if isempty(fng)
   g1a=[];
end

% Compute the energy norm of the difference (triangle by triangle):

errs=ElementEnergyNorms(T1,K1s,U1a-U1,g1a-g1);
