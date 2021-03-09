# MRI_US_FusionAndAffineRegistration

This code introduces a joint fusion and affine registration method for magnetic resonance (MR)  and ultrasound (US) images. Fusion allows complementary information from these two modalities to be captured, i.e., the good spatial resolution of the US images and the good signal-to-noise ratio and contrast of MR images. However, fusion requires images to be registered, which is generally a complicated task in practical applications. The proposed MR/US image fusion performs joint super-resolution of the MR image and despeckling of the US image, and is able to automatically account for registration errors. A polynomial function is used to link US and MR images in the fusion process while an appropriate similarity measure is introduced to handle the registration problem. The proposed registration is based on a global affine transformation. The fusion and registration operations are performed alternatively simplifying the underlying optimization problem.

How to run this code: Edit and run the demo script. In image folder, you can find two simulated images MRI and US images

This code is in development stage, thus any comments or bug reports are very welcome.
