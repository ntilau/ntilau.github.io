function [WaveGuideSegment, OpenPortSegment,  WaveGuideStructure] = ...
    TwoPortDeviceGetPortSegment(WaveGuideStructure , PortRelated)

% Returns the first or the last segment of the waveguide structure to allow
% global junction

NSegment = length(WaveGuideStructure);
if(PortRelated == 1)
    WaveGuideSegment = WaveGuideStructure{1};
    OpenPortSegment = WaveGuideStructure{NSegment};
elseif(PortRelated == 2)
    OpenPortSegment = WaveGuideStructure{1};
    WaveGuideSegment = WaveGuideStructure{NSegment};
else
    Error.fatal = sprintf('Could not retrieve Port Segment',i+1);
    return;
end
    