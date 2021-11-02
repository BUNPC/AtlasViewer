function varargout = AtlasViewerGUI(varargin)

% Start AtlasViewerGUI initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AtlasViewerGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @AtlasViewerGUI_OutputFcn, ...
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
% End AtlasViewerGUI initialization code - DO NOT EDIT

        

% ------------------------------------------------------------------
function InitSubj(hObject, handles, argExtern)
global atlasViewer
global DEBUG

DEBUG = 0;

%%% Begin initialization ....

% Create things from scratch

if isempty(argExtern)
    argExtern = {''};
end

handles.ImageRecon = [];
if length(argExtern)>=4
    if length(argExtern{4})>1
        handles.ImageRecon = argExtern{4}(2);
    end
end

checkForAtlasViewerUpdates();

atlasViewer.handles.figure = hObject;
atlasViewer.handles.hHbConc = [];

% Initialize atlas viewer objects with their respective gui
% handles
objs.axesv       = initAxesv(handles);
objs.headsurf    = initHeadsurf(handles);
objs.pialsurf    = initPialsurf(handles);
objs.labelssurf  = initLabelssurf(handles);
objs.refpts      = initRefpts(handles);
objs.digpts      = initDigpts(handles);
objs.headvol     = initHeadvol();
objs.probe       = initProbe(handles);
objs.fwmodel     = initFwmodel(handles, argExtern);
objs.imgrecon    = initImgRecon(handles);
objs.hbconc      = initHbConc(handles);
objs.fs2viewer   = initFs2Viewer(handles, atlasViewer.dirnameSubj);

fprintf('   MC application path = %s\n', objs.fwmodel.mc_exepath);
fprintf('   MC application binary = %s\n', objs.fwmodel.mc_exename);
fprintf('\n');

fields = fieldnames(objs);

% Check for a saved viewer state file and restore 
% state if it exists. 
vrnum = [];
warning('off', 'MATLAB:dispatcher:UnresolvedFunctionHandle');
if exist([atlasViewer.dirnameSubj 'atlasViewer.mat'], 'file')

    load([atlasViewer.dirnameSubj 'atlasViewer.mat'],'-mat'); %#ok<LOAD>
    for ii = 1:length(fields)
        if exist(fields{ii},'var')
            eval(sprintf('atlasViewer.%s = restoreObject(objs.%s, %s);', fields{ii}, fields{ii}, fields{ii}));
        else
            % Initialized object does NOT exist in saved state. Therefore no compatibility issues.  
            eval(sprintf('atlasViewer.%s = restoreObject(objs.%s, objs.%s);', fields{ii}, fields{ii}, fields{ii}));
        end
    end
    if ~isempty(vrnum)
        fprintf('Loading saved viewer state created by AtlasViewerGUI V%s\n', vrnum);
    else
        fprintf('Loading saved viewer state created by a version of AtlasViewerGUI prior to V2.0.1\n');
    end
    
    % Otherwise simply initialize objects from scratch

else
    
    for ii=1:length(fields)
        eval(sprintf('atlasViewer.%s = objs.%s;', fields{ii}, fields{ii}));            
    end
    
end
warning('on', 'MATLAB:dispatcher:UnresolvedFunctionHandle');


atlasViewer.dirnameProbe = '';
atlasViewer.handles.menuItemRegisterAtlasToDigpts = handles.menuItemRegisterAtlasToDigpts;

% Set the AtlasViewerGUI version number
[~, V] = AtlasViewerGUI_version(hObject);
atlasViewer.vrnum = V;



% -----------------------------------------------------------------------
function LoadSubj(hObject, ~, handles, argExtern)
global atlasViewer
global popupmenuorder

if isempty(argExtern)
    argExtern = {''};
end

InitSubj(hObject, handles, argExtern);

dirnameAtlas = atlasViewer.dirnameAtlas;
dirnameSubj = atlasViewer.dirnameSubj;
searchPaths = {dirnameSubj; dirnameAtlas};

axesv        = atlasViewer.axesv;
headvol      = atlasViewer.headvol;
headsurf     = atlasViewer.headsurf;
pialsurf     = atlasViewer.pialsurf;
labelssurf   = atlasViewer.labelssurf;
refpts       = atlasViewer.refpts;
digpts       = atlasViewer.digpts;
probe        = atlasViewer.probe;
fwmodel      = atlasViewer.fwmodel;
imgrecon     = atlasViewer.imgrecon;
hbconc       = atlasViewer.hbconc;
fs2viewer    = atlasViewer.fs2viewer;
dataTree     = atlasViewer.dataTree;
    

if ~exist([dirnameSubj 'atlasViewer.mat'], 'file')

    % Load all objects
    headvol    = getHeadvol(headvol, searchPaths);
    headsurf   = getHeadsurf(headsurf, searchPaths);
    pialsurf   = getPialsurf(pialsurf, searchPaths);
    
    % Check the consistency of the main pieces of the anatomy; make sure
    % they all come from one source and is not a patchwork from atlas and 
    % subject folders
    [headvol, headsurf, pialsurf] = checkAnatomy(headvol, headsurf, pialsurf, handles);
    
    refpts     = getRefpts(refpts, headsurf.pathname);
    digpts     = getDigpts(digpts, dirnameSubj, refpts);
    labelssurf = getLabelssurf(labelssurf, headsurf.pathname);
    probe      = getProbe(probe, dirnameSubj, digpts, headsurf, refpts, dataTree);
    fwmodel    = getFwmodel(fwmodel, dirnameSubj, pialsurf, headsurf, headvol, probe);
    imgrecon   = getImgRecon(imgrecon, dirnameSubj, fwmodel, pialsurf, probe, dataTree);
    hbconc     = getHbConc(hbconc, dirnameSubj, pialsurf, probe, dataTree);
    fs2viewer  = getFs2Viewer(fs2viewer, dirnameSubj);
    
else
    
    imgrecon   = getImgRecon(imgrecon, dirnameSubj, fwmodel, pialsurf, probe, dataTree);    
    hbconc     = getHbConc(hbconc, dirnameSubj, pialsurf, probe, dataTree);
    
end


% Set orientation and main axes attributes for all objects
if ~refpts.isempty(refpts)
    [headvol, headsurf, pialsurf, labelssurf, probe, fwmodel, imgrecon, hbconc] = ...
        setOrientationRefpts(refpts, headvol, headsurf, pialsurf, labelssurf, probe, fwmodel, imgrecon, hbconc);
elseif ~headvol.isempty(headvol)
    [refpts, headsurf, pialsurf, labelssurf, probe, fwmodel, imgrecon, hbconc] = ...
        setOrientationHeadvol(headvol, refpts, headsurf, pialsurf, labelssurf, probe, fwmodel, imgrecon, hbconc);
end

% Display all objects
digpts     = displayDigpts(digpts);
clcrefpts     = displayRefpts(refpts);
probe      = displayProbe(probe, refpts);
headsurf   = displayHeadsurf(headsurf);
pialsurf   = displayPialsurf(pialsurf);
labelssurf = displayLabelssurf(labelssurf);
fwmodel    = displaySensitivity(fwmodel, pialsurf, labelssurf, probe);
imgrecon   = displayImgRecon(imgrecon, fwmodel, pialsurf, labelssurf, probe);
hbconc     = displayHbConc(hbconc, pialsurf, probe, fwmodel, imgrecon);
axesv      = displayAxesv(axesv, headsurf, headvol, initDigpts());

% 
fwmodel.menuoffset  = popupmenuorder.Sensitivity.idx-1;
imgrecon.menuoffset = popupmenuorder.LocalizationError.idx-1;
hbconc.menuoffset   = popupmenuorder.HbOConc.idx-1;


atlasViewer.headsurf    = headsurf;
atlasViewer.pialsurf    = pialsurf;
atlasViewer.labelssurf  = labelssurf;
atlasViewer.refpts      = refpts;
atlasViewer.headvol     = headvol;
atlasViewer.digpts      = digpts;
atlasViewer.probe       = probe;
atlasViewer.fwmodel     = fwmodel;
atlasViewer.imgrecon    = imgrecon;
atlasViewer.hbconc      = hbconc;
atlasViewer.axesv       = axesv;
atlasViewer.fs2viewer   = fs2viewer;

% TBD: The workflow should be to go from volume space 
% to dig point to monte carlo space automatically whether
% dig pts are present or not - in which case the transformations 
% are identities and volume space is MC space. 
% Right now calling menuItemRegisterAtlasToDigpts_Callback 
% explicitly that is by a non-graphics event 
% doesn't do anything. It's more like a placeholder. 
menuItemRegisterAtlasToDigpts_Callback();

% Enable menu items 
AtlasViewerGUI_enableDisable(handles);

% Set GUI size relative to screen size
positionGUI(hObject);



% --------------------------------------------------------------------
function [headvol, headsurf, pialsurf] = checkAnatomy(headvol, headsurf, pialsurf, handles)
global atlasViewer

dirnameSubj = atlasViewer.dirnameSubj;

% If the head surface and head volume don't agree on anatomy, then
% keep the object that come from the subject folder and discard that
% atlas. TBD: Whichever one we keep what we would really want
% is to generate from the discarded the head volume or head surface
% with on-the-fly generated head surface or head volume respectively
if ~headvol.isempty(headvol) && ~headsurf.isempty(headsurf)
    if ~pathscompare(headvol.pathname, headsurf.pathname)
        if pathscompare(headvol.pathname, dirnameSubj)
            
            % Generate headsurf and pialsurf from headvol
            headsurf = headvol2headsurf(headvol);
            pialsurf = headvol2pialsurf(headvol);
            
            saveHeadsurf(headsurf);
            savePialsurf(pialsurf);
            
            headsurf = getHeadsurf(headsurf, dirnameSubj);
            pialsurf = getPialsurf(pialsurf, dirnameSubj);
            
            headsurf = setHeadsurfHandles(headsurf, handles);
            pialsurf = setPialsurfHandles(pialsurf, handles);
            
        elseif pathscompare(headsurf.pathname, dirnameSubj)
            
            headvol = initHeadvol();    % Discard head volume
            
        else
            
            headvol = initHeadvol();    % Discard head volume
            
        end
    end
end
    
% If the head surface and pial surface don't agree on anatomy, then
% keep the head surface no matter where it comes from subject or atlas folder
if ~headsurf.isempty(headsurf)  && ~pialsurf.isempty(pialsurf)
    if ~pathscompare(headsurf.pathname, pialsurf.pathname)

        pialsurf = initPialsurf();
            
    end
end


    
    
% --------------------------------------------------------------------
function Edit_Probe_Callback(~, ~, ~)
global atlasViewer;

%%%% close GUI
hij = findobj(0,'name','Edit Probe');
if ~isempty(hij)
    close(hij)
end

%%%% replace Edit_Probe.fig if it's oversized
SOURCE      = which('Edit_Probe_backup.fig');
DESTINATION = which('Edit_Probe.fig');
if ~isempty(SOURCE) && ~isempty(DESTINATION)
    if GetFileSize(DESTINATION) > 100000  %%% check if the file is oversized
        delete(DESTINATION);
        copyfile(SOURCE,DESTINATION,'f');
    end
elseif isempty(DESTINATION)
    return;
end

%%%% NOTE: since we're getting the true vertex positions from the graphics handle
%%%% rather than the mesh field of headsurf (which does contain the true
%%%% positions) we need to apply axes_order. The reason to get it from the 
%%%% graphics handle rather than headsurf.mesh is for the normals, to keep that 
%%%% straight between vertices and normals we use the graphics handle. 
if leftRightFlipped(atlasViewer.refpts)
    axes_order = [2,1,3];
else
    axes_order = [1,2,3];
end
Hh = get(atlasViewer.headsurf.handles.surf); %%% head surface mesh
headsurf.vertices = Hh.Vertices(:,axes_order);
headsurf.faces    = Hh.Faces;
if ~isempty(Hh.VertexNormals)
    headsurf.normals = Hh.VertexNormals(:,axes_order);
else
    fv.vertices      = headsurf.vertices;
    fv.faces         = headsurf.faces;
    headsurf.normals = patchnormals(fv);
end

for i = 1:size(atlasViewer.refpts.handles.circles,1)
    refpts{i,1} = atlasViewer.refpts.pos(i,:);
    refpts{i,2} = atlasViewer.refpts.labels{i};
    refpts{i,3} = atlasViewer.refpts.orientation;
end
probe = atlasViewer.probe;   %%%% probe
if isempty(probe.optpos_reg)
    menu('There was a problem launching Edit_Probe. Probe is missing or is not registered to head.', 'OK');
    return;
end
[optodes, channels] = Edit_Probe(headsurf, refpts, probe, axes_order, 'userargs');
if isempty(optodes)
    return;
end
atlasViewer.probe.mlmp = channels;   

%%% update optode positions    
for i=1:size(optodes,1)
    atlasViewer.probe.optpos_reg(i,:) = optodes(i,:);   
    set(atlasViewer.probe.handles.labels(i,1),'Position',optodes(i,axes_order));
    set(atlasViewer.probe.handles.circles(i,1),'XData',optodes(i,axes_order(1)),'YData',optodes(i,axes_order(2)),'ZData',optodes(i,axes_order(3)));
end

%%%% update NIRS channel positions
ml = atlasViewer.probe.ml;
Num_Scr = atlasViewer.probe.nsrc;
for i = 1:size(ml,1)
    XData = [optodes(ml(i,1),axes_order(1)) optodes(ml(i,2)+Num_Scr,axes_order(1))];
    YData = [optodes(ml(i,1),axes_order(2)) optodes(ml(i,2)+Num_Scr,axes_order(2))];
    ZData = [optodes(ml(i,1),axes_order(3)) optodes(ml(i,2)+Num_Scr,axes_order(3))];
    set(atlasViewer.probe.handles.hMeasList(i,1),'XData',XData,'YData',YData,'ZData',ZData)
end



% -----------------------------------------------------------------------
function AtlasViewerGUI_OpeningFcn(hObject, eventdata, handles, varargin)
global atlasViewer
global cfg

setNamespace('AtlasViewerGUI');

if isempty(varargin)
    atlasViewer = [];
end
cfg = ConfigFileClass();

% Choose default command line output for AtlasViewerGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

if ~isempty(getappdata(gcf, 'zoomlevel'))
    rmappdata(gcf, 'zoomlevel');
end

initAxesv(handles);

atlasViewer.dirnameSubj = getSubjDir(varargin);
atlasViewer.dirnameAtlas = getAtlasDir(varargin);

fprintf('%s\n', banner());
fprintf('   dirnameApp = %s\n', getAppDir());
fprintf('   dirnameAtlas = %s\n', atlasViewer.dirnameAtlas);
fprintf('   dirnameSubj = %s\n', atlasViewer.dirnameSubj);

cd(atlasViewer.dirnameSubj);

checkForAtlasViewerUpdates();
PrintSystemInfo([], 'AtlasViewer');

hDataTreeGUI = [];
if length(varargin)>3
    if ishandles(varargin{4})
        hDataTreeGUI = varargin{4};
    end
end

if isempty(hDataTreeGUI)
    atlasViewer.handles.dataTree = DataTreeGUI();
else
    atlasViewer.dataTree.LoadCurrElem();
end

if ~isempty(atlasViewer.dirnameSubj) & atlasViewer.dirnameSubj ~= 0
    if length(varargin)<2
        varargin{1} = atlasViewer.dirnameSubj;
        varargin{2} = 'userargs';
    else
        varargin{1} = atlasViewer.dirnameSubj;
    end
end
LoadSubj(hObject, eventdata, handles, varargin);

if ishandles(atlasViewer.imgrecon.handles.ImageRecon)
    ImageRecon();
end
set(handles.editSelectChannel,'string','0 0');
set(handles.togglebuttonMinimizeGUI, 'tooltipstring', 'Minimize GUI Window')

positionDataTreeGUI(handles, 'init');

% check for MCXlab in path - JAY, WHERE SHOULD THIS GO?
if exist('mcxlab.m','file')
    set(handles.menuItemRunMCXlab,'enable','on');
else
    set(handles.menuItemRunMCXlab,'enable','off');
end

if isfield(atlasViewer,'probe')
   atlasViewer.probe_copy   = atlasViewer.probe; % this is useful for testing if the probe is modified 
end



% -------------------------------------------------------------------
function positionDataTreeGUI(handles, options)
global atlasViewer

if isempty(atlasViewer.handles.dataTree)
    return;
end

if ~exist('options','var')
    options = {};
end
k = 1.05;

% Place helper gui relative to main gui position
set(handles.AtlasViewerGUI,'units','pixels');
set(atlasViewer.handles.dataTree,'units','pixels');
p1 = get(handles.AtlasViewerGUI,'Position');
p2 = get(atlasViewer.handles.dataTree,'Position');

% Reposition DataTreeGUI
set(atlasViewer.handles.dataTree, 'Position',[(p1(1)-(p2(3)*k)), p2(2), p2(3), p2(4)]);

% Make sure dialog is within screen bounds
rePositionGuiWithinScreen(atlasViewer.handles.dataTree);
p2 = get(atlasViewer.handles.dataTree,'Position');

% Reposition AtlasViewerGUI if needed
d = p1(1) - (p2(1)+p2(3));
if d<0
    set(handles.AtlasViewerGUI, 'Position',[(p2(1)+(p2(3)))*k, p1(2), p1(3), p1(4)]);
end




% -------------------------------------------------------------------
function varargout = AtlasViewerGUI_OutputFcn(~, ~, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;




% --------------------------------------------------------------------
function AtlasViewerGUI_DeleteFcn(~, ~, ~)
global atlasViewer

fclose all;

if isempty(atlasViewer)
    deleteNamespace('AtlasViewerGUI');
    return;
end
axesv = atlasViewer.axesv;

probe = atlasViewer.probe;
imgrecon = atlasViewer.imgrecon;

if ishandles(probe.handles.hSDgui)
    delete(probe.handles.hSDgui);
end

if ishandles(imgrecon.handles.ImageRecon)
    delete(imgrecon.handles.ImageRecon);
end

if length(axesv)>1
    if ishandles(axesv(2).handles.axesSurfDisplay)
        hp = get(axesv(2).handles.axesSurfDisplay,'parent');
        delete(hp);
    end
end
if ishandles(atlasViewer.handles.dataTree)
    delete(atlasViewer.handles.dataTree);
end
atlasViewer=[];
clear atlasViewer;
deleteNamespace('AtlasViewerGUI');




% ----------------------------------------------------------------
function radiobuttonShowHead_Callback(hObject, eventdata, handles)
global atlasViewer;
hHeadSurf = atlasViewer.headsurf.handles.surf;

val = get(hObject,'value');

if val==1
    set(hHeadSurf,'visible','on');
elseif val==0
    set(hHeadSurf,'visible','off');
end




% ------------------------------------------------------------------
function editHeadTransparency_Callback(hObject, eventdata, handles)
global atlasViewer;

hHeadSurf = atlasViewer.headsurf.handles.surf;

val_old = get(hHeadSurf,'facealpha');
val = str2num(get(hObject,'string')); %#ok<*ST2NM>

% Error checking 
if isempty(val)
    set(hObject,'string',num2str(val_old));
    return;
end
if ~isnumeric(val)
    set(hObject,'string',num2str(val_old));
    return;
end
if ~isscalar(val)
    set(hObject,'string',num2str(val_old));
    return;
end
if val>1 || val<0
    set(hObject,'string',num2str(val_old));
    return;
end
if ~isempty(hHeadSurf)
    set(hHeadSurf,'facealpha',val);
end




% --------------------------------------------------------------------
function editBrainTransparency_Callback(hObject, eventdata, handles)
global atlasViewer;

hPialSurf = atlasViewer.pialsurf.handles.surf;
hLabelsSurf = atlasViewer.labelssurf.handles.surf;
iFaces = atlasViewer.labelssurf.iFaces;
mesh = atlasViewer.labelssurf.mesh;

val_old = get(hPialSurf,'facealpha');
val = str2num(get(hObject,'string'));

% Error checking 
if isempty(val)
    set(hObject,'string',num2str(val_old));
    return;
end
if ~isnumeric(val)
    set(hObject,'string',num2str(val_old));
    return;
end
if ~isscalar(val)
    set(hObject,'string',num2str(val_old));
    return;
end
if val>1 || val<0
    set(hObject,'string',num2str(val_old));
    return;
end

if ~isempty(hPialSurf)
    set(hPialSurf,'facealpha',val);
end
if ~isempty(hLabelsSurf)
    facevertexalphadata = ones(size(mesh.faces,1),1)*val;
    facevertexalphadata(iFaces) = 1;
    set(hLabelsSurf,'facevertexalphadata',facevertexalphadata);
end



% --------------------------------------------------------------------
function [probe, fwmodel, labelssurf] = ...
    clearRegistration(probe, fwmodel, labelssurf, dirname)

probe = resetProbeGui(probe);
fwmodel = resetSensitivity(fwmodel,probe,dirname);
labelssurf  = resetLabelssurf(labelssurf);



% --------------------------------------------------------------------

function pushbuttonRegisterProbeToSurface_Callback(hObject, eventdata, handles)
global atlasViewer

if ~exist('hObject','var')
    hObject = [];
end
if ~ishandles(hObject)
    % If call to menuItemRegisterAtlasToDigpts_Callback is not a GUI event then exit
    return;
end
if strcmp(get(hObject, 'enable'), 'off')
    return
end
    
refpts       = atlasViewer.refpts;
probe        = atlasViewer.probe;
headsurf     = atlasViewer.headsurf;
headvol      = atlasViewer.headvol;
dirnameSubj  = atlasViewer.dirnameSubj;
fwmodel      = atlasViewer.fwmodel;
imgrecon     = atlasViewer.imgrecon;
labelssurf   = atlasViewer.labelssurf;
digpts       = atlasViewer.digpts;

% for displayAxesv whichever head object (headsurf or headvol) 
% is not empty will work. 
if ~headsurf.isempty(headsurf)
    headobj = headsurf;
else
    headobj = headvol;
end

if isempty(probe.optpos_reg) && isempty(probe.optpos)
    menu('No probe has been loaded or created. Use the SDgui to make or load a probe','ok');
    atlasViewer.probe = resetProbe(probe);
    return;
end

refpts.eeg_system.selected = '10-5';
refpts = set_eeg_active_pts(refpts, [], false);

% Finish registration
if isPreRegisteredProbe(probe, refpts)
    
    % Register probe by simply pulling (or pushing) optodes toward surface
    % toward (or away from) center of head.
    probe = pullProbeToHeadsurf(probe, headobj);
    probe.hOptodesIdx = 1;
   
else
    
    % Register probe using springs based method
    if headvol.isempty(headvol)
        MessageBox('Error registering probe using spring relaxation. Headvol object is empty');
        return;
    end
    [reg_flag, msg] = probeHasSpringRegistration(probe);
    if ~reg_flag
%         msg{1} = sprintf('\nWARNING: Loaded probe lacks registration data. In order to register it\n');
%         msg{2} = sprintf('to head surface you need to add registration data. You can manually add\n');
%         msg{3} = sprintf('registration data using SDgui application.\n\n');
        MessageBox(msg);
        return
    end
        
    % Get registered optode positions and then display springs
    probe = registerProbe2Head(probe, headvol, refpts);
    probe = probe.copyLandmarks(probe, refpts);
    probe.save(probe);
    
end
probe.orientation = refpts.orientation;
probe.center      = refpts.center;

% Clear old registration from gui after registering probe to avoid 
% lag time between diplay of initial probe and registered probe
[probe, fwmodel, labelssurf] = ...
    clearRegistration(probe, fwmodel, labelssurf, dirnameSubj);

% View registered optodes on the head surface
probe = displayProbe(probe);

% Draw measurement list and save handle
probe = findMeasMidPts(probe);

fwmodel = updateGuiControls_AfterProbeRegistration(probe, fwmodel, imgrecon, labelssurf);

probe.hOptodesIdx = 1; 
probe = setProbeDisplay(probe, headsurf);


atlasViewer.probe       = probe;
atlasViewer.probe_copy = probe;
atlasViewer.fwmodel     = fwmodel;
atlasViewer.labelssurf  = labelssurf;
atlasViewer.digpts      = digpts;

set(handles.text_isProbeChanged,'String','')


if strcmpi(get(handles.menuItemProbeDesignEditAV,'Checked'),'on')
    if get(handles.radiobuttonEditOptodeAV,'Value')
        if get(handles.radiobutton_MeasListVisible,'Value')
            radiobutton_MeasListVisible_Callback(hObject, eventdata, handles)
        elseif get(handles.radiobutton_SpringListVisible,'Value')
            radiobutton_SpringListVisible_Callback(hObject, eventdata, handles)
        end
    end
end


% --------------------------------------------------------------------
function menuItemExit_Callback(~, ~, ~)
global atlasViewer
probe = atlasViewer.probe;

if ishandles(probe.handles.hSDgui) 
    delete(probe.handles.hSDgui);
    probe.handles.hSDgui=[];
end
delete(atlasViewer.handles.figure);
atlasViewer=[];




% --------------------------------------------------------------------
function checkboxHideProbe_Callback(hObject, ~, ~)
global atlasViewer;
probe    = atlasViewer.probe;
headsurf = atlasViewer.headsurf;

hideProbe = get(hObject,'value');
probe.hideProbe = hideProbe;

probe = setProbeDisplay(probe, headsurf);
atlasViewer.probe = probe;



% --------------------------------------------------------------------
function checkboxHideMeasList_Callback(hObject, ~, ~)
global atlasViewer;
probe = atlasViewer.probe;
headsurf = atlasViewer.headsurf;

hideMeasList = get(hObject,'value');
probe.hideMeasList = hideMeasList;
probe = drawMeasChannels(probe);
probe = setProbeDisplay(probe, headsurf);

atlasViewer.probe = probe;


% --------------------------------------------------------------------
function checkboxHideSprings_Callback(hObject, ~, handles)
global atlasViewer;
probe = atlasViewer.probe;
headsurf = atlasViewer.headsurf;

hideSprings = get(hObject,'value');
probe.hideSprings = hideSprings;

if hideSprings==0
    set(handles.editSpringLenThresh,'visible','on');
    set(handles.textSpringLenThresh,'visible','on');
else
    set(handles.editSpringLenThresh,'visible','off');
    set(handles.textSpringLenThresh,'visible','off');
end

probe = displaySprings(probe);
probe = setProbeDisplay(probe,headsurf);

atlasViewer.probe = probe;


% --------------------------------------------------------------------
function checkboxHideDummyOpts_Callback(hObject, ~, ~)
global atlasViewer;
probe = atlasViewer.probe;
headsurf = atlasViewer.headsurf;

hideDummyOpts = get(hObject,'value');
probe.hideDummyOpts = hideDummyOpts;
probe = setProbeDisplay(probe,headsurf);

atlasViewer.probe = probe;



% --------------------------------------------------------------------
function menuItemChangeSubjDir_Callback(~, ~, ~) %#ok<*DEFNU>
global atlasViewer

dirnameAtlas = atlasViewer.dirnameAtlas;
axesv = atlasViewer.axesv;


dirnameSubj = uigetdir('*.*','Change current subject directory');
if dirnameSubj==0
    return;
end
if length(axesv)>1
    if ishandles(axesv(2).handles.axesSurfDisplay)
        hp = get(axesv(2).handles.axesSurfDisplay,'parent');
        delete(hp);
    end
end
AtlasViewerGUI(dirnameSubj, dirnameAtlas, 'userargs');




% --------------------------------------------------------------------
function menuItemChangeAtlasDir_Callback(~, ~, ~)
global atlasViewer
dirnameSubj = atlasViewer.dirnameSubj;
dirnameAtlas = atlasViewer.dirnameAtlas;
axesv = atlasViewer.axesv;
fwmodel = atlasViewer.fwmodel;


% Get the directory containing all the atlases and pass it to the 
% function which lets the user select from the list of atlases.
if ~isempty(dirnameAtlas)
    k = find(dirnameAtlas=='\' | dirnameAtlas=='/');
    dirnameAtlas = selectAtlasDir(dirnameAtlas(1:k(end-1)));
else
    dirnameAtlas = getAtlasDir({''});
end
if isempty(dirnameAtlas) 
    return;
end
if length(dirnameAtlas)==1 
    if dirnameAtlas==0
        return;
    end
end
if ~exist([dirnameSubj,'viewer'],'dir')
    mkdir([dirnameSubj,'viewer']);
else
    delete([dirnameSubj 'viewer/headvol*']);
end
fid = fopen([dirnameSubj,'viewer/settings.cfg'],'w');
fprintf(fid,'%s',dirnameAtlas);
fclose(fid);

% Restart AtlasViewerGUI with the new atlas directory.
AtlasViewerGUI(dirnameSubj, dirnameAtlas, fwmodel.mc_exepath, 'userargs');



% --------------------------------------------------------------------
function menuItemSaveRegisteredProbe_Callback(~, ~, ~)
global atlasViewer

probe      = atlasViewer.probe;
refpts     = atlasViewer.refpts;

optpos_reg = probe.optpos_reg;
nsrc       = probe.nsrc;
ndet       = probe.noptorig-nsrc;
ndummy     = probe.registration.ndummy;

q = menu('Saving registered probe in probe_reg.txt - is this OK? Choose ''No'' to save in other filename or format','Yes','No');
if q==2
    filename = uiputfile({'*.mat';'*.txt'},'Save registered probe to file');
    if filename==0
        return;
    end
elseif q==1
    filename = 'probe_reg.txt';
end

k = find(filename=='.');
ext = filename(k(end)+1:end);
if strcmpi(ext,'txt') || isempty(ext)
    fid = fopen(filename,'w');
    optpos_s        = optpos_reg(1:nsrc, :);
    optpos_d        = optpos_reg(nsrc+1:nsrc+ndet, :);
    optpos_dummy    = optpos_reg(nsrc+ndet+1:end, :);
    for ii=1:nsrc
        fprintf(fid,'s%d: %0.15f %0.15f %0.15f\n',ii,optpos_s(ii,:));
    end
    for ii=1:ndet
        fprintf(fid,'d%d: %0.15f %0.15f %0.15f\n',ii,optpos_d(ii,:));
    end
    for ii=1:ndummy
        fprintf(fid,'m%d: %0.15f %0.15f %0.15f\n',ii,optpos_dummy(ii,:));
    end
    
    qq = menu('Do you want to include the 10-20 reference points?','Yes','No');
    if qq==1
        fprintf(fid,'\n\n\n');
        for ii=1:size(refpts.pos,1)
            fprintf(fid,'%s: %.1f %.1f %.1f\n',refpts.labels{ii},refpts.pos(ii,1),refpts.pos(ii,2),refpts.pos(ii,3) );
        end
    end    
    fclose(fid);
elseif strcmpi(extenstion,'mat')
    save(filename,'-mat','optpos_reg','nsrc');
end



% --------------------------------------------------------------------
function hray = drawRayProjection(p1,p2,headsurf)

if leftRightFlipped(headsurf)
    axesOrd=[2 1 3];
else
    axesOrd=[1 2 3];
end    

hray = line([p1(axesOrd(1)),p2(axesOrd(1))],[p1(axesOrd(2)),p2(axesOrd(2))],...
            [p1(axesOrd(3)),p2(axesOrd(3))],'color','m','linewidth',2);       
set(hray,'tag','MNI projection');
drawnow();




% --------------------------------------------------------------------
function menuItemChooseLabelsColormap_Callback(~, ~, ~)
global atlasViewer

hLabelsSurf     = atlasViewer.labelssurf.handles.surf;
vertices        = atlasViewer.labelssurf.mesh.vertices;
idxL            = atlasViewer.labelssurf.idxL;
namesL          = atlasViewer.labelssurf.names;
colormaps       = atlasViewer.labelssurf.colormaps;
colormapsIdx    = atlasViewer.labelssurf.colormapsIdx;
iFaces          = atlasViewer.labelssurf.iFaces;

if ~ishandles(hLabelsSurf)
    return;
end

n = length(colormaps);
cmLst = cell(n,1);
for ii=1:n
    cmLst{ii} = sprintf('%s',colormaps(ii).name);
end
cmLst{n+1} = 'Cancel';
ch = menu('Choose Labels Colormap',cmLst);
if ch>n
    return;
end
cm = colormaps(ch).col;
faceVertexCData = cm(idxL,:);
faceVertexCData(iFaces,:) = repmat([1 0 0],length(iFaces),1);
set(hLabelsSurf,'faceVertexCData',faceVertexCData);
atlasViewer.labelssurf.colormapsIdx = ch;




% --------------------------------------------------------------------
function menuItemRegisterAtlasToDigpts_Callback(hObject, ~, ~)
global atlasViewer
global DEBUG

if ~exist('hObject','var')
    hObject = [];
end
if ~ishandles(hObject)
    % If call to menuItemRegisterAtlasToDigpts_Callback is not a GUI event then exit
    return;
end
if strcmp(get(hObject, 'enable'), 'off')
    return
end

refpts       = atlasViewer.refpts;
digpts       = atlasViewer.digpts;
headsurf     = atlasViewer.headsurf;
headvol      = atlasViewer.headvol;
pialsurf     = atlasViewer.pialsurf;
probe        = atlasViewer.probe;
labelssurf   = atlasViewer.labelssurf;
axesv        = atlasViewer.axesv;
fwmodel      = atlasViewer.fwmodel;
imgrecon     = atlasViewer.imgrecon; 
hbconc       = atlasViewer.hbconc; 


% Check conditions which would make us exit early
if digpts.refpts.isempty(digpts.refpts)
    return;
end
if refpts.isempty(refpts)
    return;
end 
if all(isregistered(refpts,digpts))
    return;
end

%%%% Move all the volumes, surfaces and points back to a known space 
%%%% volume space. 

% First determine transformation to monte carlo space from volume 
% Generate transformation from head volume to digitized points space
[rp_atlas, rp_subj] = findCorrespondingRefpts(refpts, digpts.refpts);
headvol.T_2digpts = gen_xform_from_pts(rp_atlas, rp_subj);
headvol.imgOrig = headvol.img;


% Register headvol to digpts but first check fwmodel if it's volume 
% is already registered to digpts. if it is then set the headvol object 
% to the fwmodel's headvol and reuse it. 
if ~isregisteredFwmodel(fwmodel, headvol)
    
    [headvol.img, digpts.T_2mc] = ...
        xform_apply_vol_smooth(headvol.img, headvol.T_2digpts);
    
    headvol.T_2mc   = digpts.T_2mc * headvol.T_2digpts;
    headvol.center = xform_apply(headvol.center, headvol.T_2mc);
    headvol.orientation = digpts.orientation;
    
    % The MC space volume changed invalidating fwmodel meshes and 
    % vol to surface mesh. We need to recalculate all of this.
    fwmodel  = resetFwmodel(fwmodel, headvol);
    imgrecon = resetImgRecon(imgrecon);
    
else
    
    % Reusing MC space headvol from fwmodel. 
    headvol = fwmodel.headvol;
    
    % We know that headvol.T_2mc = digpts.T_2mc * headvol.T_2digpts.
    % Here we need to recover digpts.T_2mc. We can do this from 
    % headvol.T_2mc and headvol.T_2digpts with a little matrix algebra
    digpts.T_2mc = headvol.T_2mc / headvol.T_2digpts;
    
end

% Move digitized pts to monte carlo space
digpts.refpts.pos = xform_apply(digpts.refpts.pos, digpts.T_2mc);
digpts.pcpos      = xform_apply(digpts.pcpos, digpts.T_2mc);
digpts.srcpos     = xform_apply(digpts.srcpos, digpts.T_2mc);
digpts.detpos     = xform_apply(digpts.detpos, digpts.T_2mc);
digpts.optpos     = [digpts.srcpos; digpts.detpos];
digpts.center     = digpts.refpts.center;

% Copy digitized optodes to probe object
if ~isempty(probe.optpos_reg)
    probe.optpos_reg = xform_apply(probe.optpos_reg, digpts.T_2mc * probe.T_2digpts);
else
    probe.optpos_reg = xform_apply(probe.optpos, digpts.T_2mc * probe.T_2digpts);
end
probe.registration.refpts.pos = xform_apply(probe.registration.refpts.pos, digpts.T_2mc * probe.T_2digpts);

% move head surface to monte carlo space 
headsurf.mesh.vertices   = xform_apply(headsurf.mesh.vertices, headvol.T_2mc);
headsurf.center          = xform_apply(headsurf.center, headvol.T_2mc);
headsurf.centerRotation  = xform_apply(headsurf.centerRotation, headvol.T_2mc);

% move pial surface to monte carlo space 
pialsurf.mesh.vertices   = xform_apply(pialsurf.mesh.vertices, headvol.T_2mc);
pialsurf.center          = xform_apply(pialsurf.center, headvol.T_2mc);

% move anatomical labels surface to monte carlo space 
labelssurf.mesh.vertices = xform_apply(labelssurf.mesh.vertices, headvol.T_2mc);
labelssurf.center        = xform_apply(labelssurf.center, headvol.T_2mc);

% move ref points to monte carlo space 
refpts = xform_apply_Refpts(refpts, headvol.T_2mc);

% The fwmodel meshes are inherited from pial and head surf at init time. Therefore they are 
% in original unregistered volume space, not MC space. Therefore we have to transform it to 
% MC space. 
fwmodel.mesh.vertices       = xform_apply(fwmodel.mesh.vertices, headvol.T_2mc);
fwmodel.mesh_scalp.vertices = xform_apply(fwmodel.mesh_scalp.vertices, headvol.T_2mc);
fwmodel.mesh_orig.vertices  = xform_apply(fwmodel.mesh_orig.vertices, headvol.T_2mc);
fwmodel.mesh_scalp_orig.vertices = xform_apply(fwmodel.mesh_scalp_orig.vertices, headvol.T_2mc);

% The imgrecon meshes are inherited from pial surf at init time. Therefore they are 
% in original unregistered volume space, not MC space. Therefore we have to transform it to 
% MC space. 
imgrecon.mesh.vertices       = xform_apply(imgrecon.mesh.vertices, headvol.T_2mc);
imgrecon.mesh_orig.vertices  = xform_apply(imgrecon.mesh_orig.vertices, headvol.T_2mc);

% No need to move hbconc mesh, we already have our pialsurf in mc space 
% simply assign it to hbconc. 
hbconc.mesh        = pialsurf.mesh;

if DEBUG
    headvol.mesh.vertices = xform_apply(headvol.mesh.vertices, headvol.T_2mc);
end

%%%% Now display all axes objects 

% Bounding box of axes objects might change - allow the axes limits 
% to change with it dynamically.
set(axesv(1).handles.axesSurfDisplay,{'xlimmode','ylimmode','zlimmode'},{'auto','auto','auto'});
axes(axesv(1).handles.axesSurfDisplay);
cla

% Set the orientation for display puposes to the dig pts 
[refpts, headvol, headsurf, pialsurf, labelssurf, probe, fwmodel, imgrecon, hbconc] = ...
    setOrientationDigpts(digpts, refpts, headvol, headsurf, pialsurf, labelssurf, probe, fwmodel, imgrecon, hbconc);

headsurf       = displayHeadsurf(headsurf);
pialsurf       = displayPialsurf(pialsurf);
labelssurf     = displayLabelssurf(labelssurf);
refpts         = displayRefpts(refpts);
digpts         = displayDigpts(digpts);
probe          = displayProbe(probe);
axesv(1)       = displayAxesv(axesv(1), headsurf, headvol, initDigpts());

set(axesv(1).handles.axesSurfDisplay,{'xlimmode','ylimmode','zlimmode'},{'manual','manual','manual'});

if ishandles(labelssurf.handles.surf)
    set(labelssurf.handles.menuItemSelectLabelsColormap,'enable','on');
else
    set(labelssurf.handles.menuItemSelectLabelsColormap,'enable','off');
end

probe = updateProbeGuiControls(probe, headsurf);

%%% Save new atlas coordinates in atlasViewer
atlasViewer.headsurf    = headsurf;
atlasViewer.pialsurf    = pialsurf;
atlasViewer.labelssurf  = labelssurf;
atlasViewer.refpts      = refpts;
atlasViewer.headvol     = headvol;
atlasViewer.digpts      = digpts;
atlasViewer.probe       = probe;
atlasViewer.axesv       = axesv;
atlasViewer.fwmodel     = fwmodel;
atlasViewer.imgrecon    = imgrecon;
atlasViewer.hbconc      = hbconc;




% --------------------------------------------------------------------
function menuItemGenerateMCInput_Callback(hObject, eventdata, handles)
global atlasViewer

fwmodel       = atlasViewer.fwmodel;
dirnameSubj   = atlasViewer.dirnameSubj;
probe         = atlasViewer.probe;

qAdotExists = 0;

% Check if there's a sensitivity profile which already exists
if exist([dirnameSubj 'fw/Adot.mat'],'file')
    qAdotExists = menu('Do you want to use the existing sensitivity profile in Adot.mat','Yes','No');
    if qAdotExists == 1
        fwmodel = menuItemGenerateLoadSensitivityProfile_Callback(hObject, struct('EventName','Action'), handles);
        if ~isempty(fwmodel.Adot)
            enableDisableMCoutputGraphics(fwmodel, 'on');
        end
    else
        delete([dirnameSubj 'fw/Adot*.mat']);
    end
end
    
% If neither a sensitivity not fluence profiles exist, then generate MC input and output
if qAdotExists~=1

    %%% Figure out wether we can proceed with the next step in the workflow
    %%% check whether we have what we need (i.e., MC output) to enable the
    %%% sensitivity profile menu item
    fwmodel = existMCOutput(fwmodel,probe,dirnameSubj);    
    if all(fwmodel.errMCoutput==3)
        if ~isempty(probe.ml)
            msg1 = sprintf('MC input and output already exist for this probe.\n');
            msg2 = sprintf('Use ''Generate/Load Sensitivity Profile'' under the\n');
            msg3 = sprintf('Forward Model menu to generate the sensitivity profile');
            menu([msg1,msg2,msg3],'OK');
            enableDisableMCoutputGraphics(fwmodel, 'on');
        else
            msg1 = sprintf('MC input and output already exist for this probe, but file with measurement list\n');
            msg2 = sprintf('is missing. NOTE: The .nirs file from an experiment using this probe\n');
            msg3 = sprintf('should contain the measurement list. Copy this file to the subject directory');
            menu([msg1,msg2,msg3],'OK');
            enableDisableMCoutputGraphics(fwmodel, 'off');
        end
    else
        if ismember(-1,fwmodel.errMCoutput)
            q = menu(sprintf('MC input does not match current probe. Generate new input and output for MC app %s?',fwmodel.mc_appname),...
                'Yes','No');
            if q==1
                fwmodel = genMCinput(fwmodel, probe, dirnameSubj);
                fwmodel = genMCoutput(fwmodel, probe, dirnameSubj);
            end
        elseif ismember(-2,fwmodel.errMCoutput)
            q = menu(sprintf('MC input doesn''t match current MC settings. Generate new input and output for MC app %s?',fwmodel.mc_appname),...
                'Yes','No');
            if q==1
                fwmodel = genMCinput(fwmodel, probe, dirnameSubj);
                fwmodel = genMCoutput(fwmodel, probe, dirnameSubj);
            end
        elseif all(fwmodel.errMCoutput>1)
            q = menu(sprintf('MC input exists but newer than ouput. Generate new input and output for MC app %s?',fwmodel.mc_appname),...
                'Yes','No');
            if q==1
                fwmodel = genMCinput(fwmodel, probe, dirnameSubj);
                fwmodel = genMCoutput(fwmodel, probe, dirnameSubj);
            end
        elseif all(fwmodel.errMCoutput>0)
            q = menu(sprintf('MC input exists but no output.'),...
                sprintf('Overwrite input and generate output for MC app %s',fwmodel.mc_appname),...
                'Generate new output only',...
                'Cancel');
            if q==1
                fwmodel = genMCinput(fwmodel, probe, dirnameSubj);
                fwmodel = genMCoutput(fwmodel, probe, dirnameSubj);
            elseif q==2
                fwmodel = genMCoutput(fwmodel, probe, dirnameSubj);
            end
        else
            q = menu(sprintf('Generate new input and output for MC app %s?',fwmodel.mc_appname),...
                'Yes','No');
            if q==1
                fwmodel = genMCinput(fwmodel, probe, dirnameSubj);
                fwmodel = genMCoutput(fwmodel, probe, dirnameSubj);
            end
        end
    end
end

atlasViewer.fwmodel = fwmodel;




% --------------------------------------------------------------------
function msg = makeMsgOutOfMem(type)

switch(type)
    case 'outofmem'
        msg = 'There''s not enough contiguous memory to generate a sensitivity profile. ';
        msg = [msg, 'This can happen on older 32-bit systems or 32-bit matlab. '];
        msg = [msg, 'AtlasViewerGUI will try to increase the memory. It will require '];
        msg = [msg, 'a restart of the PC for these changes to take effect.'];
    case 'outofmemlinux'
        msg = 'An error occured which terminated the generation of the sensitivity profile. ';
        msg = [msg, 'One reason for this might be that the system ran out of contiguous memory. '];
        msg = [msg, 'Since matlab''s memory command is only implemented for Windows '];
        msg = [msg, 'the user has to monitor the memory themselves to confirm this. '];
        msg = [msg, 'Some possible solutions might be to increase swap space, terminataing other '];
        msg = [msg, 'processes or adding more physical memory.'];
    case 'restart'
        msg = 'Successfully changed setting for the amount of memory allocated to applications ';
        msg = [msg, '(ran dos command ''bcdedit /set IncreaseUserVa 3072''). '];
        msg = [msg, 'Now close all windows, restart the PC and rerun AtlasViewerGUI. '];
        msg = [msg, 'If that still doesn''t work consider running on a 64-bit system and/or '];
        msg = [msg, 'with a 64-bit matlab.'];
    case 'accessdenied'
        msg = 'Attempt to increase contiguous memory setting failed. This may be due to ';
        msg = [msg, 'lack of administrator priviledges for this account. '];
        msg = [msg, 'Consider acquiring administrator priviledges then re-running or '];
        msg = [msg, 'running AtlasViewerGUI on a 64-bit system and/or with a 64-bit matlab.'];
end



% --------------------------------------------------------------------
function fwmodel = menuItemGenerateLoadSensitivityProfile_Callback(hObject, eventdata, handles)
global atlasViewer

fwmodel     = atlasViewer.fwmodel;
imgrecon    = atlasViewer.imgrecon;
hbconc      = atlasViewer.hbconc;
probe       = atlasViewer.probe;
headvol     = atlasViewer.headvol;
pialsurf    = atlasViewer.pialsurf;
headsurf    = atlasViewer.headsurf;
dirnameSubj = atlasViewer.dirnameSubj;
axesv       = atlasViewer.axesv;

try 
    if isempty(eventdata) | strcmp(eventdata.EventName,'Action')
        fwmodel = genSensitivityProfile(fwmodel,probe,headvol,pialsurf,headsurf,dirnameSubj);
        if isempty(fwmodel.Adot)
            return;
        end
        imgrecon = resetImgRecon(imgrecon);
    end 
catch ME
    if strcmp(ME.identifier,'MATLAB:nomem') | ...
       strcmp(ME.identifier,'MATLAB:pmaxsize')
        if ispc()
            waitfor(msgbox(makeMsgOutOfMem('outofmem')));
            status = dos('bcdedit /set IncreaseUserVa 3072');
            if status>0
                waitfor(msgbox(makeMsgOutOfMem('accessdenied')));
            else
                waitfor(msgbox(makeMsgOutOfMem('restart')));
            end
            closeallwaitbars();
        else
            waitfor(msgbox(makeMsgOutOfMem('outofmemlinux')));
        end
    else
        rethrow(ME);
    end
    return;
end

% Set image popupmenu to sensitivity
set(handles.popupmenuImageDisplay,'value',fwmodel.menuoffset+1);
set(handles.editColormapThreshold,'string',sprintf('%0.2g %0.2g',fwmodel.cmThreshold(1),fwmodel.cmThreshold(2)));

% Turn off image recon display
imgrecon = showImgReconDisplay(imgrecon, axesv(1).handles.axesSurfDisplay, 'off', 'off', 'off','off');
hbconc = showHbConcDisplay(hbconc, axesv(1).handles.axesSurfDisplay, 'off', 'off');

fwmodel = displaySensitivity(fwmodel, pialsurf, [], probe);
if isempty(fwmodel.Adot)
    return
end
    
set(pialsurf.handles.radiobuttonShowPial, 'value',0);
uipanelBrainDisplay_Callback(pialsurf.handles.radiobuttonShowPial, [], handles);

if ~isempty(fwmodel.Adot)
    imgrecon = enableImgReconGen(imgrecon,'on');
    imgrecon.mesh = fwmodel.mesh;
else
    imgrecon = enableImgReconGen(imgrecon,'off');
end

atlasViewer.fwmodel = fwmodel;
atlasViewer.imgrecon = imgrecon;



% --------------------------------------------------------------------
function menuItemGenFluenceProfile_Callback(~, ~, ~)
global atlasViewer

fwmodel     = atlasViewer.fwmodel;
probe       = atlasViewer.probe;
headvol     = atlasViewer.headvol;
pialsurf    = atlasViewer.pialsurf;
dirnameSubj = atlasViewer.dirnameSubj;

dirnameOut = [dirnameSubj 'fw/'];

err = 0;

fwmodel.fluenceProfFnames = {};
probe_section = initProbe();
inp = inputdlg_errcheck({'Number of fluence profiles per file'},'Number of fluence profiles per file', ...
                        1, {num2str(fwmodel.nFluenceProfPerFile)});
if ~isempty(inp)
    fwmodel.nFluenceProfPerFile = str2num(inp{1});
end
sectionsize = fwmodel.nFluenceProfPerFile;

fwmodel.fluenceProf(1) = initFluenceProf();
fwmodel.fluenceProf(2) = initFluenceProf();
for ii = 1:sectionsize:probe.noptorig
    fluenceExists = false;

    fwmodel.fluenceProf(1).index = fwmodel.fluenceProf(1).index+1;
    iFirst = ii;
    iF = fwmodel.fluenceProf(1).index;
    if sectionsize>probe.noptorig
        iLast = probe.noptorig;
    else
        iLast = mod((iF-1)*sectionsize+sectionsize, probe.noptorig);
        if iFirst>iLast
            iLast = probe.noptorig;
            fwmodel.fluenceProf(1).last = true;
        end
    end
    
    fprintf('iFirst=%d, iLast=%d\n', iFirst, iLast);
    
    % Get number of sources in this probe section
    nsrc = probe.nsrc-iFirst+1;
    if nsrc<0
        nsrc=0;
    elseif iLast <= probe.nsrc
        nsrc = iLast-iFirst+1;
    end
    
    % Get number of dets in this probe section
    if iFirst > probe.nsrc
        ndet = iFirst-iLast+1;
    elseif iFirst <= probe.nsrc & iLast <= probe.nsrc
        ndet = 0;
    elseif iFirst <= probe.nsrc & iLast > probe.nsrc
        ndet = iLast-probe.nsrc;
    end
    
    probe_section.optpos_reg = probe.optpos_reg(iFirst:iLast,:);
    probe_section.nsrc     = nsrc;
    probe_section.ndet     = ndet;
    probe_section.nopt     = nsrc+ndet;
    probe_section.noptorig = nsrc+ndet;
    
    filenm = sprintf('%sfluenceProf%d.mat', dirnameOut, fwmodel.fluenceProf(1).index);
    if exist(filenm, 'file')
        fluenceExists = true;
    end
    
    if ~fluenceExists
	    fwmodel = existMCOutput(fwmodel,probe_section,dirnameSubj);
	    if ~all(fwmodel.errMCoutput==3 | fwmodel.errMCoutput==2)
	        fwmodel = genMCinput(fwmodel, probe_section, dirnameSubj);
	        [fwmodel, err] = genMCoutput(fwmodel, probe_section, dirnameSubj, 'noninteractive');
	    else
	        fprintf('MC output already exists for fluence profile %d\n', fwmodel.fluenceProf(1).index);
	    end
    end
    
    if err~=0
        return;
    end
    
    s = iLast-iFirst+1;
    iFirst = 1;
    iLast = s;
    
    fprintf('Finished with MC output for fluence profile %d\n', fwmodel.fluenceProf(1).index);
    if ~fluenceExists
    	fwmodel = genFluenceProfile(fwmodel, probe, iFirst, iLast, headvol, pialsurf, dirnameSubj);
    end
    fprintf('Completed fluence profile %d\n\n', fwmodel.fluenceProf(1).index);
    
    delete([dirnameOut 'fw*.inp*']);
    
end

atlasViewer.fwmodel = fwmodel;



% --------------------------------------------------------------------
function radiobuttonShowDigpts_Callback(hObject, ~, ~)
global atlasViewer

digpts = atlasViewer.digpts;
hRefpts = digpts.handles.hRefpts;
hPcpos = digpts.handles.hPcpos;

val = get(hObject,'value');
if val==1
    if ~isempty(digpts.refpts.pos)
        set(hRefpts(:,1),'visible','on');
        set(hRefpts(:,2),'visible','off');
    end
    if ~isempty(digpts.pcpos)
        set(hPcpos(:,1),'visible','on');
        set(hPcpos(:,2),'visible','off');
    end
else
    set(hRefpts,'visible','off');
    set(hPcpos,'visible','off');
end

    


% --------------------------------------------------------------------
function checkboxOptodeSDMode_Callback(~, ~, ~)
global atlasViewer
probe    = atlasViewer.probe;
headsurf = atlasViewer.headsurf;

probe = setOptodeNumbering(probe);
probe = setProbeDisplay(probe, headsurf);

atlasViewer.probe = probe;




% --------------------------------------------------------------------
function menuItemFs2Viewer_Callback(hObject, eventdata, handles)
global atlasViewer

fs2viewer = atlasViewer.fs2viewer;
dirnameSubj = atlasViewer.dirnameSubj;
dirnameAtlas = atlasViewer.dirnameAtlas;

status = ImportMriAnatomy(fs2viewer, handles, dirnameSubj, 'AtlasViewerGUI');
if sum(status)>0
    return;
end

% Reload subject with it's own, newly-generated anatomical files
AtlasViewerGUI(dirnameSubj, dirnameAtlas, 'userargs');

% Allow user to select reference points
q = menu('Select basic reference points, Nz, Iz, LPA, RPA, Cz, for this anatomy?', 'OK','Cancel');
if q==1
    menuItemFindRefpts_Callback(hObject, eventdata, handles);
end



% --------------------------------------------------------------------
function menuItemShowRefpts_Callback(hObject, eventdata, handles)
global atlasViewer

switch(get(hObject, 'tag'))
    case 'menuItemShow10_20'
        atlasViewer.refpts.eeg_system.selected = '10-20';
        set_eeg_curve_select(atlasViewer.refpts);
    case 'menuItemShow10_10'
        atlasViewer.refpts.eeg_system.selected = '10-10';
        set_eeg_curve_select(atlasViewer.refpts);
    case 'menuItemShow10_5'
        atlasViewer.refpts.eeg_system.selected = '10-5';
        set_eeg_curve_select(atlasViewer.refpts);
    case 'menuItemShow10_2_5'
        atlasViewer.refpts.eeg_system.selected = '10-2.5';
    case 'menuItemShow10_1'
        atlasViewer.refpts.eeg_system.selected = '10-1';
    case 'menuItemShowSelectedCurves10_20'
                atlasViewer.refpts.eeg_system.selected = 'selected_curves_10_20';
        if ~ishandles(atlasViewer.refpts.handles.SelectEEGCurvesGUI)
            atlasViewer.refpts.handles.SelectEEGCurvesGUI = SelectEEGCurvesGUI();
        end
    case 'menuItemShowSelectedCurves10_10'
        atlasViewer.refpts.eeg_system.selected = 'selected_curves_10_10';
        if ~ishandles(atlasViewer.refpts.handles.SelectEEGCurvesGUI)
            atlasViewer.refpts.handles.SelectEEGCurvesGUI = SelectEEGCurvesGUI();
        end
    case 'menuItemShowSelectedCurves10_5'
        atlasViewer.refpts.eeg_system.selected = 'selected_curves_10_5';
        if ~ishandles(atlasViewer.refpts.handles.SelectEEGCurvesGUI)
            atlasViewer.refpts.handles.SelectEEGCurvesGUI = SelectEEGCurvesGUI();
        end
end

atlasViewer.refpts = setRefptsMenuItemSelection(atlasViewer.refpts);
atlasViewer.refpts = set_eeg_active_pts(atlasViewer.refpts);

atlasViewer.refpts = displayRefpts(atlasViewer.refpts);

if ishandles(atlasViewer.refpts.handles.SelectEEGCurvesGUI)
    figure(atlasViewer.refpts.handles.SelectEEGCurvesGUI);
end



% --------------------------------------------------------------------
function menuItemEnableSensitivityMatrixVolume_Callback(hObject, ~, ~)
global atlasViewer
fwmodel = atlasViewer.fwmodel;

checked = get(hObject,'checked');
if strcmp(checked,'on')
    set(hObject,'checked','off');
    val=0;
elseif strcmp(checked,'off')
    set(hObject,'checked','on');
    val=1;
else
    return;
end
fwmodel = enableSensitivityMatrixVolume(fwmodel,val);
atlasViewer.fwmodel = fwmodel;




% --------------------------------------------------------------------
function pushbuttonCopyFigure_Callback(~, ~, ~)
global atlasViewer
axesv       = atlasViewer.axesv;

cm = colormap;
clim = caxis;

hf = figure;
hAxes = copyobj(axesv(1).handles.axesSurfDisplay, hf);
axis off
axis equal
axis vis3d
set(gca, 'unit','normalized');
p = get(gca, 'position');
set(gca, 'unit','normalized', 'position', [.20, .30, .40, .40]);

% colormap is a propery of figure not axes. Since we don't want to 
% copy the whole figure which is the gui but only the axes, we need to 
% set the figure colormap after the copyobj. 
h = colormap(cm);
caxis(clim);

axesv(1).handles.axesSurfDisplay = hAxes;
camzoom(axesv(1).handles.axesSurfDisplay, 1.3*axesv(1).zoomincr);



% --------------------------------------------------------------------
function menuItemSaveViewerState_Callback(~, ~, ~)
global atlasViewer

axesv       = atlasViewer.axesv(1);
headvol     = atlasViewer.headvol;
headsurf    = atlasViewer.headsurf;
pialsurf    = atlasViewer.pialsurf;
labelssurf  = atlasViewer.labelssurf;
refpts      = atlasViewer.refpts;
digpts      = atlasViewer.digpts;
probe       = atlasViewer.probe;
hbconc      = atlasViewer.hbconc;
fwmodel 	= atlasViewer.fwmodel;
imgrecon    = atlasViewer.imgrecon;

saveObjects('atlasViewer.mat', ...
    axesv, ...
    headvol, ...
    headsurf, ...
    pialsurf, ...
    labelssurf, ...
    refpts, ...
    labelssurf, ...
    digpts, ...
    probe, ...
    hbconc, ...
    fwmodel, ...
    imgrecon ...
    );



% --------------------------------------------------------------------
function checkboxOptodeCircles_Callback(hObject, eventdata, handles)
global atlasViewer

probe    = atlasViewer.probe;
headsurf = atlasViewer.headsurf;

val = get(hObject,'value');
if val==1
    probe.optViewMode='circles';
else
    probe.optViewMode='numbers';
end
probe = setOptodeNumbering(probe);
probe = setProbeDisplay(probe, headsurf);

atlasViewer.probe = probe;




% --------------------------------------------------------------------
function menuItemLighting_Callback(hObject, eventdata, handles)
global atlasViewer

axesv       = atlasViewer.axesv;

if strcmp(get(hObject,'checked'), 'on');
    set(hObject,'checked', 'off');
    val=0;
elseif strcmp(get(hObject,'checked'), 'off');
    set(hObject,'checked', 'on');
    val=1;
end

name = get(hObject,'label');
iLight = str2num(name(end));

if val==1
    set(axesv(1).handles.lighting(iLight),'visible','on');
else
    set(axesv(1).handles.lighting(iLight),'visible','off');
end



% --------------------------------------------------------------------
function menuItemFindRefpts_Callback(hObject, eventdata, handles)
FindRefptsGUI();


% --------------------------------------------------------------------
function menuProbePlacementVariation_Callback(hObject, eventdata, handles)
plotProbePlacementVariation();



% --------------------------------------------------------------------
function menuItemRegisterAtlasToHeadSize_Callback(hObject, eventdata, handles)
global atlasViewer

digpts      = atlasViewer.digpts;
probe       = atlasViewer.probe;
refpts      = atlasViewer.refpts;

% If unregistered flat probe exists, warn user that itshould be registed
% before generating simulated digitized optodes.
% if isempty(probe.optpos_reg) && ~isempty(probe.al)
%     msg{1} = sprintf('Warning: Unregistered probe exists. Generating simulated digitized points from unregistred probe');
%     msg{2} = sprintf('will yeild incorrect results. Please register probe to head surface before generating simulated ');
%     msg{3} = sprintf('digitized points. Do you still want to proceed?');
%     q = MenuBox(msg, {'YES','NO'});
%     if q==2
%         return;
%     end
% end


% Get head size measurements from input dialog
prompt = {'Head Circumference (cm):','Iz to Nz (cm):','RPA to LPA (cm):'};
dlg_title = 'Input Head Size';
num_lines = 1;
[HC, NzCzIz, LPACzRPA] = extractHeadsize(digpts.headsize);
def = {num2str(HC), num2str(NzCzIz), num2str(LPACzRPA)};
answer = inputdlg(prompt,dlg_title,num_lines,def);
if isempty(answer)
    return
end
digpts.headsize = setHeadsize(digpts.headsize, answer);

% Calculate digitized points
digpts = calcDigptsFromHeadsize(digpts, refpts);

% If digitized points exist but are missing probe optodes, generate 
% artificial digitize optodes 
if ~digpts.isempty(digpts) && digpts.isemptyProbe(digpts)
    digpts = digpts.copyProbe(digpts, probe);    
    saveDigpts(digpts, 'overwrite');
    probe.T_2digpts = inv(digpts.T_2vol);
end

atlasViewer.digpts = digpts;
atlasViewer.probe = probe;

menuItemRegisterAtlasToDigpts_Callback(hObject, eventdata, handles)




% --------------------------------------------------------------------
function editSpringLenThresh_Callback(hObject, ~, ~)
global atlasViewer;

probe = atlasViewer.probe;
sl = probe.registration.sl;
hSprings = probe.handles.hSprings;

if ~isempty(probe.optpos_reg)
    optpos = probe.optpos_reg;
elseif ~isempty(probe.optpos)
    optpos     = probe.optpos;
else
    return;
end

cm = [0 0 1; 0 1 1; 0 0 0; 1 1 0; 1 0 0];
sLenThresh = probe.registration.springLenThresh;

foo = str2num(get(hObject,'string'));
if length(foo)~=2
    set(hObject,'string',num2str(sLenThresh));
    return;
elseif foo(1)>=foo(2)
    set(hObject,'string',num2str(sLenThresh));
    return;
end
probe.registration.springLenThresh = foo;
sLenThresh = probe.registration.springLenThresh;

for ii=1:size(sl,1) 
    springLenReg(ii) = dist3(optpos(sl(ii,1),:), optpos(sl(ii,2),:));
    springLenErr(ii) = springLenReg(ii)-sl(ii,3);
    if springLenErr(ii)<-sLenThresh(2)
        k = 1;
    elseif springLenErr(ii)<-sLenThresh(1)
        k = 2;
    elseif springLenErr(ii)>sLenThresh(2)
        k = 5;
    elseif springLenErr(ii)>sLenThresh(1)
        k = 4;
    else
        k = 3;
    end
    set(hSprings(ii),'color',cm(k,:));
end



% --------------------------------------------------------------------
function menuCalcOptProp_Callback(hObject, eventdata, handles)

prompt        = {'Wavelengths (nm)','HbT (uM)','SO2 (%)','Reduced Scattering Coefficient at 800 nm (1/mm)','Scattering Slope b'};
name          = 'Calculate absorption and scattering';
numlines      = 1;
defaultanswer = {'690 830','60','65','0.8','1.5'};
   
answer = inputdlg(prompt,name,numlines,defaultanswer,'on');
if isempty(answer)
    return;
end

wv = str2num(answer{1});
hbt = str2num(answer{2}) * 1e-6;
so2 = str2num(answer{3}) / 100;
a = str2num(answer{4});
b = str2num(answer{5});

e = GetExtinctions( wv );

mua = e(:,1)*(hbt*so2) + e(:,2)*(hbt*(1-so2));
musp = a * exp(-b*(wv-800)/800);

ch = menu( sprintf('For wavelengths %s nm:\nmua = %s 1/mm\nmusp = %s 1/mm\n', num2str(wv),num2str(mua',4),num2str(musp,4)), 'okay');




% --------------------------------------------------------------------
function probe = menuItemProjectProbeToCortex_Callback(hObject, eventdata, ~)
global atlasViewer

% eventdata tells us if we are displaying label projections ( eventdata==true ) 
% or just finding projection positions ( eventdata==false )
if isempty(eventdata)
    eventdata = true;
end
if isa(eventdata, 'matlab.ui.eventdata.ActionData') && strcmp(eventdata.EventName,'Action')
    eventdata = true;
end

% Assign main objects
probe              = atlasViewer.probe;
labelssurf         = atlasViewer.labelssurf;
headvol            = atlasViewer.headvol;
headsurf           = atlasViewer.headsurf;
pialsurf           = atlasViewer.pialsurf;

% Assign variables from the main objects
optpos_reg         = probe.optpos_reg;
optpos_reg_mean    = probe.optpos_reg_mean;
hProjectionTbl     = probe.handles.hProjectionTbl;
hProjectionRays    = probe.handles.hProjectionRays;
nopt               = probe.noptorig;
ml                 = probe.ml;
ptsProj_cortex_mni = probe.ptsProj_cortex_mni;
attractPt          = headvol.center;
T_labelssurf2vol   = labelssurf.T_2vol;

if ~labelssurf.isempty(labelssurf) && (eventdata == true)
    labelssurf     = initLabelssurfProbeProjection(labelssurf);
    hLabelsSurf    = labelssurf.handles.surf;
    mesh           = labelssurf.mesh;
    vertices       = labelssurf.mesh.vertices;
    idxL           = labelssurf.idxL;
    namesL         = labelssurf.names;
elseif eventdata == false
    vertices       = pialsurf.mesh.vertices;
else
    menu('Warning: No cortical anatomical labels provided for this anatomy.','Ok');
    return;
end
T_headvol2mc       = headvol.T_2mc;

if isempty(hObject)
    option = 2;
else
    option = menu('Select projection type', 'Curr Subject Optodes','Curr Subject Channels', ...
                  'Group Mean: Optodes','Group Mean: Channels','Cancel');
end

% Project optodes to labeled cortex
iTbl = 1;
tblPos = [.1,.02,.45,.8];
ptsProj = [];
switch(option)
    case 1
        
        if ~isempty(optpos_reg)
            ptsProj = optpos_reg(1:nopt,:);
            
            % If projecting optodes rather than meas channels, display optodes
            % in their original registered positions rather than the
            % ones which were lifted off the head surface for easier viewing.
            probe.hOptodesIdx = 2;
            probe = setProbeDisplay(probe,headsurf);
            figname = 'Curr Subject Optode Projection to Cortex Labels';
            
            tblPos(1)= tblPos(1)-.1;
        end
        
    case 2

        ptsProj = probe.mlmp;
        figname = 'Curr Subject Channel Projection to Cortex Labels';
        tblPos(1)= tblPos(1)-.1;
        
    case 3
        
        if ~isempty(optpos_reg_mean)
            ptsProj = optpos_reg_mean(1:nopt,:);
            
            % If projecting optodes rather than meas channels, display optodes
            % in their original registered positions rather than the
            % ones which were lifted off the head surface for easier viewing.
            probe.hOptodesIdx = 2;
            probe = setProbeDisplay(probe,headsurf);
            figname = 'Group Optode Projection to Cortex Labels';
            iTbl = 2;
            tblPos(1)= tblPos(1)+.2;
        end
        
    case 4

        ptsProj = probe.mlmp_mean;
        figname = 'Group Channel Projection to Cortex Labels';
        iTbl = 2;
        tblPos(1)= tblPos(1)+.2;
        
    case 5
        
        return;        
end

if isempty(ptsProj)
    menu('Warning: Projection is Empty', 'OK');
    return;
end

if ishandle(hObject)
    probe = clearProbeProjection(probe, iTbl);
end

% ptsProj_cortex is in viewer space. To get back to MNI coordinates take the
% inverse of the tranformation from mni to viewer space.
ptsProj_cortex = ProjectionBI(ptsProj, vertices);
[~, iP] = nearest_point(vertices, ptsProj_cortex);
if ~labelssurf.isempty(labelssurf)
    ptsProj_cortex_mni = xform_apply(ptsProj_cortex,inv(T_headvol2mc*T_labelssurf2vol));
end

% Display optodes on labeled cortex
hProjectionPts = [];
iFaces = [];
if eventdata == true
    pts = prepPtsStructForViewing(ptsProj_cortex, size(ptsProj_cortex,1), 'probenum','k',[11,22]);
    hProjectionPts = viewPts(pts, attractPt,  0);
    set(hProjectionPts,'visible','off');
    
    % Generate rays from optodes on head to optodes on cortex and
    % highlight the faces on the label that they pass through.
    faceVertexCData = get(hLabelsSurf,'faceVertexCData');
    faceVertexAlphaData = get(hLabelsSurf,'faceVertexAlphaData');
    iFaces = [];
    for ii=1:size(ptsProj,1)
        p1 = ptsProj(ii,:);
        p2 = ptsProj_cortex(ii,:);
        hProjectionRays(ii) = drawRayProjection(p1, p2, headsurf);
        v=p1-p2;
        [t,~,~,iFace] = raytrace(p1,v, mesh.vertices, mesh.faces);
        
        % Find closest face
        [~,iFaceMin] = min(abs(t(iFace)));
        faceVertexCData(iFace(iFaceMin),:) = repmat([1 0 0],length(iFace(iFaceMin)),1);
        set(hLabelsSurf,'FaceVertexCData',faceVertexCData);
        faceVertexAlphaData(iFace(iFaceMin)) = ones(length(iFace(iFaceMin)),1);
        set(hLabelsSurf,'FaceVertexAlphaData',faceVertexAlphaData);
        iFaces = [iFaces iFace(iFaceMin)];
    end
    if all(ishandles(hProjectionRays))
        set(hProjectionRays,'color','k');
    else
        return;
    end

    % Create table associating projected cortex optodes with brain labels
    hProjectionTbl(iTbl) = figure('name',figname,'toolbar','none',...
                                  'menubar','none','numbertitle','off', ...
                                  'units','normalized', 'position',tblPos);
    
    if option==1 || option==3
        optlabelsTbl = repmat({'','',''},length(iP),1);
        columnname = {'opt #','opt coord (Monte Carlo)','opt coord (MNI)','label name'};
        columnwidth = {40,160,120,140};
        for k=1:nopt
            optlabelsTbl{k,1} = num2str(k);
            optlabelsTbl{k,2} = num2str(round(ptsProj_cortex(k,:)));
            optlabelsTbl{k,3} = num2str(round(ptsProj_cortex_mni(k,:)));
            j = find(mesh.faces(:,1)==iP(k) | mesh.faces(:,2)==iP(k) | mesh.faces(:,3)==iP(k));
            optlabelsTbl{k,4} = namesL{idxL(j(1))};
            faceVertexCData(j,:) = repmat([1 0 0],length(j),1);
        end
    else
        optlabelsTbl = repmat({'','','',''},length(iP),1);
        columnname = {'src','det','ch coord (Monte Carlo) ','ch coord (MNI)','label name'};
        columnwidth = {30,30,160,120,140};
        for k=1:size(ptsProj,1)
            optlabelsTbl{k,1} = num2str(ml(k,1));
            optlabelsTbl{k,2} = num2str(ml(k,2));
            optlabelsTbl{k,3} = num2str(round(ptsProj_cortex(k,:)));
            optlabelsTbl{k,4} = num2str(round(ptsProj_cortex_mni(k,:)));
            j = find(mesh.faces(:,1)==iP(k) | mesh.faces(:,2)==iP(k) | mesh.faces(:,3)==iP(k));
            optlabelsTbl{k,5} = namesL{idxL(j(1))};
            faceVertexCData(j,:) = repmat([1 0 0],length(j),1);
        end
    end
    uitable('parent',hProjectionTbl(iTbl),'columnname',columnname,...
        'units','normalized','position',[.10 .10 .80 .80],'columnwidth',columnwidth,...
        'data',optlabelsTbl);
             
    uicontrol('parent',hProjectionTbl(iTbl),'style','pushbutton','string','EXIT',...
        'units','normalized','position',[.40 .02 .08 .04],'callback',@closeProjectionTbl);
end

% Save outputs
probe.handles.hProjectionPts = hProjectionPts;
probe.handles.hProjectionTbl = hProjectionTbl;
probe.handles.hProjectionRays = hProjectionRays;
probe.ptsProj_cortex = ptsProj_cortex;
probe.ptsProj_cortex_mni = ptsProj_cortex_mni;

atlasViewer.probe = probe;
atlasViewer.labelssurf.iFaces = iFaces;




% --------------------------------------------------------------------
function menuItemProjectRefptsToCortex_Callback(~, ~, ~)
global atlasViewer

dirnameSubj = atlasViewer.dirnameSubj;
dirnameAtlas = atlasViewer.dirnameAtlas;
T_vol2mc = atlasViewer.headvol.T_2mc;

d = dir([dirnameSubj '/*']);

% Search for subject folders under the current subject. 
kk=1;
iDirs=[];
for ii=1:length(d)
    if ~d(ii).isdir
        continue;
    end
    if ~exist([d(ii).name, '/anatomical'], 'dir')
        continue;
    end
    if strcmp(d(ii).name, '..')
        continue;
    end
    iDirs(kk) = ii;
    kk=kk+1;
end

if ~isempty(iDirs)
    q = menu('There are subject folders under the current subject. Do you want to process the group or only the current subject?', 'Group','Current Subject','Cancel');
    if q==1
        
        for ii=iDirs
            % Reload subject with it's own anatomical files
            AtlasViewerGUI([dirnameSubj, d(ii).name], dirnameAtlas, 'userargs');
            
            fprintf('Projecting ref points to cortex for subject: %s\n', d(ii).name);
            pause(2);
            refpts = menuItemProjectRefptsToCortex();
            refpts = saveRefpts(refpts, T_vol2mc);
        end
        
    elseif q==2
       
        menuItemProjectRefptsToCortex();
        
    end
end



% --------------------------------------------------------------------
function refpts = menuItemProjectRefptsToCortex()
global atlasViewer

% Assign main objects
refpts           = atlasViewer.refpts;
headvol          = atlasViewer.headvol;
headsurf         = atlasViewer.headsurf;
pialsurf         = atlasViewer.pialsurf;

% Assign variables from the main objects
hProjectionRays              = refpts.handles.hProjectionRays;
attractPt          = headvol.center;

if isempty(pialsurf.mesh.vertices)
    return;
end
if isempty(refpts.pos)
    return;
end

vertices = pialsurf.mesh.vertices;
ptsProj = refpts.pos;

% ptsProj_cortex is in viewer space. To get back to MNI coordinates take the
% inverse of the tranformation from mni to viewer space.
ptsProj_cortex = ProjectionBI(ptsProj, vertices);
[~, iP] = nearest_point(vertices, ptsProj_cortex);

% Display optodes on labeled cortex
pts = prepPtsStructForViewing(ptsProj_cortex, size(ptsProj_cortex,1), 'probenum','k',[11,22]);
hCortexProjection = viewPts(pts, attractPt,  0);
set(hCortexProjection,'visible','off');

% Generate rays from optodes on head to optodes on cortex and
% highlight the faces on the label that they pass through.
faceVertexCData = get(pialsurf.handles.surf,'faceVertexCData');
faceVertexAlphaData = get(pialsurf.handles.surf,'faceVertexAlphaData');
iFaces = [];
for ii=1:size(ptsProj,1)
    p1 = ptsProj(ii,:);
    p2 = ptsProj_cortex(ii,:);
    hProjectionRays(ii) = drawRayProjection(p1, p2, headsurf);
    v=p1-p2;
    [t,~,~,iFace] = raytrace(p1,v, pialsurf.mesh.vertices, pialsurf.mesh.faces);
    
    % Find closest face
    [~,iFaceMin] = min(abs(t(iFace)));
    faceVertexCData(iFace(iFaceMin),:) = repmat([1 0 0],length(iFace(iFaceMin)),1);
    set(pialsurf.handles.surf,'FaceVertexCData',faceVertexCData);
    iFaces = [iFaces, iFace(iFaceMin)];
end
if all(ishandles(hProjectionRays))
    set(hProjectionRays,'color','k');
else
    return;
end

% Save outputs
refpts.handles.hCortexProjection = hCortexProjection;
refpts.handles.hProjectionRays = hProjectionRays;
refpts.cortexProjection.vertices = ptsProj_cortex;
refpts.cortexProjection.iFaces = iFaces;
refpts.cortexProjection.iVertices = iP;
refpts.cortexProjection.pos = pialsurf.mesh.vertices(iP,:);

atlasViewer.refpts = refpts;



% --------------------------------------------------------------------
function menuItemGetSensitivityatMNICoordinates_Callback(~, ~, handles)
global atlasViewer

% get user input
prompt={'MNI Coordinates (x, y, z) one or more separated by semicolumns ','radius (mm)','absorption change (mm-1)'};
name='Get brain activation sensitivity at MNI coordinates';
numlines=1;
defaultanswer={'[0 0 0; 0 0 0]','3','0.001'};

answer=inputdlg(prompt,name,numlines,defaultanswer,'on');

if isempty(answer)
    return
end

coordinate_mni = str2num(answer{1});
radius = str2num(answer{2});
absorption_change = str2num(answer{3});

no_mni = size(coordinate_mni,1);

% Load the sensitivity volume
if  exist([atlasViewer.dirnameSubj  'fw' filesep 'AdotVolSum.3pt'],'file')
    cd([atlasViewer.dirnameSubj '/fw'])
    fid = fopen('AdotVolSum.3pt','rb');
    v = single(fread(fid, 'float32'));
    cd(atlasViewer.dirnameSubj);
else
    msg = sprintf('You need to first generate a sensitivity profile with sensitivity matrix volume option enabled.');
    menu(msg,'OK');
    return;
end

% get the dimensions of the volume
dims = ones(1,4);
dims(1) = size(atlasViewer.headvol.img,1);
dims(2) = size(atlasViewer.headvol.img,2);
dims(3) = size(atlasViewer.headvol.img,3);

% reshape to get volume in 3D
f = reshape(v, dims);

% go from Monte Carlo space to MNI space
T_headvol2mc         = atlasViewer.headvol.T_2mc; % colin to Monte Carlo space
T_labelssurf2vol = atlasViewer.labelssurf.T_2vol; % mni to colin

h = waitbar(0,'Please wait while loading volume and calculating...');

% loop around MNI coordinates to get dOD change for each.
for i = 1: no_mni
    
    coordinate_MC(i,:) = xform_apply(coordinate_mni(i,:), (T_headvol2mc*T_labelssurf2vol));
    
    % generate a sphere with MNI at the center
    vol = gen_blob([radius radius radius],coordinate_MC(i,:),ones(size(f)),0);
    
    % sum the sensitivity within the sphere (this sensitivity is the sum of
    % all optode sensitivities.)
    blob_ind = find(vol>1);
    sum_sensitivity = sum(f(blob_ind));
    vox_vol = 1; %mm^3   Talk to Jay to get the vox vol from the data structure as it is not necessarily 1 mm^3
    
    % estimate optical density change
    deltaMa = absorption_change * vox_vol;
    dOD_blob(i) = sum_sensitivity * deltaMa;
    
    clear vol blob_ind sum_sensitivity;
    waitbar(i/no_mni);
    
end
close(h);% close waitbar
% Save here for later plotting the projection on Atlas
atlasViewer.fwmodel.MNI = coordinate_mni;
atlasViewer.fwmodel.MNI_inMCspace = coordinate_MC;


% Create a table associating projected cortex optodes with brain labels
figname = 'Integrated Sensitivity of a Sphere with MNI Coordinates at the Center';
MNI_2_sensitivity_Table = figure('name',figname,'toolbar','none',...
    'menubar','none','numbertitle','off', ...
    'units','normalized', 'position',[.4 .1 .2 .4]);

cnames = {'x','y','z','radius', 'deltaMa', 'dOD'};
rnames = {'1','2','3'};
columnwidth = {40, 40, 40, 40, 80, 80};
columnformat = {'char','char','char','char','char','char'}; % to allign the entries to left

d = zeros(no_mni,6);
d(1:no_mni,1:3) = coordinate_mni;
d(1:no_mni,4) = radius;
d(1:no_mni,5) = deltaMa;
d(1:no_mni,6) = dOD_blob;

t = uitable(MNI_2_sensitivity_Table ,'Data',d,...
    'ColumnName',cnames,...
    'RowName',rnames,'position',[5 1.5 335 400],'columnwidth',columnwidth,'ColumnFormat', columnformat);
%[left bottom width height]

% Enable display_mni_projection
set(handles.checkbox_Display_MNI_Projection, 'enable','on');
set(handles.checkbox_Display_MNI_Projection, 'value',0);



% --------------------------------------------------------------------
function checkbox_Display_MNI_Projection_Callback(hObject, eventdata, handles)
global atlasViewer

fwmodel    = atlasViewer.fwmodel;
headvol    = atlasViewer.headvol; 
labelssurf = atlasViewer.labelssurf; 
headvol    = atlasViewer.headvol; 
headsurf   = atlasViewer.headsurf;
 
if get(hObject,'value')==1 % if checkbox is checked
    
    prompt={'MNI Coordinates (x, y, z) one or more separated by semicolumns'};
    name='Input MNI Coordinate(s)';
    numlines=1;
    
    % if user already ran brain activation MNI to get the sensitivy
    % have those MNIs as default
    if ~isfield(atlasViewer.fwmodel,'MNI') == 0
        coordinate_mni = atlasViewer.fwmodel.MNI;
        no_mni = size(coordinate_mni,1);
        foo = num2str(coordinate_mni);
        fooi = sprintf(foo(1,:));
        if no_mni == 1
            defaultanswer = {[fooi]};
        else
            for i = 2:no_mni
                foon = ['; ' sprintf(foo(i,:))];
                defaultanswer = {[fooi foon]};
                fooi = [fooi foon];
            end %defaultanswer = {[sprintf(foo(1,:)) ';' sprintf(foo(2,:))]}
        end
    else
        defaultanswer={'[0 0 0; 0 0 0]'};
    end
    answer=inputdlg(prompt,name,numlines,defaultanswer,'on');
    if isempty(answer)
        return
    end
    coordinate_mni = str2num(answer{1});
    no_mni = size(coordinate_mni,1);
    
    % get coordinate in MC space
    T_headvol2mc     = atlasViewer.headvol.T_2mc; % colin to Monte Carlo space
    T_labelssurf2vol = atlasViewer.labelssurf.T_2vol; % mni to colin
    for i = 1: no_mni
        coordinate_MC(i,:) = xform_apply(coordinate_mni(i,:), (T_headvol2mc*T_labelssurf2vol));
    end
    
    % PLOT
    % clean if there is rays or dots left corresponding to previous points
    h = findobj('type','line','tag','MNI projection','color','m');
    set(h,'Visible','off');
    h2 = findobj('Marker','o');
    set(h2,'Visible','off');
    
    headvol   = atlasViewer.headvol;
    vertices  = atlasViewer.labelssurf.mesh.vertices;
    
    % Project MNI in MC space to head surface and pial surface
    for i = 1:no_mni
        
        coordinate_MC_headsurf = ProjectionBI(coordinate_MC(i,:), atlasViewer.headsurf.mesh.vertices);
        coordinate_MC_cortex = ProjectionBI(coordinate_MC_headsurf, vertices);
        
        % Generate rays from cortex to head surface
        
        p1 = coordinate_MC_headsurf;
        p2 = coordinate_MC_cortex;
        hProjectionRays = drawRayProjection(p1,p2,headsurf);
        hold on;
        plot3(coordinate_MC_cortex(2),coordinate_MC_cortex(1),coordinate_MC_cortex(3),'bo','MarkerSize',15,'MarkerFaceColor','b');
        hold off;
    end
    
else % cleans ray(s) and blue spheres from the display.
    
    h1 = findobj('MarkerFaceColor','b','MarkerSize',15); %
    h2 = findobj('type','line','tag','MNI projection');
    set(h1,'Visible','off')
    set(h2,'Visible','off')
    
end



% --------------------------------------------------------------------
function menuItemSetMCApp_Callback(~, ~, ~)
global atlasViewer
fwmodel = atlasViewer.fwmodel;

% Last resort: If none of the above locate MC app then ask user where it is. 
while 1
    pause(.1)
    [filenm, pathnm] = uigetfile({'*'; '*.exe'}, ['Monte Carlo executable not found. Please select Monte Carlo executable.']);
    if filenm==0
        return;
    end
    
    % Do a few basic error checks
    if istextfile(filenm)
        q = menu('Selected file not an executable. Try again', 'OK', 'Cancel');
        if q==2
            return;
        else
            continue;
        end
    end    
    break;
end
[mc_exename, mc_appname, ext] = searchDirForMCApp(pathnm);
if ~isempty(mc_exename)
    fwmodel.mc_rootpath = pathnm;
    fwmodel.mc_exepath = pathnm;
    fwmodel.mc_exename = mc_exename;
    fwmodel.mc_appname = mc_appname;
    fwmodel.mc_exename_ext = ext;
end

% Set MC options based on app type
fwmodel = setMCoptions(fwmodel);

atlasViewer.fwmodel = fwmodel;



% --------------------------------------------------------------------
function menuItemSaveAnatomy_Callback(~, ~, ~)
global atlasViewer

headvol      = atlasViewer.headvol;
headsurf     = atlasViewer.headsurf;
pialsurf     = atlasViewer.pialsurf;
labelssurf   = atlasViewer.labelssurf;
refpts       = atlasViewer.refpts;
dirnameSubj  = atlasViewer.dirnameSubj;

saveHeadvol(headvol);
saveHeadsurf(headsurf, headvol.T_2mc);
savePialsurf(pialsurf, headvol.T_2mc);
saveLabelssurf(labelssurf, headvol.T_2mc);
saveRefpts(refpts, headvol.T_2mc);



% --------------------------------------------------------------------
function menuItemLoadPrecalculatedProfile_Callback(hObject, eventdata, handles)
global atlasViewer

fwmodel = atlasViewer.fwmodel;
headvol = atlasViewer.headvol;
pialsurf = atlasViewer.pialsurf;
probe = atlasViewer.probe;
T_vol2mc = headvol.T_2mc;

dirnameSubj = atlasViewer.dirnameSubj;

% Since we're generating new fluence for what is in effect a probe covering
% the whole head, the sensitivity from that should be regenerated. 
fwmodel.Adot = [];
fwmodel = genSensitivityProfileFromFluenceProf(fwmodel, probe, T_vol2mc, dirnameSubj);

atlasViewer.fwmodel = fwmodel;
menuItemGenerateLoadSensitivityProfile_Callback([], struct('EventName','profile'), handles);




% --------------------------------------------------------------------
function popupmenuImageDisplay_Callback(hObject, eventdata, handles)
global atlasViewer

fwmodel  = atlasViewer.fwmodel;
imgrecon = atlasViewer.imgrecon;
hbconc = atlasViewer.hbconc;
pialsurf = atlasViewer.pialsurf;
axesv    = atlasViewer.axesv;

val = get(hObject,'value');

Ch = str2num(get(hbconc.handles.editSelectChannel, 'string'));
fwmodel.Ch = Ch;
hbconc.Ch = Ch;

% Set colormap threshold and channel edit boxes 
switch(val)
    case fwmodel.menuoffset+1
        set(handles.editColormapThreshold,'string',sprintf('%0.2g %0.2g',fwmodel.cmThreshold(1),fwmodel.cmThreshold(2)));
    case {imgrecon.menuoffset+1, imgrecon.menuoffset+2, imgrecon.menuoffset+3, imgrecon.menuoffset+4}
        set(handles.editColormapThreshold,'string',sprintf('%0.2g %0.2g',imgrecon.cmThreshold(val-imgrecon.menuoffset, 1), ...
                                                               imgrecon.cmThreshold(val-imgrecon.menuoffset, 2)));                                                          
    case {hbconc.menuoffset+1, hbconc.menuoffset+2}
        set(handles.editColormapThreshold,'string',sprintf('%0.2g %0.2g',hbconc.cmThreshold(val-hbconc.menuoffset, 1), ...
                                                               hbconc.cmThreshold(val-hbconc.menuoffset, 2)));                                                          
    otherwise
        return;
end

% Display image in main axes
switch(val)
    case fwmodel.menuoffset+1
        fwmodel = showFwmodelDisplay(fwmodel, axesv(1).handles.axesSurfDisplay, 'on');

        imgrecon = showImgReconDisplay(imgrecon, axesv(1).handles.axesSurfDisplay, 'off', 'off', 'off', 'off');
        hbconc = showHbConcDisplay(hbconc, axesv(1).handles.axesSurfDisplay, 'off', 'off');
    case imgrecon.menuoffset+1
        imgrecon = showImgReconDisplay(imgrecon, axesv(1).handles.axesSurfDisplay, 'on', 'off', 'off', 'off');

        fwmodel = showFwmodelDisplay(fwmodel, axesv(1).handles.axesSurfDisplay, 'off');
        hbconc = showHbConcDisplay(hbconc, axesv(1).handles.axesSurfDisplay, 'off', 'off');
    case imgrecon.menuoffset+2
        imgrecon = showImgReconDisplay(imgrecon, axesv(1).handles.axesSurfDisplay, 'off', 'on', 'off', 'off');

        fwmodel = showFwmodelDisplay(fwmodel, axesv(1).handles.axesSurfDisplay, 'off');
        hbconc = showHbConcDisplay(hbconc, axesv(1).handles.axesSurfDisplay, 'off', 'off');
    case imgrecon.menuoffset+3
        imgrecon = showImgReconDisplay(imgrecon, axesv(1).handles.axesSurfDisplay, 'off', 'off', 'on', 'off');

        fwmodel = showFwmodelDisplay(fwmodel, axesv(1).handles.axesSurfDisplay, 'off');
        hbconc = showHbConcDisplay(hbconc, axesv(1).handles.axesSurfDisplay, 'off', 'off');
    case imgrecon.menuoffset+4
        imgrecon = showImgReconDisplay(imgrecon, axesv(1).handles.axesSurfDisplay, 'off', 'off', 'off', 'on');

        fwmodel = showFwmodelDisplay(fwmodel, axesv(1).handles.axesSurfDisplay, 'off');
        hbconc = showHbConcDisplay(hbconc, axesv(1).handles.axesSurfDisplay, 'off', 'off');
    case hbconc.menuoffset+1
        hbconc = showHbConcDisplay(hbconc, axesv(1).handles.axesSurfDisplay, 'on', 'off');

        fwmodel = showFwmodelDisplay(fwmodel, axesv(1).handles.axesSurfDisplay, 'off');
        imgrecon = showImgReconDisplay(imgrecon, axesv(1).handles.axesSurfDisplay, 'off', 'off', 'off', 'off');
    case hbconc.menuoffset+2
        hbconc = showHbConcDisplay(hbconc, axesv(1).handles.axesSurfDisplay, 'off', 'on');

        fwmodel = showFwmodelDisplay(fwmodel, axesv(1).handles.axesSurfDisplay, 'off');
        imgrecon = showImgReconDisplay(imgrecon, axesv(1).handles.axesSurfDisplay, 'off', 'off', 'off', 'off');
end

set(pialsurf.handles.radiobuttonShowPial, 'value',0);
uipanelBrainDisplay_Callback(pialsurf.handles.radiobuttonShowPial, [], handles);




% --------------------------------------------------------------------
function popupmenuImageDisplay_CreateFcn(hObject, eventdata, handles)
global popupmenuorder;

popupmenuorder = struct(...
    'HbOConc',          struct('idx',1,'label','HbO Conc'), ...
    'HbRConc',          struct('idx',2,'label','HbR Conc'), ...
    'Sensitivity',      struct('idx',3,'label','Sensitivity'), ...
    'LocalizationError',struct('idx',4,'label','Localization Error'), ...
    'Resolution',       struct('idx',5,'label','Resolution'), ...
    'HbORecon',         struct('idx',6,'label','HbO Recon'), ...
    'HbRRecon',         struct('idx',7,'label','HbR Recon'), ...
    'None',             struct('idx',8,'label','None') ...
);

set(hObject, 'string',{...
    popupmenuorder.HbOConc.label, ...
    popupmenuorder.HbRConc.label, ...
    popupmenuorder.Sensitivity.label, ...
    popupmenuorder.LocalizationError.label, ...
    popupmenuorder.Resolution.label, ...
    popupmenuorder.HbORecon.label, ...
    popupmenuorder.HbRRecon.label, ...
    popupmenuorder.None.label ...
});

set(hObject, 'value',1);




% --------------------------------------------------------------------
function editSelectChannel_Callback(hObject, eventdata, handles)
global atlasViewer

fwmodel      = atlasViewer.fwmodel;
imgrecon     = atlasViewer.imgrecon;
hbconc     = atlasViewer.hbconc;
probe        = atlasViewer.probe;
mesh         = atlasViewer.pialsurf.mesh;
headsurf     = atlasViewer.headsurf;
pialsurf     = atlasViewer.pialsurf;
axesv        = atlasViewer.axesv; 

ChStr = get(hObject,'string');
if isempty(ChStr)
    set(hObject,'string', '0 0');
    return;
end
if ~isnumber(ChStr)
    set(hObject,'string', '0 0');
    return;
end
Ch = str2num(ChStr);
if length(Ch)~=2
    set(hObject,'string','0 0');
    return;
end
if isempty(find( (probe.ml(:,1)==Ch(1)) & (probe.ml(:,2)==Ch(2))))
    if ~all(Ch==0)
        set(hObject,'string','0 0');
        return;
    end
end
    
val = get(handles.popupmenuImageDisplay,'value');
switch(val)
    case fwmodel.menuoffset+1
        fwmodel.Ch = Ch;
        set(handles.editColormapThreshold, ...
            'string',sprintf('%0.2g %0.2g', fwmodel.cmThreshold(1), fwmodel.cmThreshold(1)));        
        fwmodel = displaySensitivity(fwmodel,pialsurf,[],probe);        
    case {imgrecon.menuoffset+1, imgrecon.menuoffset+2, imgrecon.menuoffset+3, imgrecon.menuoffset+4}
        % ImgRecon has no channels (??) 
        set(hObject,'string',sprintf('0 0'));         
    case {hbconc.menuoffset+1, hbconc.menuoffset+2}
        hbconc.Ch = Ch;
        hbconc = calcHbConc(hbconc, probe);
        hbconc = calcHbConcCmThreshold(hbconc);
        set(handles.editColormapThreshold, ...
            'string',sprintf('%0.2g %0.2g', hbconc.cmThreshold(val-hbconc.menuoffset,1), hbconc.cmThreshold(val-hbconc.menuoffset,2)));
        hbconc = displayHbConc(hbconc, pialsurf, probe, fwmodel, imgrecon);
    otherwise
        return;
end

atlasViewer.fwmodel = fwmodel;
atlasViewer.imgrecon = imgrecon;
atlasViewer.hbconc = hbconc;
atlasViewer.probe = probe;





% --------------------------------------------------------------------
function editColormapThreshold_Callback(hObject, eventdata, handles)
global atlasViewer

fwmodel = atlasViewer.fwmodel;
imgrecon = atlasViewer.imgrecon;
hbconc = atlasViewer.hbconc;
axesv = atlasViewer.axesv; 
probe = atlasViewer.probe; 

val = str2num(get(hObject, 'string'));
if length(val)>1
    set(hObject,'string',sprintf('%0.2g %0.2g',val(1), val(2)));
end

val = get(handles.popupmenuImageDisplay,'value');
switch(val)
    case fwmodel.menuoffset+1
        fwmodel = setSensitivityColormap(fwmodel, axesv(1).handles.axesSurfDisplay);
    case {imgrecon.menuoffset+1, imgrecon.menuoffset+2, imgrecon.menuoffset+3, imgrecon.menuoffset+4}
        imgrecon = setImgReconColormap(imgrecon, axesv(1).handles.axesSurfDisplay);
    case {hbconc.menuoffset+1, hbconc.menuoffset+2}
        hbconc = setHbConcColormap(hbconc, axesv(1).handles.axesSurfDisplay);
end
atlasViewer.fwmodel = fwmodel;
atlasViewer.imgrecon = imgrecon;
atlasViewer.hbconc = hbconc;



% --------------------------------------------------------------------
function pushbuttonOpticalPropertiesSet_new_Callback(hObject, eventdata, handles)
global atlasViewer;
headvol = atlasViewer.headvol;
fwmodel = atlasViewer.fwmodel;

% Set tissue properties
name='Input Head Optical Properties';
numlines=1;
if ~fwmodel.headvol.isempty(fwmodel.headvol)
    tiss_prop = fwmodel.headvol.tiss_prop;
else
    tiss_prop = headvol.tiss_prop;
end

prompt = {};
defaultanswer = {};
outstr = {};
for ii=1:length(tiss_prop)
    switch lower(tiss_prop(ii).name)
        case {'skin', 'scalp'}
            prompt{end+1} = 'Scalp Scattering (1/mm)';
            prompt{end+1} = 'Scalp Absroption (1/mm)';
            outstr{end+1} = 'Scalp:';
        case {'skull', 'bone'}
            prompt{end+1} = 'Skull Scattering (1/mm)';
            prompt{end+1} = 'Skull Absroption (1/mm)';
            outstr{end+1} = 'Skull:';
        case {'dm' , 'dura mater'}
            prompt{end+1} = 'Dura Scattering (1/mm)';
            prompt{end+1} = 'Dura Absroption (1/mm)';
            outstr{end+1} = 'Dura:';
        case {'csf', 'cerebral spinal fluid'}
            prompt{end+1} = 'CSF Scattering (1/mm)';
            prompt{end+1} = 'CSF Absroption (1/mm)';
            outstr{end+1} = 'CSF:';
        case {'gm', 'gray matter'}
            prompt{end+1} = 'Gray Scattering (1/mm)';
            prompt{end+1} = 'Gray Absroption (1/mm)';
            outstr{end+1} = 'Gray:';
        case {'wm', 'white matter'}
            prompt{end+1} = 'White Scattering (1/mm)';
            prompt{end+1} = 'White Absroption (1/mm)';
            outstr{end+1} = 'White:';
        case 'other'
            prompt{end+1} = 'Other Scattering (1/mm)';
            prompt{end+1} = 'Other Absroption (1/mm)';
            outstr{end+1} = 'Other:';
        otherwise
            prompt{end+1} = 'Huh Scattering (1/mm)';
            prompt{end+1} = 'Huh Absroption (1/mm)';
            outstr{end+1} = 'Huh:';
    end
       
    defaultanswer{end+1} = num2str(tiss_prop(ii).scattering);
    defaultanswer{end+1} = num2str(tiss_prop(ii).absorption);
end

answer = inputdlg(prompt,name,numlines,defaultanswer,'on');

if ~isempty(answer)
    jj = 0;
    nw = [];
    foos = [];
    for ii=1:length(tiss_prop)
        jj=jj+1;
        foo = str2num(answer{jj});
        nw(ii,1) = length(foo);
        tiss_prop(ii).scattering = foo;
        outstr{ii} = [outstr{ii} ' ' answer{jj}];
        
        jj=jj+1;
        foo = str2num(answer{jj});
        nw(ii,2) = length(foo);
        tiss_prop(ii).absorption = foo;
        outstr{ii} = [outstr{ii} '; ' answer{jj}];
        
        foos = sprintf('%s%s\n',foos,outstr{ii});
    end
    if length(unique(nw))>1
        errordlg('You must enter the same number of wavelengths for each property')
        return;
    end
    
    %set(handles.textOpticalProperties,'string',foos);
    
    headvol.tiss_prop = tiss_prop;
    fwmodel.headvol.tiss_prop = tiss_prop;
    fwmodel.nWavelengths = nw(1);

end

% Set number of photons
answer = inputdlg_errcheck({'Number of photons'},'Number of Photons', 1, {num2str(fwmodel.nphotons)});
if ~isempty(answer)
    fwmodel.nphotons = str2num(answer{1});
end

fwmodel = setMCoptions(fwmodel);

atlasViewer.headvol = headvol;
atlasViewer.fwmodel = fwmodel;




% --------------------------------------------------------------------
function pushbuttonCalcMetrics_new_Callback(hObject, eventdata, handles)
global atlasViewer

imgrecon     = atlasViewer.imgrecon;
hbconc     = atlasViewer.hbconc;
fwmodel 	 = atlasViewer.fwmodel;
pialsurf     = atlasViewer.pialsurf;
probe        = atlasViewer.probe;
dirnameSubj  = atlasViewer.dirnameSubj;
axesv       = atlasViewer.axesv;

% Set image popupmenu to resolution 
set(imgrecon.handles.popupmenuImageDisplay,'value',imgrecon.menuoffset+1);
set(handles.editColormapThreshold,'string',sprintf('%0.2g %0.2g',imgrecon.cmThreshold(imgrecon.menuoffset+1,1), ...
                                                                 imgrecon.cmThreshold(imgrecon.menuoffset+1,2)));
imgrecon = genImgReconMetrics(imgrecon, fwmodel, dirnameSubj);

% Turn off image recon display
fwmodel = showFwmodelDisplay(fwmodel, axesv(1).handles.axesSurfDisplay, 'off');
hbconc = showHbConcDisplay(hbconc, axesv(1).handles.axesSurfDisplay, 'off', 'off');

imgrecon = displayImgRecon(imgrecon, fwmodel, pialsurf, [], probe);

atlasViewer.imgrecon = imgrecon;



% --------------------------------------------------------------------
function menuItemImageReconGUI_Callback(hObject, eventdata, handles)
global atlasViewer

ImageRecon();




% --------------------------------------------------------------------
function radiobuttonShowRefpts_Callback(hObject, eventdata, handles)

radiobuttonShowRefpts(hObject, eventdata, handles)



% --------------------------------------------------------------
function uipanelBrainDisplay_Callback(hObject, eventdata, handles)

uipanelBrainDisplay(hObject, eventdata, handles);



% --------------------------------------------------------------------
function menuItemOverlayHbConc_Callback(~, ~, ~)
global atlasViewer

hbconc    = atlasViewer.hbconc;
imgrecon  = atlasViewer.imgrecon;
fwmodel   = atlasViewer.fwmodel;
pialsurf  = atlasViewer.pialsurf;
dataTree  = atlasViewer.dataTree;

hbconc = loadDataHbConc(hbconc, dataTree);

if isempty(hbconc.HbConcRaw)
    MessageBox('No HRF data to display for the current folder. Use Homer3 to generate HRF output for the current folder.');
    return;
end

hbconc = inputParamsHbConc(hbconc);
if isempty(hbconc)
    return;
end

% Project channels to cortex and save projecttion points in probe
probe = menuItemProjectProbeToCortex_Callback([], false);
if isempty(probe.ptsProj_cortex)
    return;
end

if get(hbconc.handles.popupmenuImageDisplay, 'value') < hbconc.menuoffset || ...
     get(hbconc.handles.popupmenuImageDisplay, 'value') > hbconc.menuoffset+2
    set(hbconc.handles.popupmenuImageDisplay,'value', hbconc.menuoffset+1);    
end

% Calculate Hb concentration interpolation function and display
hbconc = calcHbConc(hbconc, probe);
hbconc = calcHbConcCmThreshold(hbconc);
set(hbconc.handles.editColormapThreshold, 'string', sprintf('%0.2g %0.2g',hbconc.cmThreshold(1,1), ...
                                                                          hbconc.cmThreshold(1,2)));
                                                             
% Turn off the other object displays that share the Image Display panel
fwmodel = showFwmodelDisplay(fwmodel, [], 'off');
imgrecon = showImgReconDisplay(imgrecon, [], 'off','off','off','off');
hbconc = displayHbConc(hbconc, pialsurf, probe, fwmodel, imgrecon);

atlasViewer.hbconc = hbconc;
atlasViewer.probe = probe;




% --------------------------------------------------------------------
function editCondition_Callback(hObject, ~, handles)
global atlasViewer

hbconc = atlasViewer.hbconc;
imgrecon  = atlasViewer.imgrecon;
fwmodel   = atlasViewer.fwmodel;
pialsurf  = atlasViewer.pialsurf;
probe     = atlasViewer.probe;

condstr = get(hObject, 'string');
if isempty(condstr)
    set(hObject, 'string', num2str(hbconc.iCond));
    return;
end
if ~isnumber(condstr)
    set(hObject, 'string', num2str(hbconc.iCond));
    return;
end
cond = str2num(condstr);
if floor(str2num(condstr))~=cond
    set(hObject, 'string', num2str(hbconc.iCond));
    return;
end
if (cond < 1) | (cond > size(hbconc.HbConcRaw,4))
    set(hObject, 'string', num2str(hbconc.iCond));
    return;
end
if hbconc.iCond == cond    
    return;
end
val = get(handles.popupmenuImageDisplay,'value');
if val ~= hbconc.menuoffset+1 & val ~= hbconc.menuoffset+2
    return;
end

hbconc = calcHbConc(hbconc, probe);
hbconc = calcHbConcCmThreshold(hbconc);
set(hbconc.handles.editColormapThreshold, ...
    'string',sprintf('%0.2g %0.2g', hbconc.cmThreshold(1,1), hbconc.cmThreshold(1,2)));
                                                             
% Turn off the other object displays that share the Image Display panel
fwmodel = showFwmodelDisplay(fwmodel, [], 'off');
imgrecon = showImgReconDisplay(imgrecon, [], 'off','off','off','off');

hbconc = displayHbConc(hbconc, pialsurf, probe, fwmodel, imgrecon);

atlasViewer.hbconc = hbconc;




% --------------------------------------------------------------------
function menuItemClearRefptsToCortex_Callback(~, ~, ~)
global atlasViewer

refpts = atlasViewer.refpts;
refpts = clearRefptsProjection(refpts);
atlasViewer.refpts = refpts;



% --------------------------------------------------------------------
function menuItemClearProbeProjection_Callback(~, ~, ~)
global atlasViewer

probe = atlasViewer.probe;
probe = clearProbeProjection(probe);
atlasViewer.probe = probe;



% --------------------------------------------------------------------
function closeProjectionTbl(hObject, eventdata)
global atlasViewer

probe = atlasViewer.probe;
probe = clearProbeProjection(probe);
atlasViewer.probe = probe;



% --------------------------------------------------------------------
function menuItemResetViewerState_Callback(~, ~, ~)

global atlasViewer
dirnameSubj = atlasViewer.dirnameSubj;
dirnameAtlas = atlasViewer.dirnameAtlas;

% Reload subject with it's own, newly-generated anatomical files
AtlasViewerGUI(dirnameSubj, dirnameAtlas, 'userargs');



% --------------------------------------------------------------------
function editViewAnglesAzimuth_Callback(hObject, eventdata, handles)
global atlasViewer

axesv = atlasViewer.axesv;
headsurf = atlasViewer.headsurf;

ax=[];
for ii=1:length(axesv)
    if ishandles(axesv(ii).handles.editViewAnglesAzimuth)
        if hObject==axesv(ii).handles.editViewAnglesAzimuth
            ax=axesv(ii);
            break;
        end
    end
end

% Error checks
if isempty(ax)
    return;
end
if isempty(headsurf.orientation)
    menu(ax.errmsg{1},'OK');
    return;
end

az = str2num(get(hObject, 'string'));
el = str2num(get(handles.editViewAnglesElevation, 'string'));
setViewAngles(ax.handles.axesSurfDisplay, headsurf.orientation, az, el);
updateViewAngles(ii, az, el);




% --------------------------------------------------------------------
function editViewAnglesElevation_Callback(hObject, eventdata, handles)
global atlasViewer

axesv = atlasViewer.axesv;
headsurf = atlasViewer.headsurf;

ax=[];
for ii=1:length(axesv)
    if ishandles(axesv(ii).handles.editViewAnglesElevation)
        if hObject==axesv(ii).handles.editViewAnglesElevation
            ax=axesv(ii);
            break;
        end
    end
end

% Error checks
if isempty(ax)
    return;
end
if isempty(headsurf.orientation)
    menu(ax.errmsg{1},'OK');
    return;
end

el = str2num(get(hObject, 'string'));
az = str2num(get(handles.editViewAnglesAzimuth, 'string'));
setViewAngles(ax.handles.axesSurfDisplay, headsurf.orientation, az, el);
updateViewAngles(ii, az, el);




% --------------------------------------------------------------------
function pushbuttonStandardViewsAnterior_Callback(hObject, eventdata, handles)
global atlasViewer

axesv = atlasViewer.axesv;
headsurf = atlasViewer.headsurf;

ax=[];
for ii=1:length(axesv)
    if ishandles(axesv(ii).handles.pushbuttonStandardViewsAnterior)
        if hObject==axesv(ii).handles.pushbuttonStandardViewsAnterior
            ax=axesv(ii);
            break;            
        end
    end
end

% Error checks
if isempty(ax)
    return;
end
if isempty(headsurf.orientation)
    menu(ax.errmsg{1},'OK');
    return;
end


setViewAngles(ax.handles.axesSurfDisplay, headsurf.orientation, 180, 0);
set(handles.editViewAnglesAzimuth, 'string', sprintf('%0.2f', 180));
set(handles.editViewAnglesElevation, 'string', sprintf('%0.2f', 0));
updateViewAngles(ii, 180, 0);


% --------------------------------------------------------------------
function pushbuttonStandardViewsPosterior_Callback(hObject, eventdata, handles)
global atlasViewer

axesv = atlasViewer.axesv;
headsurf = atlasViewer.headsurf;

ax=[];
for ii=1:length(axesv)
    if ishandles(axesv(ii).handles.pushbuttonStandardViewsPosterior)
        if hObject==axesv(ii).handles.pushbuttonStandardViewsPosterior
            ax=axesv(ii);
            break;
        end
    end
end

% Error checks
if isempty(ax)
    return;
end
if isempty(headsurf.orientation)
    menu(ax.errmsg{1},'OK');
    return;
end

setViewAngles(ax.handles.axesSurfDisplay, headsurf.orientation, 0, 0);
set(handles.editViewAnglesAzimuth, 'string', sprintf('%0.2f', 0));
set(handles.editViewAnglesElevation, 'string', sprintf('%0.2f', 0));
updateViewAngles(ii, 0, 0);




% --------------------------------------------------------------------
function pushbuttonStandardViewsRight_Callback(hObject, eventdata, handles)

global atlasViewer

axesv = atlasViewer.axesv;
headsurf = atlasViewer.headsurf;
o = headsurf.orientation;

ax=[];
for ii=1:length(axesv)
    if ishandles(axesv(ii).handles.pushbuttonStandardViewsRight)
        if hObject==axesv(ii).handles.pushbuttonStandardViewsRight
            ax=axesv(ii);
            break;
        end
    end
end

% Error checks
if isempty(ax)
    return;
end
if isempty(headsurf.orientation)
    menu(ax.errmsg{1},'OK');
    return;
end

setViewAngles(ax.handles.axesSurfDisplay, headsurf.orientation, 90, 0);
set(handles.editViewAnglesAzimuth, 'string', sprintf('%0.2f', 90));
set(handles.editViewAnglesElevation, 'string', sprintf('%0.2f', 0));
updateViewAngles(ii, 90, 0);




% --------------------------------------------------------------------
function pushbuttonStandardViewsLeft_Callback(hObject, eventdata, handles)
global atlasViewer

axesv = atlasViewer.axesv;
headsurf = atlasViewer.headsurf;
o = headsurf.orientation;

ax=[];
for ii=1:length(axesv)
    if ishandles(axesv(ii).handles.pushbuttonStandardViewsLeft)
        if hObject==axesv(ii).handles.pushbuttonStandardViewsLeft
            ax=axesv(ii);
            break;
        end
    end
end

% Error checks
if isempty(ax)
    return;
end
if isempty(headsurf.orientation)
    menu(ax.errmsg{1},'OK');
    return;
end

setViewAngles(ax.handles.axesSurfDisplay, headsurf.orientation, -90, 0);
set(handles.editViewAnglesAzimuth, 'string', sprintf('%0.2f', -90));
set(handles.editViewAnglesElevation, 'string', sprintf('%0.2f', 0));
updateViewAngles(ii, -90, 0);




% --------------------------------------------------------------------
function pushbuttonStandardViewsSuperior_Callback(hObject, eventdata, handles)
global atlasViewer

axesv = atlasViewer.axesv;
headsurf = atlasViewer.headsurf;

ax=[];
for ii=1:length(axesv)
    if ishandles(axesv(ii).handles.pushbuttonStandardViewsSuperior)
        if hObject==axesv(ii).handles.pushbuttonStandardViewsSuperior
            ax=axesv(ii);
            break;
        end
    end
end
if isempty(ax)
    return;
end

if isempty(headsurf.orientation)
    menu(ax.errmsg{1},'OK');
    return;
end

setViewAngles(ax.handles.axesSurfDisplay, headsurf.orientation, 0, 90);
set(handles.editViewAnglesAzimuth, 'string', sprintf('%0.2f', 0));
set(handles.editViewAnglesElevation, 'string', sprintf('%0.2f', 90));
updateViewAngles(ii, 0, 90);



% --------------------------------------------------------------------
function pushbuttonStandardViewsInferior_Callback(hObject, ~, handles)
global atlasViewer

axesv = atlasViewer.axesv;
headsurf = atlasViewer.headsurf;

ax=[];
for ii=1:length(axesv)
    if ishandles(axesv(ii).handles.pushbuttonStandardViewsInferior)
        if hObject==axesv(ii).handles.pushbuttonStandardViewsInferior
            ax=axesv(ii);
            break;
        end
    end
end
if isempty(ax)
    return;
end

if isempty(headsurf.orientation)
    menu(ax.errmsg{1},'OK');
    return;
end

setViewAngles(ax.handles.axesSurfDisplay, headsurf.orientation, 0, -90);
set(handles.editViewAnglesAzimuth, 'string', sprintf('%0.2f', 0));
set(handles.editViewAnglesElevation, 'string', sprintf('%0.2f', -90));
updateViewAngles(ii, 0, -90);




% --------------------------------------------------------------------
function menuItemCalcRefpts_Callback(~, ~, ~)
global atlasViewer

refpts  = atlasViewer.refpts;
headvol = atlasViewer.headvol;
headsurf = atlasViewer.headsurf;

err = 0;
if isfield(atlasViewer,'headsurf')
    [refpts, err]  = calcRefpts(refpts, headvol);
    if err==-1
        [refpts, err]  = calcRefpts(refpts, headsurf);
        if err==-1
            msg{1} = sprintf('The head surface and/or volume of this subject does not have enough vertices to\n');
            msg{2} = sprintf('calculate the eeg reference points. Need a denser surface mesh for this subject...');
            menu([msg{:}],'OK');
            return;
        end
    end
end

saveRefpts(refpts, headvol.T_2mc, 'overwrite');
if ~err
    refpts = displayRefpts(refpts);
    atlasViewer.refpts = refpts;
end



% --------------------------------------------------------------------
function menuItemConfigureRefpts_Callback(~, ~, ~)

RefptsSystemConfigGUI();



% --------------------------------------------------------------------
function radiobuttonHeadDimensions_Callback(hObject, eventdata, handles)

global atlasViewer

refpts = atlasViewer.refpts;

if get(hObject,'value')==1
    valstr = 'on';
    refpts = calcRefptsCircumf(refpts);
else
    valstr = 'off';
end

set(refpts.handles.uipanelHeadDimensions, 'visible',valstr);



% --------------------------------------------------------------------
function menuItemInstallAtlas_Callback(~, ~, ~)

% Find default folder where AV searches for atlases
dirnameDst = filesepStandard(fileparts(fileparts(getAtlasDir())));
dirnameAtlasNew = filesepStandard(selectAtlasDir());
if isempty(dirnameAtlasNew)
    return;
end
[~, pname] = fileparts(dirnameAtlasNew(1:end-1));
h = waitbar(0,'Installing new atlas, please wait...');
if exist([dirnameDst, pname], 'dir') == 7
    fprintf('%s is already installed ... moving %s to %s_old\n', pname, pname, pname);
    copyfile([dirnameDst, pname], [dirnameDst, pname, '_old']); 
end
copyfile(dirnameAtlasNew, [dirnameDst, pname]);
waitbar(1, h, 'Installion completed.');
pause(2);
close(h);




% -------------------------------------------------------------------------------
function togglebuttonMinimizeGUI_Callback(hObject, ~, handles)
u0 = get(handles.AtlasViewerGUI, 'units');

k = [1.0, 1.0, 0.8, 0.8];
set(handles.AtlasViewerGUI, 'units','characters');
p1_0 = get(handles.AtlasViewerGUI, 'position');
if strcmp(get(hObject, 'string'), '--')
    set(hObject, 'tooltipstring', 'Maximize GUI Window')
    set(hObject, 'string', '+');
    p1 = k.*p1_0;

    % Shift position closer to screen edge since GUI got smaller
	p1(1) = p1(1) + abs(p1_0(3)-p1(3));
	p1(2) = p1(2) + abs(p1_0(4)-p1(4));
elseif strcmp(get(hObject, 'string'), '+')
    set(hObject, 'tooltipstring', 'Minimize GUI Window')
    set(hObject, 'string', '--');
    p1 = p1_0./k;

    % Shift position away from screen edge since GUI got bigger
	p1(1) = p1(1) - abs(p1_0(3)-p1(3));
	p1(2) = p1(2) - abs(p1_0(4)-p1(4));
end
pause(.2)
set(handles.AtlasViewerGUI, 'position', p1);
rePositionGuiWithinScreen(handles.AtlasViewerGUI);

set(handles.AtlasViewerGUI, 'units',u0);
positionDataTreeGUI(handles);




% --------------------------------------------------------------------
function menuItemRunMCXlab_Callback(hObject, eventdata, handles)
global atlasViewer

fwmodel       = atlasViewer.fwmodel;
imgrecon      = atlasViewer.imgrecon;
dirnameSubj   = atlasViewer.dirnameSubj;
probe         = atlasViewer.probe;
axesv       = atlasViewer.axesv;
hbconc      = atlasViewer.hbconc;
pialsurf    = atlasViewer.pialsurf;


% Check if there's a sensitivity profile which already exists
if exist([dirnameSubj 'fw/Adot.mat'],'file')
    qAdotExists = menu('Do you want to use the existing sensitivity profile in Adot.mat','Yes','No');
    if qAdotExists == 1
        % JAY, I NEED TO FIX THIS FOR runMCXlab. WHAT DO I DO?
        fwmodel = menuItemGenerateLoadSensitivityProfile_Callback(hObject, struct('EventName','Action'), handles);
        if ~isempty(fwmodel.Adot)
            enableDisableMCoutputGraphics(fwmodel, 'on');
        end
        return;
    else
%         delete([dirnameSubj 'fw/Adot*.mat']);
        fwmodel.Adot=[];
    end
end

% run MCXlab
fwmodel = runMCXlab( fwmodel, probe, dirnameSubj);

% Set image popupmenu to sensitivity
set(handles.popupmenuImageDisplay,'value',fwmodel.menuoffset+1);
set(handles.editColormapThreshold,'string',sprintf('%0.2g %0.2g',fwmodel.cmThreshold(1),fwmodel.cmThreshold(2)));

% Turn off image recon display
imgrecon = showImgReconDisplay(imgrecon, axesv(1).handles.axesSurfDisplay, 'off', 'off', 'off','off');
hbconc = showHbConcDisplay(hbconc, axesv(1).handles.axesSurfDisplay, 'off', 'off');

fwmodel = displaySensitivity(fwmodel, pialsurf, [], probe);

set(pialsurf.handles.radiobuttonShowPial, 'value',0);
uipanelBrainDisplay_Callback(pialsurf.handles.radiobuttonShowPial, [], handles);

if ~isempty(fwmodel.Adot)
    imgrecon = enableImgReconGen(imgrecon,'on');
    imgrecon.mesh = fwmodel.mesh;
else
    imgrecon = enableImgReconGen(imgrecon,'off');
end

atlasViewer.fwmodel = fwmodel;
atlasViewer.imgrecon = imgrecon;



% --------------------------------------------------------------------
function menuItemProbeCreate_Callback(hObject, eventdata, handles)
global atlasViewer

labelssurf   = atlasViewer.labelssurf;

hSDgui = atlasViewer.probe.handles.hSDgui;
if isempty(which('SDgui'))
    menu('SDgui doesn''t exist in the search path.','OK');
    return;
end
if ishandles(hSDgui)
    menu('SDgui already active.','OK');
    return;
end
atlasViewer.probe = resetProbe(atlasViewer.probe);
atlasViewer.probe.handles.hSDgui = SDgui(atlasViewer.dirnameProbe,'userargs');
set(atlasViewer.probe.handles.pushbuttonRegisterProbeToSurface,'enable','on');

% Clear labels faces associated with probe to cortex projection (we mark 
% the faces red). It's all new for a new probe.
labelssurf = resetLabelssurf(labelssurf);

atlasViewer.labelssurf = labelssurf;


% --------------------------------------------------------------------
function menuItemProbeImport_Callback(hObject, eventdata, handles)
global atlasViewer

dirnameProbe = atlasViewer.dirnameProbe;
probe        = atlasViewer.probe;
refpts       = atlasViewer.refpts;
headsurf     = atlasViewer.headsurf;
labelssurf   = atlasViewer.labelssurf;
fwmodel      = atlasViewer.fwmodel;
imgrecon     = atlasViewer.imgrecon;
digpts       = atlasViewer.digpts;

[filename, pathname] = uigetfile([dirnameProbe '*.*'],'Import subject probe');
if filename==0
    return;
end

% Make sure we are using all available eeg points. Select locally so that
% we don't change anything in refpts
refpts.eeg_system.selected = '10-5';
refpts = set_eeg_active_pts(refpts, [], false);

% New probe means resetting probe, anatomical labels and sensitivity profile
probe       = resetProbe(probe);
fwmodel     = resetFwmodel(fwmodel);
imgrecon    = resetImgRecon(imgrecon);
labelssurf  = resetLabelssurf(labelssurf);

probe = importProbe(probe, [pathname, filename], headsurf, refpts);

hAxesCurr = gca;
axes(atlasViewer.axesv(1).handles.axesSurfDisplay);
probe = viewProbe(probe,'unregistered');
axes(hAxesCurr)

% This is done to not display dummy points by default. It does nothing 
% if the method isn't spring registration.
probe = setProbeDisplay(probe,headsurf);

atlasViewer.probe        = probe;
atlasViewer.probe_copy   = atlasViewer.probe; % this is useful for testing if the probe is modified
atlasViewer.dirnameProbe = pathname;
atlasViewer.labelssurf   = labelssurf;
atlasViewer.digpts       = digpts;
atlasViewer.fwmodel      = fwmodel;
atlasViewer.imgrecon     = imgrecon;


% --------------------------------------------------------------------
% function menuItemProbeEdit_Callback(~, ~, ~)
% global atlasViewer
% SD = convertProbe2SD(atlasViewer.probe);
% SDgui(SD);


% this is removed and replaced with create/edit probe in AtlasViewer itself
% --------------------------------------------------------------------
% function menuItemProbeAdjust3DRegistration_Callback(~, ~, ~)
% Edit_Probe_Callback



% --------------------------------------------------------------------
function menuItemRefptsFontSize_Callback(~, ~, ~)
global atlasViewer
atlasViewer.refpts = resizeFonts(atlasViewer.refpts, 'Reference Points');


% --------------------------------------------------------------------
function menuItemProbeFontSize_Callback(~, ~, ~)
global atlasViewer
atlasViewer.probe = resizeFonts(atlasViewer.probe, 'Probe Optodes');



% --------------------------------------------------------------------
function menuItemViewAxes_Callback(hObject, ~, handles) %#ok<INUSD>
global atlasViewer

axesv = atlasViewer.axesv; 
refpts = atlasViewer.refpts;

if leftRightFlipped(refpts)
    axes_order = [2,1,3];   %#ok<NASGU>
else
    axes_order = [1,2,3]; %#ok<NASGU>
end

type = get(hObject,'type');
label = get(hObject,'label');
if strcmp(type, 'uimenu')
    checked_propname = 'checked';
    ia = 1;
elseif strcmp(type, 'uicontrol')
    checked_propname = 'value';
    ia = 2;
end

hAxes = axesv(ia).handles.axesSurfDisplay;
hOrigin = getappdata(hAxes, 'hOrigin');

labels = {'XYZ','RAS'};
if strcmp(label, 'XYZ')
    idx = 1;
elseif strcmp(label, 'RAS')
    idx = 2;
elseif strcmp(label, 'XYZ and RAS')
    idx = [1,2];
end

onoff = '';
for ii=1:length(idx)
    if ~ishandles(hOrigin(idx(ii),:))
        continue;
    end
    if strcmp(get(hOrigin(idx(ii),:), 'visible'), 'off')
        if ia==1
            onoff = 'on';
        elseif ia==2
            onoff = 1;
        end
    elseif strcmp(get(hOrigin(idx(ii),:), 'visible'), 'on')
        if ia==1
            onoff = 'off';
        elseif ia==2
            onoff = 0;
        end
    end
    eval( sprintf('set(handles.menuItemViewAxes%s, checked_propname, onoff);', labels{idx(ii)}) );
    eval( sprintf('viewAxes%s(hAxes, axes_order, [], ''donotredraw'');', labels{idx(ii)}) );
end
if isempty(onoff)
    return;
end
set(hObject, checked_propname, onoff);





% --------------------------------------------------------------------
function menuItemResetForwardModel_Callback(hObject, eventdata, handles)
global atlasViewer
msg{1} = sprintf('WARNING: This action will reset the Forward Model to a known ''empty'' state. ');
msg{2} = sprintf('This means all the Monte Carlo output and Sensitivity Profile for this subject will be deleted. ');
msg{3} = sprintf('Do this to re-run the forward model from scratch. ');
msg{4} = sprintf('Are you sure that is what you want to do?');
q = MenuBox(msg, {'YES','NO'});
if q==2
    return;
end

if ispathvalid([atlasViewer.dirnameSubj, 'fw'])
    fprintf('rmdir(''%s'',''s'');\n', [atlasViewer.dirnameSubj, 'fw']);
    rmdir([atlasViewer.dirnameSubj, 'fw'],'s');
end
atlasViewer.fwmodel = initFwmodel(handles);
atlasViewer.fwmodel = getFwmodel(atlasViewer.fwmodel, atlasViewer.dirnameSubj, atlasViewer.pialsurf, ...
                                 atlasViewer.headsurf, atlasViewer.headvol, atlasViewer.probe);



% --------------------------------------------------------------------
function menuItemProbeDesignEditAV_Callback(hObject, eventdata, handles)
% hObject    handle to menuItemProbeDesignEditAV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global atlasViewer

headSurf = atlasViewer.headsurf.handles.surf;
set(handles.uipanelProbeDesignEdit,'Units','normalized','Position',[0.7113 0.033 0.227 0.265])
% set(handles.uipanelProbeDesignEdit,'Units','normalized','Position',[0.7113 0.033 0.4 0.265])
% set(handles.uibuttongroupEditOptode,'Units','normalized','Position',[0.05 0.5 0.7 0.4])
% set(handles.uipaneSpringListDist,'Units','normalized','Position',[0.05 0.05 0.7 0.4])
if strcmpi(get(handles.uipanelProbeDesignEdit,'Visible'),'On')
    set(handles.uipanelProbeDesignEdit,'Visible','Off')
    set(handles.menuItemProbeDesignEditAV,'Checked','Off')
    set(handles.uipanel_EditOptode,'Visible','Off')
    set(handles.checkboxOptodeSDMode,'Enable','on')
    if isfield(atlasViewer.probe.handles,'hSprings_editOptode')
    if ishandles(atlasViewer.probe.handles.hSprings_editOptode)
        delete(atlasViewer.probe.handles.hSprings_editOptode);
    end
    end

    if isfield(atlasViewer.probe.handles,'hMeasList_editOptode')
        if ishandles(atlasViewer.probe.handles.hMeasList_editOptode)
            delete(atlasViewer.probe.handles.hMeasList_editOptode);
        end
    end
    
    % remove editOptodeinfo if it is already exists and set Anchor Point to
    % none
    if isfield(atlasViewer.probe,'editOptodeInfo')
       atlasViewer.probe = rmfield(atlasViewer.probe,'editOptodeInfo');
    end
    set(handles.edit_assignAnchorPt,'String','none');
elseif strcmpi(get(handles.uipanelProbeDesignEdit,'Visible'),'Off')
    set(handles.uipanelProbeDesignEdit,'Visible','On')
    set(handles.menuItemProbeDesignEditAV,'Checked','On')
    contents = cellstr(get(handles.popupmenuSelectOptodeType,'String'));
    selected_grommet_type = contents{get(handles.popupmenuSelectOptodeType,'Value')};
    if strcmpi(selected_grommet_type,'Source') || strcmpi(selected_grommet_type,'Detector')
        set(handles.checkboxOptodeSDMode,'Value',1.0)
        checkboxOptodeSDMode_Callback(hObject, eventdata, handles)
        set(handles.checkboxOptodeSDMode,'Enable','off')
    elseif strcmpi(selected_grommet_type,'Dummy')
        set(handles.checkboxHideDummyOpts,'Value',0.0)
        checkboxHideDummyOpts_Callback(hObject, eventdata, handles)
        set(handles.checkboxOptodeSDMode,'Enable','off')
    end        
    set(headSurf, 'buttondownfcn', {@headsurf_btndwn,handles})
    if ~isempty(atlasViewer.probe.lambda)
        set(handles.edit_Lamdbas,'String',num2str(atlasViewer.probe.lambda));
    else
        atlasViewer.probe.lambda = str2num(get(handles.edit_Lamdbas, 'string'));
    end
end

% --- Executes on button press in radiobuttonAddOptodeAV.
function radiobuttonAddOptodeAV_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonAddOptodeAV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonAddOptodeAV
global atlasViewer
set(handles.radiobuttonAddOptodeAV,'Value',1.0)
set(handles.radiobuttonRemoveOptodeAV,'Value',0.0)
set(handles.radiobuttonEditOptodeAV,'Value',0.0)
set(handles.uipanel_EditOptode,'Visible','Off')

% remove editOptodeinfo if it is already exists and set Anchor Point to
% none
if isfield(atlasViewer.probe,'editOptodeInfo')
   atlasViewer.probe = rmfield(atlasViewer.probe,'editOptodeInfo');
end
set(handles.edit_assignAnchorPt,'String','none');

contents = cellstr(get(handles.popupmenuSelectOptodeType,'String'));
selected_grommet_type = contents{get(handles.popupmenuSelectOptodeType,'Value')};
if strcmpi(selected_grommet_type,'Source') || strcmpi(selected_grommet_type,'Detector')
    set(handles.checkboxOptodeSDMode,'Value',1.0)
    checkboxOptodeSDMode_Callback(hObject, eventdata, handles)
elseif strcmpi(selected_grommet_type,'Dummy')
    set(handles.checkboxHideDummyOpts,'Value',0.0)
    checkboxHideDummyOpts_Callback(hObject, eventdata, handles)
end
set(handles.checkboxOptodeSDMode,'Enable','off')

if isfield(atlasViewer.probe.handles,'hSprings_editOptode')
    if ishandles(atlasViewer.probe.handles.hSprings_editOptode)
        delete(atlasViewer.probe.handles.hSprings_editOptode);
    end
end

if isfield(atlasViewer.probe.handles,'hMeasList_editOptode')
    if ishandles(atlasViewer.probe.handles.hMeasList_editOptode)
        delete(atlasViewer.probe.handles.hMeasList_editOptode);
    end
end

set(handles.popupmenuSelectOptodeType,'Enable','on');
set(handles.popupmenu_selectGrommetType,'Enable','on');
set(handles.edit_assignAnchorPt,'Enable','off');
set(handles.edit_grommetRotation,'Enable','on');


% --- Executes on button press in radiobuttonRemoveOptodeAV.
function radiobuttonRemoveOptodeAV_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonRemoveOptodeAV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonRemoveOptodeAV
global atlasViewer
set(handles.radiobuttonAddOptodeAV,'Value',0.0)
set(handles.radiobuttonRemoveOptodeAV,'Value',1.0)
set(handles.radiobuttonEditOptodeAV,'Value',0.0)
set(handles.uipanel_EditOptode,'Visible','Off')

% remove editOptodeinfo if it is already exists and set Anchor Point to
% none
if isfield(atlasViewer.probe,'editOptodeInfo')
   atlasViewer.probe = rmfield(atlasViewer.probe,'editOptodeInfo');
end
set(handles.edit_assignAnchorPt,'String','none');

set(handles.checkboxOptodeSDMode,'Value',1.0)
checkboxOptodeSDMode_Callback(hObject, eventdata, handles)

if isfield(atlasViewer.probe.handles,'hSprings_editOptode')
    if ishandles(atlasViewer.probe.handles.hSprings_editOptode)
        delete(atlasViewer.probe.handles.hSprings_editOptode);
    end
end

if isfield(atlasViewer.probe.handles,'hMeasList_editOptode')
    if ishandles(atlasViewer.probe.handles.hMeasList_editOptode)
        delete(atlasViewer.probe.handles.hMeasList_editOptode);
    end
end
set(handles.checkboxOptodeSDMode,'Enable','off')
set(handles.popupmenuSelectOptodeType,'Enable','off');
set(handles.popupmenu_selectGrommetType,'Enable','off');
set(handles.edit_assignAnchorPt,'Enable','off');
set(handles.edit_grommetRotation,'Enable','off');

% --- Executes on button press in radiobuttonEditOptodeAV.
function radiobuttonEditOptodeAV_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonEditOptodeAV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonEditOptodeAV
set(handles.radiobuttonAddOptodeAV,'Value',0.0)
set(handles.radiobuttonRemoveOptodeAV,'Value',0.0)
set(handles.radiobuttonEditOptodeAV,'Value',1.0)
set(handles.popupmenuSelectOptodeType,'Enable','off');
set(handles.popupmenu_selectGrommetType,'Enable','off');
set(handles.edit_assignAnchorPt,'Enable','off');
set(handles.edit_grommetRotation,'Enable','off');
% set(handles.uipanel_EditOptode,'Visible','On')
% set(handles.uipanel_EditOptode,'Units','normalized','Position',[0.77 0.45 0.2 0.465])
% set(handles.uitable_editMLorSL,'Data',cell(5,3))
% set(handles.uitable_editMLorSL,'ColumnName',{'Source','Detector','Distance'})
% set(handles.uitable_editMLorSL,'Units','normalized','Position',[0.1 0.1 0.88 0.55])

% --- Executes on selection change in popupmenuSelectOptodeType.
function popupmenuSelectOptodeType_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSelectOptodeType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSelectOptodeType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSelectOptodeType
global atlasViewer
nrsc = atlasViewer.probe.nsrc;
ndet = atlasViewer.probe.ndet;
contents = cellstr(get(handles.popupmenuSelectOptodeType,'String'));
selected_optode_type = contents{get(handles.popupmenuSelectOptodeType,'Value')};
if strcmpi(selected_optode_type,'Source') || strcmpi(selected_optode_type,'Detector')
    set(handles.checkboxOptodeSDMode,'Value',1.0)
    checkboxOptodeSDMode_Callback(hObject, eventdata, handles)
elseif strcmpi(selected_optode_type,'Dummy')
    set(handles.checkboxHideDummyOpts,'Value',0.0)
    checkboxHideDummyOpts_Callback(hObject, eventdata, handles)
end
set(handles.checkboxOptodeSDMode,'Enable','off')

if get(handles.radiobuttonEditOptodeAV,'Value') && isfield(atlasViewer.probe,'editOptodeInfo')
    idx = atlasViewer.probe.editOptodeInfo.currentOptode;
    if idx <= nrsc
        opt_type = 'Source';
%         opt_no = idx;
%         grommet_type = atlasViewer.probe.SrcGrommetType{opt_no};
%         grommet_rot = atlasViewer.probe.SrcGrommetRot{opt_no};
    elseif idx <= nrsc+ndet
        opt_type = 'Detector';
%         opt_no = idx-nrsc;
%         grommet_type = atlasViewer.probe.DetGrommetType{opt_no};
%         grommet_rot = atlasViewer.probe.DetGrommetRot{opt_no};
    else
        opt_type = 'Dummy';
%         opt_no = idx-nrsc;
%         grommet_type = atlasViewer.probe.DummyGrommetType{idx-nrsc-ndet};
%         grommet_rot = atlasViewer.probe.DummyGrommetRot{idx-nrsc-ndet};
    end
    
    if strcmp(selected_optode_type, opt_type)
        return
    else
        if strcmp(selected_optode_type,'Source')
            atlasViewer.probe.editOptodeInfo.currentOptode = nrsc+1;
        elseif strcmp(selected_optode_type,'Detector')
            atlasViewer.probe.editOptodeInfo.currentOptode = nrsc+ndet;
        else
           atlasViewer.probe.editOptodeInfo.currentOptode = size(atlasViewer.probe.optpos_reg,1);
        end
        al_index = find([atlasViewer.probe.registration.al{:,1}]==idx);
        optode_pos = atlasViewer.probe.optpos_reg(idx,:);
        deleteAnOptode(idx)
        addAnOptode(optode_pos, handles)
        if ~isempty(al_index)
            atlasViewer.probe.registration.al{al_index,1} = atlasViewer.probe.editOptodeInfo.currentOptode;
        end
        probe = displayProbe(atlasViewer.probe, atlasViewer.headsurf);
        atlasViewer.probe = probe;
         if get(handles.radiobutton_MeasListVisible,'Value')
             radiobutton_MeasListVisible_Callback(hObject, eventdata, handles)
         elseif get(handles.radiobutton_SpringListVisible,'Value')
             radiobutton_SpringListVisible_Callback(hObject, eventdata, handles)
         end
    end 
end

function deleteAnOptode(idx)
    
global atlasViewer
optpos_reg = atlasViewer.probe.optpos_reg;
ml = atlasViewer.probe.ml;
sl = atlasViewer.probe.registration.sl;
nrsc = atlasViewer.probe.nsrc;
ndet = atlasViewer.probe.ndet;
if idx <= nrsc
    opt_type = 'Source';
    opt_no = idx;
elseif idx <= nrsc+ndet
    opt_type = 'Detector';
    opt_no = idx-nrsc;
else
    opt_type = 'Dummy';
    opt_no = idx-nrsc-ndet;
end

optpos_reg(idx,:) = [];
atlasViewer.probe.noptorig = atlasViewer.probe.noptorig-1;
if strcmp(opt_type,'Source')
    atlasViewer.probe.nsrc = atlasViewer.probe.nsrc-1;
    atlasViewer.probe.SrcGrommetType(opt_no) = [];
    atlasViewer.probe.SrcGrommetRot(opt_no) = [];
    atlasViewer.probe.srcpos(opt_no,:) = []; 
    if ~isempty(ml)
        optode_ml_idx = find(ml(:,1) == opt_no);
        m_idx = find(ml(:,1) >= opt_no);
        ml(m_idx,1) = ml(m_idx,1)-1;
    else
        optode_ml_idx = [];
    end
elseif strcmp(opt_type,'Detector')
    atlasViewer.probe.ndet = atlasViewer.probe.ndet-1;
    atlasViewer.probe.DetGrommetType(opt_no) = [];
    atlasViewer.probe.DetGrommetRot(opt_no) = [];
    atlasViewer.probe.detpos(opt_no,:) = []; 
    if ~isempty(ml)
        optode_ml_idx = find(ml(:,2) == opt_no);
        m_idx = find(ml(:,2) >= opt_no);
        ml(m_idx,2) = ml(m_idx,2)-1;
    else
        optode_ml_idx = [];
    end
elseif strcmp(opt_type,'Dummy')
    optode_ml_idx = [];
    atlasViewer.probe.DummyGrommetType(idx-nrsc-ndet) = [];
    atlasViewer.probe.DummyGrommetRot(idx-nrsc-ndet) = [];
    atlasViewer.probe.registration.dummypos(idx-nrsc-ndet,:) = [];
end  
if ~isempty(optode_ml_idx)
    ml(optode_ml_idx,:) = [];
end
if ~isempty(sl)
    optode_sl_idx = find(sl(:,1) == idx | sl(:,2) == idx);
    if ~isempty(optode_sl_idx)
        sl(optode_sl_idx,:) = [];
    end

    s_idx = find(sl(:,1) >= idx);
    sl(s_idx,1) = sl(s_idx,1)-1;
    s_idx = find(sl(:,2) >= idx);
    sl(s_idx,2) = sl(s_idx,2)-1;
end
al = atlasViewer.probe.registration.al;
for u = 1:size(al,1)
    if al{u,1} >= idx
        al{u,1} = al{u,1}-1;
    end
end
atlasViewer.probe.registration.al = al;
atlasViewer.probe.optpos_reg = optpos_reg ;
atlasViewer.probe.ml = ml;
atlasViewer.probe.registration.sl = sl;


function addAnOptode(selected_point, handles)
global atlasViewer
contents = cellstr(get(handles.popupmenuSelectOptodeType,'String'));
selected_optode_type = contents{get(handles.popupmenuSelectOptodeType,'Value')};
contents = cellstr(get(handles.popupmenu_selectGrommetType,'String'));
selected_grommet_type = contents{get(handles.popupmenu_selectGrommetType,'Value')};
grommet_rot = str2double(get(handles.edit_grommetRotation,'String'));
measurement_dist = str2num(get(handles.editMeasurementListDist, 'string'));
sprint_dist = str2num(get(handles.editSpringListDist, 'string'));
nrsc = atlasViewer.probe.nsrc;
ndet = atlasViewer.probe.ndet;
lambda = atlasViewer.probe.lambda;
optpos_reg = atlasViewer.probe.optpos_reg;
if strcmpi(selected_optode_type,'Source')
    optpos_reg = [optpos_reg(1:nrsc,:); selected_point; optpos_reg(nrsc+1:end,:)];
    atlasViewer.probe.SrcGrommetType{end+1} = selected_grommet_type;
    atlasViewer.probe.SrcGrommetRot{end+1} = grommet_rot;
    atlasViewer.probe.optpos_reg = optpos_reg;
    atlasViewer.probe.srcpos = [atlasViewer.probe.srcpos; [0 0 0]];
    nrsc = nrsc+1;
    atlasViewer.probe.nsrc = nrsc;
    atlasViewer.probe.noptorig = atlasViewer.probe.noptorig+1;
%             atlasViewer.probe.SrcGrommetType{end+1} = '';
%             atlasViewer.probe.SrcGrommetRot{end+1} = 0;

    % add measurement list to new optode
    det_dist = sqrt(sum((optpos_reg(nrsc+1:nrsc+ndet,:)-selected_point).^2,2));
    nearby_det = find(det_dist >= measurement_dist(1) & det_dist <= measurement_dist(2));
    MeasList = [];
    if isempty(lambda)
        n_lambda = 1;
    else
        n_lambda = length(lambda);
    end
    for u = 1:n_lambda
        MeasList = [MeasList; ones(size(nearby_det))*(nrsc) nearby_det ones(size(nearby_det)) ones(size(nearby_det))*u];
    end
    atlasViewer.probe.ml = [atlasViewer.probe.ml; MeasList];

    % add spring list to new optode
    sl = atlasViewer.probe.registration.sl;
    if ~isempty(sl)
        idx = find(sl(:,1) >= nrsc);
        sl(idx,1) = sl(idx,1)+1;
        idx = find(sl(:,2) >= nrsc);
        sl(idx,2) = sl(idx,2)+1;
    end
    opt_dist = sqrt(sum((optpos_reg-selected_point).^2,2));
    nearby_opt = find(opt_dist >= sprint_dist(1) & opt_dist <= sprint_dist(2));
    nearby_opt = setdiff(nearby_opt,nrsc);
    springList = [ones(size(nearby_opt))*(nrsc) nearby_opt opt_dist(nearby_opt)];
    sl = [sl; springList];
    atlasViewer.probe.registration.sl = sl;

    al = atlasViewer.probe.registration.al;
    for u = 1:size(al,1)
        if al{u,1} >= nrsc
            al{u,1} = al{u,1}+1;
        end
    end
    atlasViewer.probe.registration.al = al;
%             probe = viewProbe(atlasViewer.probe, 'registered');
%             probe = setProbeDisplay(probe, atlasViewer.headsurf);
    probe = displayProbe(atlasViewer.probe, atlasViewer.headsurf);
%             probe.handles.labels = [probe.handles.labels(1:nrsc,:); probe.handles.labels(end,:); probe.handles.labels(nrsc+1:end-1,:)];
    atlasViewer.probe = probe;
elseif strcmpi(selected_optode_type,'Detector')
    optpos_reg = [optpos_reg(1:nrsc+ndet,:); selected_point; optpos_reg(nrsc+ndet+1:end,:)];
    atlasViewer.probe.DetGrommetType{end+1} = selected_grommet_type;
    atlasViewer.probe.DetGrommetRot{end+1} = grommet_rot;
    atlasViewer.probe.optpos_reg = optpos_reg;
    atlasViewer.probe.detpos = [atlasViewer.probe.detpos; [0 0 0]];
    ndet = ndet+1;
    atlasViewer.probe.ndet = ndet;
    atlasViewer.probe.noptorig = atlasViewer.probe.noptorig+1;

    % add measurement list to new optode
    src_dist = sqrt(sum((optpos_reg(1:nrsc,:)-selected_point).^2,2));
    nearby_src = find(src_dist >= measurement_dist(1) & src_dist <= measurement_dist(2));
    MeasList = [];
    if isempty(lambda)
        n_lambda = 1;
    else
        n_lambda = length(lambda);
    end
    for u = 1:n_lambda
        MeasList = [MeasList; nearby_src ones(size(nearby_src))*ndet ones(size(nearby_src)) ones(size(nearby_src))*u];
    end
    atlasViewer.probe.ml = [atlasViewer.probe.ml; MeasList];

    % add spring list to new optode
    sl = atlasViewer.probe.registration.sl;
    if ~isempty(sl)
        idx = find(sl(:,1) >= nrsc+ndet);
        sl(idx,1) = sl(idx,1)+1;
        idx = find(sl(:,2) >= nrsc+ndet);
        sl(idx,2) = sl(idx,2)+1;
    end
    opt_dist = sqrt(sum((optpos_reg-selected_point).^2,2));
    nearby_opt = find(opt_dist >= sprint_dist(1) & opt_dist <= sprint_dist(2));
    nearby_opt = setdiff(nearby_opt,nrsc+ndet);
    springList = [ones(size(nearby_opt))*(nrsc+ndet) nearby_opt opt_dist(nearby_opt)];
    sl = [sl; springList];
    atlasViewer.probe.registration.sl = sl;

    al = atlasViewer.probe.registration.al;
    for u = 1:size(al,1)
        if al{u,1} >= nrsc+ndet
            al{u,1} = al{u,1}+1;
        end
    end
    atlasViewer.probe.registration.al = al;

    probe = displayProbe(atlasViewer.probe, atlasViewer.headsurf);
    atlasViewer.probe = probe;

elseif strcmpi(selected_optode_type,'Dummy')
    atlasViewer.probe.optpos_reg = [atlasViewer.probe.optpos_reg; selected_point];
    atlasViewer.probe.registration.dummypos = [atlasViewer.probe.registration.dummypos; [0 0 0]];
    atlasViewer.probe.DummyGrommetType{end+1} = selected_grommet_type;
    atlasViewer.probe.DummyGrommetRot{end+1} = grommet_rot;
    opt_pos = size(atlasViewer.probe.optpos_reg,1);
    atlasViewer.probe.noptorig = atlasViewer.probe.noptorig+1;

    % add spring list to new probe
    opt_dist = sqrt(sum((optpos_reg-selected_point).^2,2));
    nearby_opt = find(opt_dist >= sprint_dist(1) & opt_dist <= sprint_dist(2));
    springList = [ones(size(nearby_opt))*(opt_pos) nearby_opt opt_dist(nearby_opt)];
    atlasViewer.probe.registration.sl = [atlasViewer.probe.registration.sl; springList];
end


% --- Executes during object creation, after setting all properties.
function popupmenuSelectOptodeType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSelectOptodeType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSpringListDist_Callback(hObject, eventdata, handles)
% hObject    handle to editSpringListDist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSpringListDist as text
%        str2double(get(hObject,'String')) returns contents of editSpringListDist as a double


% --- Executes during object creation, after setting all properties.
function editSpringListDist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSpringListDist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editMeasurementListDist_Callback(hObject, eventdata, handles)
% hObject    handle to editMeasurementListDist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMeasurementListDist as text
%        str2double(get(hObject,'String')) returns contents of editMeasurementListDist as a double

global atlasViewer

answer = questdlg('This change will impact all new optodes. Do you want to apply it to the existing measurement list?', ...
    '',...
	'Yes', ...
	'No','No');
switch answer
    case 'Yes'
        measurement_dist = str2num(get(hObject,'String'));
        spring_dist = str2num(get(handles.editSpringListDist,'String'));
        nsrc = atlasViewer.probe.nsrc;
        ndet = atlasViewer.probe.ndet;
        lambda = atlasViewer.probe.lambda;
        if isempty(lambda)
            n_lambda = 1;
        else
            n_lambda = length(lambda);
        end
        SrcPos3D = atlasViewer.probe.optpos_reg(1:nsrc,:);
        DetPos3D = atlasViewer.probe.optpos_reg(nsrc+1:nsrc+ndet,:);
        MeasList_new = [];
        for u = 1:nsrc
            dist = sqrt(sum((DetPos3D-SrcPos3D(u,:)).^2,2));
            nearby_det = find(dist >=measurement_dist(1) & dist <=measurement_dist(2));
            if ~isempty(nearby_det)
                for v = 1:n_lambda
                    MeasList_new = [MeasList_new; [u*ones(length(nearby_det),1) nearby_det ones(length(nearby_det),1) v*ones(length(nearby_det),1)]];
                end
            end
        end
        if isempty(MeasList_new)
            return
        end
        MeasList = atlasViewer.probe.ml;
        MeasList_idx_to_add = ~ismember(MeasList_new, MeasList,'rows');
        MeasList_idx_to_remove = ~ismember(MeasList, MeasList_new,'rows');
        MeasList_length_to_add = length(find(MeasList_idx_to_add==1));
        MeasList_length_to_remove = length(find(MeasList_idx_to_remove==1));
        
        measuremnts_add_answer = questdlg(['This will add ' num2str(MeasList_length_to_add) ' new measurement list. Do you want to continue?'], ...
            'Add measurement list',...
            'Yes, add new measurements', ...
            'No, do not add new measurements','No, do not add new measurements');
        
        switch measuremnts_add_answer
            case 'Yes, add new measurements'
                MeasList_to_add = MeasList_new(MeasList_idx_to_add,:);
                SpringList_new = unique(MeasList_to_add(:,1:2),'rows');
                SpringList_new(:,2) = SpringList_new(:,2)+nsrc;
                SpringList = atlasViewer.probe.registration.sl;
                if ~isempty(SpringList)
                    SpringList_idx_to_add =  ~(ismember(SpringList_new,[SpringList(:,1) SpringList(:,2)],'rows') | ...
                        ismember(SpringList_new,[SpringList(:,2) SpringList(:,1)],'rows'));
                else
                    SpringList_idx_to_add = SpringList_new;
                end
                SpringList_to_add = SpringList_new(SpringList_idx_to_add,:);
                SpringList_to_add_dist = sqrt(sum((atlasViewer.probe.optpos_reg(SpringList_to_add(:,1),:)-atlasViewer.probe.optpos_reg(SpringList_to_add(:,2),:)).^2,2));
                SpringList_to_add = [SpringList_to_add SpringList_to_add_dist];
                MeasList = [MeasList; MeasList_to_add];
                % remove spring list items from SpringList_to_add that are
                % outside the specified range of Spring List Dist from GUI
                idx_to_remove = find(SpringList_to_add(:,3) < spring_dist(1) | SpringList_to_add(:,3) > spring_dist(2));
                if ~isempty(idx_to_remove)
                    SpringList_to_add(idx_to_remove,:) = [];
                end
                SpringList = [SpringList; SpringList_to_add];
                atlasViewer.probe.ml = MeasList;
                atlasViewer.probe.registration.sl = SpringList;
            case 'No, do not add new measurements'
        end
        
        measuremnts_delete_answer = questdlg(['This will remove ' num2str(MeasList_length_to_remove) ' from previous measurement List. Do you want to continue?'], ...
            'Delete measurement list',...
            'Yes, delete measurements', ...
            'No, do not delete measurements','No, do not delete measurements');
        switch measuremnts_delete_answer
            case 'Yes, delete measurements'
                atlasViewer.probe.ml(MeasList_idx_to_remove,:) = [];
        end
        
        probe = displayProbe(atlasViewer.probe, atlasViewer.headsurf);
        atlasViewer.probe = probe;
        
    case 'No'
end



% --- Executes during object creation, after setting all properties.
function editMeasurementListDist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMeasurementListDist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function headsurf_btndwn(hObject, eventdata, handles)
global atlasViewer
if eventdata.Button == 1
    if strcmpi(get(handles.menuItemProbeDesignEditAV,'Checked'),'on')
        selected_point = eventdata.IntersectionPoint;
        if leftRightFlipped(atlasViewer.probe)
                temp_pt = selected_point(2);
                selected_point(2) = selected_point(1);
                selected_point(1) = temp_pt;
        end
        if get(handles.radiobuttonAddOptodeAV,'Value')
            contents = cellstr(get(handles.popupmenuSelectOptodeType,'String'));
            selected_optode_type = contents{get(handles.popupmenuSelectOptodeType,'Value')};
            contents = cellstr(get(handles.popupmenu_selectGrommetType,'String'));
            selected_grommet_type = contents{get(handles.popupmenu_selectGrommetType,'Value')};
            grommet_rot = str2double(get(handles.edit_grommetRotation,'String'));
            measurement_dist = str2num(get(handles.editMeasurementListDist, 'string'));
            sprint_dist = str2num(get(handles.editSpringListDist, 'string'));
            nrsc = atlasViewer.probe.nsrc;
            ndet = atlasViewer.probe.ndet;
            lambda = atlasViewer.probe.lambda;
            optpos_reg = atlasViewer.probe.optpos_reg;
            if strcmpi(selected_optode_type,'Source')
                optpos_reg = [optpos_reg(1:nrsc,:); selected_point; optpos_reg(nrsc+1:end,:)];
                atlasViewer.probe.SrcGrommetType{end+1} = selected_grommet_type;
                atlasViewer.probe.SrcGrommetRot{end+1} = grommet_rot;
                atlasViewer.probe.optpos_reg = optpos_reg;
                atlasViewer.probe.srcpos = [atlasViewer.probe.srcpos; [0 0 0]];
                nrsc = nrsc+1;
                atlasViewer.probe.nsrc = nrsc;
                atlasViewer.probe.noptorig = atlasViewer.probe.noptorig+1;
    %             atlasViewer.probe.SrcGrommetType{end+1} = '';
    %             atlasViewer.probe.SrcGrommetRot{end+1} = 0;

                % add measurement list to new optode
                det_dist = sqrt(sum((optpos_reg(nrsc+1:nrsc+ndet,:)-selected_point).^2,2));
                nearby_det = find(det_dist >= measurement_dist(1) & det_dist <= measurement_dist(2));
                MeasList = [];
                if isempty(lambda)
                    n_lambda = 1;
                else
                    n_lambda = length(lambda);
                end
                for u = 1:n_lambda
                    MeasList = [MeasList; ones(size(nearby_det))*(nrsc) nearby_det ones(size(nearby_det)) ones(size(nearby_det))*u];
                end
                atlasViewer.probe.ml = [atlasViewer.probe.ml; MeasList];

                % add spring list to new optode
                sl = atlasViewer.probe.registration.sl;
                if ~isempty(sl)
                    idx = find(sl(:,1) >= nrsc);
                    sl(idx,1) = sl(idx,1)+1;
                    idx = find(sl(:,2) >= nrsc);
                    sl(idx,2) = sl(idx,2)+1;
                end
                opt_dist = sqrt(sum((optpos_reg-selected_point).^2,2));
                nearby_opt = find(opt_dist >= sprint_dist(1) & opt_dist <= sprint_dist(2));
                nearby_opt = setdiff(nearby_opt,nrsc);
                springList = [ones(size(nearby_opt))*(nrsc) nearby_opt opt_dist(nearby_opt)];
                sl = [sl; springList];
                atlasViewer.probe.registration.sl = sl;
                
                al = atlasViewer.probe.registration.al;
                for u = 1:size(al,1)
                    if al{u,1} >= nrsc
                        al{u,1} = al{u,1}+1;
                    end
                end
                atlasViewer.probe.registration.al = al;
    %             probe = viewProbe(atlasViewer.probe, 'registered');
    %             probe = setProbeDisplay(probe, atlasViewer.headsurf);
                probe = displayProbe(atlasViewer.probe, atlasViewer.headsurf);
    %             probe.handles.labels = [probe.handles.labels(1:nrsc,:); probe.handles.labels(end,:); probe.handles.labels(nrsc+1:end-1,:)];
                atlasViewer.probe = probe;
            elseif strcmpi(selected_optode_type,'Detector')
                optpos_reg = [optpos_reg(1:nrsc+ndet,:); selected_point; optpos_reg(nrsc+ndet+1:end,:)];
                atlasViewer.probe.DetGrommetType{end+1} = selected_grommet_type;
                atlasViewer.probe.DetGrommetRot{end+1} = grommet_rot;
                atlasViewer.probe.optpos_reg = optpos_reg;
                atlasViewer.probe.detpos = [atlasViewer.probe.detpos; [0 0 0]];
                ndet = ndet+1;
                atlasViewer.probe.ndet = ndet;
                atlasViewer.probe.noptorig = atlasViewer.probe.noptorig+1;

                % add measurement list to new optode
                src_dist = sqrt(sum((optpos_reg(1:nrsc,:)-selected_point).^2,2));
                nearby_src = find(src_dist >= measurement_dist(1) & src_dist <= measurement_dist(2));
                MeasList = [];
                if isempty(lambda)
                    n_lambda = 1;
                else
                    n_lambda = length(lambda);
                end
                for u = 1:n_lambda
                    MeasList = [MeasList; nearby_src ones(size(nearby_src))*ndet ones(size(nearby_src)) ones(size(nearby_src))*u];
                end
                atlasViewer.probe.ml = [atlasViewer.probe.ml; MeasList];

                % add spring list to new optode
                sl = atlasViewer.probe.registration.sl;
                if ~isempty(sl)
                    idx = find(sl(:,1) >= nrsc+ndet);
                    sl(idx,1) = sl(idx,1)+1;
                    idx = find(sl(:,2) >= nrsc+ndet);
                    sl(idx,2) = sl(idx,2)+1;
                end
                opt_dist = sqrt(sum((optpos_reg-selected_point).^2,2));
                nearby_opt = find(opt_dist >= sprint_dist(1) & opt_dist <= sprint_dist(2));
                nearby_opt = setdiff(nearby_opt,nrsc+ndet);
                springList = [ones(size(nearby_opt))*(nrsc+ndet) nearby_opt opt_dist(nearby_opt)];
                sl = [sl; springList];
                atlasViewer.probe.registration.sl = sl;
                
                al = atlasViewer.probe.registration.al;
                for u = 1:size(al,1)
                    if al{u,1} >= nrsc+ndet
                        al{u,1} = al{u,1}+1;
                    end
                end
                atlasViewer.probe.registration.al = al;

                probe = displayProbe(atlasViewer.probe, atlasViewer.headsurf);
                atlasViewer.probe = probe;

            elseif strcmpi(selected_optode_type,'Dummy')
                atlasViewer.probe.optpos_reg = [atlasViewer.probe.optpos_reg; selected_point];
                atlasViewer.probe.registration.dummypos = [atlasViewer.probe.registration.dummypos; [0 0 0]];
                atlasViewer.probe.DummyGrommetType{end+1} = selected_grommet_type;
                atlasViewer.probe.DummyGrommetRot{end+1} = grommet_rot;
                opt_pos = size(atlasViewer.probe.optpos_reg,1);
                atlasViewer.probe.noptorig = atlasViewer.probe.noptorig+1;

                % add spring list to new probe
                opt_dist = sqrt(sum((optpos_reg-selected_point).^2,2));
                nearby_opt = find(opt_dist >= sprint_dist(1) & opt_dist <= sprint_dist(2));
                springList = [ones(size(nearby_opt))*(opt_pos) nearby_opt opt_dist(nearby_opt)];
                atlasViewer.probe.registration.sl = [atlasViewer.probe.registration.sl; springList];

                probe = displayProbe(atlasViewer.probe, atlasViewer.headsurf);
                atlasViewer.probe = probe;
            end
            if isProbeChanged(atlasViewer.probe_copy,atlasViewer.probe)
                set(handles.text_isProbeChanged,'String','Click Register Probe to Surface to save the probe');
            end
        elseif get(handles.radiobuttonRemoveOptodeAV,'Value')
            optpos_reg = atlasViewer.probe.optpos_reg;
            if isempty(optpos_reg)
                return
            end
            selected_point = eventdata.IntersectionPoint;
            if leftRightFlipped(atlasViewer.probe)
                temp_pt = selected_point(2);
                selected_point(2) = selected_point(1);
                selected_point(1) = temp_pt;
            end 
            ml = atlasViewer.probe.ml;
            sl = atlasViewer.probe.registration.sl;
            opt_dist = sqrt(sum((optpos_reg-selected_point).^2,2));
            [min_dist, idx] = min(opt_dist);
            if min_dist < 10
                nrsc = atlasViewer.probe.nsrc;
                ndet = atlasViewer.probe.ndet;
                if idx <= nrsc
                    opt_type = 'Source';
                    opt_no = idx;
                elseif idx <= nrsc+ndet
                    opt_type = 'Detector';
                    opt_no = idx-nrsc;
                else
                    opt_type = 'Dummy';
                    opt_no = idx-nrsc-ndet;
                end
                msg = ['Are you sure you want to delete ' opt_type ' optode ' num2str(opt_no) '?']; 
                answer = questdlg(msg, 'Delete Optode');
                if strcmp(answer,'Yes')
                    optpos_reg(idx,:) = [];
                    atlasViewer.probe.noptorig = atlasViewer.probe.noptorig-1;
                    if strcmp(opt_type,'Source')
                        atlasViewer.probe.nsrc = atlasViewer.probe.nsrc-1;
                        atlasViewer.probe.SrcGrommetType(opt_no) = [];
                        atlasViewer.probe.SrcGrommetRot(opt_no) = [];
                        atlasViewer.probe.srcpos(opt_no,:) = []; 
                        if ~isempty(ml)
                            optode_ml_idx = find(ml(:,1) == opt_no);
                            m_idx = find(ml(:,1) >= opt_no);
                            ml(m_idx,1) = ml(m_idx,1)-1;
                        else
                            optode_ml_idx = [];
                        end
                    elseif strcmp(opt_type,'Detector')
                        atlasViewer.probe.ndet = atlasViewer.probe.ndet-1;
                        atlasViewer.probe.DetGrommetType(opt_no) = [];
                        atlasViewer.probe.DetGrommetRot(opt_no) = [];
                        atlasViewer.probe.detpos(opt_no,:) = []; 
                        if ~isempty(ml)
                            optode_ml_idx = find(ml(:,2) == opt_no);
                            m_idx = find(ml(:,2) >= opt_no);
                            ml(m_idx,2) = ml(m_idx,2)-1;
                        else
                            optode_ml_idx = [];
                        end
                    elseif strcmp(opt_type,'Dummy')
                        optode_ml_idx = [];
                        atlasViewer.probe.DummyGrommetType(idx-nrsc-ndet) = [];
                        atlasViewer.probe.DummyGrommetRot(idx-nrsc-ndet) = [];
                        atlasViewer.probe.registration.dummypos(idx-nrsc-ndet,:) = [];
                    end  
                    if ~isempty(optode_ml_idx)
                        ml(optode_ml_idx,:) = [];
                    end
                    if ~isempty(sl)
                        optode_sl_idx = find(sl(:,1) == idx | sl(:,2) == idx);
                        if ~isempty(optode_sl_idx)
                            sl(optode_sl_idx,:) = [];
                        end

                        s_idx = find(sl(:,1) >= idx);
                        sl(s_idx,1) = sl(s_idx,1)-1;
                        s_idx = find(sl(:,2) >= idx);
                        sl(s_idx,2) = sl(s_idx,2)-1;
                    end
                    al = atlasViewer.probe.registration.al;
                    for u = 1:size(al,1)
                        if al{u,1} >= idx
                            al{u,1} = al{u,1}-1;
                        end
                    end
                    atlasViewer.probe.registration.al = al;
                    atlasViewer.probe.optpos_reg = optpos_reg ;
                    atlasViewer.probe.ml = ml;
                    atlasViewer.probe.registration.sl = sl;
                    probe = displayProbe(atlasViewer.probe, atlasViewer.headsurf);
                    atlasViewer.probe = probe;

                    if isProbeChanged(atlasViewer.probe_copy,atlasViewer.probe)
                        set(handles.text_isProbeChanged,'String','Click Register Probe to Surface to save the probe');
                    end
                end
            end
        elseif get(handles.radiobuttonEditOptodeAV,'Value')
            optpos_reg = atlasViewer.probe.optpos_reg;
            if isempty(optpos_reg)
                return
            end
            selected_point = eventdata.IntersectionPoint;
            if leftRightFlipped(atlasViewer.probe)
                temp_pt = selected_point(2);
                selected_point(2) = selected_point(1);
                selected_point(1) = temp_pt;
            end
%             ml = atlasViewer.probe.ml;
            al = atlasViewer.probe.registration.al;
%             [ml,ia,ic] = unique(ml(:,1:2),'rows');
%             sl = atlasViewer.probe.registration.sl;
            nrsc = atlasViewer.probe.nsrc;
            ndet = atlasViewer.probe.ndet;
            opt_dist = sqrt(sum((optpos_reg-selected_point).^2,2));
            [min_dist, idx] = min(opt_dist);
            optode_type_contents = cellstr(get(handles.popupmenuSelectOptodeType,'String'));
            grommet_type_contents = cellstr(get(handles.popupmenu_selectGrommetType,'String'));
            if ~isempty(al)
                al_idx = find(cellfun(@(x) x==idx,al(:,1)));
            else
                al_idx = [];
            end
            if min_dist < 10
                atlasViewer.probe.editOptodeInfo.currentOptode = idx;
                set(handles.popupmenuSelectOptodeType,'Enable','on');
                set(handles.popupmenu_selectGrommetType,'Enable','on');
                set(handles.edit_assignAnchorPt,'Enable','on');
                set(handles.edit_grommetRotation,'Enable','on');
%                 nrsc = atlasViewer.probe.nsrc;
%                 ndet = atlasViewer.probe.ndet;
                if idx <= nrsc
                    opt_type = 'Source';
                    opt_no = idx;
                    grommet_type = atlasViewer.probe.SrcGrommetType{opt_no};
                    grommet_rot = atlasViewer.probe.SrcGrommetRot{opt_no};
                elseif idx <= nrsc+ndet
                    opt_type = 'Detector';
                    opt_no = idx-nrsc;
                    grommet_type = atlasViewer.probe.DetGrommetType{opt_no};
                    grommet_rot = atlasViewer.probe.DetGrommetRot{opt_no};
                else
                    opt_type = 'Dummy';
                    opt_no = idx-nrsc;
                    grommet_type = atlasViewer.probe.DummyGrommetType{idx-nrsc-ndet};
                    grommet_rot = atlasViewer.probe.DummyGrommetRot{idx-nrsc-ndet};
                end
                optode_index = find(strcmp(optode_type_contents,opt_type));
                set(handles.popupmenuSelectOptodeType,'Value',optode_index);
                grommet_index = find(strcmp(grommet_type_contents,grommet_type));
                if isempty(grommet_index)
                    contents = cellstr(get(handles.popupmenu_selectGrommetType,'String'));
                    contents{end+1} = grommet_type;
                    set(handles.popupmenu_selectGrommetType,'String',contents);
                    grommet_index = length(contents);
                end
                set(handles.popupmenu_selectGrommetType,'Value',grommet_index);
                set(handles.edit_grommetRotation,'String',num2str(grommet_rot));
                if ~isempty(al_idx)
                    set(handles.edit_assignAnchorPt,'String',al{al_idx,2});
                else
                    set(handles.edit_assignAnchorPt,'String','none');
                end
                if get(handles.radiobutton_MeasListVisible,'Value')
                    ml = atlasViewer.probe.ml;
                    if ~isempty(ml)
                        [ml,ia,ic] = unique(ml(:,1:2),'rows');
                        sl = atlasViewer.probe.registration.sl;
                        if ~ get(handles.checkboxOptodeSDMode,'Value')
                            set(handles.checkboxOptodeSDMode,'Value',1.0)
                            checkboxOptodeSDMode_Callback(hObject, eventdata, handles)
                            set(handles.checkboxOptodeSDMode,'Enable','off')
                        end
                        if strcmp(opt_type,'Source')
                            m_idx = find(ml(:,1) ==  opt_no);
                        elseif strcmp(opt_type,'Detector')
                            m_idx = find(ml(:,2) ==  opt_no);
                        elseif strcmp(opt_type,'Dummy')
                            m_idx = [];
                        end
                        if ~isempty(m_idx)
                            data = cell(length(m_idx),3);
                            for u = 1:length(m_idx)
                                data{u,1} = ml(m_idx(u),1);
                                data{u,2} = ml(m_idx(u),2);
                                o1 = ml(m_idx(u),1);
                                o2 = ml(m_idx(u),2)+nrsc;
                                s_idx = find((sl(:,1) == o1 & sl(:,2) == o2) | (sl(:,1) == o2 & sl(:,2) == o1));
                                if ~isempty(s_idx)
                                    data{u,3} = sl(s_idx,3);
                                else
                                    data{u,3} = 0;
                                end
                            end
                        else
                            data = cell(3,3);
                            msgbox('This optode do not have any measurement list');
                        end
                        probe = displyMeasChannels_editOptode(atlasViewer.probe,ia(m_idx));
                        atlasViewer.probe = probe;
                    else
                        data = cell(3,3);
                        msgbox('Measurement list is empty');
                    end
                    set(handles.uipanel_EditOptode,'Visible','On')
                    set(handles.uipanel_EditOptode,'Units','normalized','Position',[0.77 0.45 0.2 0.465])
                    set(handles.uitable_editMLorSL,'Data',data)
                    set(handles.uitable_editMLorSL,'ColumnName',{'Source','Detector','Distance'})
                elseif get(handles.radiobutton_SpringListVisible,'Value')
                    sl = atlasViewer.probe.registration.sl;
                    if ~isempty(sl)
                        if get(handles.checkboxOptodeSDMode,'Value')
                            set(handles.checkboxOptodeSDMode,'Value',0.0)
                            checkboxOptodeSDMode_Callback(hObject, eventdata, handles)
                            set(handles.checkboxOptodeSDMode,'Enable','off')
                        end
                        s_idx = find(sl(:,1)==idx |sl(:,2)==idx);
                        if ~isempty(s_idx)
                            data = cell(length(s_idx),3);
                            for u = 1:length(s_idx)
                                data{u,1} = sl(s_idx(u),1);
                                data{u,2} = sl(s_idx(u),2);
                                data{u,3} = sl(s_idx(u),3);
                            end
                        else
                            data = cell(3,3);
                            msgbox('This optode do not have any spring list');
                        end
                        probe = displySprings_editOptode(atlasViewer.probe,s_idx);
                        atlasViewer.probe = probe;
                    else
                            data = cell(3,3);
                            msgbox('Spring list is empty');
                    end
                    set(handles.uipanel_EditOptode,'Visible','On')
                        set(handles.uipanel_EditOptode,'Units','normalized','Position',[0.77 0.45 0.2 0.465])
                        set(handles.uitable_editMLorSL,'Data',data)
                        set(handles.uitable_editMLorSL,'ColumnName',{'Optode1','Optode2','Distance'})
                end
                if isProbeChanged(atlasViewer.probe_copy,atlasViewer.probe)
                    set(handles.text_isProbeChanged,'String','Click Register Probe to Surface to save the probe');
                end
            end 
        end
    end
elseif eventdata.Button == 3
    if get(handles.checkbox_optodeEditMode,'Value')
        ml = atlasViewer.probe.ml;
    %     ml = unique(ml,'rows');
        sl = atlasViewer.probe.registration.sl;
        idx = atlasViewer.probe.editOptodeInfo.currentOptode;
        lambda = atlasViewer.probe.lambda;
        nrsc = atlasViewer.probe.nsrc;
        ndet = atlasViewer.probe.ndet;
        if idx <= nrsc
            opt_type = 'Source';
            opt_no = idx;
        elseif idx <= nrsc+ndet
            opt_type = 'Detector';
            opt_no = idx-nrsc;
        else
            opt_type = 'Dummy';
            opt_no = idx-nrsc;
        end
        
        selected_point = eventdata.IntersectionPoint;
        if leftRightFlipped(atlasViewer.probe)
                temp_pt = selected_point(2);
                selected_point(2) = selected_point(1);
                selected_point(1) = temp_pt;
        end
        optpos_reg = atlasViewer.probe.optpos_reg;
%         ml = atlasViewer.probe.ml;
%         sl = atlasViewer.probe.registration.sl;
        opt_dist = sqrt(sum((optpos_reg-selected_point).^2,2));
        [min_dist, target_idx] = min(opt_dist);
        if min_dist < 10
            if target_idx <= nrsc
                target_opt_type = 'Source';
                target_opt_no = target_idx;
            elseif target_idx <= nrsc+ndet
                target_opt_type = 'Detector';
                target_opt_no = target_idx-nrsc;
            else
                target_opt_type = 'Dummy';
                target_opt_no = target_idx-nrsc;
            end
            
            if get(handles.radiobutton_MeasListVisible,'Value')
                if strcmp(opt_type,'Dummy') || strcmp(target_opt_type,'Dummy')
                    msgbox('Can not make measurement list for Dummy optode');
                    return
                end
                if strcmp(opt_type,'Source')
                   if strcmp(target_opt_type,'Source')
                       return
                   end
                   opt_pair = [opt_no target_opt_no];
               elseif strcmp(opt_type,'Detector')
                   if strcmp(target_opt_type,'Detector')
                       return
                   end
                   opt_pair = [target_opt_no opt_no];
                end
                ml_idx = ismember(ml(:,1:2),opt_pair,'rows');
                if sum(ml_idx) >=1
                    atlasViewer.probe.ml = ml(~ml_idx,:);
                else
                    % add measurment list for new connection
                    MeasList = [];
                    for u = 1:length(lambda)
                         MeasList = [MeasList; [opt_pair 1 u]];
                    end
                    atlasViewer.probe.ml = [atlasViewer.probe.ml; MeasList];  
                    sl_idx1 = ismember(sl(:,1:2),[idx target_idx],'rows');
                    sl_idx2 = ismember(sl(:,1:2),[target_idx idx],'rows');
                    sl_idx = sl_idx1 | sl_idx2;
                    % add spring list for new connection
                    if sum(sl_idx) == 0
                        connection_dist = sqrt(sum((optpos_reg(idx,:)-optpos_reg(target_idx,:)).^2,2));
                        atlasViewer.probe.registration.sl = [atlasViewer.probe.registration.sl; [idx target_idx connection_dist]];
                    end 
                end
                radiobutton_MeasListVisible_Callback(hObject, eventdata, handles)
            elseif get(handles.radiobutton_SpringListVisible,'Value')
                sl_idx1 = ismember(sl(:,1:2),[idx target_idx],'rows');
                sl_idx2 = ismember(sl(:,1:2),[target_idx idx],'rows');
                sl_idx = sl_idx1 | sl_idx2;
                if sum(sl_idx) == 0
                    connection_dist = sqrt(sum((optpos_reg(idx,:)-optpos_reg(target_idx,:)).^2,2));
                    atlasViewer.probe.registration.sl = [atlasViewer.probe.registration.sl; [idx target_idx connection_dist]];
                else
                    atlasViewer.probe.registration.sl = sl(~sl_idx,:);
                    removed_sl = sl(sl_idx,1:2);
                    if removed_sl(1) > nrsc
                        removed_sl(1) = removed_sl(1)-nrsc;
                    end
                    if removed_sl(2) > nrsc
                        removed_sl(2) = removed_sl(2)-nrsc;
                    end
                    ml_idx1 = ismember(ml(:,1:2),removed_sl,'rows'); 
                    ml_idx2 = ismember(ml(:,1:2),[removed_sl(2) removed_sl(1)],'rows'); 
                    ml_idx = ml_idx1 | ml_idx2;
                    if sum(ml_idx) >=1
                        atlasViewer.probe.ml = ml(~ml_idx,:);
                    end
                end
                radiobutton_SpringListVisible_Callback(hObject, eventdata, handles)
            end
            if isProbeChanged(atlasViewer.probe_copy,atlasViewer.probe)
                set(handles.text_isProbeChanged,'String','Probe changed but not saved');
            end
        end
    end
end


% --- Executes on button press in radiobutton_SpringListVisible.
function radiobutton_SpringListVisible_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_SpringListVisible (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_SpringListVisible
global atlasViewer
set(handles.radiobutton_SpringListVisible,'Value',1.0)
set(handles.radiobutton_MeasListVisible,'Value',0.0)
set(handles.checkboxOptodeSDMode,'Value',0.0)
checkboxOptodeSDMode_Callback(hObject, eventdata, handles)
if get(handles.checkbox_displayAllOptodes,'Value')
    checkbox_displayAllOptodes_Callback(hObject, eventdata, handles)
else
    if isfield(atlasViewer.probe,'editOptodeInfo') & isfield( atlasViewer.probe.editOptodeInfo,'currentOptode')
        sl = atlasViewer.probe.registration.sl;
        idx = atlasViewer.probe.editOptodeInfo.currentOptode;
        if ~isempty(sl)
            s_idx = find(sl(:,1)==idx |sl(:,2)==idx);
            if ~isempty(s_idx)
                data = cell(length(s_idx),3);
                for u = 1:length(s_idx)
                    data{u,1} = sl(s_idx(u),1);
                    data{u,2} = sl(s_idx(u),2);
                    data{u,3} = sl(s_idx(u),3);
                end
            else
                data = cell(3,3);
                msgbox('This optode do not have any spring list');
            end
            set(handles.checkboxHideSprings,'Value',1.0)
            probe = displySprings_editOptode(atlasViewer.probe,s_idx);
            probe.hideSprings = 0;
            probe = setProbeDisplay(probe, atlasViewer.headsurf);
            atlasViewer.probe = probe;
        else
            data = cell(3,3);
            msgbox('Spring list is empty');
        end
        set(handles.uipanel_EditOptode,'Visible','On')
        set(handles.uipanel_EditOptode,'Units','normalized','Position',[0.77 0.45 0.2 0.465])
        set(handles.uitable_editMLorSL,'Data',data)
        set(handles.uitable_editMLorSL,'ColumnName',{'Optode1','Optode2','Distance'})
    end
    set(handles.checkboxOptodeSDMode,'Enable','off')
end

% --- Executes on button press in radiobutton_MeasListVisible.
function radiobutton_MeasListVisible_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_MeasListVisible (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_MeasListVisible
global atlasViewer
set(handles.radiobutton_SpringListVisible,'Value',0.0)
set(handles.radiobutton_MeasListVisible,'Value',1.0)
set(handles.checkboxOptodeSDMode,'Value',1.0)
checkboxOptodeSDMode_Callback(hObject, eventdata, handles)
if get(handles.checkbox_displayAllOptodes,'Value')
    checkbox_displayAllOptodes_Callback(hObject, eventdata, handles)
else
    if isfield(atlasViewer.probe,'editOptodeInfo') & isfield( atlasViewer.probe.editOptodeInfo,'currentOptode')
        ml = atlasViewer.probe.ml;
        if ~isempty(ml)
        [ml,ia,ic] = unique(ml(:,1:2),'rows');
        sl = atlasViewer.probe.registration.sl;
        idx = atlasViewer.probe.editOptodeInfo.currentOptode;

        nrsc = atlasViewer.probe.nsrc;
        ndet = atlasViewer.probe.ndet;
        if idx <= nrsc
            opt_type = 'Source';
            opt_no = idx;
        elseif idx <= nrsc+ndet
            opt_type = 'Detector';
            opt_no = idx-nrsc;
        else
            opt_type = 'Dummy';
            opt_no = idx-nrsc;
        end

        if strcmp(opt_type,'Source')
            m_idx = find(ml(:,1) ==  opt_no);
        elseif strcmp(opt_type,'Detector')
            m_idx = find(ml(:,2) ==  opt_no);
        elseif strcmp(opt_type,'Dummy')
            m_idx = [];
        end
        if ~isempty(m_idx)
            data = cell(length(m_idx),3);
            for u = 1:length(m_idx)
                data{u,1} = ml(m_idx(u),1);
                data{u,2} = ml(m_idx(u),2);
                o1 = ml(m_idx(u),1);
                o2 = ml(m_idx(u),2)+nrsc;
                s_idx = find((sl(:,1) == o1 & sl(:,2) == o2) | (sl(:,1) == o2 & sl(:,2) == o1));
                if ~isempty(s_idx)
                    data{u,3} = sl(s_idx,3);
                else
                    data{u,3} = 0;
                    msgbox('This optode do not have any measurement list');
                end
            end
        else
            data = cell(3,3);
        end
        set(handles.checkboxHideMeasList,'Value',1.0)
        probe = displyMeasChannels_editOptode(atlasViewer.probe,ia(m_idx));
        probe.hideMeasList = 0;
        probe = setProbeDisplay(probe, atlasViewer.headsurf);
        atlasViewer.probe = probe;
        else
            data = cell(3,3);
            msgbox('Measurement list is empty');
        end
        set(handles.uipanel_EditOptode,'Visible','On')
        set(handles.uipanel_EditOptode,'Units','normalized','Position',[0.77 0.45 0.2 0.465])
        set(handles.uitable_editMLorSL,'Data',data)
        set(handles.uitable_editMLorSL,'ColumnName',{'Source','Detector','Distance'})
    end
    set(handles.checkboxOptodeSDMode,'Enable','off')
end

% --- Executes when entered data in editable cell(s) in uitable_editMLorSL.
function uitable_editMLorSL_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable_editMLorSL (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

global atlasViewer
Indices = eventdata.Indices;
data = eventdata.Source.Data;
sl = atlasViewer.probe.registration.sl;
nrsc = atlasViewer.probe.nsrc;
if get(handles.radiobutton_MeasListVisible,'Value')  
    mPair = data(Indices(1),1:2);
    mPair{2} = mPair{2}+nrsc;
    sl_idx1 = ismember(sl(:,1:2),[mPair{1} mPair{2}],'rows');
    sl_idx2 = ismember(sl(:,1:2),[mPair{2} mPair{1}],'rows');
    sl_idx = sl_idx1 | sl_idx2;
    if sum(sl_idx) > 0
        atlasViewer.probe.registration.sl(sl_idx,3) = eventdata.NewData; 
    end
    radiobutton_MeasListVisible_Callback(hObject, eventdata, handles)
elseif get(handles.radiobutton_SpringListVisible,'Value')
    sPair = data(Indices(1),1:2);
    sl_idx = ismember(sl(:,1:2),[sPair{1} sPair{2}],'rows');
    if sum(sl_idx) > 0
        atlasViewer.probe.registration.sl(sl_idx,3) = eventdata.NewData; 
    end
    radiobutton_SpringListVisible_Callback(hObject, eventdata, handles)
end


% --- Executes on button press in checkbox_optodeEditMode.
function checkbox_optodeEditMode_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_optodeEditMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_optodeEditMode
global atlasViewer
if get(hObject,'Value')
    
%     probe =  atlasViewer.probe;
%     if isfield(probe.handles,'hMeasList_editOptode')
%         if ishandles(probe.handles.hMeasList_editOptode)
%             set(probe.handles.hMeasList_editOptode, 'buttondownfcn', {@optodeEditMode_btndwn,handles})
%         end
%     end
% 
%     if isfield(probe.handles,'hSprings_editOptode')
%         if ishandles(probe.handles.hSprings_editOptode)
%            set(probe.handles.hSprings_editOptode, 'buttondownfcn', {@optodeEditMode_btndwn,handles})
%         end
%     end
%     
%     set(probe.handles.labels, 'buttondownfcn', {@optodeEditMode_btndwn,handles})
end

function optodeEditMode_btndwn(hObject, eventdata, handles)

global atlasViewer
if strcmp(eventdata.Source.Type,'text')
    ml = atlasViewer.probe.ml;
%     ml = unique(ml,'rows');
    sl = atlasViewer.probe.registration.sl;
    idx = atlasViewer.probe.editOptodeInfo.currentOptode;
    lambda = atlasViewer.probe.lambda;
    nrsc = atlasViewer.probe.nsrc;
    ndet = atlasViewer.probe.ndet;
    if idx <= nrsc
        opt_type = 'Source';
        opt_no = idx;
    elseif idx <= nrsc+ndet
        opt_type = 'Detector';
        opt_no = idx-nrsc;
    else
        opt_type = 'Dummy';
        opt_no = idx-nrsc;
    end
    
   target_opt_no = str2num(eventdata.Source.String);
   
   if get(handles.radiobutton_MeasListVisible,'Value')
       target_opt_color = eventdata.Source.Color;
       if isequal(target_opt_color,[1,0,0])
           target_opt_type = 'Source';
       elseif isequal(target_opt_color,[0,0,1])
           target_opt_type = 'Detector';
       end
       
       if strcmp(opt_type,'Source')
           if strcmp(target_opt_type,'Source')
               return
           end
           opt_pair = [opt_no target_opt_no];
           if sum(ismember(ml(:,1:2),opt_pair,'rows')) >=1
               return
           end
           MeasList = [];
           for u = 1:length(lambda)
                MeasList = [MeasList; [opt_pair 1 u]];
           end
           atlasViewer.probe.ml = [atlasViewer.probe.ml; MeasList];
       elseif strcmp(opt_type,'Detector')
           if strcmp(target_opt_type,'Detector')
               return
           end
           opt_pair = [target_opt_no opt_no];
           if sum(ismember(ml(:,1:2),opt_pair,'rows')) >=1
               return
           end
           MeasList = [];
           for u = 1:length(lambda)
                MeasList = [MeasList; [opt_pair 1 u]];
           end
           atlasViewer.probe.ml = [atlasViewer.probe.ml; MeasList];
       end
       radiobutton_MeasListVisible_Callback(hObject, eventdata, handles)
   elseif get(radiobutton_SpringListVisible,'Value')
       
   end
    
end


% --- Executes on selection change in popupmenu_selectGrommetType.
function popupmenu_selectGrommetType_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_selectGrommetType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_selectGrommetType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_selectGrommetType
global atlasViewer
if get(handles.radiobuttonEditOptodeAV,'Value')
    contents = cellstr(get(hObject,'String'));
    choices = GetGrommetChoices();
    if ~isempty(setdiff(choices,contents))
        set(hObject,'String',choices);
    end
    grommet_type =   contents{get(hObject,'Value')};
    if isfield(atlasViewer.probe,'editOptodeInfo') && isfield( atlasViewer.probe.editOptodeInfo,'currentOptode')
        idx = atlasViewer.probe.editOptodeInfo.currentOptode;
        nrsc = atlasViewer.probe.nsrc;
        ndet = atlasViewer.probe.ndet;
        if idx <= nrsc
            opt_no = idx;
            atlasViewer.probe.SrcGrommetType{opt_no} = grommet_type;
        elseif idx <= nrsc+ndet
            opt_no = idx-nrsc;
            atlasViewer.probe.DetGrommetType{opt_no} = grommet_type;
        else
            opt_no = idx-nrsc-ndet;
            atlasViewer.probe.DummyGrommetType{opt_no} = grommet_type;
        end
        if isProbeChanged(atlasViewer.probe_copy,atlasViewer.probe)
            set(handles.text_isProbeChanged,'String','Click Register Probe to Surface to save the probe');
        end
    end  
end

% --- Executes during object creation, after setting all properties.
function popupmenu_selectGrommetType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_selectGrommetType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
choices = GetGrommetChoices();
set(hObject,'String',choices);



function edit_assignAnchorPt_Callback(hObject, eventdata, handles)
% hObject    handle to edit_assignAnchorPt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_assignAnchorPt as text
%        str2double(get(hObject,'String')) returns contents of edit_assignAnchorPt as a double

global atlasViewer

if get(handles.radiobuttonEditOptodeAV,'Value')
    if isfield(atlasViewer.probe,'editOptodeInfo') && isfield( atlasViewer.probe.editOptodeInfo,'currentOptode')
        Anchor_pt = get(hObject,'String');
        optode_idx = atlasViewer.probe.editOptodeInfo.currentOptode;
        al = atlasViewer.probe.registration.al;
        if ~isempty(al)
            al_idx = find(cellfun(@(x) x==optode_idx,al(:,1)));
        else
            al_idx = [];
        end
        if strcmpi(Anchor_pt,'none')
            if ~isempty(al_idx)
                al(al_idx,:) = [];
            end
        else
            refPts = atlasViewer.refpts.labels;
            anchorpt_idx = find(strcmpi(refPts,Anchor_pt));
            if ~isempty(anchorpt_idx)
                if isempty(al_idx)
                    al{end+1,1} = optode_idx;
                    al{end,2} = Anchor_pt;
                else
                    al{al_idx,2} = Anchor_pt;
                end
            else
                f = msgbox('Refernce point you entered does not exist');
            end
        end
        atlasViewer.probe.registration.al = al;
        if isProbeChanged(atlasViewer.probe_copy,atlasViewer.probe)
            set(handles.text_isProbeChanged,'String','Click Register Probe to Surface to save the probe');
        end
    end
end

% --- Executes during object creation, after setting all properties.
function edit_assignAnchorPt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_assignAnchorPt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_grommetRotation_Callback(hObject, eventdata, handles)
% hObject    handle to edit_grommetRotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_grommetRotation as text
%        str2double(get(hObject,'String')) returns contents of edit_grommetRotation as a double
global atlasViewer
if get(handles.radiobuttonEditOptodeAV,'Value')
    grommet_rot = str2double(get(hObject, 'String'));
    if isfield(atlasViewer.probe,'editOptodeInfo') && isfield( atlasViewer.probe.editOptodeInfo,'currentOptode')
        idx = atlasViewer.probe.editOptodeInfo.currentOptode;
        nrsc = atlasViewer.probe.nsrc;
        ndet = atlasViewer.probe.ndet;
        if idx <= nrsc
            opt_no = idx;
            atlasViewer.probe.SrcGrommetRot{opt_no} = grommet_rot;
        elseif idx <= nrsc+ndet
            opt_no = idx-nrsc;
            atlasViewer.probe.DetGrommetRot{opt_no} = grommet_rot;
        else
            opt_no = idx-nrsc-ndet;
            atlasViewer.probe.DummyGrommetRot{opt_no} = grommet_rot;
        end
        if isProbeChanged(atlasViewer.probe_copy,atlasViewer.probe)
            set(handles.text_isProbeChanged,'String','Click Register Probe to Surface to save the probe');
        end
    end  
end

% --- Executes during object creation, after setting all properties.
function edit_grommetRotation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_grommetRotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text_isProbeChanged_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_isProbeChanged (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String','');



function edit_Lamdbas_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Lamdbas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Lamdbas as text
%        str2double(get(hObject,'String')) returns contents of edit_Lamdbas as a double
global atlasViewer
lambdas = str2num(get(hObject, 'string'));

if isempty(lambdas)
    set(handles.edit_Lamdbas,'String',num2str(atlasViewer.probe.lambda));
    msgbox('Please enter atleast one wavelenth value to update wavelengths');
    return
end

% if lengths are same then we don't need to update measurement list
if length(atlasViewer.probe.lambda) == length(lambdas)
    atlasViewer.probe.lambda = lambdas;
    return
end

atlasViewer.probe.lambda = lambdas;
if ~isempty(atlasViewer.probe.ml)
    ml = atlasViewer.probe.ml;
    ml_unique_list = unique(ml(:,1:2),'rows','stable');
    new_ml = [];
    ml_unique_list_length = size(ml_unique_list,1);
    for u= 1:length(lambdas)
        new_ml = [new_ml; [ml_unique_list ones(ml_unique_list_length,1) u*ones(ml_unique_list_length,1)]];
    end
    atlasViewer.probe.ml = new_ml;
end


% --- Executes during object creation, after setting all properties.
function edit_Lamdbas_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Lamdbas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Lambda2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Lambda2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Lambda2 as text
%        str2double(get(hObject,'String')) returns contents of edit_Lambda2 as a double


% --- Executes during object creation, after setting all properties.
function edit_Lambda2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Lambda2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Lambda3_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Lambda3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Lambda3 as text
%        str2double(get(hObject,'String')) returns contents of edit_Lambda3 as a double


% --- Executes during object creation, after setting all properties.
function edit_Lambda3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Lambda3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in checkbox_displayAllOptodes.
function checkbox_displayAllOptodes_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_displayAllOptodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_displayAllOptodes
global atlasViewer
if get(handles.checkbox_displayAllOptodes,'Value')
    if get(handles.radiobutton_SpringListVisible,'Value')
        data = atlasViewer.probe.registration.sl; 
        set(handles.radiobutton_SpringListVisible,'Value',1.0)
        set(handles.radiobutton_MeasListVisible,'Value',0.0)
        set(handles.checkboxOptodeSDMode,'Value',0.0)
        checkboxOptodeSDMode_Callback(hObject, eventdata, handles)
        col1_name = 'Optode1';
        col2_name = 'Optode2';
        set(handles.checkboxHideSprings,'Value',0.0)
        probe = atlasViewer.probe;
        probe.hideSprings = 1;
        probe = displaySprings(probe);
        probe = setProbeDisplay(probe,atlasViewer.headsurf);
        atlasViewer.probe = probe;
    elseif get(handles.radiobutton_MeasListVisible,'Value')
        nrsc = atlasViewer.probe.nsrc;
        ml = atlasViewer.probe.ml;
        col1_name = 'Source';
        col2_name = 'Detector';
        if ~isempty(ml)
            sl = atlasViewer.probe.registration.sl;
            [data,ia,ic] = unique(ml(:,1:3),'rows');
            data(:,3) = data(:,3)*0;
            data(:,2) = data(:,2)+nrsc;
            [Lia1, Locb1] = ismember(data(:,1:2),sl(:,1:2),'rows');
            [Lia2, Locb2] = ismember([data(:,2) data(:,1)],sl(:,1:2),'rows');
            Lia = Lia1 | Lia2;
            Locb = Locb1+Locb2;
            idx = find(Lia == 1);
            data(idx,3) = sl(Locb(idx),3);
            data(:,2) = data(:,2)-nrsc;
            set(handles.radiobutton_SpringListVisible,'Value',0.0)
            set(handles.radiobutton_MeasListVisible,'Value',1.0)
            set(handles.checkboxOptodeSDMode,'Value',1.0)
            checkboxOptodeSDMode_Callback(hObject, eventdata, handles)
            probe = atlasViewer.probe;
            probe.hideMeasList = 1;
            set(handles.checkboxHideMeasList,'Value',0.0)
            probe = drawMeasChannels(probe);
            probe = setProbeDisplay(probe, atlasViewer.headsurf);
            atlasViewer.probe = probe;
        else
            data = [];
        end
    end
    set(handles.uipanel_EditOptode,'Visible','On')
    set(handles.uipanel_EditOptode,'Units','normalized','Position',[0.77 0.45 0.2 0.465])
    set(handles.uitable_editMLorSL,'Data',num2cell(data))
    set(handles.uitable_editMLorSL,'ColumnName',{col1_name,col2_name,'Distance'})
    if isfield(atlasViewer.probe.handles,'hSprings_editOptode')
        if ishandles(atlasViewer.probe.handles.hSprings_editOptode)
            delete(atlasViewer.probe.handles.hSprings_editOptode);
        end
    end

    if isfield(atlasViewer.probe.handles,'hMeasList_editOptode')
        if ishandles(atlasViewer.probe.handles.hMeasList_editOptode)
            delete(atlasViewer.probe.handles.hMeasList_editOptode);
        end
    end
else
    if get(handles.radiobutton_SpringListVisible,'Value')
        radiobutton_SpringListVisible_Callback(hObject, eventdata, handles)
    elseif get(handles.radiobutton_MeasListVisible,'Value')
        radiobutton_MeasListVisible_Callback(hObject, eventdata, handles)
    end
end

