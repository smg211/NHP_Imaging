%% Installation Info
% Had to download SPM12 in order to execute this code (SPM 12): https://www.fil.ion.ucl.ac.uk/spm/software/download/
% https://en.wikibooks.org/wiki/SPM/Installation_on_64bit_Mac_OS_(Intel)

%%
% Path to ct file: 
subid = 'Nike';%;'Haribo'; % animal name
img_dir = '/Users/preeyakhanna/Library/CloudStorage/Box-Box/Data/NHP_Imaging'; 

% used Slicer 3d to convert Alice Tarantals' scans to nii format
% when load the folder, the scan included Head/Scout/Dose files too; 
ct_file = 'MMU42889_CT_mA_60.nii'; 
mri_acpc = 'AFNI/Nike_T1_shft.nii'; 

% Load the CT 
ct = ft_read_mri([img_dir filesep subid filesep ct_file]);

% Determine its coordinate system 
% Left-right axis is X, Right is +
% Z axis (S/I), Y axis (A/P) seems rotated; 
ft_determine_coordsys(ct); 

% mark fiducials 
% no idea which is L/R in this animal
cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'ctf';
ct_ctf = ft_volumerealign(cfg, ct);

% Automatically convert CT into acpc: 
% Seems to need SPM12
ct_acpc = ft_convert_coordsys(ct_ctf, 'acpc');

% Also needs SPM12
% Fusion of CT with MRI: 
cfg = [];
cfg.ct_acpc = ft_convert_coordsys(ct_ctf, 'acpc');
cfg.method = 'spm';
cfg.spmversion = 'spm12';
cfg.coordsys = 'acpc';
cfg.viewresult = 'yes';

% Read the MRI 
fsmri_acpc = ft_read_mri([img_dir filesep subid filesep mri_acpc]);

% Align CT to the MRI 
ct_acpc_f = ft_volumerealign(cfg, ct_acpc, fsmri_acpc);

% Write out MRI-aligned CT -- this seems to show up weird in Slicer3D --
% non-aligned; 
cfg = [];
cfg.filename = [img_dir filesep subid filesep ct_file(1:end-4) '_CT_acpc_f.nii'];
cfg.filetype = 'nifti';
cfg.parameter = 'anatomy';
ft_volumewrite(cfg, ct_acpc_f);





