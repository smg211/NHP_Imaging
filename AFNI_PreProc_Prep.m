% Creates .mat files for the keys for each AFNI atlas
% AND sets the ACPC fiducials on the template scan
% THIS ONLY NEEDS TO BE RUN ONCE (NOT FOR EACH SUBJECT), BUT MUST BE RUN
% BEFORE AFNI_PreProc

%% GET PATH TO THE TEMPLATE DIRECTORY
filePath = matlab.desktop.editor.getActiveFilename;
i_fname = strfind(filePath, 'AFNI_PreProc_Prep');
nhp_imaging_path = filePath(1:i_fname-2);
template_base_dir = [nhp_imaging_path filesep 'NMT_v2.0_sym'];
template_dir = [template_base_dir filesep 'NMT_v2.0_sym_05mm'];

%% CREATE A STRUCTURE CONTAINING ALL THE ROI LABELS FOR EACH LEVEL OF THE ATLASES
atlas_abbrevs = {'CHARM', 'SARM'};

for at = 1:length(atlas_abbrevs)
  table_csv = [template_base_dir filesep 'tables_' atlas_abbrevs{at} filesep atlas_abbrevs{at} '_key_table.csv'];
  opts = detectImportOptions(table_csv);
  opts.Delimiter = {','};
  opts.DataLines = [2 Inf];
  opts.VariableNamesLine = 1;
  M = readmatrix(table_csv, opts);
  
  atlas_key = [];
  for n = 1:6 % for each level
    atlas_key(n).level = n;
    atlas_key(n).level_char = ['0' num2str(n-1)];
    idx = 0;
    for i = 1:size(M, 1)
      str = M{i, n};
      i_colon = strfind(str, ':');
      i_paren = strfind(str, '(');
      val = str2num(str(1:i_colon-1));
      if i == 1 || ~any([atlas_key(n).code] == val)
        idx = idx+1;
        atlas_key(n).code(idx) = val;
        atlas_key(n).area_name{idx} = str(i_colon+2:i_paren(end)-2);
        atlas_key(n).area_abbrev{idx} = str(i_paren(end)+1:end-1);
        
        if any(strfind(atlas_key(n).area_abbrev{idx}, '/'))
          i_slash = strfind(atlas_key(n).area_abbrev{idx}, '/');
          atlas_key(n).area_abbrev{idx}(i_slash) = '-';
        end
      end
    end
  end
  
  eval([lower(atlas_abbrevs{at}) '_key = atlas_key']);
  
  save([template_base_dir filesep 'tables_' atlas_abbrevs{at} filesep atlas_abbrevs{at} '_key.mat'], [lower(atlas_abbrevs{at}) '_key'], '-v7.3');
end

%% FIND THE FIDUCIALS ON THE TEMPLATE USED WITH ANIMAL WARPER
nmt2 = ft_read_mri([template_dir filesep 'NMT_v2.0_sym_05mm.nii.gz']);

% find the fiducials on the template 
ft_determine_coordsys(nmt2)

cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'acpc';
nmt2_acpc = ft_volumerealign(cfg, nmt2);

% warp the template fiducials to universal RAS space
fiducial_nmt2.ac = ft_warp_apply(nmt2.transform, nmt2_acpc.cfg.fiducial.ac);
fiducial_nmt2.pc = ft_warp_apply(nmt2.transform, nmt2_acpc.cfg.fiducial.pc);
fiducial_nmt2.xzpoint = ft_warp_apply(nmt2.transform, nmt2_acpc.cfg.fiducial.xzpoint);
fiducial_nmt2.right = ft_warp_apply(nmt2.transform, nmt2_acpc.cfg.fiducial.right);

% save these fiducials for use later
save([template_dir filesep 'acpc_fiducial.mat'], 'fiducial_nmt2', '-v7.3');
