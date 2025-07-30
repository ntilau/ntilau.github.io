function [ WaveGuideSegment ] = DelayMatrix( WaveGuideSegment, k0 )
% Compute the Delays matrix for all modes for given waveguide segment
% V 1.0 - 26 Sept. 2007
% ------------------------------------------------------------------------
% [IN]
%   WaveGuideSegment = Waveguide segment data structure containing
%                      ALL FREQUENCY INDEPENDENT ITEMS 
%                      AND mode wavenumbers
%   k0 - Free space wavenumber at current frequency.
%   
% [OUT]
%   D - Delay matrix
%

D = [[diag(exp(-sqrt(-1)*WaveGuideSegment.kh.mn*WaveGuideSegment.l)),...
          zeros(WaveGuideSegment.Nh,WaveGuideSegment.Ne)];...
     [zeros(WaveGuideSegment.Ne,WaveGuideSegment.Nh),...
          diag(exp(-sqrt(-1)*WaveGuideSegment.ke.mn*WaveGuideSegment.l))]];
      
WaveGuideSegment.D = D;