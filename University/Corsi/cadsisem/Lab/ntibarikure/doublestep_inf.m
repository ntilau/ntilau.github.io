%
%
% NO USARE GRADIENT!!!!
%
%
%
clear
% Geometria
WGS{1}.a=0.01905;
WGS{1}.b=0.009525;
WGS{1}.Nmodes = 12;
WGS{1}.l = 0.01;
WGS{1}.xo=0;
WGS{1}.yo=0;

WGS{2}.a=0.01905;
WGS{2}.b=0.009525;
WGS{2}.Nmodes = 12;
WGS{2}.xo=0.000;
WGS{2}.yo=0.000;
WGS{2}.l = 0.01;

WGS{3}.a=0.01905;
WGS{3}.b=0.009525/2;
WGS{3}.Nmodes = 12;
WGS{3}.xo=0.000;
WGS{3}.yo=-0.009525/4;
WGS{3}.l = 0.01;

FS.start = 12.5*10^9;
FS.end   = 12.5*10^9;
FS.N     = 1;

N   = 100;
lwg = 1/sqrt((12.5*10^9/299800000)^2-(1/(WGS{1}.a*2))^2);
L(1)   = lwg/4;
b(1)   = WGS{1}.b*3/4;

delta = 10^-5;
idx=1;

omega = 32;

for i=1:N

    [S,WGSx,FS] = MultiStepDevice(WGS,FS,0);
    
    b(idx) = WGS{2}.b;
    l(idx) = WGS{2}.l;
    Sc(idx) = 20*log10(abs(S{1}.S11(1,1)));
    plot ((1:idx),b*1000,(1:idx),l*1000,(1:idx),Sc);
    drawnow
    idx = idx+1;
    
    WGSdb = WGS;
    WGSdb{2}.b = WGSdb{2}.b + delta;
    WGSdb{2}.yo = - (WGSdb{1}.b-WGSdb{2}.b)/2;
    [Sdb,WGSx,FS] = MultiStepDevice(WGSdb,FS,0);
    
    WGSdl = WGS;
    WGSdl{2}.l = WGSdl{2}.l + delta;
    [Sdl,WGSx,FS] = MultiStepDevice(WGSdl,FS,0);
    
    
    grad = [ (abs(Sdb{1}.S11(1,1)) - abs(S{1}.S11(1,1)))/delta, ...
             (abs(Sdl{1}.S11(1,1)) - abs(S{1}.S11(1,1)))/delta ];
 
    mgrad = norm(grad);
    
    WGS{2}.b  = WGS{2}.b - omega*grad(1)*delta/mgrad;
    WGS{2}.l  = WGS{2}.l - omega*grad(2)*delta/mgrad;
    WGS{2}.yo = - (WGS{1}.b-WGS{2}.b)/2;
    omega=omega*0.95;
    
end
