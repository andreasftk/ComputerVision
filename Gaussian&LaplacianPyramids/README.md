# Gaussian & Laplacian Pyramids – Image Blending Project

This project implements multi–scale image representations using **Gaussian** and **Laplacian pyramids** and applies them to **image blending and compositing** in MATLAB. The work follows the theoretical framework of multi–resolution analysis and pyramid-based blending presented in the course material.

## Objectives

- Construct Gaussian and Laplacian pyramids in 1D and 2D.
- Understand the relationship between filtering, downsampling and upsampling in pyramid construction.
- Implement pyramid-based **image blending** using masks and smooth transitions.
- Create complex image **composites** from multiple foreground objects and a background using affine transformations and pyramid blending.
- Gain familiarity with a MATLAB toolbox for pyramid generation and reconstruction.

## Pyramid Toolbox Functions

The project first documents and analyses the provided MATLAB toolbox functions: `genPyr`, `pyrReduce`, `pyrExpand`, `pyrBlend`, and `pyrReconstruct`.

- **`genPyr`**Generates either a **Gaussian pyramid** or a **Laplacian pyramid**:

  - Gaussian pyramid: repeated Gaussian filtering and downsampling.
  - Laplacian pyramid: difference between a Gaussian level and the upsampled next level.
- **`pyrReduce`**Applies a separable 5×5 Gaussian kernel (discrete analogue of a Gaussian filter) and then downsamples by a factor of 2 in each spatial dimension.
- **`pyrExpand`**Upsamples an image by inserting zeros between pixels and filters with appropriately partitioned Gaussian kernels to interpolate intermediate samples.
- **`pyrBlend`**Performs blending in the Laplacian pyramid domain using Gaussian pyramids of masks to obtain smooth, scale-dependent transitions between images.
- **`pyrReconstruct`**
  Reconstructs an image from its Laplacian pyramid by iterative expansion and summation of pyramid levels.

These functions are related back to the 1D matrix formulation of filtering and sampling using Toeplitz and Kronecker product matrices.

## 1D Gaussian & Laplacian Pyramids

A 1D noisy sinusoidal signal is used to:

- Build a **Gaussian pyramid** by repeated convolution with the 5-tap kernel\( h = \frac{1}{16}[1\;4\;6\;4\;1] \) and downsampling.
- Construct the corresponding **Laplacian pyramid** as\( L_k = G_k - \text{Expand}(G_{k+1}) \).
- Reconstruct the original signal from the Laplacian pyramid and verify that the reconstruction error is negligible.

This validates the correctness of the pyramid construction and reconstruction procedures. :contentReference[oaicite:2]{index=2}

## Image Blending – Apple/Orange

Using the classic **apple–orange** example:

- Two aligned images (`apple.jpg`, `orange.jpg`) and complementary binary masks are defined.
- The masks are **feathered** using Gaussian filtering to produce smooth transitions.
- Laplacian pyramids of both images and a Gaussian pyramid of the mask are computed.
- At each level, a blended Laplacian level is formed as\( B_j = G_j \cdot L^{(1)}_j + (1-G_j)\cdot L^{(2)}_j \).
- The final blended image is reconstructed with `pyrReconstruct`.

The result is a seamless hybrid image where the transition between apple and orange is visually natural across scales. :contentReference[oaicite:3]{index=3}

## Image Blending – Woman/Hand (Elliptical Mask)

A second blending experiment uses `woman.png` and `hand.png`:

- An **elliptical mask** is analytically defined around the eye region and then smoothed with a Gaussian filter.
- Gaussian and Laplacian pyramids for both images and for the mask are constructed.
- Pyramid-based blending is applied as in the previous case, but with a spatially localized elliptical transition.

This demonstrates how mask design affects the blending region and how pyramids provide spatially smooth mixing of local structures. :contentReference[oaicite:4]{index=4}

## Multi-Object Composition with Affine Transforms

A more complex composite image is created using:

- Background: `P200.jpg`
- Foreground objects: `bench.jpg`, `dog1.jpg`, `dog2.jpg`, `cat.jpg`, and a personal photograph (photographer).

For each object:

1. A foreground mask is extracted (freehand selection).
2. An **affine transformation** (scaling, rotation, translation) is defined and applied to both image and mask using `affine2d` and `imwarp`, optionally followed by `imtranslate`.
3. Transformed masks satisfy:
   - Local exclusivity:\(\sum_k m_k^{\text{final}}(n) \le 1\) for all pixels \(n\).
   - Binary support:
     \(m_k^{\text{final}}(n) = 1\) iff the pixel belongs to object \(k\).

Blending steps:

- Gaussian pyramids are built for each transformed mask.
- Laplacian pyramids are built for the background and all transformed objects.
- At each level, the blended Laplacian level is obtained by iteratively mixing objects into the background using their Gaussian masks.
- The final composite is reconstructed from the blended Laplacian pyramid.

The resulting image is a visually coherent scene where all objects are integrated smoothly into the park background. :contentReference[oaicite:5]{index=5}

---

# PSPNet Semantic Segmentation Evaluation

This part of the project evaluates a **pre-trained PSPNet (Pyramid Scene Parsing Network)** model on the **Cityscapes** validation dataset, focusing on semantic segmentation performance. The PSPNet architecture uses pyramid pooling over feature maps to aggregate contextual information at multiple spatial scales. :contentReference[oaicite:6]{index=6}

## Setup

The following resources are provided:

- `pspnet.py` – PSPNet model definition.
- `cityscapes_dataset.py` – dataset class for loading and preprocessing Cityscapes images and ground-truth labels.
- `train_epoch_200_CPU.pth` – pre-trained PSPNet weights (around 200 epochs).
- `cityscapes_val_dataset.zip` – validation images and labels.
- `cityscapes_colors.txt` – mapping of class indices to RGB colors.
- `cityscapes_names.txt` – class names corresponding to each label.

A new script `pspnet_eval.py` is implemented to:

- Load the pre-trained model and switch it to evaluation mode.
- Iterate over the validation dataset and compute predictions.
- Convert predictions and ground-truth labels into **confusion matrices** for each image.
- Aggregate statistics to compute segmentation metrics.

## Evaluation Metric – Mean Intersection over Union (mIoU)

The main metric used is **Mean Intersection over Union (mIoU)**, which is standard for semantic segmentation:

\[
\text{IoU}_c = \frac{\text{TP}_c}{\text{TP}_c + \text{FP}_c + \text{FN}_c},
\]

where TP, FP, FN are true positives, false positives and false negatives for class \(c\).

Several variants are considered: :contentReference[oaicite:8]{index=8}

1. **Per-class IoU over the dataset** (\( \text{IoU}_D \))

   - Accumulates TP, FP, FN across all images for each class.
2. **Mean IoU over the dataset** (\( \text{mIoU}_D \))

   - Average of \(\text{IoU}_D\) across all classes.
3. **Per-image IoU** (\( \text{IoU}_i \))

   - Computes IoU over all classes for each individual image.
4. **Mean IoU over images** (\( \text{mIoU}_I \))

   - Average IoU across the validation images.

In code, per-class IoU for one confusion matrix is computed as:

```python
def compute_mIoU(conf_matrix):
    intersection = np.diag(conf_matrix)
    union = conf_matrix.sum(axis=1) + conf_matrix.sum(axis=0) - intersection
    iou = np.array([
        intersection[i] / union[i] if union[i] > 0 else np.nan
        for i in range(len(intersection))
    ])
    return iou
```
