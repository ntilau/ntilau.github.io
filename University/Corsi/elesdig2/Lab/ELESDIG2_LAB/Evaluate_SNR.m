clear all;

sorgente = 'ext';
fck = 10e3;     % [Hz]

%----------------------------------------------------------
%       Sintesi segnale di prova
%----------------------------------------------------------
fs  = 1;   % [Hz]
snr = 20;   % [dB]
N   = 4096; % Numero campioni

T = N/fck;
n=1:N;
t=n/N*T;

ySignal = 1*sin(2*pi*fs*t+pi/4);
%y  = awgn(ySignal,snr,'measured');
y = ySignal;

%----------------------------------------------------------
%       Lettura dati sperimentali
%----------------------------------------------------------
if sorgente == 'ext'
    load BitStream.dat;
    y = BitStream';
    N   = length(y);
    T   = N/fck;
    n   = 1:N;
    t   = n/N*T;
end

f = (1:N/2)/(N/2)*fck/2;

%----------------------------------------------------------
%       Calcolo spettro
%----------------------------------------------------------
%w = ones (1,N);
w = hamming(N)';
%w = blackman(N)';
%w = nuttal(N)';
Y = abs(fft(y/N.*w));

Yreal = 2*Y(1:end/2);


%---------------------------------------------------
%   Valutazione segnale in frequenza
%---------------------------------------------------
WW = 5;
[YrealMax,YrealMaxIndex] = max(Yreal);
YrealSoloNoise = Yreal;
YrealSoloNoise(1:3)=1e-6;
YrealSoloNoise(YrealMaxIndex-WW :YrealMaxIndex+WW )=1e-6;
YRmsSoloNoise = sqrt(sum(YrealSoloNoise.*YrealSoloNoise));



%Fs = 32e3;
%t = 0:1/Fs:2.96;
%x = cos(2*pi*t*1.24e3)+ cos(2*pi*t*10e3)+ randn(size(t));
%Pxx = periodogram(x);
%Hpsd = dspdata.psd(Pxx,'Fs',Fs); % Create a PSD data object.
%plot(Hpsd);                        % Plot the PSD data object.


%----------------------------------------------------------
%       Mostra risultati
%----------------------------------------------------------
figure(1), plot(t,y), title('Signal'), xlabel('time [s]'), ylabel('amplitude [A.U.]');
figure(2), plot(f, 20*log10(abs(Yreal))), title('Signal'), xlabel('frequency [Hz]'), ylabel('amplitude (dB) [A.U.]');
figure(3), plot(f, 20*log10(abs(YrealSoloNoise))), title('Signal'), xlabel('frequency [Hz]'), ylabel('amplitude (dB) [A.U.]');

sprintf('YMax            = %f [dB]',20*log10(abs(YrealMax)))
sprintf('YRms(SoloNoise) = %f [dB]',20*log10(abs(YRmsSoloNoise)))
sprintf('SNR = %f [dB]',20*log10(abs(YrealMax))-20*log10(abs(YRmsSoloNoise)))
