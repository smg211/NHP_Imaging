% Loads all of the afni surfaces, optionally smoothes them, and creates
% plots of all of the ROIs at each level of each atlas, including separate plots for the legends

%% ENTER SETTINGS
clear all
img_dir = '/Users/Sandon/Box/Data/NHP_Imaging'; % path to NHP imaging data
subid = 'Haribo'; % animal name
scan_dir = 'ds_2021-08-26_10-07'; % name of folder where the raw DICOM files are located
sm_iter = []; % int, number of smoothing iterations (higher number = more smooth, [] = skip smoothing)
facealpha = 1; % transparecy of each ROI
n_distinct_colors = 15; % number of different colors you want to cycle through for coloring the ROIs

%% GET PATH TO THE TEMPLATE DIRECTORY
filePath = matlab.desktop.editor.getActiveFilename;
i_fname = strfind(filePath, 'AFNI_Surfaces_PostProc');
nhp_imaging_path = filePath(1:i_fname-2);
template_base_dir = [nhp_imaging_path filesep 'NMT_v2.0_sym'];

%% LOAD EACH OF THE SURFACES AND OPTIONALLY SMOOTH THEM (NOTE: SMOOTHING EVERY SURFACE WILL TAKE SEVERAL HOURS)
% Get directory names again in case you want to start here
afni_dir = [img_dir filesep subid filesep 'AFNI'];
aw_dir = [afni_dir filesep 'AnimalWarperOut'];
subsurfdir = [afni_dir filesep 'Surfaces'];

% Create a directory for the atlases
if exist(subsurfdir) ~= 7
  mkdir(subsurfdir);
end

% get the name of the directory where the surfaces are stored
awsurfdir = [aw_dir filesep 'surfaces'];

% initialize some stuff
atlas_key = {};
surf_atlas = {};
surf_atlas_sm = {};

for at = 1:length(atlas_abbrevs) % for each atlas
  % load the atlas key
  load([template_base_dir filesep 'tables_' atlas_abbrevs{at} filesep atlas_abbrevs{at} '_key.mat']);
  
  % standardize the name for the atlas key
  eval(['atlas_key{at} = ' lower(atlas_abbrevs{at}) '_key']);
  
  for n = 1:length(atlas_key{at}) % for every level
    surfdir_lvl = [awsurfdir filesep 'surfaces_' atlas_abbrevs{at} '_' atlas_key{at}(n).level_char];
    
    for i = 1:length(atlas_key{at}(n).code)
      surf_path = [surfdir_lvl filesep 'native.' atlas_key{at}(n).area_abbrev{i} '.k' num2str(atlas_key{at}(n).code(i))];
      
      if exist([surf_path '.gii'])
        surf_atlas{at}{n}{i} = ft_read_headshape([surf_path '.gii'], 'format', 'gifti', 'coordsys', 'acpc', 'unit', 'mm');
        surf_atlas_sm{at}{n}{i} = surf_atlas{at}{n}{i};
        
        if ~isempty(sm_iter)
          % smooth the mesh
          [surf_atlas_sm{at}{n}{i}.pos, surf_atlas_sm{at}{n}{i}.tri] = fairsurface(surf_atlas{at}{n}{i}.pos, surf_atlas{at}{n}{i}.tri, sm_iter);
        
          % save the mesh
          ft_write_headshape([surf_path '_sm.gii'], surf_atlas_sm{at}{n}{i}, 'format', 'gifti', 'unit', surf_atlas_sm{at}{n}{i}.unit);
        end
      else
        fprintf(['No surface found for ' atlas_abbrevs{at} '_' atlas_key{at}(n).level_char filesep ...
          'native.' atlas_key{at}(n).area_abbrev{i} '.k' num2str(atlas_key{at}(n).code(i)) '\n']);
      end
    end
  end
end

%% CREATE A MESH THAT INCLUDES ALL 4 LOBES OF CORTEX
for at = 1:length(atlas_abbrevs) % for each atlas
  if strcmp(atlas_abbrevs{at}, 'CHARM')
    cortex = surf_atlas{at}{1}{1};
    cortex_sm = surf_atlas_sm{at}{1}{1};
    for i = 2:4
      cortex.pos = [cortex.pos; surf_atlas{at}{1}{i}.pos];
      cortex.tri = [cortex.tri; surf_atlas{at}{1}{i}.tri+max(cortex.tri, [], 'all')];
      
      cortex_sm.pos = [cortex_sm.pos; surf_atlas_sm{at}{1}{i}.pos];
      cortex_sm.tri = [cortex_sm.tri; surf_atlas_sm{at}{1}{i}.tri+max(cortex_sm.tri, [], 'all')];
    end
    
    ft_write_headshape([subsurfdir filesep 'cortex.gii'], cortex, 'format', 'gifti', 'unit', cortex.unit);
    ft_write_headshape([subsurfdir filesep 'cortex_sm.gii'], cortex_sm, 'format', 'gifti', 'unit', cortex.unit);
  end
end

%% MAKE A 3D FIGURE FOR EACH ROI AT EACH LEVEL OF EACH ATLAS
% enter legend settings (these probably do not need to be edited)
n_labels_per_column = 53; 
leg_fontsize = [30 20 20 13 13 13];
for at = 1:length(atlas_abbrevs)
  for n = 1:length(atlas_key{at})
    cmap = cbrewer('qual', 'Set1', n_distinct_colors);
    cmap = repmat(cmap, ceil(length(atlas_key{at}(n).code)/n_distinct_colors), 1);
    cmap = cmap(1:length(atlas_key{at}(n).code), :);

    i_empty = [];
    for i = 1:length(atlas_key{at}(n).code)
      if isempty(surf_atlas{at}{n}{i})
        i_empty = [i_empty i];
      end
    end
    
    % delete the meshes and associated area names that do not exist
    cmap(i_empty, :) = [];
    mesh_plot = surf_atlas{at}{n};
    mesh_plot(i_empty) = [];
    mesh_plot_sm = surf_atlas_sm{at}{n};
    mesh_plot_sm(i_empty) = [];
    area_name = atlas_key{at}(n).area_name;
    area_name(i_empty) = [];
    
    % settings for plotting
    cfg = [];
    cfg.facecolor   = cmap;
    cfg.facealpha   = repmat(facealpha, 1, length(mesh_plot));
    cfg.fig_size    = [1 1];

    % Plot unsmoothed meshes
    plot_mesh_follow_me(cfg, mesh_plot)
    savefig([subsurfdir filesep atlas_abbrevs{at} '_' num2str(n) '_AllSurfaces.fig']);
    close

    % Plot smoothed meshes
    if ~isempty(sm_iter)
      plot_mesh_follow_me(cfg, mesh_plot_sm)
      savefig([subsurfdir filesep atlas_abbrevs{at} '_' num2str(n) '_AllSurfaces_Smoothed.fig']);
      close
    end
    
    % Make a legend in another figure
    nsubplot = ceil(length(atlas_key{at}(n).code)/n_labels_per_column);
    fig = figure('units','normalized','outerposition', [0 0 0.25*nsubplot 1]);
    i_start = 1;

    for s = 1:nsubplot
      i_end = min([length(mesh_plot) i_start+n_labels_per_column-1]);
      subplot(1, nsubplot, s); hold on;
      h = [];
      idx = 0;
      for i = i_start:i_end
        idx = idx + 1;
        h(idx) = plot(0, 0, '-', 'LineWidth', 10, 'Color', cmap(i, :));
      end
      leg = legend(h);
      leg.String = area_name;
      leg.FontSize = leg_fontsize(n);
      leg.Location = 'East';
      leg.Interpreter = 'none';
      a = gca;
      a.XTick = [];
      a.YTick = [];

      i_start = i_end+1;
    end
    print(fig, [subsurfdir filesep atlas_abbrevs{at} '_' num2str(n) '_AllSurfaces_KEY.png'], '-dpng');
    close(fig);
  end
end
