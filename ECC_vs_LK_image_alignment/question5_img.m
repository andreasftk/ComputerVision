%%%%%%%%% Question 5_img %%%%%%%%%%
%% Read All Videos

clear all; close all; clc; tic;

% High‐quality videos
high1 = VideoReader('video1_high.avi');
high2 = VideoReader('video2_high.avi');

% Low‐quality videos
low1 = VideoReader('video1_low.avi');
low2 = VideoReader('video2_low.avi');

%% Initialize useful parameters
nol = 2;   % number of levels
noi = 10;  % number of iterations

% Preallocate PSNR arrays for each video and each approach (ECC vs. LK).
PSNRh_1    = zeros(1, high1.NumberOfFrames - 1);
PSNRh_lk_1 = zeros(1, high1.NumberOfFrames - 1);

PSNRh_2    = zeros(1, high2.NumberOfFrames - 1);
PSNRh_lk_2 = zeros(1, high2.NumberOfFrames - 1);

PSNR1_1    = zeros(1, low1.NumberOfFrames - 1);
PSNR1_lk_1 = zeros(1, low1.NumberOfFrames - 1);

PSNR1_2    = zeros(1, low2.NumberOfFrames - 1);
PSNR1_lk_2 = zeros(1, low2.NumberOfFrames - 1);

%% Main loop over frames
% We assume all four videos have the same number of frames.

for i = 1 : high1.NumberOfFrames - 1
    
    % --- High1 video ---
    % Convert frames to double and add integer noise from -3 to +3 
    temp = double(high1.read(i));
    img  = double(high1.read(i + 1)) + randi([-3 3], 256, 256);

    [~, ~, MSE,~ ,MSELK] = ecc_lk_alignment(img, temp, nol, noi, 'affine', eye(2,3));
    PSNRh_1(i)    = mean(20 * log10(255 ./ MSE));
    PSNRh_lk_1(i) = mean(20 * log10(255 ./ MSELK));

    % --- High2 video ---
    temp = double(high2.read(i));
    img  = double(high2.read(i + 1)) + randi([-3 3], 256, 256);

    [~, ~, MSE,~ ,MSELK] = ecc_lk_alignment(img, temp, nol, noi, 'affine', eye(2,3));
    PSNRh_2(i)    = mean(20 * log10(255 ./ MSE));
    PSNRh_lk_2(i) = mean(20 * log10(255 ./ MSELK));

    % --- Low1 video ---
    % Here the frames are presumably 64×64 (or some smaller size).
    temp = double(low1.read(i));
    img  = double(low1.read(i + 1)) + randi([-3 3], 64, 64);

    [~, ~, MSE,~ ,MSELK] = ecc_lk_alignment(img, temp, nol, noi, 'affine', eye(2,3));
    PSNR1_1(i)    = mean(20 * log10(255 ./ MSE));
    PSNR1_lk_1(i) = mean(20 * log10(255 ./ MSELK));

    % --- Low2 video ---
    temp = double(low2.read(i));
    img  = double(low2.read(i + 1)) + randi([-3 3], 64, 64);

    [~, ~, MSE,~ ,MSELK] = ecc_lk_alignment(img, temp, nol, noi, 'affine', eye(2,3));
    PSNR1_2(i)    = mean(20 * log10(255 ./ MSE));
    PSNR1_lk_2(i) = mean(20 * log10(255 ./ MSELK));
end

%% Compute mean PSNR for each sequence
m_PSNRh_1    = mean(PSNRh_1);
m_PSNRh_lk_1 = mean(PSNRh_lk_1);
m_PSNRh_2    = mean(PSNRh_2);
m_PSNRh_lk_2 = mean(PSNRh_lk_2);

m_PSNR1_1    = mean(PSNR1_1);
m_PSNR1_lk_1 = mean(PSNR1_lk_1);
m_PSNR1_2    = mean(PSNR1_2);
m_PSNR1_lk_2 = mean(PSNR1_lk_2);

% Collect into a single vector (or matrix) and save
q5_img = [m_PSNRh_1 m_PSNRh_lk_1 m_PSNR1_1 m_PSNR1_lk_1;
          m_PSNRh_2 m_PSNRh_lk_2 m_PSNR1_2 m_PSNR1_lk_2];
save('question5_img.mat','q5_img');

%% Plot (semilogy) Results
xvector = 1 : (high1.NumberOfFrames - 1);

% --- PSNR for high‐quality videos ---
figure('Name','PSNR for high video');
semilogy(xvector, PSNRh_1,    '-+b'); hold on;
semilogy(xvector, PSNRh_2,    '-+r');
semilogy(xvector, PSNRh_lk_1, '-*k');
semilogy(xvector, PSNRh_lk_2, '-+g');
ylabel('PSNR (dB)'); xlabel('Time');
title('PSNR for high video');
legend('High1\_ECC','High2\_ECC','High1\_LK','High2\_LK');

% --- PSNR for low‐quality videos ---
figure('Name','PSNR for low video');
semilogy(xvector, PSNR1_1,    '-+b'); hold on;
semilogy(xvector, PSNR1_2,    '-+r');
semilogy(xvector, PSNR1_lk_1, '-*k');
semilogy(xvector, PSNR1_lk_2, '-+g');
ylabel('PSNR (dB)'); xlabel('Time');
title('PSNR for low video');
legend('Low1\_ECC','Low2\_ECC','Low1\_LK','Low2\_LK');

% --- Combined plot for all videos ---
figure('Name','PSNR for all videos');
semilogy(xvector, PSNRh_1, '-+b', ...
         xvector, PSNRh_2, '-+r', ...
         xvector, PSNR1_1, '-+k', ...
         xvector, PSNR1_2, '-+g'); hold on;
semilogy(xvector, PSNRh_lk_1, '-*b', ...
         xvector, PSNRh_lk_2, '-*r', ...
         xvector, PSNR1_lk_1, '-*k', ...
         xvector, PSNR1_lk_2, '-*g');
ylabel('PSNR (dB)'); xlabel('Time');
title('PSNR for all videos');
legend('High1\_ECC','High2\_ECC','Low1\_ECC','Low2\_ECC',...
       'High1\_LK','High2\_LK','Low1\_LK','Low2\_LK');
