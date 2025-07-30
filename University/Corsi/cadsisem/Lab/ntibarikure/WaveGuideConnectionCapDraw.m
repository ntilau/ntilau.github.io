function WaveGuideConnectionCapDraw( TwoPortDevice, Color,  z0 )
%Draws the Cap petween two Wave guide segment
% V 1.0 - Ott. 2007
% V 2.0 - 21 Nov. 2008 - ported to multiport device, added .zo
% ------------------------------------------------------------------------
% [IN]
%  WaveGuideSegmentA = a WaveGuideSegment structure
%  WaveGuideSegmentB = the other WaveGuideSegment structure
%  z0                = offset in drawing (drawing starts here)
%
        
a1  = TwoPortDevice.a;
b1  = TwoPortDevice.b;
xo1 = TwoPortDevice.xo;
yo1 = TwoPortDevice.yo;

x = [xo1 - a1/2, xo1 + a1/2, xo1 + a1/2, xo1 - a1/2];
y = [yo1 - b1/2, yo1 - b1/2, yo1 + b1/2, yo1 + b1/2];

patch(x,y,[z0, z0, z0, z0], Color, 'EdgeColor', 'k', 'Marker', '*');