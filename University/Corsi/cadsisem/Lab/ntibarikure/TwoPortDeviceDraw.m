function  [Position] = TwoPortDeviceDraw( TwoPortDevice, explode )
%Draws a single Two Port device
% V 1.0 - Ott. 2007
% V 2.0 - 21 Nov. 2008 - ported to multiport device, added .zo
% ------------------------------------------------------------------------
% [IN]
%  TwoPortDevice = a TwoPortDevice structure
%  explode            = 0 nothing is drawn, 1 compact draw, 2 exploded draw
%
ze = 0;
z0 = TwoPortDevice{1}.zo;
if(explode)
    for i=1:length(TwoPortDevice)
        ze = ze + TwoPortDevice{i}.b;
    end
    ze = ze / length(TwoPortDevice);
    if(sign(z0) == -1)
        z0 = -(ze*(length(TwoPortDevice))) + z0;
        if(length(TwoPortDevice) == 1)
            z0 = z0 - ze/2;
        end
    end           
end

for i=1:length(TwoPortDevice)-1
    z0 = z0 + ze/2;
    z0 = ShowSegment(TwoPortDevice{i},z0)+ze/2;
    WaveGuideCapDraw(TwoPortDevice{i},TwoPortDevice{i+1},z0);
end

z0 = z0 + ze/2;
z0 = ShowSegment(TwoPortDevice{length(TwoPortDevice)},z0);
axis equal;

Position = z0 + ze/2;