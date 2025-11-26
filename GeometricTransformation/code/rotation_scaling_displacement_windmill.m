% Load input images
windmill = imread('windmill.png','BackgroundColor',[0 0 0]);        % Windmill image (with red background)
windmill_mask = imread('windmill_mask.png'); % Windmill mask
background = imread('windmill_back.jpeg');   % Background image

% Convert mask to logical
if size(windmill_mask, 3) == 3
    windmill_mask = rgb2gray(windmill_mask);
end
windmill_mask = imbinarize(windmill_mask);

% Inverse the mask (background becomes the windmill)
windmill_mask = ~windmill_mask;

%% 
% Prepare video writer
outputVideo = VideoWriter('transf_windmill', 'MPEG-4');
outputVideo.FrameRate = 30; % Set desired frame rate
open(outputVideo);

% Video settings
numFrames = 150; % Total frames for rotation sequence
rotationAngles = linspace(0, 360, numFrames); % Rotation angles for impellers

%% 

% Get the dimensions of the images
[windmillRows, windmillCols, ~] = size(windmill);
[bgRows, bgCols, ~] = size(background);

% Calculate the center of the windmill and the background
centerWindmill = [windmillCols / 2, windmillRows / 2];
centerBackground = [bgCols / 2, bgRows / 2];

% Process each frame
for i = 1:numFrames


    % Define rotation transformation matrix
    theta = rotationAngles(i); % Rotation angle in degrees
    A = [ cosd(theta) sind(theta) 0;
         -sind(theta) cosd(theta) 0;
          0           0           1];
    
    tform_rt = affine2d(A'); % Create affine transformation
    
    % Define reference object for the transformation
    imref_temp = imref2d(size(windmill)); % Reference for transformation
    
    % Apply transformation to the windmill image & mask
    rotatedWindmill = imwarp(windmill, imref_temp, tform_rt, 'Interp', 'cubic', 'FillValues', 1);
    rotatedMask = imwarp(windmill_mask, imref_temp, tform_rt, 'Interp', 'cubic', 'FillValues', 0);
    
    % Center the rotated windmill on the background
    [rotRows, rotCols, ~] = size(rotatedWindmill);
    offsetX = round(centerBackground(1) - rotCols / 2);
    offsetY = round(centerBackground(2) - rotRows / 2);

    % Create a canvas the size of the background
    canvasWindmill = zeros(bgRows, bgCols, 3, 'uint8');
    canvasMask = false(bgRows, bgCols);

    % Place the rotated windmill and mask on the canvas
    yRange = max(1, offsetY):min(bgRows, offsetY + rotRows - 1);
    xRange = max(1, offsetX):min(bgCols, offsetX + rotCols - 1);

    % Ensure the ranges are valid
    windmillYRange = max(1, 1 - offsetY):min(rotRows, bgRows - offsetY);
    windmillXRange = max(1, 1 - offsetX):min(rotCols, bgCols - offsetX);

    % Add the rotated windmill to the canvas, respecting transparency
    canvasWindmill(yRange, xRange, :) = rotatedWindmill(windmillYRange, windmillXRange, :);
    canvasMask(yRange, xRange) = rotatedMask(windmillYRange, windmillXRange);

    % Combine the canvas with the background
    combinedImage = background;
    for c = 1:size(background, 3)
        combinedImage(:, :, c) = combinedImage(:, :, c) .* uint8(~canvasMask) + ...
                                 canvasWindmill(:, :, c) .* uint8(canvasMask);
    end

    % Write the frame to the video
    writeVideo(outputVideo, combinedImage);
end

% Close the video writer
close(outputVideo);

disp('Video transf_windmill created successfully!');
