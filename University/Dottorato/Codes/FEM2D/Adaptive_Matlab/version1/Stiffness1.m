function K=Stiffness1(T,fnk)

% K=Stiffness1(T,fnk)
%
%   Assembles the stiffness matrix for the PDE
%
%        -div(k*grad u)=f in Omega,
%             u=g on Gamma,
%             k*du/dn=h on Bndy(Omega)-Gamma.
%
%   The coefficient k(x,y) is provided as the
%   input fnk; if k(x,y) is constant, fnk can
%   be replaced by a scalar or omitted for k(x,y)=1;
%   otherwise, fnk is a real-valued function of
%   two real variables.
%
%   T describes the triangulation of Omega.
%   For a description of the data structure T, see
%   "help Mesh1".

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if nargin<2||isempty(fnk)
   fnk=1;
end

% Allocate the stiffness matrix:

Nf=length(T.FNodePtrs);
K=sparse(Nf,Nf);

% Loop over the elements, adding the contributions from each.

vo=ones(3,1);
Nt=size(T.Elements,1);
for k=1:Nt

   % Get the coordinates of the vertices and their indices
   % in FNodePtrs and CNodePtrs:

   [c,ll]=getNodes1(T,k);

   % Each basis function, restricted to this triangle, is a function
   % of the form z=g(1)+g(2)x+g(3)y.  Compute the vector g for each of
   % three basis functions (the three vectors are stored as the columns
   % of the matrix C).

   M=[vo,c];
   C=inv(M);

   % The typical integral we must compute is
   %
   %      integral over Ti (k(x,y)(grad phi1).(grad phi2).
   %
   % The gradients are constant vectors, since the basis functions
   % are linear over this triangle.   So we just compute all the
   % dot products and store them in a matrix G:

   G=C(2:3,:)'*C(2:3,:);

   % We then compute the integral of k(x,y) over Ti.  We use a simple
   % one-point formula:

   % Compute the area of the triangle:

   J=[c(2,1)-c(1,1) c(3,1)-c(1,1);c(2,2)-c(1,2) c(3,2)-c(1,2)];
   A=0.5*abs(det(J));

   % Apply the quadrature rule:

   if isnumeric(fnk)
      I=fnk*A;
   else
      % Compute the centroid of the triangle:

      qpt=(1/3)*sum(c);

      I=A*feval(fnk,qpt(1),qpt(2));
   end

   % The triangle contributes to at most 6 entries in the (upper triangle
   % of the) stiffness matrix.  We compute these six entries in the
   % following double loop.

   for s=1:3

      lls=ll(s);
      if lls>0

         for r=1:s

            % If both vertices are free, then there is a contribution
            % to the stiffness matrix

            llr=ll(r);
            if llr>0

               if llr<=lls
                  K(llr,lls)=K(llr,lls)+G(r,s)*I;
               else
                  K(lls,llr)=K(lls,llr)+G(r,s)*I;
               end

            end

         end

      end

   end

end

% Now fill in the lower triangle of K, using the symmetry.

K=K+triu(K,1)';
