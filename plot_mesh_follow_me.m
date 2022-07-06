function fig1 = plot_mesh_follow_me(cfg, mesh)
% plot meshes in a figure that allows the light source to follow the view angle
%
% Use as:
%       plot_mesh_follow_me(cfg, mesh)
% 
% Where:
%   mesh = 1 x N cell array of triangulated meshes (each must contain a pos
%   and tri field)
%
%   cfg is a configuration structure that contains the following fields:
%       fig_size    = [width height], size of the figure (relative to overall screen size)
%       facecolor   = 1 x N cell array, each cell can either be an [r g b] 
%                     color triplet or name of a color in the 'colors' folder 
%                     of this repo. If length(cfg.facecolor) == 1, but
%                     length(mesh) > 1, then all of the meshes will be the
%                     same color (default = 'skin')
%       facealpha   = 1 x N array of scalars defining the alpha for each
%                     mesh. If length(cfg.facealpha) == 1, but
%                     length(mesh) > 1, then all of the meshes will be the
%                     same alpha (default = 1)

dir_func = fileparts(mfilename('fullpath'));
addpath([dir_func filesep 'colors'])

% get settings
fig_size = ft_getopt(cfg, 'fig_size', []);
facecolor = ft_getopt(cfg, 'facecolor', 'skin');
facealpha = ft_getopt(cfg, 'facealpha', 1);

if ~iscell(mesh)
  mesh = {mesh};
end
nmesh = length(mesh);

if isempty(fig_size)
  fig_loc_size = [0.3 0.25 0.4 0.5];
else
  fig_loc_size = [0 0 fig_size];
end

if isstr(facecolor)
  facecolor = eval(facecolor);
  facecolor = repmat(facecolor, nmesh, 1);
elseif iscell(facecolor)
  facecolor_cell = facecolor;
  clear facecolor
  for n = 1:nmesh
    if isstr(facecolor_cell{n})
      facecolor(n, :) = eval(facecolor_cell{n});
    else
      facecolor(n, :) = facecolor_cell{n};
    end
  end
end

if length(facealpha) == 1
  facealpha = repmat(facealpha, 1, nmesh);
end

fig1 = figure('units','normalized','outerposition', fig_loc_size); hold on;
set(gca, 'XTick', [])
set(gca, 'YTick', [])
set(gca, 'ZTick', [])
set(gca, 'XColor','none')
set(gca, 'YColor','none')
set(gca, 'ZColor','none')

% added to make axes not squish the brain
axis('equal'); 

axes('buttondownfcn', @buttondownfcn);  % assign callback
set(gca,'NextPlot','add');              % add next plot to current axis
axis('equal'); 

for m = 1:nmesh
  hs = patch('Vertices', mesh{m}.pos, 'Faces', mesh{m}.tri, ...
    'FaceColor', facecolor(m, :), 'FaceAlpha', facealpha(m), 'EdgeColor', 'none');
  hs.HitTest = 'off';
  material dull
  lighting gouraud
end

view(3);                                % view to start from
c = camlight('headlight');              % add light
set(c,'style','infinite');              % set style of light


  function buttondownfcn(ax,~)
    fig = ancestor(ax,'figure');        % get figure handle
    [oaz, oel] = view(ax);              % get current azimuth and elevation
    oloc = get(0,'PointerLocation');    % get starting point
    set(fig,'windowbuttonmotionfcn',{@rotationcallback,ax,oloc,oaz,oel});
    set(fig,'windowbuttonupfcn',{@donecallback});
    axis('equal'); 
  end

  function rotationcallback(~,~,ax,oloc,oaz,oel)
    locend = get(0, 'PointerLocation'); % get mouse location
    dx = locend(1) - oloc(1);           % calculate difference x
    dy = locend(2) - oloc(2);           % calculate difference y
    factor = 2;                         % correction mouse -> rotation
    newaz = oaz-dx/factor;              % calculate new azimuth
    newel = oel-dy/factor;              % calculate new elevation
    view(ax,newaz,newel);               % adjust view
    c = camlight(c,'headlight');        % adjust light
    axis('equal'); 
  end

  function donecallback(src,~)
    fig = ancestor(src,'figure');           % get figure handle
    set(fig,'windowbuttonmotionfcn',[]);    % unassign windowbuttonmotionfcn
    set(fig,'windowbuttonupfcn',[]);        % unassign windowbuttonupfcn
    axis('equal'); 
  end

end
