function uGrad=getGrad1(J,ll,U,g)

% g=getGrad1(J,ll,U,g)
%
%   This function computes the gradient of the piecewise
%   linear function u defined by its nodal values, on the
%   triangle which is the image of T_R under the linear
%   transformation J.  T_R is the standard reference triangle.
%   ll is the vector of pointers into (U,g), where U
%   contains the nodal values of u at the free nodes and g
%   at the constrained nodes.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Extract the nodal values of u:

w=zeros(3,1);
for j=1:3
   if ll(j)>0
      w(j)=U(ll(j));
   else
      w(j)=g(-ll(j));
   end
end

% Get the gradient of u on this triangle:

uGrad=[-1 1 0;-1 0 1]*w;
uGrad=J'\uGrad;
