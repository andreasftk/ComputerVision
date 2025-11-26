%%%%%%%%%%%%% Question 8 (Revised with Physics, Scaling, & Vertical Flipping) %%%%%%%%%%%%%
clear all;
close all;

%% Load images and create ball mask
beach = imread('beach.jpg');           % Background image
ball  = imread('ball.jpg');            % Ball image
ball_mask = imread('ball_mask.jpg');   % Ball mask

ball_mask = imbinarize(rgb2gray(ball_mask));  % Ensure mask is binary
ball_mask = double(ball_mask);                % For blending
inverseMask = 1 - ball_mask;                  % Inverse mask (background area)

% Get dimensions
[beach_height, beach_width, ~] = size(beach);
[ball_height, ball_width, ~]   = size(ball);

%% Video parameters
video_filename = 'transf_beach_depth.mp4';  % Output video filename
fps = 30;                                   % Frames per second
num_frames = 240;                           % Total frames (8 seconds at 30 fps)

%% Physics parameters (matching previous style)
pixel_gravity    = 0.6;    % Downward acceleration (pixels/frame^2)
initial_velocity = 25;     % Initial upward velocity (pixels/frame)
bounciness       = 0.6;    % Energy loss factor on bounce

% Scaling parameters: the ball scales from larger (near the ground) to smaller (at its peak)
initial_scale = 0.5;      
final_scale   = 0.1;      

% Initial conditions for vertical motion
position_x = beach_width / 2;     % Fixed horizontal position (centered)
position_y = beach_height - 150;  % Starting near the bottom
velocity_y = initial_velocity;    % Start upward

% Ground level (for bounce)
ground_level = beach_height - 150;

%% Video writer setup
video_writer = VideoWriter(video_filename, 'MPEG-4');
video_writer.FrameRate = fps;
open(video_writer);

%% Main loop: update physics, scaling, and vertical flip
for frame = 1:num_frames
    
    %--------------------------------------------------------------
    % 1) Update scaling factor (linearly from initial_scale to final_scale)
    %--------------------------------------------------------------
    alpha = frame / num_frames;  % progress from 0 to 1 over the animation
    current_scale = (1 - alpha) * initial_scale + alpha * final_scale;
    
    %--------------------------------------------------------------
    % 2) Update vertical motion using physics
    %--------------------------------------------------------------
    velocity_y = velocity_y - pixel_gravity;   % apply gravity
    position_y = position_y - velocity_y;       % update position (note: image y increases downward)
    
    % Prevent the ball from moving off the top of the frame
    if position_y < 0
        position_y = 0;
        velocity_y = 0;
    end
    
    % Bounce on the ground
    if position_y > ground_level
        position_y = ground_level;
        velocity_y = -velocity_y * bounciness;
    end
    
    %--------------------------------------------------------------
    % 3) Determine vertical flip factor for this frame
    %    flip_factor alternates between 1 and -1 each frame.
    %    When flip_factor is -1, the ball is vertically flipped.
    %--------------------------------------------------------------
    flip_interval = 2;  % Number of frames before the ball flips
    flip_factor = (-1)^(floor((frame-1)/flip_interval) + 1);  % Change exponent if you want to start unflipped
    
    %--------------------------------------------------------------
    % 4) Build the combined affine transform for scaling and vertical flip
    %    We apply the transform about the center of the original ball image.
    %--------------------------------------------------------------
    cx = ball_width / 2;
    cy = ball_height / 2;
    
    % Translate the center to the origin
    Tcenter = [1 0 0; 0 1 0; -cx -cy 1];
    
    % Create a scaling matrix that also flips vertically when flip_factor = -1
    Tscale_flip = [ current_scale, 0, 0;
                    0, current_scale * flip_factor, 0;
                    0, 0, 1 ];
    
    % Translate the center back to its original location
    Tback = [1 0 0; 0 1 0; cx cy 1];
    
    % Combined affine transform
    transformMatrix = Tback * Tscale_flip * Tcenter;
    tform = affine2d(transformMatrix);
    
    % Warp the ball image and its mask using the combined transform
    ball_ref = imref2d(size(ball(:,:,1)));
    mask_ref = imref2d(size(inverseMask));
    
    transformed_ball = imwarp(ball, ball_ref, tform, 'cubic', 'FillValues', 0);
    transformed_mask = imwarp(inverseMask, mask_ref, tform, 'cubic', 'FillValues', 0);
    
    %--------------------------------------------------------------
    % 5) Overlay the transformed ball on the beach background
    %    The ball is placed so that its center is at (position_x, position_y)
    %--------------------------------------------------------------
    top_left_x = round(position_x - size(transformed_ball,2)/2);
    top_left_y = round(position_y - size(transformed_ball,1)/2);
    
    % Clip coordinates to ensure they fall within the background image
    x_start = max(1, top_left_x);
    y_start = max(1, top_left_y);
    x_end   = min(beach_width,  top_left_x + size(transformed_ball,2) - 1);
    y_end   = min(beach_height, top_left_y + size(transformed_ball,1) - 1);
    
    % Determine the corresponding indices in the transformed ball image and mask
    ball_x_start = max(1, 1 - top_left_x + 1);
    ball_y_start = max(1, 1 - top_left_y + 1);
    ball_x_end   = ball_x_start + (x_end - x_start);
    ball_y_end   = ball_y_start + (y_end - y_start);
    
    % Crop the transformed ball and mask as necessary
    cropped_ball = transformed_ball(ball_y_start:ball_y_end, ball_x_start:ball_x_end, :);
    cropped_mask = transformed_mask(ball_y_start:ball_y_end, ball_x_start:ball_x_end);
    
    % Compose the final frame by overlaying the ball onto the beach
    frame_image = beach;
    for c = 1:3
        region = frame_image(y_start:y_end, x_start:x_end, c);
        ball_overlay = double(cropped_ball(:, :, c)) .* cropped_mask;
        frame_image(y_start:y_end, x_start:x_end, c) = ...
            uint8(double(region) .* (1 - cropped_mask) + ball_overlay);
    end
    
    writeVideo(video_writer, frame_image);
end

close(video_writer);
