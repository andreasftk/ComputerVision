%%%%%%%%%%%%% Question 7 (Higher Shot) %%%%%%%%%%%%%
clear all;
close all;

%% 1) Load images
beach = imread('beach.jpg');          % Background image
ball  = imread('ball.jpg');           % Ball image
ball_mask = imread('ball_mask.jpg');  % Ball mask

% Ensure the ball mask is binary (0 or 1)
ball_mask = imbinarize(rgb2gray(ball_mask));
ball_mask = double(ball_mask);
inverseMask = 1 - ball_mask;

% Get dimensions
[beach_height, beach_width, ~] = size(beach);
[ball_height,  ball_width,  ~] = size(ball);

%% 2) Video parameters
video_filename = 'transf_beach.mp4';
fps = 30;
num_frames = 240;  % e.g. 8 seconds at 30 fps
dt = 1/fps;        % Time step in seconds

%% 3) Physics parameters
% Gravity in "pixel units" (instead of real m/s^2)
pixel_gravity = 0.6;       % downward acceleration per frame^2
bounciness = 0.6;          % energy loss factor on bounce
scale_factor = 0.2;        % ball scale

% Launch angle and velocity (in "pixels/frame")
theta = 70;                % Launch angle in degrees (increased from 50)
v0_pixels = 25;            % Initial speed in pixels/frame (increased from 25)

% Horizontal and vertical velocity components
v0x = v0_pixels * cosd(theta);
v0y = v0_pixels * sind(theta);

%% 4) Initial placement of the ball
ball_height_scaled = ball_height * scale_factor;
ball_width_scaled  = ball_width  * scale_factor;

% Start near the left side, but higher up:
position_x = ball_width_scaled / 2;
position_y = beach_height - 300;  % Higher than -200 to make the ball start higher

velocity_x = v0x;
velocity_y = v0y;

% "Ground" is a bit above the bottom of the beach
ground_level = beach_height - 100;

%% 5) Video writer setup
video_writer = VideoWriter(video_filename, 'MPEG-4');
video_writer.FrameRate = fps;
open(video_writer);

%% 6) Rotation parameters
rotation_angle = 0;
rotation_step = -2;  % Negative => clockwise in standard image coords

for frame = 1:num_frames
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % A) UPDATE PHYSICS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % 1) Gravity update
    velocity_y = velocity_y - pixel_gravity;
    
    % 2) Update positions
    position_x = position_x + velocity_x;
    position_y = position_y - velocity_y;  % subtract because y grows downward
    
    % 3) Check for bounce with the ground
    bottom_of_ball = position_y + ball_height_scaled / 2;
    if bottom_of_ball > ground_level
        position_y = ground_level - ball_height_scaled / 2;
        velocity_y = -velocity_y * bounciness;
    end
    
    % (Optional) Check for side bounces
    left_of_ball = position_x - ball_width_scaled / 2;
    right_of_ball = position_x + ball_width_scaled / 2;
    if left_of_ball < 1
        position_x = 1 + ball_width_scaled / 2;
        velocity_x = -velocity_x * bounciness; 
    elseif right_of_ball > beach_width
        position_x = beach_width - ball_width_scaled / 2;
        velocity_x = -velocity_x * bounciness;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % B) ROTATION + IMAGE WARP
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    rotation_angle = rotation_angle + rotation_step;
    
    cx = ball_width / 2;  
    cy = ball_height / 2; 
    
    Tcenter = [1 0 0; 0 1 0; -cx -cy 1];
    Tscale = [ scale_factor 0           0
               0           scale_factor 0
               0           0            1 ];
    R = [ cosd(rotation_angle)  sind(rotation_angle)  0
         -sind(rotation_angle)  cosd(rotation_angle)  0
          0                     0                     1 ];
    Tback = [1 0 0; 0 1 0; cx cy 1];
    
    transformMatrix = Tback * R * Tscale * Tcenter;
    tform = affine2d(transformMatrix);
    
    ball_ref = imref2d(size(ball(:,:,1)));
    mask_ref = imref2d(size(inverseMask));
    
    rotated_ball = imwarp(ball, ball_ref, tform, 'cubic', 'FillValues', 0);
    rotated_mask = imwarp(inverseMask, mask_ref, tform, 'cubic', 'FillValues', 0);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % C) OVERLAY ON BACKGROUND
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    top_left_x = round(position_x - size(rotated_ball,2)/2);
    top_left_y = round(position_y - size(rotated_ball,1)/2);
    
    x_start = max(1, top_left_x);
    y_start = max(1, top_left_y);
    x_end   = min(beach_width,  top_left_x + size(rotated_ball,2) - 1);
    y_end   = min(beach_height, top_left_y + size(rotated_ball,1) - 1);
    
    ball_x_start = max(1, 1 - top_left_x + 1);
    ball_y_start = max(1, 1 - top_left_y + 1);
    ball_x_end   = ball_x_start + (x_end - x_start);
    ball_y_end   = ball_y_start + (y_end - y_start);
    
    cropped_ball = rotated_ball(ball_y_start:ball_y_end, ball_x_start:ball_x_end, :);
    cropped_mask = rotated_mask(ball_y_start:ball_y_end, ball_x_start:ball_x_end);
    
    frame_image = beach;  % Start with the beach
    for c = 1:3
        region = frame_image(y_start:y_end, x_start:x_end, c);
        ball_overlay = double(cropped_ball(:, :, c)) .* cropped_mask;
        frame_image(y_start:y_end, x_start:x_end, c) = ...
            uint8(double(region) .* (1 - cropped_mask) + ball_overlay);
    end
    
    writeVideo(video_writer, frame_image);
end

close(video_writer);
