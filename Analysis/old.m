
% N = n;
% Fs = 1;
% % x = complex(file_cos,-file_minus_sin) .* blackmsn(n);
% x = complex(file_cos,-file_minus_sin);
% xdft = fft(x);
% xdft = xdft(1:N/2+1);
% psdx = (1/(Fs*N)) * abs(xdft).^2;
% psdx(2:end-1) = 2*psdx(2:end-1);
% freq = 0:Fs/length(x):Fs/2;
%
% figure;
% plot(real(x));
% hold on;
% plot(imag(x));
% hold off;
%
%
% figure;
% plot(freq,10*log10(psdx))
% grid on
% title('Periodogram Using FFT')
% xlabel('Frequency (Hz)')
% ylabel('Power/Frequency (dB/Hz)')
