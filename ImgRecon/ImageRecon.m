function varargout = ImageRecon(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ImageRecon_OpeningFcn, ...
    'gui_OutputFcn',  @ImageRecon_OutputFcn, ...
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


% ---------------------------------------------------------------------------------
function err = UpdateGuiControls(handles)
global atlasViewer

err = -1;
if isempty(atlasViewer.dataTree)
    return;
end
currElem  = atlasViewer.dataTree.currElem;

% Display list of subject name
set(handles.ListofSubjects, 'String',currElem.GetName);

% default exp condition
set(handles.Condition, 'String',1);

% default time range
set(handles.time_range, 'String',num2str([5 10]));

% default alpha (regularization) for brain only reconstruction
set(handles.alpha_brainonly, 'String',1e-2);

% default alpha (regularization) for brain and scalp reconstruction
set(handles.alpha_brain_scalp, 'String',1e-2);

% default beta (regularization) for brain and scalp reconstruction
set(handles.beta_brain_scalp, 'String',1e-2);

err = 0;


% ---------------------------------------------------------------------------------
function ImageRecon_OpeningFcn(hObject, ~, handles, varargin)
% This function executes just before ImageRecon is made visible.

global atlasViewer

% Choose default command line output for ImageRecon
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

atlasViewer.imgrecon.handles.ImageRecon = hObject;

UpdateGuiControls(handles);



% -----------------------------------------------------------------------------
function varargout = ImageRecon_OutputFcn(~, ~, handles)
if isempty(handles)
    varargout{1} = [];
else
    varargout{1} = handles.output;
end



% -----------------------------------------------------------------------------
function ListofSubjects_Callback(hObject, eventdata, handles, cond)
s = set(handles.ListofSubjects, 'Value');



% -----------------------------------------------------------------------------
function ListofSubjects_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% -----------------------------------------------------------------------------
function Condition_Callback(hObject, eventdata, handles)
cond = get(handles.Condition, 'String');


% -----------------------------------------------------------------------------
function Condition_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% -----------------------------------------------------------------------------
function time_range_Callback(hObject, eventdata, handles)
tRangeimg = str2num(get(handles.time_range,'String'));


% -----------------------------------------------------------------------------
function time_range_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% -----------------------------------------------------------------------------
function shortsep_thresh_Callback(hObject, eventdata, handles)
rhoSD_ssThresh = str2num(get(handles.shortsep_thresh,'String'));


% -----------------------------------------------------------------------------
function shortsep_thresh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% -----------------------------------------------------------------------------
function brainonly_Callback(hObject, eventdata, handles)
value1 = get(handles.brainonly, 'Value');
if value1==1
    set(handles.brain_scalp, 'value', 0);
end



% -----------------------------------------------------------------------------
function brain_scalp_Callback(hObject, eventdata, handles)
value2 = get(handles.brain_scalp, 'Value');
if value2==1
    set(handles.brainonly, 'value', 0);
end


% -----------------------------------------------------------------------------
function alpha_brainonly_Callback(hObject, eventdata, handles)
alpha = str2num(get(handles.alpha_brainonly,'String'));


% -----------------------------------------------------------------------------
function alpha_brainonly_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% -----------------------------------------------------------------------------
function alpha_brain_scalp_Callback(hObject, eventdata, handles)
alpha = str2num(get(handles.alpha_brain_scalp,'String'));


% -----------------------------------------------------------------------------
function alpha_brain_scalp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% -----------------------------------------------------------------------------
function beta_brain_scalp_Callback(hObject, eventdata, handles)
beta = str2num(get(handles.beta_brain_scalp,'String'));


% -----------------------------------------------------------------------------
function beta_brain_scalp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% -----------------------------------------------------------------------------
function plotylimit_Callback(hObject, eventdata, handles)
ylimits = str2num(get(handles.plotylimit,'String'));


% -----------------------------------------------------------------------------
function plotylimit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% -----------------------------------------------------------------------------
function image_recon_Callback(~, ~, handles)
global atlasViewer

value1 = get(handles.brainonly, 'Value'); % 1 if brain only checked
value2 = get(handles.brain_scalp, 'Value'); % 1 if brain and scalp checked
cond = str2num(get(handles.Condition, 'String'));
s = get(handles.ListofSubjects, 'Value');
tRangeimg = str2num(get(handles.time_range,'String'));
rhoSD_ssThresh = str2num(get(handles.shortsep_thresh,'String'));

err = UpdateGuiControls(handles);
if err<0
    MessageBox('Error: data is missing ... existing image reconstruction GUI');
    return
end

dirnameSubj = atlasViewer.dirnameSubj;
imgrecon = atlasViewer.imgrecon;
fwmodel = atlasViewer.fwmodel;
probe = atlasViewer.probe;
dataTree = atlasViewer.dataTree;

dataTree.currElem.Load();

Adot        = fwmodel.Adot;
Adot_scalp  = fwmodel.Adot_scalp;

% Error checking
if  value1 == 0 & value2 == 0 %#ok<*AND2>
    msg = sprintf('Please choose one image reconstruction option.');
    menu(msg,'OK');
    return;
end
if  value1 == 1 & value2 == 1
    msg = sprintf('Please choose one image reconstruction option ONLY.');
    menu(msg,'OK');
    return;
end
if value1 == 1 & isempty(Adot)
    menu('You need the file fw/Adot.mat to perform this image reconstruction.','Okay');
    return;
end
if value1 == 1 & ndims(Adot) < 3 %#ok<*ISMAT>
    menu('You need at least two wavelengths for image reconstruction.','Okay');
    return;
end
if value2 == 1 & isempty(Adot_scalp)
    menu('You need the file fw/Adot_scalp.mat to perform this image reconstruction.','Okay');
    return;
end
if value2 == 1 & ndims(Adot_scalp) < 3
    menu('You need at least two wavelengths for image reconstruction.','Okay');
    return;
end

%%%% Get probe data 
SD   = convertProbe2SD(probe);

% Get fnirs time course data
dc   = dataTree.currElem.GetDcAvg();
tHRF = dataTree.currElem.GetTHRF();

% Error checking of subject data itself
if isempty(tHRF)
    menu('Error: tHRF is missing from subject data. Check groupResults.mat use Homer3 to generate new groupResults.mat file','Okay');
    return;
end
if isempty(dc)
    menu('Error: dcAvg is missing from subject data. Check groupResults.mat or use Homer3 to generate new groupResults.mat file','Okay');
    return;
end
if cond<1 | cond>size(dc, 4)
    menu('Invalid condition for this time course.','Okay');
    return;
end
if cond<1 | cond>size(dc, 4)
    menu('Invalid condition for this time course.','Okay');
    return;
end
if tRangeimg(1)<tHRF(1) | tRangeimg(1)>tHRF(end) | tRangeimg(2)<tHRF(1) | tRangeimg(2)>tHRF(end)
    menu(sprintf('Invalid time rage entered. Enter values between tHRF range [%0.1f - %0.1f].', tHRF(1), tHRF(end)), 'OK');
    return;
end

h = waitbar(0,'Please wait, running...');

% use only active channels
ml = SD.MeasList;
if isfield(SD, 'MeasListAct') == 1
    activeChLst = find(ml(:,4)==1 & SD.MeasListAct==1);
    dc = dc(:,:,activeChLst,:); % Homer assumes that MeasList is ordered first wavelength and then second, otherwise this breaks
end

dc(find(isnan(dc))) = 0;

% get dod conversion for each cond, if more than one condition
if ndims(dc) == 4
    for icond = 1:size(dc,4)
        dod(:,:,icond) = hmrConc2OD( squeeze(dc(:,:,:,icond)), SD, [6 6] );
    end
end

% average HRF over a time range
yavgimg = hmrImageHrfMeanTwin(dod, tHRF, tRangeimg);

% get long separation channels only for reconstruction
lst = find(ml(:,4)==1 & SD.MeasListAct==1);
rhoSD = zeros(length(lst),1);
posM = zeros(length(lst),3);
for iML = 1:length(lst)
    rhoSD(iML) = sum((SD.SrcPos(ml(lst(iML),1),:) - SD.DetPos(ml(lst(iML),2),:)).^2).^0.5;
    posM(iML,:) = (SD.SrcPos(ml(lst(iML),1),:) + SD.DetPos(ml(lst(iML),2),:)) / 2;
end
longSepChLst = lst(find(rhoSD>=rhoSD_ssThresh));
lstLS_all = [longSepChLst; longSepChLst+size(ml,1)/2]; % both wavelengths

if isempty(lstLS_all)
    menu(sprintf('All channels meet short separation threshold.\nYou need some long separation channels for image recon.\nPlease lower the threshold and retry.'), 'Okay');
    return;
end

yavgimg = yavgimg(lstLS_all,:);
SD.MeasList = SD.MeasList(lstLS_all,:);

if ~exist([dirnameSubj, '/imagerecon/'],'dir')
    mkdir([dirnameSubj, '/imagerecon']);
end

if value1 == 1 % brain only reconstruction after short separation regression
    
    Adot = Adot(activeChLst,:,:);
    Adot = Adot(longSepChLst,:,:);
    
    % put A matrix together and combine with extinction coefficients
    E = GetExtinctions([SD.Lambda(1) SD.Lambda(2)]);
    E = E/10; %convert from /cm to /mm  E raws: wavelength, columns 1:HbO, 2:HbR
    Amatrix = [squeeze(Adot(:,:,1))*E(1,1) squeeze(Adot(:,:,1))*E(1,2);
        squeeze(Adot(:,:,2))*E(2,1) squeeze(Adot(:,:,2))*E(2,2)];
    
    
    alpha = str2num(get(handles.alpha_brainonly,'String'));
    [HbO, HbR, err] = hmrImageReconConc(yavgimg, [], alpha, Amatrix);
    if err==1
        menu('Error: Number of channels in measuremnt is not the same as in Adot.', 'Okay');
        return;
    end
    
    if size(cond,2) == 1  % if single condition is chosen
        imgrecon.Aimg_conc.HbO = HbO(:,cond);
        imgrecon.Aimg_conc.HbR = HbR(:,cond);
    else                  % if constrast vector is provided
        fooHbO = zeros(size(HbO,1),1);
        fooHbR = zeros(size(HbR,1),1);
        for jcond = 1:size(cond,2) % now this is looping along the contrast vector
            fooHbO = fooHbO + HbO(:,jcond)*cond(jcond);
            fooHbR = fooHbR + HbR(:,jcond)*cond(jcond);
        end
        imgrecon.Aimg_conc.HbO = fooHbO;
        imgrecon.Aimg_conc.HbR = fooHbR;
    end
    
elseif value2 == 1 % brain and scalp reconstruction without short separation regression (Zhan2012)
    
    Adot = Adot(activeChLst,:,:);
    Adot = Adot(longSepChLst,:,:);
    
    Adot_scalp = Adot_scalp(activeChLst,:,:);
    Adot_scalp = Adot_scalp(longSepChLst,:,:);
    
    % get alpha and beta for regularization
    alpha = str2num(get(handles.alpha_brain_scalp,'String')); %#ok<*ST2NM>
    beta = str2num(get(handles.beta_brain_scalp,'String'));
    
    % spatial regularization on brain only by Dehghani group [Zhan et al.,Neuroenergetics,2012]
    for j = 1:size(Adot,3)
        J = single(squeeze(Adot(:,:,j)));
        try
            JTJ = diag(J'*J);
        catch
            close(h);
            menu(sprintf('Out of memory: JTJ = diag(J''*J) generates matrix that is too large!!'), 'Okay');
            return;
        end
        L = beta.*max(JTJ);
        LL = sqrt(JTJ+L)';
        LL = diag(1./LL);
        % Normalise J
        Adot(:,:,j) = J*LL;
    end
    
    [u1,s1,v1]=svds(double([squeeze(Adot(:,:,1)) squeeze(Adot_scalp(:,:,1))]),size(Adot,1)); max_sing1 = max(s1(:));
    [u2,s2,v2]=svds(double([squeeze(Adot(:,:,2)) squeeze(Adot_scalp(:,:,2))]),size(Adot,1)); max_sing2 = max(s2(:));
    
    % regularization parameters
    alpha1 = alpha * max_sing1 ;
    alpha2 = alpha * max_sing2 ;
    
    % new sensitivity with regularization
    Anew(:,:,1) = u1 * sqrtm(s1*s1 + alpha1^2*eye(size(s1))) *v1';
    Anew(:,:,2) = u2 * sqrtm(s2*s2 + alpha2^2*eye(size(s2))) *v2';
    
    % put A matrix together and combine with extinction coefficients
    E = GetExtinctions([SD.Lambda(1) SD.Lambda(2)]);
    E = E/10; %convert from /cm to /mm  E raws: wavelength, columns 1:HbO, 2:HbR
    Amatrix = [squeeze(Anew(:,:,1))*E(1,1) squeeze(Anew(:,:,1))*E(1,2);
        squeeze(Anew(:,:,2))*E(2,1) squeeze(Anew(:,:,2))*E(2,2)];
    %########### CORRECT A MATRIX WITH LIST OF long and ACTIVE CHANNELS
    
    % all regularization (alpha and beta) is done above so here we put 0 to alpha!
    [HbO, HbR] = hmrImageReconConc(yavgimg, [], 0, Amatrix);
    
    if size(cond,2) == 1
        imgrecon.Aimg_conc.HbO = HbO(1:size(Adot,2), cond);
        imgrecon.Aimg_conc.HbR = HbR(1:size(Adot,2), cond);
        
        imgrecon.Aimg_conc_scalp.HbO = HbO((size(Adot,2)+1):end, cond);
        imgrecon.Aimg_conc_scalp.HbR = HbR((size(Adot,2)+1):end, cond);
    else
        fooHbO = zeros(size(HbO,1),1);
        fooHbR = zeros(size(HbR,1),1);
        for jcond = 1:size(cond,2) % now this is contrast)
            fooHbO = fooHbO + HbO(:,jcond)*cond(jcond);
            fooHbR = fooHbR + HbR(:,jcond)*cond(jcond);
        end
        imgrecon.Aimg_conc.HbO = fooHbO(1:size(Adot,2));
        imgrecon.Aimg_conc.HbR = fooHbR(1:size(Adot,2));
        
        imgrecon.Aimg_conc_scalp.HbO = fooHbO((size(Adot,2)+1):end);
        imgrecon.Aimg_conc_scalp.HbR = fooHbR((size(Adot,2)+1):end);
    end
    
end

close(h); % close waitbar

saveImgRecon(imgrecon);

atlasViewer.imgrecon = imgrecon;


% ---------------------------------------------------------------------------------
function plotHb_Callback(~, ~, handles)
% This function executes on button press in plotHb.
global atlasViewer

value1 = get(handles.brainonly, 'Value'); % 1 if brain only checked
value2 = get(handles.brain_scalp, 'Value'); % 1 if brain and scalp checked

imgrecon = atlasViewer.imgrecon;
fwmodel = atlasViewer.fwmodel;
hbconc  = atlasViewer.hbconc;
axesv = atlasViewer.axesv;
pialsurf = atlasViewer.pialsurf;

axes(axesv.handles.axesSurfDisplay);
hold on;

ylimits = str2num(get(handles.plotylimit,'String'));

if value1 == 1
    Aimg_conc = imgrecon.Aimg_conc;
    HbO = Aimg_conc.HbO;
    HbR = Aimg_conc.HbR;
elseif value2 == 1
    if 1
        Aimg_conc = imgrecon.Aimg_conc;
        HbO = Aimg_conc.HbO;
        HbR = Aimg_conc.HbR;
    else
        Aimg_conc_scalp = imgrecon.Aimg_conc_scalp;
        HbO = Aimg_conc_scalp.HbO;
        HbR = Aimg_conc_scalp.HbR;
    end
else
    q = menu('Please select an image reconstruction type: Brian Only or Brian and Scalp', 'OK');
    return;
end

if isempty(imgrecon)
    return;
end
if isempty(HbO) & isempty(HbR)
    menu('Missing reconstructed image. First generate HbO and HbR', 'Okay');
    return;
end
if isempty(fwmodel)
    return;
end

if leftRightFlipped(imgrecon)
    axes_order = [2,1,3];
else
    axes_order = [1,2,3];
end

% plot HbO
hHbO = displayIntensityOnMesh(imgrecon.mesh, HbO, 'off','off', axes_order);
hHbR = displayIntensityOnMesh(imgrecon.mesh, HbR, 'off','off', axes_order);
caxis([ylimits(1), ylimits(2)]);
hold off;

% Set image popupmenu to HbO
set(imgrecon.handles.popupmenuImageDisplay,'value',imgrecon.menuoffset+3);

% Since sensitivity profile exists, enable all image panel controls
% for calculating metrics
if ishandles(imgrecon.handles.hHbO)
    delete(imgrecon.handles.hHbO)
end
if ishandles(imgrecon.handles.hHbR)
    delete(imgrecon.handles.hHbR)
end

imgrecon.handles.hHbO = hHbO;
imgrecon.handles.hHbR = hHbR;
imgrecon.cmThreshold(3,:) = [ylimits(1) ylimits(2)];
imgrecon.cmThreshold(4,:) = [ylimits(1) ylimits(2)];

% set(imgrecon.handles.editColormapThreshold, 'enable','on');
% set(imgrecon.handles.textColormapThreshold, 'enable','on');
set(imgrecon.handles.editColormapThreshold, 'string', sprintf('%g, %g',ylimits(1), ylimits(2)));

set(pialsurf.handles.radiobuttonShowPial, 'value',0);
uipanelBrainDisplay(pialsurf.handles.radiobuttonShowPial, []);

% Turn off image recon display
fwmodel = showFwmodelDisplay(fwmodel, axesv(1).handles.axesSurfDisplay, 'off');
hbconc = showHbConcDisplay(hbconc, axesv(1).handles.axesSurfDisplay, 'off', 'off');

% Turn resolution on and localization error display off
imgrecon = showImgReconDisplay(imgrecon, axesv(1).handles.axesSurfDisplay, 'off', 'off', 'on', 'off');


atlasViewer.fwmodel = fwmodel;
atlasViewer.imgrecon = imgrecon;
