function errs=EJindicator1(T,U,g)

% errs=EJindicator1(T,U,g)
%
%   This function computes the Eriksson-Johnson
%   error indicator for the piecewise linear solution
%   (U,g) on the mesh T.  The indicator is based on
%   estimating the L-infinity of the second
%   derivatives of u on each element.  (Since there
%   is an unknown constant involved in the error bound,
%   which is not estimated by this code, the numbers
%   produced by this routine should be regarded as
%   error indicators, not error estimators.)
%
%   The input vector U gives the nodal values at
%   the free node and the input vector g gives
%   the nodal values at the constrained nodes.
%   If g is omitted, it is taken to be the zero
%   vector.
%
%   See "help Mesh1" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Deal with the optional input:

if nargin<3 | isempty(g)
   g=zeros(length(T.CNodePtrs),1);
end

% Get the gradient and centroid of each triangle:

[g,c]=getGradients1(T,U,g);

% Now loop over the triangles and compute the error indicator:

Nt=size(T.Elements,1);
errs=zeros(Nt,1);
for i=1:Nt

   % Get the indices of the three adjacent triangles
   % (if this triangle is adjacent to the boundary,
   % then the corresponding pointer is set to zero):

   t=getAdjacentTriangles(T,i);

   % Now loop over the three adjacent triangles and compute
   % the indicator for this triangle:

   for j=1:3
      if t(j)>0
         h=norm(c(i,:)-c(t(j),:));
         errs(i)=max([errs(i),abs(g(1,i)-g(1,t(j)))/h,...
                              abs(g(2,i)-g(2,t(j)))/h]);
      end
   end

end

errs=errs.*getDiameters(T).^2;
