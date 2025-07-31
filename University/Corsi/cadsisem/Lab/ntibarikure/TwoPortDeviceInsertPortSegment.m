function WaveGuideStructure = ...
    TwoPortDeviceInsertPortSegment( WaveGuideStructureToChange, WaveGuideSegment, Position)

NSegment = length(WaveGuideStructureToChange);
if(Position == 1)
        WaveGuideStructure.D{2:NSegment+1} = WaveGuideStructureToChange.D{1:NSegment};
        WaveGuideStructure.D{1} = WaveGuideSegment;
elseif(Position == 2)
    WaveGuideStructure.D{1:NSegment} = WaveGuideStructureToChange.D{1:NSegment};
    WaveGuideStructure.D{NSegment+1} = WaveGuideSegment;
else
    Error.fatal = sprintf('Could not insert Port Segment',i+1);
    return;
end