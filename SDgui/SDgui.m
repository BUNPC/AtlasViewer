function varargout = SDgui(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SDgui_OpeningFcn, ...
    'gui_OutputFcn',  @SDgui_OutputFcn, ...
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



% -------------------------------------------------------------------
function SDgui_OpeningFcn(hObject, eventdata, handles, varargin)

set(hObject, 'visible','off');

global SD;
SD = [];

% Choose default command line output for SDgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SDgui wait for user response (see UIRESUME)
% uiwait(handles.SDgui);

set(hObject,'userdata',pwd);

sd_data_Create();
% loadSDfile(handles);

SDgui_chooseMode(handles.radiobuttonSpringEnable, handles);

probe_geometry_axes_SetAxisEqual(handles);
probe_geometry_axes2_SetAxisEqual(handles);

SDgui_newmenuitem_Callback([],[],handles);
[filename, pathname] = getCurrPathname(varargin);
if ~isempty(filename) & filename ~= 0
    sd_filename_edit_Set(handles,filename);
    sd_file_panel_SetPathname(handles,pathname);
    err = sd_file_open(filename, pathname, handles);
    if err
        SDgui_SetVersion(hObject);
        positionGUI(hObject, 0.30, 0.20, 0.65, 0.78);
        SDgui_set_font_size(handles);        
        return;
    end
    % cd(pathname);
else
    sd_file_panel_SetPathname(handles,pathname);
end

% Set the AtlasViewerGUI version number
SDgui_version(hObject);

positionGUI(hObject, 0.30, 0.20, 0.65, 0.78);
SDgui_set_font_size(handles);



% -------------------------------------------------------------------
function SDgui_DeleteFcn(hObject, eventdata, handles)

global SD;
SD = [];
hSDgui = get(get(hObject,'parent'),'parent');
delete(hSDgui);



% -------------------------------------------------------------------
function varargout = SDgui_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
if ~isempty(handles)
    varargout{1} = handles.output;
end


% -------------------------------------------------------------------
function SDgui_clear_all_bttn_Callback(hObject, eventdata, handles)

% Clear central data object first
sd_data_Clear();

if ~exist('handles','var') || isempty(handles)
    return;
end

% Clear Axes
probe_geometry_axes_Clear(handles);

% Clear Axes2
probe_geometry_axes2_Clear(handles);

% Clear source optode table
optode_src_tbl_Clear(handles);

% Clear detector optode table
optode_det_tbl_Clear(handles);

% Clear detector optode table
optode_dummy_tbl_Clear(handles);

% Clear position probe related optode table
optode_spring_tbl_Clear(handles);
optode_anchor_tbl_Clear(handles);

% Clear SD file panel
sd_file_panel_Clear(handles);

% Clear Lambda panel
wavelength1_edit_Update(handles,[]);
wavelength2_edit_Update(handles,[]);
wavelength3_edit_Update(handles,[]);

SDgui_disp_msg(handles, '');



% -------------------------------------------------------------------
function SDgui_openmenuitem_Callback(hObject, eventdata, handles)
global SD;

pathname = sd_file_panel_GetPathname(handles);

% Change directory SDgui
[filename, pathname] = uigetfile({'*.SD; *.sd';'*.nirs'},'Open SD file',pathname);
if(filename == 0)
    return;
end

SDgui_clear_all_bttn_Callback(hObject, eventdata, handles);
err = sd_file_open(filename, pathname, handles);



% -------------------------------------------------------------------
function SDgui_newmenuitem_Callback(hObject, eventdata, handles)
global SD;

SDgui_clear_all_bttn_Callback(hObject, [], handles);



% -------------------------------------------------------------------
function loadSDfile(handles)



% -------------------------------------------------------------------
function SDgui_savemenuitem_Callback(hObject, eventdata, handles)

% Get current pathname
filename = sd_filename_edit_Get(handles);
pathname = sd_file_panel_GetPathname(handles);

% Save file
if(isempty(filename))
    [filename, pathname, filterindex] = uiputfile({'*.SD'; '*.sd'; '*.nirs'},'Save SD file',filename);
    if(filename == 0)
        return;
    end
end
sd_file_save(filename, pathname, handles);



% -------------------------------------------------------------------
function SDgui_saveasmenuitem_Callback(hObject, eventdata, handles)

% Get current pathname
filename = sd_filename_edit_Get(handles);
pathname = sd_file_panel_GetPathname(handles);

% Save file
[filename, pathname, filterindex] = uiputfile({'*.SD'; '*.sd'; '*.nirs'},'Save SD file as under another file name',filename);
if(filename == 0)
    return;
end
sd_file_save(filename, pathname, handles);


% -------------------------------------------------------------------
function SDgui_radiobuttonSpringEnable_Callback(hObject, eventdata, handles)

SDgui_chooseMode(hObject, handles);



% -------------------------------------------------------------------
function SDgui_chooseMode(hObject, handles)

if get(handles.radiobuttonSpringEnable,'value')==0
    probe_geometry_axes_Hide(handles,'on');
    optode_tbls_Hide(handles,'on');
    
    probe_geometry_axes2_Hide(handles,'off');
    optode_tbls2_Hide(handles,'off');
else
    probe_geometry_axes_Hide(handles,'off');
    optode_tbls_Hide(handles,'off');
    
    probe_geometry_axes2_Hide(handles,'on');
    optode_tbls2_Hide(handles,'on');
end




% -------------------------------------------------------------------
function [filename, pathname] = getCurrPathname(arg)

pathname = [];
filename = [];
if length(arg)==2
    pathname = arg{1};
    if isempty(pathname)
        return;
    end
    k = find(pathname == '/' | pathname == '\');
    if length(k)>0
        filename = pathname(k(end)+1:end);
        pathname = pathname(1:k(end));
    else
        filename = pathname;
        pathname = [];
    end
elseif length(arg)==3
    pathname = arg{1};
    filename = arg{2};
end

if isempty(filename)
    [filename, pathname] = uigetfile({'*.SD; *.sd';'*.nirs'},'Open SD file',pathname);
    if(filename == 0)
        return;
    end
end



% -------------------------------------------------------------------
function sd_filename_edit_Callback(hObject, eventdata, handles)
filename = get(hObject,'string');
if isempty(filename);
    return;
end
k=findstr(filename,'.');
if ~isempty(k)
    ext=filename(k(end):end);
else
    ext=[];
end
if ~strcmpi(ext,'.nirs') & ~strcmpi(ext,'.sd')
    filename = [filename '.SD'];
    set(hObject,'string',filename);
end



% -------------------------------------------------------------------
function SDgui_set_font_size(handles)

objtypes = {'text','pushbutton','edit','checkbox','radiobutton'};

if ismac() || islinux()
    fields = fieldnames(handles);
    for ii=1:length(fields)
        if eval(sprintf('~isproperty(handles.%s, ''style'')', fields{ii}))
            continue;
        end
        
        if eval(sprintf('ismember(get(handles.%s, ''style''), objtypes);', fields{ii}))
            eval( sprintf('set(handles.%s, ''fontsize'',12.0);', fields{ii}) );
        end
    end
elseif ispc()
    ;
end



% ------------------------------------------------------------------
function SDgui_SetVersion(hObject)

V = getVernum();
if str2num(V{2})==0
    set(hObject,'name', sprintf('SDgui  (v%s) - %s', [V{1}],cd) )
else
    set(hObject,'name', sprintf('SDgui  (v%s) - %s', [V{1} '.' V{2}],cd) )
end
SD.vrnum = V;



% ------------------------------------------------------------------
function checkboxViewFilePath_Callback(hObject, eventdata, handles)

if get(hObject,'value')==1
    set(handles.textViewFilePath, 'visible','on');
else
    set(handles.textViewFilePath, 'visible','off');
end
