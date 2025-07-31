%   step = step data structure
clear
% Geometria
WGS{1}.a=0.0158;
WGS{1}.b=0.0079;
WGS{1}.Nmodes = 21;
WGS{1}.l = 0.0;
WGS{1}.xo=0;
WGS{1}.yo=0;

WGS{2}.a=0.0158;
WGS{2}.b=0.009407;
WGS{2}.Nmodes = 21;
WGS{2}.xo=0.00;
WGS{2}.yo=-0.00075;
WGS{2}.l = 0.0022;

WGS{3}.a=0.0158;
WGS{3}.b=0.0079;
WGS{3}.Nmodes = 21;
WGS{3}.xo=0;
WGS{3}.yo=-0.00075*2;
WGS{3}.l = 0.006222;

FS.start = 15.7*10^9;
FS.end   = 17.5*10^9;
FS.N     = 61;
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPARE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[WGSS,Symmetry,Error]=StructureCheck(WGS);
Nsteps = length(WGSS)-1;
sym(1) = Symmetry.x;
sym(2) = Symmetry.y;
sym(3) = Symmetry.H;
sym(4) = Symmetry.E;
for i=1:Nsteps+1;
    M(i) = WGSS{i}.Nmodes;
    a(i) = WGSS{i}.a;
    b(i) = WGSS{i}.b;
    if (i>1)
        c(i) = abs((WGSS{i-1}.xo - WGSS{i-1}.a/2) - (WGSS{i}.xo - WGSS{i}.a/2));
        d(i) = abs((WGSS{i-1}.yo - WGSS{i-1}.b/2) - (WGSS{i}.yo - WGSS{i}.b/2));
    else
        c(i)=0;
        d(i)=0;
    end
    l(i) = WGSS{i}.l;
end     
cd 'MMfront-end';
figure;
%drawgeo(Nsteps, sym, M, a, b, c, d, l);
[fr, S11r, S21r] = mmrcdps( FS.start/10^9, FS.end/10^9, FS.N, Nsteps,...
    sym, M, a*1000, b*1000, c*1000, d*1000, l*1000);
cd '..';

[S,WGS,FS] = MultiStepDevice(WGS,FS);
figure

load S11Contraves.txt;
load S21Contraves.txt;

if (iscell(S))
    for i=1:FS.N
        S11(i) = S{i}.S11(1,1);
        S21(i) = S{i}.S21(1,1);
    end

    subplot(2,1,1);
    plot(FS.f/10^9,20*log10(abs(S11)),'+',FS.f/10^9,20*log10(abs(S21)),'+');
    hold
    plot(fr,20*log10(abs(S11r)),'.',fr,20*log10(abs(S21r)),'.');
    plot(S11Contraves(:,1),S11Contraves(:,6),S21Contraves(:,1),S21Contraves(:,6));
    hold
    
    subplot(2,1,2);
    plot(FS.f/10^9,atan2(imag(S11),real(S11))*180/pi,'+',FS.f/10^9,atan2(imag(S21),real(S21))*180/pi,'+');
    hold
    plot(fr,atan2(imag(S11r),real(S11r))*180/pi,'.',fr,atan2(imag(S21r),real(S21r))*180/pi,'.');
    plot(S11Contraves(:,1),S11Contraves(:,7),S21Contraves(:,1),S21Contraves(:,7));
    hold
end