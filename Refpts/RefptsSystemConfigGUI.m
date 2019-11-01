function varargout = RefptsSystemConfigGUI(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @RefptsSystemConfigGUI_OpeningFcn, ...
    'gui_OutputFcn',  @RefptsSystemConfigGUI_OutputFcn, ...
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




% ------------------------------------------------------------------
function RefptsSystemConfigGUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for RefptsSystemConfigGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global atlasViewer
global refpts

if isempty(atlasViewer)
    return;
end

refpts  = atlasViewer.refpts;

% Get the eeg system standard being used by the refpts    
switch(refpts.eeg_system.ear_refpts_anatomy)
    case 'tragus'
        set(handles.radiobuttonTragus, 'value',1);
    case 'preauricular'
        set(handles.radiobuttonPreauricularPoint, 'value',1);
    case 'lobule'
        set(handles.radiobuttonLobuleOfAuricle, 'value',1);
    case 'antitragus'
        set(handles.radiobuttonAntitragus, 'value',1);
    otherwise
        set(handles.radiobuttonTragus, 'value',1);
end


% ------------------------------------------------------------------
function varargout = RefptsSystemConfigGUI_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;



% ------------------------------------------------------------------
function radiobuttonSelectEarAnatomy_Callback(hObject, eventdata, handles)
global refpts

if     get(handles.radiobuttonTragus, 'value')==1
    refpts = setRefptsEarAnatomy(refpts, 'tragus');
elseif get(handles.radiobuttonPreauricularPoint, 'value')==1
    refpts = setRefptsEarAnatomy(refpts, 'preauricular');
elseif get(handles.radiobuttonLobuleOfAuricle, 'value')==1
    refpts = setRefptsEarAnatomy(refpts, 'lobule');
elseif get(handles.radiobuttonAntitragus, 'value')==1
    refpts = setRefptsEarAnatomy(refpts, 'antitragus');
end




% ------------------------------------------------------------------
function pushbuttonSave_Callback(hObject, eventdata, handles)
global atlasViewer
global refpts

refpts = calcRefptsCircumf(refpts);
atlasViewer.refpts = refpts;

close(gcf);


% ------------------------------------------------------------------
function pushbuttonCancel_Callback(hObject, eventdata, handles)

close(gcf);



% ------------------------------------------------------------------
function editHeadDimensionsScaling_Callback(hObject, eventdata, handles)
global refpts

scaling = str2num(get(hObject, 'string'));

refpts.scaling = scaling;


% ------------------------------------------------------------------
function editHeadDimensionsScaling_CreateFcn(hObject, eventdata, handles)
global atlasViewer

scaling = atlasViewer.refpts.scaling;

set(hObject, 'string', sprintf('%0.1f', scaling));
