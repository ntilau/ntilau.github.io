function errs=ExpResidual1(T,fnk,fnf,h,U,g)

% errs=ExpResidual1(T,fnk,fnf,h,U,g)
%
%   This function estimates the errors in (U,g),
%   where (U,g) is the (piecewise linear) finite
%   element solution to the BVP
%
%        -div(k*grad u)=f in Omega,
%             u=g on Gamma,
%             k*du/dn=h on Bndy(Omega)-Gamma
%
%   on the mesh T.  The explicit residual method is
%   used.  (Since there is an unknown constant
%   involved in the error bound, which is not
%   estimated by this code, the numbers produced
%   by this routine should be regarded as
%   error indicators, not error estimators.)
%
%   The input vector U gives the nodal values at
%   the free node and the input vector g gives
%   the nodal values at the constrained nodes.
%   If g is omitted, it is taken to be the zero
%   vector.
%
%   The inputs fnk and fnf define k(x,y) and f(x,y).
%   fnk can be a positive scalar or a function of
%   two variables, and fnf must be a function of
%   two variables.  If fnk and/or fnf are omitted, then
%   k and/or f are taken to be the constant functions
%   1 and 0, respectively.
%
%   See "help Mesh1" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if T.Degree~=1
   error('Input mesh must have degree 1')
end

if isempty(fnk)
   fnk=1.0;
end
if isnumeric(fnk)
   nkflag=1;
else
   nkflag=0;
end

if isempty(h)
   h=zeros(length(T.FBndyEdges),2);
end

Nt=size(T.Elements,1);
errs=zeros(Nt,1);

% Record the gradients of all the basis functions at all
% of the quadrature nodes:

G=[-1 1 0;-1 0 1];

% Get the lengths of the edges, the midpoints and the values of
% fnk (if fnk is given):

Ne=size(T.Edges,1);
lens=zeros(Ne,1);
if ~nkflag
   kvals=zeros(Ne,1);
   mids=zeros(Ne,2);
end

for i=1:Ne
   e=T.Edges(i,:);
   lens(i)=norm(T.Nodes(e(1),:)-T.Nodes(e(2),:));
   if ~nkflag
      mids(i,:)=0.5*(T.Nodes(e(1),:)+T.Nodes(e(2),:));
   end
end
if ~nkflag
   kvals=feval(fnk,mids(:,1),mids(:,2));
end

% Record gradients and diameters:

[grads,cents]=getGradients1(T,U,g);
diams=getDiameters(T);

% Get the values of f at the centroids (if f is nonzero):

if ~isempty(fnf)
   fvals=feval(fnf,cents(:,1),cents(:,2));
end

% If k is nonconstant, then its gradients are needed at
% the centroids.  Estimate them by finite differences:

if ~nkflag

   kgrads=zeros(2,Nt);

   % Get the values of k at the centroids:

   kvals0=feval(fnk,cents(:,1),cents(:,2));

   % Estimate the partials w.r.t x:

   h1=diams/10;
   kvals1=feval(fnk,cents(:,1)+h1,cents(:,2));
   kgrads(1,:)=((kvals1-kvals0)./h1)';
      
   % Estimate the partials w.r.t y:

   kvals1=feval(fnk,cents(:,1),cents(:,2)+h1);
   kgrads(2,:)=((kvals1-kvals0)./h1)';

end      

% Compute the interior residuals

for i=1:Nt

   % Evaluate f at the quadrature node:

   if ~isempty(fnf)
      r=fvals(i);
   else
      r=0;
   end

   % If fnk is given (so that k is assumed nonconstant), correct the
   % residual by div(k*grad u_h):

   if ~nkflag
      r=r+kgrads(:,i)'*grads(:,i);
   end

   % Now estimate the integral:

   c=getNodes1(T,i);
   adetJ=abs(det([c(2,1)-c(1,1),c(3,1)-c(1,1);c(2,2)-c(1,2),c(3,2)-c(1,2)]));
   errs(i)=diams(i)*diams(i)*0.5*adetJ*r*r;

end

% Add the boundary residuals:

for i=1:Ne

   % Extract the indices of the elements adjacent to this
   % edge:

   els=T.EdgeEls(i,:);

   if els(2)<0

      % This is a free boundary edge.

      % Estimate h at the midpoint:

      hval=0.5*(h(-els(2),1)+h(-els(2),2));

      % Get the normal vector:

      n=getNormal1a(T,els(1),i);

      % Estimate the integral of the residual and add it to the
      % error estimate:

      if ~nkflag
         R=(hval-kvals(i)*(grads(:,els(1))'*n));
      else
         R=(hval-fnk*(grads(:,els(1))'*n));
      end
      I=(diams(els(1))*lens(i)*R*R);
      errs(els(1))=errs(els(1))+I;

   elseif els(2)>0

      % This is an interior edge:

      % Get the normal vector:

      n=getNormal1a( T,els(1),i );

      % Compute the jump in the flux:

      if ~nkflag
         R=kvals(i)*((grads(:,els(1))-grads(:,els(2)))'*n);         
      else
         R=fnk*((grads(:,els(1))-grads(:,els(2)))'*n);
      end

      % Add the integral of the edge residual to the error
      % estimates:

      I1=0.5*lens(i)*diams(els(1))*R*R;
      I2=0.5*lens(i)*diams(els(2))*R*R;
      errs(els(1))=errs(els(1))+I1;
      errs(els(2))=errs(els(2))+I2;

   end

end

errs=sqrt(errs);
