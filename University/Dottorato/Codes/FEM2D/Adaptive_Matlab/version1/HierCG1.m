function [U,relres,its]=HierCG1(T,K,F,Tol,MaxItn,trace)

% [U,relres,its]=HierCG1(T,K,F,Tol,MaxItn,trace)
%
%   This function applies the hierarchical basis
%   conjugate gradient method to solve the system
%   KU=F, where K is a stiffness matrix and F a
%   load vector corresponding to the mesh T.
%
%   The routine halts if the relative residual falls
%   below Tol (i.e. ||K1U-F1||/||F1||<=Tol) or if
%   the number of iterations reaches MaxItn.  Here
%   K1 and F1 are the stiffness matrix and load vector
%   corresponding to the hierarchical basis.
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
%   the corresponding relative residual and the number
%   of iterations taken.
%
%   See "help Mesh1" fora description of the mesh T.
%   Note that T must have been produced by one or more
%   calls to Refine1.

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

% The initial point is U=0:

U=zeros(size(F));

% Compute the right-hand side expressed in terms of the
% hierarchical basis:

F1=HierToNodalTrans1(T,F);

% The initial residual is r=F1, and this is also the
% initial search direction:

r=F1;
p=F1;

% Compute (r,r) and the initial residual:

c1=r'*r;
res0=sqrt(c1);
res=res0;

if trace>1
   disp(['HierCG iteration 0: residual = ',num2str(res0)])
end

% Main loop; stop when the relative residual falls below the
% tolerance or the maximum number of iterations is reached:

its=0;
while res>Tol*res0 & its<MaxItn

   % The stiffness matrix in the hierarchical basis is
   % K1=S^TKS:

   v=HierToNodalTrans1(T,K*(HierToNodal1(T,p)));
   c2=p'*v;

   % Update the estimated solution x:

   a=c1/c2;
   U=U+a*p;
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
      disp(['HierCG iteration ',int2str(its),': residual = ',num2str(res),...
            ', relative residual = ',num2str(res/res0)])
   end

end

relres=res/res0;
if trace==1
   disp(['HierCG iteration ',int2str(its),': residual = ',num2str(res),...
         ', relative residual = ',num2str(res/res0)])
end
if trace
   if relres<Tol
      disp(['HierCG succeeded in reducing the relative residual below ',...
            num2str(Tol,'%.3g')])
   else
      disp('HierCG halted because the iteration limit was reached')
   end
end

% Convert back to the nodal basis:

U=HierToNodal1(T,U);
