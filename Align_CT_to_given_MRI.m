%% 0. INSTALLATION INFO
% Had to download SPM12 in order to execute this code (SPM 12): https://www.fil.ion.ucl.ac.uk/spm/software/download/
% https://en.wikibooks.org/wiki/SPM/Installation_on_64bit_Mac_OS_(Intel)

%% 1. ENTER FILE INFO FOR THE CT AND MRI
img_dir = '/Users/Sandon/Library/CloudStorage/Box-Box/Data/NHP_Imaging'; 
subid = 'Butters';%;'Haribo'; % animal name
ct_path = [img_dir filesep 'Butters/CT/Post-Op/MMU40402_Head_CT_10May2023/Z01']; 
% for the CT, use the path to one of the DICOM files in the folder
% containing all of the DICOMs for that CT (any single DICOM will work)


%% 2. LOAD MRI AND CT (do not edit)
aw_dir = [img_dir filesep subid filesep 'AFNI' filesep 'AnimalWarperOut' filesep];
mri_path = [aw_dir subid '_anat.nii.gz'];
mri_acpc = ft_read_mri(mri_path);
ct = ft_read_mri(ct_path);

%% 3. DETERMINE CT LEFT AND RIGHT
% Note: What axis is represented by left and right? Is right + or – on that
% axis?
ft_determine_coordsys(ct); 

% once you have noted the above, you can just close the figure

%% 4. CROP AND RESLICE THE CT SO THAT IT COVERS A SIMILAR SPACE AS THE MRI
% plot the high res scan to determine the range to crop
ft_sourceplot([], ct);

% Enter the coordinates where you want to crop (the goal is to crop it as
% similarly to the MRI as possible)
cfg = [];
cfg.method      = 'nearest';
cfg.xrange      = input('Enter the minimum and maximum X (left --> right) headspace coordinate in the form [min max]: \n');
cfg.yrange      = input('Enter the minimum and maximum Y (posterior --> anterior) headspace coordinate in the form [min max]: \n');
cfg.zrange      = input('Enter the minimum and maximum Z (inferior --> superior) headspace coordinate in the form [min max]: \n');

ct_crop = ft_volumereslice(cfg, ct);

% close the figure you used to determine the cropping dimensions
close;
% plot the cropped CT to make sure it looks as you intended
ft_sourceplot([], ct_crop);

%% 5. ALIGN CT TO ACPC COORDINATES, WHICH IS THE SYSTEM THE MRI FILE IS USING
% the AC point will be the origin (in headpsace coords) so it should be as close to the origin of
% the MRI as possible

% plot the MRI so you can note the approximate position of the origin and
% the X and Y axes
ft_sourceplot([], mri_acpc);

% select the fiducials in the CT scan
cfg = [];
cfg.method      = 'interactive';
cfg.coordsys    = 'acpc';
ct_acpc = ft_volumerealign(cfg, ct_crop);

% iMPORTANT: When selecting coordinates
% 1. AC should be at the same point where the origin in the MRI is
% 2. PC should be selected such that if you drew a line from AC --> PC you
% would be moving negatively in the anterior-posterior axis, as defined by
% the anterior-posterior axis in the MRI
% 3. XZ point should be selected such that if you drew a line from AC -->
% XZ you would be moving positively in the inferior-superior axis, as
% defined by the inferior-superior axis in the MRI
% 4. Right point can be any point on the right side of the brain

% plot the MRI so you can note the approximate position of the origin
ft_sourceplot([], ct_acpc);

%% 5 (ALTERNATIVE). ALIGN CT TO CTF COORDINATES AND THEN CONVERT TO ACPC COORDINATES
% Theoretically, this is easier because you can actually see the CTF
% fiducials on a CT (unlike the ACPC coordinates). But sometimes this
% method gives errors during the coordinate conversion step
cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'ctf';
ct_ctf = ft_volumerealign(cfg, ct);

% Automatically convert CT into acpc: 
ct_acpc = ft_convert_coordsys(ct_ctf, 'acpc');

%% 6. FUSE MRI AND CT
cfg = [];
cfg.method = 'spm';
cfg.spmversion = 'spm12';
cfg.coordsys = 'acpc';
cfg.viewresult = 'yes';
ct_acpc_f = ft_volumerealign(cfg, ct_acpc, mri_acpc);

% if the results are bad, repeat step 5 to realign the CT as close as
% possible to the MRI

%% SAVE THE REALIGNMENT RESULT AND THE FUSED SCAN
savefig([img_dir filesep subid filesep subid '_CT_fusionToMRI_results']);

cfg_sv = [];
cfg_sv.filename   = [img_dir filesep subid filesep subid '_CT_fusedToAFNIAW_anat'];
cfg_sv.filetype   = 'nifti';
cfg_sv.parameter  = 'anatomy';
cfg_sv.datatype   = 'int32';
ft_volumewrite(cfg_sv, ct_acpc_f);




