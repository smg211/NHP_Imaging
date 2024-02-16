% Fully automated pipeline for preprocessing scans before running
% AFNI's @Animal-warper

%% ENTER SETTINGS
clear all
img_dir = '/Users/Sandon/Library/CloudStorage/Box-Box/Data/NHP_Imaging'; 
subid = 'Haribo'; % animal name
scan_dir = 'ds_2021-08-26_10-07'; % name of folder where the raw DICOM files are located
min_slices2convert = 40; % minimum number of files in an imaging directory in order to trigger aconversion to nifti
do_run_afni_in_matlab = false; % T/F 
% true: export the AFNI portion of the pipeline to terminal within
% matlab (note: this will make matlab unusable while the AFNI portion of
% the pipeline runs)
% false: print the lines in the matlab command window that should be run in
% a separate shell terminal

%% GET PATH TO THE TEMPLATE DIRECTORY
filePath = matlab.desktop.editor.getActiveFilename;
i_fname = strfind(filePath, 'AFNI_PreProc');
nhp_imaging_path = filePath(1:i_fname-2);
template_base_dir = [nhp_imaging_path filesep 'NMT_v2.0_sym'];
template_dir = [template_base_dir filesep 'NMT_v2.0_sym_05mm'];

%% GET THE PATH TO THE RAW DICOM FOLDER AND CD TO IT
img_dir_sub_sel = [img_dir filesep subid filesep scan_dir];
cd(img_dir_sub_sel);

%% CREATE A FOLDER FOR AFNI AND A SUBFOLDER FOR SAVING THE PREPROCESSED SCANS
% AND COPY THE .NII SCANS TO THE PREPROC FOLDER
afni_dir = [img_dir filesep subid filesep 'AFNI'];
if exist(afni_dir) ~= 7
  mkdir(afni_dir);
end
cd(afni_dir);

preproc_dir = [afni_dir filesep 'ScansPreproc'];
if exist(preproc_dir) ~= 7
  mkdir(preproc_dir);
end

%% CONVERT DICOMS TO NIFIT (.NII) FORMAT
fnames = dir(img_dir_sub_sel); % file names
v = 0;

for f = 1:length(fnames)
  % find the scans that have at least min_slices2convert slices (this will
  % avoid unnecessary conversion of localizers and other scans)
  conversiondone = 0;
  if ~ismember(fnames(f).name, {'.', '..'})
    dir_f = dir([img_dir_sub_sel filesep fnames(f).name]);
    if length(dir_f) > min_slices2convert
      i_f = 0;
      while ~conversiondone
        i_f = i_f+1;
        if length(dir_f(i_f).name) > 4 && strcmp(dir_f(i_f).name(end-3:end), '.dcm')
          img = ft_read_mri([img_dir_sub_sel filesep fnames(f).name filesep dir_f(i_f).name]);
          conversiondone = 1;
        end
      end
    end
  end
  
  % convert the dicoms to nii
  if conversiondone
    v = v + 1;
    img_pre{v} = fnames(f).name;
    
    cfg = [];
    cfg.filename    = [preproc_dir filesep img_pre{v} '.nii'];
    cfg.filetype    = 'nifti';
    cfg.parameter   = 'anatomy';
    cfg.datatype    = 'int32';
    ft_volumewrite(cfg, img);
  end
end

nscans = length(img_pre);

% save the names of the scans we are putting through the pipeline
save([afni_dir filesep 'scan_prefixes.mat'], 'img_pre');

%% REALIGN EACH OF THE SCANS SO THAT THEY ARE IN RAS COORDINATES
% (SAME COORDINATES AS THE TEMPLATE)

% get the ACPC fiducials on the template in RAS coordinates
load([template_dir filesep 'acpc_fiducial.mat']);

% initialize some stuff
img_acpc = cell(1, nscans);
img_acpc_nmt2 = cell(1, nscans);

% load each of the scans
img = {};
nslices = [];
for v = 1:nscans
  img{v} = ft_read_mri([preproc_dir filesep img_pre{v} '.nii']);
  nslices(v) = img{v}.dim(3);
end

% determine which is the scan with highest resolution (most # of slices)
% this should be one of the T1s
[~, i_highres] = max(nslices);

% plot the 3 orthogonal slices mainly to determine which voxels correspond
% to the right
ft_determine_coordsys(img{i_highres}); % say no to the question that appears

% select the fiducials in the scan with highest quality
cfg = [];
cfg.method      = 'interactive';
cfg.coordsys    = 'acpc';
img_acpc{i_highres} = ft_volumerealign(cfg, img{i_highres});

% save the high res image
cfg = [];
cfg.filename    = [preproc_dir filesep img_pre{i_highres} '_acpc'];
cfg.filetype    = 'nifti';
cfg.parameter   = 'anatomy';
cfg.datatype    = 'int32';
ft_volumewrite(cfg, img_acpc{i_highres});

% warp the fiducials from voxel to [universal] RAS space
fiducial_acpc.ac = ft_warp_apply(img{i_highres}.transform, img_acpc{i_highres}.cfg.fiducial.ac);
fiducial_acpc.pc = ft_warp_apply(img{i_highres}.transform, img_acpc{i_highres}.cfg.fiducial.pc);
fiducial_acpc.xzpoint = ft_warp_apply(img{i_highres}.transform, img_acpc{i_highres}.cfg.fiducial.xzpoint);
fiducial_acpc.right = ft_warp_apply(img{i_highres}.transform, img_acpc{i_highres}.cfg.fiducial.right);

for v = 1:nscans
  if v ~= i_highres
    % warp the RAS fiducials to voxel space for this image
    fiducial_acpc2ijk.ac = ft_warp_apply(inv(img{v}.transform), fiducial_acpc.ac);
    fiducial_acpc2ijk.pc = ft_warp_apply(inv(img{v}.transform), fiducial_acpc.pc);
    fiducial_acpc2ijk.xzpoint = ft_warp_apply(inv(img{v}.transform), fiducial_acpc.xzpoint);
    fiducial_acpc2ijk.right = ft_warp_apply(inv(img{v}.transform), fiducial_acpc.right);
    
    % realign this scan according to the RAS fiducials
    cfg = [];
    cfg.method      = 'fiducial';
    cfg.coordsys    = 'acpc';
    cfg.fiducial    = fiducial_acpc2ijk;
    img_acpc{v}     = ft_volumerealign(cfg, img{v});
    
    % save the realigned scan
    cfg = [];
    cfg.filename    = [preproc_dir filesep img_pre{v} '_acpc'];
    cfg.filetype    = 'nifti';
    cfg.parameter   = 'anatomy';
    cfg.datatype    = 'int32';
    ft_volumewrite(cfg, img_acpc{v});
  end
end

%% TRANSLATE THE SCANS SO THAT THE ANTERIOR COMMISSURE IS ALIGNED WITH THE TEMPLATE (NMT2)
img_acpc_nmt2 = img_acpc;
for v = 1:nscans
  % find the difference in RAS coordinates between the AC location in the
  % NMT2 template and this scan
  % note: AC of this scan in RAS is [0 0 0];
  ac_diff = fiducial_nmt2.ac;
  
  % add a translation to the ACPC transformation matrix for this scan
  img_acpc_nmt2{v}.transform(1:3, 4) = img_acpc_nmt2{v}.transform(1:3, 4) + fiducial_nmt2.ac';

  % save the translated ACPC scan
  cfg = [];
  cfg.filename    = [preproc_dir filesep img_pre{v} '_nmt2'];
  cfg.filetype    = 'nifti';
  cfg.parameter   = 'anatomy';
  cfg.datatype    = 'int32';
  ft_volumewrite(cfg, img_acpc_nmt2{v});
end

%% CROP AND RESLICE (INTERPOLATE) EACH OF THE IMAGES SO THAT THEY ARE ALL THE SAME
% EXACT DIMENSIONS
% plot the high res scan to determine the range to crop *in acpc coordinates*
ft_sourceplot([], img_acpc_nmt2{i_highres});

% Enter the coordinates where you want to crop (get within a few mm of the
% edge of the skull but make sure not to crop any of the skull surrounding 
% the brain, because the skull will be vital for fusing the CT to any MRI.
% It's okay to crop out parts of the skull inferior to the foramen magnum. 
% Often helpful to leave at least part of the orbits too.)
cfg = [];
cfg.method      = 'nearest';
cfg.resolution  = min([img_acpc_nmt2{i_highres}.hdr.xsize img_acpc_nmt2{i_highres}.hdr.ysize img_acpc_nmt2{i_highres}.hdr.zsize]);
cfg.xrange      = input('Enter the minimum and maximum X (left --> right) acpc coordinate in the form [min max]: \n');
cfg.yrange      = input('Enter the minimum and maximum Y (posterior --> anterior) acpc coordinate in the form [min max]: \n');
cfg.zrange      = input('Enter the minimum and maximum Z (inferior --> superior) acpc coordinate in the form [min max]: \n');
img_reslice = {};
for v = 1:nscans
  img_reslice{v} = ft_volumereslice(cfg, img_acpc_nmt2{v});
  
  % save the resliced scan
  cfg_sv = [];
  cfg_sv.filename   = [preproc_dir filesep img_pre{v} '_nmt2_reslice'];
  cfg_sv.filetype   = 'nifti';
  cfg_sv.parameter  = 'anatomy';
  cfg_sv.datatype   = 'int32';
  ft_volumewrite(cfg_sv, img_reslice{v});
end

%% SAVE THE PREPROCESSED T1 IN THE AFNI DIRECTORY
copyfile([preproc_dir filesep img_pre{i_highres} '_nmt2_reslice.nii'], ...
  [afni_dir filesep subid '_T1.nii']);
  
%% RUN AFNI ANIMAL WARPER (AW)
% create the directory where you want to store the output
aw_dir = [afni_dir filesep 'AnimalWarperOut'];
mkdir(aw_dir);

% Define inputs to @animal_warper
input_path      = [afni_dir filesep subid '_T1']; % full path to the subject T1
input_abbrev    = [subid '_anat']; % all files output by AW will refer to the subject T1 this way
child_path      = []; % full path to all of the other (non-T1) scans
for v = 1:nscans
  child_path    = [child_path preproc_dir filesep img_pre{v} '_nmt2_reslice.nii '];
end
base            = [template_dir filesep 'NMT_v2.0_sym_05mm.nii.gz']; % full path to the template scan. the subject scan will be warped to fit this template
base_abbrev     = 'NMT2'; % all files output by AW will refer to the template this way
atlas_followers = [template_dir filesep 'CHARM_in_NMT_v2.0_sym_05mm.nii.gz']; % full path to all of the atlases; must be in the same space as the template
atlas_followers = [atlas_followers ' ' template_dir filesep 'SARM_in_NMT_v2.0_sym_05mm.nii.gz']; % add as many atlases as you want separated by a space
atlas_abbrevs   = 'CHARM SARM'; % all files output by AW will refer to each atlas this way (order corresponds to above paths)
seg             = [template_dir filesep 'NMT_v2.0_sym_05mm_segmentation.nii.gz']; % full path to tissue segmentation (basically a coarse-grain atlas)
seg_abbrev      = 'SEG'; % all files output by AW will refer to the segmentation this way
skullstrip_mask = [template_dir filesep 'NMT_v2.0_sym_05mm_brainmask.nii.gz']; % full path to the brain mask associated with the template


% @animal_warper is technically supposed to be able to do
% @Align_Centers under the hood too, but for whatever reason, the other (non T1) scans do
% not end up in the same space, which is why we do this step separately
line1 = 'export PATH=$PATH:~/abin ; '; % add AFNI to the path
line2 = 'export PATH=$PATH:/Library/Frameworks/R.framework/Versions/3.6/Resources/bin ; '; % add correct version (3.6) of R to the path
% note: line2 was necessary for me since I have multiple versions of R. It
% may not be necessary for all systems.
line3 = 'export DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:/opt/X11/lib/flat_namespace ; '; % add this specific Xquartz thing to the path

% @Align_Centers will simply deoblique all of the subject scans at once,
% keeping them in the same space (note: this ONLY works if the scans are all 
% the same dimensions, which is why we had to reslice/interpolate earlier). 
line4 = ['@Align_Centers' ... % see above
  ' -base ' base ...
  ' -dset ' input_path '.nii' ...
  ' -child ' child_path ' ; '];


% @animal_warper does the heavy lifting of volume-based registration,
% warping back to subject space, and generating native space atlases and surfaces
line5 = ['@animal_warper' ... % start of @animal_warper
  ' -echo' ...
  ' -input ' input_path '_shft.nii' ... % make sure we are using the output of @Align_Centers (ends in _shft)
  ' -input_abbrev ' input_abbrev ...
  ' -base ' base ...
  ' -base_abbrev ' base_abbrev ...
  ' -atlas_followers ' atlas_followers ...
  ' -atlas_abbrevs ' atlas_abbrevs ...
  ' -seg_followers ' seg ...
  ' -seg_abbrevs ' seg_abbrev ...
  ' -skullstrip ' skullstrip_mask ...
  ' -outdir ' aw_dir ...
  ' -align_centers_meth OFF' ...
  ' -aff_move_opt OFF' ...
  ' -ok_to_exist'];

if do_run_afni_in_matlab
  system([line1 line2 line3 line4 line5]);
else
  line1
  line2
  line3
  line4
  line5
  fprintf('Copy-paste the above lines (in order) in a separate terminal before continuing to the final step\n');
end

% If you get an error, run this check:
% system(['export PATH=$PATH:~/abin ; ' ... % add AFNI to the path
%   'export PATH=$PATH:/Library/Frameworks/R.framework/Versions/3.6/Resources/bin ; ' ... % add correct version of R to the path
%   'export DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:/opt/X11/lib/flat_namespace ; ' ...
%   'cd ~/abin ; ' ...
%   'python afni_system_check.py -check_all'])

% If everything runs smoothly, look at the QC images in the animal warper
% folder to determine if registration looks nice 
% start with init_qc_03_inpNL_base.jpg, note that the other images with
% "init" prefixes should not look perfectly aligned (see AW help
% documentation for more info)

%% FOR EACH ATLAS, AW OUTPUTS ONE .NII FILE WITH N_LEVELS SUBVOLUMES BUT MOST
% SCAN VIEWERS PREFER NOT TO HAVE SUBVOLUMES SO LETS SAVE EACH LEVEL (SUB_VOLUME) 
% AS ITS OWN .NII FILE
atlas_abbrevs = {'CHARM', 'SARM'};

% Get directory names again in case you want to start here
afni_dir = [img_dir filesep subid filesep 'AFNI'];
atlasdir = [afni_dir filesep 'AtlasesIn' subid];
aw_dir = [afni_dir filesep 'AnimalWarperOut'];

% Create a directory for the atlases
if exist(atlasdir) ~= 7
  mkdir(atlasdir);
end

for at = 1:length(atlas_abbrevs)
  atlas_native = ft_read_mri([aw_dir filesep atlas_abbrevs{at} '_in_' subid '_anat.nii.gz']);
  atlas_native_lvl = {};
  for i = 1:6
    atlas_native_lvl{i} = atlas_native;
    atlas_native_lvl{i}.dim = atlas_native.dim(1:3);
    atlas_native_lvl{i}.anatomy = atlas_native.anatomy(:, :, :, i); % only copy the subvolume associated with level i
    
    % save this level of the atlas as .nii
    cfg = [];
    cfg.filename    = [atlasdir filesep atlas_abbrevs{at} num2str(i) '_in_' subid '.nii'];
    cfg.filetype    = 'nifti';
    cfg.parameter   = 'anatomy';
    cfg.datatype    = 'int32';
    ft_volumewrite(cfg, atlas_native_lvl{i});
  end
end

