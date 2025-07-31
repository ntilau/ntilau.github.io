clear

% profile on
l = 0.01;

WGS1{1}.D{1}.a=0.01905;
WGS1{1}.D{1}.b=0.009525/2;
WGS1{1}.D{1}.Nmodes = 12;
WGS1{1}.D{1}.l = l;
WGS1{1}.D{1}.xo=0;
WGS1{1}.D{1}.yo=-0.009525/4;
WGS1{1}.D{1}.zo=-l;

WGS1{2}.D{1}.a=0.01905;
WGS1{2}.D{1}.b=0.009525/2;
WGS1{2}.D{1}.Nmodes = 12;
WGS1{2}.D{1}.l = l;
WGS1{2}.D{1}.xo=0;
WGS1{2}.D{1}.yo=0.009525/4;
WGS1{2}.D{1}.zo=-l;

WGS1{3}.D{1}.a=0.01905;
WGS1{3}.D{1}.b=0.009525;
WGS1{3}.D{1}.Nmodes = 12;
WGS1{3}.D{1}.l = l;
WGS1{3}.D{1}.xo=0;
WGS1{3}.D{1}.yo=0;
WGS1{3}.D{1}.zo=0;

% Symmetry
Symmetry.x=1;
Symmetry.y=0;
Symmetry.H=1;
Symmetry.E=0;

FS.start = 10*10^9;
FS.end   = 25*10^9;
FS.N     = 51;

Nto1{1}.SideOne{1}.TwoPortDeviceIndex = 1;
Nto1{1}.SideOne{1}.TwoPortDevicePort = 2;
Nto1{1}.SideOne{2}.TwoPortDeviceIndex = 2;
Nto1{1}.SideOne{2}.TwoPortDevicePort = 2;
Nto1{1}.SideTwo.TwoPortDeviceIndex = 3;
Nto1{1}.SideTwo.TwoPortDevicePort = 1;

[FS,Error] = FrequencyCheck(FS);
if (DumpError('|  +--+>',Error))
    return;
end

OpenPorts = [];
Topology = [];
% 
% [ Sf, Sinfo, WGS1, Nto1, FS, Error ] = ...
%     MultiPortDevice( WGS1, Nto1, OpenPorts, FS , 2 );
[Sf, Sinfo, Error] = MultiPortDeviceSolve( WGS1, Nto1, OpenPorts,...
    FS, Symmetry, Topology );

figure
f=FS.f;
for nf=1:length(f)    
    S11_h10(nf) = ExtractSingleS(Sf{nf},Sinfo,1,1,'h',1,0,'h',1,0);
    S21_h10(nf) = ExtractSingleS(Sf{nf},Sinfo,2,1,'h',1,0,'h',1,0);
    S31_h10(nf) = ExtractSingleS(Sf{nf},Sinfo,3,1,'h',1,0,'h',1,0);
    S31_h11(nf) = ExtractSingleS(Sf{nf},Sinfo,3,1,'h',1,1,'h',1,0);
    S31_h13(nf) = ExtractSingleS(Sf{nf},Sinfo,3,1,'h',1,3,'h',1,0);
    S31_e11(nf) = ExtractSingleS(Sf{nf},Sinfo,3,1,'e',1,1,'h',1,0);
    S31_e13(nf) = ExtractSingleS(Sf{nf},Sinfo,3,1,'e',1,3,'h',1,0);
end

plot(f,20*log10(abs(S11_h10)),'k',...
    f,20*log10(abs(S21_h10)),'r',...
    f,20*log10(abs(S31_h10)),'g',...
    f,20*log10(abs(S31_h11)),'b',...
    f,20*log10(abs(S31_h13)),'b--',...
    f,20*log10(abs(S31_e11)),'m',...
    f,20*log10(abs(S31_e13)),'m--'...
    );
legend('S11_{h10}','S21_{h10}','S31_{h10}',...
    'S31_{h11}','S31_{h13}','S31_{e11}',...
    'S31_{e13}'...
    );
axis([min(f) max(f) -60 0]);

load HFSS;
hold on;
plot(HFSS(:,1)*10^9,HFSS(:,2),'k:',...
    HFSS(:,1)*10^9,HFSS(:,3),'r:',...
    HFSS(:,1)*10^9,HFSS(:,4),'g:',...
    HFSS(:,1)*10^9,HFSS(:,5),'m:',...
    HFSS(:,1)*10^9,HFSS(:,6),'b:'...
    );

% profile viewer
