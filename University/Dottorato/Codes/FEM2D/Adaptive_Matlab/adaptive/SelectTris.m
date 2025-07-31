function TList=SelectTris(d0,d1,e0,e1)

% TList=SelectTris(d0,d1,e0,d1)
%
%   Selects triangles to be refined from the
%   diameters (d1) and estimated errors (e1) on
%   each triangle.  The diameters (d0) and
%   estimated errors (e0) of the supertriangles
%   of the current triangles must also be provided.
%   The four arrays d0, d1, e0, e1 are all Nt by 1,
%   where Nt is the number of triangles.
%
%   The algorithm is the Babuska-Rheinboldt strategy,
%   but at least 20% of the triangles are always
%   selected.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

Nt=length(d0);

% Compute c and lambda for each triangle
% (use different calculation if the diameter of a
% triangle equals the diameter of its supertriangle):

lam=zeros(Nt,1);
ii=find(abs(d0-d1)<0.01*d1);
jj=find(abs(d0-d1)>=0.01*d1);
lam(ii)=2*log(e0(ii)./e1(ii))./log(2);
lam(jj)=log(e0(jj)./e1(jj))./log(d0(jj)./d1(jj));
c=e1./d1.^lam;

% Estimate the errors on a uniformly refined mesh:

e2=c.*(0.5*d1).^lam;
e2a=e1.^2./e0;
ii=find(e2>=e0);
e2(ii)=0.5*e1(ii);

% Select the triangles whose current errors are
% larger than the maximum predicted error:

m=max(e2);
TList=find(e1>m);
if length(TList)<0.2*Nt
   TList=[];
end

% if no triangles were selected by the above criterion,
% just refine the 20% with the greatest error:

if isempty(TList)
   [e1,ind]=sort(e1);
   n=floor(0.2*Nt);
   TList=ind(Nt-n+1:Nt);
end
