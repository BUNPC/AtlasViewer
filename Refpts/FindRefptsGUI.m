function varargout = FindRefptsGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FindRefptsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @FindRefptsGUI_OutputFcn, ...
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


% --------------------------------------------------------------------
function FindRefptsGUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for FindRefptsGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

set(hObject','color',[.20, .20, .20]);
%%%% menuItemFindRefpts %%%%

global atlasViewer

axesv = atlasViewer.axesv;
fs2viewer = atlasViewer.fs2viewer;
headsurf = atlasViewer.headsurf;
headvol = atlasViewer.headvol;
refpts = atlasViewer.refpts;

if length(axesv)==2
    if ishandles(axesv(2).handles.axesSurfDisplay)
        return;
    end
end

% Get 3-letter orientation of volume
o = {'',''};
if ~isempty(headsurf.orientation)
    o{1} = headsurf.orientation;
    o{2} = getOrientationCompl(o{1});
elseif ~isempty(fs2viewer.hseg.orientation)
    o{1} = fs2viewer.hseg.orientation;
    o{2} = getOrientationCompl(o{1});
end

set(handles.axesSurfDisplay, {'xlimmode','ylimmode','zlimmode'}, {'manual','manual','manual'});
set(handles.axesSurfDisplay,'xlim')
set(handles.axesSurfDisplay,'units','normalized','position',[.25, .35, .70, .65 ]);

% Panel position
xpos_p = .02;
          
%%%% Display Save panel

% Button positions 
xpos_b = .05; 
ypos_b = .85;
ypos_b_decr = .15;

% Button size 
xsize_b = .90;  
ysize_b = .10;

ii=0;

colBttnUnselPt = [.80, .30, .20; .95, .95, .10];
colBttnSelPt   = [.20, .80, .10; 1.00, 1.00, .00];
          
handles.pushbuttonStandardViewsAnterior=[];
handles.pushbuttonStandardViewsPosterior=[];
handles.pushbuttonStandardViewsRight=[];
handles.pushbuttonStandardViewsLeft=[];
handles.pushbuttonStandardViewsSuperior=[];
handles.pushbuttonStandardViewsInferior=[];
handles.editViewAnglesAzimuth=[];
handles.editViewAnglesElevation=[];

handles.menuItemLight1=[];
handles.menuItemLight2=[];
handles.menuItemLight3=[];
handles.menuItemLight4=[];
handles.menuItemLight5=[];
handles.menuItemLight6=[];
handles.menuItemLight7=[];
handles.menuItemLight8=[];

setappdata(hObject, 'handles',handles);
setappdata(hObject, 'colBttnUnselPt',colBttnUnselPt);
setappdata(hObject, 'colBttnSelPt',colBttnSelPt);

axesv(2) = initAxesv(handles,1);

headsurf_savehandles(1) = headsurf.handles.surf;
headsurf.handles.surf=[];

% This code is a workaround for a MATLAB bug introduced in version R2014b (8.4)
% and fixed (mostly fixed) in R2016a (9.0.1)
matlabVerNewGraphics = '8.4';
if verLessThan('matlab','9.0') & verGreaterThanOrEqual('matlab', matlabVerNewGraphics)
    MenuBox(sprintf(['Please NOTE that "Find Reference Points" uses a MATLAB graphics feature which has\n', ...
        'a Matlab bug in versions R2014b (8.4) - R2015b (8.6). The bug occasionally causes the \n', ...
        'the datacursor to attach to vertices on the the hidden side of the graphics object instead\n', ...
        'of the one selected. This can be detected by observing how the black square data cursor moves\n', ...
        'when rotating the head. If the datacursor moves ''with'' the rotating head then it attahed correstly\n', ...
        'If the datacursor moves in the opposite direction then it attahed to the hidden side of the head and\n', ...
        'the vertex should be reselected.                                                                  \n\n', ...
        'Please Note: This issue was fixed in R2016a (9.0). Also this issue doesn''t exist in versions prior\n', ...
        'to R2014b (8.4), for example R2013b. Consider using an altrnative Matlab release...                ']), 'OK');
    q = MenuBox(sprintf(['Normally Matlab''s patch rendering would be used to draw the head surface. As a workaround to the\n', ...
        'previously described bug, choose an alternative (to patch) rendering that works best for you.\n']), {'Point Cloud','Surf Mesh'});
    if q==1
        headvol = displayHeadvol(headvol, handles.axesSurfDisplay);
    else
        % Display head surface using matlab's surf rather than patch to
        % avoid bug describes in the menu note above.
        headsurf = displayHeadsurf(headsurf, handles.axesSurfDisplay, 'surf');
    end
else
    headsurf = displayHeadsurf(headsurf, handles.axesSurfDisplay);
    set(headsurf.handles.surf,'facealpha',.8);
    if verGreaterThanOrEqual('matlab',matlabVerNewGraphics)
        set(headsurf.handles.surf, 'pickableparts','visible','facealpha',1.0);
    end
end

axesv(2) = displayAxesv(axesv(2), headsurf, headvol, initDigpts());

refpts.handles.selected = zeros(length(refpts.labels),1)-1;

% Before user starts picking points display the location of any existing
% landmarks.
if leftRightFlipped(headsurf)
    axes_order=[2 1 3];
else
    axes_order=[1 2 3];
end

[~,~,~,~,~,r] = getLandmarks(refpts);
if ~isempty(r.pos)
    headsurf.currentPt = [r.pos(:,axes_order(1)), r.pos(:,axes_order(2)), r.pos(:,axes_order(3))];
    refpts = updateRefpts(refpts, headsurf, r.labels, axesv(2).handles.axesSurfDisplay);
end

% Display orientation coordinates
if ~isempty(o{1}) & ~isempty(o{2})
    [~, m] = gen_bbox(headsurf.mesh.vertices, 40);
    for ii=1:3
        if o{1}(ii) == 'L' | o{1}(ii) == 'R'
            % line([m(ii*2-1,axes_order(1)),m(ii*2,axes_order(1))], [m(ii*2-1,axes_order(2)),m(ii*2,axes_order(2))], [m(ii*2-1,axes_order(3)),m(ii*2,axes_order(3))], 'color','y', 'linewidth',1);
            text(m(ii*2,axes_order(1)), m(ii*2,axes_order(2)), m(ii*2,axes_order(3)), o{1}(ii), 'color','r');
            text(m(ii*2-1,axes_order(1)), m(ii*2-1,axes_order(2)), m(ii*2-1,axes_order(3)), o{2}(ii), 'color','r');
        end
    end
end

updateSelectBttns(refpts);

headsurf.handles.surf = headsurf_savehandles(1);
headsurf.currentPt = [];

% Save objects 
atlasViewer.refpts = refpts;
atlasViewer.axesv = axesv;
atlasViewer.headsurf = headsurf;

hd = datacursormode(hObject);
set(hd,'UpdateFcn',@headsurfUpdateFcn,'SnapToDataVertex','off', 'DisplayStyle','window');
datacursormode on



% --------------------------------------------------------------------
function FindRefptsGUI_OutputFcn(hObject, eventdata, handles)



% --------------------------------------------------------------------
function pushbuttonSaveRefpts_Callback(hObject, eventdata, handles)
global atlasViewer;

refpts       = atlasViewer.refpts;
headsurf     = atlasViewer.headsurf;
headvol      = atlasViewer.headvol;
pialsurf     = atlasViewer.pialsurf;
labelssurf   = atlasViewer.labelssurf;
axesv        = atlasViewer.axesv;
digpts       = atlasViewer.digpts;
fwmodel      = atlasViewer.fwmodel;
imgrecon     = atlasViewer.imgrecon;
hbconc       = atlasViewer.hbconc;
probe        = atlasViewer.probe;

dirnameSubj  = atlasViewer.dirnameSubj;

cmd = get(hObject,'String');

if strcmpi(cmd, 'DONE')
    
    if all(refpts.handles.selected(:)==-1)
        return;
    end
    
	% Ref points might not exist at all yet in which case the 
    % pathname would not be set. So now that we have ref points 
    % in memory set the refpts pathname to subject folder
    if isempty(refpts.pathname)
        refpts.pathname = dirnameSubj;
    end
    
    % Set the eeg_system.curves to the newly found points. 
    % Thsi has to be done before saveRefpts other wise the refpts.pos 
    % and refpts.labels will be made empty
    refpts = init_eeg_pos(refpts);
    refpts = getRefpts(refpts, dirnameSubj);
    refpts = displayRefpts(refpts, atlasViewer.axesv(1).handles.axesSurfDisplay );    
    
    if length(axesv)>1
        if ishandles(axesv(2).handles.axesSurfDisplay)
            ha = get(axesv(2).handles.axesSurfDisplay,'parent');
            delete(ha);
            axesv(2) = [];
        end
    end
    
    if ~refpts.isempty(refpts)
        [headvol, headsurf, pialsurf, labelssurf, probe, fwmodel, imgrecon, hbconc] = ...
            setOrientationRefpts(refpts, headvol, headsurf, pialsurf, labelssurf, probe, fwmodel, imgrecon, hbconc);
        
        refpts     = displayRefpts(refpts);
        headsurf   = displayHeadsurf(headsurf);
        pialsurf   = displayPialsurf(pialsurf);
        labelssurf = displayLabelssurf(labelssurf);
        fwmodel    = displaySensitivity(fwmodel, pialsurf, labelssurf, probe);
        imgrecon   = displayImgRecon(imgrecon, fwmodel, pialsurf, labelssurf, probe);
        hbconc     = displayHbConc(hbconc, pialsurf, probe, fwmodel, imgrecon);
        digpts     = displayDigpts(digpts);
        probe      = displayProbe(probe, headsurf);
        axesv      = displayAxesv(axesv, headsurf, headvol, digpts);
        
    end
    
    % Enable ref points display
    set(refpts.handles.radiobuttonShowRefptsLabels, 'enable', 'on');
    set(refpts.handles.radiobuttonShowRefptsLabels, 'value', 1);
    radiobuttonShowRefpts(refpts.handles.radiobuttonShowRefptsLabels, refpts);
    
    % Ask user if they want to calculate 10-20/10-10/10-5 reference points
    if length(refpts.labels)>=5
        set(refpts.handles.menuItemShowRefpts,'enable','on');
        if ~isempty(digpts.refpts.pos)
            set(digpts.handles.menuItemRegisterAtlasToDigpts,'enable','on');
        end
        q = MenuBox('Calculate EEG reference points?', {'OK','Cancel'});
        if q == 1
            [refpts, err]  = calcRefpts(refpts, headvol);
            if err==-1
                [refpts, err]  = calcRefpts(refpts, headsurf);
                if err==-1
                    msg{1} = sprintf('The head surface and/or volume of this subject does not have enough vertices to\n');
                    msg{2} = sprintf('calculate the eeg reference points. Need a denser surface mesh for this subject...');
                    MenuBox(msg,'OK');
                    return;
                end
            end
            refpts = displayRefpts(refpts);
        end
        saveRefpts(refpts, headvol.T_2mc, 'overwrite');
    else
        set(refpts.handles.menuItemShowRefpts,'enable','off');
    end
   
else
    
    idx = find(cmd==' ')+1;
    labels{1} = cmd(idx:end);
    [refpts, currentPt] = updateRefpts(refpts, headsurf, labels, atlasViewer.axesv(2).handles.axesSurfDisplay);
    if isempty(currentPt)
        MenuBox('Warning: Selection made without data cursor head location','OK');
        return;
    end
    fprintf('%s: %s\n', labels{1}, num2str(currentPt));
    
end

atlasViewer.refpts      = refpts;
atlasViewer.headsurf    = headsurf;
atlasViewer.pialsurf    = pialsurf;
atlasViewer.labelssurf  = labelssurf;
atlasViewer.digpts      = digpts;
atlasViewer.probe       = probe;
atlasViewer.fwmodel     = fwmodel;
atlasViewer.imgrecon    = imgrecon;
atlasViewer.hbconc      = hbconc;
atlasViewer.axesv       = axesv;



% ---------------------------------------------------------------------
function txt = headsurfUpdateFcn(o,e)
global atlasViewer;

% Instead of getting position with "p = get(e,'position')", we get it 
% from with "p = e.Position". The former isn't compatible with matlab
% version beyond 2014a. 
p = e.Position;
atlasViewer.headsurf.currentPt = p;
txt = sprintf('%0.1f, %0.1f, %0.1f', p(1), p(2), p(3));




% --------------------------------------------------------------------
function findRefptsGUI_DeleteFcn(hObject, eventdata, handles)
global atlasViewer
atlasViewer.axesv(2).handles.axesSurfDisplay=-1;
atlasViewer.refpts.handles.selected(:)=-1;

