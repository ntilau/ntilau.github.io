function pts=Ellipsef(p1,p2,k)

% pts=Ellipsef(p1,p2,k)
%
%   This function returns k-1 evenly space points on the
%   interior of the arc of the ellipse
%
%               x^2+y^2/4=1
%
%   having endpoints p1 and p2.  The output pts is a
%   k-1 by 2 array.
%
%   If k is omitted, it is taken to be 2.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if nargin<3
   k=2;
end

if length(p1)~=2
   error('First input must be a vector of length 2');
end
if length(p2)~=2
   error('Second input must be a vector of length 2');
end

th1=atan2(p1(2)/2,p1(1));
th2=atan2(p2(2)/2,p2(1));

if abs(th1-th2)>pi
   if th1<th2
      th1=th1+2*pi;
   else
      th2=th2+2*pi;
   end
end

if th1<th2

   dth=(th2-th1)/k;
   th=linspace(th1+dth,th2-dth,k-1)';
   pts=[cos(th),2*sin(th)];

else

   dth=(th1-th2)/k;
   th=linspace(th2+dth,th1-dth,k-1)';
   pts=flipud([cos(th),2*sin(th)]);

end
