function ShowGeo( WaveGuideStructure, explode )

figure;

z0=0;
ze = 0;
if (explode) 
    for i=1:length(WaveGuideStructure)
        ze = ze+WaveGuideStructure{i}.b;
    end
    ze = ze/length(WaveGuideStructure);
end
    
for i=1:length(WaveGuideStructure)-1
    
    z0 = ShowSegment(WaveGuideStructure{i},z0)+ze;
    ShowCap(WaveGuideStructure{i},WaveGuideStructure{i+1},z0-ze/2);
    
end

z0 = ShowSegment(WaveGuideStructure{length(WaveGuideStructure)},z0)+ze;

axis('equal');
