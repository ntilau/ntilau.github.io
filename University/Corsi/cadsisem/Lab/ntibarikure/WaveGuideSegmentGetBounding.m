function [xmin,xmax,ymin,ymax] =...
    WaveGuideSegmentGetBounding(TwoPortSegment);

[a,b,xo,yo] = WaveGuideSegmentGetCrossSection(TwoPortSegment);

xmin = xo - a/2;
xmax = xo + a/2;
ymin = yo - b/2;
ymax = yo + b/2;