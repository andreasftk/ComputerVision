clc; clear; close all;

background_img = im2double(imread('P200.jpg')); 
images = {'bench.jpg', 'dog1.jpg', 'dog2.jpg', 'cat.jpg', 'photographer.jpg'};
mask_paths = {'masks/bench_mask.png', 'masks/dog1_mask.png', 'masks/dog2_mask.png', 'masks/cat_mask.png', 'masks/photographer_mask.png'};

num_objects = length(images);
image_data = cell(1, num_objects);
mask_data = cell(1, num_objects);

% Load foreground images and their masks
for i = 1:num_objects
    image_data{i} = im2double(imread(images{i}));
    mask_data{i} = im2double(imread(mask_paths{i}));
    
    % Convert mask to grayscale if needed
    if size(mask_data{i}, 3) == 3
        mask_data{i} = rgb2gray(mask_data{i});
    end
end

% Resize all images and masks to match the background size
[M, N, C] = size(background_img);
for i = 1:num_objects
    image_data{i} = imresize(image_data{i}, [M, N]);
    mask_data{i} = imresize(mask_data{i}, [M, N]);
end

%% Parameters

% Define the number of pyramid levels
levels = 5;

% Define affine transformation parameters for each object
affine_params = [
    0.5,  0.5,  0, 1200, 1300; % Bench
    0.3,  0.3,  0, 1400, 1800;  % Dog1
    0.25, 0.3,  0, 1100, 1700;  % Dog2
    0.15, 0.15, 0, 1880, 2000;  % Cat
    0.4,  0.3,  0, 0, 1700]; % Photographer

%% Apply affine transformations (scaling, rotation, translation) to images and masks
transformed_images = cell(1, num_objects);
transformed_masks = cell(1, num_objects);

for i = 1:num_objects
    % Extract parameters
    scale_x = affine_params(i, 1);
    scale_y = affine_params(i, 2);
    theta = deg2rad(affine_params(i, 3)); % Convert degrees to radians
    tx = affine_params(i, 4); % Translation X
    ty = affine_params(i, 5); % Translation Y
    
    % Define affine transformation matrix (excluding translation)
    A = [scale_x * cos(theta), -sin(theta),  0;
         sin(theta), scale_y * cos(theta),  0;
         0, 0, 1];
    
    % Create affine2d transformation object
    affine_tform = affine2d(A);
    
    % Apply transformation to image and mask
    transformed_images{i} = imwarp(image_data{i}, affine_tform, 'OutputView', imref2d(size(background_img)));
    transformed_masks{i} = imwarp(mask_data{i}, affine_tform, 'OutputView', imref2d(size(background_img)));
    
    % Apply translation separately
    transformed_images{i} = imtranslate(transformed_images{i}, [tx, ty], 'FillValues', 0);
    transformed_masks{i} = imtranslate(transformed_masks{i}, [tx, ty], 'FillValues', 0);
end

%%
%%%%%%%%%%%%%% Προτεινόμενη διαδικασία %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1. Create Gaussian pyramids for the transformed masks
gauss_masks = cell(1, num_objects);
for i = 1:num_objects
    gauss_masks{i} = genPyr(transformed_masks{i}, 'gauss', levels);
end

%% 2. Create Laplacian pyramids for the background and transformed objects (Now in COLOR!)
lap_background = genPyr(background_img, 'laplace', levels);
lap_objects = cell(1, num_objects);
for i = 1:num_objects
    lap_objects{i} = genPyr(transformed_images{i}, 'laplace', levels);
end

% Ensure each mask pyramid level is resized correctly
for i = 1:levels
    [Mp, Np, ~] = size(lap_background{i});
    for j = 1:num_objects
        gauss_masks{j}{i} = imresize(gauss_masks{j}{i}, [Mp, Np]);
    end
end

%% 3. Create the blended Laplacian pyramid
blended_pyr = lap_background; % Start with background as base
for i = 1:levels
    for j = 1:num_objects
        blended_pyr{i} = blended_pyr{i} .* (1 - gauss_masks{j}{i}) + lap_objects{j}{i} .* gauss_masks{j}{i};
    end
end

%% 4. Reconstruct the final blended image
final_image = pyrReconstruct(blended_pyr);



%% Display the Laplacian pyramids for all objects and the final blended composition
figure;
for i = 1:levels
    subplot(1, levels, i);
    imshow(lap_background{i} + 0.5); % Adjust contrast for visibility
    title(['BG - L', num2str(i)]);
end
sgtitle('Laplacian Pyramid of Background');

% Laplacian Pyramids for Each Object
for j = 1:num_objects
    figure;
    for i = 1:levels
        subplot(1, levels, i);
        imshow(lap_objects{j}{i} + 0.5); % Adjust contrast for visibility
        title(['Obj ', num2str(j), ' - L', num2str(i)]);
    end
    sgtitle(['Laplacian Pyramid of Object ', num2str(j)]);
end

figure;
imshow(final_image);
title('Final Blended Composition');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Display Original, Mask, Transformed Image, and Transformed Mask
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
for j = 1:num_objects
    subplot(num_objects, 4, (j-1)*4 + 1);
    imshow(image_data{j}); title(['Obj ', num2str(j), ' - Original']);

    subplot(num_objects, 4, (j-1)*4 + 2);
    imshow(mask_data{j}); title(['Obj ', num2str(j), ' - Original Mask']);

    subplot(num_objects, 4, (j-1)*4 + 3);
    imshow(transformed_images{j}); title(['Obj ', num2str(j), ' - Transformed']);

    subplot(num_objects, 4, (j-1)*4 + 4);
    imshow(transformed_masks{j}); title(['Obj ', num2str(j), ' - Transformed Mask']);
end
sgtitle('Original, Mask, Transformed Image, and Transformed Mask');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Blended Laplacian Pyramid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;
for i = 1:levels
    subplot(1, levels, i);
    imshow(blended_pyr{i} + 0.5); % Adjust contrast for visibility
    title(['Blended - L', num2str(i)]);
end
sgtitle('Blended Laplacian Pyramid');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Gauss Pyramids for Each Mask
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j = 1:num_objects
    figure;
    for i = 1:levels
        subplot(1, levels, i);
        imshow(gauss_masks{j}{i} + 0.5); % Adjust contrast for visibility
        title(['Obj ', num2str(j), ' - L', num2str(i)]);
    end
    sgtitle(['Gaussian Pyramid of Mask ', num2str(j)]);
end


% %% Display Original Images and Corresponding Masks
% 
% figure;
% for j = 1:num_objects
%     % First row: Original Images
%     subplot(2, num_objects, j);
%     imshow(image_data{j});
%     title(['Obj ', num2str(j), ' - Original']);
% 
%     % Second row: Corresponding Masks
%     subplot(2, num_objects, j + num_objects);
%     imshow(mask_data{j});
%     title(['Obj ', num2str(j), ' - Original Mask']);
% end
% sgtitle('Original Images and Corresponding Masks');