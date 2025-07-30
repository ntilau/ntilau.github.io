function WGSout = ReverseWaveGuideStructure(WGSin)

WGSout = {};
NbrSegments = length(WGSin);

Indices = 1:NbrSegments;
newIndices = sort(Indices, 'descend');

for i=1:NbrSegments
    WGSout{i} = WGSin{newIndices(i)};
end