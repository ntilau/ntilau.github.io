function [ WaveGuideSegment ] = WaveNumbers( WaveGuideSegment, k0 )
% Computes the Wavenumbers and eigenvalues of a Wave Guide Segment
% V 1.0 - 26 Sept. 2007
% ------------------------------------------------------------------------
% [IN]
%   WaveGuideSegment = Waveguide segment data structure containing
%                      ALL FREQUENCY INDEPENDENT ITEMS
%   k0 - Free space wavenumber at current frequency.
%
% [OUT]
%  kh(1:Nh) propagation constants at k0 for mode "(h)"
%  ke(1:Ne) same for "(e)" modes
%

for i=1:WaveGuideSegment.Nh
    kh(i) = -sqrt(-1)*sqrt((WaveGuideSegment.mh(i)*pi/WaveGuideSegment.a)^2 + ...
          (WaveGuideSegment.nh(i)*pi/WaveGuideSegment.b)^2 - k0^2);
end
ke = [];
for i=1:WaveGuideSegment.Ne
    ke(i) = -sqrt(-1)*sqrt((WaveGuideSegment.me(i)*pi/WaveGuideSegment.a)^2 + ...
          (WaveGuideSegment.ne(i)*pi/WaveGuideSegment.b)^2 - k0^2);
end

WaveGuideSegment.kh.mn = kh;
WaveGuideSegment.ke.mn = ke;
