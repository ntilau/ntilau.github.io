function [T1,U,g]=TestConv(T,N,d,fnA,fnf,Nflag,u,ux,uy,gflag)

% [T,U,g]=TestConv(T0,N,d,fnA,fnf,Nflag,u,ux,uy,gflag)
%
%   This function tests the finite element method, using
%   Lagrange triangles of degree d, on the BVP
%
%             -div(A*grad u)=f in Omega,
%                          u=0 on Gamma,
%               (A*grad u).n=h on Bndy(Omega)-Gamma.
%
%   The coefficient A is (symmetric, positive definite)
%   matrix-valued.
%
%   T0 is an initial mesh on Omega (see "help Mesh" for
%   details), while fnA and fnf, are functions defining
%   A and f, respectively.  fnf can be replaced by [],
%   in which case the zero function is used for f.
%
%   Nflag indicates nonzero Neumann data.  This routine
%   does not handle nonzero Dirichlet data.
%
%   N is the number of mesh refinements, while u, ux, uy
%   define the exact solution and its first partial
%   derivatives.
%
%   The energy norm error is displayed at each iteration,
%   and the energy norm of the solution is displayed at
%   the end.  If the optional input gflag is nonzero, then
%   the mesh and solution at each iteration are displayed
%   in figure(gflag).
%
%   The computed solution U, g from the final mesh T are
%   returned.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if nargin<10
   gflag=0;
end

for i=1:N

   % Refine the mesh (for the first iteration, use the given mesh):

   if i>1
      T=Refine1(T);
   end
   T1=GenLagrangeMesh(T,d);

   % Assemble the Neumann boundary data (if any):

   Nf=length(T1.FNodePtrs);
   Nc=length(T1.CNodePtrs);
   Nb=length(T1.FBndyEdges);
   if Nb>0 & Nflag
      h=getNeumannDataMC(T1,ux,uy,fnA);
   else
      h=[];
   end

   % Compute the stiffness matrix and load vector and solve the
   % finite element equation KU=F:

   t1=clock;
   K=StiffnessMC(T1,fnA);
   disp(['Assembling the stiffness matrix: ',...
          num2str(etime(clock,t1)),' seconds'])
   t1=clock;
   F=Load(T1,fnf,[],[],h);
   disp(['Assembling the load vector: ',...
          num2str(etime(clock,t1)),' seconds'])
   t1=clock;
   if Nc>0
      U=K\F;
   else
      K1=K(2:Nf,2:Nf);
      F1=F(2:Nf);
      U1=K1\F1;
      U=[0;U1];
   end
   disp(['Solving the linear system: ',num2str(etime(clock,t1)),' seconds'])

   % Compute the energy norm of the error:

   t1=clock;
   [err1,elerrs]=EnergyNormErr(T1,1,ux,uy,U);
   disp(['Computing the norm of the error: ',...
          num2str(etime(clock,t1)),' seconds'])
   disp(['Energy norm error is ',num2str(err1)])
   if i>1
      disp(['Ratio of errors is ',num2str(err0/err1)])
   end

   disp('-----')

   % Graph the mesh and the computed solution, if requested:

   if gflag
      figure(gflag)
      clf
      hh=subplot(1,2,1);
      set(hh,'FontSize',16);
      set(hh,'LineWidth',2);
      ShowMesh(T1);
      title('Mesh')
      hh=subplot(1,2,2);
      set(hh,'FontSize',16);
      set(hh,'LineWidth',2);
      ShowPWPolyFcn(T1,U);
      title('Computed solution')
      axis('square')
      drawnow

   end

   % Prepare for the next iteration:

   err0=err1;

end

nrm1=EnergyNorm(T,1,ux,uy);
disp(['Energy Norm of solution is ',num2str(nrm1)])
