function varargout = DataTreeGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DataTreeGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @DataTreeGUI_OutputFcn, ...
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



% -----------------------------------------------------------------------
function DataTreeGUI_OpeningFcn(hObject, ~, handles, varargin)
global datatreegui

datatreegui.dataTree = [];

handles.output = hObject;
guidata(hObject, handles);

datatreegui.dataTree = DataTreeClass({},'snirf','','noloadconfig:oneformat');
if datatreegui.dataTree.IsEmpty()
    datatreegui.dataTree.ResetAllGroups;
    return;
end
if datatreegui.dataTree.IsEmptyOutput()
    datatreegui.dataTree.ResetAllGroups;
    return;
end
DisplayGroupTree(handles);



% -----------------------------------------------------------------------
function varargout = DataTreeGUI_OutputFcn(hObject, ~, ~) 
global datatreegui
global atlasViewer

varargout{1} = [];
if datatreegui.dataTree.IsEmpty() || datatreegui.dataTree.IsEmptyOutput()
    datatreegui.dataTree.ResetAllGroups;
    if ishandle(hObject)
        close(hObject)
    end
    datatreegui.dataTree = [];
    datatreegui.listboxGroupTreeParams = InitListboxGroupTreeParams();
end
if ~isempty(atlasViewer)
    atlasViewer.dataTree = datatreegui.dataTree;
end
if ~ishandle(hObject)
    return
end
varargout{1} = hObject;
set(hObject, 'visible','on');



% --------------------------------------------------------------------
function listboxGroupTree_Callback(hObject0, eventdata, handles)
global datatreegui

if isempty(hObject0)
    hObject = handles.listboxGroupTree;
else
    hObject = hObject0;
end

iList = get(hObject,'value');
if isempty(iList==0)
    return;
end

fprintf('Loading fNIRS data from %s ...\n', datatreegui.dataTree.currElem.GetName);

% If evendata isn't empty then caller is trying to set currElem
if isa(eventdata, 'matlab.ui.eventdata.ActionData')
    
    % Get the [iGroup,iSubj,iRun] mapping of the clicked lisboxFiles entry
    [iGroup, iSubj, iSess, iRun] = MapList2GroupTree(iList);
    
    % Set current processing element
    datatreegui.dataTree.SetCurrElem(iGroup, iSubj, iSess, iRun);
 
elseif ~isempty(eventdata)
    
    iGroup = eventdata(1);
    iSubj = eventdata(2);
    iSess = eventdata(3);
    iRun = eventdata(4);
    iList = MapGroupTree2List(iGroup, iSubj, iSess, iRun);
    if iList==0
        return;
    end
    set(hObject,'value', iList);    

    % Set current processing element
    datatreegui.dataTree.SetCurrElem(iGroup, iSubj, iSess, iRun);
end

datatreegui.dataTree.LoadCurrElem();

ReloadAnatomy(handles)



% -----------------------------------------------------------------------
function ReloadAnatomy(handles)
global datatreegui
global atlasViewer

if isempty(atlasViewer)
    return;
end

groupDir     = datatreegui.dataTree.currElem.path;
currElemName = datatreegui.dataTree.currElem.GetName;

% Function to determine if we need to load a new subject in datatreegui.
% That is, if there is a folder corresponding to the selected fNIRS data 
% then AtlasViever will change the subject context
if pathscompare([groupDir, currElemName], atlasViewer.dirnameSubj)
    return;
end
dirnameSubjNew = filesepStandard([groupDir, currElemName]);
if isempty(dirnameSubjNew)
    dirnameSubjNew = filesepStandard(fileparts([groupDir, currElemName]));
end
if ~ispathvalid(dirnameSubjNew, 'dir')
    if ispathvalid(dirnameSubjNew, 'file')
        dirnameSubjNew = filesepStandard(fileparts([groupDir, currElemName]));
    else
        return;
    end
end
if pathscompare(dirnameSubjNew, atlasViewer.dirnameSubj)
    % We end up here IF selected data does NOT correspond to a separate subject
    % folder, it means that a separate anatomy is not associated with this data,
    % so then do NOT reload datatreegui
    return;
end
fprintf('There is a separate subject folder corresponding to the selected fNIRS data.\n');
fprintf('Opening datatreegui in new subject folder %s \n', dirnameSubjNew);
AtlasViewerGUI(dirnameSubjNew, atlasViewer.dirnameAtlas, [], handles.figure1, 'userargs');




% -----------------------------------------------------------------------
function listboxFilesErr_Callback(~, ~, ~) %#ok<*DEFNU>



% --------------------------------------------------------------------------------------------
function DisplayGroupTree(handles)
global datatreegui;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize listboxGroupTree params struct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
datatreegui.listboxGroupTreeParams = struct('listMaps',struct('names',{{}}, 'idxs', []), ...
                                        'views', struct('GROUP',1, 'SUBJS',2, 'SESS',3, 'NOSESS',4, 'RUNS',5), ...
                                        'viewSetting',0);
                      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate linear lists from group tree nodes for the 3 group views
% in listboxGroupTree
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[nSubjs, nSess, nRuns] = GenerateGroupDisplayLists();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine the best view for the data files 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[viewSetting, views] = SetView(handles, nSubjs, nSess, nRuns);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set listbox used for displaying valid data
% Get the GUI listboxGroupTree setting 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
listboxGroup = datatreegui.listboxGroupTreeParams.listMaps(viewSetting).names;
nFiles = length(datatreegui.listboxGroupTreeParams.listMaps(views.RUNS).names);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set listbox used for displaying files that did not load correctly
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
listboxFilesErr = cell(length(datatreegui.dataTree.filesErr),1);
nFilesErr=0;
for ii=1:length(datatreegui.dataTree.filesErr)
    if datatreegui.dataTree.filesErr(ii).isdir
        listboxFilesErr{ii} = datatreegui.dataTree.filesErr(ii).name;
    elseif ~isempty(datatreegui.dataTree.filesErr(ii).subjdir)
        listboxFilesErr{ii} = ['    ', datatreegui.dataTree.filesErr(ii).name];
        nFilesErr=nFilesErr+1;
    else
        listboxFilesErr{ii} = datatreegui.dataTree.filesErr(ii).name;
        nFilesErr=nFilesErr+1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set graphics objects: text and listboxes if handles exist
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(handles)
    % Report status in the status text object
    set( handles.textStatus, 'string', { ...
        sprintf('%d files loaded successfully',nFiles), ...
        sprintf('%d files failed to load',nFilesErr) ...
        } );
    
    if ~isempty(listboxGroup)
        set(handles.listboxGroupTree, 'value',1, 'string',listboxGroup)
    end
    
    if ~isempty(listboxFilesErr)
        set(handles.listboxFilesErr, 'visible','on', 'value',1, 'string',listboxFilesErr)
    else
        set(handles.listboxFilesErr, 'visible','off');
    end
end

listboxGroupTree_Callback([], [1, 0, 0, 0], handles)




% --------------------------------------------------------------------------------------------
function [nSubjs, nSess, nRuns] = GenerateGroupDisplayLists()
global datatreegui

list = datatreegui.dataTree.DepthFirstTraversalList();
views = datatreegui.listboxGroupTreeParams.views;
jj=0; hh=0; kk=0; mm=0;
nSubjs = 0;
nSess = 0;
nRuns = 0;
for ii = 1:length(list)
    
    % Add group level nodes only to whole-tree list
    if list{ii}.IsGroup()
        datatreegui.listboxGroupTreeParams.listMaps(views.GROUP).names{ii,1} = list{ii}.GetName;
        datatreegui.listboxGroupTreeParams.listMaps(views.GROUP).idxs(ii,:) = list{ii}.GetIndexID;
    
        kk=kk+1;
        datatreegui.listboxGroupTreeParams.listMaps(views.NOSESS).names{kk,1}  = list{ii}.GetFileName;
        datatreegui.listboxGroupTreeParams.listMaps(views.NOSESS).idxs(kk,:)   = list{ii}.GetIndexID;
    
    % Add subject level nodes to whole-tree and subject lists
    elseif list{ii}.IsSubj()
        datatreegui.listboxGroupTreeParams.listMaps(views.GROUP).names{ii,1}   = ['    ', list{ii}.GetName];
        datatreegui.listboxGroupTreeParams.listMaps(views.GROUP).idxs(ii,:) = list{ii}.GetIndexID;
        
        jj=jj+1;
        datatreegui.listboxGroupTreeParams.listMaps(views.SUBJS).names{jj,1} = list{ii}.GetName;
        datatreegui.listboxGroupTreeParams.listMaps(views.SUBJS).idxs(jj,:)  = list{ii}.GetIndexID;
    
        kk=kk+1;
        datatreegui.listboxGroupTreeParams.listMaps(views.NOSESS).names{kk,1}  = ['    ', list{ii}.GetFileName];
        datatreegui.listboxGroupTreeParams.listMaps(views.NOSESS).idxs(kk,:)   = list{ii}.GetIndexID;

        nSubjs = nSubjs+1;
        
    % Add session level nodes to whole-tree and session lists
    elseif list{ii}.IsSess()
        datatreegui.listboxGroupTreeParams.listMaps(views.GROUP).names{ii,1} = ['        ', list{ii}.GetFileName];
        datatreegui.listboxGroupTreeParams.listMaps(views.GROUP).idxs(ii,:) = list{ii}.GetIndexID;
            
        jj=jj+1;
        datatreegui.listboxGroupTreeParams.listMaps(views.SUBJS).names{jj,1} = ['    ', list{ii}.GetFileName];
        datatreegui.listboxGroupTreeParams.listMaps(views.SUBJS).idxs(jj,:)  = list{ii}.GetIndexID;

        hh=hh+1;
        datatreegui.listboxGroupTreeParams.listMaps(views.SESS).names{hh,1}  = list{ii}.GetFileName;
        datatreegui.listboxGroupTreeParams.listMaps(views.SESS).idxs(hh,:)   = list{ii}.GetIndexID;
    
        nSess = nSess+1;
        
    % Add run level nodes to ALL lists 
    elseif list{ii}.IsRun()
        datatreegui.listboxGroupTreeParams.listMaps(views.GROUP).names{ii,1}   = ['            ', list{ii}.GetFileName];
        datatreegui.listboxGroupTreeParams.listMaps(views.GROUP).idxs(ii,:) = list{ii}.GetIndexID;
            
        jj=jj+1;
        datatreegui.listboxGroupTreeParams.listMaps(views.SUBJS).names{jj,1} = ['        ', list{ii}.GetFileName];
        datatreegui.listboxGroupTreeParams.listMaps(views.SUBJS).idxs(jj,:)  = list{ii}.GetIndexID;

        hh=hh+1;
        datatreegui.listboxGroupTreeParams.listMaps(views.SESS).names{hh,1}  = ['    ', list{ii}.GetFileName];
        datatreegui.listboxGroupTreeParams.listMaps(views.SESS).idxs(hh,:)   = list{ii}.GetIndexID;

        kk=kk+1;
        datatreegui.listboxGroupTreeParams.listMaps(views.NOSESS).names{kk,1}  = ['            ', list{ii}.GetFileName];
        datatreegui.listboxGroupTreeParams.listMaps(views.NOSESS).idxs(kk,:)   = list{ii}.GetIndexID;

        mm=mm+1;
        datatreegui.listboxGroupTreeParams.listMaps(views.RUNS).names{mm,1}  = list{ii}.GetFileName;
        datatreegui.listboxGroupTreeParams.listMaps(views.RUNS).idxs(mm,:)   = list{ii}.GetIndexID;

        nRuns = nRuns+1;
        
    end
end



% -----------------------------------------------------
function [viewSetting, views] = SetView(handles, nSubjs, nSess, nRuns)
global datatreegui

if nSess == nRuns
    set(handles.menuItemGroupViewSettingGroup,'checked','off');
    set(handles.menuItemGroupViewSettingSubjects,'checked','off');
    set(handles.menuItemGroupViewSettingSessions,'checked','off');
    set(handles.menuItemGroupViewSettingNoSessions,'checked','on');
    set(handles.menuItemGroupViewSettingRuns,'checked','off');
else
    set(handles.menuItemGroupViewSettingGroup,'checked','on');
    set(handles.menuItemGroupViewSettingSubjects,'checked','off');
    set(handles.menuItemGroupViewSettingSessions,'checked','off');
    set(handles.menuItemGroupViewSettingNoSessions,'checked','off');
    set(handles.menuItemGroupViewSettingRuns,'checked','off');
end

if strcmp(get(handles.menuItemGroupViewSettingGroup,'checked'),'on')
    datatreegui.listboxGroupTreeParams.viewSetting = datatreegui.listboxGroupTreeParams.views.GROUP;
elseif strcmp(get(handles.menuItemGroupViewSettingSubjects,'checked'),'on')
    datatreegui.listboxGroupTreeParams.viewSetting = datatreegui.listboxGroupTreeParams.views.SUBJS;
elseif strcmp(get(handles.menuItemGroupViewSettingSessions,'checked'),'on')
    datatreegui.listboxGroupTreeParams.viewSetting = datatreegui.listboxGroupTreeParams.views.SESS;
elseif strcmp(get(handles.menuItemGroupViewSettingNoSessions,'checked'),'on')
    datatreegui.listboxGroupTreeParams.viewSetting = datatreegui.listboxGroupTreeParams.views.NOSESS;
elseif strcmp(get(handles.menuItemGroupViewSettingRuns,'checked'),'on')
    datatreegui.listboxGroupTreeParams.viewSetting = datatreegui.listboxGroupTreeParams.views.RUNS;
else
    datatreegui.listboxGroupTreeParams.viewSetting = datatreegui.listboxGroupTreeParams.views.GROUP;
end

viewSetting = datatreegui.listboxGroupTreeParams.viewSetting;
views = datatreegui.listboxGroupTreeParams.views;




% -----------------------------------------------------
function [iGroup, iSubj, iSess, iRun] = MapList2GroupTree(iList)
global datatreegui

viewSetting = datatreegui.listboxGroupTreeParams.viewSetting;

iGroup = datatreegui.listboxGroupTreeParams.listMaps(viewSetting).idxs(iList,1);
iSubj  = datatreegui.listboxGroupTreeParams.listMaps(viewSetting).idxs(iList,2);
iSess  = datatreegui.listboxGroupTreeParams.listMaps(viewSetting).idxs(iList,3);
iRun   = datatreegui.listboxGroupTreeParams.listMaps(viewSetting).idxs(iList,4);



% -----------------------------------------------------
function iList = MapGroupTree2List(iGroup, iSubj, iSess, iRun)
global datatreegui

% Function to convert from processing element 3-tuple index to 
% a linear index used to select a listbox entry

viewSetting = datatreegui.listboxGroupTreeParams.viewSetting;
idxs = datatreegui.listboxGroupTreeParams.listMaps(viewSetting).idxs;

% Convert processing element tuple index to a scalar
scalar0 = index2scalar(iGroup, iSubj, iSess, iRun);

% Find closest match to processing element argument in the listMap 
for ii = 1:size(idxs, 1)
    ig = idxs(ii,1);
    is = idxs(ii,2);
    ie = idxs(ii,3);
    ir = idxs(ii,4);
    scalar1 = index2scalar(ig, is, ie, ir);
    if scalar0<=scalar1
        break;
    end
end
iList = ii;



% -----------------------------------------------------
function scalar = index2scalar(ig, is, ie, ir)
scalar = ig*1000 + is*100 + ie*10 + ir;



% --------------------------------------------------------------------
function menuItemGroupViewSettingGroup_Callback(hObject, ~, handles)
global datatreegui

if strcmp(get(hObject, 'checked'), 'off')
    set(hObject, 'checked','on');
else
    return;
end
views = datatreegui.listboxGroupTreeParams.views;
if strcmp(get(hObject, 'checked'), 'on')
    iListNew = FindGroupDisplayListMatch(views.GROUP);    
    set(handles.listboxGroupTree, 'value',iListNew, 'string',datatreegui.listboxGroupTreeParams.listMaps(views.GROUP).names);

    datatreegui.listboxGroupTreeParams.viewSetting = views.GROUP;    
    set(handles.menuItemGroupViewSettingSubjects,'checked','off');
    set(handles.menuItemGroupViewSettingSessions,'checked','off');
    set(handles.menuItemGroupViewSettingNoSessions,'checked','off');
    set(handles.menuItemGroupViewSettingRuns,'checked','off');
end




% --------------------------------------------------------------------
function menuItemGroupViewSettingSubjects_Callback(hObject, ~, handles)
global datatreegui

if strcmp(get(hObject, 'checked'), 'off')
    set(hObject, 'checked','on');
else
    return;
end
views = datatreegui.listboxGroupTreeParams.views;
if strcmp(get(hObject, 'checked'), 'on')
    iListNew = FindGroupDisplayListMatch(views.SUBJS);    
    set(handles.listboxGroupTree, 'value',iListNew, 'string',datatreegui.listboxGroupTreeParams.listMaps(views.SUBJS).names);

    datatreegui.listboxGroupTreeParams.viewSetting = views.SUBJS;
    set(handles.menuItemGroupViewSettingGroup,'checked','off');
    set(handles.menuItemGroupViewSettingSessions,'checked','off');
    set(handles.menuItemGroupViewSettingNoSessions,'checked','off');
    set(handles.menuItemGroupViewSettingRuns,'checked','off');
end



% --------------------------------------------------------------------
function menuItemGroupViewSettingSessions_Callback(hObject, ~, handles)
global datatreegui

if strcmp(get(hObject, 'checked'), 'off')
    set(hObject, 'checked','on');
else
    return;
end
views = datatreegui.listboxGroupTreeParams.views;
if strcmp(get(hObject, 'checked'), 'on')
    iListNew = FindGroupDisplayListMatch(views.SESS);
    set(handles.listboxGroupTree, 'value',iListNew, 'string', datatreegui.listboxGroupTreeParams.listMaps(views.SESS).names);

    datatreegui.listboxGroupTreeParams.viewSetting = views.SESS;
    set(handles.menuItemGroupViewSettingGroup,'checked','off');
    set(handles.menuItemGroupViewSettingSubjects,'checked','off');
    set(handles.menuItemGroupViewSettingNoSessions,'checked','off');
    set(handles.menuItemGroupViewSettingRuns,'checked','off');
end



% --------------------------------------------------------------------
function menuItemGroupViewSettingNoSessions_Callback(hObject, ~, handles)
global datatreegui

if strcmp(get(hObject, 'checked'), 'off')
    set(hObject, 'checked','on');
else
    return;
end
views = datatreegui.listboxGroupTreeParams.views;
if strcmp(get(hObject, 'checked'), 'on')
    iListNew = FindGroupDisplayListMatch(views.NOSESS);
    set(handles.listboxGroupTree, 'value',iListNew, 'string', datatreegui.listboxGroupTreeParams.listMaps(views.NOSESS).names);

    datatreegui.listboxGroupTreeParams.viewSetting = views.NOSESS;
    set(handles.menuItemGroupViewSettingGroup,'checked','off');
    set(handles.menuItemGroupViewSettingSubjects,'checked','off');
    set(handles.menuItemGroupViewSettingSessions,'checked','off');
    set(handles.menuItemGroupViewSettingRuns,'checked','off');
end



% --------------------------------------------------------------------
function menuItemGroupViewSettingRuns_Callback(hObject, ~, handles)
global datatreegui

if strcmp(get(hObject, 'checked'), 'off')
    set(hObject, 'checked','on');
else
    return;
end
views = datatreegui.listboxGroupTreeParams.views;
if strcmp(get(hObject, 'checked'), 'on')
    iListNew = FindGroupDisplayListMatch(views.RUNS);
    set(handles.listboxGroupTree, 'value',iListNew, 'string', datatreegui.listboxGroupTreeParams.listMaps(views.RUNS).names);

    datatreegui.listboxGroupTreeParams.viewSetting = views.RUNS;
    set(handles.menuItemGroupViewSettingGroup,'checked','off');
    set(handles.menuItemGroupViewSettingSubjects,'checked','off');
    set(handles.menuItemGroupViewSettingSessions,'checked','off');    
    set(handles.menuItemGroupViewSettingNoSessions,'checked','off');
end



% --------------------------------------------------------------------
function iList = FindGroupDisplayListMatch(iView)
% 
% FindGroupDisplayListMatch finds the closest match to the 
% dataTree's current processing element in the group listbox 
% view. This function was originally written for Homer3 MainGUI
%

global datatreegui

iList = [];

% Get the group index of current list selection
groupIdx = datatreegui.dataTree.currElem.GetIndexID();
iG = groupIdx(1); 
iS = groupIdx(2); 
iE = groupIdx(3); 
iR = groupIdx(4);

% 
% 6 states, 3 transitional events
% 
% In the following specification, R means run, S means eubject, G means group . Note that 
% every group processing element is associated with a group, subject and run ID. 
% 
% 6 states are 
% 
%       Listbox Entry  |  Processing Level
%       ---------------|------------------
%    1.         R      |      R
%    2.         R      |      S
%    3.         R      |      G
%    4.         S      |      S
%    5.         S      |      G
%    6.         G      |      G
%               
% 3 transitional user actions (via View menu --> Group View Type) :  
%
%    1. Gv: Group   view 
%    2. Sv; Subject view
%    3. Rv: Runs    view
%
% 18 Possible state transitions:
%    
%    1 . RR  == Rv ==> RR
%    2 . RR  == Sv ==> RR
%    3 . RR  == Gv ==> RR
%
%    4 . RS  == Rv ==> RS
%    5 . RS  == Sv ==> SS
%    6 . RS  == Gv ==> SS
%
%    7 . RG  == Rv ==> RG
%    8 . RG  == Sv ==> SG
%    9 . RG  == Gv ==> GG
%
%    10. SS  == Rv ==> RS
%    11. SS  == Sv ==> SS
%    12. SS  == Gv ==> SS
%
%    13. SG  == Rv ==> RG
%    14. SG  == Sv ==> SG
%    15. SG  == Gv ==> GG
%
%    16. GG  == Rv ==> RG
%    17. GG  == Sv ==> SG
%    18. GG  == Gv ==> GG
% 

% This simple algorithm implements the 18 state stransitions. 
% Basically it just finds the closest match to the group index
% of the dataTree.currElem (i.e., the index of the actual current 
% group element) in the current display list (i.e. the current
% listbox entries)
listIdxs = datatreegui.listboxGroupTreeParams.listMaps(iView).idxs;
for ii = 1:length(listIdxs)
    if listIdxs(ii,1)>=iG && listIdxs(ii,2)>=iS && listIdxs(ii,3)>=iE && listIdxs(ii,4)>=iR
        iList = ii;
        break;
    end
end

