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

% Last Modified by GUIDE v2.5 27-Apr-2022 19:06:15

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

name = ['f_' num2str(val_in_list+1)];
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
    MException('Fiducial_GUI:load_stereotax_fiducials_Callback',['we dont support this stereotax now ' stereotax_name]);
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
mri_pts = [];

for i = 1:nFids
    % This is a fiducial then;
    if strfind(handles.mri_handles{i}{1}, 'f_') == 1
        mri_pts = [mri_pts; handles.mri_handles{i}{2}];
    end
end

stx_pts = [];
nFids = length(handles.stereotax_fiducials.(stx_name));
for i = 1:nFids
    assert(handles.stereotax_fiducials.(stx_name){i}{1}(1:2) == 'f_')
    stx_pts = [stx_pts handles.stereotax_fiducials.(stx_name){i}{2}];
end

assert(size(mri_pts, 1) == size(stx_pts, 1))
assert(size(mri_pts, 2) == size(stx_pts, 2) == 3)

% Transform
fiducial_pts_1 = mri_pts'; % 3 x N
fiducial_pts_2 = stx_pts'; % 3 x N;

handles.transform_matrix = TransformationMatrix(fiducial_pts_1, fiducial_pts_2);


% --- Executes on selection change in listbox4.
function listbox4_Callback(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox4


% --- Executes during object creation, after setting all properties.
function listbox4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
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