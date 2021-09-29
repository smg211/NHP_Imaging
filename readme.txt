Welcome! These instructions apply to the FieldTrip- and AFNI-based pipeline for volume-based registration of NHP MRIs to a template MRI, segmentation and parcellation of T1 MRIs according to atlases, creation of ROI surfaces (triangulated meshes) in native subject space, and conversion of MRI voxels within an intensity range to surfaces (e.g., for overlaying veins and/or arteries on the cortex).

### The functions and scripts addressed in this document are:
- AFNI_PreProc_Prep.m
- AFNI_PreProc.m
- AFNI_Surfaces_PostProc.m
- Voxel_to_Surface.m
- plot_mesh_follow_me.m

### Requirements:
- FieldTrip (Matlab toolbox): https://www.fieldtriptoolbox.org/
- Analysis of Functional NeuroImages (AFNI): https://afni.nimh.nih.gov/
- Recommended: FreeView (part of FreeSurfer): https://surfer.nmr.mgh.harvard.edu/

Each script is structured to ask you to enter the relevant parameters in the first section, and then the rest of the script is automated. 

## Step-by-Step Instructions
### Step 0 (see note): AFNI_PreProc_Prep.m
This script creates .mat files for the keys for each AFNI atlas AND sets the ACPC fiducials on the template scan. 

NOTE: ONLY RUN THIS SCRIPT IF YOU ARE TRYING TO USE A NEW ATLAS (OTHER THAN CHARM OR SARM) OR A NEW TEMPLATE MRI. The necessary outputs from this script for the CHARM and SARM atlas (based on the NMT v2.0 template) are already in this repo.

### Step 1 (required): AFNI_PreProc.m
This script preprocesses all of the scans to ensure that they are in the same space (coordinates aligned), crops them, and does an affine transformation to align their origins with the origin of the template used by @animal_warper, which helps with the volume-based registration

This script involves some interaction with FieldTrip GUI's for alignment in the beginning. For help with those steps, see the videos in this repo:
- Determining_Left_Right_Orientation_with_ft_determine_coordsys.mp4
- Aligning_MRI_to_RAS_Orientation_with_ft_volumerealign.mp4

### Step 2 (optional): AFNI_Surfaces_PostProc.m
This script loads all of the afni surfaces, optionally smoothes them, and creates plots of all of the ROIs at each level of each atlas, including separate plots for the legends

### Step 3 (optional): Voxel_to_Surface.m
This script takes a volume (e.g., MRV) as input, identifies voxels within a specified intensity range (e.g., the range of veins in the MRV), creates a surface of those voxels, and plots it overlaid on the cortical surface

Additionally, you can filter the voxels included in the surface so that only those that are within or close to the brain are included. This is helpful when the intensity range of the structures you are trying to create a surface of also include artifacts that lie outside the brain

Note: before running this script, you will need to explore the intensity values of the volume of interest in order to identify the intensity range that you want to include in your mesh. FreeView can be used for this purpose, but most MRI viewers have a similar ability to identify voxel intensity values



#### Questions? sandon.griffin@ucsf.edu






