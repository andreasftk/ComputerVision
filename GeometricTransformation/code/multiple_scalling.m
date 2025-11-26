%% Load Image and Mask, Remove Background
ball = imread('ball.jpg'); 
ball_mask = imread('ball_mask.jpg'); % Load ball mask

ball_mask = imbinarize(rgb2gray(ball_mask));
ball_mask = im2double(1 - ball_mask);
ball_double = im2double(ball);

ball_removed_bg = zeros(size(ball_double));
for c = 1:3
    ball_removed_bg(:,:,c) = ball_double(:,:,c) .* ball_mask;
end
ball_removed_bg = im2uint8(ball_removed_bg);

%% Create Affine Transformations for Scaling
scale1 = affine2d([0.5 0 0; 0 0.5 0; 0 0 1]);   % 50% Scale
scale2 = affine2d([1.5 0 0; 0 1.5 0; 0 0 1]);   % 150% Scale
scale3 = affine2d([0.75 0 0; 0 0.75 0; 0 0 1]);  % 75% Scale
scale4 = affine2d([0.25 0 0; 0 0.25 0; 0 0 1]);  % 25% Scale

% Use an output view that is larger than the original to prevent cropping
outputView = imref2d(size(ball) * 2);

% Apply transformations
I1 = imwarp(ball_removed_bg, scale1, 'OutputView', outputView);   % 50%
I2 = imwarp(ball_removed_bg, scale2, 'OutputView', outputView);   % 150%
I3 = imwarp(ball_removed_bg, scale3, 'OutputView', outputView);   % 75%
I4 = imwarp(ball_removed_bg, scale4, 'OutputView', outputView);   % 25%
I_original = ball_removed_bg;                                      % Original (100%)

%% Arrange All Versions on a Single Canvas (Side-by-Side)

% Define the images in the desired left-to-right order:
% Order: 25% Scale, 50% Scale, 75% Scale, Original, 150% Scale
images = {I4, I1, I3, I_original, I2};
labels = {'25% Scale', '50% Scale', '75% Scale', 'Original', '150% Scale'};

% Get dimensions for each image
nImgs = numel(images);
widths = zeros(1, nImgs);
heights = zeros(1, nImgs);
for k = 1:nImgs
    [heights(k), widths(k), ~] = size(images{k});
end

% Define margins and label space (in pixels)
margin = 10;  % **Reduced spacing between images**
label_space = 30;  % space at top for labels

% Compute the canvas dimensions:
canvasHeight = max(heights) + label_space + 2*margin;
canvasWidth = margin;  % start with left margin
for k = 1:nImgs
    canvasWidth = canvasWidth + widths(k) + margin;
end

% Create a blank canvas (black background)
canvas = zeros(canvasHeight, canvasWidth, 3, 'uint8');

% Place each image side-by-side with a margin
currentX = margin + 1;  % starting x-coordinate (MATLAB indices start at 1)
label_positions = zeros(nImgs,2);  % to store label center positions

for k = 1:nImgs
    img = images{k};
    [h, w, ~] = size(img);
    % Compute vertical position: leave margin and label space at top, then center vertically
    yPos = margin + label_space + floor((max(heights) - h)/2) + 1;
    % Place the image on the canvas
    canvas(yPos:yPos+h-1, currentX:currentX+w-1, :) = img;
    % Compute the horizontal center for the label
    centerX = currentX + floor(w/2);
    label_positions(k,:) = [centerX, margin + round(label_space/2)];
    % Update currentX for next image (current image width + margin)
    currentX = currentX + w + margin;
end

%% Display the Final Canvas with Labels
imshow(canvas);
hold on;
for k = 1:nImgs
    % Place label above each image, centered horizontally.
    text(label_positions(k,1), label_positions(k,2), labels{k}, ...
        'Color', 'white', 'FontSize', 12, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');
end
hold off;
