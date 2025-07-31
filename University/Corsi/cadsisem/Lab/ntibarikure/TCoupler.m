clear;
clc;

%% Defines the Frequency Sweep
FS.start = 13*10^9;
FS.end   = 15*10^9;
FS.N     = 251;

%% Nbr of modes for calculus accuracy
Lambda = 299792458/FS.end;
Nmodes = floor(20*sqrt(a*b)/Lambda);

%% STRUCTURE IMPLEMETENTION
WGS{1}.D{1}.a = a;
WGS{1}.D{1}.b = b;
WGS{1}.D{1}.Nmodes = Nmodes;
WGS{1}.D{1}.l = length;
WGS{1}.D{1}.xo = a/2+t/2;
WGS{1}.D{1}.yo = 0.0;
WGS{1}.D{1}.zo = -((L1-Lgap)/2 + (WGS{1}.D{1}.l));

WGS{1}.D{2}.a = W1/2-t/2;
WGS{1}.D{2}.b = b;
WGS{1}.D{2}.Nmodes = Nmodes;
WGS{1}.D{2}.l = (L1-Lgap)/2;
WGS{1}.D{2}.xo = (W1/2+t/2)/2;
WGS{1}.D{2}.yo = 0.0;
WGS{1}.D{2}.zo = -(L1-Lgap)/2;

WGS{2}.D{1}.a = a;
WGS{2}.D{1}.b = b;
WGS{2}.D{1}.Nmodes = Nmodes;
WGS{2}.D{1}.l = length;
WGS{2}.D{1}.xo = -(a/2+t/2);
WGS{2}.D{1}.yo = 0;
WGS{2}.D{1}.zo = -((L1-Lgap)/2 + (WGS{2}.D{1}.l));

%% Defines the Nto1Connections
Nto1{1}.SideOne{1}.TwoPortDeviceIndex = 1;
Nto1{1}.SideOne{1}.TwoPortDevicePort = 2;
Nto1{1}.SideOne{2}.TwoPortDeviceIndex = 2;
Nto1{1}.SideOne{2}.TwoPortDevicePort = 2;
Nto1{1}.SideTwo.TwoPortDeviceIndex = 3;
Nto1{1}.SideTwo.TwoPortDevicePort = 1;
Nto1{1}.zo = 0;

%% Defines the Opened Ports
OpenPorts{1}.TwoPortDeviceIndex = 1;
OpenPorts{1}.TwoPortDevicePort = 1;
OpenPorts{2}.TwoPortDeviceIndex = 2;
OpenPorts{2}.TwoPortDevicePort = 1;
OpenPorts{3}.TwoPortDeviceIndex = 3;
OpenPorts{3}.TwoPortDevicePort = 2;


TeeCouplerSolve();



load Tee;
hold on;
plot(f,20*log(abs(S(:,1))),'k:',...
    f,20*log(abs(S(:,301))),'r:',...
    f,20*log(abs(S(:,601))),'g:',...
    f,20*log(abs(S(:,631))),'m:',...
    f,20*log(abs(S(:,691))),'b:',...
    f,20*log(abs(S(:,721))),'y:'...
    );

legend('S11_{1}','S21_{1}','S31_{1}','S31_{2}','S31_{3}','S31_{4}')
axis([min(f) max(f) -80 0]);