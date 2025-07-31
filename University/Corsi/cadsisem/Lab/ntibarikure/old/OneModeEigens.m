function [ kx, ky ] = OneModeEigens( a, b, m, n )
% Compute eigenvalues for mode m,n in rectangular waveguide
% V 1.0 - 26 Sept. 2007
% ------------------------------------------------------------------------
% [IN]
%    a,b - Waveguide dimensions along x and y, respectively
%    m,n - mode indices
%   
% [OUT]
%    kx,ky - Eigenvalues along x and y
%

kx = m*pi/a;

ky = n*pi/b;



