function z0 = WaveGuideSegmentDraw(WaveGuideSegment,explode,z0)

ze = 0;
if (explode) 
    ze = WaveGuideSegment.b;
    ze = ze/length(WaveGuideSegment);
end

z0 = ShowSegment(WaveGuideSegment,z0)+ze;
ShowCap(WaveGuideSegment,WaveGuideSegment,z0-ze/2);

axis('equal');