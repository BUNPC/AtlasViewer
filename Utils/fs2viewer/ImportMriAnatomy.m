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
function ParseArgs(args)
global importmri

% Init all parameters whose value can be obtained from args
importmri.fs2viewer = [];
importmri.handles = [];
importmri.dirnameSubj = pwd;
importmri.parent = '';

% Extract all available arg values
nargin = length(args);
if nargin == 1
    importmri.fs2viewer = args{1};    
elseif nargin == 2
    importmri.fs2viewer = args{1};    
    importmri.handles = args{2};
elseif nargin == 3
    importmri.fs2viewer = args{1};    
    importmri.handles = args{2};
    importmri.dirnameSubj = args{3};
elseif nargin == 4
    importmri.fs2viewer = args{1};    
    importmri.handles = args{2};
    importmri.dirnameSubj = args{3};
    importmri.parent = args{4};
end
importmri.dirnameSubj = filesepStandard(importmri.dirnameSubj);



% ------------------------------------------------------------------
function SetPaths(handles)
global importmri

if isempty(importmri.fs2viewer)
    importmri.fs2viewer = initFs2Viewer(importmri.handles, importmri.dirnameSubj);
    importmri.fs2viewer = getFs2Viewer(importmri.fs2viewer);
end
fs2viewer = importmri.fs2viewer;
set(handles.editHeadVolume, 'string', fs2viewer.layers.head.filename);
set(handles.editSkullVolume, 'string', fs2viewer.layers.skull.filename);
set(handles.editDuraVolume, 'string', fs2viewer.layers.dura.filename);
set(handles.editCsfVolume, 'string', fs2viewer.layers.csf.filename);
set(handles.editBrainVolume, 'string', fs2viewer.layers.gm.filename );
set(handles.editWhiteMatterVolume, 'string', fs2viewer.layers.wm.filename );
set(handles.editSegmentedVolume, 'string', fs2viewer.hseg.filename);
set(handles.editRightBrainSurface, 'string', fs2viewer.surfs.pial_rh.filename);
set(handles.editLeftBrainSurface, 'string', fs2viewer.surfs.pial_lh.filename);
importmri.fs2viewer = fs2viewer;




% ------------------------------------------------------------------
function ImportMriAnatomy_OpeningFcn(hObject, ~, handles, varargin)
global importmri

if nargin<4
    varargin = {};
end

importmri = [];
importmri.status = zeros(1,5);

% Choose default command line output for ImportMriAnatomy
handles.output = hObject;
guidata(hObject, handles);

importmri.cancel = false;

ParseArgs(varargin);

if ~isempty(importmri.parent)
    set(handles.menuFile, 'visible','off');
end

SetPaths(handles);
waitForGui(hObject);
ConvertFs2Viewer();




% ------------------------------------------------------------------
function varargout = ImportMriAnatomy_OutputFcn(~, ~, ~)
global importmri
varargout{1} = importmri.status;



% ------------------------------------------------------------------
function pushbuttonHeadVolume_Callback(~, ~, ~)


% ------------------------------------------------------------------
function pushbuttonSkullVolume_Callback(~, ~, ~)



% ------------------------------------------------------------------
function pushbuttonDuraVolume_Callback(~, ~, ~)



% ------------------------------------------------------------------
function pushbuttonCsfVolume_Callback(~, ~, ~)


% ------------------------------------------------------------------
function pushbuttonBrainVolume_Callback(~, ~, ~)



% ------------------------------------------------------------------
function pushbuttonBrowse_Callback(hObject, ~, handles)
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
function pushbuttonSubmit_Callback(~, ~, handles) %#ok<*DEFNU>
global importmri

fs2viewer = importmri.fs2viewer;

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
            q = MenuBox([msg{:}],{'Yes','No'});
            if q==1
                return;
            else
                q = MenuBox('Importing of subject anatomical files will now begin',{'OK','Cancel'});
                if q==2
                    return;
                end
            end
        end
    end
    
    importmri.fs2viewer = fs2viewer;
end
delete(handles.ImportMriAnatomy);


% ------------------------------------------------------------------
function pushbuttonCancel_Callback(~, ~, handles)
global importmri

importmri.cancel = true;
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


% -------------------------------------------------------------------
function ImportMriAnatomy_CloseRequestFcn(~, ~, handles)
global importmri

importmri.cancel = true;
delete(handles.ImportMriAnatomy);




% -------------------------------------------------------------------
function status = ConvertFs2Viewer()
global importmri

status = importmri.status;

% Generate the following objects:
%
%   headvol
%   headsurf
%   pialvol
%   pialsurf
%

% If user hit cancel then we assume they changed their mind about wanting
% to import the subject anatomy
if importmri.cancel
    importmri.status = 1;
    status = importmri.status;
    return;
end

fs2viewer = importmri.fs2viewer;

try
    % Generate single segmented volume: this is what will be
    % used for generating the forward model
    [headvol, fs2viewer, status(1)] = fs2headvol(fs2viewer);
    [pialsurf, importmri.status(2)]           = fs2pialsurf(fs2viewer);
    
    % Generate surfaces: this is what is displayed in the GUI
    if ~headvol.isempty(headvol)
        [headsurf, importmri.status(3)] = headvol2headsurf(headvol);
    end
    if pialsurf.isempty(pialsurf)
        [pialsurf, importmri.status(2)] = headvol2pialsurf(headvol);
    end
    
    if sum(status)>0
        
        % Change 5/29/2018: allow only head or only brain to be imported if that's all
        % that's available.
        
        if status(1)>0
            q = MenuBox(sprintf('Error generating segmented head volume.'),{'Proceed Anyway','Cancel'});
            if q==2
                return;
            end
        elseif status(3)>0
            q = MenuBox(sprintf('Error generating head surface.'),{'Proceed Anyway','Cancel'});
            if q==2
                status = importmri.status;
                return;
            end
        elseif importmri.status(2)>0 || importmri.status(4)>0
            q = MenuBox(sprintf('Error generating brain surface. Do you want to proceed with only the head surface?'),{'Proceed Anyway','Cancel'});
            if q==2
                return;
            end
        end
        
        % reset status to no error since user decided to proceed anyway
        importmri.status = zeros(1,5);
        
    end
    
    % Since the objects don't exist as files yet, need to set the subject paths
    % in each object
    if ~headvol.isempty(headvol)
        headvol.pathname = importmri.dirnameSubj;
    end
    if ~headsurf.isempty(headsurf)
        headsurf.pathname = importmri.dirnameSubj;
    end
    if ~pialsurf.isempty(pialsurf)
        pialsurf.pathname = importmri.dirnameSubj;
    end    
    
    % Create the AtlasViewer anatomical files corresponding to the imported mri
    % files
    saveHeadvol(headvol);
    saveHeadsurf(headsurf);
    savePialsurf(pialsurf);
    saveLabelSurf2Vol(headvol);

catch ME
    
    if exist([importmri.dirnameSubj, 'anatomical'],'dir')==7
        fprintf('delete([dirnameSubj, ''anatomical/*'']);\n');
        delete([importmri.dirnameSubj, 'anatomical/*']);
        fprintf('delete([dirnameSubj, ''hseg*'']);\n');
        delete([importmri.dirnameSubj, 'hseg*']);
        delete([importmri.dirnameSubj, 'head.nii.gz']);
    end
    msg{1} = sprintf('There was an error importing MRI files. Please make sure the files are valid volume files ');
    msg{2} = sprintf('and are coregistered.\n After checking file, restart AtlasViewer to re-try importing.');
    MessageBox(msg);
    rethrow(ME);
    
end
status = importmri.status;



% --------------------------------------------------------------------
function menuItemReset_Callback(~, ~, handles)
global importmri
msg{1} = sprintf('WARNING: This action will reset the import process of the subject specific MRI in this folder. ');
msg{2} = sprintf('It will do this by deleting all AtlasViewer-format anatomical files. ');
msg{3} = sprintf('Are you sure that is what you want?');
q = MenuBox(msg, {'YES','NO'});
if q==2
    return;
end

if ispathvalid([importmri.dirnameSubj, 'anatomical'])
    fprintf('rmdir(''%s'',''s'');\n', [importmri.dirnameSubj, 'anatomical']);
    rmdir([importmri.dirnameSubj, 'anatomical'],'s');
end

dirs = dir();
for ii = 1:length(dirs)
    if ~dirs(ii).isdir()
        continue
    end
    if strcmp(dirs(ii).name, '.')
       if isSubjDir(dirs(ii).name)
           continue
       end
    end
    if strcmp(dirs(ii).name, '..')
        continue
    end
    if ~pathscompare(dirs(ii).name, importmri.dirnameSubj)
       if isSubjDir(dirs(ii).name)
           continue
       end
    end
    
    rootdir = filesepStandard(dirs(ii).name, 'full');
    
    fprintf('delete([''%shseg*'']);\n', rootdir);
    delete([rootdir, 'hseg*'])
    if ispathvalid([rootdir, 'head.nii.gz'])
        fprintf('delete(''%s'');\n', [rootdir, 'head.nii.gz']);
        delete([rootdir, 'head.nii.gz'])
    end    
end
importmri.fs2viewer = [];
SetPaths(handles)


