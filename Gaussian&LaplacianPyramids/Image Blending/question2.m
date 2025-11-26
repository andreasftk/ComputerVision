clc; clear; close all;

% Load input images (convert to grayscale if necessary)
woman = im2double(rgb2gray(imread('woman.png')));
hand = im2double(rgb2gray(imread('hand.png')));

% Ensure both images have the same size
[M, N] = size(woman);
hand = imresize(hand, [M, N]);

% Create an elliptical mask
mask = zeros(M, N);
[X, Y] = meshgrid(1:N, 1:M);
center_x = round(N / 2);
center_y = round(M / 1.7);
a = round(N / 3.5); % Semi-major axis
b = round(M / 8); % Semi-minor axis
mask(((X - center_x).^2) / a^2 + ((Y - center_y).^2) / b^2 <= 1) = 1;

% Smooth the mask using Gaussian filtering
mask = imgaussfilt(mask, 2); % Blur for smooth blending

% Define number of pyramid levels
levels = 5;

% Generate Gaussian pyramids for the mask
gauss_mask = genPyr(mask, 'gauss', levels);

% Generate Laplacian pyramids for the images
lap_woman = genPyr(woman, 'laplace', levels);
lap_hand = genPyr(hand, 'laplace', levels);

% Ensure that the mask is correctly sized for each Laplacian level
for i = 1:levels
    [Mp, Np] = size(lap_woman{i}); % Get the size of the current Laplacian level
    gauss_mask{i} = imresize(gauss_mask{i}, [Mp, Np]); % Resize mask to match
end

% Create the blended Laplacian pyramid
blended_pyr = cell(1, levels);
for i = 1:levels
    blended_pyr{i} = lap_woman{i} .* gauss_mask{i} + lap_hand{i} .* (1 - gauss_mask{i});
end

% Reconstruct the final blended image
blended_image = pyrReconstruct(blended_pyr);

% Display results
figure;
subplot(2,2,1); imshow(woman); title('(a) Woman');
subplot(2,2,2); imshow(hand); title('(b) Hand');
subplot(2,2,3); imshow(mask); title('(c) Generated Elliptical Mask');
subplot(2,2,4); imshow(blended_image); title('(d) Blended Image');
