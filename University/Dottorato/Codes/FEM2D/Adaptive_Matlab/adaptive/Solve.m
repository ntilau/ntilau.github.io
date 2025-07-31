function [U,g,T,N,errsE,errsinf]=Solve(method,T,fnk,fnf,fng,fnh,Tol,...
                                       NtMax,trace,sol)

% [U,g,T,N,errsE,errsinf]=Solve(method,T0,fnk,fnf,fng,fnh,,...
%                               Tol,NtMax,trace,sol)
%
%   This function applies an adaptive finite element method to
%   solve the BVP
%
%             -div(k*grad u)=f in Omega,
%                          u=g on Gamma,
%                    k*du/dn=h on Bndy(Omega)-Gamma.
%
%   The pure Neumann problem (Gamma equal to the empty set)
%   is not handled by this code.
%
%   T0 is an initial mesh on Omega (see "help Mesh" for details),
%   while fnk, fnf, fng, fnh are functions defining k, f, g,
%   and h, respectively.  Any of these can be replaced by []
%   (the empty vector), in which case the zero function is used
%   for f, g, or h, and the constant function 1 for k.
%
%   The integer method defines the error estimator/indicator
%   to be used.  Specifically:
%
%         method:  0 - true energy norm errors computed from
%                      exact solution (input sol required, with
%                      fields sol.fnux, sol.fnuy)
%                  1 - true L-infinity errors computed from exact
%                      solution (input sol required, with
%                      field sol.fnu)
%                  2 - error estimation by comparison with
%                      the piecewise quadratric solution
%                      on the same mesh (expensive---for
%                      illustration only!)
%                  3 - the element residual estimator (3 point)
%                  4 - the element residual estimator (4 point)
%                  5 - the Eriksson-Johnson indicator (L-infinity
%                      version)
%                  6 - the explicit residual method
%
%   The default is method=3; this is chosen if method=[].
%
%   The procedure halts when the estimate of the total error falls
%   below Tol.  The final mesh T along with the nodal value
%   U (free nodes) and g (constrained nodes) are returned. The
%   computed solution is piecewise linear.
%
%   The optional input NtMax gives the maximum number of triangles
%   in the final mesh; the iteration halts if this number is exceeded.
%
%   If the input trace is nonzero, then the estimated error is
%   displayed for each mesh.  If trace>1, then the mesh is displayed
%   each time it is refined.
%
%   If the input sol is provided, the output vectors N, errsE, and
%   errsinf contain the number of nodes, energy norm errors,
%   and L-infinity norm errors.  sol must be a struct with fields
%   sol.fnu, sol.fnux, sol.fnuy implementing the solution u and
%   its partial derivatives, respectively.
%
%   If sol is provided, the results are analyzed by fitting the
%   errors (both energy norm and L-infinity norm) as
%                       error=CN^p

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Handle the optional inputs:

if nargin<9
   trace=0;
end

if nargin<8
   NtMax=1e6;
end

if nargin<7
   Tol=0.1;
end

if isempty(method)
   method=3;
end

% Handle the default value for fnk, if necessary:

if isempty(fnk)
   fnk=1.0;
end

% Main loop---continue until tolerance is satisfied
% or maximum number of triangles is reached (always
% perform at least two steps).

N=[];
esterr=[];
errsinf=[];
errsE=[];
errs0=[];
for kk=1:NtMax

   % Construct the Dirichlet data, if necessary:

   if ~isempty(fng)
      g=getDirichletData(T,fng);
   else
      g=[];
   end

   % Construct the Neumann data, if necessary:

   if ~isempty(fnh)
      h=getNeumannData1a(T,fnh);
   else
      h=[];
   end

   % Compute the stiffness matrix and load vector,
   % and solve the finite element equations:

   K=Stiffness1(T,fnk);
   F=Load1(T,fnf,fnk,g,h);
   U=K\F;

   if method==0
      errs1=ElementEnergyNormErrs1(T,fnk,sol.fnux,sol.fnuy,U,g);
   elseif method==1
      errs1=ElementLinfNormErrs1(T,sol.fnu,U,g);
   elseif method==2
      errs1=QuadElementErrEst1(T,U,g,fnk,fnf,fng,fnh);
   elseif method==3
      errs1=ElementResidual1(T,fnk,fnf,h,U,g);
   elseif method==4
      errs1=ElementResidual1(T,fnk,fnf,h,U,g,1);
   elseif method==5
      errs1=EJindicator1(T,U,g);
   elseif method==6
      errs1=ExpResidual1(T,fnk,fnf,h,U,g);
   else
      error('Unknown choice of error estimator/indicator')
   end
   d1=getDiameters(T);

   % If the estimated error on any triangle is zero, set it to
   % the minimum nonzero error:

   ii=find(errs1==0);
   if ~isempty(ii)
      jj=find(errs1>0);
      m=min(errs1(jj));
      errs1(ii)=m;
   end

   % Estimate the total error and display it (if desired):

   Nt=size(T.Elements,1);
   if method==1 | method==5
      toterr=norm(errs1,inf);
   else
      toterr=norm(errs1);
   end
   Nv=length(T.NodePtrs);
   N=[N;Nv];
   esterr=[esterr;toterr];
   if nargin>=10 & isfield(sol,'fnu')
     if method==1
        errsinf=[errsinf;toterr];
     else
        errsinf=[errsinf;LinfNormErr1(T,sol.fnu,U,g)];
     end
   end
   if nargin>=10 & isfield(sol,'fnux') & isfield(sol,'fnuy')
      if method==0
         errsE=[errsE;toterr];
      else
         errsE=[errsE;EnergyNormErr1(T,fnk,sol.fnux,sol.fnuy,U,g)];
      end
   end
   if trace
      disp(['Nt=',int2str(Nt),', Nv=',int2str(Nv),' Estimated error: ',...
            num2str(toterr),' eq. ratio: ',...
            num2str(max(errs1)/min(errs1),'%4g')])
   end
   if trace>1
      figure(1)
      clf
      ShowMesh1(T);
      drawnow
   end

   if length(N)>=2 && (toterr<=Tol | Nt>=NtMax)
      break
   end

   % Decide which triangles to refine.

   % Babuska-Rheinboldt strategy: select those triangles
   % whose current error is greater than the maximum
   % error predicted after a uniform refinement.
   % (First time, just do a uniform refinement.)

   if isempty(errs0)
      TList=(1:Nt)';
      d0=getDiameters(T);
      errs0=errs1;
      hFrac=0.5*ones(size(TList));
   else
      TList=SelectTris(d0,d1,errs0,errs1);
      hFrac=0.5*ones(size(TList));
   end

   % Now refine the mesh:

   [T,errs0,d0]=LocalRefine1(T,TList,hFrac,errs0,errs1,d0,d1);

end

% If the exact solution is provided, analyze the results
% by fitting the errors (both energy norm and L-infinity
% norm) as
%                     error=CN^p
% (print out C and p).

if trace && length(N)>2
   i=find(N>=100);
   N1=N(i);
   M=[ones(length(i),1),log(N1)];
   if nargin>=10 & isfield(sol,'fnu') & isfield(sol,'fnux') & ...
                                        isfield(sol,'fnuy')
      fprintf( ' N   Energy Err.      Est. Linf Err.   Est. C (Linf)\n' )
      fprintf( '%4d   %11.5e  %11.5e  %11.5e\n',[N,errsE,errsinf,N.*errsinf]' )
      err=errsinf(i);
      c=M\log(err);
      C=(N1.^(-1))\err;
      err1=errsE(i);
      c1=M\log(err1);
      C1=(N1.^(-0.5))\err1;
      disp('Fitting errors to err=ch^p:')
      disp(['L-infinity norm: c=',num2str(exp(c(1))),', p=',num2str(c(2))])
      disp(['Energy norm: c=',num2str(exp(c1(1))),', p=',num2str(c1(2))])
   elseif nargin>=10 & isfield(sol,'fnu')
      fprintf( ' N   Est. Linf Err.\n' )
      fprintf( '%4d   %11.5e\n',[N,errsinf]' )
      err=errsinf(i);
      c=M\log(err);
      C=(N1.^(-1))\err;
      disp('Fitting errors to err=ch^p:')
      disp(['L-infinity norm: c=',num2str(exp(c(1))),', p=',num2str(c(2))])
   elseif nargin>=10 & isfield(sol,'fnux') & isfield(sol,'fnuy')
      fprintf( ' N   Energy Err.\n' )
      fprintf( '%4d   %11.5e\n',[N,errsE]' )
      err1=errsE(i);
      c1=M\log(err1);
      C1=(N1.^(-0.5))\err1;
      disp('Fitting errors to err=ch^p:')
      disp(['Energy norm: c=',num2str(exp(c1(1))),', p=',num2str(c1(2))])
   end
end
