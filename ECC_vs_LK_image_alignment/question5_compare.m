%% Question5_comparison %%
% Load .mat files and assign the means to 2×2 matrices.
% These matrices contain (in the 1st row) statistics about the high1, low1
% videos and (in the 2nd row) statistics about the high2, low2 videos.

clear all; close all;

load('question4.mat');          
load('question5_temp.mat');
load('question5_img.mat');  
load('question5_both.mat');      

% Each of q4, q5_template, q5_img, q5_both is presumably 1×4 or 1×8.
% Here, we place them all into one array:
vectory = [q4; q5_temp; q5_img; q5_both];
vectorx = 1:4; % This makes it match the number of selected rows (1st and 3rd)


%% Plot
figure('Name','Comparison for question 5 and 4');

% --- Subplot for High1 & Low1 ---
subplot(1,2,1);
semilogy(vectorx, vectory(1:2:end,1), '-+', ...
         vectorx, vectory(1:2:end,2), '-+', ...
         vectorx, vectory(1:2:end,3), '-+', ...
         vectorx, vectory(1:2:end,4), '-+');
title('Comparison for question 5 and 4 - High1 and Low1');
xlabel(''); ylabel('PSNR (dB)');
legend('PSNR High1\_1','PSNR High1\_LK\_1','PSNR Low1\_1','PSNR Low1\_LK\_1');

% --- Subplot for High2 & Low2 ---
subplot(1,2,2);
semilogy(vectorx, vectory(2:2:end,1), '-+', ...
         vectorx, vectory(2:2:end,2), '-+', ...
         vectorx, vectory(2:2:end,3), '-+', ...
         vectorx, vectory(2:2:end,4), '-+');
title('Comparison for question 5 and 4 - High2 and Low2');
xlabel(''); ylabel('PSNR (dB)');
legend('PSNR High2\_2','PSNR High2\_LK\_2','PSNR Low2\_2','PSNR Low2\_LK\_2');
