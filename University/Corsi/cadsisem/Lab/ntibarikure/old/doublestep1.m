clear
% Geometria
WGSa{1}.a=0.01905;
WGSa{1}.b=0.009525;
WGSa{1}.Nmodes = 12;
WGSa{1}.l = 0.00;
WGSa{1}.xo=0;
WGSa{1}.yo=0;

WGSa{2}.a=0.01905;
WGSa{2}.b=0.009525;
WGSa{2}.Nmodes = 12;
WGSa{2}.xo=0.000;
WGSa{2}.yo=0.000;
WGSa{2}.l = 0.00;

% Geometria
WGSb{1}.a=0.01905;
WGSb{1}.b=0.009525;
WGSb{1}.Nmodes = 12;
WGSb{1}.l = 0.00;
WGSb{1}.xo=0;
WGSb{1}.yo=0;

WGSb{2}.a=0.01905;
WGSb{2}.b=0.009525/2;
WGSb{2}.Nmodes = 12;
WGSb{2}.xo=0.000;
WGSb{2}.yo=0.000;
WGSb{2}.l = 0.00;

FS.start = 12.5*10^9;
FS.end   = 12.5*10^9;
FS.N     = 1;

N = 75;

for i=1:N
    WGSa{2}.b  = WGSa{1}.b*(0.5*(N-i+1)/(N+1)+0.5);
    WGSa{2}.yo = - (WGSa{1}.b-WGSa{2}.b)/2;
    [Sa,WGSx,FS] = MultiStepDevice(WGSa,FS,0);

    WGSb{1}.b  = WGSa{2}.b;
    WGSb{1}.yo = (WGSb{1}.b-WGSb{2}.b)/2;
    [Sb,WGSx,FS] = MultiStepDevice(WGSb,FS,0);

    b(i) = WGSa{2}.b;
    
    S11a(i) = Sa{1}.S11(1,1);
    S21a(i) = Sa{1}.S21(1,1);
    S12a(i) = Sa{1}.S12(1,1);

    S11b(i) = Sb{1}.S11(1,1);
    S21b(i) = Sb{1}.S21(1,1);

    S11aux(i) = S21a(i)*S11b(i)*S12a(i);
    
end

for i=1:N
    if (abs(S11a(i)) > abs(S11aux(i)))
        idx = i;
        break;
    end
end

a1 = abs(S11a(idx-1)) - abs(S11aux(idx-1));
a2 = abs(S11a(idx)) - abs(S11aux(idx));
alpha = abs(a1)/(abs(a1)+abs(a2));

bbb = b(idx-1)*(1-alpha) + b(idx)*(alpha);
aaa = abs(S11a(idx-1))*(1-alpha) + abs(S11a(idx))*(alpha);
figure
plot (b/0.009525,20*log10(abs(S11a)),'b-',b/0.009525,20*log10(abs(S21a)),'b--',...
    b/0.009525,20*log10(abs(S11b)),'r-',b/0.009525,20*log10(abs(S21b)),'r--',...
    b/0.009525,20*log10(abs(S11aux)),'m-');
hold
plot([0.5 1.0],[20*log10(aaa),20*log10(aaa)],'g-');
plot([bbb/0.009525,bbb/0.009525],[-25,0],'g-');
text(bbb/0.009525,-10,num2str(bbb));
text(bbb/0.009525,-12,num2str(bbb/0.009525));
axis([0.5 1 -25 0]);
hold

figure
plot (b/0.009525,angle(S11a)*180/pi,'b-',b/0.009525,angle(S21a)*180/pi,'b--',...
    b/0.009525,angle(S11b)*180/pi,'r-',b/0.009525,angle(S21b)*180/pi,'r--',...
    b/0.009525,angle(S11aux)*180/pi,'m-');
hold
paa11 = angle(S11a(idx-1))*(1-alpha) + angle(S11a(idx))*(alpha);
paa21 = angle(S21a(idx-1))*(1-alpha) + angle(S21a(idx))*(alpha);
paa12 = angle(S12a(idx-1))*(1-alpha) + angle(S12a(idx))*(alpha);
pab11 = angle(S11b(idx-1))*(1-alpha) + angle(S11b(idx))*(alpha);
paaux = angle(S11aux(idx-1))*(1-alpha) + angle(S11aux(idx))*(alpha);
plot([bbb/0.009525,bbb/0.009525],[-180, 0],'g-');
text(bbb/0.009525,-150,num2str(paa11*180/pi));
text(bbb/0.009525,-170,num2str(pab11*180/pi));
text(bbb/0.009525,-180,num2str(paaux*180/pi));
Dphase = paaux-paa11;
text(bbb/0.009525-.2,-170,num2str(Dphase*180/pi));
hold
axis([0.5 1 -180 0]);

WGS{1}.a=0.01905;
WGS{1}.b=0.009525;
WGS{1}.Nmodes = 12;
WGS{1}.l = 0.01;
WGS{1}.xo=0;
WGS{1}.yo=0;

WGS{2}.a=0.01905;
WGS{2}.b=bbb;
WGS{2}.Nmodes = 12;
WGS{2}.xo=0.000;
WGS{2}.yo=-(0.009525-bbb)/2;
lwg = 1/sqrt((12.5*10^9/299800000)^2-(1/(WGS{1}.a*2))^2);
Plength = pab11 + pi + paa21 + paa12 - paa11;
WGS{2}.l = lwg*Plength/(4*pi)

WGS{3}.a=0.01905;
WGS{3}.b=0.009525/2;
WGS{3}.Nmodes = 12;
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
