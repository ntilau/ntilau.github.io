function [x,relres,its]=Jacobi(A,b,Tol,MaxItn,trace)

% [x,relres,its]=Jacobi(A,b,Tol,MaxItn,trace)
%
%   This function applies Jacobi iteration to
%   solve the system Ax=b. The diagonal of A
%   must be nonzero.
%
%   The routine halts if the relative residual
%   falls below Tol (i.e. ||Ax-b||/||b||<=Tol)
%   or if the number of iterations reaches MaxItn.
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
%   The computed solution is returned, along with
%   the corresponding relative residual and the
%   number of iterations taken.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if nargin<5
   trace=0;
end

if nargin<4
   MaxItn=100;
end

if nargin<3
   Tol=1e-4;
end

% The initial point is x=0 and the initial residual is b:

x=zeros(size(b));
r=b;

% Compute the initial residual:

res0=norm(r);
res=res0;

if trace>1
   disp(['Jacobi iteration 0: residual = ',num2str(res0)])
end

% Extract the diagonal of A and prepare for the iteration:

d=full(diag(A));
dmin=min(abs(d));
if dmin<10*eps
   error('Diagonal of A must be safely nonzero')
end

dinv=1./d;

% Main loop; stop when the relative residual falls below the
% tolerance or the maximum number of iterations is reached:

its=0;
while res>Tol*res0 & its<MaxItn

   % Take the step:

   x=dinv.*r+x;
   its=its+1;

   % Compute the new residual:

   r=b-A*x;
   res=norm(r);

   if trace>1
      disp(['Jacobi iteration ',int2str(its),': residual = ',num2str(res),...
            ', relative residual = ',num2str(res/res0)])
   end

end

relres=res/res0;
if trace==1
   disp(['Jacobi iteration ',int2str(its),': residual = ',num2str(res),...
         ', relative residual = ',num2str(res/res0)])
end
if trace
   if relres<Tol
      disp(['Jacobi succeeded in reducing the relative residual below ',...
            num2str(Tol,'%.3g')])
   else
      disp('Jacobi halted because the iteration limit was reached')
   end
end
