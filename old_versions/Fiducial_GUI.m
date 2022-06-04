function varargout = Fiducial_GUI(varargin)
% FIDUCIAL_GUI MATLAB code for Fiducial_GUI.fig
%      FIDUCIAL_GUI, by itself, creates a new FIDUCIAL_GUI or raises the existing
%      singleton*.
%
%      H = FIDUCIAL_GUI returns the handle to a new FIDUCIAL_GUI or the handle to
%      the existing singleton*.
%
%      FIDUCIAL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIDUCIAL_GUI.M with the given input arguments.
%
%      FIDUCIAL_GUI('Property','Value',...) creates a new FIDUCIAL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Fiducial_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Fiducial_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Fiducial_GUI

% Last Modified by GUIDE v2.5 13-May-2022 10:36:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Fiducial_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @Fiducial_GUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Fiducial_GUI is made visible.
function Fiducial_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Fiducial_GUI (see VARARGIN)

% Choose default command line output for Fiducial_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Fiducial_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Fiducial_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load_MRI.
function load_MRI_Callback(hObject, eventdata, handles)
% hObject    handle to load_MRI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, path] = uigetfile('*.nii');

% display the filename
set(handles.mri_fname, 'String', filename)

% Read this filenmae;
mri = ft_read_mri([path filename]);
handles.mri_filename = [path filename];

mx = max(mri.anatomy(:));
mn = min(mri.anatomy(:));

% Process anatomy
ana = (mri.anatomy - mn) / (mx - mn);

% default starting clim
if isfield(handles, 'clim')
    clim = handles.clim;
else
    clim = [0, 1];
    handles.clim = clim;
end

prep_axes(hObject, handles, mri)

% Now plot this MRI;
% default starting point
ijk = [100, 100, 100];
xyz = mri.transform * [ijk 1]';
options = {'transform', eye(4),     'location', ijk, 'style', 'subplot',...
    'update',    [1, 1, 1], 'doscale',  false,   'clim',  handles.clim,...
    'parents', [handles.coronal_ax, handles.sag_ax, handles.ax_ax]};

% GUIDE:
% ortho plot: coronal: sag: axial
% index into xyz or ijk: R (sag), A (coronal), S (axial)

% Make horizontal lines
ft_plot_ortho(ana, options{:});

% Save some stuff for updating these plots later
anahandles = findobj('type', 'surface')';
%assert(length(anahandles) == 3)
handles.anahandles = [];
for i = 1:length(anahandles)
    tg = get(get(anahandles(i), 'parent'), 'tag');
    switch tg
        case 'coronal_ax'
            handles.anahandles(1) = anahandles(i);
        case 'sag_ax'
            handles.anahandles(2) = anahandles(i);
        case 'ax_ax'
            handles.anahandles(3) = anahandles(i);
    end
end

% Plot the crosshair
hch1 = ft_plot_crosshair([ijk(1) 1 ijk(3)], 'parent',           handles.coronal_ax);
hch3 = ft_plot_crosshair([ijk(1) ijk(2) size(ana,3)], 'parent', handles.ax_ax);
hch2 = ft_plot_crosshair([size(ana,1) ijk(2) ijk(3)], 'parent', handles.sag_ax);
handles.handlescross  = [hch1(:)';hch2(:)';hch3(:)'];
guidata(hObject, handles)

% Update the slider min/max/values etc.
prep_slider(hObject, handles, ana, mri)

% Save the MRI stuff
handles.xyz = xyz;
handles.ana = ana;
handles.mri = mri;
handles = update_MRI_coordinates(handles, xyz);
guidata(hObject, handles);

function prep_axes(hObject, handles, mri)
[cp_voxel, cp_head] = cornerpoints(mri.dim, mri.transform);
%     axlen1 = norm(cp_head(2,:)-cp_head(1,:));
%     axlen2 = norm(cp_head(4,:)-cp_head(1,:));
%     axlen3 = norm(cp_head(5,:)-cp_head(1,:));
%     h1size(1) = 0.82*axlen1/(axlen1 + axlen2);
%     h1size(2) = 0.82*axlen3/(axlen2 + axlen3);
%     h2size(1) = 0.82*axlen2/(axlen1 + axlen2);
%     h2size(2) = 0.82*axlen3/(axlen2 + axlen3);
%     h3size(1) = 0.82*axlen1/(axlen1 + axlen2);
%     h3size(2) = 0.82*axlen2/(axlen2 + axlen3);

% pos1 = get(handles.coronal_ax, 'position');
% pos1(3:4) = h1size;
% set(handles.coronal_ax, 'position', pos1);
%
% pos2 = get(handles.sag_ax, 'position');
% pos2(3:4) = h2size;
% set(handles.sag_ax, 'position', pos2);
%
% pos3 = get(handles.ax_ax, 'position');
% pos3(3:4) = h3size;
% set(handles.ax_ax, 'position', pos3);

voxlen1 = norm(cp_head(2,:)-cp_head(1,:))/norm(cp_voxel(2,:)-cp_voxel(1,:));
voxlen2 = norm(cp_head(4,:)-cp_head(1,:))/norm(cp_voxel(4,:)-cp_voxel(1,:));
voxlen3 = norm(cp_head(5,:)-cp_head(1,:))/norm(cp_voxel(5,:)-cp_voxel(1,:));

set(handles.coronal_ax, 'DataAspectRatio',1./[voxlen1 voxlen2 voxlen3]);
set(handles.sag_ax, 'DataAspectRatio',1./[voxlen1 voxlen2 voxlen3]);
set(handles.ax_ax, 'DataAspectRatio',1./[voxlen1 voxlen2 voxlen3]);
guidata(hObject, handles);

function prep_slider(hObject, handles, ana, mri)
i_range = [0, size(ana, 1)];
j_range = [0, size(ana, 2)];
k_range = [0, size(ana, 3)];
onz = [1, 1];

% transformation %
ijk = [i_range; j_range; k_range; onz]; % 4 x 2
xyz_range = mri.transform * ijk; % 4 x 2

set(handles.sag_slider, 'Min', xyz_range(1, 1));
set(handles.sag_slider, 'Max', xyz_range(1, 2));

set(handles.coronal_slider, 'Min', xyz_range(2, 1));
set(handles.coronal_slider, 'Max', xyz_range(2, 2));

set(handles.ax_slider, 'Min', xyz_range(3, 1));
set(handles.ax_slider, 'Max', xyz_range(3, 2));
guidata(hObject, handles);

function handles = update_MRI_coordinates(handles, xyz)

handles.xyz = xyz;
set(handles.sag_slider, 'Value', xyz(1))
set(handles.coronal_slider, 'Value', xyz(2))
set(handles.ax_slider, 'Value', xyz(3))

set(handles.sag_ML, 'String', num2str(xyz(1)))
set(handles.coronal_AP, 'String', num2str(xyz(2)))
set(handles.DV, 'String', num2str(xyz(3)))

% Go from xyz to ijk;
inv_trans = inv(handles.mri.transform);
ijk = inv_trans * handles.xyz;
ijk = round(ijk);

% Update images
options = {'transform', eye(4),     'location', ijk(1:3)', 'style', 'subplot',...
    'update',    [1, 1, 1], 'doscale',  false,   'clim',  handles.clim,...
    'surfhandle', handles.anahandles};

if ~isfield(handles, 'surf_toggle')
    handles.surf_toggle = 1;
end

if isfield(handles, 'brain_surfaces')
    if length(handles.brain_surfaces) > 0    
        options{end+1} = 'intersectmesh';
        options{end+1} = {};

        for l = 1:length(handles.brain_surfaces)

            % For this
            options2 = options;
            options2{end}{end+1} = handles.brain_surfaces{l}{2}; %name, ijk, list

            if handles.surf_toggle == 0
                % Delete patch
                for i = 1:3
                    if ~isempty(handles.brain_surfaces_handles{l})
                        delete(handles.brain_surfaces_handles{l}(i))
                        handles.brain_surfaces_handles{l} = []; 
                    end
                end
                
            else
                if isempty(handles.brain_surfaces_handles{l})

                    % Do the plot
                    ft_plot_ortho(handles.ana, options2{:});
                    patchhandles = findobj('type', 'patch')';

                    for i = 1:length(patchhandles)
                        tg = get(get(patchhandles(i), 'parent'), 'tag');
                        switch tg
                            case 'coronal_ax'

                                handles.brain_surfaces_handles{l}(1) = patchhandles(i);

                            case 'sag_ax'

                                handles.brain_surfaces_handles{l}(2) = patchhandles(i);

                            case 'ax_ax'

                                handles.brain_surfaces_handles{l}(3) = patchhandles(i);

                        end
                    end
                else
                    options2{end+1} = 'patchhandle';
                    options2{end+1}= handles.brain_surfaces_handles{l};
                    ft_plot_ortho(handles.ana, options2{:});
                end
            end
        end
    end
end

fprintf(' i j k [%d, %d, %d], x y z [ %.1f, %.1f, %.1f]\n', ijk(1), ijk(2), ijk(3), xyz(1), xyz(2), xyz(3));

% Update handles
ft_plot_ortho(handles.ana, options{:});

% Update cross hair
ft_plot_crosshair([ijk(1) 1 ijk(3)], 'handle', handles.handlescross(1, :));
ft_plot_crosshair([size(handles.ana, 1) ijk(2) ijk(3)], 'handle', handles.handlescross(2, :));
ft_plot_crosshair([ijk(1) ijk(2) size(handles.ana,3)], 'handle', handles.handlescross(3, :));

handles = plot_fiducials(handles);
handles = plot_electrode_tracts(handles); 

function handles = plot_fiducials(handles)
% Update fiducial marker
% If within a 1mm vicinity of any position plot it;
if isfield(handles, 'mri_fiducials_handles')
    delete(handles.mri_fiducials_handles)
end


if isfield(handles, 'mri_fiducials')
    fid_list = handles.mri_fiducials;
    if length(fid_list) > 0
        colors = jet(2*length(fid_list));
        % Only use the warmer colors for better viewing;
        colors = colors(length(fid_list):end, :);
        handles.mri_fiducials_handles = [];
        inv_trans = inv(handles.mri.transform);
        
        for i = 1:length(fid_list)
            pos = [fid_list{i}{2} 1];
            % Go from xyz to ijk;
            ijk = inv_trans * pos';
            ijk = round(ijk);
            
            % Current position;
            if abs(pos(2) - handles.xyz(2)) < 1
                set(gcf, 'currentaxes', handles.coronal_ax);
                hold on;
                h1 = line(ijk(1), 1, ijk(3), 'color', colors(i, :), 'Marker', '.');
                handles.mri_fiducials_handles = [handles.mri_fiducials_handles h1];
                hold off;
            end
            if abs(pos(3) - handles.xyz(3)) < 1
                set(gcf, 'currentaxes', handles.ax_ax);
                hold on;
                h2 = line(ijk(1),ijk(2), size(handles.ana,3), 'color', colors(i, :),'Marker', '.');
                handles.mri_fiducials_handles = [handles.mri_fiducials_handles h2];
                hold off;
            end
            if abs(pos(1) - handles.xyz(1)) < 1
                set(gcf, 'currentaxes', handles.sag_ax);
                hold on;
                h3 = line(size(handles.ana, 1), ijk(2),ijk(3), 'color', colors(i, :), 'Marker', '.');
                handles.mri_fiducials_handles = [handles.mri_fiducials_handles h3];
                hold off;
            end
        end
    end
end



% --- Executes on slider movement.
function coronal_slider_Callback(hObject, eventdata, handles)
% hObject    handle to coronal_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
xyz = handles.xyz;
xyz(2) = get(handles.coronal_slider, 'Value');
handles.xyz = xyz;
handles = update_MRI_coordinates(handles, xyz);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function coronal_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to coronal_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sag_slider_Callback(hObject, eventdata, handles)
% hObject    handle to sag_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
xyz = handles.xyz;
xyz(1) = get(handles.sag_slider, 'Value');
handles.xyz = xyz;
handles = update_MRI_coordinates(handles, xyz);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sag_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sag_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function ax_slider_Callback(hObject, eventdata, handles)
% hObject    handle to ax_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
xyz = handles.xyz;
xyz(3) = get(handles.ax_slider, 'Value');
handles.xyz = xyz;
handles = update_MRI_coordinates(handles, xyz);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ax_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ax_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function coronal_AP_Callback(hObject, eventdata, handles)
% hObject    handle to coronal_AP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of coronal_AP as text
%        str2double(get(hObject,'String')) returns contents of coronal_AP as a double
xyz = handles.xyz;
xyz(2) = str2double(get(handles.coronal_AP, 'String'));
handles.xyz = xyz;
handles = update_MRI_coordinates(handles, xyz);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function coronal_AP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to coronal_AP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sag_ML_Callback(hObject, eventdata, handles)
% hObject    handle to coronal_AP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of coronal_AP as text
%        str2double(get(hObject,'String')) returns contents of coronal_AP as a double
xyz = handles.xyz;
xyz(1) = str2double(get(handles.sag_ML, 'String'));
handles.xyz = xyz;
handles = update_MRI_coordinates(handles, xyz);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sag_ML_CreateFcn(hObject, eventdata, handles)
% hObject    handle to coronal_AP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DV_Callback(hObject, eventdata, handles)
% hObject    handle to DV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DV as text
%        str2double(get(hObject,'String')) returns contents of DV as a double
xyz = handles.xyz;
xyz(3) = str2double(get(handles.DV, 'String'));
handles.xyz = xyz;
handles = update_MRI_coordinates(handles, xyz);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function DV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function clim_max_Callback(hObject, eventdata, handles)
% hObject    handle to clim_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of clim_max as text
%        str2double(get(hObject,'String')) returns contents of clim_max as a double
handles.clim(2) = str2double(get(handles.clim_max, 'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function clim_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clim_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in mri_fiducials_list.
function mri_fiducials_list_Callback(hObject, eventdata, handles)
% hObject    handle to mri_fiducials_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns mri_fiducials_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mri_fiducials_list


% --- Executes during object creation, after setting all properties.
function mri_fiducials_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mri_fiducials_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in add_fiducial.
function add_fiducial_Callback(hObject, eventdata, handles)
% hObject    handle to add_fiducial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newname = get(handles.fiducial_id, 'String');
if ~isfield(handles, 'mri_fiducials')
    handles.mri_fiducials = {};
end

val_in_list = length(get(handles.mri_fiducials_list, 'String'));

coords = [str2double(get(handles.sag_ML, 'String')),...
    str2double(get(handles.coronal_AP, 'String')), str2double(get(handles.DV, 'String'))];

handles.mri_fiducials{end+1} = {newname, coords, val_in_list+1};

list = get(handles.mri_fiducials_list, 'String');
list{end+1} = [newname ': (' num2str(coords(1)) ',' num2str(coords(2)) ',' num2str(coords(3)) ')'];
set(handles.mri_fiducials_list, 'String', list);
handles = plot_fiducials(handles);
guidata(hObject, handles);


% --- Executes on button press in rm_fiducial.
function rm_fiducial_Callback(hObject, eventdata, handles)
% hObject    handle to rm_fiducial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(handles.mri_fiducials_list, 'Value');

% Remove this value;
for i = 1:length(handles.mri_fiducials)
    if handles.mri_fiducials{i}{3} > val
        handles.mri_fiducials{i}{3} = handles.mri_fiducials{i}{3} - 1;
    end
end
for i = 1:length(handles.mri_fiducials)
    if handles.mri_fiducials{i}{3} == val
        if i == length(handles.mri_fiducials)
            handles.mri_fiducials = {handles.mri_fiducials{1:i-1}};
        elseif i == 1
            handles.mri_fiducials = {handles.mri_fiducials{i+1:end}};
        else
            handles.mri_fiducials = {handles.mri_fiducials{1:i-1}, handles.mri_fiducials{i+1:end}};
        end
        break
    end
end

list = {};
for i = 1:length(handles.mri_fiducials)
    nm  = handles.mri_fiducials{i}{1};
    coords = handles.mri_fiducials{i}{2};
    list{end+1} = [nm ': (' num2str(coords(1)) ',' num2str(coords(2)) ',' num2str(coords(3))];
    handles.mri_fiducials{i}{3} = i;
end

if length(list) >= 1
    set(handles.mri_fiducials_list, 'Value', 1); 
else
    set(handles.mri_fiducials_list, 'Value', 0);
end

set(handles.mri_fiducials_list, 'String', list);
handles = plot_fiducials(handles);
guidata(hObject, handles);


function fiducial_id_Callback(hObject, eventdata, handles)
% hObject    handle to fiducial_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fiducial_id as text
%        str2double(get(hObject,'String')) returns contents of fiducial_id as a double


% --- Executes during object creation, after setting all properties.
function fiducial_id_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fiducial_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_mri_fiducials.
function save_mri_fiducials_Callback(hObject, eventdata, handles)
% hObject    handle to save_mri_fiducials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mri_filename = handles.mri_filename;
fiducials_filename = [mri_filename(1:end-4) '_fiducials.mat'];
mri_fiducials = handles.mri_fiducials;
disp(['Saving mri fiducials ' fiducials_filename ]); 
save(fiducials_filename, 'mri_fiducials');


% --- Executes on button press in load_mri_fiducials.
function load_mri_fiducials_Callback(hObject, eventdata, handles)
% hObject    handle to load_mri_fiducials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, path] = uigetfile('*.mat');
fiducials = load([path filename]);
handles.mri_fiducials = fiducials.mri_fiducials;
list = {};
for i = 1:length(handles.mri_fiducials)
    nm  = handles.mri_fiducials{i}{1};
    coords = handles.mri_fiducials{i}{2};
    list{end+1} = [nm ': (' num2str(coords(1)) ',' num2str(coords(2)) ',' num2str(coords(3))];
    handles.mri_fiducials{i}{3} = i;
end

set(handles.mri_fiducials_list, 'String', list);

% Plot the fiducials;
handles = plot_fiducials(handles);
guidata(hObject, handles);


% --- Executes on selection change in stereotax_fiducials_list.
function stereotax_fiducials_list_Callback(hObject, eventdata, handles)
% hObject    handle to stereotax_fiducials_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns stereotax_fiducials_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from stereotax_fiducials_list


% --- Executes during object creation, after setting all properties.
function stereotax_fiducials_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stereotax_fiducials_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ap_blk_Callback(hObject, eventdata, handles)
% hObject    handle to ap_blk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ap_blk as text
%        str2double(get(hObject,'String')) returns contents of ap_blk as a double


% --- Executes during object creation, after setting all properties.
function ap_blk_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ap_blk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ap_Callback(hObject, eventdata, handles)
% hObject    handle to ap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ap as text
%        str2double(get(hObject,'String')) returns contents of ap as a double


% --- Executes during object creation, after setting all properties.
function ap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ml_Callback(hObject, eventdata, handles)
% hObject    handle to ml (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ml as text
%        str2double(get(hObject,'String')) returns contents of ml as a double


% --- Executes during object creation, after setting all properties.
function ml_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ml (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dv_Callback(hObject, eventdata, handles)
% hObject    handle to dv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dv as text
%        str2double(get(hObject,'String')) returns contents of dv as a double


% --- Executes during object creation, after setting all properties.
function dv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in add_stereotax_fiducial.
function add_stereotax_fiducial_Callback(hObject, eventdata, handles)
% hObject    handle to add_stereotax_fiducial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stx_nms = get(handles.stereotax_selector, 'String');
stereotax_id = get(handles.stereotax_selector, 'Value');
stx_name = stx_nms{stereotax_id};

AP_blk = str2double(get(handles.ap_blk, 'String'));
AP = str2double(get(handles.ap, 'String'));
AP = AP+ AP_blk;
ML = str2double(get(handles.ml, 'String'));
DV = str2double(get(handles.dv, 'String'));

if ~isfield(handles, 'stereotax_fiducials')
    handles.stereotax_fiducials = struct();
end

if ~isfield(handles.stereotax_fiducials, stx_name)
    handles.stereotax_fiducials.(stx_name) = {};
end

val_in_list = length(get(handles.stereotax_fiducials_list, 'String'));

coords = [ML, AP, DV];

x = input('enter fiducial number: '); 
if ~isempty(x)
    name = ['f_' num2str(x)]; 
else
    name = ['f_' num2str(val_in_list+1)];
end
handles.stereotax_fiducials.(stx_name){end+1} = {name, coords, val_in_list+1};

list = get(handles.stereotax_fiducials_list, 'String');
list{end+1} = [name ': (' num2str(coords(1)) ',' num2str(coords(2)) ',' num2str(coords(3)) ')'];
set(handles.stereotax_fiducials_list, 'String', list);
guidata(hObject, handles);

% --- Executes on button press in rm_stereotax_fiducial.
function rm_stereotax_fiducial_Callback(hObject, eventdata, handles)
% hObject    handle to rm_stereotax_fiducial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in rm_fiducial.
stx_nms = get(handles.stereotax_selector, 'String');
stereotax_id = get(handles.stereotax_selector, 'Value');
stx_name = stx_nms{stereotax_id};

val = get(handles.stereotax_fiducials_list, 'Value');

% Remove this value;
for i = 1:length(handles.stereotax_fiducials.(stx_name))
    if handles.stereotax_fiducials.(stx_name){i}{3} > val
        handles.stereotax_fiducials.(stx_name){i}{3} = handles.stereotax_fiducials.(stx_name){i}{3} - 1;
    end
end
for i = 1:length(handles.stereotax_fiducials.(stx_name))
    if handles.stereotax_fiducials.(stx_name){i}{3} == val
        if i == length(handles.stereotax_fiducials.(stx_name))
            handles.stereotax_fiducials.(stx_name) = {handles.stereotax_fiducials.(stx_name){1:i-1}};
        elseif i == 1
            handles.stereotax_fiducials.(stx_name) = {handles.stereotax_fiducials.(stx_name){i+1:end}};
        else
            handles.stereotax_fiducials.(stx_name) = {handles.stereotax_fiducials.(stx_name){1:i-1}, handles.stereotax_fiducials.(stx_name){i+1:end}};
        end
        break
    end
end

list = {};
for i = 1:length(handles.stereotax_fiducials.(stx_name))
    nm  = handles.stereotax_fiducials.(stx_name){i}{1};
    coords = handles.stereotax_fiducials.(stx_name){i}{2};
    list{end+1} = [nm ': (' num2str(coords(1)) ',' num2str(coords(2)) ',' num2str(coords(3))];
    handles.stereotax_fiducials.(stx_name){i}{3} = i;
end

if length(list) >= 1
    set(handles.stereotax_fiducials_list, 'Value', 1);
else
    set(handles.stereotax_fiducials_list, 'Value', 0);
end

set(handles.stereotax_fiducials_list, 'String', list);
guidata(hObject, handles);


% --- Executes on selection change in stereotax_selector.
function stereotax_selector_Callback(hObject, eventdata, handles)
% hObject    handle to stereotax_selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns stereotax_selector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from stereotax_selector
stx_nms = get(handles.stereotax_selector, 'String');
stereotax_id = get(handles.stereotax_selector, 'Value');
stx_name = stx_nms{stereotax_id};

list = {};
if ~isfield(handles, 'stereotax_fiducials')
    handles.stereotax_fiducials = struct();
end

if ~isfield(handles.stereotax_fiducials, stx_name)
    handles.stereotax_fiducials.(stx_name) = {};
end

for i = 1:length(handles.stereotax_fiducials.(stx_name))
    nm  = handles.stereotax_fiducials.(stx_name){i}{1};
    coords = handles.stereotax_fiducials.(stx_name){i}{2};
    list{end+1} = [nm ': (' num2str(coords(1)) ',' num2str(coords(2)) ',' num2str(coords(3))];
    handles.stereotax_fiducials.(stx_name){i}{3} = i;
end

set(handles.stereotax_fiducials_list, 'String', list);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function stereotax_selector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stereotax_selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_stereotax_fiducials.
function save_stereotax_fiducials_Callback(hObject, eventdata, handles)
% hObject    handle to save_stereotax_fiducials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mri_filename = handles.mri_filename;

stx_nms = get(handles.stereotax_selector, 'String');
stereotax_id = get(handles.stereotax_selector, 'Value');
stx_name = stx_nms{stereotax_id};

fiducials_filename = [mri_filename(1:end-4) '_stereotax' stx_name '.mat'];
stereotax_fiducials = handles.stereotax_fiducials.(stx_name);
stereotax_name = stx_name;
save(fiducials_filename, 'stereotax_fiducials', 'stereotax_name');

% --- Executes on button press in load_stereotax_fiducials.
function load_stereotax_fiducials_Callback(hObject, eventdata, handles)
% hObject    handle to load_stereotax_fiducials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, path] = uigetfile('*.mat');
fiducials = load([path filename]);

stereotax_name = fiducials.stereotax_name;
nms = get(handles.stereotax_selector, 'String');
stx_name = '';
for i = 1:length(nms)
    if strcmp(stereotax_name, nms{i})
        stx_name = nms{i};
        set(handles.stereotax_selector, 'Value', i);
    end
end

if strcmp(stx_name, '')
    disp(['load_stereotax_fiducials_Callback: we dont support this stereotax now ' stereotax_name]);
else
    
    if ~isfield(handles, 'stereotax_fiducials')
        handles.stereotax_fiducials = struct();
    end
    if ~isfield(handles.stereotax_fiducials, stx_name)
        handles.stereotax_fiducials.(stx_name) = {};
    end
    handles.stereotax_fiducials.(stx_name) = fiducials.stereotax_fiducials;
    
    list = {};
    for i = 1:length(handles.stereotax_fiducials.(stx_name))
        nm  = handles.stereotax_fiducials.(stx_name){i}{1};
        coords = handles.stereotax_fiducials.(stx_name){i}{2};
        list{end+1} = [nm ': (' num2str(coords(1)) ',' num2str(coords(2)) ',' num2str(coords(3))];
        handles.stereotax_fiducials.(stx_name){i}{3} = i;
    end
    
    set(handles.stereotax_fiducials_list, 'String', list);
end

guidata(hObject, handles);


% --- Executes on button press in transform_fiducials_to_stereotax.
function transform_fiducials_to_stereotax_Callback(hObject, eventdata, handles)
% hObject    handle to transform_fiducials_to_stereotax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stx_nms = get(handles.stereotax_selector, 'String');
stereotax_id = get(handles.stereotax_selector, 'Value');
stx_name = stx_nms{stereotax_id};

% Get fiducial points
nFids = length(handles.mri_fiducials);
mri_pts = []; mri_pts_id = []; 

mri_tgs = [];
mri_tgs_labels = {}; 

for i = 1:nFids
    % This is a fiducial then;
    if strfind(handles.mri_fiducials{i}{1}, 'f_') == 1
        mri_pts = [mri_pts; handles.mri_fiducials{i}{2}];
        mri_pts_id = [mri_pts_id; str2double(handles.mri_fiducials{i}{1}(3:end))]; 
    else
        % This is a target brain region
        tmp = strfind(handles.mri_fiducials{i}{1}, 't_');
        if or(tmp == 1, tmp(1) == 1)
            mri_tgs = [mri_tgs; handles.mri_fiducials{i}{2}]; % ML / AP / DV
            mri_tgs_labels{end+1} = handles.mri_fiducials{i}{1}; 
        end
    end
end

stx_pts = [];stx_pts_id = []; 
nFids = length(handles.stereotax_fiducials.(stx_name));
for i = 1:nFids
    assert(strfind(handles.stereotax_fiducials.(stx_name){i}{1}(1:2), 'f_')==1)
    stx_pts = [stx_pts; handles.stereotax_fiducials.(stx_name){i}{2}];
    stx_pts_id = [stx_pts_id; str2double(handles.stereotax_fiducials.(stx_name){i}{1}(3:end))]; 
end

assert(size(mri_pts, 2) == 3)

stx_pts_indices = []; 
mri_pts_indices = []; 
for i = 1:length(mri_pts_id)
    ix = find(stx_pts_id == mri_pts_id(i)); 
    if length(ix) == 1
        stx_pts_indices = [stx_pts_indices; ix]; 
        mri_pts_indices = [mri_pts_indices; i]; 
    elseif length(ix) > 1
        disp('error more than 1 stx fiducial for an mri fiducial')
    end
end

handles.mri_pts_indices = mri_pts_indices; 
handles.stx_pts_indices = stx_pts_indices; 

mri_pts = mri_pts(mri_pts_indices, :); 
stx_pts = stx_pts(stx_pts_indices, :); 

assert(size(mri_pts, 1) == size(stx_pts, 1))
assert(size(mri_pts, 2) == size(stx_pts, 2))

% Transform
fiducial_pts_1 = mri_pts'; % 3 x N
fiducial_pts_2 = stx_pts'; % 3 x N;

handles.transform_matrix = TransformationMatrix(fiducial_pts_1, fiducial_pts_2);

% Now transform target points 
% Add ones to the end to allow for offset 
% N x 3 --> N x 4; 
if ~isempty(mri_tgs)
    mri_tgs = [mri_tgs ones(size(mri_tgs, 1), 1)]; 

    % N x 4; 
    trans_mri_tgs = (handles.transform_matrix*mri_tgs')'; 

    % Add these to the 
    list = {};
    for i = 1:length(mri_tgs_labels)
        list{i} = [mri_tgs_labels{i} ': ml ' num2str(trans_mri_tgs(i, 1))...
                                     ', ap ' num2str(trans_mri_tgs(i, 2))...
                                     ', dv ' num2str(trans_mri_tgs(i, 3))]; 
    end

    set(handles.transformed_t, 'String', list); 
end
guidata(hObject, handles);


% --- Executes on selection change in transformed_t.
function transformed_t_Callback(hObject, eventdata, handles)
% hObject    handle to transformed_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns transformed_t contents as cell array
%        contents{get(hObject,'Value')} returns selected item from transformed_t


% --- Executes during object creation, after setting all properties.
function transformed_t_CreateFcn(hObject, eventdata, handles)
% hObject    handle to transformed_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in surfaces_list.
function surfaces_list_Callback(hObject, eventdata, handles)
% hObject    handle to surfaces_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns surfaces_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from surfaces_list


% --- Executes during object creation, after setting all properties.
function surfaces_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to surfaces_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_surfaces.
function load_surfaces_Callback(hObject, eventdata, handles)
% hObject    handle to load_surfaces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, path] = uigetfile('*.gii');

% Use the filename to label this;
if ~isfield(handles, 'brain_surfaces')
    handles.brain_surfaces = {};
    handles.brain_surfaces_handles = {};
end

% Load the gifti mesh
mesh = ft_read_headshape([path filename], 'format', 'gifti', 'coordsys', 'acpc', 'unit', 'mm');

% Transform to ijk space
ijk_mesh = ft_transform_geometry(inv(handles.mri.transform), mesh);

% Also add to the list
list = get(handles.surfaces_list, 'String');
list{end+1} = filename;
set(handles.surfaces_list, 'String', list);

L = length(list);

% Add to the list of brain surfaces
handles.brain_surfaces{end+1} = {filename, ijk_mesh, L};
handles.brain_surfaces_handles{end+1} = [];

guidata(hObject, handles);


% --- Executes on button press in minus_surface.
function minus_surface_Callback(hObject, eventdata, handles)
% hObject    handle to minus_surface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(handles.surfaces_list, 'Value');

% Remove this value;
for i = 1:length(handles.brain_surfaces)
    if handles.brain_surfaces{i}{3} == val
        if i == length(handles.brain_surfaces)
            handles.brain_surfaces = {handles.brain_surfaces{1:i-1}};
            handles.brain_surfaces_handles = {handles.brain_surfaces_handles{1:i-1}};
        elseif i == 1
            handles.brain_surfaces = {handles.brain_surfaces{i+1:end}};
            handles.brain_surfaces_handles = {handles.brain_surfaces_handles{i+1:end}};
        else
            handles.brain_surfaces = {handles.brain_surfaces{1:i-1}, handles.brain_surfaces{i+1:end}};
            handles.brain_surfaces_handles = {handles.brain_surfaces_handles{1:i-1}, handles.brain_surfaces_handles{i+1:end}};
        end
        break
    end
end

list = {};
for i = 1:length(handles.brain_surfaces)
    nm  = handles.brain_surfaces{i}{1};
    list{i} = nm;
    handles.brain_surfaces{i}{3} = i;
end

set(handles.surfaces_list, 'String', list);
guidata(hObject, handles);

% --- Executes on button press in toggle_surfaces.
function toggle_surfaces_Callback(hObject, eventdata, handles)
% hObject    handle to toggle_surfaces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toggle_surfaces
val = get(handles.toggle_surfaces, 'Value');
handles.surf_toggle = val;
guidata(hObject, handles);


% --- Executes on selection change in angcalc_stx_selector.
function angcalc_stx_selector_Callback(hObject, eventdata, handles)
% hObject    handle to angcalc_stx_selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns angcalc_stx_selector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from angcalc_stx_selector

stxs = get(handles.angcalc_stx_selector, 'String'); 
vl = get(handles.angcalc_stx_selector, 'Value'); 
stx_name = stxs{vl}; 

if ~isfield(handles.angle_calc_list1, stx_name)
    handles.angle_calc_list1.(stx_name) = {}; 
end

if ~isfield(handles.angle_calc_list2, stx_name)
    handles.angle_calc_list2.(stx_name) = {}; 
end
    
list1 = {}; 
list2 = {}; 
for i = 1:size(handles.angle_calc_list1.(stx_name), 2)
    
    list1{i} = [num2str(handles.angle_calc_list1.(stx_name){i}(1)) ','...
        num2str(handles.angle_calc_list1.(stx_name){i}(2)) ','...
        num2str(handles.angle_calc_list1.(stx_name){i}(3))]; 
    
    set(handles.angle_1, 'String', num2str(handles.angle_calc_list1.(stx_name){i}(1)))
end

if size(handles.angle_calc_list1.(stx_name)) == 0
    set(handles.angle_1, 'String', '0'); 
end
if size(handles.angle_calc_list2.(stx_name)) == 0
    set(handles.angle_2, 'String', '0'); 
end

for i = 1:size(handles.angle_calc_list2.(stx_name), 2)

    list2{i} = [num2str(handles.angle_calc_list2.(stx_name){i}(1)) ','...
        num2str(handles.angle_calc_list2.(stx_name){i}(2)) ','...
        num2str(handles.angle_calc_list2.(stx_name){i}(3))]; 
    
    set(handles.angle_2, 'String', num2str(handles.angle_calc_list2.(stx_name){i}(1)))
end

set(handles.angcalc_list1,'String', list1); 
set(handles.angcalc_list2,'String', list2); 

guidata(hObject, handles);

    
    
    
% --- Executes during object creation, after setting all properties.
function angcalc_stx_selector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to angcalc_stx_selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in angcalc_list1.
function angcalc_list1_Callback(hObject, eventdata, handles)
% hObject    handle to angcalc_list1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns angcalc_list1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from angcalc_list1


% --- Executes during object creation, after setting all properties.
function angcalc_list1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to angcalc_list1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in angcalc_list2.
function angcalc_list2_Callback(hObject, eventdata, handles)
% hObject    handle to angcalc_list2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns angcalc_list2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from angcalc_list2


% --- Executes during object creation, after setting all properties.
function angcalc_list2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to angcalc_list2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function angle_1_Callback(hObject, eventdata, handles)
% hObject    handle to angle_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of angle_1 as text
%        str2double(get(hObject,'String')) returns contents of angle_1 as a double


% --- Executes during object creation, after setting all properties.
function angle_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to angle_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function angle_2_Callback(hObject, eventdata, handles)
% hObject    handle to angle_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of angle_2 as text
%        str2double(get(hObject,'String')) returns contents of angle_2 as a double


% --- Executes during object creation, after setting all properties.
function angle_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to angle_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function angcalc_ml_1_Callback(hObject, eventdata, handles)
% hObject    handle to angcalc_ml_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of angcalc_ml_1 as text
%        str2double(get(hObject,'String')) returns contents of angcalc_ml_1 as a double


% --- Executes during object creation, after setting all properties.
function angcalc_ml_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to angcalc_ml_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function angcalc_dv_1_Callback(hObject, eventdata, handles)
% hObject    handle to angcalc_dv_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of angcalc_dv_1 as text
%        str2double(get(hObject,'String')) returns contents of angcalc_dv_1 as a double


% --- Executes during object creation, after setting all properties.
function angcalc_dv_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to angcalc_dv_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in angcalc_add1.
function angcalc_add1_Callback(hObject, eventdata, handles)
% hObject    handle to angcalc_add1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
angle = str2double(get(handles.angle_1, 'String')); 
ml = str2double(get(handles.angcalc_ml_1, 'String')); 
dv = str2double(get(handles.angcalc_dv_1, 'String')); 

stxs = get(handles.angcalc_stx_selector, 'String'); 
vl = get(handles.angcalc_stx_selector, 'Value'); 
stx_name = stxs{vl}; 

if ~isfield(handles, 'angle_calc_list1')
    handles.angle_calc_list1 = struct(); 
    handles.angle_calc_list1.(stx_name) = {}; 
elseif ~isfield(handles.angle_calc_list1, stx_name)
    handles.angle_calc_list1.(stx_name) = {}; 
end

list = get(handles.angcalc_list1, 'String'); 
L = length(list); 

handles.angle_calc_list1.(stx_name){end+1} = [angle, ml, dv, L+1]; 
list{end+1} = [num2str(angle) ',' num2str(ml) ',' num2str(dv)]; 
if length(list) > 0
    set(handles.angcalc_list1, 'Value', 1);
end
set(handles.angcalc_list1, 'String', list); 
guidata(hObject, handles);



% --- Executes on button press in angcalc_rm1.
function angcalc_rm1_Callback(hObject, eventdata, handles)
% hObject    handle to angcalc_rm1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val_rm = get(handles.angcalc_list1, 'Value'); 

stxs = get(handles.angcalc_stx_selector, 'String'); 
vl = get(handles.angcalc_stx_selector, 'Value'); 
stx_name = stxs{vl}; 


for i = 1:length(handles.angle_calc_list1.(stx_name))
    if handles.angle_calc_list1.(stx_name){i}(4) == val_rm
        if i == 1
            handles.angle_calc_list1.(stx_name) = {handles.angle_calc_list1.(stx_name){i+1:end}}; 
        elseif i== length(handles.angle_calc_list1.(stx_name))
            handles.angle_calc_list1.(stx_name) = {handles.angle_calc_list1.(stx_name){1:i-1}}; 
        else
            handles.angle_calc_list1.(stx_name) = {handles.angle_calc_list1.(stx_name){1:i-1}, handles.angle_calc_list1.(stx_name){i+1:end}}; 
        end
        break
    end
end

list = {};
for i = 1:length(handles.angle_calc_list1.(stx_name))
    coords = handles.angle_calc_list1.(stx_name){i}(1:3); 
    list{end+1} = [num2str(coords(1)) ',' num2str(coords(2)) ',' num2str(coords(3))];
    handles.angle_calc_list1.(stx_name){i}(4) = i;
end

if length(list) >= 1
    set(handles.angcalc_list1, 'Value', 1); 
else
    set(handles.angcalc_list1, 'Value', 0);
end

set(handles.angcalc_list1, 'String', list);
guidata(hObject, handles);

function angcalc_ml_2_Callback(hObject, eventdata, handles)
% hObject    handle to angcalc_ml_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of angcalc_ml_2 as text
%        str2double(get(hObject,'String')) returns contents of angcalc_ml_2 as a double


% --- Executes during object creation, after setting all properties.
function angcalc_ml_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to angcalc_ml_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function angcalc_dv_2_Callback(hObject, eventdata, handles)
% hObject    handle to angcalc_dv_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of angcalc_dv_2 as text
%        str2double(get(hObject,'String')) returns contents of angcalc_dv_2 as a double


% --- Executes during object creation, after setting all properties.
function angcalc_dv_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to angcalc_dv_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in angcalc_add2.
function angcalc_add2_Callback(hObject, eventdata, handles)
% hObject    handle to angcalc_add2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
angle = str2double(get(handles.angle_2, 'String')); 
ml = str2double(get(handles.angcalc_ml_2, 'String')); 
dv = str2double(get(handles.angcalc_dv_2, 'String')); 

stxs = get(handles.angcalc_stx_selector, 'String'); 
vl = get(handles.angcalc_stx_selector, 'Value'); 
stx_name = stxs{vl}; 

if ~isfield(handles, 'angle_calc_list2')
    handles.angle_calc_list2 = struct(); 
    handles.angle_calc_list2.(stx_name) = {}; 
elseif ~isfield(handles.angle_calc_list2, stx_name)
    handles.angle_calc_list2.(stx_name) = {}; 
end

list = get(handles.angcalc_list2, 'String'); 
L = length(list); 

handles.angle_calc_list2.(stx_name){end+1} = [angle, ml, dv, L+1]; 
list{end+1} = [num2str(angle) ',' num2str(ml) ',' num2str(dv)]; 
if length(list) > 0
    set(handles.angcalc_list2, 'Value', 1);
end
set(handles.angcalc_list2, 'String', list); 
guidata(hObject, handles);

% --- Executes on button press in angcalc_rm2.
function angcalc_rm2_Callback(hObject, eventdata, handles)
% hObject    handle to angcalc_rm2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val_rm = get(handles.angcalc_list2, 'Value'); 

stxs = get(handles.angcalc_stx_selector, 'String'); 
vl = get(handles.angcalc_stx_selector, 'Value'); 
stx_name = stxs{vl}; 


for i = 1:length(handles.angle_calc_list2.(stx_name))
    if handles.angle_calc_list2.(stx_name){i}(4) == val_rm
        if i == 1
            handles.angle_calc_list2.(stx_name) = {handles.angle_calc_list2.(stx_name){i+1:end}}; 
        elseif i== length(handles.angle_calc_list2.(stx_name))
            handles.angle_calc_list2.(stx_name) = {handles.angle_calc_list2.(stx_name){1:i-1}}; 
        else
            handles.angle_calc_list2.(stx_name) = {handles.angle_calc_list2.(stx_name){1:i-1}, handles.angle_calc_list2.(stx_name){i+1:end}}; 
        end
        break
    end
end

list = {};
for i = 1:length(handles.angle_calc_list2.(stx_name))
    coords = handles.angle_calc_list2.(stx_name){i}(1:3); 
    list{end+1} = [num2str(coords(1)) ',' num2str(coords(2)) ',' num2str(coords(3))];
    handles.angle_calc_list2.(stx_name){i}(4) = i;
end

if length(list) >= 1
    set(handles.angcalc_list2, 'Value', 1); 
else
    set(handles.angcalc_list2, 'Value', 0);
end

set(handles.angcalc_list2, 'String', list);
guidata(hObject, handles);

% --- Executes on button press in angcalc_calc.
function angcalc_calc_Callback(hObject, eventdata, handles)
% hObject    handle to angcalc_calc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

stxs = get(handles.angcalc_stx_selector, 'String'); 
vl = get(handles.angcalc_stx_selector, 'Value'); 
stx_name = stxs{vl};

% Make sure same length of points and same angles 
assert(length(handles.angle_calc_list1.(stx_name)) == length(handles.angle_calc_list2.(stx_name)))
L = length(handles.angle_calc_list1.(stx_name));

angle1 = handles.angle_calc_list1.(stx_name){1}(1);
angle2 = handles.angle_calc_list2.(stx_name){1}(1);

pt1 = [handles.angle_calc_list1.(stx_name){1}(2:3)];
pt2 = [handles.angle_calc_list2.(stx_name){1}(2:3)];


for i = 2:L
    assert(handles.angle_calc_list1.(stx_name){i}(1) == angle1)
    assert(handles.angle_calc_list2.(stx_name){i}(1) == angle2)
    
    % Pts x 2 
    pt1 = [pt1; handles.angle_calc_list1.(stx_name){i}(2:3)];
    pt2 = [pt2; handles.angle_calc_list2.(stx_name){i}(2:3)];

end

dAng = angle2 - angle1; % degrees; 
dRad = dAng / 180 * pi; % radians 

% Transforms 
rotMx = [cos(dRad) -sin(dRad); 
         sin(dRad)  cos(dRad)]; 
     
% pt' = (R*(pt - d)) + d
% pt' - d = R*pt - R*d
% pt' - R*pt = -R*d + d
% pt' - R*pt = (I - R)*d
% (I -  R)^-1 (pt' - R*pt) = d; 

IRinv = inv(eye(2) - rotMx); % 2 x 2 
dest = IRinv* (pt2' - (rotMx*pt1')); % 2 x T 

dmean = mean(dest, 2); 
dstd = std(dest, [], 2); 

if ~isfield(handles, 'angle_calc_d')
    handles.angle_calc_d = struct(); 
end

if ~isfield(handles.angle_calc_d, stx_name)
    handles.angle_calc_d.(stx_name) = struct(); 
end

dataset_nm = ['A_' num2str(angle1) '_' num2str(angle2)];
display_str = ['mn: ' num2str(dmean(1)) ' ( ' num2str(dstd(1)) '), ' num2str(dmean(2)) ' ( ' num2str(dstd(2)) ')']; 
handles.angle_calc_d.(stx_name).(dataset_nm) = {pt1, pt2, dest, dmean, dstd, display_str}; 
set(handles.angcalc_offset_est, 'String', display_str)

guidata(hObject, handles);

% --- Executes on button press in angcalc_save.
function angcalc_save_Callback(hObject, eventdata, handles)
% hObject    handle to angcalc_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stxs = get(handles.angcalc_stx_selector, 'String'); 
vl = get(handles.angcalc_stx_selector, 'Value'); 
stx_name = stxs{vl};

angle1 = handles.angle_calc_list1.(stx_name){1}(1);
angle2 = handles.angle_calc_list2.(stx_name){1}(1);
dataset_nm = ['A_' num2str(angle1) '_' num2str(angle2)];

pt1 = handles.angle_calc_d.(stx_name).(dataset_nm){1}; 
pt2 = handles.angle_calc_d.(stx_name).(dataset_nm){2}; 
dest = handles.angle_calc_d.(stx_name).(dataset_nm){3}; 
dmean = handles.angle_calc_d.(stx_name).(dataset_nm){4}; 
dstd = handles.angle_calc_d.(stx_name).(dataset_nm){5}; 
display_str = handles.angle_calc_d.(stx_name).(dataset_nm){6}; 

mri_filename = handles.mri_filename;
dmean_filename = [mri_filename(1:end-4) '_' stx_name '_' dataset_nm '.mat'];
disp(['saving offset info: ' dmean_filename]); 
save(dmean_filename, 'pt1', 'pt2', 'dest', 'dmean', 'dstd', 'display_str',...
'stx_name', 'dataset_nm', 'angle1', 'angle2');

guidata(hObject, handles);

% --- Executes on button press in angcalc_load.
function angcalc_load_Callback(hObject, eventdata, handles)
% hObject    handle to angcalc_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, path] = uigetfile('*.mat');

data = load([path filename]); 

dt = {data.pt1, data.pt2, data.dest, data.dmean, data.dstd, data.display_str}; 

if ~isfield(handles, 'angle_calc_d')
    handles.angle_calc_d = struct(); 
end
stx_name = data.stx_name; 
if ~isfield(handles.angle_calc_d, stx_name)
    handles.angle_calc_d.(stx_name) = struct(); 
end

stx_opts = get(handles.angcalc_stx_selector, 'String'); 
for s= 1:length(stx_opts)
    if strmatch(stx_opts{s}, stx_name)
        set(handles.angcalc_stx_selector, 'Value', s);
    end
end

handles.angle_calc_d.(data.stx_name).(data.dataset_nm) = dt; 

% Display 
set(handles.angcalc_offset_est, 'String', data.display_str); 

% Render lists
handles.angle_calc_list1.(stx_name) = {}; 
handles.angle_calc_list2.(stx_name) = {}; 
list1 = {}; 
list2 = {}; 
for i = 1:size(data.pt1, 1)
    
    % Add to 
    handles.angle_calc_list1.(stx_name){i} = [data.angle1, data.pt1(i, 1), data.pt1(i, 2), i]; 
    handles.angle_calc_list2.(stx_name){i} = [data.angle2, data.pt2(i, 1), data.pt2(i, 2), i]; 
    
    list1{i} = [num2str(data.angle1) ',' num2str(data.pt1(i, 1)) ',' num2str(data.pt1(i, 2))]; 
    list2{i} = [num2str(data.angle2) ',' num2str(data.pt2(i, 1)) ',' num2str(data.pt2(i, 2))]; 

end
set(handles.angcalc_list1,'String', list1); 
set(handles.angcalc_list2,'String', list2); 

set(handles.angle_1, 'String', num2str(data.angle1))
set(handles.angle_2, 'String', num2str(data.angle2))

guidata(hObject, handles);



function calc_ML_Callback(hObject, eventdata, handles)
% hObject    handle to calc_ML (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of calc_ML as text
%        str2double(get(hObject,'String')) returns contents of calc_ML as a double


% --- Executes during object creation, after setting all properties.
function calc_ML_CreateFcn(hObject, eventdata, handles)
% hObject    handle to calc_ML (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function calc_DV_Callback(hObject, eventdata, handles)
% hObject    handle to calc_DV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of calc_DV as text
%        str2double(get(hObject,'String')) returns contents of calc_DV as a double


% --- Executes during object creation, after setting all properties.
function calc_DV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to calc_DV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function calc_ang1_Callback(hObject, eventdata, handles)
% hObject    handle to calc_ang1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of calc_ang1 as text
%        str2double(get(hObject,'String')) returns contents of calc_ang1 as a double


% --- Executes during object creation, after setting all properties.
function calc_ang1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to calc_ang1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function calc_ang2_Callback(hObject, eventdata, handles)
% hObject    handle to calc_ang2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of calc_ang2 as text
%        str2double(get(hObject,'String')) returns contents of calc_ang2 as a double


% --- Executes during object creation, after setting all properties.
function calc_ang2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to calc_ang2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in convert_angle.
function convert_angle_Callback(hObject, eventdata, handles)
% hObject    handle to convert_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get stereotax; 
stx_nms = get(handles.stereotax_selector, 'String');
stereotax_id = get(handles.stereotax_selector, 'Value');
stx_name = stx_nms{stereotax_id};

% Get data from the most recent data; 
angle1 = handles.angle_calc_list1.(stx_name){1}(1);
angle2 = handles.angle_calc_list2.(stx_name){1}(1);
dataset_nm = ['A_' num2str(angle1) '_' num2str(angle2)];
disp(['Using dataset ' dataset_nm ', if you want to use another dataset, load it directly']); 

% dmean; 
dmean = handles.angle_calc_d.(stx_name).(dataset_nm){4}; 
dstd = handles.angle_calc_d.(stx_name).(dataset_nm){5}; 

dAngle = str2double(get(handles.calc_ang2, 'String')) - str2double(get(handles.calc_ang1, 'String'));
dRad = dAngle / 180 * pi; 

% 2 x 1 vector
pt1 = [str2double(get(handles.calc_ML, 'String'));  str2double(get(handles.calc_DV, 'String'))];
pt1_mx = pt1;
pt1_mx(1) = pt1_mx(1) + dstd(1); 
pt1_mx(2) = pt1_mx(2) + dstd(2); 

pt1_mn = pt1;
pt1_mn(1) = pt1_mn(1) - dstd(1); 
pt1_mn(2) = pt1_mn(2) - dstd(2); 


pt1_demean = pt1 - dmean; 
pt1_mx_d = pt1_mx - dmean; 
pt1_mn_d = pt1_mn - dmean; 

% Transforms 
rotMx = [cos(dRad) -sin(dRad); 
         sin(dRad)  cos(dRad)]; 
     
pt2_demean = rotMx*pt1_demean; 
pt2_mx_demean = rotMx*pt1_mx_d; 
pt2_mn_demean = rotMx*pt1_mn_d; 

assert(size(pt2_demean, 1) == 2)
assert(size(pt2_demean, 2) == 1)

% Add back the mean 
pt2 = pt2_demean + dmean; 
dpt2 = abs(pt2_mx_demean - pt2_mn_demean);

str = ['ML: ' num2str(pt2(1)) ' ( ' num2str(dpt2(1)) '), DV: ' num2str(pt2(2)) ' ( ' num2str(dpt2(2)) ')']; 
set(handles.estimated_ml_dv, 'String', str); 
guidata(hObject, handles);


% --- Executes on button press in calc_TRE.
function calc_TRE_Callback(hObject, eventdata, handles)
% hObject    handle to calc_TRE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

stx_nms = get(handles.stereotax_selector, 'String');
stereotax_id = get(handles.stereotax_selector, 'Value');
stx_name = stx_nms{stereotax_id};

% Get fiducial points
nFids = length(handles.mri_fiducials);
mri_pts = [];
mri_tgs = [];
mri_tgs_labels = {}; 

for i = 1:nFids
    % This is a fiducial then;
    if strfind(handles.mri_fiducials{i}{1}, 'f_') == 1
        mri_pts = [mri_pts; handles.mri_fiducials{i}{2}];
    elseif strfind(handles.mri_fiducials{i}{1}, 't_') == 1
        mri_tgs = [mri_tgs; handles.mri_fiducials{i}{2}]; % ML / AP / DV
        mri_tgs_labels{end+1} = handles.mri_fiducials{i}{1}; 
    end
end

stx_pts = [];
nFids = length(handles.stereotax_fiducials.(stx_name));
for i = 1:nFids
    assert(strfind(handles.stereotax_fiducials.(stx_name){i}{1}(1:2), 'f_')==1)
    stx_pts = [stx_pts; handles.stereotax_fiducials.(stx_name){i}{2}];
end

% Use previously defined MRI / STX pts indices 
mri_pts = mri_pts(handles.mri_pts_indices, :); 
stx_pts = stx_pts(handles.stx_pts_indices, :); 
assert(size(mri_pts, 1) == size(stx_pts, 1)); 

% Get out error and axes
[r_ax, a_ax, s_ax, err] = compute_TRE(handles, mri_pts, stx_pts); 
[Nr, Na, Ns] = size(err); 

% For each target figure out error % 
for t=1:size(mri_tgs, 1)
    
    % target 
    tg = mri_tgs(t, :); 
    
    % find closest error; 
    [~, ix_r] = min(abs(r_ax-tg(1)));
    [~, ix_a] = min(abs(a_ax-tg(2)));
    [~, ix_s] = min(abs(s_ax-tg(3)));
    
    disp([ mri_tgs_labels{t} ' est. error: ' num2str(err(ix_r, ix_a, ix_s))]);
end

% Save if we want to save for later % 
handles.TRE = {r_ax, a_ax, s_ax, err};

% Plot figure with TRE
figure; 
AX = {r_ax, a_ax, s_ax};
clim = [prctile(err, 10, 'all'), prctile(err, 90, 'all')]; 
subplot(131); 
s=pcolor(AX{1}, AX{2}, err(:, :, round(Ns/2))');
s.LineStyle = 'none'; 
set(gca, 'clim', clim);
hold all; 
plot(mri_pts(:, 1), mri_pts(:, 2), 'w.'); 
xlabel('L <--> R')
ylabel('P <--> A'); 
title('Axial')

subplot(132); 
s=pcolor(AX{2}, AX{3}, squeeze(err(round(Nr/2), :, :))');
s.LineStyle = 'none'; 
set(gca, 'clim', clim); 
hold all;
plot(mri_pts(:, 2), mri_pts(:, 3), 'w.'); 
xlabel('P <--> A'); 
ylabel('I <--> S')
title('Sag.')

subplot(133); 
s=pcolor(AX{1}, AX{3}, squeeze(err(:, round(Na/2), :))');
s.LineStyle = 'none'; 
set(gca, 'clim', clim);
hold all;
plot(mri_pts(:, 1), mri_pts(:, 3), 'w.');
xlabel('L <--> R')
ylabel('I <--> S')
title('Coronal')

colorbar()

assert(size(mri_pts, 1) == size(stx_pts, 1))
assert(size(mri_pts, 2) == size(stx_pts, 2))
assert(size(mri_pts, 2) == 3)


% Plot fiducials; 


guidata(hObject, handles);


function [r_ax, a_ax, s_ax, err] = compute_TRE(handles, fids, stx_fids)
    N = size(fids, 1); 
    fids = [fids, ones(N, 1)]; 
    T = handles.transform_matrix; 
    
    % Transform true fiducials 
    trans_fids = (T*fids')'; 
    
    % Fiducial registration error (FRE) 
    FRE2 = mean(sqrt(sum(((trans_fids(:, 1:3) - stx_fids).^2), 2))); 
    disp(['Mean FRE2 = ' num2str(FRE2)])
    
    mn_true = mean(fids, 1); 
    fids_demean = fids - repmat(mn_true, [N, 1]); 
    
    % Get principle axis of demeaned x/y/z 
    [~, ~, v] = svd(fids_demean(:, 1:3)); 
    
    r_ax = linspace(min(fids(:, 1))-10, max(fids(:, 1))+10, 60); 
    a_ax = linspace(min(fids(:, 2))-10, max(fids(:, 2))+10, 50); 
    s_ax = linspace(min(fids(:, 3))-10, max(fids(:, 3))+10, 45); 
    
    err = zeros(length(r_ax), length(a_ax), length(s_ax)); 
    
    for ir=1:length(r_ax)
        r = r_ax(ir);
        for ia=1:length(a_ax)
            a = a_ax(ia); 
            for is=1:length(s_ax)
                s = s_ax(is); 
                err(ir, ia, is) = get_TRE([r, a, s], fids(:, 1:3), mn_true(1:3), FRE2, v, N);
            end
        end
    end


function tre = get_TRE(target, fids, fid_centroid, FRE2, v, N)
    t_pa = (v'*((target - fid_centroid)'))'; 
    f_pa = (v'*(fids - repmat(fid_centroid, [N, 1]))')'; 
    
    rat = 0;
    for i = 1:3
        dk2 = t_pa(i).^2; 
        fk2 = mean(f_pa(:, i).^2); 
        rat = rat + (dk2/fk2); 
    end
    
    tre = (FRE2) / (N-2) * (1 + (1/3)*rat); 


% --- Executes on button press in save_everything.
function save_everything_Callback(hObject, eventdata, handles)
% hObject    handle to save_everything (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Basically save handles; 
mri_filename = handles.mri_filename;

% Add datetimestamp 
dttim = datestr(now,'HH:MM:SS.FFF'); 

% Get ext for notes 
ext = get(handles.save_all_ext, 'String'); 
filename = [mri_filename(1:end-4) '_' dttim '_' ext '.mat'];
save(filename, 'handles');

function save_all_ext_Callback(hObject, eventdata, handles)
% hObject    handle to save_all_ext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of save_all_ext as text
%        str2double(get(hObject,'String')) returns contents of save_all_ext as a double


% --- Executes during object creation, after setting all properties.
function save_all_ext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_all_ext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_angled_approach.
function plot_angled_approach_Callback(hObject, eventdata, handles)
% hObject    handle to plot_angled_approach (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mri_tgs = [];
mri_pts = []; 
mri_tgs_labels = {}; 

nFids = length(handles.mri_fiducials);

for i = 1:nFids
    % This is a fiducial then;
    if strfind(handles.mri_fiducials{i}{1}, 'f_') == 1
        mri_pts = [mri_pts; handles.mri_fiducials{i}{2}];
    else
        tmp = strfind(handles.mri_fiducials{i}{1}, 't_');
        if or(tmp==1, tmp(1) == 1)
            mri_tgs = [mri_tgs; handles.mri_fiducials{i}{2}]; % ML / AP / DV
            mri_tgs_labels{end+1} = handles.mri_fiducials{i}{1}; 
        end
    end
end

% Which one is highlighted ? % 
val = get(handles.transformed_t, 'Value'); 
mri_target = [mri_tgs(val, :), 1]; 
stx_target = (handles.transform_matrix*mri_target')'; 
disp(['Plotting target: ' mri_tgs_labels{val}]); 

% Now presumably these stereotaxic coordinates are in R.A.S coordinates too
angle = str2double(get(handles.angled_approach, 'String')); 

% Now in stereotaxic coordinates, focus on coronal plane; 
% Go 40 mm distance 
rad = angle / 180 * pi; 
ML_end = 40*sin(rad) + stx_target(1); 
SI_end = 40*cos(rad) + stx_target(3); 
stx_target_end = [ML_end, stx_target(2), SI_end, 1]; 

% Now transform this back to MRI coordinates
inv_trans = inv(handles.transform_matrix); 

mri_target_st = (inv_trans*stx_target')'; 
mri_target_end = (inv_trans*stx_target_end')'; 

if ~isfield(handles, 'electrode_tracts')
    handles.electrode_tracts = {}; 
end

handles.electrode_tracts{end+1} = {mri_tgs_labels{val}, mri_target_st, mri_target_end, angle}; 

list = {}; 
for i=1:length(handles.electrode_tracts)
    list{end+1}=['Ang ' num2str(handles.electrode_tracts{i}{4}) ', ' handles.electrode_tracts{i}{1}];  
end
set(handles.electrode_list, 'String', list)

% Plot a line from MRI target_st to MRI_target_end; 
handles = plot_electrode_tracts(handles);
guidata(hObject, handles);

function handles = plot_electrode_tracts(handles)

if isfield(handles, 'electrode_tract_handles')
    delete(handles.electrode_tract_handles)
end

if isfield(handles, 'electrode_tracts')
    elec_list = handles.electrode_tracts;
    
    if length(elec_list) > 0
        if length(elec_list) == 1
            colors = [0, 1, 1]; 
        else
            colors = jet(2*length(elec_list));
            % Only use the warmer colors for better viewing;
            colors = colors(length(elec_list):end, :);
        end
        handles.electrode_tract_handles = [];

        % MM to pixels % 
        inv_trans = inv(handles.mri.transform);
        
        for i = 1:length(elec_list)
            
            pos1 = [elec_list{i}{2}];
            pos2 = [elec_list{i}{3}];
            
            pos_inter = [linspace(pos1(1), pos2(1), 200)',...
                         linspace(pos1(2), pos2(2), 200)',...
                         linspace(pos1(3), pos2(3), 200)',...
                         ones(200, 1)]; 
            
            % N x 3 points; 
            
            % Go from xyz to ijk;
            ijk_inter = (inv_trans * pos_inter')';
            ijk_inter = round(ijk_inter);
           
            ix_near2 = find(abs(pos_inter(:, 2) - handles.xyz(2)) < .6); 
            if ~isempty(ix_near2) > 0
                set(gcf, 'currentaxes', handles.coronal_ax);
                hold on;
                h1 = line(ijk_inter(ix_near2, 1), ones(length(ix_near2)),...
                    ijk_inter(ix_near2, 3), 'color', colors(i, :),...
                    'linewidth', 2);
                try
                    handles.electrode_tract_handles = [handles.electrode_tract_handles h1];
                catch
                    handles.electrode_tract_handles = [handles.electrode_tract_handles; h1];
                end
                hold off;
            end
            
            ix_near3 = find(abs(pos_inter(:, 3) - handles.xyz(3))<.6); 
            if ~isempty(ix_near3)
                set(gcf, 'currentaxes', handles.ax_ax);
                hold on;
                h2 = line(ijk_inter(ix_near3, 1), ijk_inter(ix_near3, 2),...
                    zeros(length(ix_near3), 1) + size(handles.ana,3), 'color', colors(i, :),...
                    'linewidth', 2);
                try
                    handles.electrode_tract_handles = [handles.electrode_tract_handles h2];
                catch
                    handles.electrode_tract_handles = [handles.electrode_tract_handles; h2];
                end
                hold off;
            end
            
            ix_near1 = find(abs(pos_inter(:, 1) - handles.xyz(1)) < .6); 
            if ~isempty(ix_near1)
                set(gcf, 'currentaxes', handles.sag_ax);
                hold on;
                h3 = line(zeros(length(ix_near1), 1) + size(handles.ana, 1),...
                    ijk_inter(ix_near1, 2),ijk_inter(ix_near1, 3), 'color', colors(i, :),...
                    'linewidth', 2);
                try
                    handles.electrode_tract_handles = [handles.electrode_tract_handles h3];
                catch
                    handles.electrode_tract_handles = [handles.electrode_tract_handles; h3];
                end
                hold off;
            end
        end
    end
end


function angled_approach_Callback(hObject, eventdata, handles)
% hObject    handle to angled_approach (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of angled_approach as text
%        str2double(get(hObject,'String')) returns contents of angled_approach as a double


% --- Executes during object creation, after setting all properties.
function angled_approach_CreateFcn(hObject, eventdata, handles)
% hObject    handle to angled_approach (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in electrode_list.
function electrode_list_Callback(hObject, eventdata, handles)
% hObject    handle to electrode_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns electrode_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from electrode_list


% --- Executes during object creation, after setting all properties.
function electrode_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to electrode_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in clear_electrodes.
function clear_electrodes_Callback(hObject, eventdata, handles)
% hObject    handle to clear_electrodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.electrode_list, 'String', {}); 
handles.electrode_tracts = {}; 
delete(handles.electrode_tract_handles); 
% Update handles structure
guidata(hObject, handles); 


% --- Executes on button press in go_to_fid.
function go_to_fid_Callback(hObject, eventdata, handles)
% hObject    handle to go_to_fid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(handles.mri_fiducials_list, 'Value');
id = -1;
for i = 1: length(handles.mri_fiducials)
    if handles.mri_fiducials{i}{3} == val
        id = i; 
        break
    end
end

if id == -1
    disp('No fiducial available'); 
else
    xyz = handles.mri_fiducials{id}{2}; 
    handles.xyz(1) = xyz(1);
    handles.xyz(2) = xyz(2);
    handles.xyz(3) = xyz(3);
    handles = update_MRI_coordinates(handles, handles.xyz);
    guidata(hObject, handles);
end


% --- Executes on button press in compute_distance.
function compute_distance_Callback(hObject, eventdata, handles)
% hObject    handle to compute_distance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(handles.mri_fiducials_list, 'Value'); 
assert(length(val) == 2)

pt1 = handles.mri_fiducials{val(1)}{2}; 
pt2 = handles.mri_fiducials{val(2)}{2}; 

distance = norm(pt1-pt2); 
str = ['Distance: ' num2str(distance) ' mm']; 
set(handles.fid_distance, 'String', str)