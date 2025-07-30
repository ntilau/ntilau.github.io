
% Da Francesco Rossi
bbb = 6.814/1000;
lwg = 7.7075/1000;

WGS{1}.a=0.01905;
WGS{1}.b=0.009525;
WGS{1}.Nmodes = 20;
WGS{1}.l = 0.01;
WGS{1}.xo=0;
WGS{1}.yo=0;

WGS{2}.a=0.01905;
WGS{2}.b=bbb;
WGS{2}.Nmodes = 15;
WGS{2}.xo=0.000;
WGS{2}.yo=-(0.009525-bbb)/2;
%lwg = 1/sqrt((12.5*10^9/299800000)^2-(1/(WGS{1}.a*2))^2);
%Plength = pab11 + pi + paa21 + paa12 - paa11;
%WGS{2}.l = lwg*Plength/(4*pi)
WGS{2}.l = lwg;

WGS{3}.a=0.01905;
WGS{3}.b=0.009525/2;
WGS{3}.Nmodes = 10;
WGS{3}.xo=0.000;
WGS{3}.yo=-0.009525/4;
WGS{3}.l = 0.01;

FSs.start = 10*10^9;
FSs.end   = 15*10^9;
FSs.N     = 401;

[S,WGSx,FSs] = MultiStepDevice(WGS,FSs,1);

for i=1:FSs.N
    S11(i) = S{i}.S11(1,1);
    S21(i) = S{i}.S21(1,1);
end

figure
plot(FSs.f/10^9,20*log10(abs(S11)),FSs.f/10^9,20*log10(abs(S21)));
xlabel('Frequency [GHz]');
ylabel('Amplitude [dB]');
legend('|S_{11}|','|S_{21}|');
figure
plot(FSs.f/10^9,atan2(imag(S11),real(S11))*180/pi,FSs.f/10^9,atan2(imag(S21),real(S21))*180/pi);
xlabel('Frequency [GHz]');
ylabel('Phase [deg]');
legend('\angle S_{11}','\angle S_{21}');
