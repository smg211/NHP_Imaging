%% ENTER SETTINGS
img_dir = '/Users/preeyakhanna/Box Sync/Data/NHP_Imaging'; % path to NHP imaging data
subid = 'Haribo'; % animal name
scan_dir = '4chan_scans_MRI_aug2021'; % name of folder where the raw DICOM files are located
sm_iter = []; % int, number of smoothing iterations (higher number = more smooth, [] = skip smoothing)
facealpha = 1; % transparecy of each ROI
n_distinct_colors = 15; % number of different colors you want to cycle through for coloring the ROIs

%% LOAD EACH OF THE SURFACES AND OPTIONALLY SMOOTH THEM (NOTE: SMOOTHING EVERY SURFACE WILL TAKE SEVERAL HOURS)
% Get directory names again in case you want to start here
afni_dir = [img_dir filesep subid filesep 'AFNI'];
aw_dir = [afni_dir filesep 'AnimalWarperOut'];
subsurfdir = [afni_dir filesep 'Surfaces'];

cortex = ft_read_headshape([subsurfdir filesep 'cortex.gii'], 'format', 'gifti', 'coordsys', 'acpc', 'unit', 'mm');
m1 = ft_read_headshape([subsurfdir filesep 'primary_motor_cortex.gii'], 'format', 'gifti', 'coordsys', 'acpc', 'unit', 'mm');
pmd = ft_read_headshape([subsurfdir filesep 'dorsal_premotor_cortex.gii'], 'format', 'gifti', 'coordsys', 'acpc', 'unit', 'mm');
pmv = ft_read_headshape([subsurfdir filesep 'ventral_premotor_cortex.gii'], 'format', 'gifti', 'coordsys', 'acpc', 'unit', 'mm');
caudate = ft_read_headshape([subsurfdir filesep 'caudate.gii'], 'format', 'gifti', 'coordsys', 'acpc', 'unit', 'mm');
putamen = ft_read_headshape([subsurfdir filesep 'putamen.gii'], 'format', 'gifti', 'coordsys', 'acpc', 'unit', 'mm');

post_thalamus = ft_read_headshape([subsurfdir filesep 'posterior_thalamus.gii'], 'format', 'gifti', 'coordsys', 'acpc', 'unit', 'mm');
vent_thalamus = ft_read_headshape([subsurfdir filesep 'ventral_thalamus.gii'], 'format', 'gifti', 'coordsys', 'acpc', 'unit', 'mm');
medial_thalamus = ft_read_headshape([subsurfdir filesep 'medial_thalamus.gii'], 'format', 'gifti', 'coordsys', 'acpc', 'unit', 'mm');

% Plot the surface on top of the cortex
cfg = [];
cfg.facecolor     = {'skin', 'yellow', 'magenta', 'red', 'black', 'black', 'green', 'blue', 'cyan'};
cfg.facealpha     = [.3 .3 .7 .7 .3 .3 .7, .7 .7];
cfg.fig_size      = [1 1];
plot_mesh_follow_me(cfg, {cortex, caudate, putamen, vent_thalamus, medial_thalamus, post_thalamus, m1, pmd, pmv});
