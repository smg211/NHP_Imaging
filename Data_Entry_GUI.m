function varargout = Data_Entry_GUI(varargin)
% DATA_ENTRY_GUI MATLAB code for Data_Entry_GUI.fig
%      DATA_ENTRY_GUI, by itself, creates a new DATA_ENTRY_GUI or raises the existing
%      singleton*.
%
%      H = DATA_ENTRY_GUI returns the handle to a new DATA_ENTRY_GUI or the handle to
%      the existing singleton*.
%
%      DATA_ENTRY_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATA_ENTRY_GUI.M with the given input arguments.
%
%      DATA_ENTRY_GUI('Property','Value',...) creates a new DATA_ENTRY_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Data_Entry_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Data_Entry_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Data_Entry_GUI

% Last Modified by GUIDE v2.5 04-Jun-2022 15:34:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Data_Entry_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @Data_Entry_GUI_OutputFcn, ...
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


% --- Executes just before Data_Entry_GUI is made visible.
function Data_Entry_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Data_Entry_GUI (see VARARGIN)

% Choose default command line output for Data_Entry_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Data_Entry_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Fill in data table with output from Fiducial_GUI; 
h = findobj('Tag','fiducial_gui');

% if exists (not empty)
if ~isempty(h)
    % get handles and other user-defined data associated to fiducial gui
    g1data = guidata(h);
    
    % get datatable 
    tableData = get(handles.data_table,'data');
    
    % set stx data 
    [tableData, N] = populate_data_table(tableData, g1data.data_table);
    handles.N = N; 
    
    % set table data again
    set(handles.data_table, 'data', tableData); 
    
    % set stx string here 
    set(handles.stx_name, 'String', [' Stx: ' g1data.data_table_stx]); 
    
else
    disp('Cant access fiducial gui data'); 
end

guidata(hObject, handles);

function [tableData, N] = populate_data_table(tableData, gui_data)
    N = length(gui_data);
    for i = 1:N
        assert(length(gui_data{i}) == 4)
        for j = 1:4
            tableData{i, j} = gui_data{i}{j};
        end
    end
    

% --- Outputs from this function are returned to the command line.
function varargout = Data_Entry_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in plot_errors.
function plot_errors_Callback(hObject, eventdata, handles)
% hObject    handle to plot_errors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

plot_errors(handles)

function plot_errors(handles)
dataTable = get(handles.data_table, 'data'); 

% plot the errors % 
figure; 
labels = {'L<--> R', 'P <--> A', 'I <--> S'}; 
titles = {{'Axial--stx','(r:meas,b:pred)'}, {'Sag--stx','(r:meas,b:pred)'}, {'Coronal--stx','(r:meas,b:pred)'}}; 

for p = 1:3
    subplot(1,4,p); hold all; 
    ax1 = p; 
    if p+1 > 3
        ax2 = p+1 - 3; 
    else
        ax2 = p+1; 
    end
    
    if ax2 < ax1
        ax1_ = ax2; 
        ax2_ = ax1; 
        ax1 = ax1_; 
        ax2 = ax2_; 
    end
    
    for i = 1:handles.N
        if ~isempty(dataTable{i, 6})
            
            % Plot predictions 
            plot(dataTable{i, ax1+1}, dataTable{i, ax2+1}, 'k.', 'Markersize', 30) % Predictions
            text(dataTable{i, ax1+1}, dataTable{i, ax2+1}, dataTable{i, 1}, ...
                'Interpreter','None', 'fontsize', 8); 
            
            x= nan; 
            y= nan; 
            
            switch ax1
                case 1
                    x = s2d(dataTable{i, 6}); 
                case 2
                    x = s2d(dataTable{i, 7}) + s2d(dataTable{i, 8}); 
                case 3
                    x = s2d(dataTable{i, 9}); 
            end
            
            switch ax2
                case 1
                    y = s2d(dataTable{i, 6}); 
                case 2
                    y = s2d(dataTable{i, 7}) + s2d(dataTable{i, 8}); 
                case 3
                    y = s2d(dataTable{i, 9}); 
            end
            
            if and(~isnan(x), ~isnan(y))
                plot(x, y, 'r.', 'Markersize', 30) % Measurements
                plot([dataTable{i, ax1+1} x], [dataTable{i, ax2+1} y],...
                    'k-')
            end
        end
    end
    
    xlabel(labels{ax1})
    ylabel(labels{ax2})
    title(titles{p})
end

pred = []; 
meas = []; 
N = 0;
for i = 1:handles.N
    if ~isempty(dataTable{i, 6})
        pred = [pred; dataTable{i, 2} dataTable{i, 3} dataTable{i, 4}]; 
        meas = [meas; s2d(dataTable{i, 6}) s2d(dataTable{i, 7})+s2d(dataTable{i, 8}) s2d(dataTable{i, 9})]; 
        N = N + 1; 
    end
end
    
% Subplot 4 -- errors; 
subplot(1, 4, 4); hold all; 
title('Err (mm): Meas - Pred');
err = meas - pred; 
for p = 1:3
    bar(p, mean(err(:, p)))
    plot(zeros(1, N)+p, err(:, p), 'k.', 'Markersize',30); 
end
ylabel('Error in mm')
xticks([1, 2,3])
xticklabels({'ML', 'AP', 'DV'})


function d = s2d(string)
    d = str2double(string); 

% --- Executes on button press in save_results.
function save_results_Callback(hObject, eventdata, handles)
% hObject    handle to save_results (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dataTable = get(handles.data_table, 'data'); 
stx_name = get(handles.stx_name, 'String'); 

savenm = get(handles.save_name, 'String'); 
save([savenm '.mat'], 'dataTable', 'stx_name'); 




function save_name_Callback(hObject, eventdata, handles)
% hObject    handle to save_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of save_name as text
%        str2double(get(hObject,'String')) returns contents of save_name as a double


% --- Executes during object creation, after setting all properties.
function save_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_and_plot.
function load_and_plot_Callback(hObject, eventdata, handles)
% hObject    handle to load_and_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get data

[filename, path] = uigetfile('*.mat');
dat = load([path filename]); 

% Set stx string correctly 
set(handles.stx_name, 'String', dat.stx_name); 

% Populate data table 
set(handles.data_table, 'data', dat.dataTable); 

% Set N
handles.N = size(dat.dataTable, 1);

% Update handles 
guidata(hObject, handles);

% Plot errors 
plot_errors(handles)

