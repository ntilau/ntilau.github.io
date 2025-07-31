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

WGS2.a=0.01905;
WGS2.b=0.009525;
WGS2.Nmodes = 12;
WGS2.l = 0.01;
WGS2.xo=0;
WGS2.yo=0;

Symmetry.x=1;
Symmetry.y=0;
Symmetry.H=1;
Symmetry.E=0;

[ WGS1{1}, Error ] = OrderModes( WGS1{1}, Symmetry );
[ WGS1{2}, Error ] = OrderModes( WGS1{2}, Symmetry );
[ WGS2, Error ]    = OrderModes( WGS2, Symmetry );

[ WGS1{1} ] = EigenModes( WGS1{1} );
[ WGS1{2} ] = EigenModes( WGS1{2} );
[ WGS2 ]    = EigenModes( WGS2 );

[ WGS1{1} ] = NormCoeff( WGS1{1} );
[ WGS1{2} ] = NormCoeff( WGS1{2} );
[ WGS2 ]    = NormCoeff( WGS2 );

f=(10:0.05:25)*10^9;

for i=1:length(f)
  lambda = 299792458/f(i);
  k0 = 2*pi/lambda;

  [ WGS1{1} ] = WaveNumbers( WGS1{1}, k0 );
  [ WGS1{2} ] = WaveNumbers( WGS1{2}, k0 );
  [ WGS2 ]    = WaveNumbers( WGS2, k0 );

  [ WGS1{1} ] = DelayMatrix( WGS1{1}, k0 );
  [ WGS1{2} ] = DelayMatrix( WGS1{2}, k0 );
  [ WGS2 ]    = DelayMatrix( WGS2, k0 );

  [Stot, S]= Nto1Step(WGS1,WGS2,k0);
  
  S11_h10(i) = S.S11(1,1);
  S11_h11(i) = S.S11(2,1);
  S11_h12(i) = S.S11(3,1);
  S21_h10(i) = S.S11(14,1);
  S21_h11(i) = S.S11(15,1);
  S21_h12(i) = S.S11(16,1);
  S31_h10(i) = S.S21(1,1);
  S31_h11(i) = S.S21(2,1);
  S31_h12(i) = S.S21(3,1);
  
  S31_e11(i) = S.S21(8,1); %port 3to1 TM11 for normalization control

%   S11_3(i) = S.S11(3,1);
%   S12_3(i) = S.S11(3,14);
%   S13_3(i) = S.S12(3,1);
%   S21_3(i) = S.S11(16,1);
%   S22_3(i) = S.S11(16,14);
%   S23_3(i) = S.S12(16,1);
%   S31_3(i) = S.S21(3,1);
%   S32_3(i) = S.S21(3,14);
%   S31_2h(i) = S.S21(2,1);
  % if(S.S21(8,1) > 1)
	% S31_1e(i) = 1/S.S21(8,1);
  % else 
	%S31_1e(i) = 1/S.S21(8,1);
  % end

end


figure
plot(f,20*log10(abs(S11_h10)),'r',f,20*log10(abs(S11_h11)),'r--',f,20*log10(abs(S11_h12)),'r:',...
f,20*log10(abs(S21_h10)),'g',f,20*log10(abs(S21_h11)),'g--',f,20*log10(abs(S21_h12)),'g:',...
f,20*log10(abs(S31_h10)),'b',f,20*log10(abs(S31_h11)),'b--',f,20*log10(abs(S31_h12)),'b:',...
f,20*log10(abs(S31_e11)),'k');
legend('S11_{h10}','S11_{h11}','S11_{h12}','S21_{h10}','S21_{h11}','S21_{h12}','S31_{h10}',...
    'S31_{h11}','S31_{h12}','S31_{e11}');

% figure
% plot(f,20*log10(abs(S11_1)),'r*',f,20*log10(abs(S21_1)),'g',f,20*log10(abs(S31_1)),'b',...
% f,20*log10(abs(S31_2h)),'g--',f,20*log10(abs(S31_1e)),'b*');
% legend('S21_h10','S21_h11','S31_h10','S31_h11','S31_e11');%,'S31(8)');

% figure
% plot(f,abs(S11_1),'r*',f,abs(S21_1),'g',f,abs(S31_1),'b',f,abs(S31_2h),'m',f,abs(S31_1e),'k');
% legend('S11(1)','S12(1)','S13(1)');

% figure
% plot(f,20*log10(abs(S11_1)),'r',f,20*log10(abs(S12_1)),'g',f,20*log10(abs(S13_1)),'b',...
  % f,20*log10(abs(S11_3)),'r--',f,20*log10(abs(S12_3)),'g--',f,20*log10(abs(S13_3)),'b--');
% legend('S11(1)','S12(1)','S13(1)','S11(3)','S12(3)','S13(3)');

% figure
% plot(f,20*log10(abs(S21_1)),'r',f,20*log10(abs(S22_1)),'g',f,20*log10(abs(S23_1)),'b',...
  % f,20*log10(abs(S21_3)),'r--',f,20*log10(abs(S22_3)),'g--',f,20*log10(abs(S23_3)),'b--');
% legend('S21(1)','S22(1)','S23(1)','S21(3)','S22(3)','S23(3)');

% figure
% plot(f,20*log10(abs(S31_1)),'r',f,20*log10(abs(S32_1)),'g',f,20*log10(abs(S33_1)),'b',...
  % f,20*log10(abs(S31_3)),'r--',f,20*log10(abs(S32_3)),'g--',f,20*log10(abs(S33_3)),'b--');
% legend('S31(1)','S32(1)','S33(1)','S31(3)','S32(3)','S33(3)');

axis([min(f) max(f) -40 0]);
