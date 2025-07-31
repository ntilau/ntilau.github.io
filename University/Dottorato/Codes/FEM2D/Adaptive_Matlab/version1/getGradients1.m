function [grads,centroids]=getGradients1(T,U,g)

% [grads,centroids]=getGradients1(T,U,g)
%
%   This function computes the gradients of
%   the piecewise linear function defined by
%   the nodal values U (free nodes) and g
%   (constrained nodes) on the mesh T.
%
%   The input g is optional and is taken to
%   be zero if omitted.
%
%   See "help Mesh1" for a description of the mesh T.
%
%   The output is the 2 by Nt array grads; the
%   Nt by 2 array centroids, which contains the
%   coordinates of the centroids of the triangles,
%   is also computed if requested.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Handle the optional input:

Nc=length(T.CNodePtrs);
if nargin<3 || isempty(g)
   g=zeros(Nc,1);
end

% Get the gradients element by element:

Nt=size(T.Elements,1);
grads=zeros(2,Nt);
vo=ones(3,1);
if nargout==2
   centroids=zeros(Nt,2);
end
for i=1:Nt

   % Get the coordinates of the vertices and their indices
   % in FNodePtrs and CNodePtrs:

   [c,ll]=getNodes1(T,i);

   % Get the nodal values of the piecwise linear function,
   % restricted to this triangle:

   w=zeros(3,1);
   for ii=1:3
      if ll(ii)>0
         w(ii)=U(ll(ii));
      else
         w(ii)=g(-ll(ii));
      end
   end

   % The piecewise linear function, restricted to this triangle,
   % is a function of the form z=a(1)+a(2)x+a(3)y.  Compute the
   % vector g:

   M=[vo,c];
   a=M\w;

   % Extract the gradient:

   grads(:,i)=a(2:3);

   % Compute the centroids (if requested):

   if nargout==2
      centroids(i,:)=mean(c);
   end

end
