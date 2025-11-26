# Exercise 2 – Geometric Transformations in Computer Vision

This repository contains the implementation of **Exercise 2** from the Computer Vision course on geometric transformations and computer graphics. The aim of the exercise is to implement and study basic 2D geometric transformations using MATLAB, and to apply them in simple image-based animation tasks.

---

## Overview

The main objectives of this exercise are:

- To become familiar with **affine** and **projective** geometric transformations in 2D.
- To use MATLAB functions for image transformation and visualization:
  - `imread`, `imshow`
  - `imwarp`
  - `affine2d`, `projective2d`
  - `imref2d`
  - `implay`
- To apply transformations such as **translation**, **scaling**, **shearing**, and **rotation**.
- To perform **image masking** and **compositing** on a background.
- To generate **animation sequences** and export them as video files.

---

## Contents

The exercise is structured in several parts:

1. **MATLAB Function Study**  
   A brief study and usage of core MATLAB functions related to geometric transformations and image display:
   - Reading and displaying images.
   - Defining affine and projective transformations.
   - Handling spatial referencing objects.
   - Playing and inspecting image sequences.

2. **Scaled Composite Image**  
   Construction of a composite image formed by multiple scaled versions of an object:
   - Use of affine scaling transformations and/or `imresize`.
   - Exploration of uniform and non-uniform scaling.
   - Arrangement of scaled copies into a single output image.

3. **Shearing Animation (`sheared_pudding`)**  
   Creation of a periodic shearing animation of `pudding.png`:
   - Definition of a horizontal shear factor that varies sinusoidally over time.
   - Application of time-varying affine transformations using `affine2d` and `imwarp`.
   - Export of the resulting frames as a video sequence (e.g. `sheared_pudding.mp4` or similar).

4. **Windmill Animation (`transf_windmill`)**  
   Synthesis of a rotating windmill animation using:
   - `windmill.png` (foreground object)
   - `windmill_mask.png` (binary mask)
   - `windmill_back.jpeg` (background)
   
   Main steps:
   - Rotation of the windmill blades via affine transformations.
   - Use of masks and `imref2d` for proper alignment and compositing onto the background.
   - Experimentation with different interpolation methods (`nearest`, `linear`, `cubic`) and visual comparison.
   - Export of the final animation as `transf_windmill.*`.

5. **Ball-on-Beach Animation (`transf_beach`)**  
   Implementation of a physics-inspired animation of a ball over a beach background using:
   - `ball.jpg` and `ball_mask.jpg`
   - `beach.jpg`
   
   The ball undergoes:
   - Translation, rotation, and uniform scaling.
   - Masking and compositing on the beach background.
   - Motion governed by simple discrete-time kinematics with:
     - Gravity
     - Bounces with energy loss
     - Boundary checks (ground and screen limits)
   - Export of the animation as `transf_beach.*`.

6. **Depth-Enhanced Ball Trajectory (`transf_beach_depth`)**  
   An extended version of the previous animation in which:
   - The ball follows a different trajectory towards the sea and horizon.
   - Dynamic scaling and vertical flipping are applied to simulate motion in depth.
   - A second video sequence is generated (e.g. `transf_beach_depth.*`).

---

## Requirements

- **MATLAB** (version with Image Processing Toolbox recommended)
- Basic knowledge of:
  - Matrix operations and homogeneous coordinates.
  - Affine transformations in 2D.
  - MATLAB scripting and function usage.

---

## How to Run

1. Clone or download this repository.
2. Open MATLAB and add the repository folder (and subfolders, if any) to the MATLAB path:
   ```matlab
   addpath(genpath('path_to_repository'));
