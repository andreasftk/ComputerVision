%% Question6_compare %%
clear all; close all;

load('question6_gauss.mat');
load('question6_uniform.mat');

L = 2;
a = [6 12 18];
var_ = [4 8 12];

%% Semilogy Results

% High video
figure('Name', 'PSNR for high video');
semilogy(var_, q6_gauss(1:3,1), '-+', a, q6_uniform(1:3,1), '-+', ...
         var_, q6_gauss(4:6,1), '-+', a, q6_uniform(4:6,1), '-+', ...
         var_, q6_gauss(1:3,2), '-+', a, q6_uniform(1:3,2), '-+', ...
         var_, q6_gauss(4:6,2), '-+', a, q6_uniform(4:6,2), '-+');

ylabel('PSNR (dB)');
xlabel('Variance');
title('PSNR for high video');

legend('High1\_ECC\_gauss', 'High1\_ECC\_uniform', ...
       'High2\_ECC\_gauss', 'High2\_ECC\_uniform', ...
       'High1\_LK\_gauss', 'High1\_LK\_uniform', ...
       'High2\_LK\_gauss', 'High2\_LK\_uniform');

% Low video
figure('Name', 'PSNR for low video');
semilogy(var_, q6_gauss(1:3,3), '-+', a, q6_uniform(1:3,3), '-+', ...
         var_, q6_gauss(4:6,3), '-+', a, q6_uniform(4:6,3), '-+', ...
         var_, q6_gauss(1:3,4), '-+', a, q6_uniform(1:3,4), '-+', ...
         var_, q6_gauss(4:6,4), '-+', a, q6_uniform(4:6,4), '-+');

ylabel('PSNR (dB)');
xlabel('Variance');
title('PSNR for low video');

legend('Low1\_ECC\_gauss', 'Low1\_ECC\_uniform', ...
       'Low2\_ECC\_gauss', 'Low2\_ECC\_uniform', ...
       'Low1\_LK\_gauss', 'Low1\_LK\_uniform', ...
       'Low2\_LK\_gauss', 'Low2\_LK\_uniform');
