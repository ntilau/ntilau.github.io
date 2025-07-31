clear
l=0.01;
%% Defines the TwoPortDevices
WGS1{1}.a=0.01905;
WGS1{1}.b=0.009525;
WGS1{1}.Nmodes = 12;
WGS1{1}.l = l;
WGS1{1}.xo=-0.01905/2-0.001;
WGS1{1}.yo=0;
WGS1{1}.zo=-l;

WGS1{2}.a=0.01905;
WGS1{2}.b=0.009525;
WGS1{2}.Nmodes = 12;
WGS1{2}.l = l;
WGS1{2}.xo=0.01905/2+0.001;
WGS1{2}.yo=0;
WGS1{2}.zo=-l;

WGS1{3}.a=0.019052*2;
WGS1{3}.b=0.009525;
WGS1{3}.Nmodes = 12;
WGS1{3}.l = l;
WGS1{3}.xo=0;
WGS1{3}.yo=0;
WGS1{3}.zo=0;

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

% Symmetry
Symmetry.x=0;
Symmetry.y=1;
Symmetry.H=0;
Symmetry.E=1;

%% Defines the Frequency Sweep
FS.start = 10*10^9;
FS.end   = 25*10^9;
FS.N     = 51;

[FS,Error] = FrequencyCheck(FS);
if (DumpError('|  +--+>',Error))
    return;
end
                       
%% Calculus                         
[ Sf, Sinfo, WGS1, Nto1, FS, Error ] = ...
    MultiPortDevice( WGS1, Nto1, OpenPorts, FS , 2 );
                 
f = FS.f;

% GSMDraw(f,Sf,Sinfo,...
%     {{1,3,'h',1,0,'h',1,0,'md'};...
%      {2,3,'h',1,0,'h',1,0,'md'};...
%      {3,3,'h',1,0,'h',1,0,'md'};...
%      {3,3,'h',1,1,'h',1,0,'md'};...
%      {3,3,'h',1,3,'h',1,0,'md'};...
%      {3,3,'e',1,1,'h',1,0,'md'};...
%      {3,3,'e',1,3,'h',1,0,'md'};...
%      });
% ModeStruct = {{1,1,'h',1,0,'h',1,0,'md'};...
%               {2,1,'h',1,0,'h',1,0,'md'};...
%               {3,1,'h',1,0,'h',1,0,'md'};...
%               {3,1,'h',2,0,'h',1,0,'md'};...
%               {3,1,'h',3,0,'h',1,0,'md'};...
%               {3,1,'h',4,0,'h',1,0,'md'};...
%               {3,1,'h',5,0,'h',1,0,'md'};...
%               };
%     
%  
% GSMDraw(f,Sf,Sinfo,ModeStruct,1);

figure
f=FS.f;
for nf=1:length(f)    
    S11_h10(nf) = ExtractSingleS(Sf{nf},Sinfo,1,1,'h',1,0,'h',1,0);
    S21_h10(nf) = ExtractSingleS(Sf{nf},Sinfo,2,1,'h',1,0,'h',1,0);
    S31_h10(nf) = ExtractSingleS(Sf{nf},Sinfo,3,1,'h',1,0,'h',1,0);
%    S31_h11(nf) = ExtractSingleS(Sf{nf},Sinfo,3,1,'h',1,1,'h',1,0);
%    S31_h13(nf) = ExtractSingleS(Sf{nf},Sinfo,3,1,'h',1,3,'h',1,0);
%    S31_e11(nf) = ExtractSingleS(Sf{nf},Sinfo,3,1,'e',1,1,'h',1,0);
%    S31_e13(nf) = ExtractSingleS(Sf{nf},Sinfo,3,1,'e',1,3,'h',1,0);
end

plot(f,20*log10(abs(S11_h10)),'k',...
    f,20*log10(abs(S21_h10)),'r',...
    f,20*log10(abs(S31_h10)),'g');%...
%     f,20*log10(abs(S31_h11)),'b',...
%     f,20*log10(abs(S31_h13)),'b--',...
%     f,20*log10(abs(S31_e11)),'m',...
%     f,20*log10(abs(S31_e13)),'m--'...
%     );
legend('S11_{h10}','S21_{h10}','S31_{h10}');
%     'S31_{h11}','S31_{h13}','S31_{e11}',...
%     'S31_{e13}'...
%     );
axis([min(f) max(f) -60 0]);
 
load HFSSh;
hold on;
plot(HFSSh(:,1)*10^9,HFSSh(:,2),'k:',...
    HFSSh(:,1)*10^9,HFSSh(:,3),'r:',...
    HFSSh(:,1)*10^9,HFSSh(:,4),'g:',...
    HFSSh(:,1)*10^9,HFSSh(:,5),'b:',...
    HFSSh(:,1)*10^9,HFSSh(:,6),'y:',...
    HFSSh(:,1)*10^9,HFSSh(:,7),'m:',...
    HFSSh(:,1)*10^9,HFSSh(:,8),'c:'...
    );