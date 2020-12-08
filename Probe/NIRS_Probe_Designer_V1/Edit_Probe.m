function varargout = Edit_Probe(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Edit_Probe_OpeningFcn, ...
    'gui_OutputFcn',  @Edit_Probe_OutputFcn, ...
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


% ----------------------------------------------------------------------
function Edit_Probe_OpeningFcn(hObject, eventdata, handles, varargin)
global EditProbe;
EditProbe = [];

% Choose default command line output for Edit_Probe
set(handles.figure1,'Name','Manual Correction','NumberTitle','off')
handles.output = hObject;

if isempty(varargin)
    return;
end

handles.headsurf   = varargin{1,1};
handles.refpts     = varargin{1,2};
handles.probe      = varargin{1,3};
handles.axes_order = varargin{1,4};

%%%% read head surface mesh
axes_order = handles.axes_order;
nodes = handles.headsurf.vertices(:,axes_order);
faces = handles.headsurf.faces;
normals = handles.headsurf.normals(:,axes_order);

%%%% load optode position
Num_Scr = handles.probe.nsrc;
Num_Det = handles.probe.ndet;
Num_Chn = size(handles.probe.mlmp,1);
Chspos = [handles.probe.optpos_reg(1:Num_Scr,:), ones(Num_Scr,1)];
Chspos = [Chspos; handles.probe.optpos_reg(Num_Scr+1:Num_Scr+Num_Det,:), 2*ones(Num_Det,1)];
Chspos = [Chspos; handles.probe.mlmp 3*ones(Num_Chn,1)];
Chspos = [Chspos(:,axes_order(1:3)), Chspos(:,4)];

%%%% plot head model and optodes
Edit_Optode_Positions

EditProbe.handles = handles;

if size(handles.refpts,1)<=1
    set(handles.Show_EEG_Electrodes, 'Enable','off');
    set(handles.Show_EEG_Labels, 'Enable','off');
    set(handles.Show_Optode_Labels, 'Enable','off');
end

%%%% show arrows/ NIRS channels
h = findobj(gcf,'Type','text','fontsize',12,'color','k','FontAngle','italic'); % find labels
if get(handles.Show_NIRS_Channels,'value')
    set(h,'Visible','on')
else
    set(h,'Visible','off')
end
h = findobj(gcf,'Type','text','fontsize',12,'color','k','FontAngle','normal'); % find labels
if get(handles.Show_Optode_Labels,'value')
    set(h,'Visible','on')
else
    set(h,'Visible','off')
end

axes(handles.axes1)


% UIWAIT makes Edit_Probe wait for user response (see UIRESUME)
uiwait(handles.figure1);



% ----------------------------------------------------------------------
function varargout = Edit_Probe_OutputFcn(hObject, eventdata, handles)
global EditProbe;

if isempty(EditProbe)
    return;
end
if isempty(EditProbe.handles)
    return;
end

Num_Scr    = EditProbe.handles.probe.nsrc;
Num_Det    = EditProbe.handles.probe.ndet;
Num_Chn    = size(EditProbe.handles.probe.mlmp,1);
axes_order = EditProbe.handles.axes_order;

Optodes_update = [];

%%% sort sources
for i = 1:Num_Scr
    hj = findobj(EditProbe.handles.hj, 'AmbientStrength',.2,'DiffuseStrength',.8,'SpecularStrength',.5,'Tag',['S' num2str(i)]); % find optodes and their tags
    H = get(hj);
    Position = H.UserData;
    Optodes_update = [Optodes_update; Position];
end

%%% sort Detectors
for i = 1:Num_Det
    hj = findobj(EditProbe.handles.hj, 'AmbientStrength',.2,'DiffuseStrength',.8,'SpecularStrength',.5,'Tag',['D' num2str(i)]); % find optodes and their tags
    H = get(hj);
    Position = H.UserData;
    Optodes_update = [Optodes_update; Position];
end

%%% sort Channels
Channels = [];
for i = 1:Num_Chn
    hj = findobj(EditProbe.handles.hj, 'AmbientStrength',.2,'DiffuseStrength',.8,'SpecularStrength',.5,'Tag',['Ch' num2str(i)]); % find optodes and their tags
    H = get(hj);
    Position = H.UserData;
    Channels = [Channels; Position];
end
p = pullPtsToSurf(Optodes_update, EditProbe.handles.headsurf, 'center');

varargout{1} = Optodes_update(:,axes_order(1:3));
varargout{2} = Channels(:,axes_order(1:3));
varargout{3} = hObject;

h=get(hObject);
for i=1:length(h.Children)
    h1 = get(h.Children(i));
    if strcmp(h1.Type,'axes')
       h1.Children = []; 
    end
end
delete(hObject);



% ----------------------------------------------------------------------
function Show_Optode_Labels_Callback(hObject, eventdata, handles)

h = findobj(gcf,'Type','text','fontsize',12,'color','k','FontAngle','normal'); % find labels
if get(handles.Show_Optode_Labels,'value')
    set(h,'Visible','on')
else
    set(h,'Visible','off')
end


% ----------------------------------------------------------------------
function Show_NIRS_Channel_Labels_Callback(hObject, eventdata, handles)

h = findobj(gcf,'Type','text','fontsize',12,'color','k','FontAngle','italic'); % find labels
h1 = findobj(gcf,'Facecolor','c'); % find channels
if get(handles.Show_NIRS_Channels,'value')
    set(h,'Visible','on')
    set(h1,'Visible','on')
else
    set(h,'Visible','off')
    set(h1,'Visible','off')
end


% ----------------------------------------------------------------------
function Show_EEG_Electrodes_Callback(hObject, eventdata, handles)

h = findobj(gcf,'Facecolor','g'); % find its label
if get(handles.Show_EEG_Electrodes,'value')
    set(h,'Visible','on')
else
    set(h,'Visible','off')
end


% ----------------------------------------------------------------------
function Show_EEG_Labels_Callback(hObject, eventdata, handles)

h = findobj(gcf,'Type','text','fontsize',8,'color','k'); % find its label
if get(handles.Show_EEG_Labels,'value')
    set(h,'Visible','on')
else
    set(h,'Visible','off')
end
h = findobj(gcf,'Type','text','fontsize',12,'color','k','FontAngle','italic'); % find labels
if get(handles.Show_NIRS_Channels,'value')
    set(h,'Visible','on')
else
    set(h,'Visible','off')
end


% ----------------------------------------------------------------------
function Show_Arrows_Callback(hObject, eventdata, handles)

h = findobj(gcf,'Tag','Arrow'); % find its label
if get(handles.Show_Arrows,'value')
    set(h,'Visible','on')
else
    set(h,'Visible','off')
end


% ----------------------------------------------------------------------
function Show_Cortex_Callback(hObject, eventdata, handles)

hgm = findobj(gcf,'Tag','gm'); % find its label
hsk = findobj(gcf,'Tag','nd'); % find its label
if get(handles.Show_Cortex,'value')
    set(hgm,'FaceAlpha',0)
    set(hsk,'FaceAlpha',1)
else
    set(hgm,'FaceAlpha',0.5)
    set(hsk,'FaceAlpha',0.7)
end


% ----------------------------------------------------------------------
function figure1_CloseRequestFcn(hObject, eventdata, handles)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
%    cla
    delete(hObject);
end


% ----------------------------------------------------------------------
function Close_Callback(hObject, eventdata, handles)

handles.output = get(hObject,'String');

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);

