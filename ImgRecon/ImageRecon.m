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
function err = UpdateGuiControls(handles, iCond)
global atlasViewer

err = -1;
if isempty(atlasViewer.dataTree)
    return;
end
currElem  = atlasViewer.dataTree.currElem;

% Display list of subject name
set(handles.ListofSubjects, 'String',currElem.GetName);

% default exp editcondition
if ~isempty(atlasViewer.dataTree)
    set(handles.editCondition, 'string',atlasViewer.dataTree.currElem.CondNames, 'value',iCond,'enable','on');
else
    set(handles.editCondition, 'string',atlasViewer.dataTree.currElem.CondNames, 'enable','off');
end

% default time range
set(handles.time_range, 'String',num2str([5 10]));

% default alpha (regularization) for brain only reconstruction
set(handles.alpha_brainonly, 'String',1e-2);

% default alpha (regularization) for brain and scalp reconstruction
set(handles.alpha_brain_scalp, 'String',1e-2);

% default beta (regularization) for brain and scalp reconstruction
set(handles.beta_brain_scalp, 'String',1e-2);

trange = abs(atlasViewer.dataTree.currElem.GetVar('trange'));
set(handles.time_range,'String',num2str(trange));


err = 0;


% ---------------------------------------------------------------------------------
function ImageRecon_OpeningFcn(hObject, ~, handles, varargin)
global atlasViewer

if ~isempty(varargin)
    iCond = varargin{1};
else
    iCond = 1;
end

% Choose default command line output for ImageRecon
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

atlasViewer.imgrecon.handles.ImageRecon = hObject;

UpdateGuiControls(handles, iCond);



% -----------------------------------------------------------------------------
function varargout = ImageRecon_OutputFcn(~, ~, handles)
if isempty(handles)
    varargout{1} = [];
else
    varargout{1} = handles.output;
end



% -----------------------------------------------------------------------------
function ListofSubjects_Callback(~, ~, handles)
s = set(handles.ListofSubjects, 'Value');


% -----------------------------------------------------------------------------
function brainonly_Callback(~, ~, handles)
value1 = get(handles.brainonly, 'Value');
if value1==1
    set(handles.brain_scalp, 'value', 0);
end



% -----------------------------------------------------------------------------
function brain_scalp_Callback(~, ~, handles)
value2 = get(handles.brain_scalp, 'Value');
if value2==1
    set(handles.brainonly, 'value', 0);
end


% -----------------------------------------------------------------------------
function alpha_brainonly_Callback(~, ~, handles)
alpha = str2num(get(handles.alpha_brainonly,'String'));


% -----------------------------------------------------------------------------
function alpha_brain_scalp_Callback(~, ~, handles)
alpha = str2num(get(handles.alpha_brain_scalp,'String'));


% -----------------------------------------------------------------------------
function beta_brain_scalp_Callback(~, ~, handles)
beta = str2num(get(handles.beta_brain_scalp,'String'));


% -----------------------------------------------------------------------------
function plotylimit_Callback(~, ~, handles) %#ok<*DEFNU>
ylimits = str2num(get(handles.plotylimit,'String'));



% -----------------------------------------------------------------------------
function image_recon_Callback(~, ~, handles)
global atlasViewer
global logger

atlasViewer.imgrecon.Aimg_conc.HbO = [];
atlasViewer.imgrecon.Aimg_conc.HbR = [];

imgrecon = atlasViewer.imgrecon;
fwmodel = atlasViewer.fwmodel;
dataTree = atlasViewer.dataTree;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Get image parameters from GUI 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
value1 = get(handles.brainonly, 'Value'); % 1 if brain only checked
value2 = get(handles.brain_scalp, 'Value'); % 1 if brain and scalp checked
cond = get(handles.editCondition, 'value');
trange = str2num(get(handles.time_range,'String'));
rhoSD_ssThresh = str2num(get(handles.shortsep_thresh,'String'));

Adot        = fwmodel.Adot;
Adot_scalp  = fwmodel.Adot_scalp;

% Error checking
if  value1 == 0 & value2 == 0 %#ok<*AND2>
    msg = sprintf('Please choose one image reconstruction option.');
    MenuBox(msg,'OK');
    return;
end
if  value1 == 1 & value2 == 1
    msg = sprintf('Please choose one image reconstruction option ONLY.');
    MenuBox(msg,'OK');
    return;
end
if value1 == 1 & isempty(Adot)
    MenuBox('You need the file fw/Adot.mat to perform this image reconstruction.','Okay');
    return;
end
if value1 == 1 & ndims(Adot) < 3 %#ok<*ISMAT>
    MenuBox('You need at least two wavelengths for image reconstruction.','Okay');
    return;
end
if value2 == 1 & isempty(Adot_scalp)
    MenuBox('You need the file fw/Adot_scalp.mat to perform this image reconstruction.','Okay');
    return;
end
if value2 == 1 & ndims(Adot_scalp) < 3
    MenuBox('You need at least two wavelengths for image reconstruction.','Okay');
    return;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Get processed data from dataTree
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(dataTree) || dataTree.IsEmpty()
    MenuBox('Error: data is missing');
    return
end

h = waitbar(0,'Please wait, running...');

dataTree.currElem.Load();
if isempty(dataTree.currElem) || dataTree.currElem.procStream.output.IsEmpty()
    close(h);
    MenuBox('Error: data is missing');
    return
end

%%%% Get probe data 
SD = extractSDFromDataTree(dataTree);

%%%% Get HRF time course 
[dcAvg, tHRF, ml_dcAvg]  = dataTree.currElem.procStream.output.dcAvg.GetDataTimeSeries('reshape:matrix');

%%%% Use only active channels. Active channels in this case are channels that have NOT 
%%%% been prunned by data tree processing AND long separation channels. 
ml_dod  = dataTree.currElem.GetMeasurementList('matrix');
[activeChLst_SDpairs, activeChLst_OD] = GetActiveChannels(dcAvg, ml_dcAvg, ml_dod, SD, rhoSD_ssThresh);

if isempty(activeChLst_SDpairs)
    MenuBox('Error: There are no active channels and therefore no data to display');
    close(h);
    return;
end

%%%% After figuring out inactive channels in HRF, we can erase all NaN values 
dcAvg(find(isnan(dcAvg))) = 0;

%%%% Error checking of subject data itself
if ErrorCheck_Data(dcAvg, tHRF, cond, trange) < 0 
    return
end

%%%%  get dod conversion for each cond, if more than one editcondition
dod = [];
ppf = dataTree.currElem.GetVar('ppf');
if isempty(ppf)
    ppf = zeros(1, length(SD.Lambda)) + 6;
    msg = sprintf('WARNING: could not retrieve value of partial path length (ppf) used in Homer processing. Will use ppf = [ %s ]\n', num2str(ppf));
    logger.Write(msg);
    MenuBox(msg);
end
for icond = 1:size(dcAvg,4)
    dod(:,:,icond) = hmrConc2OD( squeeze(dcAvg(:, :, :, icond)), SD, ppf );
end

% average HRF (number of channels at all wavelengths X number of conditions) over a time range
yavgimg = hmrImageHrfMeanTwin(dod, tHRF, trange);

% Use only active channels
yavgimg = yavgimg(activeChLst_OD, :);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Calculate image from processed dataTree data and GUI params 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if value1 == 1 % brain only reconstruction after short separation regression
        
    % Use only active sd pairs
    Adot = Adot(activeChLst_SDpairs,:,:);
    
    % put A matrix together and combine with extinction coefficients
    E = GetExtinctions([SD.Lambda(1) SD.Lambda(2)]);
    E = E/10; %convert from /cm to /mm  E raws: wavelength, columns 1:HbO, 2:HbR
    Amatrix = [squeeze(Adot(:,:,1))*E(1,1) squeeze(Adot(:,:,1))*E(1,2);
        squeeze(Adot(:,:,2))*E(2,1) squeeze(Adot(:,:,2))*E(2,2)];
    
    
    alpha = str2num(get(handles.alpha_brainonly,'String'));
    [HbO, HbR, err] = hmrImageReconConc(yavgimg, [], alpha, Amatrix);
    if err==1
        MenuBox('Error: Number of channels in measuremnt is not the same as in Adot.', 'Okay');
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

    Adot = Adot(activeChLst_SDpairs,:,:);
    Adot_scalp = Adot_scalp(activeChLst_SDpairs,:,:);

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
            MenuBox(sprintf('Out of memory: JTJ = diag(J''*J) generates matrix that is too large!!'), 'Okay');
            return;
        end
        L = beta.*max(JTJ);
        LL = sqrt(JTJ+L)';
        LL = diag(1./LL);
        % Normalise J
        Adot(:,:,j) = J*LL;
    end
    
    [u1,s1,v1] = svds(double([squeeze(Adot(:,:,1)) squeeze(Adot_scalp(:,:,1))]),size(Adot,1)); max_sing1 = max(s1(:));
    [u2,s2,v2] = svds(double([squeeze(Adot(:,:,2)) squeeze(Adot_scalp(:,:,2))]),size(Adot,1)); max_sing2 = max(s2(:));
    
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




% --------------------------------------------------------------------------------
function [activeChLst1, activeChLst2] = GetActiveChannels(y, ml, ml2, SD, rhoSD_ssThresh)
mlact1 = mlAct_Initialize([], ml);
mlact2 = mlAct_Initialize([], ml2);

n = NirsClass(SD);
SrcPos = n.GetSrcPos();
DetPos = n.GetDetPos();

% Get long separation channels and mark inacive all sd pairs that have short sep optodes
for iML = 1:length(ml)
    rho = sum( (SrcPos(ml(iML,1),:) - DetPos(ml(iML,2),:)) .^ 2) ^ 0.5;
    if rho < rhoSD_ssThresh
        k1 = mlact1(:,1)==ml(iML,1) & mlact1(:,2)==ml(iML,2);
        k2 = mlact2(:,1)==ml(iML,1) & mlact2(:,2)==ml(iML,2);
        mlact1(k1,3) = 0;
        mlact2(k2,3) = 0;
    end
end

% Get active channels prunned in processing
for iDataType = 1:size(y,2)
    for iCond = 1:size(y,4)
        for iCh = 1:size(y,3)
            if all(isnan(y(:,iDataType, iCh, iCond)))
                mlact1(iCh,3) = 0;
            end
        end
    end
end
for ii = 1:size(mlact2,1)
    k = find(mlact1(:,1)==mlact2(ii,1) & mlact1(:,2)==mlact2(ii,2));
    if isempty(k)
        continue;
    end
    if mlact1(k(1),3)==0
        mlact2(ii,3) = 0;
    end
end
k = mlact1(:,4)==1;
activeChLst1 = find(mlact1(k,3) == 1);
activeChLst2 = find(mlact2(:,3) == 1);



% ---------------------------------------------------------------------------------
function plotHb_Callback(~, ~, handles)
% This function executes on button press in plotHb.
global atlasViewer

imgrecon = atlasViewer.imgrecon;
fwmodel = atlasViewer.fwmodel;
hbconc  = atlasViewer.hbconc;
axesv = atlasViewer.axesv;
pialsurf = atlasViewer.pialsurf;

value1 = get(handles.brainonly, 'Value'); % 1 if brain only checked
value2 = get(handles.brain_scalp, 'Value'); % 1 if brain and scalp checked

axes(axesv.handles.axesSurfDisplay);
hold on;

% Get the HbO and HbR images
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
    MenuBox('Please select an image reconstruction type: Brian Only or Brian and Scalp');
    return;
end

% Set image popupmenu to HbO if it's not already set to a Recon menu choice
datatypeChoices = get(imgrecon.handles.popupmenuImageDisplay, 'string');
v = get(imgrecon.handles.popupmenuImageDisplay, 'value');
if any(strfind(lower(datatypeChoices{v}), 'recon'))
    if contains(lower(datatypeChoices{v}), 'hbo')
        ylimits = [min(HbO), max(HbO)];
    else
        ylimits = [min(HbR), max(HbR)];
    end
else
    k = find(strcmpi(datatypeChoices, 'hbo recon'));
    set(imgrecon.handles.popupmenuImageDisplay, 'value', k);
    ylimits = [min(HbO), max(HbO)];
end

if isempty(imgrecon)
    return;
end
if isempty(HbO) & isempty(HbR)
    setImageDisplay_EmptyImage([], 'on')
    MenuBox('Missing reconstructed image. First generate HbO and HbR');
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




% ----------------------------------------------------------------------------
function err = ErrorCheck_Data(dcAvg, tHRF, cond, trange)
err = -1;
if isempty(tHRF)
    MenuBox('Error: tHRF is missing from subject data. Check groupResults.mat use Homer3 to generate new groupResults.mat file','Okay');
    return;
end
if isempty(dcAvg)
    MenuBox('Error: dcAvg is missing from subject data. Check groupResults.mat or use Homer3 to generate new groupResults.mat file','Okay');
    return;
end
if cond<1 || cond>size(dcAvg, 4)
    MenuBox('Invalid condition for this time course.','Okay');
    return;
end
if cond<1 || cond>size(dcAvg, 4)
    MenuBox('Invalid condition for this time course.','Okay');
    return;
end
if trange(1)<tHRF(1) || trange(1)>tHRF(end) || trange(2)<tHRF(1) || trange(2)>tHRF(end)
    MenuBox(sprintf('Invalid time rage entered. Enter values between tHRF range [%0.1f - %0.1f].', tHRF(1), tHRF(end)), 'OK');
    return;
end
err = 0;

