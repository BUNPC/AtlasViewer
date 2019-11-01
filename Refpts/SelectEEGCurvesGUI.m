function varargout = SelectEEGCurvesGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SelectEEGCurvesGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SelectEEGCurvesGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
               
if nargin && ischar(varargin{1}) && ~strcmp(varargin{end},'userargs')
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end



% --------------------------------------------------------------------------
function SelectEEGCurvesGUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global atlasViewer

if ~isempty(atlasViewer)
    refpts = atlasViewer.refpts;
    
    % Set radio buttons for currently selected curves
    curves = fieldnames(refpts.eeg_system.curves);
    refpts.handles.selectedcurves = createGUIObjects(hObject, curves);
    
    atlasViewer.refpts = refpts;
end



% --------------------------------------------------------------------------
function varargout = SelectEEGCurvesGUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --------------------------------------------------------------------------
function SelectEEGCurvesGUI_CloseRequestFcn(hObject, eventdata, handles)
global atlasViewer

if ~isempty(atlasViewer)
    atlasViewer.refpts.handles.SelectEEGCurvesGUI = [];
end

delete(hObject);


% --------------------------------------------------------------------------
function SelectEEGCurvesGUI_DeleteFcn(hObject, eventdata, handles)
global atlasViewer

if ~isempty(atlasViewer)
    atlasViewer.refpts.handles.SelectEEGCurvesGUI = [];
end



% --------------------------------------------------------------------------
function pushbuttonDone_Callback(hObject, eventdata, handles)

delete(gcf);



% --------------------------------------------------------------------------
function pushbuttonCancel_Callback(hObject, eventdata, handles)

delete(gcf);



% --------------------------------------------------------------------------
function hChecks = createGUIObjects(hGui, fields)
global atlasViewer

refpts = atlasViewer.refpts;

hChecks = [];

if ~ishandles(hGui)
    return;
end

ug0 = get(hGui, 'units');
set(hGui, 'units','characters');
pg = get(hGui, 'position');

W = pg(3);
H = pg(4) - pg(4)*.30;

N = length(fields);
nr = 15;
nc = floor(N/nr)+1;
xsize = (W/nc);
ysize = (H/nr);
for ii=1:length(fields)
    i = floor((ii-1)/nr)  + 1;
    j = nr - mod(ii-1,nr) + 1;
    xpos = (i-1)*xsize + (xsize*.2);
    ypos = j*ysize + 2*ysize;
    eval(sprintf('val = refpts.eeg_system.curves.%s.selected;', fields{ii}));    
    hChecks(ii) = uicontrol('parent',hGui, 'style','radiobutton', 'value', val, 'units','characters', ...
                       'position',[xpos,ypos,xsize,ysize], 'string',fields{ii}, 'tag',fields{ii}, ...
                       'fontsize',9, 'callback',{@optionsCallback,guidata(hGui)});                   
    drawnow;
end
set(hGui, 'units',ug0);



% --------------------------------------------------------------------------
function optionsCallback(hObject, eventdata, handles)
global atlasViewer

refpts = atlasViewer.refpts;

val = get(hObject,'value');
curve = get(hObject,'tag');
if strcmpi(curve,'all')
    curves = fieldnames(refpts.eeg_system.curves);
    for ii=1:length(curves)
        eval(sprintf('refpts.eeg_system.curves.%s.selected = val;', curves{ii}));
        set(refpts.handles.selectedcurves(ii), 'value', val);
    end
else
    eval(sprintf('refpts.eeg_system.curves.%s.selected = val;', curve));
end
v = get(refpts.handles.selectedcurves,'Value');
val_all = ~all([v{:}]==0);
set(handles.all,'value',val_all);

refpts = set_eeg_active_pts(refpts);
refpts = displayRefpts(refpts);




atlasViewer.refpts = refpts;
