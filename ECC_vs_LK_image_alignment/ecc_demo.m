%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is a demo execution of the ECC image alignment algorithm
% 
% Adjusted for compatibility with the referenced ECC alignment code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Uncomment one of the following lines to select the transformation type
% transform = 'translation';
transform = 'affine';
%transform = 'homography';
% transform = 'euclidean';

% Parameters for the ECC algorithm
NoI = 50; % Number of iterations
NoL = 2;  % Number of pyramid levels
verbose = 1; % Plot results at the end of execution

% Load and preprocess the input image
im_demo = imread('cameraman.tif'); % Replace with your image if needed
[A, B, C] = size(im_demo);
if C == 3
    im_demo = rgb2gray(im_demo); % Convert to grayscale if RGB
end
im_demo = double(im_demo);

% Transformation-specific initialization
switch lower(transform)
    case 'translation'
        warp_demo = [1.53; -2.67] + 20; % Example warp
        init = [20; 20]; % Translation initialization
                
    case 'affine'
        warp_demo = [1 - 0.02, 0.03, 1.5; 0.02, 1 - 0.05, -2.5];
        warp_demo(1:2, 3) = warp_demo(1:2, 3) + 20;
        init = [eye(2), 20 * ones(2, 1)]; % Translation-only initialization
        
    case 'euclidean'
        angle = pi / 30;
        warp_demo = [cos(angle), -sin(angle), 1.25; sin(angle), cos(angle), -2.55];
        warp_demo(1:2, 3) = warp_demo(1:2, 3) + 20;
        init = [eye(2), 20 * ones(2, 1)]; % Translation-only initialization
        
    case 'homography'
        warp_demo = [1 - 0.02, -0.03, 1.5; 0.05, 1 - 0.05, -2.5; 0.0001, 0.0002, 1];
        warp_demo(1:2, 3) = warp_demo(1:2, 3) + 20;
        init = eye(3);
        init(1:2, 3) = 20; % Translation-only initialization
        
    otherwise
        error('Invalid transform type. Choose from: translation, affine, euclidean, homography');
end

% Define the ROI
Nx = 1:B-40; % X-coordinates of ROI
Ny = 1:A-40; % Y-coordinates of ROI

% Generate the template using the warp_demo parameters
template_demo = spatial_interp(im_demo, warp_demo, 'linear', transform, Nx, Ny);

% Perform ECC alignment
[results, results_lk, final_warp, warped_image] = ecc_lk_alignment(...
    im_demo, template_demo, NoL, NoI, transform, init);

% Backward warp the input image
nx = 1:size(template_demo, 2);
ny = 1:size(template_demo, 1);
image2 = spatial_interp(double(im_demo), results(NoL,NoI).warp, 'linear', transform, nx, ny);
template = double(template_demo);

% Display results
if verbose
    pad = 1; % Padding for ROI visualization
    
    % Project ROI corners using the final warp
    ROI_corners = [nx(1) + pad, nx(1) + pad, nx(end) - pad, nx(end) - pad; ...
                   ny(1) + pad, ny(end) - pad, ny(1) + pad, ny(end) - pad];
    if strcmp(transform, 'translation')
        wROI_corners = ROI_corners + repmat(results(NoL,NoI).warp, 1, 4);
    else
        wROI_corners = results(NoL,NoI).warp * [ROI_corners; ones(1, 4)];
        if strcmp(transform, 'homography')
            wROI_corners = wROI_corners ./ repmat(wROI_corners(3, :), 3, 1);
        end
    end
    
    % Plot template with marked ROI
    subplot(2, 2, 1);
    imshow(uint8(template_demo));
    hold on;
    plot_roi(nx, ny, pad, 'm');
    title('1 Template with marked ROI');
    hold off;
    
    % Plot input image with warped ROI
    subplot(2, 2, 2);
    imshow(uint8(im_demo));
    hold on;
    plot_roi(wROI_corners(1, :), wROI_corners(2, :), 0, 'm');
    title('Input image with warped ROI');
    hold off;
    
    % Plot backward-warped input image
    subplot(2, 2, 3);
    imshow(uint8(image2));
    title('Backward-warped input image');
    
    % Plot error image
    subplot(2, 2, 4);
    imshow(double(image2) - template_demo, []);
    colorbar;
    title('Error image');
end

%% Helper Function for ROI Visualization
function plot_roi(x, y, pad, color)
    line([x(1) + pad, x(end) - pad], [y(1) + pad, y(1) + pad], 'Color', color);
    line([x(end) - pad, x(end) - pad], [y(1) + pad, y(end) - pad], 'Color', color);
    line([x(1) + pad, x(end) - pad], [y(end) - pad, y(end) - pad], 'Color', color);
    line([x(1) + pad, x(1) + pad], [y(1) + pad, y(end) - pad], 'Color', color);
end
