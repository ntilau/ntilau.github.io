function [x,relres,its]=CGsing(A,N,b,Tol,MaxItn,trace)

% [x,relres,its]=CGsing(A,N,b,Tol,MaxItn,trace)
%
%   This function applies the conjugate gradient
%   method to solve the singular system Ax=b,
%   where A is assumed to be symmetric and positive
%   semidefinite.  The columns of N form a basis for
%   the null space of A.  The routine halts if the
%   relative residual falls below Tol (i.e.
%   ||Ax-b||/||b||<=Tol) or if the number of
%   iterations reaches MaxItn.
%
%   The algorithm has a random element (in choosing
%   a penalty parameter), so its behavior will not
%   be identical if called twice with the same inputs.
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
%   The computed solution is returned, along with the corresponding
%   relative residual and the number of iterations taken.

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

% The initial point is x=0:

x=zeros(size(b));

% The initial residual is r=b, and this is also the
% initial search direction:

r=b;
p=b;

% Compute (r,r) and the initial residual:

c1=r'*r;
res0=sqrt(c1);
res=res0;

if trace>1
   disp(['CGsing iteration 0: residual = ',num2str(res0)])
end

% Choose a reasonable penalty parameter:

u=randn(size(b));
rho=((u'*(A*u))/(u'*u))/length(p);

% Main loop; stop when the relative residual falls below the
% tolerance or the maximum number of iterations is reached:

its=0;
while res>Tol*res0 && its<MaxItn

   v=A*p+rho*(N*(N'*p));
   c2=p'*v;

   % Update the estimated solution x:

   a=c1/c2;
   x=x+a*p;
   its=its+1;

   % Update the residual:

   r=r-a*v;

   % Compute the new search direction:

   c3=r'*r;
   b=c3/c1;
   p=b*p+r;

   % Prepare for the next iteration:

   c1=c3;
   res=sqrt(c1);

   if trace>1
      disp(['CGsing iteration ',int2str(its),': residual = ',num2str(res),...
            ', relative residual = ',num2str(res/res0)])
   end

end

relres=res/res0;
if trace==1
   disp(['CGsing iteration ',int2str(its),': residual = ',num2str(res),...
         ', relative residual = ',num2str(relres)])
end
if trace
   if relres<Tol
      disp(['CGsing succeeded in reducing the relative residual below ',...
            num2str(Tol,'%.3g')])
   else
      disp('CGsing halted because the iteration limit was reached')
   end
end
