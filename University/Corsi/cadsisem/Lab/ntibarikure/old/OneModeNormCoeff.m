function [ A ] = OneModeNormCoeff( a, b, m, n, kx, ky )
% Compute normalization for mode m,n in rectangular waveguide
% V 1.0 - 26 Sept. 2007
% ------------------------------------------------------------------------
% [IN]
%    a,b - Waveguide dimensions along x and y, respectively
%    m,n - mode indices
%    kx,ky - Eigenvalues along x and y
%   
% [OUT]
%    A - Normalization coefficient
%

if (m==0)
    dm = 1;
else
    dm = 0;
end

if (n==0)
    dn = 1;
else
    dn = 0;
end

A = 2 / ( sqrt(a*b) * ...
    sqrt(kx^2*(1+dn)+ky^2*(1+dm)) );