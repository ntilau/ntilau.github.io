function [x,relres,its]=SOR(A,b,w,Tol,MaxItn,trace)

% [x,relres,its]=SOR(A,b,w,Tol,MaxItn,trace)
%
%   This function applies the successive over-relaxtion
%   (SOR) iteration, with parameter w, to solve the
%   system Ax=b.  The diagonal of A must be nonzero.
%
%   The routine halts if the relative residual falls
%   below Tol (i.e. ||Ax-b||/||b||<=Tol) or if the
%   number of iterations reaches MaxItn.
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

if nargin<6
   trace=0;
end

if nargin<5
   MaxItn=100;
end

if nargin<4
   Tol=1e-4;
end

% The initial point is x=0 and the initial residual is b:

n=length(b);
x=zeros(n,1);
r=b;

% Compute the initial residual:

res0=norm(r);
res=res0;

if trace>1
   disp(['SOR iteration 0: residual = ',num2str(res0)])
end

% Extract the lower triangle of A:

M=spdiags((1/w)*diag(A),0,n,n)+tril(A,-1);

% Main loop; stop when the relative residual falls below the
% tolerance or the maximum number of iterations is reached:

its=0;
while res>Tol*res0 & its<MaxItn

   % Take the step:

   x=M\r+x;
   its=its+1;

   % Compute the new residual:

   r=b-A*x;
   res=norm(r);

   if trace>1
      disp(['SOR iteration ',int2str(its),': residual = ',...
             num2str(res),', relative residual = ',num2str(res/res0)])
   end

end

relres=res/res0;
if trace==1
   disp(['SOR iteration ',int2str(its),': residual = ',num2str(res),...
         ', relative residual = ',num2str(relres)])
end
if trace
   if relres<Tol
      disp(['SOR succeeded in reducing the relative residual below ',...
            num2str(Tol,'%.3g')])
   else
      disp('SOR halted because the iteration limit was reached')
   end
end
