clc; clear; close all;

% Load input images (ensure they exist in the working directory)
apple = im2double(imread('apple1.jpg'));
orange = im2double(imread('orange1.jpg'));

% Ensure both images have the same size
[M, N, C] = size(apple);
orange = imresize(orange, [M, N]);

% Define number of pyramid levels
levels = 5;

% Generate Laplacian pyramids for each image (for each color channel)
lap_apple = genPyr(apple, 'laplace', levels);
lap_orange = genPyr(orange, 'laplace', levels);

% Create a blending mask (left side: apple, right side: orange)
mask = zeros(M, N, C);
mask(:, 1:floor(N/2), :) = 1;  % Left side = 1 (apple), right side = 0 (orange)
mask_blurred = imgaussfilt(mask, 10); % Smooth transition with Gaussian filter

% Create the blended Laplacian pyramid
blended_pyr = cell(1, levels);
for i = 1:levels
    [Mp, Np, ~] = size(lap_apple{i});
    mask_resized = imresize(mask_blurred, [Mp, Np]);
    blended_pyr{i} = lap_apple{i} .* mask_resized + lap_orange{i} .* (1 - mask_resized);
end

% Reconstruct the final blended image
blended_image = pyrReconstruct(blended_pyr);

% Display results
figure;
subplot(1, 3, 1); imshow(apple); title('Original Apple Image');
subplot(1, 3, 2); imshow(orange); title('Original Orange Image');
subplot(1, 3, 3); imshow(blended_image); title('Final Blended Image');

% Display Laplacian Pyramids for each color channel
figure;
for i = 1:levels
    subplot(2, levels, i);
    imshow(lap_apple{i} + 0.5); title(['Apple - L', num2str(i)]);
    
    subplot(2, levels, i + levels);
    imshow(lap_orange{i} + 0.5); title(['Orange - L', num2str(i)]);
end

% Create a figure similar to the reference image layout
figure;

% Plot Laplacian pyramid levels for apple, orange, and blended result
for i = 1:levels
    % Row 1: Apple Laplacian Pyramid
    subplot(4, levels, i);
    imshow(lap_apple{i} + 0.5);
    title(['(a) L', num2str(i)]);
    
    % Row 2: Orange Laplacian Pyramid
    subplot(4, levels, i + levels);
    imshow(lap_orange{i} + 0.5);
    title(['(b) L', num2str(i)]);
    
    % Row 3: Blended Laplacian Pyramid
    subplot(4, levels, i + 2 * levels);
    imshow(blended_pyr{i} + 0.5);
    title(['(c) L', num2str(i)]);
end

% Reconstruct blended image step by step and display each stage
reconstructed_images = cell(1, levels);
reconstructed_images{levels} = blended_pyr{levels}; % Start with the last blended level

for i = levels-1:-1:1
    % Expand and add next level
    reconstructed_images{i} = pyr_expand(reconstructed_images{i+1}) + blended_pyr{i};
    
    % Display the reconstruction at each stage
    subplot(4, levels, i + 3 * levels);
    imshow(reconstructed_images{i});
    title(['(d) Rec L', num2str(i)]);
end

% Final reconstructed blended image
figure;
subplot(1,3,1); imshow(apple); title('(j) Original Apple');
subplot(1,3,2); imshow(orange); title('(k) Original Orange');
subplot(1,3,3); imshow(reconstructed_images{1}); title('(l) Final Blended Image');
