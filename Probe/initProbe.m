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
    set(probe.handles.menuItemOverlayHbConc, 'enable','off');

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
b = true;
if isempty(probe.registration)
    return;
end
if ~probeHasSpringRegistrationInfo(probe)
    if ~probeHasDigptsRegistrationInfo(probe)
        return;
    end
end
b = false;



% --------------------------------------------------------------
function probe = copy_loc(probe, probe2)
if isempty(probe2)
    return;
end
if probe2.isempty(probe2)
    return;
end
if ~similarProbes(probe, probe2)
    return;
end
probe = scaleFactor(probe);

if ~probe2.registration.isempty(probe2)
    probe = copyRegistration(probe, probe2);
end
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
if ~isempty(SD) && ~exist([probe.pathname, 'probe.SD'],'file')
    save([probe.pathname, 'probe.SD'],'-mat', 'SD');
elseif ~isempty(SD)
    filedata = load([probe.pathname, 'probe.SD'], '-mat');
    if ~sd_data_Equal(SD, filedata.SD)
        save([probe.pathname, 'probe.SD'],'-mat', 'SD');
    end
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
function p2 = copyRegistration(p2, p1)
if ~isempty(p1.registration.sl) && isempty(p2.registration.sl)
    p2.registration.sl              = p1.registration.sl;
end
if ~isempty(p1.registration.al) && isempty(p2.registration.al)
    p2.registration.al              = p1.registration.al;
end
if ~isempty(p1.registration.dummypos) && isempty(p2.registration.dummypos)
    p2.registration.dummypos        = p1.registration.dummypos;
end
if ~isempty(p1.registration.springLenThresh)
    p2.registration.springLenThresh = p1.registration.springLenThresh;
end
if ~isempty(p1.registration.refpts) && ~p1.registration.refpts.isempty(p1.registration.refpts) && ...
        p2.registration.refpts.isempty(p2.registration.refpts)
    p2.registration.refpts          = p1.registration.refpts;
end



% -------------------------------------------------
function probe = copyLandmarks(probe, refpts)
probe.registration.refpts = refpts.copyLandmarks(probe.registration.refpts, refpts);

