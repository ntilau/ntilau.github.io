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
WGS{1}.a=0.0158;
WGS{1}.b=0.0079;
WGS{1}.Nmodes = 18;
WGS{1}.l = 0.1;
WGS{1}.xo=0;
WGS{1}.yo=0;

WGS{2}.a=0.0229;
WGS{2}.b=0.0102;
WGS{2}.Nmodes = 18;
WGS{2}.xo=0.0;
WGS{2}.yo=0.0;
WGS{2}.l = 0.1;

FS.start = 8*10^9;
FS.end   = 45*10^9;
FS.N     = 371;

%FS.start = 25*10^9;
%FS.end   = 25*10^9;
%FS.N     = 1;

flags = 8+4;

[S,WGS,FS] = MultiStepDevice(WGS,FS,1);
figure;

if (iscell(S))
    for i=1:FS.N
        S11_h10(i) = S{i}.S11(1,1);
        S11_h30(i) = S{i}.S11(2,1);
        S11_e12(i) = S{i}.S11(12+1,1);
        S11_e32(i) = S{i}.S11(12+2,1);
        
        S21_h10(i) = S{i}.S21(1,1);
        S21_h30(i) = S{i}.S21(2,1);
        S21_e12(i) = S{i}.S21(12+1,1);
        S21_e32(i) = S{i}.S21(12+2,1);
        
        check(i) = abs(S{i}.S11(1,1))^2 + abs(S{i}.S21(1,1))^2;
    end

    plot(FS.f/10^9,abs(S11_h10),FS.f/10^9,abs(S21_h10),...
         FS.f/10^9,abs(S11_h30),FS.f/10^9,abs(S21_h30),...
         FS.f/10^9,abs(S11_e12),FS.f/10^9,abs(S21_e12),...
         FS.f/10^9,abs(S11_e32),FS.f/10^9,abs(S21_e32));

    legend('S_{11}[TE_{10}]','S_{21}[TE_{10}]',...
        'S_{11}[TE_{30}]','S_{21}[TE_{30}]',...
        'S_{11}[TM_{12}]','S_{21}[TM_{12}]',...
        'S_{11}[TM_{32}]','S_{21}[TM_{32}]');
end