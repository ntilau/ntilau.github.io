clear
lwg = 1/sqrt((12.5*10^9/299800000)^2-(1/(0.01905*2))^2);
eps = 10^-6;
N = 20;

%p(1) = 0.0068;
%p(2) = 0.0071;

p(1) = 0.009525*3/4;
p(2) = lwg/4;

for idx=1:N;
   g = gcost(p,eps);
   delta = - g';
   
   b(idx)  = p(1);
   l(idx)  = p(2)
   Sc(idx) = cost(p);
   
   plot ((1:idx),b*1000,(1:idx),l*1000,(1:idx),20*log10(Sc));
   drawnow
    
   a = linesearch(p,delta,eps);
   p = p + a*delta';
end
      
save pathtooptimum b l p;

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
WGS{2}.yo=-(0.009525-p(1))/2;
WGS{2}.l = p(2);

WGS{3}.a=0.01905;
WGS{3}.b=0.009525/2;
WGS{3}.Nmodes = 12;
WGS{3}.xo=0.000;
WGS{3}.yo=-0.009525/4;
WGS{3}.l = 0.01;

FSs.start = 10*10^9;
FSs.end   = 15*10^9;
FSs.N     = 501;

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
