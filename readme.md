## Welcome! 
This is a two-part document that applies to the main two parts of this repository. 

Part I applies to the FieldTrip- and AFNI-based pipeline for volume-based registration of NHP MRIs to a template MRI, segmentation and parcellation of T1 MRIs according to atlases, creation of ROI surfaces (triangulated meshes) in native subject space, and conversion of MRI voxels within an intensity range to surfaces (e.g., for overlaying veins and/or arteries on the cortex).

Part II applies to a GUI that is used for registration of a stereotaxic surgical space to a specific NHP's MRI using skin (or any) fiducials that are visible in the MRI and can be measured in stereotaxic surgical space. This GUI's method is still in development, and is heavily based on work from the following publication: "Bentley JN, Khalsa SS, Kobylarek M, Schroeder KE, Chen K, Bergin IL, Tat DM, Chestek CA, Patil PG. A simple, inexpensive method for subcortical stereotactic targeting in nonhuman primates. Journal of Neuroscience Methods. 2018 Jul 15;305:89-97"

A typical surgery prep will consist of running T1 MRIs through the pipeline in Part I and using the surfaces to identify points of interest (e.g. brain regions) to expose or target with electrodes during the surgical procedure. In part II, these points of interest can be marked in MRI space, and transformed to stereotax space for more accurate targeting. 

## Part I: The functions and scripts addressed in Part I are: 
- AFNI_PreProc_Prep.m
- AFNI_PreProc.m
- AFNI_Surfaces_PostProc.m
- Voxel_to_Surface.m
- plot_mesh_follow_me.m

## Part I: Requirements:
- FieldTrip (Matlab toolbox): https://www.fieldtriptoolbox.org/
- Analysis of Functional NeuroImages (AFNI): https://afni.nimh.nih.gov/
- Recommended: FreeView (part of FreeSurfer): https://surfer.nmr.mgh.harvard.edu/

## Part I: This pipeline is currently set up to use AFNI's templates and atlases
- Template: NMT v2.0
- Cortical Atlas: Cortical Hierarchical Atlas for Rhesus Macaques (CHARM)
- Subcortical Atlas: Subcortical Atlas for Rhesus Macaques (SARM)
For more info: https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/nonhuman/macaque_tempatl/main_toc.html

## Part I: Step-by-Step Instructions
Each script is structured to ask you to enter the relevant parameters in the first section, and then the rest of the script is automated. 

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

#### Questions on Part I? sandon.griffin@ucsf.edu


## Part II: Requirements
Software: 
- Slicer3D (free surface viewer) : https://www.slicer.org/
- FieldTrip (Matlab toolbox): https://www.fieldtriptoolbox.org/

MRI requirements: 
- You'll need to make sure you have your T1 MRI in an .nii format (can be done in the early steps of AFNI_PreProc.m) 
- You'll also need to make sure that you have fiducials in your MRI that you'll be able to measure at the time of your surgery
- Our approach has been to place these circular "donut" fiducials (https://izimed.com/products/multi-modality-fiducial-markers) on and around the animals' shaved head prior to the MRI, while the animal is in a stereotax. Then, after the scan is complete and while the animal is still in the steretax, the center of each fiducial is permanently marked on the animals' skin with a tattooing needle. Other examples of fiducials are given in the studies below. The effect of fiducial placement on targeting error is well-covered in the Bentley study. Another consideration re. fiducial placement is making sure you'll actually be able to measure your fiducials in the OR with the tools you're planning on using.  We used a micromanipulator which only had a certain amount of medial-lateral travel, preventing us from accessing very lateral fiducials as well as fiducials on the opposite hemisphere. 

- - Bentley JN, Khalsa SS, Kobylarek M, Schroeder KE, Chen K, Bergin IL, Tat DM, Chestek CA, Patil PG. A simple, inexpensive method for subcortical stereotactic targeting in nonhuman primates. Journal of Neuroscience Methods. 2018 Jul 15;305:89-97
- - Glud, A.N., Bech, J., Tvilling, L., Zaer, H., Orlowski, D., Fitting, L.M., Ziedler, D., Geneser, M., Sangill, R., Alstrup, A.K.O., et al. (2017). A fiducial skull marker for precise MRI-based stereotaxic surgery in large animal models. Journal of Neuroscience Methods 285, 45–48. https://doi.org/10.1016/j.jneumeth.2017.04.017.
- - Ohayon, S., and Tsao, D.Y. (2012). MR-guided stereotactic navigation. Journal of Neuroscience Methods 204, 389–397. https://doi.org/10.1016/j.jneumeth.2011.11.031.



## Part II: The functions and scripts addressed in Part II are: 
- Fiducial_GUI.m and Fiducial_GUI.fig

## Part II: Step-by-Step Instructions 
### Step 0: Setup paths and Launch the GUI
If you haven't already added the directory and subdirectories to the NHP_imaging repo, do so now ("addpath(genpath('path to NHP_imaging repo'))"). Then launch the Fiducial GUI by executing "Fiducial_GUI"

### Step 1: Create a numbering convention for your fiducials
In this methodology you are going to mark fiducial points on your MRI, and then measure the same points using a micromanipulator. To keep track of which point is which, you'll want to come up with a numbering system where you assign each fiducial a number. I usually do this in Slicer3D by thresholding the MRI to see all the fiducials, taking a few screenshots, and then labeling the fiducials. See the video "Create_fiducial_numbering.mp4" to see this in more detail. Doing this step in Slicer3D will also help with step 2. 

### Step 2: Load the MRI
Click the "Load MRI" button on the top left of the GUI. Navigate to wherever your ".nii" file is and select it. Note that the axes ("coronal", "sag", "axial") all assume you've followed the full set of Part I steps outlined above. 

### Step 3: Identify fiducials and points of interest
Once the MRI is loaded, you can navigate around using the sliders above each axis, or by directly entering values into the ML, AP, or DV text entry boxes. Now your job is to identify the precise points of the fiducials. I like to do this using Slicer3D, and then do fine adjustments in the GUI. See the "MRI_navigation_and_fiducial_entry.mp4" video for how I do this. A few tips: 
- Use the shift + click to drag around the cross hairs in Slicer 3D. This makes it easy to align the crosshairs with a specific fiducial in the 3D model and then make all the slices align to the cross hair. You can then just read out the ML/AP/DV values from the slices and enter them into the GUI. I usually do fine adjustments in the GUI after this. 
- When you are satisfied with the position of a fiducial in the GUI, type "f_#" where "#" is the fiducial number into the text box and click the (+) button. If you'd like to change a fiducial's location you can select it and click the (-) button and it will be removed. 
- If the list of fiducials gets grayed out (ListBox error) just add a fiducial a few times (+) and then subtract it (-) to fix the box. 
- To identify points of interest (i.e. anything thats not a fiducial that you'd like to transform into stereotax space like a deep brain target), add that point with the prefix "t_" (t is for "target", f is for "fiducial"). 

### Step 4: Save out your fiducials 
- Once you are happy with your fiducials and targets list, click "save fiducials". These will then get saved in the same folder as your MRI for accessibility later. 

### Step 5: Planning for the OR
In the OR, the general steps are to 1) measure the fiducials and enter them into the GUI, 2) transform your points of interest to stereotaxic coordinate space using the GUI, and 3) design an approach to your points of interest if relevant (e.g. for deep brain structures). You need to think through sterility and timing and what tool you use to measure the skin vs mark the skull vs insert electrodes. Since we used skin fiducials we needed to measure the skin marks using an instrument and micromanipulator that could remain non-sterile, and do it before the first incision (after incision skin fiducials are useless). If you use skull fidiucials you can use the same tool to measure and then mark / target your points. This is attractive since changing instruments used to measure the tools is potentially a large source of variability. If you are using this approach to insert electrodes, you'll want to make sure that the tool you use to insert the electrodes can also be used to measure and that you use the tool in the same geometry each time. 

An example protocol: 
- Use micromanipulator A (non-sterile) to measure skin fiducials while animal is in the stereotax but before sterile field is prepped 
- After incision / craniotomy, use micromanipulator B (sterile) with electrode holder to insert electrodes to deep brain targets. 
- Ahead of time, need to know the transform between MMA with measuring tool and MMB with electrode insertion tool. 
- Then need to sterilize MMB and insertion tool

Tip: 
- Practice reading ML/AP/DV coordinates off your micromanipulator ahead of time. On the stereotax arms, know where AP transitions from + to negative. 
- For debugging, its helpful to make a dummy skin fiducials file. You can do this using the "helpers/make_noisy_fiducials_for_testing.m" file. Its only input is a noise value, and it will ask you for a fiducials file. It will then save a dummy skin fiducials file in that same directory using the stereotax name "test"

### Step 6: Measuring skin fiducials
Using the same fiducial numbering system as above, enter micromanipulator measurements for each fiducial. As outlined in the Bentley paper, your stereotax coordinate system must be the same "handedness" as your MRI coordinate system. If you follow Part I, your MRI will be in "RAS" meaning the coordinates will be ML (increasing going Right), AP (increasing going Anterior), and DV (increasing going Superior). If you place your micromanipulator on the right arm of the stereotax you should be able to reach off coordinates as they are. If you place your micromanipulator on the left arm, you'll need to keep the ML coordinates negative. This is because micromanipulators have low numbers for medial coordinates and high numbers for lateral coordinates. This is fine for the right arm where lateral coordinates are Right of medial coordinates, but for the left arm, this coordinate system could constitute a change in handedness. Making all ML coordinates when the micromanipulator is on the left arm fixes this. 

Procedure to enter fiducials in the GUI: 
- Same as the fiducial entry procedure above
- Not all fiducials need to be measured -- only the ones that are measured will be used to fit the transform

Tips: 
- Some micromanipulators come with an AP adjustment block ("AP_blk") in addtion to the AP coordinate read off of the base of the micromanipulator. If there's no AP block, just enter "0" there. The AP_blk and AP measurement just get added together in the code. 

### Step 7: Fit and test the transform
Once all the fiducials have been measured, use the "transform fid to stx" button to fit the MRI to stereotax transform. Use the "Calc TRE" button to illustrate the errors in the fiducials. There will be two plots -- one that illustrates the discrepancy between the measured fiducial points (red) and what their predicted position is (in black) based on the transform. On the right you'll also see a bar plot with the errors in the ML/AP/DV dimensions. Because these datapoints are the ones used to fit the transform, the avg. error should be around 0mm. The variance may vary though. The second plot is the one demonstrating the 'target registration error' in different points in stereotaxic space, and is based on the error in the fiducials. See Bentley et. al. for a more detailed description of TRE. See "Transform_fid_to_stx" video for more information. 

Tips: 
- If a particular fiducial looks particularly erroneous based on these plots, you can re-measure it. Remove the point using the (-) sign from the fiducial GUI and re-enter it. You can also then re-save the new measured fiducials (will save with a new timestamp, so you dont need to worry about over-writting)
- Make sure to select the correct micromanipulator from the drop-down menu prior to entering fiducial measurements. These can be edited by opening up the matlab fig file (Fiducial_GUI.fig) and directly editing the options for the dropdown. 

### Step 8: Electrode targeting to deep strutures. 
See the "Plan electrode insertion" video. Briefly, you design an electrode track that is a straight down 0 degree insertion in stereotax space. This may end up looking angled in MRI space. Once the track is plotted, you can navigate in the MRI and mark your insertion point. Then you can transform this insertion point to stereotax space. 

### Step 9: Prep to transform from skin stereotax space 1 --> brain stereotax space 2
If you're using skin fiducials and need to measure them using a different tool than the one you want to use to mark insertion points or skull points (i.e. due to sterility reasons), there's a final transform you'll need to do in order to transform points from the "skin/non-sterile" stereotax space to the "brain/sterile" stereotax space. To set this up there are a few steps required. Also see "stx to stx conversion" video: 

- name your tools (I labeled micromanipulators as A/B/C, then labled the tools attached to the micromanipulators as "meas" for measuring tool, "edge" for Edge electrode inserter, and "DBS" for DBS electrode inserter)
- change the dropdown menus to reflect these names. Since I was only ever going to measure with "meas" I used MMA_meas as my main measuring tool. Note you'll also need to list which arm of of the stereotax the micromanipulator is on since mounting it to the left vs. right create different coordinate systems (hence MMA_right_meas, MMA_left_meas). 
- perform an experiment where you measure a few common points using the different micromanipulator and tool combinations. I write down the ML / AP / DV coordinates of each micromanipultor-tool combo for each point in a matlab file called stx_conversion.m saved for each animal / MRI. This file then saves out a .mat file that needs to be loaded when you do a stx-->stx conversion. 
- See an example of a stx_conversion.m file and stx_conversion.mat file in "helpers/example_stx_conversion"

### Step 10: Measuring cortical landmarks or others
Once youve transformed your points of interest into the desired micromanipulator+tool space, you can write down measurements, save them, and plot them by clicking the "open data entry" button on the bottom right of the GUI. Here you'll see your transformed stereotax points and you can edit the right columns. At the top you'll find save and plot buttons. See the "stx to stx conversion" video for more details. 

### Other features: 
See the "other features" video for more details: 
- Left panel: 
- compute distance button
- go to fiducial button
- clim max button

- Right panel: 
- Show 3D surfaces button
- Add 3D electrode tracts


- Middle panel: 
- Save all

#### Questions on Part II? preeya.khanna@ucsf.edu or pkhanna@berkeley.edu





