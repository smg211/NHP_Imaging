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
subid = 'Fifi'; % animal name
scan_dir = 'CT'; % name of folder where the raw DICOM files are located
img_pref = 'CT_head_crop_acpc_fused'; % prefix of the scan you want to make a mask for
thresh = [700 10000000000]; % minimum and maximum intensity value, anything between this will = 1. use a slice viewer (e.g., freeview) to determine this
sm_iter = []; % int, number of smoothing iterations (higher number = more smooth, [] = skip smoothing)
do_run_afni_in_matlab = false; % T/F 
% true: export the AFNI portion of the pipeline to terminal within
% matlab (note: this will make matlab unusable while the AFNI portion of
% the pipeline runs)
% false: print the lines in the matlab command window that should be run in
% a separate shell terminal

if isempty(sm_iter)
  sm_iter = 100;
end

%% CREATE SURFACE DIRECTORY FOR OUTPUT
subsurfdir = [img_dir filesep subid filesep scan_dir filesep 'Surfaces'];
if exist(subsurfdir) ~= 7
  mkdir(subsurfdir);
end

%% CREATE A MASK OF VOXELS WITHIN A CERTAIN INTENSITY WINDOW FOR A SPECIFIC 
% SCAN (E.G., an MRV), THEN MAKE A SURFACE FROM THAT MASK, AND PLOT IT OVER
% TOP OF THE CORTEX
preproc_dir = [img_dir filesep subid filesep scan_dir filesep 'ScansPreproc'];
if exist(preproc_dir) ~= 7
  mkdir(preproc_dir);
end

% load the scan you want to window
img_thresh = ft_read_mri([preproc_dir filesep img_pref '.nii']);
img_thresh.coordsys = 'acpc';

% create the mask
img_thresh.mask = img_thresh.anatomy > thresh(1) & img_thresh.anatomy < thresh(2);

% save the mask
cfg = [];
cfg.filename    = [preproc_dir filesep img_pref '_thresh.nii'];
cfg.filetype    = 'nifti';
cfg.parameter   = 'mask';
cfg.datatype    = 'int32';
ft_volumewrite(cfg, img_thresh);

% Open in some slice viewer (e.g., FreeView) to make sure your mask looks right

% % Convert the mask to a surface using AFNI's IsoSurface function
% line1 = ['IsoSurface -input ' preproc_dir filesep img_pref '_thresh.nii ' ...
%   '-isoval 1 ' ...
%   '-Tsmooth 0.1 ' sm_iter ' ' ...
%   '-o_gii ' subsurfdir filesep img_pref '_thresh_surf.gii'];
% if do_run_afni_in_matlab
%   system(line1)
% else
%   line1
%   fprintf('Copy-paste the above line in a separate terminal before continuing to the next step\n');
% end

%% LOAD AND PLOT THE RESULTING SURFACE
% % Load the surface that you made with AFNI
% thresh_surf = ft_read_headshape([subsurfdir filesep img_pref '_thresh_surf.gii'], ...
%   'format', 'gifti', 'coordsys', 'acpc', 'unit', 'mm');

% This code will convert the mask to a surface using fieldtrip, which uses
% the Iso2Mesh toolbox under the hood. It only works well when the mask is
% one continuous structure, so it can help to crop out continuous
% thresholded areas that are larger than the area that you want to create
% the surface for
cfg = [];
cfg.method = 'iso2mesh';
cfg.radbound = 2;
cfg.maxsurf = 0;
cfg.tissue = 'mask';
cfg.numvertices = 1000000;
cfg.smooth = 1;
mask_surf = ft_prepare_mesh(cfg, img_thresh);

% Plot the surface on top of the cortex
cfg = [];
cfg.facecolor     = {'skin'};
cfg.facealpha     = 1;
cfg.fig_size      = [1 1];
plot_mesh_follow_me(cfg, mask_surf);

% Save the figure
% savefig([subsurfdir filesep 'cortex_overlaid with__' img_pref '.fig']);

ft_write_headshape([subsurfdir filesep img_pref '_thresh_head_surf.stl'], mask_surf, 'format', 'stl', 'unit', 'mm');
ft_write_headshape([subsurfdir filesep img_pref '_thresh_head_surf.gii'], mask_surf, 'format', 'gifti', 'unit', 'mm');





