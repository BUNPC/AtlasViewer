function varargout = SDgui(varargin)
gui_Singleton = 1;

suppressGuiArgWarning(1);

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

suppressGuiArgWarning(0);



% -------------------------------------------------------------------
function SDgui_OpeningFcn(hObject, ~, handles, varargin)
global SD
global filedata

set(hObject, 'visible','off');

setNamespace('AtlasViewerGUI')

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
        SDgui_version(hObject);
        positionGUI(hObject, 0.20, 0.10, 0.75, 0.78);
        setGuiFonts(hObject);
        return;
    end
elseif ~isempty(varargin)
    SDgui_display(handles, varargin{1})
end

sd_file_panel_SetPathname(handles, pathname);
SDgui_version(hObject);
positionGUI(hObject, [], [], 0.75, 0.78);
setGuiFonts(hObject);

% Disable 3D view by default
set(handles.radiobuttonView3D, 'value',0);
radiobuttonView3D_Callback(handles.radiobuttonView3D, [], handles)

EnableGUI(hObject);




% -------------------------------------------------------------------
function SDgui_DeleteFcn(~, ~, handles)
global filedata

if isempty(handles)
    return;
end
if ~ishandle(handles.SDgui)
    return;
end

% If SD has been edited but not saved, notify user there's unsaved changes
% before loading new file
if SDgui_EditsMade()
    msg{1} = 'SD data has been edited. Do you want to save your changes before exiting? ';
    msg{2} = '(Click CANCEL to go back to SDgui)';
    q = MenuBox(msg, {'Save and Exit','Exit Only','CANCEL'});
    if q==3
        return;
    end
    if q==1
        SDgui_savemenuitem_Callback([], [], handles)
    end
end
filedata.SD = [];
delete(handles.SDgui);



% -------------------------------------------------------------------
function varargout = SDgui_OutputFcn(~, ~, handles)
% Get default command line output from handles structure
if ~isempty(handles)
    varargout{1} = handles.output;
end


% -------------------------------------------------------------------
function SDgui_clear_all_bttn_Callback(~, ~, handles)
SDgui_clear_all(handles)



% -------------------------------------------------------------------
function SDgui_openmenuitem_Callback(~, ~, handles)
pathname = sd_file_panel_GetPathname(handles);

% Change directory SDgui
[filename, pathname] = uigetfile({'*.SD; *.sd; *.nirs; *.snirf'},'Open SD file',pathname);
if(filename == 0)
    return;
end
sd_file_open(filename, pathname, handles);



% -------------------------------------------------------------------
function SDgui_newmenuitem_Callback(hObject, ~, handles)
SDgui_clear_all_bttn_Callback(hObject, [], handles);



% -------------------------------------------------------------------
function SDgui_savemenuitem_Callback(~, ~, handles)
% Get current pathname
filename = sd_filename_edit_Get(handles);
pathname = sd_file_panel_GetPathname(handles);
sd_file_save(filename, pathname, handles);



% -------------------------------------------------------------------
function SDgui_saveasmenuitem_Callback(~, ~, handles)
% Get current pathname
filename = sd_filename_edit_Get(handles);

% Save file
[filename, pathname] = uiputfile({'*.SD'; '*.sd'; '*.nirs'},'Save SD file',filename);
if(filename == 0)
    return;
end
sd_file_save(filename, pathname, handles);



% -------------------------------------------------------------------
function SDgui_radiobuttonSpringEnable_Callback(hObject, ~, handles)
SDgui_chooseMode(hObject, handles);
radiobuttonView3D_Callback(handles.radiobuttonView3D, [], handles);



% -------------------------------------------------------------------
function SDgui_chooseMode(~, handles)
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
function sd_filename_edit_Callback(hObject, ~, ~)
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
function checkboxViewFilePath_Callback(hObject, ~, handles)

if get(hObject,'value')==1
    set(handles.editFolderName, 'visible','on');
    set(handles.textFolderName, 'visible','on');
else
    set(handles.editFolderName, 'visible','off');
    set(handles.textFolderName, 'visible','off');
end



% ------------------------------------------------------------------
function checkboxNinjaCap_Callback(~, ~, handles)
optode_src_tbl_Update(handles);
optode_det_tbl_Update(handles);
optode_dummy_tbl_Update(handles);




% ------------------------------------------------------------------
function popupmenuSpatialUnit_Callback(hObject, ~, handles)
global SD
strs = get(hObject, 'string');
idx = get(hObject, 'value');
n = NirsClass(SD);
n.SetProbeSpatialUnit(strs{idx});
SD = n.SD;
SDgui_display(handles, SD);



% --------------------------------------------------------------------
function menuItemReorderOptodes_Callback(~, ~, handles)
global SD

x = inputdlg({'Source Order (leave empty to skip)','Detector Order (leave empty to skip)'});
if isempty(x)
    return
end

MeasList = SD.MeasList;
SpringList = SD.SpringList;
AnchorList = SD.AnchorList;

nSrcs = size(SD.SrcPos,1);
nDets = size(SD.DetPos,1);

% reorder the sources
if ~isempty(x{1})
    
    lstS = str2num(x{1});
    
    if length(unique(lstS)) ~= nSrcs
        warndlg('Source list must reorder all sources');
        return
    else
        SD.SrcPos = SD.SrcPos(lstS,:);
        
        for iS = 1:nSrcs
            lst = find(SD.MeasList(:,1)==lstS(iS));
            MeasList(lst,1) = iS;
            
            lst = find(SD.SpringList(:,1)==lstS(iS));
            SpringList(lst,1) = iS;
            lst = find(SD.SpringList(:,2)==lstS(iS));
            SpringList(lst,2) = iS;
            
            for iA = 1:size(SD.AnchorList,1)
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
    if length(unique(lstD)) ~= nDets
        warndlg('Detector list must reorder all sources');
        return
    else
        SD.DetPos = SD.DetPos(lstD,:);        
        for iD = 1:nDets
            lst = find(SD.MeasList(:,2) == lstD(iD));
            MeasList(lst,2) = iD;            
            lst = find(SD.SpringList(:,1) == (nSrcs+lstD(iD)));
            SpringList(lst,1) = (nSrcs+iD);
            lst = find(SD.SpringList(:,2) == (nSrcs+lstD(iD)));
            SpringList(lst,2) = (nSrcs+iD);            
            for iA = 1:size(SD.AnchorList,1)
                if SD.AnchorList{iA,1} == (nSrcs+lstD(iD))
                    AnchorList{iA,1} = (nSrcs+iD);
                end
            end
        end
    end    
end

% Sort the MeasList
MeasList2 = [];
for iS = 1:nSrcs
    lst = find(MeasList(:,1)==iS & MeasList(:,4)==1);
    mlTmp = MeasList(lst,:);
    [~,lst] = sort(mlTmp(:,2));
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




% --------------------------------------------------------------------
function radiobuttonView3D_Callback(hObject, ~, handles) %#ok<*DEFNU>
global SD
SDgui_display(handles, SD)

htoolbar = getToolbarHandle(handles);
hAxes = chooseAxes(handles);
if get(hObject, 'value')
    set(htoolbar, 'visible','on');
    set(get(hAxes,'zlabel'), 'visible','on')
    rotate3d(hAxes, 'on')
    
    % Only later versions of Matlab (after 2017b) have ContextMenu
    if isproperty(hAxes, 'ContextMenu') && isempty(hAxes.ContextMenu) % Only later versions of Matlab have ContextMenu
        hcm = uicontextmenu();
        % hcm.ContextMenuOpeningFcn = @(hObject,eventdata)SDgui('Delete3D',hObject,eventdata,guidata(hObject));
        hm = uimenu(hcm, 'text','Delete 3D');
        hm.MenuSelectedFcn = @(hObject,eventdata)SDgui('menuItemDelete3D_Callback',hObject,eventdata,guidata(hObject));
        hAxes.ContextMenu = hcm;
    end
else
    set(htoolbar, 'visible','off');
    set(get(hAxes,'zlabel'), 'visible','off')    
    rotate3d(hAxes, 'off')
end



% ---------------------------------------------------------------
function h = getToolbarHandle(handles)
h = [];
hc = get(handles.SDgui, 'children');
for ii = 1:length(hc)
    if strcmp(get(hc(ii), 'type'), 'uitoolbar')
        h = hc(ii);
        break
    end
end



% ---------------------------------------------------------------
function hAxes = chooseAxes(handles)
if ~get(handles.radiobuttonSpringEnable, 'value')
    hAxes = handles.probe_geometry_axes;
else
    hAxes = handles.probe_geometry_axes2;
end
axes(hAxes);



% ---------------------------------------------------------------
function pushbuttonExit_Callback(~, ~, handles)
SDgui_DeleteFcn([], [], handles);



% ---------------------------------------------------------------
function SDgui_CloseRequestFcn(~, ~, handles)
SDgui_DeleteFcn([], [], handles);



% --------------------------------------------------------------------
function menuItemExit_Callback(~, ~, handles)
SDgui_DeleteFcn([], [], handles);



% --------------------------------------------------------------------
function uitoggletool1_OffCallback(~, ~, handles)
hAxes = chooseAxes(handles);
SDgui_set_axes_view(hAxes);



% --------------------------------------------------------------------
function menuItemDelete3D_Callback(~, ~, handles)
sd_data_Delete3D();
radiobuttonView3D_Callback(handles.radiobuttonView3D, [], handles)



% --------------------------------------------------------------------
function menuItemDeleteRegistrationData_Callback(~, ~, handles)
global SD
sd_data_DeleteRegistrationData();
SDgui_display(handles, SD);
