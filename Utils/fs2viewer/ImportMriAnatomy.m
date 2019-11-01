function varargout = ImportMriAnatomy(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ImportMriAnatomy_OpeningFcn, ...
    'gui_OutputFcn',  @ImportMriAnatomy_OutputFcn, ...
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

% End initialization code - DO NOT EDIT


% ------------------------------------------------------------------
function ImportMriAnatomy_OpeningFcn(hObject, eventdata, handles, varargin)
global importMriAnatomyUI

% Choose default command line output for ImportMriAnatomy
handles.output = hObject;
guidata(hObject, handles);

importMriAnatomyUI.fs2viewer = [];
if isempty(varargin)
    return;
end
importMriAnatomyUI.cancel = false;
importMriAnatomyUI.fs2viewer = varargin{1};
fs2viewer = importMriAnatomyUI.fs2viewer;

set(handles.editHeadVolume, 'string', fs2viewer.layers.head.filename);
set(handles.editSkullVolume, 'string', fs2viewer.layers.skull.filename);
set(handles.editDuraVolume, 'string', fs2viewer.layers.dura.filename);
set(handles.editCsfVolume, 'string', fs2viewer.layers.csf.filename);
set(handles.editBrainVolume, 'string', fs2viewer.layers.gm.filename );
set(handles.editWhiteMatterVolume, 'string', fs2viewer.layers.wm.filename );
set(handles.editSegmentedVolume, 'string', fs2viewer.hseg.filename);
set(handles.editRightBrainSurface, 'string', fs2viewer.surfs.pial_rh.filename);
set(handles.editLeftBrainSurface, 'string', fs2viewer.surfs.pial_lh.filename);



% ------------------------------------------------------------------
function varargout = ImportMriAnatomy_OutputFcn(hObject, eventdata, handles)
if ~isempty(handles)
    varargout{1} = handles.output;
end



% ------------------------------------------------------------------
function pushbuttonHeadVolume_Callback(hObject, eventdata, handles)


% ------------------------------------------------------------------
function pushbuttonSkullVolume_Callback(hObject, eventdata, handles)



% ------------------------------------------------------------------
function pushbuttonDuraVolume_Callback(hObject, eventdata, handles)



% ------------------------------------------------------------------
function pushbuttonCsfVolume_Callback(hObject, eventdata, handles)


% ------------------------------------------------------------------
function pushbuttonBrainVolume_Callback(hObject, eventdata, handles)



% ------------------------------------------------------------------
function pushbuttonBrowse_Callback(hObject, eventdata, handles)
global atlasViewer

dirnameSubj = '.';
if ~isempty(atlasViewer)
    dirnameSubj = atlasViewer.dirnameSubj;
end

tag = get(hObject, 'tag');
switch(tag)
    case 'pushbuttonHeadVolume'
        title = 'Import Head';
    case 'pushbuttonSkullVolume'
        title = 'Import Skull';
    case 'pushbuttonDuraVolume'
        title = 'Import Dura';
    case 'pushbuttonCsfVolume'
        title = 'Import CSF';
    case 'pushbuttonBrainVolume'
        title = 'Import Brain';
    case 'pushbuttonWhiteMatterVolume'
        title = 'Import White Matter';
    case 'pushbuttonRightBrainSurface'
        title = 'Import Right Brain Surface';
    case 'pushbuttonLeftBrainSurface'
        title = 'Import Left Brain Surface';
    case 'pushbuttonBrainSurface'
        title = 'Import Brain Surface';
    case 'pushbuttonHsegVolume'
        title = 'Import Segmented Volume';
end

[filename, pathname] = uigetfile({'*.nii; *.mgz; *.tri'}, title, dirnameSubj);
if(filename == 0)
    return;
end

switch(tag)
    case 'pushbuttonHeadVolume'
        set(handles.editHeadVolume, 'string', [pathname, filename]);
    case 'pushbuttonSkullVolume'
        set(handles.editSkullVolume, 'string', [pathname, filename]);
    case 'pushbuttonDuraVolume'
        set(handles.editDuraVolume, 'string', [pathname, filename]);
    case 'pushbuttonCsfVolume'
        set(handles.editCsfVolume, 'string', [pathname, filename]);
    case 'pushbuttonBrainVolume'
        set(handles.editBrainVolume, 'string', [pathname, filename]);
    case 'pushbuttonWhiteMatterVolume'
        set(handles.editWhiteMatterVolume, 'string', [pathname, filename]);
    case 'pushbuttonRightBrainSurface'
        set(handles.editRightBrainVolume, 'string', [pathname, filename]);
    case 'pushbuttonLeftBrainSurface'
        set(handles.editLeftBrainSurface, 'string', [pathname, filename]);
    case 'pushbuttonBrainSurface'
        set(handles.editBrainSurface, 'string', [pathname, filename]);
    case 'pushbuttonHsegVolume'
        set(handles.editSegmentedVolume, 'string', [pathname, filename]);
end


% ------------------------------------------------------------------
function pushbuttonSubmit_Callback(hObject, eventdata, handles)
global importMriAnatomyUI

fs2viewer = importMriAnatomyUI.fs2viewer;

if ~isempty(fs2viewer)
    
    fs2viewer.layers.head = assignEditboxFilePath(fs2viewer.layers.head, handles.editHeadVolume);
    fs2viewer.layers.skull = assignEditboxFilePath(fs2viewer.layers.skull, handles.editSkullVolume);
    fs2viewer.layers.dura = assignEditboxFilePath(fs2viewer.layers.dura, handles.editDuraVolume);
    fs2viewer.layers.csf = assignEditboxFilePath(fs2viewer.layers.csf, handles.editCsfVolume);
    fs2viewer.layers.gm = assignEditboxFilePath(fs2viewer.layers.gm, handles.editBrainVolume);
    fs2viewer.layers.wm = assignEditboxFilePath(fs2viewer.layers.wm, handles.editWhiteMatterVolume);
    fs2viewer.hseg = assignEditboxFilePath(fs2viewer.hseg, handles.editSegmentedVolume);
    fs2viewer.surfs.pial_rh = assignEditboxFilePath(fs2viewer.surfs.pial_rh, handles.editRightBrainSurface);
    fs2viewer.surfs.pial_lh = assignEditboxFilePath(fs2viewer.surfs.pial_lh, handles.editLeftBrainSurface);

    % If not enough volumes and surfaces selected, then warn users about a
    % possible problem. 
    if isempty(fs2viewer.layers.head.filename)
        if isempty(fs2viewer.hseg.filename)
            msg{1} = sprintf('WARNING: Neither a head volume or a segmented volume file was chosen. Results might not be what\n');
            msg{2} = sprintf('is expected unless you provide a head volume or segmented volume file. Do you want to provide the\n');
            msg{3} = sprintf('path of one of these files? ');
            q = menu([msg{:}],'Yes','No');
            if q==1
                return;
            else
                q = menu('Importing of subject anatomical files will now begin','OK','Cancel');
                if q==2
                    return;
                end
            end
        end
    end
    
    importMriAnatomyUI.fs2viewer = fs2viewer;
end
delete(handles.ImportMriAnatomy);


% ------------------------------------------------------------------
function pushbuttonCancel_Callback(hObject, eventdata, handles)
global importMriAnatomyUI

importMriAnatomyUI.cancel = true;
delete(handles.ImportMriAnatomy);




% -------------------------------------------------------------------
function layer = assignEditboxFilePath(layer, handle)

[p1, f1, e1] = fileparts(layer.filename);
p1 = [p1, '/'];

[p2, f2, e2] = fileparts(get(handle, 'string'));
p2 = [p2, '/'];

if ~strcmp([p1,f1,e1],[p2,f2,e2])
    layer = initLayer;
    layer.filename = get(handle, 'string');
end


