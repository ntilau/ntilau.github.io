function V=mgmu1(T,fnk,K,F,V,params)

% U=mgmu1(T,fnk,K,F,V,params)
%
%   This function applies the multigrid mu-cycle
%   to solve the system KU=F arising from the BVP
%
%        -div(k*grad u)=f in Omega,
%                     u=0 on Gamma,
%               k*du/dn=0 on Bndy(Omega)-Gamma
%
%   using piecewise linear finite elements.  The
%   vector V is the initial estimate of the
%   solution; if V is omitted or empty, it is
%   taken to be the zero vector.
%
%   The optional input params is a structure with
%   the following fields (defaults are in
%   parentheses):
%
%      params.PreIts (1) - Number of Gauss-Seidel
%             pre-smoothing iterations at each level
%      params.PostIts (1) - Number of Gauss-Seidel
%             post-smoothing iterations at each level
%      params.mu (1) - Scheduling parameter; 1 yields
%             the V-cycle, 2 the W-cycle
%
%   The input mesh T is the finest mesh used in the
%   multigrid method and must be produced by calling
%   Refine1 one or more times on an initial mesh.
%
%   See "help Mesh1" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if nargin<6
   params.PreIts=1;
   params.PostIts=1;
   params.mu=1;
else
   if ~isfield(params,'PreIts')
      params.PreIts=1;
   end
   if ~isfield(params,'PostIts')
      params.PostIts=1;
   end
   if ~isfield(params,'mu')
      params.mu=1;
   end
end

% Assign the default value of V is necessary:

if nargin<5 || isempty(V)
   V=zeros(length(T.FNodePtrs),1);
end

% Relax on the current mesh (pre-smoothing):

V=GaussSeidel1(K,F,V,params.PreIts);

% If possible, do the coarse-mesh correction mu times:

if length(T.LevelNodes)>1

   T0=unRefine1(T);
   Nf0=length(T0.FNodePtrs);
   if Nf0>0

      % Form the equations on the coarser mesh:

      K0=Stiffness1(T0,fnk);
      F0=InterpolateTrans1(T,T0,F-K*V);

      % Perform the mu-cycle recursively mu times:

      V0=zeros(Nf0,1);
      for i=1:params.mu
         V0=mgmu1(T0,fnk,K0,F0,V0,params);
      end

      % Correct on the current mesh:

      V=V+Interpolate1(T0,T,V0);

   end

end


% Relax on the current mesh (post-smoothing):

V=GaussSeidel1(K,F,V,params.PostIts);
