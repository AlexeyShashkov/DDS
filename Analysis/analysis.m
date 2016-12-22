close all;
clear all; %#ok<*CLALL>

load file_minus_sin.txt;
[n,p] = size(file_minus_sin);
t = 1:n;
% figure;
% plot(t, file_minus_sin);
% title('file minus sin');

load file_cos.txt
% figure;
% plot(t,file_cos);
% title('file cos');

figure;
sfdr(file_cos,1000);

figure;
sfdr(file_minus_sin,1000);
