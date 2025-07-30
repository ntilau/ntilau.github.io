function [c] = cost(p);
% Geometria
WGS{1}.a=0.01905;
WGS{1}.b=0.009525;
WGS{1}.Nmodes = 12;
WGS{1}.l = 0.01;
WGS{1}.xo=0;
WGS{1}.yo=0;

WGS{2}.a=0.01905;
WGS{2}.b=p(1);
WGS{2}.Nmodes = 12;
WGS{2}.xo=0.000;
WGS{2}.yo=- (WGS{1}.b-WGS{2}.b)/2;
WGS{2}.l=p(2);

WGS{3}.a=0.01905;
WGS{3}.b=0.009525/2;
WGS{3}.Nmodes = 12;
WGS{3}.xo=0.000;
WGS{3}.yo=-0.009525/4;
WGS{3}.l = 0.01;

FS.start = 12.5*10^9;
FS.end   = 12.5*10^9;
FS.N     = 1;

delta = 10^-5;

[S,WGSx,FS] = MultiStepDevice(WGS,FS,0);
    
c = abs(S{1}.S11(1,1))
