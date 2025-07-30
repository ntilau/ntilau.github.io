function [ WaveGuideSegment ] = EigenModes( WaveGuideSegment )
% Computes the Wavenumbers and eigenvalues of a Wave Guide Segment
% V 1.0 - 26 Sept. 2007
% ------------------------------------------------------------------------
% [IN]
%   WaveGuideSegment = Waveguide segment data structure containing AT LEAST
%
%     WaveGuideSegment.a 
%     WaveGuideSegment.b  
%
%     WaveGuideSegment.Nh 
%     WaveGuideSegment.mh(1:Nh)  
%     WaveGuideSegment.nh(1:Nh)  
%     WaveGuideSegment.Ne 
%     WaveGuideSegment.me(1:Ne) 
%     WaveGuideSegment.ne(1:Ne)  
%
% [OUT]
%   kh = Structure of eigenmodes for (h) modes
%
%     kh.x(1:Nh)  eigenvalue kx for said mode
%     kh.y(1:Nh)  eigenvalue ky for said mode
%
%  ke = same for (e) modes
%

for i=1:WaveGuideSegment.Nh
    [kh.x(i), kh.y(i)] ...
        = OneModeEigens(WaveGuideSegment.a, WaveGuideSegment.b, ...
          WaveGuideSegment.mh(i),WaveGuideSegment.nh(i));
end
ke.x = [];
ke.y = [];
for i=1:WaveGuideSegment.Ne
    [ke.x(i), ke.y(i)] ...
        = OneModeEigens(WaveGuideSegment.a, WaveGuideSegment.b, ...
          WaveGuideSegment.me(i),WaveGuideSegment.ne(i));
end

WaveGuideSegment.kh = kh;
WaveGuideSegment.ke = ke;

