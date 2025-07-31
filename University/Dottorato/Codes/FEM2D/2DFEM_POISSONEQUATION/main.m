%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  2D-FEM to solve poisson equation
%-------------------------------------
%
%  PDE: -div(eps*grad(V)) = rho   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% clear workspace and close all other open windows
clear all ;
close all ;
clc ;

% variable definition
name  = 'MeshDaten\box' ;

% set parameters
order = 2 ;    % order of nodal basis function (1 or 2)
rho = 0 ;      % "Raumladungsdichte"

% import data

proj = projectReader(name) ;

% set material parameters
eps0 = 8.854187818e-12 ;
epsR = proj.material(1).epsilonRelativ ;
eps  = eps0*epsR ;

% read boundaries
dirichlet = proj.bcInfo.dirichlet ;   
neumann = proj.bcInfo.neumann ;       

% get system matrix for whole problem
Asys = getSysMatrix(proj, order, eps) ;    
S = Asys ;                            

% attach neumann boundaries
bN = attachBCN(proj, order, neumann) ;   

% build r vector caused by rho
r = buildR(proj, order, rho) ;

% attach dirichlet boundaries and build rhs
[Asys, bD, bN, r] = attachBCD(proj, Asys, bN, r, order, dirichlet) ;

% solve linear system A*x = b
phi = solveSys(Asys, bN+bD+r) ;

% calculate energy
fprintf('energy = %e\n', 0.5 * (phi.' * S) * phi) ;

% write solution in file
solutionWriter(phi, proj, name) ;

% visualize solution
showPhi(phi, proj, order) ;
