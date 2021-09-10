function probe = initProbe(handles)
probe = struct( ...
               'name','probe', ...
               'pathname',filesepStandard(pwd), ...
               'handles',struct( ...
                                'labels',[], ...
                                'circles',[], ...
                                'hMeasList',[], ...
                                'hProjectionPts',[], ...
                                'hProjectionTbl', [-1,-1], ...
                                'hProjectionRays',[], ...
                                'hSprings',[], ...
                                'hSDgui',[], ...
                                'hRefpts',[], ...
                                'pushbuttonRegisterProbeToSurface',[], ...
                                'checkboxHideProbe',[], ...
                                'checkboxHideSprings',[], ...
                                'checkboxHideDummyOpts',[], ...
                                'checkboxHideMeasList',[], ...
                                'checkboxOptodeSDMode',[], ....
                                'menuItemProbeToCortex',[], ...
                                'menuItemOverlayHbConc',[], ...
                                'menuItemSaveRegisteredProbe',[], ...
                                'menuItemLoadPrecalculatedProfile',[], ...
                                'checkboxOptodeCircles',[], ...
                                'textSpringLenThresh',[], ...
                                'menuItemProbeCreate',[], ...
                                'menuItemProbeImport',[], ...
                                'textSize',12, ...
                                'circleSize',24, ...
                                'axes',[] ...
                               ), ...
               'lambda',[], ...
               'srcpos',[], ...
               'detpos',[], ...
               'optpos',[], ...
               'optpos_reg',[], ...
               'optpos_reg_mean',[], ...
               'nsrc',0, ...
               'ndet',0, ...
               'nopt',0, ...
               'noptorig',0, ...
               'mlmp',[], ...
               'mlmp_mean',[], ...
               'ptsProj_cortex',[], ...
               'ptsProj_cortex_mni',[], ...
               'ml',[], ...
               'registration',[], ...
               'SrcGrommetType',{{}}, ...
               'DetGrommetType',{{}}, ...
               'DummyGrommetType',{{}}, ...
               'SrcGrommetRot',{{}}, ...
               'DetGrommetRot',{{}}, ...
               'DummyGrommetRot',{{}}, ...
               'hideProbe',0, ...
               'hideMeasList',0, ...
               'hideSprings',0, ...
               'hideDummyOpts',0, ...
               'hOptodesIdx',1, ...
               'optViewMode','numbers', ...
               'center',[], ...
               'orientation', '', ...
               'checkCompatability',[], ...
               'isempty',@isempty_loc, ...
               'copy',@copy_loc, ...
               'copyLandmarks',@copyLandmarks, ...
               'copyMeasList',@copyMeasList, ...
               'copyOptodes', @copyOptodes, ...
               'save',@save_loc, ...
               'prepObjForSave',[], ...
               'pullToSurfAlgorithm','center', ...
               'rhoSD_ssThresh', 15, ...
               'T_2digpts',eye(4), ...
               'T_2mc',eye(4) ...
              );
          
probe = initFontSizeConfigParams(probe);
probe = initRegistration(probe);

if exist('handles','var')
    probe.handles.pushbuttonRegisterProbeToSurface = handles.pushbuttonRegisterProbeToSurface;
    probe.handles.checkboxHideProbe                = handles.checkboxHideProbe;
    probe.handles.checkboxHideSprings              = handles.checkboxHideSprings;
    probe.handles.checkboxHideDummyOpts            = handles.checkboxHideDummyOpts;
    probe.handles.checkboxHideMeasList             = handles.checkboxHideMeasList;
    probe.handles.checkboxOptodeSDMode             = handles.checkboxOptodeSDMode;
    probe.handles.checkboxOptodeCircles            = handles.checkboxOptodeCircles;
    probe.handles.menuItemSaveRegisteredProbe      = handles.menuItemSaveRegisteredProbe;
    probe.handles.menuItemProbeToCortex            = handles.menuItemProbeToCortex;
    probe.handles.menuItemOverlayHbConc            = handles.menuItemOverlayHbConc;
    probe.handles.editSpringLenThresh              = handles.editSpringLenThresh;
    probe.handles.textSpringLenThresh              = handles.textSpringLenThresh;
    probe.handles.menuItemLoadPrecalculatedProfile = handles.menuItemLoadPrecalculatedProfile;
    probe.handles.menuItemProbeCreate              = handles.menuItemProbeCreate;
    probe.handles.menuItemProbeImport              = handles.menuItemProbeImport;
    probe.handles.axes                             = handles.axesSurfDisplay;
    
    set(probe.handles.pushbuttonRegisterProbeToSurface, 'enable','off');
    set(probe.handles.checkboxHideProbe, 'enable','off');
    set(probe.handles.checkboxHideSprings, 'enable','off');
    set(probe.handles.checkboxHideDummyOpts, 'enable','off');
    set(probe.handles.checkboxHideMeasList, 'enable','off');
    set(probe.handles.checkboxOptodeSDMode, 'enable','off');
    set(probe.handles.checkboxOptodeCircles, 'enable','off');
    set(probe.handles.menuItemProbeToCortex, 'enable','off');
%    set(probe.handles.menuItemOverlayHbConc, 'enable','off');

    set(probe.handles.menuItemSaveRegisteredProbe,'enable','off');
    set(probe.handles.editSpringLenThresh,'string',num2str(probe.registration.springLenThresh) );
    set(probe.handles.menuItemLoadPrecalculatedProfile, 'enable','off');
    set(probe.handles.menuItemProbeCreate,'enable','on');
    set(probe.handles.menuItemProbeImport,'enable','on');

    probe.hideProbe     = get(probe.handles.checkboxHideProbe,'value');
    probe.hideSprings   = get(probe.handles.checkboxHideSprings,'value');
    probe.hideDummyOpts = get(probe.handles.checkboxHideDummyOpts,'value');
    probe.hideMeasList  = get(probe.handles.checkboxHideMeasList,'value');
    val                 = get(probe.handles.checkboxOptodeCircles,'value');
    if val==1
        probe.optViewMode='circles';
    elseif val==0
        probe.optViewMode='numbers';
    end
end


% --------------------------------------------------------------
function b = isempty_loc(probe)
b = true;
if isempty(probe)
    return;
end
if ~isempty(probe.optpos_reg)
    b = false;
    return;
end
if isempty(probe.optpos)
    return;
end
if isempty(probe.srcpos) && isempty(probe.detpos) && isempty(probe.optpos)
    return;
end
b = false;



% --------------------------------------------------------------
function b = isempty_reg_loc(probe)
b = false;
if probeHasSpringRegistration(probe)
    return
end
if probeHasDigptsRegistration(probe)
    return;
end
b = true;



% --------------------------------------------------------------
function probe = copy_loc(probe, probe2)
if isempty(probe2)
    return;
end
if probe2.isempty(probe2)
    return;
end
if ~compatibleProbes(probe, probe2)
    return;
end
probe = scaleFactor(probe);

probe = copySpringRegistration(probe, probe2);
probe = copyLandmarks(probe, probe2);

if ~isempty(probe2.lambda) && isempty(probe.lambda)
    probe.lambda        = probe2.lambda;
end
if ~isempty(probe2.srcpos) && isempty(probe.srcpos)
    probe.srcpos        = probe2.srcpos;
end
if ~isempty(probe2.detpos) && isempty(probe.detpos)
    probe.detpos        = probe2.detpos;
end
if ~isempty(probe2.optpos_reg) && isempty(probe.optpos_reg)
    probe.optpos_reg    = probe2.optpos_reg;
end
if ~isempty(probe2.ml) && isempty(probe.ml)
    probe.ml            = probe2.ml;
end

if isfield(probe2,'SrcGrommetType') %&& isempty(probe.SrcGrommetType)
    probe.SrcGrommetType = probe2.SrcGrommetType;
end
if isfield(probe2,'DetGrommetType') %&& isempty(probe.DetGrommetType)
    probe.DetGrommetType = probe2.DetGrommetType;
end
if isfield(probe2,'DummyGrommetType') %&& isempty(probe.DummyGrommetType )
    probe.DummyGrommetType = probe2.DummyGrommetType;
end
if isfield(probe2,'SrcGrommetRot') %&& isempty(probe.SrcGrommetRot)
    probe.SrcGrommetRot = probe2.SrcGrommetRot;
end
if isfield(probe2,'DetGrommetRot') %&& isempty(probe.DetGrommetRot)
    probe.DetGrommetRot = probe2.DetGrommetRot;
end
if isfield(probe2,'DummyGrommetRot') %&& isempty(probe.DummyGrommetRot )
    probe.DummyGrommetRot = probe2.DummyGrommetRot;
end
if ~isempty(probe2.SrcGrommetType) && isempty(probe.SrcGrommetType)
    probe.SrcGrommetType = probe2.SrcGrommetType;
end
if ~isempty(probe2.DetGrommetType) && isempty(probe.DetGrommetType)
    probe.DetGrommetType = probe2.DetGrommetType;
end
if ~isempty(probe2.DummyGrommetType) && isempty(probe.DummyGrommetType )
    probe.DummyGrommetType = probe2.DummyGrommetType;
end
probe.optpos        = [probe.srcpos; probe.detpos; probe.registration.dummypos];
probe.center        = probe2.center;
probe.orientation   = probe2.orientation;

probe = setNumberOfOptodeTypes(probe, probe2);



% ------------------------------------------------
function save_loc(probe)
if isempty(probe)
    return;
end
if probe.isempty(probe)
    return;
end
SD = convertProbe2SD(probe);
SD = updateProbe2DcircularPts(SD);
% create snirf object 
snirf = SnirfClass();
probe_snirf_object = ProbeClass(SD);
snirf.probe = probe_snirf_object;
snirf.data = DataClass();
% measurementList = MeasListClass(SD.MeasList);
for ii=1:size(SD.MeasList,1)
    snirf.data.measurementList(end+1) = MeasListClass(SD.MeasList(ii,:));
end
% snirf.data(1).measurementList = measurementList;
metaDataTags = MetaDataTagsClass();
snirf.metaDataTags = metaDataTags;
if ~isempty(SD) && ~exist([probe.pathname, 'probe.SD'],'file')
    save([probe.pathname, 'probe.SD'],'-mat', 'SD');
    snirf.Save([probe.pathname, 'probe.snirf'])
elseif ~isempty(SD)
    save([probe.pathname, 'probe.SD'],'-mat', 'SD');
    snirf.Save([probe.pathname, 'probe.snirf'])
end




% ------------------------------------------------
function probe = scaleFactor(probe)
if strcmp(guessUnit(probe), 'cm')
    probe.optpos    = 10 * probe.optpos;
    probe.srcpos    = 10 * probe.srcpos;
    probe.detpos    = 10 * probe.detpos;
    probe.registration.dummypos = 10 * probe.registration.dummypos;
end


% ------------------------------------------------
function u = guessUnit(probe)
u = '';
if isempty(probe)
    return;
end
if probe.isempty(probe)
    return;
end
if isempty(probe.ml)
    return;
end
th = 10;
d = zeros(size(probe.ml,1), 1)+th;
for ii = 1:size(probe.ml,1)
    d(ii) = dist3(probe.srcpos(probe.ml(ii,1),:), probe.detpos(probe.ml(ii,2),:));
end
if isempty(d)
    return;
end
if all(d<th)
    u = 'cm';
else
    u = 'mm';
end


% -------------------------------------------------
function probe = initRegistration(probe)
probe.registration = struct(...
    'sl',[], ...
    'al',[], ...    
    'dummypos',[], ...
    'ndummy',0, ...
    'springLenThresh',[3,10], ...
    'refpts',initRefpts(), ...
    'isempty',@isempty_reg_loc, ...
    'init',@initRegistration ...
    );


% -------------------------------------------------
function probe1 = copySpringRegistration(probe1, probe2)
if probeHasSpringRegistration(probe1)
    return
end
probe1.registration.sl              = probe2.registration.sl;
probe1.registration.al              = probe2.registration.al;
probe1.registration.dummypos        = probe2.registration.dummypos;
probe1.registration.springLenThresh = probe2.registration.springLenThresh;



% -------------------------------------------------
function probe = copyLandmarks(probe, refpts)
if strcmp(refpts.name, 'probe')
    probe2 = refpts;
    refpts = probe2.registration.refpts;
end
if probeHasLandmarkRegistration(probe)
    return
end
[~,~,~,~,~, refpts] = getLandmarks(refpts);
probe.registration.refpts = refpts.copyLandmarks(probe.registration.refpts, refpts);



% -------------------------------------------------
function probe1 = copyOptodes(probe1, probe2)

if ~isempty(probe2.srcpos) && isempty(probe1.srcpos)
    probe1.srcpos        = probe2.srcpos;
end
if ~isempty(probe2.detpos) && isempty(probe1.detpos)
    probe1.detpos        = probe2.detpos;
end
if ~isempty(probe2.optpos_reg) && isempty(probe1.optpos_reg)
    probe1.optpos_reg    = probe2.optpos_reg;
end
if ~isempty(probe2.SrcGrommetRot) && isempty(probe1.SrcGrommetRot)
    probe1.SrcGrommetRot = probe2.SrcGrommetRot;
end
if ~isempty(probe2.DetGrommetRot) && isempty(probe1.DetGrommetRot)
    probe1.DetGrommetRot = probe2.DetGrommetRot;
end
if ~isempty(probe2.DummyGrommetRot) && isempty(probe1.DummyGrommetRot )
    probe1.DummyGrommetRot = probe2.DummyGrommetRot;
end
if ~isempty(probe2.SrcGrommetType) && isempty(probe1.SrcGrommetType)
    probe1.SrcGrommetType = probe2.SrcGrommetType;
end
if ~isempty(probe2.DetGrommetType) && isempty(probe1.DetGrommetType)
    probe1.DetGrommetType = probe2.DetGrommetType;
end
if ~isempty(probe2.DummyGrommetType) && isempty(probe1.DummyGrommetType )
    probe1.DummyGrommetType = probe2.DummyGrommetType;
end
probe1.optpos        = [probe1.srcpos; probe1.detpos; probe1.registration.dummypos];

if ~isempty(probe2.optpos_reg) && isempty(probe1.optpos_reg)
    probe1.optpos_reg = probe2.optpos_reg;
end



% -------------------------------------------------
function probe1 = copyMeasList(probe1, probe2)

% Error checking: Must pass a bunch of error checks before 
% being granted permission to copy measurement list from probe2 
% to probe1
if isempty(probe2.ml)
    return;
end
if size(probe2.ml,1)<2
    return;
end
if ~isempty(probe1.ml)
    return;
end

% Check to make sure measurement list is compatible with
% source/detector pairs
if max(probe2.ml(:,1))>size(probe1.srcpos,1)
    return;
end
if max(probe2.ml(:,2))>size(probe1.detpos,1)
    return;
end
ks = find(probe2.ml(:,1)<1); %#ok<*EFIND>
kd = find(probe2.ml(:,2)<1);
if ~isempty(ks)
    return;
end
if ~isempty(kd)
    return;
end

% probe1.ml is empty and probe2.ml seems valid, lets copy it...
probe1.ml = probe2.ml;



