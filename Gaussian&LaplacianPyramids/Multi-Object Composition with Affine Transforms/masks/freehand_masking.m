% Demo to have the user freehand draw an irregular shape over a gray scale image.
% Then it creates new images:
% (1) where the drawn region is all white inside the region and untouched outside the region,
% (2) where the drawn region is all black inside the region and untouched outside the region,
% (3) where the drawn region is untouched inside the region and all black outside the region.
% It also (4) calculates the mean intensity value and standard deviation of the image within that shape,
% (5) calculates the perimeter, centroid, and center of mass (weighted centroid), and
% (6) crops the drawn region to a new, smaller separate image.

% Change the current folder to the folder of this m-file.
if(~isdeployed)
	cd(fileparts(which(mfilename)));
end
clc; % Clear command window.
clear; % Delete all variables.
close all; % Close all figure windows except those created by imtool.
imtool close all; % Close all figure windows created by imtool.
workspace; % Make sure the workspace panel is showing.
fontSize = 16;

% See if the user wants to mask a gray scale image or a color RGB image.
promptMessage = sprintf('Do you want to mask a gray scale or color image?');
titleBarCaption = 'Continue?';
buttonText = questdlg(promptMessage, titleBarCaption, 'Gray Scale', 'Color', 'Cancel', 'Gray Scale');
if strcmpi(buttonText, 'Cancel')
	return;
elseif strcmpi(buttonText, 'Color')
	colorImage = true;
	baseFileName = 'photographer.jpg';
else
	colorImage = false;
	baseFileName = 'cameraman.tif';
end

% Read in a standard MATLAB gray scale demo image.
folder = fileparts(which('peppers.png')); % Determine where demo images folder is (works with all versions).
% Get the full filename, with path prepended.
fullFileName = fullfile(folder, baseFileName);
% Check if file exists.
if ~exist(fullFileName, 'file')
	% File doesn't exist -- didn't find it there. Check the search path for it.
	fullFileName = baseFileName; % No path this time.
	if ~exist(fullFileName, 'file')
		% Still didn't find it. Alert user.
		errorMessage = sprintf('Error: %s does not exist in the search path folders.', fullFileName);
		uiwait(warndlg(errorMessage));
		return;
	end
end

grayImage = imread(fullFileName);
imshow(grayImage, []);
axis on;
title('Original Grayscale Image', 'FontSize', fontSize);
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.

% Ask user to draw freehand mask.
message = sprintf('Left click and hold to begin drawing.\nSimply lift the mouse button to finish');
uiwait(msgbox(message));
hFH = imfreehand(); % Actual line of code to do the drawing.
% Create a binary image ("mask") from the ROI object.
binaryImage = hFH.createMask();
xy = hFH.getPosition;

% Save the binary mask image with a dynamic filename
[filepath, name, ext] = fileparts(baseFileName);
maskFileName = fullfile(filepath, [name, '_mask.png']);
imwrite(binaryImage, maskFileName);

% Now make it smaller so we can show more images.
subplot(2, 4, 1);
imshow(grayImage, []);
axis on;
drawnow;
title('Original gray scale image', 'FontSize', fontSize);

% Display the freehand mask.
subplot(2, 4, 2);
imshow(binaryImage);
axis on;
title('Binary mask of the region', 'FontSize', fontSize);
