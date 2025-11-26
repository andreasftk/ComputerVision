%% Question 3 %%

% Read image and initialize useful parameters
clear all; close all;

im = im2double(imread('pudding.png'));

% Generate a sinusoid. It will be used for the shear values
f = 1;
t = 0:0.01:1-0.01;
x_n = 0.2 * sin(2 * pi * f * t);

frames = length(x_n); % Number of frames
F(frames) = struct('cdata', [], 'colormap', []); % Struct containing all the frames

%% Convert the background from black to white
express = im > 0;
im = (ones(size(im)) - express) + express .* im;
[m,n]=size(im);
%% Create Video Writer object
video_filename = 'sheared_pudding.mp4';
video_writer = VideoWriter(video_filename, 'MPEG-4');
video_writer.FrameRate = 40; % Set frame rate
open(video_writer);

%% Loop - Shear image and place into the overall image
for i = 1:frames
    image = ones(m, 2 * n, 3); % Overall image

    %% Create an affine2d class object
    % Create affine2d's argument matrix A
    sh_y = 0;
    sh_x = x_n(i);
    
    A = [1 sh_x 0;
         sh_y 1 0;
         0    0 1];
     
    tform = affine2d(A');

    %% Apply scaling to image with imwarp
    im_temp = imwarp(im, tform, 'FillValues', 1.0);

    %% Place image to the right coordinates
    [k, l, ~] = size(im_temp);
    start_m = 1;
    end_m = start_m + k - 1;

    if sh_x > 0
        start_n = ceil(n / 2) - ceil((m * sh_x));
    else
        start_n = ceil(n / 2);
    end
    
    end_n = start_n + l - 1;

    image(start_m:end_m, start_n:end_n, :) = im_temp;

    %% Update movie F
    F(i) = im2frame(image, []);

    % Write frame to video file
    writeVideo(video_writer, F(i));
end

%% Close the video file
close(video_writer);

%% Play the results in 40 fps
%implay(F, 40);