clear
l=0.01;

WGS1{1}.D{1}.a=0.0158;%0.01905;
WGS1{1}.D{1}.b=0.0079;%0.009525;
WGS1{1}.D{1}.Nmodes = 18;
WGS1{1}.D{1}.l = l;
WGS1{1}.D{1}.xo=0;
WGS1{1}.D{1}.yo=0;
WGS1{1}.D{1}.zo=-l;

WGS1{1}.D{2}.a=0.0229;%0.01905/2;
WGS1{1}.D{2}.b=0.0102;%0.009525/2;
WGS1{1}.D{2}.Nmodes = 18;
WGS1{1}.D{2}.l = l;
WGS1{1}.D{2}.xo=0;
WGS1{1}.D{2}.yo=0;
WGS1{1}.D{2}.zo=l;

% WGS1{2}.D{1}.a=0.0226;%0.01905/2;
% WGS1{2}.D{1}.b=0.0102;%0.009525/2;
% WGS1{2}.D{1}.Nmodes = 18;
% WGS1{2}.D{1}.l = l;
% WGS1{2}.D{1}.xo=0;
% WGS1{2}.D{1}.yo=0;
% WGS1{2}.D{1}.zo=l;

%% Defines the Nto1Connections
Nto1{1}.SideOne{1}.TwoPortDeviceIndex = 1;
Nto1{1}.SideOne{1}.TwoPortDevicePort = 2;
Nto1{1}.SideTwo{1}.TwoPortDeviceIndex = 2;
Nto1{1}.SideTwo{1}.TwoPortDevicePort = 1;
Nto1{1}.zo = 0;

%% Defines the Opened Ports
OpenPorts{1}.TwoPortDeviceIndex = 1;
OpenPorts{1}.TwoPortDevicePort = 1;
OpenPorts{2}.TwoPortDeviceIndex = 2;
OpenPorts{2}.TwoPortDevicePort = 2;

%% Defines the Frequency Sweep
FS.start = 10*10^9;
FS.end   = 25*10^9;
FS.N     = 251;
                         
%% Defines Connected Ports
ConnectedPorts={};

%% Defines Options
% Overall device's symmetry (enable and side)
Options.DeviceSymmetry.Use = 0;
Options.DeviceSymmetry.Side = 2;

%% Enable Device plot
% 2 = Explodes parts; 1 = shows united parts; 0 = no plot
DevicePlotType = 1;
                         
%% Calculus                         
[ Sf, Sinfo, WGS1, Nto1, ConnectedPorts, FS, Error ] = ...
    MultiPortDevice( WGS1, Nto1, OpenPorts, ConnectedPorts, FS, DevicePlotType, Options);
                 
f = FS.f;

ModeStruct = {{1,1,'h',1,0,'h',1,0,'md'};...
              {2,1,'h',1,0,'h',1,0,'md'};...
              {2,1,'h',3,0,'h',1,0,'md'};...
              {2,1,'h',1,2,'h',1,0,'md'};...
              {2,1,'h',3,2,'h',1,0,'md'};...
              {2,1,'e',1,2,'h',1,0,'md'};...
              {2,1,'e',3,2,'h',1,0,'md'};...
              };
    
 
GSMDraw(f,Sf,Sinfo,ModeStruct,1);
%axis([min(f) max(f) -90 40 ]);
% load HFSS;
% hold on;
% plot(HFSS(:,1)*10^9,HFSS(:,2),'k:',...
%     HFSS(:,1)*10^9,HFSS(:,3),'r:',...
%     HFSS(:,1)*10^9,HFSS(:,4),'g:',...
%     HFSS(:,1)*10^9,HFSS(:,5),'m:',...
%     HFSS(:,1)*10^9,HFSS(:,6),'b:'...
%     );
% 
% WGS{1}.a=0.0158;
% WGS{1}.b=0.0079;
% WGS{1}.Nmodes = 18;
% WGS{1}.l = 0.1;
% WGS{1}.xo=0;
% WGS{1}.yo=0;
% 
% WGS{2}.a=0.0229;
% WGS{2}.b=0.0102;
% WGS{2}.Nmodes = 18;
% WGS{2}.xo=0.0;
% WGS{2}.yo=0.0;
% WGS{2}.l = 0.1;
% 
% FS.start = 8*10^9;
% FS.end   = 45*10^9;
% FS.N     = 371;
% 
% %FS.start = 25*10^9;
% %FS.end   = 25*10^9;
% %FS.N     = 1;
% 
% flags = 8+4;
% 
% [S,WGS,FS] = MultiStepDevice(WGS,FS,1);
% figure;
% 
% if (iscell(S))
%     for i=1:FS.N
%         S11_h10(i) = S{i}.S11(1,1);
%         S11_h30(i) = S{i}.S11(2,1);
%         S11_e12(i) = S{i}.S11(12+1,1);
%         S11_e32(i) = S{i}.S11(12+2,1);
%         
%         S21_h10(i) = S{i}.S21(1,1);
%         S21_h30(i) = S{i}.S21(2,1);
%         S21_e12(i) = S{i}.S21(12+1,1);
%         S21_e32(i) = S{i}.S21(12+2,1);
%         
%         check(i) = abs(S{i}.S11(1,1))^2 + abs(S{i}.S21(1,1))^2;
%     end
% 
%     plot(FS.f/10^9,abs(S11_h10),FS.f/10^9,abs(S21_h10),...
%          FS.f/10^9,abs(S11_h30),FS.f/10^9,abs(S21_h30),...
%          FS.f/10^9,abs(S11_e12),FS.f/10^9,abs(S21_e12),...
%          FS.f/10^9,abs(S11_e32),FS.f/10^9,abs(S21_e32));
% 
%     legend('S_{11}[TE_{10}]','S_{21}[TE_{10}]',...
%         'S_{11}[TE_{30}]','S_{21}[TE_{30}]',...
%         'S_{11}[TM_{12}]','S_{21}[TM_{12}]',...
%         'S_{11}[TM_{32}]','S_{21}[TM_{32}]');
% end