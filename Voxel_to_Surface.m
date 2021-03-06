%% Takes a volume (e.g., MRV) as input, identifies voxels within a specified intensity
% range (e.g., the range of veins in the MRV), creates a surface of those
% voxels, and plots it overlaid on the cortical surface
%
% Additionally, you can filter the voxels included in the surface so that
% only those that are within or close to the brain are included. This is
% helpful when the intensity range of the structures you are trying to
% create a surface of also include artifacts that lie outside the brain

%% ENTER SETTINGS
clear all
img_dir = '/Users/Sandon/Box/Data/NHP_Imaging'; % path to NHP imaging data
subid = 'Haribo'; % animal name
scan_dir = 'ds_2021-08-26_10-07'; % name of folder where the raw DICOM files are located
img_pref = '009_tof_fl3d_tra_p2_multi-slab'; % prefix of the scan you want to make a mask for
thresh = [600000000 10000000000]; % minimum and maximum intensity value, anything between this will = 1. use a slice viewer (e.g., freeview) to determine this
sm_iter = 100; % int, number of smoothing iterations (higher number = more smooth, [] = skip smoothing)
expansion_factor = 1.05; % scalar, multiplicative factor for expanding the brainmask 
% (1.00 = only voxels within the brain will be kept. As this scalar
% increases, voxels farther from the brain will be kept.)
do_run_afni_in_matlab = false; % T/F 
% true: export the AFNI portion of the pipeline to terminal within
% matlab (note: this will make matlab unusable while the AFNI portion of
% the pipeline runs)
% false: print the lines in the matlab command window that should be run in
% a separate shell terminal

%% CREATE A MASK OF VOXELS WITHIN A CERTAIN INTENSITY WINDOW FOR A SPECIFIC 
% SCAN (E.G., an MRV), THEN MAKE A SURFACE FROM THAT MASK, AND PLOT IT OVER
% TOP OF THE CORTEX

% Get directory names again in case you want to start here
afni_dir = [img_dir filesep subid filesep 'AFNI'];
preproc_dir = [afni_dir filesep 'ScansPreproc'];
aw_dir = [afni_dir filesep 'AnimalWarperOut'];
subsurfdir = [afni_dir filesep 'Surfaces'];

% load the scan you want to window
img_thresh = ft_read_mri([preproc_dir filesep img_pref '_nmt2_reslice_shft.nii']);
img_thresh.coordsys = 'acpc';

% create the mask
img_thresh.mask = img_thresh.anatomy > thresh(1) & img_thresh.anatomy < thresh(2);

% save the mask
cfg = [];
cfg.filename    = [preproc_dir filesep img_pref '_nmt2_reslice_shft_thresh.nii'];
cfg.filetype    = 'nifti';
cfg.parameter   = 'mask';
cfg.datatype    = 'int32';
ft_volumewrite(cfg, img_thresh);

% Open in some slice viewer (e.g., FreeView) to make sure your mask looks right

% Convert the mask to a surface using AFNI's IsoSurface function
line1 = ['IsoSurface -input ' preproc_dir filesep img_pref '_nmt2_reslice_shft_thresh.nii ' ...
  '-isoval 1 ' ...
  '-Tsmooth 0.1 100 ' ...
  '-o_gii ' subsurfdir filesep img_pref '_nmt2_reslice_shft_thresh_surf.gii'];
if do_run_afni_in_matlab
  system(line1)
else
  line1
  fprintf('Copy-paste the above line in a separate terminal before continuing to the next step\n');
end

%% LOAD, SMOOTH, AND PLOT THE RESULTING SURFACE
% Load the surface that you made with AFNI
thresh_surf = ft_read_headshape([subsurfdir filesep img_pref '_nmt2_reslice_shft_thresh_surf.gii'], ...
  'format', 'gifti', 'coordsys', 'acpc', 'unit', 'mm');

% This code will convert the mask to a surface using fieldtrip, which uses
% the Iso2Mesh toolbox under the hood. It only works well when the mask is
% one continuous structure, so it can help to crop out continuous
% thresholded areas that are larger than the area that you want to create
% the surface for
% cfg = [];
% cfg.method = 'iso2mesh';
% cfg.radbound = 2;
% cfg.maxsurf = 0;
% cfg.tissue = 'mask';
% cfg.numvertices = 1000000;
% cfg.smooth = 1;
% mask_surf = ft_prepare_mesh(cfg, img_thresh);

% Smooth the surface of the thresholded scan
thresh_surf_sm = thresh_surf;
if ~isempty(sm_iter)
  [thresh_surf_sm.pos, thresh_surf_sm.tri] = fairsurface(thresh_surf_sm.pos, thresh_surf_sm.tri, sm_iter);

  % save the smoothed surface
  ft_write_headshape([subsurfdir filesep img_pref '_nmt2_reslice_shft_thresh_surf_sm.gii'], thresh_surf_sm, 'format', 'gifti', 'unit', thresh_surf_sm.unit);
end

% Load the cortical mesh
cortex = ft_read_headshape([subsurfdir filesep 'cortex.gii'], 'format', 'gifti', 'coordsys', 'acpc', 'unit', 'mm');

% Plot the surface on top of the cortex
cfg = [];
cfg.facecolor     = {'skin', 'cyan'};
cfg.facealpha     = [0.3 1];
cfg.fig_size      = [1 1];
plot_mesh_follow_me(cfg, {cortex, thresh_surf_sm});

% Save the figure
savefig([subsurfdir filesep 'cortex_overlaid with__' img_pref '.fig']);

%% FILTER THE MASK USING ANOTHER MASK (I.E, EXPANDED BRAIN MASK) TO GET RID OF 
% VOXELS THAT WERE INCLUDED BUT ARE FAR FROM THE BRAIN (E.G., IN THE SKULL)

% Load the brain mask
mask = ft_read_mri([aw_dir filesep subid '_anat_mask.nii.gz']);

% Expand the brainmask by a user-defined factor
mask_blowup = mask;
mask_blowup.transform(1,1) = mask_blowup.transform(1,1)*expansion_factor;
mask_blowup.transform(2,2) = mask_blowup.transform(2,2)*expansion_factor;
mask_blowup.transform(3,3) = mask_blowup.transform(3,3)*expansion_factor;
mask_blowup.hdr.xsize = mask_blowup.hdr.xsize*expansion_factor;
mask_blowup.hdr.ysize = mask_blowup.hdr.ysize*expansion_factor;
mask_blowup.hdr.zsize = mask_blowup.hdr.zsize*expansion_factor;
mask_blowup.transform(1:3, 4) = mask_blowup.transform(1:3, 4).*expansion_factor;

% Save the expanded mask
cfg = [];
cfg.filename  = [preproc_dir filesep subid '_anat_mask_blowup.nii'];
cfg.filetype  = 'nifti';
cfg.parameter = 'anatomy';
cfg.datatype  = 'int32';
ft_volumewrite(cfg, mask_blowup);

% first get the head coordinates of the edges of the original mask for the
% next step
corner1 = ft_warp_apply(mask.transform, [1 1 1]);
corner2 = ft_warp_apply(mask.transform, mask.dim);

% Reslice the blown up mask so that the blown up voxels map onto the native
% space voxels
cfg = [];
cfg.method      = 'nearest';
cfg.resolution  = 0.3;
cfg.xrange      = [corner2(1) corner1(1)];
cfg.yrange      = [corner2(2) corner1(2)];
cfg.zrange      = [corner1(3) corner2(3)];
mask_blowup_reslice = ft_volumereslice(cfg, mask_blowup);

% Save the resliced expanded mask
cfg = [];
cfg.filename    = [preproc_dir filesep subid '_anat_mask_blowup_reslice.nii'];
cfg.filetype    = 'nifti';
cfg.parameter   = 'anatomy';
cfg.datatype    = 'int32';
ft_volumewrite(cfg, mask_blowup_reslice);

% Apply the mask to the thresholded scan so that any voxels outside of the
% mask become zeros
img_thresh_mask = ft_read_mri([preproc_dir filesep img_pref '_nmt2_reslice_shft_thresh.nii']);
img_thresh_mask.mask = img_thresh_mask.anatomy;
img_thresh_mask.mask(mask_blowup_reslice.anatomy == 0) = 0;

% Save the masked thresholded scan
cfg = [];
cfg.filename    = [preproc_dir filesep img_pref '_nmt2_reslice_shft_thresh_mask.nii'];
cfg.filetype    = 'nifti';
cfg.parameter   = 'mask';
cfg.datatype    = 'int32';
ft_volumewrite(cfg, img_thresh_mask);

% Convert the mask to a surface using AFNI's IsoSurface function
line1 = ['IsoSurface -input ' preproc_dir filesep img_pref '_nmt2_reslice_shft_thresh_mask.nii ' ...
  '-isoval 1 ' ...
  '-Tsmooth 0.1 100 ' ...
  '-o_gii ' subsurfdir filesep img_pref '_nmt2_reslice_shft_thresh_mask_surf.gii'];
if do_run_afni_in_matlab
  system(line1)
else
  line1
  fprintf('Copy-paste the above line in a separate terminal before continuing to the next step\n');
end

%% LOAD, SMOOTH, AND PLOT THE RESULTING SURFACE
thresh_mask_surf = ft_read_headshape([subsurfdir filesep img_pref '_nmt2_reslice_shft_thresh_mask_surf.gii'], ...
  'format', 'gifti', 'coordsys', 'acpc', 'unit', 'mm');

% Smooth the surface of the thresholded scan
thresh_mask_surf_sm = thresh_mask_surf;
if ~isempty(sm_iter)
  [thresh_mask_surf_sm.pos, thresh_mask_surf_sm.tri] = fairsurface(thresh_mask_surf_sm.pos, thresh_mask_surf_sm.tri, sm_iter);
  
  % save the smoothed surface
  ft_write_headshape([subsurfdir filesep img_pref '_nmt2_reslice_shft_thresh_mask_surf_sm.gii'], thresh_mask_surf_sm, 'format', 'gifti', 'unit', thresh_mask_surf_sm.unit);
end

% Plot the surface on top of the cortex
cfg = [];
cfg.facecolor   = {'skin', 'cyan'};
cfg.facealpha   = [0.3 1];
cfg.fig_size    = [1 1];
plot_mesh_follow_me(cfg, {cortex, thresh_mask_surf});

% Save the figure
savefig([subsurfdir filesep 'cortex_overlaid with__' img_pref '_brainmask.fig']);
