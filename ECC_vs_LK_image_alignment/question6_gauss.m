%% Question6_gauss %%
%% Read All Videos

clear all; close all; clc;

% High-quality videos
high1 = VideoReader('video1_high.avi');
high2 = VideoReader('video2_high.avi');

% Low-quality videos
low1 = VideoReader('video1_low.avi');
low2 = VideoReader('video2_low.avi');

%% Initialize useful matrices and vectors
nol = 2;   % number of levels
noi = 10;  % number of iterations

% Gaussian variance vector
var_ = [4 8 12];

N = 100; % number of iterations

% PSNR matrices for high1, high2, low1, low2
PSNRh_1    = zeros(length(var_), high1.NumberOfFrames - 1);
PSNRh_lk_1 = zeros(length(var_), high1.NumberOfFrames - 1);

PSNRh_2    = zeros(length(var_), high2.NumberOfFrames - 1);
PSNRh_lk_2 = zeros(length(var_), high2.NumberOfFrames - 1);

PSNR1_1    = zeros(length(var_), low1.NumberOfFrames - 1);
PSNR1_lk_1 = zeros(length(var_), low1.NumberOfFrames - 1);

PSNR1_2    = zeros(length(var_), low2.NumberOfFrames - 1);
PSNR1_lk_2 = zeros(length(var_), low2.NumberOfFrames - 1);

L = 2;

%% Run the main Loop
% It is known that the input videos have the same number of frames,
% so we have one loop for all the videos.
% Before alignment, apply Gaussian(0, var_(j)) distortion to images.

for j = 1:length(var_)
    for i = 1:high1.NumberOfFrames - 1

        %% High1 video
        mesos = zeros(N, noi);
        mesos_lk = zeros(N, noi);
        disp(['High1: j = ' num2str(j)]);

        for k = 1:N
            temp = high1.read(i);

            % Apply Gaussian distortion to img
            img = high1.read(i + 1);
            img = uint8(double(img) + sqrt(var_(j)) .* randn(size(img)));

            [results, results_lk, MSE, rho, MSELK] = ecc_lk_alignment( ...
                img, temp, nol, noi, 'affine', eye(2,3));

            mesos(k, :) = MSE;
            mesos_lk(k, :) = MSELK;
        end

        PSNRh_1(j, i) = mean(20 * log10(255 ./ mean(mesos, 2)));
        PSNRh_lk_1(j, i) = mean(20 * log10(255 ./ mean(mesos_lk, 2)));

        %% High2 video
        mesos = zeros(N, noi);
        mesos_lk = zeros(N, noi);
        disp(['High2: j = ' num2str(j)]);

        for k = 1:N
            temp = high2.read(i);

            % Apply Gaussian distortion to img
            img = high2.read(i + 1);
            img = uint8(double(img) + sqrt(var_(j)) .* randn(size(img)));

            [results, results_lk, MSE, rho, MSELK] = ecc_lk_alignment( ...
                img, temp, nol, noi, 'affine', eye(2,3));

            mesos(k, :) = MSE;
            mesos_lk(k, :) = MSELK;
        end

        PSNRh_2(j, i) = mean(20 * log10(255 ./ mean(mesos, 2)));
        PSNRh_lk_2(j, i) = mean(20 * log10(255 ./ mean(mesos_lk, 2)));

        %% Low1 video
        mesos = zeros(N, noi);
        mesos_lk = zeros(N, noi);
        disp(['Low1: j = ' num2str(j)]);

        for k = 1:N
            temp = low1.read(i);

            % Apply Gaussian distortion to img
            img = low1.read(i + 1);
            img = uint8(double(img) + sqrt(var_(j)) .* randn(size(img)));

            [results, results_lk, MSE, rho, MSELK] = ecc_lk_alignment( ...
                img, temp, nol, noi, 'affine', eye(2,3));

            mesos(k, :) = MSE;
            mesos_lk(k, :) = MSELK;
        end

        PSNR1_1(j, i) = mean(20 * log10(255 ./ mean(mesos, 2)));
        PSNR1_lk_1(j, i) = mean(20 * log10(255 ./ mean(mesos_lk, 2)));

        %% Low2 video
        mesos = zeros(N, noi);
        mesos_lk = zeros(N, noi);
        disp(['Low2: j = ' num2str(j)]);

        for k = 1:N
            temp = low2.read(i);

            % Apply Gaussian distortion to img
            img = low2.read(i + 1);
            img = uint8(double(img) + sqrt(var_(j)) .* randn(size(img)));

            [results, results_lk, MSE, rho, MSELK] = ecc_lk_alignment( ...
                img, temp, nol, noi, 'affine', eye(2,3));

            mesos(k, :) = MSE;
            mesos_lk(k, :) = MSELK;
        end

        PSNR1_2(j, i) = mean(20 * log10(255 ./ mean(mesos, 2)));
        PSNR1_lk_2(j, i) = mean(20 * log10(255 ./ mean(mesos_lk, 2)));
    end
end
toc;

%% Get PSNR frames' mean
m_PSNRh_1    = mean(PSNRh_1(:, 1:L), 2);
m_PSNRh_lk_1 = mean(PSNRh_lk_1(:, 1:L), 2);
m_PSNRh_2    = mean(PSNRh_2(:, 1:L), 2);
m_PSNRh_lk_2 = mean(PSNRh_lk_2(:, 1:L), 2);

m_PSNR1_1    = mean(PSNR1_1(:, 1:L), 2);
m_PSNR1_lk_1 = mean(PSNR1_lk_1(:, 1:L), 2);
m_PSNR1_2    = mean(PSNR1_2(:, 1:L), 2);
m_PSNR1_lk_2 = mean(PSNR1_lk_2(:, 1:L), 2);

q6_gauss = [m_PSNRh_1 m_PSNRh_lk_1 m_PSNR1_1 m_PSNR1_lk_1;
            m_PSNRh_2 m_PSNRh_lk_2 m_PSNR1_2 m_PSNR1_lk_2];

save('question6_gauss.mat', 'q6_gauss');

