function [ WaveGuideSegment ] = NormCoeff( WaveGuideSegment )
% Computes the Normalization constants of a Waveguide Segment modes
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
%     WaveGuideSegment.kh.x(1:Nh)  
%     WaveGuideSegment.kh.y(1:Nh)  
%
%     WaveGuideSegment.Ne 
%     WaveGuideSegment.me(1:Ne)
%     WaveGuideSegment.ne(1:Ne) 
%     WaveGuideSegment.kh.x(1:Ne)  
%     WaveGuideSegment.kh.y(1:Ne)  
%
%
% [OUT]
%   Ah(1:Nh) = Normalization coefficients for (h) modes
%
%   Ae(1:Ne) = same for (e) modes
%

Ah = [];
for i=1:WaveGuideSegment.Nh
    Ah(i) = ...
          OneModeNormCoeff(WaveGuideSegment.a, WaveGuideSegment.b, ...
          WaveGuideSegment.mh(i),WaveGuideSegment.nh(i), ...
          WaveGuideSegment.kh.x(i),WaveGuideSegment.kh.y(i));
end
Ae = [];
for i=1:WaveGuideSegment.Ne
    Ae(i) = ...
          OneModeNormCoeff(WaveGuideSegment.a, WaveGuideSegment.b, ...
          WaveGuideSegment.me(i),WaveGuideSegment.ne(i), ...
          WaveGuideSegment.ke.x(i),WaveGuideSegment.ke.y(i));
end

WaveGuideSegment.Ah = Ah;
WaveGuideSegment.Ae = Ae;

