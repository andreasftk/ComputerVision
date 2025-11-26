%%%%%% Question 3 %%%%%%

%% Read All Videos
% High quality video
close all; clear all;

high1 = VideoReader('video1_high.avi');
high2 = VideoReader('video2_high.avi');

% Low quality video
low1 = VideoReader('video1_low.avi');
low2 = VideoReader('video2_low.avi');

%% Initialize useful matrices and vectors
LEVELS = [2:3]; % Number of levels
NOI = [10:5:50]; % Number of iterations

% Execution time vectors
t_high1 = zeros(length(LEVELS), length(NOI));
t_high2 = zeros(length(LEVELS), length(NOI));
t_low1 = zeros(length(LEVELS), length(NOI));
t_low2 = zeros(length(LEVELS), length(NOI));

% PSNR for high1, high2, low1, low2
PSNRh_1 = zeros(length(LEVELS), length(NOI));
PSNRh_lk_1 = zeros(length(LEVELS), length(NOI));

PSNRh_2 = zeros(length(LEVELS), length(NOI));
PSNRh_lk_2 = zeros(length(LEVELS), length(NOI));

PSNR1_1 = zeros(length(LEVELS), length(NOI));
PSNR1_lk_1 = zeros(length(LEVELS), length(NOI));

PSNR1_2 = zeros(length(LEVELS), length(NOI));
PSNR1_lk_2 = zeros(length(LEVELS), length(NOI));

% Frame selection
frame = 70;

%% Initialize templates
temp_h_1 = high1.read(1);
temp_h_2 = high2.read(1);
temp_l_1 = low1.read(1);
temp_l_2 = low2.read(1);

%% Initialize images
img_h_1 = high1.read(frame);
img_h_2 = high2.read(frame);
img_l_1 = low1.read(frame);
img_l_2 = low2.read(frame);

%% Run the main loop
for i = 1:length(LEVELS)
    for j = 1:length(NOI)
        % High1 video
        tic;
        [results, results_lk, MSE, rho, MSELK] = ecc_lk_alignment(img_h_1, temp_h_1, i, j, 'affine', eye(2,3));
        t_high1(i, j) = toc;
        PSNRh_1(i, j) = mean(20 * log10(255 ./ MSE));
        PSNRh_lk_1(i, j) = mean(20 * log10(255 ./ MSELK));
        
        % High2 video
        tic;
        [results, results_lk, MSE, rho, MSELK] = ecc_lk_alignment(img_h_2, temp_h_2, i, j, 'affine', eye(2,3));
        t_high2(i, j) = toc;
        PSNRh_2(i, j) = mean(20 * log10(255 ./ MSE));
        PSNRh_lk_2(i, j) = mean(20 * log10(255 ./ MSELK));
        
        % Low1 video
        tic;
        [results, results_lk, MSE, rho, MSELK] = ecc_lk_alignment(img_l_1, temp_l_1, i, j, 'affine', eye(2,3));
        t_low1(i, j) = toc;
        PSNR1_1(i, j) = mean(20 * log10(255 ./ MSE));
        PSNR1_lk_1(i, j) = mean(20 * log10(255 ./ MSELK));
        
        % Low2 video
        tic;
        [results, results_lk, MSE, rho, MSELK] = ecc_lk_alignment(img_l_2, temp_l_2, i, j, 'affine', eye(2,3));
        t_low2(i, j) = toc;
        PSNR1_2(i, j) = mean(20 * log10(255 ./ MSE));
        PSNR1_lk_2(i, j) = mean(20 * log10(255 ./ MSELK));
    end
end

%% Plot Results
xvector = [1:length(NOI)];

% PSNR for high video
figure('Name','PSNR for high video');
semilogy(xvector, PSNRh_1(1,:), xvector, PSNRh_2(1,:), xvector, PSNRh_lk_1(1,:), xvector, PSNRh_lk_2(1,:),...
         xvector, PSNRh_1(2,:), xvector, PSNRh_2(2,:), xvector, PSNRh_lk_1(2,:), xvector, PSNRh_lk_2(2,:));
ylabel('PSNR (dB)');
xlabel('Number of Iterations');
title('PSNR for high video');
legend(sprintf('High 1 ECC LEVELS:%d',1), ...
       sprintf('High 2 ECC LEVELS:%d',1), ...
       sprintf('High 1 LK LEVELS:%d',1), ...
       sprintf('High 2 LK LEVELS:%d',1), ...
       sprintf('High 1 ECC LEVELS:%d',2), ...
       sprintf('High 2 ECC LEVELS:%d',2), ...
       sprintf('High 1 LK LEVELS:%d',2), ...
       sprintf('High 2 LK LEVELS:%d',2) ...
       );

% PSNR for low video
figure('Name','PSNR for low video');
semilogy(xvector, PSNR1_1(1,:), xvector, PSNR1_2(1,:), xvector, PSNR1_lk_1(1,:), xvector, PSNR1_lk_2(1,:),...
         xvector, PSNR1_1(2,:), xvector, PSNR1_2(2,:), xvector, PSNR1_lk_1(2,:), xvector, PSNR1_lk_2(2,:));
ylabel('PSNR (dB)');
xlabel('Number of Iterations');
title('PSNR for low video');
legend(sprintf('Low 1 ECC LEVELS:%d',1), ...
       sprintf('Low 2 ECC LEVELS:%d',1), ...
       sprintf('Low 1 LK LEVELS:%d',1), ...
       sprintf('Low 2 LK LEVELS:%d',1), ...
       sprintf('Low 1 ECC LEVELS:%d',2), ...
       sprintf('Low 2 ECC LEVELS:%d',2), ...
       sprintf('Low 1 LK LEVELS:%d',2), ...
       sprintf('Low 2 LK LEVELS:%d',2) ...
       );

% Execution time
figure('Name','Execution time for videos');
plot(xvector, t_high1(1,:), xvector, t_high2(1,:), xvector, t_low1(1,:), xvector, t_low2(1,:),...
     xvector, t_high1(2,:), xvector, t_high2(2,:), xvector, t_low1(2,:), xvector, t_low2(2,:));
ylabel('Time (sec.)');
xlabel('Number of Iterations');
title('Time execution');
legend(sprintf('High 1 LEVELS:%d',1), ...
    sprintf('High 2 LEVELS:%d',1), ...
    sprintf('Low 1 LEVELS:%d',2), ...
    sprintf('Low 2 LEVELS:%d',2));
