function [T,fail,meth]=DefineBases(T,ntries)

% [T,fail]=DefineBases(T,ntries)
%
%   This function implements a heuristic algorithm to
%   define the list of bases for the triangles in
%   the mesh T.  If it is successful, it adds the
%   field Bases to T; T.Bases(i) is the index of
%   the base of triangle i in T.Edges.
%
%   The input ntries determines how many times
%   the heuristic algorithm is attempted; the default
%   is ntries=4.  (There is a random element to
%   the algorithm, so it can be attempted repeatedly.
%   The probability of success increases with ntries,
%   but obviously so does the execution time.)
%
%   The output flag fail is 0 if the algorithm succeeds
%   (so that T.Bases is added to T) and nonzero if
%   the algorithm fails (in which case T is unchanged).
%
%   T.Bases is used by the newest node refinement algorithm.
%   See LocalRefine1 for details.

% The following algorithm is based on a linear programming
% formulation of the problem.  If the linear program
% has an integer-valued solution, then DefineBases succeeds.
% However, this is not guaranteed.  The code tries four
% non-random cost functions and then ntries-4 random
% cost functions, if necessary.

if nargin<2
   ntries=4;
end

Nt=size(T.Elements,1);
Ne=size(T.Edges,1);

% First, get the triangle-edge incidence matrix

A=TriEdgeIncidence(T);

% Define the right-hand side for the LP constraints:

b=ones(Nt,1);

% Get the lengths of the edges in T:

c=zeros(Ne,1);
for i=1:Ne
   c(i,1)=norm(T.Nodes(T.Edges(i,1),:)-T.Nodes(T.Edges(i,2),:));
end

% Weight boundary edges by half:

i=find(T.EdgeEls(:,2)<=0);
c(i)=0.5*c(i);

% Define ntries different cost functions.
%
% 1: Maximize the total length of the chosen bases.
% 2: Maximize the number of bases chosen.
% 3: Minimize the total length of the chosen bases.
% 4: Minimize the number of bases chosen.
% 5,6,...,ntries: random

C=[c,ones(Ne,1),-c,-ones(Ne,1)];
for i=5:ntries
   C=[C,rand(Ne,1)];
end

% Invoke the simplex method up to ntries times, looking
% for an integer-valued solution:

fail=1;
for i=1:ntries
   x=rsimplex(C(:,i),A,b,zeros(Ne,1),ones(Ne,1));
   if norm(x-round(x))<100*eps*norm(x)
      fail=0;
      meth=i;
      break
   end
end

if fail
   meth=0;
   return
else

   % An integer-valued solution was found.
   % x now indicates the edges chosen as bases.  Loop through
   % the triangles and record the base of each:

   T.Bases=zeros(Nt,1);
   for i=1:Nt
      e=abs(T.Elements(i,:));
      T.Bases(i)=e(find(x(e)==1));
   end

end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function A=TriEdgeIncidence(T)

% A=TriEdgeIncidence(T)
%
%   This function computes the triangle-edge incidence
%   matrix of the mesh T.  The result is an Nt by Ne
%   sparse 0-1 matrix.

Nt=size(T.Elements,1);
Ne=size(T.Edges,1);
A=sparse(Nt,Ne);

for i=1:Nt
   A(i,abs(T.Elements(i,:)))=1;
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function x=rsimplex(c,A,b,l,u)

% x=rsimplex(c,A,b,l,u)
%
%   This function applies the revised simplex method to the LP
%
%         max  c'x
%         s.t. Ax=b
%              l<=x<=u

% Get the problem size

[m,n]=size(A);

% Get a value for scaling:

sval=max([max(max(abs(A))),max(abs(b))])*1e5*eps;

% Set up the Phase 1 LP

% Create the augmented cost vector and constraint matrix

c1=zeros(m+n,1);
A1=[A,speye(m)];

% Assign the basic variables

bfs.B=n+1:n+m;

% Assign the nonbasic variables

bfs.N1=[];
bfs.N2=[];
bfs.N3=[];
bfs.x=zeros(n+m,1);
for j=1:n
   if l(j)>-inf
      bfs.x(j)=l(j);
      bfs.N1=[bfs.N1,j];
   elseif u(j)<inf
      bfs.x(j)=u(j);
      bfs.N2=[bfs.N1,j];
   else
      bfs.N3=[bfs.N3,j];
   end
end

% Solve for the basic variables

bfs.x(n+1:n+m)=b-A*bfs.x(1:n);

% Create the extended constraints and
% define the extended cost vector

l1=[l;zeros(m,1)];
u1=[u;zeros(m,1)];
for i=1:m
   if bfs.x(n+i)>=0
      l1(n+i)=0;
      u1(n+i)=inf;
      c1(n+i)=-1;
   else
      l1(n+i)=-inf;
      u1(n+i)=0;
      c1(n+i)=1;
   end
end

% Now invoke rsimplex_bfs to solve the Phase 1 LP

bfs=rsimplex_bfs(c1,A1,b,l1,u1,bfs);

% If the optimal value in Phase 1 is not zero, then the
% program is infeasible.

if any(abs(bfs.x(n+1:n+m))>sval)

   error('The LP is infeasible')

% Otherwise, invoke Phase 2

else

   % Change the bounds for the artificial variables

   l1(n+1:n+m)=zeros(m,1);
   u1(n+1:n+m)=zeros(m,1);

   % Change the extended cost vector

   c1=[c;zeros(m,1)];

   % Apply the simplex method again

   [bfs,tflag]=rsimplex_bfs(c1,A1,b,l1,u1,bfs);

   x=bfs.x(1:n);
   z=c'*x;
   if tflag==1
      error('The LP is unbounded')
   end

end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [bfs,tflag]=rsimplex_bfs(c,A,b,l,u,bfs);

% [bfs,termcode]=rsimplex_bfs(c,A,b,l,u,bfs);
%
%   This function applies the revised simplex method to the LP
%
%         max  c'x
%         s.t. Ax=b
%              l<=x<=u
%
%   An initial basic feasible solution bfs must be provided.
%   The basic feasible solution is described by a structure
%   containing the following fields
%
%       bfs.x - the BFS itself (an n-vector)
%       bfs.B - the index set for the basis
%       bfs.N1 - the index set for the nonbasic variables at
%                their lower bounds
%       bfs.N2 - the index set for the nonbasic variables at
%                their upper bounds
%       bfs.N3 - the index set for the unrestricted nonbasic
%                variables
%       (The index sets are all row vectors.)
%
%   The return code termcode indicates how the simplex method
%   terminated:
%
%        termcode==0 - Optimal solution found
%        termcode==1 - LP is unbounded

% Get the problem size

[m,n]=size(A);

% Get a value for scaling:

sval=max([max(max(abs(A))),max(abs(b))])*1e5*eps;

% Main iteration

done=0;
while ~done

   % Get the basis A_B matrix and factor it

   AB=A(:,bfs.B);
   [L,U]=lu(AB);

   % Gather the indices of the nonbasic variables

   N=[bfs.N1,bfs.N2,bfs.N3];
   n1=length(bfs.N1);
   n2=length(bfs.N2);
   n3=length(bfs.N3);

   % Step 1: Compute the dual vector y and the vector of
   %         prices

   y=L'\(U'\c(bfs.B));
   cbar=c(N)-A(:,N)'*y;

   % Now choose the entering variable

   % First identify all of the candidates:

   i1=find(cbar(1:n1)>sval);
   i2=find(cbar(n1+1:n1+n2)<-sval);
   i3=find(abs(cbar(n1+n2+1:n1+n2+n3))>sval);

   % If there are no candidates, the current BFS is optimal

   if isempty(i1)&isempty(i2)&isempty(i3)

      done=1;
      break;

   end

   % If there are candidates, choose the entering variable by
   % the smallest-subscript rule.

   pc=min([bfs.N1(i1),bfs.N2(i2),bfs.N3(i3)]);
   if isempty(bfs.N1)
      i1=[];
   else
      i1=find(bfs.N1==pc);
   end
   if ~isempty(i1)
      Nflag=1;
      pc=bfs.N1(i1);
   else
      if isempty(bfs.N2)
         i2=[];
      else
         i2=find(bfs.N2==pc);
      end
      if ~isempty(i2);
         Nflag=2;
         pc=bfs.N2(i2);
      else
         if isempty(bfs.N3)
            i3=[];
         else
            i3=find(bfs.N3==pc);
         end
         if ~isempty(i3)
            if cbar(n1+n2+i3)>0
               Nflag=3;
            else
               Nflag=4;
            end
            pc=bfs.N3(i3);
         else
            error('Inconsistency in choice of entering variable')
         end
      end
   end

   % Step 2:  Find the changes in the basic variables and choose the
   %          leaving variable

   d=U\(L\A(:,pc));

   % Identify the candidates for leaving variables

   % First look among the basic variables

   pr=[];
   len=0;
   for i=1:m

      if (d(i)>sval & (Nflag==1|Nflag==3)) | ...
         (d(i)<-sval & (Nflag==2|Nflag==4))
         if l(bfs.B(i))>-inf
            len=len+1;
            pr(len,:)=[i,abs((bfs.x(bfs.B(i))-l(bfs.B(i)))/d(i))];
         end
      elseif (d(i)>sval & (Nflag==2|Nflag==4)) | ...
         (d(i)<-sval & (Nflag==1|Nflag==3))
         if u(bfs.B(i))<inf
            len=len+1;
            pr(len,:)=[i,abs((bfs.x(bfs.B(i))-u(bfs.B(i)))/d(i))];
         end
      end

   end

   % Now look at the entering variable itself

   if Nflag==1

      % The entering variable is increasing

      if u(pc)<inf
         len=len+1;
         pr(len,:)=[0,u(pc)-bfs.x(pc)];
      end

   elseif Nflag==2

      % The entering variable is decreasing

      if l(pc)>-inf
         len=len+1;
         pr(len,:)=[0,bfs.x(pc)-l(pc)];
      end

   end

   if len==0

      % No variable must leave the basis, so the LP is unbounded

      done=1;
      tflag=1;
      return

   end

   % Now we can choose the candidates for the leaving variables

   t=min(pr(:,2));
   k=find(abs(pr(:,2)-t)<sval);

   % Check to see if the entering variable should immediately leave

   if pr(k(length(k)),1)==0

      % The entering variable leave immediately.  We just switch
      % its index from N1 to N2 or vice versa

      ipr=pc;
      pr=0;
      if Nflag==1
         bfs.N2=[bfs.N2,bfs.N1(i1)];
         bfs.N1=[bfs.N1(1:i1-1),bfs.N1(i1+1:n1)];
      elseif Nflag==2
         bfs.N1=[bfs.N1,bfs.N2(i2)];
         bfs.N2=[bfs.N2(1:i2-1),bfs.N2(i2+1:n2)];
      else
         error('Inconsistency in entering-leaving variable')
      end

   elseif length(k)==1

      % There is only one candidate for the leaving variable

      ipr=bfs.B(pr(k,1));
      pr=pr(k,1);

   else

      % There are multiple candidates to leave the basis.
      % Choose the leaving variable according to the
      % smallest-subscript rule.
   
      [ipr,k1]=min(bfs.B(pr(k,1)));
      pr=pr(k(k1),1);

   end

   % Finally, update the index sets and the new BFS

   if Nflag==1 | Nflag==3  % Entering variable increases

      bfs.x(bfs.B)=bfs.x(bfs.B)-t*d;
      bfs.x(pc)=bfs.x(pc)+t;

   else   % Entering variable decreases

      bfs.x(bfs.B)=bfs.x(bfs.B)+t*d;
      bfs.x(pc)=bfs.x(pc)-t;

   end

   % Update the index sets unless the entering variable
   % is also the leaving variable.
   if pc~=ipr

      if Nflag==1 & d(pr)>0
         tmp=bfs.B(pr);
         bfs.B(pr)=bfs.N1(i1);
         bfs.N1(i1)=tmp;
      elseif Nflag==1 & d(pr)<0
         tmp=bfs.B(pr);
         bfs.B(pr)=bfs.N1(i1);
         bfs.N1=[bfs.N1(1:i1-1),bfs.N1(i1+1:n1)];
         bfs.N2(n2+1)=tmp;
      elseif Nflag==2 & d(pr)<0
         tmp=bfs.B(pr);
         bfs.B(pr)=bfs.N2(i2);
         bfs.N2=[bfs.N2(1:i2-1),bfs.N2(i2+1:n2)];
         bfs.N1(n1+1)=tmp;
      elseif Nflag==2 & d(pr)>0
         tmp=bfs.B(pr);
         bfs.B(pr)=bfs.N2(i2);
         bfs.N2(i2)=tmp;
      elseif (Nflag==3 & d(pr)>0) | (Nflag==4 & d(pr)<0)
         tmp=bfs.B(pr);
         bfs.B(pr)=bfs.N3(i3);
         bfs.N3=[bfs.N3(1:i3-1),bfs.N3(i3+1:n3)];
         bfs.N1(n1+1)=tmp;
      else
         tmp=bfs.B(pr);
         bfs.B(pr)=bfs.N3(i3);
         bfs.N3=[bfs.N3(1:i3-1),bfs.N3(i3+1:n3)];
         bfs.N2(n2+1)=tmp;
      end

   end

end
tflag=0;
