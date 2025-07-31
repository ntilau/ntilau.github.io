function [Vals,Grads]=getBubbleVals(enodes)

% [Vals,Grads]=getBubbleVals
%
%   This function returns the values and gradients of
%   the four bubble functions (on the reference triangle)
%   at the evaluation nodes contained in the n by 2 array
%   enodes.
%
%   Vals is 4 by n; each row corresponds to one bubble function
%   and each column to one evaluation node.
%
%   Grads is 2 by 4 by n; Grads(:,i,j) is the gradient of the ith
%   bubble function at the jth evaluation node.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Get the number of evaluation nodes:

n=size(enodes,1);

% Evaluate the bubble functions and their gradients:

Vals=zeros(4,n);
Grads=zeros(2,4,n);
for j=1:n

   s=enodes(j,1);
   t=enodes(j,2);
   u=1-s-t;

   Vals(:,j)=[4*u*s;4*s*t;4*u*t;27*s*t*u];
   Grads(:,:,j)=[4-8*s-4*t 4*t -4*t      27*t-54*s*t-27*t*t
                 -4*s      4*s 4-4*s-8*t 27*s-27*s*s-54*s*t];

end
