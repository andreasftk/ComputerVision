## ECC vs Lucas–Kanade Image Alignment

This project focuses on **parametric image alignment** using two classical optimization-based registration methods:

- The **Enhanced Correlation Coefficient (ECC)** algorithm [[1]](https://inria.hal.science/hal-00864385v1/document) [[3]](https://www.mathworks.com/matlabcentral/fileexchange/27253-ecc-image-alignment-algorithm-image-registration)
- The **Lucas–Kanade (LK)** algorithm [[2]](https://www.ri.cmu.edu/pub_files/pub3/lucas_bruce_d_1981_1/lucas_bruce_d_1981_1.pdf)

Both methods are evaluated using the provided MATLAB implementation (`ecc_lk_alignment`) on synthetic video sequences with **affine motion** and two different spatial resolutions (**64×64** and **256×256** pixels).

### Experimental Setup

- **Motion model:** 2D affine transformation (translation, rotation, scaling, shear).
- **Algorithms:** ECC-based alignment vs. gradient-based LK alignment.
- **Multi-resolution scheme:** Experiments with different numbers of **pyramid levels**.
- **Optimization settings:** Systematic variation of the **maximum number of iterations** per level.
- **Evaluation metrics:**
  - **Peak Signal-to-Noise Ratio (PSNR)** between the aligned frame and the ground-truth reference.
  - **Mean Squared Error (MSE)** for quantitative reconstruction error.

In addition to the baseline clean sequences, robustness is investigated under:

- **Photometric distortions:** global brightness and contrast changes between reference and target frames.
- **Additive noise:** Gaussian and uniform noise with different noise levels.

### Main Findings

- The **ECC algorithm** converges more reliably and typically achieves **higher PSNR and lower MSE** than the Lucas–Kanade method, especially:
  - When using **multi-level pyramids**, and
  - Under **photometric distortions** and moderate noise.
- The **LK algorithm** performs well when the photometric model is close to ideal and displacements are small, but is more sensitive to illumination changes and noise.
- Increasing the number of pyramid levels and iterations generally improves alignment quality up to a point, after which gains saturate.

Overall, Part (a) demonstrates the advantages of ECC-based alignment over classical LK in terms of robustness to real-world imaging conditions, while also highlighting the impact of multi-scale optimization and parameter choices on registration performance.

### References

[1] G. D. Evangelidis and E. Z. Psarakis, “Parametric Image Alignment Using Enhanced Correlation Coefficient Maximization,” *IEEE Transactions on Pattern Analysis and Machine Intelligence*, vol. 30, no. 10, pp. 1858–1865, 2008.

[2] B. D. Lucas and T. Kanade, “An Iterative Image Registration Technique with an Application to Stereo Vision,” in *Proceedings of the 7th International Joint Conference on Artificial Intelligence (IJCAI ’81)*, pp. 674–679, 1981.

[3] G. Evangelidis, “ECC image alignment algorithm (image registration),” MATLAB Central File Exchange, 2017. Available: https://www.mathworks.com/matlabcentral/fileexchange/27253-ecc-image-alignment-algorithm-image-registration
