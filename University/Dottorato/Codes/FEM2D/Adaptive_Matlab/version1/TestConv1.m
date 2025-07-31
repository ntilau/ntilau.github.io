function [T,U,g]=TestConv1(T,N,fnk,fnf,Dflag,Nflag,u,ux,uy,gflag)

%[T,U,g]=TestConv1(T0,N,fnk,fnf,Dflag,Nflag,u,ux,uy,gflag)
%
%   This function tests the piecewise linear finite element
%   method on the BVP
%
%             -div(k*grad u)=f in Omega,
%                          u=g on Gamma,
%                    a*du/dn=h on Bndy(Omega)-Gamma.
%
%   The exact solution u must be known and provided as input
%   so that the error in the computed solutions can be
%   computed.
%
%   T0 is an initial mesh on Omega (see "help Mesh1" for
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
%   The L2 and energy norm errors are displayed at each
%   iteration, and the L2 and energy norms of the solution
%   are displayed at the end.  If the optional input gflag
%   is nonzero, then the mesh and solution at each iteration
%   are displayed in figure(gflag).
%
%   In the case of pure Neumann conditions, TestConv1 computes
%   the solution whose nodal value at the first free node
%   is zero.
%
%   The computed solution U, g and the final mesh T are
%   returned.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if isempty(fnk)
   fnk=1;
end

if nargin<10 || gflag<0
   gflag=0;
end

for i=1:N

   % Refine the mesh (for the first iteration, use the given mesh):

   if i>1
      T=Refine1(T);
   end

   % Assemble the boundary data

   % First, the Dirichlet data:

   Nf=length(T.FNodePtrs);
   Nc=length(T.CNodePtrs);
   if Nc>0 & Dflag
      g=getDirichletData(T,u);
   else
      g=[];
   end

   % Next, the Neumann data:

   Nb=length(T.FBndyEdges);
   if Nb>0 & Nflag
      h=getNeumannData1(T,ux,uy,fnk);
   else
      h=[];
   end

   % Compute the stiffness matrix and load vector and solve the
   % finite element equation KU=F:

   t1=clock;
   K=Stiffness1(T,fnk);
   disp(['Assembling the stiffness matrix: ',...
          num2str(etime(clock,t1)),' seconds'])
   t1=clock;
   F=Load1(T,fnf,fnk,g,h);
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
   err0=L2NormErr1(T,u,U,g);
   err1=EnergyNormErr1(T,fnk,ux,uy,U,g);
   disp(['Computing the norms of the error: ',...
          num2str(etime(clock,t1)),' seconds'])
   disp(['L2, Energy norm errors: ',num2str(err0),', ',num2str(err1)])
   if i>1
      disp(['Ratio of errors is ',num2str(err00/err0),', ',num2str(err10/err1)])
   end

   disp('-----')

   % Graph the mesh and the computed solution, if requested:

   if gflag
      figure(gflag)
      clf
      hh=subplot(1,2,1);
      set(hh,'FontSize',16);
      set(hh,'LineWidth',2);
      ShowMesh1(T);
      title('Mesh')
      hh=subplot(1,2,2);
      set(hh,'FontSize',16);
      set(hh,'LineWidth',2);
      ShowPWLinFcn1(T,U,g);
      title('Computed solution')
      axis('square')
      drawnow
   end

   % Prepare for the next iteration:

   err00=err0;
   err10=err1;

end

nrm0=L2Norm1(T,u);
nrm1=EnergyNorm1(T,fnk,ux,uy);
disp(['L2, Energy norms of solution: ',num2str(nrm0),', ',num2str(nrm1)])
