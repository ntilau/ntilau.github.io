function V=fullmg1(T,fnk,K,F,params)

% U=fullmg1(T,fnk,K,F,params)
%
%   This function applies the full multigrid mu-cycle
%   algorithm to solve the system KU=F arising from
%   the BVP
%
%        -div(k*grad u)=f in Omega,
%                     u=0 on Gamma,
%               k*du/dn=0 on Bndy(Omega)-Gamma
%
%   using piecewise linear finite elements.
%
%   The optional input params is a structure with the
%   following fields (defaults are in parentheses):
%
%      params.PreIts (1) - Number of Gauss-Seidel
%             pre-smoothing iterations at each level
%      params.PostIts (1) - Number of Gauss-Seidel
%             post-smoothing iterations at each level
%      params.mu (1) - Scheduling parameter; 1 yields
%             the V-cycle, 2 the W-cycle
%      params.nmu (1) - Number of mu-cycles done at
%             each level.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if nargin<5
   params.PreIts=1;
   params.PostIts=1;
   params.mu=1;
   params.nmu=1;
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
   if ~isfield(params,'nmu')
      params.nmu=1;
   end
end

% If this is not the coarsest mesh, then call fmg1
% recursively.

Nf=length(T.FNodePtrs);
if isfield(T,'LevelNodes') & length(T.LevelNodes)>1 & Nf>0

   T0=unRefine1(T);
   if length(T0.FNodePtrs)>0
      K0=Stiffness1(T0,fnk);
      F0=InterpolateTrans1(T,T0,F);
      V0=fullmg1(T0,fnk,K0,F0,params);
      V=Interpolate1(T0,T,V0);
   else
      V=zeros(Nf,1);
   end

else

   V=zeros(Nf,1);

end

% Apply nmu mu-cycles to solve the system on the
% current mesh:

for i=1:params.nmu

   V=mgmu1(T,fnk,K,F,V,params);

end
