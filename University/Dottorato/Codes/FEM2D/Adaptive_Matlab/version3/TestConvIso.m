function [T1,U]=TestConvIso(T,N,d,fnmu,fnlam,fnf1,fnf2,Dflag,Nflag,...
                            u1,u1x,u1y,u2,u2x,u2y,gflag)

% [T,U]=TestConvIso(T0,N,d,fnmu,fnlam,fnf1,fnf2,Dflag,Nflag,u,ux,uy,gflag)
%
%   This function tests the finite element method, using Lagrange
%   triangles of degree d, on the BVP
%
%        -div(sigma)=f in Omega,
%                  u=0 on Gamma,
%            sigma*n=h on Bndy(Omega)-Gamma,
%   where
%          sigma=2*mu*e(u)+lambda*tr(e(u))*I.
%
%   T0 is an initial mesh on Omega (see "help Mesh" for details).
%
%   Teh inputs fnmu, fnlam  define mu and lam.  mu and lam
%   can be scalars or functions.
%
%   fnf1 and fnf2 define the two components of the vector-valued
%   function f. if f is zero, these inputs can be replaced by []
%   (the empty matrix).
%
%   Dflag and Nflag indicate nonzero Dirichlet and Neumann data,
%   respectively.
%
%   N is the number of mesh refinements, while u, ux, uy define the
%   exact solution and its first partial derivatives.
%
%   The energy norm error is displayed at each iteration, and the
%   energy norm of the solution is displayed at the end.  If the
%   optional input gflag is nonzero, then the mesh and solution
%   at each iteration are displayed in figure(gflag).
%
%   The computed solution U and the final mesh T are returned.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if nargin<16
   gflag=0;
end

for i=1:N

   % Refine the mesh (for the first iteration, use the given mesh):

   if i>1
      T=Refine1(T);
   end
   T1=GenLagrangeMesh(T,d);

   % Assemble the boundary data

   Nf=length(T1.FNodePtrs);
   Nc=length(T1.CNodePtrs);
   if Dflag&Nc>0
      g1=getDirichletData(T1,u1);
      g2=getDirichletData(T1,u2);
      g=[g1;g2];
   else
      g1=[];
      g2=[];
      g=[];
   end
   Nb=length(T1.FBndyEdges);
   if Nb>0 & Nflag
      h=getNeumannDataIso(T1,u1x,u1y,u2x,u2y,fnmu,fnlam);
   else
      h=[];
   end

   % Compute the stiffness matrix and load vector and solve the
   % finite element equation KU=F:

   t1=clock;
   K=StiffnessIso(T1,fnmu,fnlam);
   disp(['Assembling the stiffness matrix: ',...
          num2str(etime(clock,t1)),' seconds'])
   t1=clock;
   F=LoadIso(T1,fnf1,fnf2,fnmu,fnlam,g,h);
   disp(['Assembling the load vector: ',...
          num2str(etime(clock,t1)),' seconds'])
   t1=clock;
   if Nc>0
      U=K\F;
   else
      ii=[2:Nf-1,Nf+2:2*Nf];
      K1=K(ii,ii);
      F1=F(ii);
      U1=K1\F1;
      U=zeros(2*Nf,1);
      U(ii)=U1;
   end
   disp(['Solving the linear system: ',num2str(etime(clock,t1)),' seconds'])

   % Compute the energy norm of the error:

   t1=clock;
   Nf=length(T1.FNodePtrs);
   err1=sqrt(EnergyNormErr(T1,1.0,u1x,u1y,U(1:Nf),g1)^2+...
             EnergyNormErr(T1,1.0,u2x,u2y,U(Nf+1:2*Nf),g2)^2);
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
      ShowDisplacement(T1,U,g);
      title('Computed displacement')
      axis('equal','off')
      drawnow

   end

   % Prepare for the next iteration:

   err0=err1;

end

nrm1=sqrt(EnergyNorm(T1,1.0,u1x,u1y)^2+EnergyNorm(T1,1.0,u2x,u2y)^2);
disp(['Energy Norm of solution is ',num2str(nrm1)])
