clear

WGS1{1}.a=0.01905;
WGS1{1}.b=0.009525/2;
WGS1{1}.Nmodes = 12;
WGS1{1}.l = 0.01;
WGS1{1}.xo=0;
WGS1{1}.yo=-0.009525/4;

WGS1{2}.a=0.01905;
WGS1{2}.b=0.009525/2;
WGS1{2}.Nmodes = 12;
WGS1{2}.l = 0.01;
WGS1{2}.xo=0;
WGS1{2}.yo=0.009525/4;

WGS1{3}.a=0.01905;
WGS1{3}.b=0.009525/1.0001;
WGS1{3}.Nmodes = 12;
WGS1{3}.l = 0.01;
WGS1{3}.xo=0;
WGS1{3}.yo=0;

Symmetry.x=1;
Symmetry.y=0;
Symmetry.H=1;
Symmetry.E=0;

FS.start = 10*10^9;
FS.end   = 25*10^9;
FS.N     = 251;

Nto1{1}.SideOne{1}.TwoPortDeviceIndex = 1;
Nto1{1}.SideOne{1}.TwoPortDevicePort = 2;
Nto1{1}.SideOne{2}.TwoPortDeviceIndex = 2;
Nto1{1}.SideOne{2}.TwoPortDevicePort = 2;
Nto1{1}.SideTwo.TwoPortDeviceIndex = 3;
Nto1{1}.SideTwo.TwoPortDevicePort = 1;

[FS,Error] = FrequencyCheck(FS);
if (DumpError(Error))
    Sf = 0;
    return;
end    
OpenPorts=[];
[ Sf, Sinfo, Error ] = ...
    MultiPortDevice( WGS1, Nto1, OpenPorts, FS, Symmetry );

figure
f=FS.f;
for nf=1:length(f)
    S11_h10(nf) = ExtractSingleS(Sf{nf},Sinfo,1,1,1,0);
%     S11_h11(nf) = ExtractSingleS(Sf{nf},Sinfo,1,1,1,1);
%     S11_h12(nf) = ExtractSingleS(Sf{nf},Sinfo,1,1,1,2);

    S21_h10(nf) = ExtractSingleS(Sf{nf},Sinfo,2,1,1,0);
%     S21_h11(nf) = ExtractSingleS(Sf{nf},Sinfo,2,1,1,1);
%     S21_h12(nf) = ExtractSingleS(Sf{nf},Sinfo,2,1,1,2);

    S31_h11(nf) = ExtractSingleS(Sf{nf},Sinfo,3,1,1,1);
    S31_h13(nf) = ExtractSingleS(Sf{nf},Sinfo,3,1,1,3);
    S31_e11(nf) = ExtractSingleS(Sf{nf},Sinfo,3,1,1,7);
    S31_e13(nf) = ExtractSingleS(Sf{nf},Sinfo,3,1,1,9);
    
%     S11_h10 = ExtractSingleS(Sf{nf},Sinfo,1,1,'h',1,0,'h',1,0);
%     S11_h11 = ExtractSingleS(Sf{nf},Sinfo,1,1,'h',1,1,'h',1,0);
%     S11_h12 = ExtractSingleS(Sf{nf},Sinfo,1,1,'h',1,2,'h',1,0);
% 
%     S21_h10 = ExtractSingleS(Sf{nf},Sinfo,2,1,'h',1,0,'h',1,0);
%     S21_h11 = ExtractSingleS(Sf{nf},Sinfo,2,1,'h',1,1,'h',1,0);
%     S21_h12 = ExtractSingleS(Sf{nf},Sinfo,2,1,'h',1,2,'h',1,0);
% 
%     S31_h10 = ExtractSingleS(Sf{nf},Sinfo,3,1,'h',1,0,'h',1,0);
%     S31_h11 = ExtractSingleS(Sf{nf},Sinfo,3,1,'h',1,1,'h',1,0);
%     S31_h12 = ExtractSingleS(Sf{nf},Sinfo,3,1,'h',1,2,'h',1,0);

end

plot(f,20*log10(abs(S11_h10)),'r', f,20*log10(abs(S21_h10)),'g',f,20*log10(abs(S31_h11)),'b',...
     f,20*log10(abs(S31_h13)),'b--',f,20*log10(abs(S31_e11)),'b:', f,20*log10(abs(S31_e13)),'b+');

% legend('S11_h10','S11_h11','S11_h12',...
%     'S21_h10','S21_h11','S21_h12',...
%     'S31_h10','S31_h11','S31_h12');
grid on;
%axis([min(f) max(f) 40 0]);