function [T1,U,g]=TestConv(T,N,d,fnk,fnf,Dflag,Nflag,u,ux,uy,gflag)

% [T,U,g]=TestConv(T0,N,d,fnk,fnf,Dflag,Nflag,u,ux,uy,gflag)
%
%   This function tests the finite element method, using
%   Lagrange triangles of degree d, on the BVP
%
%             -div(k*grad u)=f in Omega,
%                          u=g on Gamma,
%                    k*du/dn=h on Bndy(Omega)-Gamma.
%
%   The exact solution u must be known and provided as input
%   so that the error in the computed solutions can be
%   computed.
%
%   T0 is an initial mesh on Omega (see "help Mesh" for
%   details).  The inputs fnk and fnf define k
%   and f, respectively.  Either can be replaced by []
%   (the empty vector), in which case the zero function is
%   used for f and the constant function 1 for k.  Otherwise,
%   fnk must be a constant or a function of two variables,
%   and fnf must be a function of two variables.
%
%   Dflag indicates nonzero Dirichlet data, while Nflag
%   indicates nonzero Neumann data.
%
%   N is the number of mesh refinements, while u, ux, uy
%   define the exact solution and its first partial
%   derivatives.
%
%   The energy norm error is displayed at each iteration,
%   and the energy norm of the solution is displayed at the
%   end.  If the optional input gflag is nonzero, then the
%   mesh and solution at each iteration are displayed in
%   figure(gflag).
%
%   The computed solution U, g from the final mesh T are
%   returned.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if isempty(fnk)
   fnk=1.0;
end

if nargin<11
   gflag=0;
end

for i=1:N

   % Refine the mesh (for the first iteration, use the given mesh):

   if i>1
      T=Refine1(T);
   end
   T1=GenLagrangeMesh(T,d);

   % Assemble the boundary data

   % First, the Dirichlet data:

   Nf=length(T1.FNodePtrs);
   Nc=length(T1.CNodePtrs);
   if Nc>0 & Dflag

      g=getDirichletData(T1,u);

   else

      g=[];

   end

   % Next, the Neumann data:

   Nb=length(T1.FBndyEdges);
   if Nb>0 & Nflag

      h=getNeumannData(T1,ux,uy,fnk);

   else

      h=[];

   end

   % Compute the stiffness matrix and load vector and solve the
   % finite element equation KU=F:

   t1=clock;
   K=Stiffness(T1,fnk);
   disp(['Assembling the stiffness matrix: ',...
          num2str(etime(clock,t1)),' seconds'])
   t1=clock;
   F=Load(T1,fnf,fnk,g,h);
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
   [err1,elerrs]=EnergyNormErr(T1,fnk,ux,uy,U,g);
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
      ShowPWPolyFcn(T1,U,g);
      title('Computed solution')
      axis('square')
      drawnow

   end

   % Prepare for the next iteration:

   err0=err1;

end

nrm1=EnergyNorm(T1,fnk,ux,uy);
disp(['Energy Norm of solution is ',num2str(nrm1)])
