## Simulink-Based Image Transformations and Mosaicing

This exercise focuses on the implementation of geometric transformations and video-processing pipelines using **Simulink**. The objective is to model, visualize, and combine spatial transformations and feature-based alignment within a block-diagram environment.

### Geometric Transformations in Simulink

Several Simulink models are constructed to demonstrate basic and advanced geometric transformations:

- **Resizing and Translation**

  - Use of dedicated image processing blocks to resize frames and apply 2D translations.
  - Verification of spatial consistency across time in video sequences.
- **Rotation and Shearing**

  - Implementation of rotation and shearing operations via geometric transformation blocks.
  - Exploration of the effect of different rotation angles and shear factors on the input frames.
- **Affine and Projective Warping**

  - Application of general **affine** and **projective** transformations using `Warp` / geometric transform blocks.
  - Manipulation of homogeneous transformation matrices to control scaling, rotation, translation, shearing and perspective changes.

These models highlight how standard geometric operations can be chained and parameterized within Simulink to form reproducible video-processing pipelines.

### Feature-Based Corner Detection

To support alignment and mosaicing tasks, the following corner detectors are implemented and visualized in Simulink:

- **Harris & Stephens**
- **Rosen & Drummond**
- **Shi & Tomasi**

Each detector is used to compute interest points on incoming frames, and the detected corners are overlaid on the video stream for qualitative inspection. This demonstrates how Simulink can be used for real-time-like feature extraction and visualization.

### Image Mosaicing Pipeline

A Simulink-based mosaicing system is also built to create image mosaics from video sequences:

1. **Corner Detection and Matching**

   - Detection of keypoints in consecutive frames using one of the implemented detectors.
   - Matching of corner features between frames to establish correspondences.
2. **Transformation Estimation**

   - Estimation of **affine** or **projective** transformations between frames.
   - Use of robust estimation methods (e.g. RANSAC / Least Median of Squares) to reject outliers.
3. **Image Warping and Stitching**

   - Warping of frames into a common reference coordinate system.
   - Incremental composition of transformations to build a larger mosaic.
   - Compositing of warped frames into a single panoramic image.

This part of the exercise demonstrates how Simulink can be used not only for low-level geometric operations but also for higher-level **motion estimation**, **feature-based registration**, and **image mosaicing** in a modular, visually structured workflow.
