clear all; close all;
load("img.mat");
img = uint8(img);

frames = 2;

video(frames) = struct('cdata',[],'colormap',[]);

video(1) = im2frame(img,gray(256));
video(2) = im2frame(img,gray(256));