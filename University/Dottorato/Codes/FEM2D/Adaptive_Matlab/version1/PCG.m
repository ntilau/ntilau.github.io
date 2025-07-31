function [x,relres,its]=PCG(A,b,M,Tol,MaxItn,fflag,trace)

% [x,relres,its]=PCG(A,b,M,Tol,MaxItn,facflag,trace)
%
%   This function applies the preconditioned conjugate
%   gradient method to solve the system Ax=b, where A
%   is assumed to be symmetric and positive definite.
%   The routine halts if the relative residual falls
%   below Tol (i.e. ||Ax-b||/||b||<=Tol) or if the number
%   of iterations reaches MaxItn.
%
%   M is the preconditioner.  If the optional flag facflag
%   is nonzero, then it assumed that the (upper triangular)
%   Cholesky factor of the preconditioner is given as M.
%
%   Tol and MaxItn are optional; the default values are
%   1e-4 and 100, respectively.
%
%   The optional input trace controls the information sent
%   to the screen; possible values are:
%
%        0: no information displayed on the screen
%        1: a summary message printed upon completion
%        2: the relative residual printed at each iteration
%
%   The default value of trace is 0.
%
%   The computed solution is returned, along with the
%   corresponding relative residual and the number of
%   iterations taken.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if nargin<7
   trace=0;
end

if nargin<6
   fflag=0;
end

if nargin<5
   MaxItn=100;
end

if nargin<4
   Tol=1e-4;
end

% The initial point is x=0:

x=zeros(size(b));

% The initial residual is r=b:

r=b;

% Apply the preconditioner:

if fflag
   z=M\(M'\r);
else
   z=M\r;
end

% Assign the initial search direction:

p=z;

% Compute (r,z) and the initial (scaled) residual:

c1=r'*z;
res0=sqrt(c1);
res=res0;

if trace>1
   disp(['PCG iteration 0: scaled residual = ',num2str(res0)])
end

% Main loop; stop when the relative residual falls below the
% tolerance or the maximum number of iterations is reached:

its=0;
while res>Tol*res0 && its<MaxItn

   v=A*p;
   c2=p'*v;

   % Update the estimated solution x:

   a=c1/c2;
   x=x+a*p;
   its=its+1;

   % Update the residual:

   r=r-a*v;

   % Compute the new search direction:

   if fflag
      z=M\(M'\r);
   else
      z=M\r;
   end
   c3=r'*z;
   b=c3/c1;
   p=b*p+z;

   % Prepare for the next iteration:

   c1=c3;
   res=sqrt(c1);

   if trace>1
      disp(['PCG iteration ',int2str(its),': residual = ',num2str(res),...
            ', relative residual = ',num2str(res/res0)])
   end

end

relres=res/res0;
if trace==1
   disp(['PCG iteration ',int2str(its),': residual = ',num2str(res),...
         ', relative residual = ',num2str(res/res0)])
end
if trace
   if relres<Tol
      disp(['PCG succeeded in reducing the relative residual below ',...
            num2str(Tol,'%.3g')])
   else
      disp('PCG halted because the iteration limit was reached')
   end
end
