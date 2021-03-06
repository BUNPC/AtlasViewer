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
global SD
global filedata

set(hObject, 'visible','off');

SD = [];
filedata.SD = [];


% Choose default command line output for SDgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

set(hObject,'userdata',pwd);

SDgui_chooseMode(handles.radiobuttonSpringEnable, handles);

probe_geometry_axes_SetAxisEqual(handles);
probe_geometry_axes2_SetAxisEqual(handles);

SDgui_newmenuitem_Callback([], [], handles);
[filename, pathname] = getCurrPathname(varargin);
if ~isempty(filename)
    sd_filename_edit_Set(handles, filename);
    sd_file_panel_SetPathname(handles, pathname);
    err = sd_file_open(filename, pathname, handles);
    if err
        SDgui_SetVersion(hObject);
        positionGUI(hObject, 0.20, 0.10, 0.75, 0.78);
        setGuiFonts(hObject);        
        return;
    end
elseif ~isempty(varargin)
    SDgui_display(handles, varargin{1})
end
sd_file_panel_SetPathname(handles, pathname);

% Set the AtlasViewerGUI version number
SDgui_version(hObject);

positionGUI(hObject, 0.20, 0.10, 0.75, 0.78);
setGuiFonts(hObject);

popupmenuSpatialUnit_Callback([], [], handles)




% -------------------------------------------------------------------
function SDgui_DeleteFcn(hObject, eventdata, handles)
global filedata

filedata.SD = [];

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

SDgui_clear_all(handles)



% -------------------------------------------------------------------
function SDgui_openmenuitem_Callback(hObject, eventdata, handles)

pathname = sd_file_panel_GetPathname(handles);

% Change directory SDgui
[filename, pathname] = uigetfile({'*.SD; *.sd; *.nirs; *.snirf'},'Open SD file',pathname);
if(filename == 0)
    return;
end
sd_file_open(filename, pathname, handles);



% -------------------------------------------------------------------
function SDgui_newmenuitem_Callback(hObject, eventdata, handles)

SDgui_clear_all_bttn_Callback(hObject, [], handles);



% -------------------------------------------------------------------
function SDgui_savemenuitem_Callback(hObject, eventdata, handles)

% Get current pathname
filename = sd_filename_edit_Get(handles);
pathname = sd_file_panel_GetPathname(handles);

% Save file
if(isempty(filename))
    [filename, pathname] = uiputfile({'*.SD'; '*.sd'; '*.nirs'},'Save SD file',filename);
    if(filename == 0)
        return;
    end
end
sd_file_save(filename, pathname, handles);



% -------------------------------------------------------------------
function SDgui_saveasmenuitem_Callback(hObject, eventdata, handles)

% Get current pathname
filename = sd_filename_edit_Get(handles);

% Save file
[filename, pathname] = uiputfile({'*.SD'; '*.sd'; '*.nirs'},'Save SD file as under another file name',filename);
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
function [fname, pname] = getCurrPathname(arg)
fname = '';
pname = '';
if isempty(arg)
    [fname, pname] = uigetfile({'*.SD; *.sd; *.nirs; *.snirf'},'Open SD file',pwd);
    if(fname == 0)
        pname = filesepStandard(pwd);
        fname = [];        
    end
    pname = filesepStandard(pname);
    return
elseif ~ischar(arg{1})
    pname = pwd;
    return;
end

filename = arg{1};
[pname, fname, ext] = fileparts(filename);
pname = filesepStandard(pname);
if ~isempty(fname) && isempty(ext)
    ext = '.SD';
end
directory = dir(pname);

file = [];
if ~isempty(fname)
    file = dir([pname, fname, ext]);
end

if isempty(directory)
    pname = filesepStandard(pwd);
end
if isempty(file)
    [fname, pname] = uigetfile({'*.SD; *.sd; *.nirs; *.snirf'},'Open SD file',pname);
    if(fname == 0)
        pname = filesepStandard(pwd);
        fname = [];
        return
    end
    ext = '';
end
pname = filesepStandard(pname);
fname = [fname, ext];



% -------------------------------------------------------------------
function sd_filename_edit_Callback(hObject, eventdata, handles)
filename = get(hObject,'string');
if isempty(filename)
    return;
end
k = findstr(filename,'.');
if ~isempty(k)
    ext=filename(k(end):end);
else
    ext=[];
end
if ~strcmpi(ext,'.nirs') && ~strcmpi(ext,'.sd')
    filename = [filename '.SD'];
    set(hObject,'string',filename);
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
    set(handles.textFolderName, 'visible','on');
else
    set(handles.textViewFilePath, 'visible','off');
    set(handles.textFolderName, 'visible','off');
end




% ------------------------------------------------------------------
function checkboxNinjaCap_Callback(hObject, eventdata, handles)

    optode_src_tbl_Update(handles);
    optode_det_tbl_Update(handles);
    optode_dummy_tbl_Update(handles);

% ------------------------------------------------------------------
function popupmenuSpatialUnit_Callback(hObject, eventdata, handles)
global SD

if ~ishandles(hObject)
    set(handles.popupmenuSpatialUnit, 'string', {'cm', 'mm'});
    hObject = handles.popupmenuSpatialUnit;
    strs = get(hObject, 'string');
    idx = find(strcmp(strs, SD.SpatialUnit));
    if ~isempty(idx) && (idx <= length(strs))
        set(hObject, 'value', idx);
    end
end
strs = get(hObject, 'string');
idx = get(hObject, 'value');
SD.SpatialUnit = strs{idx};


% --------------------------------------------------------------------
function menuItemReorderOptodes_Callback(hObject, eventdata, handles)
global SD

x = inputdlg({'Source Order (leave empty to skip)','Detector Order (leave empty to skip)'});
if isempty(x)
    return
end

MeasList = SD.MeasList;
SpringList = SD.SpringList;
AnchorList = SD.AnchorList;

% reorder the sources
if ~isempty(x{1})
    
    lstS = str2num(x{1});
    
    if length(unique(lstS))~=SD.nSrcs
        warndlg('Source list must reorder all sources');
        return
    else
        SD.SrcPos = SD.SrcPos(lstS,:);
        
        for iS=1:SD.nSrcs
            lst = find(SD.MeasList(:,1)==lstS(iS));
            MeasList(lst,1) = iS;
            
            lst = find(SD.SpringList(:,1)==lstS(iS));
            SpringList(lst,1) = iS;
            lst = find(SD.SpringList(:,2)==lstS(iS));
            SpringList(lst,2) = iS;
            
            for iA=1:size(SD.AnchorList,1)
                if SD.AnchorList{iA,1}==lstS(iS)
                    AnchorList{iA,1} = iS;
                end
            end
        end
    end
    
end

% reorder the detectors
if ~isempty(x{2})
    lstD = str2num(x{2});    
    if length(unique(lstD))~=SD.nDets
        warndlg('Detector list must reorder all sources');
        return
    else
        SD.DetPos = SD.DetPos(lstD,:);        
        for iD=1:SD.nDets
            lst = find(SD.MeasList(:,2)==lstD(iD));
            MeasList(lst,2) = iD;            
            lst = find(SD.SpringList(:,1)==(SD.nSrcs+lstD(iD)));
            SpringList(lst,1) = (SD.nSrcs+iD);
            lst = find(SD.SpringList(:,2)==(SD.nSrcs+lstD(iD)));
            SpringList(lst,2) = (SD.nSrcs+iD);            
            for iA=1:size(SD.AnchorList,1)
                if SD.AnchorList{iA,1}==(SD.nSrcs+lstD(iD))
                    AnchorList{iA,1} = (SD.nSrcs+iD);
                end
            end
        end
    end    
end

% Sort the MeasList
MeasList2 = [];
for iS = 1:SD.nSrcs
    lst = find(MeasList(:,1)==iS & MeasList(:,4)==1);
    mlTmp = MeasList(lst,:);
    [foo,lst] = sort(mlTmp(:,2));
    mlTmp = mlTmp(lst,:);
    for ii=1:length(lst)
        MeasList2(end+1,:) = mlTmp(ii,:);
    end
end

nWav = length(SD.Lambda);
MeasList3 = MeasList2;
for ii=2:nWav
    foo = MeasList2;
    foo(:,4) = ii;
    MeasList3 = [MeasList3; foo];
end

% Update
SD.MeasList = MeasList3;
SD.SpringList = SpringList;
SD.AnchorList = AnchorList;

SDgui_display(handles, SD)


