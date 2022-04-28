
save_folder = '/Users/preeyakhanna/Library/CloudStorage/Box-Box/Data/NHP_imaging/Template/'; 
load_folder = '/Users/preeyakhanna/NHP_imaging/NMT_v2.0_sym/NMT_v2.0_sym_surfaces/atlases/';

% Need to load atlas abbrevs % 
atlas_abbrevs = {'CHARM', 'SARM'};

atlas_key = {};

template_base_dir = '/Users/preeyakhanna/NHP_imaging/NMT_v2.0_sym/';
levels_to_analyze = [1, 2, 3, 4, 5, 6]; 

for at = 1:2 %1:length(atlas_abbrevs) % for each atlas
  % load the atlas key
  load([template_base_dir filesep 'tables_' atlas_abbrevs{at} filesep atlas_abbrevs{at} '_key.mat']);
  
  % standardize the name for the atlas key
  eval(['atlas_key{at} = ' lower(atlas_abbrevs{at}) '_key']);
  
  for n = 1:length(atlas_key{at}) % for every level
      lvl = levels_to_analyze(n); 
      
      surfdir_lvl = [load_folder atlas_abbrevs{at} filesep 'Level_' num2str(lvl)];
      
      for i = 1:length(atlas_key{at}(lvl).code)
          
          surf_path = [surfdir_lvl filesep atlas_abbrevs{at} '_' num2str(lvl) '.' atlas_key{at}(lvl).area_abbrev{i} '.k' num2str(atlas_key{at}(lvl).code(i))];
      
        if exist([surf_path '.gii'])
            surf_atlas{at}{lvl}{i} = ft_read_headshape([surf_path '.gii'], 'format', 'gifti', 'coordsys', 'acpc', 'unit', 'mm');
        end
      end
  end
end

for at = 2:2 % 
    
    if exist([save_folder atlas_abbrevs{at}]) == 7
        z=10; 
    else
        mkdir([save_folder atlas_abbrevs{at}])
    end
    
    for n = 1:length(atlas_key{at})
        lvl = levels_to_analyze(n); 
        if n == 6
            if exist([save_folder atlas_abbrevs{at} filesep 'Level' num2str(lvl)]) == 7
                z=10; 
            else
                mkdir([save_folder atlas_abbrevs{at} filesep 'Level' num2str(lvl)])
            end

            subsurfdir = [save_folder atlas_abbrevs{at} filesep 'Level' num2str(lvl) filesep]; 

            for l = 1:length(atlas_key{at}(n).area_name)
                if ~isempty(surf_atlas{at}{lvl}{l})
                    save_surface(surf_atlas{at}{lvl}{l}, atlas_key{at}(n).area_name{l}, subsurfdir)
                end
            end
        end
    end
end