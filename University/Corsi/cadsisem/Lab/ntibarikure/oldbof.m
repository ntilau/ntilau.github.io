%   step = step data structure
%
%     step{i}.a = waveguide width i=1,2
%     step{i}.b = waveguide height i=1,2
%     step{i}.Nh = number of modes
%     step{i}.mh(1:Nh) = index "m" of mode "H" number i
%     step{i}.nh(1:Nh) = index "n" of mode "H" number i
%     step{i}.Ne = number of modes
%     step{i}.me(1:Ne) = index "m" of mode "E" number i
%     step{i}.ne(1:Ne) = index "n" of mode "E" number i
%
%
%     step{3}.xo offset of the SECOND waveguide axis with respect to 
%                FIRST waveguide axis on x
%     step{3}.yo offset of the SECOND waveguide axis with respect to 
%                FIRST waveguide axis on y
%
%   k0 = free space wavenumber
%
% [OUT]
%   S = Scattering matrix, step{1}.N + step{2}.N times step{1}.N +
%             step{2}.N square matrix
clear
% Geometria
WGS{1}.a=0.01905;
WGS{1}.b=0.009525;
WGS{1}.Nmodes = 12;
WGS{1}.l = 0.01;
WGS{1}.xo=0;
WGS{1}.yo=0;

WGS{2}.a=0.01705;
WGS{2}.b=0.007525;
WGS{2}.Nmodes = 12;
WGS{2}.xo=0.000;
WGS{2}.yo=0.000;
WGS{2}.l = 0.05;

WGS{3}.a=0.01905;
WGS{3}.b=0.009525;
WGS{3}.Nmodes = 12;
WGS{3}.xo=0.000;
WGS{3}.yo=0.000;
WGS{3}.l = 0.01;


FS.start = 10*10^9;
FS.end   = 15*10^9;
FS.N     = 51;

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
% cd 'MMfront-end';
% %figure;
% %drawgeo(Nsteps, sym, M, a, b, c, d, l);
% [fr, S11r, S21r] = mmrcdps( FS.start/10^9, FS.end/10^9, FS.N, Nsteps,...
%     sym, M, a*1000, b*1000, c*1000, d*1000, l*1000);
% cd '..';

[S,WGS,FS] = MultiStepDevice(WGS,FS);
figure;

if (iscell(S))
    for i=1:FS.N
        S11(i) = S{i}.S11(1,1);
        S21(i) = S{i}.S21(1,1);
        check(i) = abs(S{i}.S11(1,1))^2 + abs(S{i}.S21(1,1))^2;
    end

    subplot(2,1,1);
    plot(FS.f/10^9,20*log10(abs(S11)),'+',FS.f/10^9,20*log10(abs(S21)),'+');
    xlabel('Frequency [GHz]');
    ylabel('Amplitude [dB]');
    legend('|S_{11}|','|S_{21}|');
    hold
    plot(fr,20*log10(abs(S11r)),fr,20*log10(abs(S21r)));
    hold
    subplot(2,1,2);
    plot(FS.f/10^9,atan2(imag(S11),real(S11))*180/pi,'+',FS.f/10^9,atan2(imag(S21),real(S21))*180/pi,'+');
    xlabel('Frequency [GHz]');
    ylabel('Phase [deg]');
    legend('\angle S_{11}','\angle S_{21}');
    hold
    plot(fr,atan2(imag(S11r),real(S11r))*180/pi,fr,atan2(imag(S21r),real(S21r))*180/pi);
    hold
    check
end