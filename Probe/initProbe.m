function probe = initProbe(handles)

probe = struct( ...
               'name', 'probe', ...
               'pathname', filesepStandard(pwd), ...
               'handles',struct( ...
                                'hSrcpos', [], ...
                                'hDetpos', [], ...
                                'hOptodes', [], ...
                                'hOptodesCircles', [], ...
                                'hMeasList', [], ...
                                'hProjectionPts', [], ...
                                'hProjectionTbl', [-1,-1], ...
                                'hProjectionRays', [], ...
                                'hSprings', [], ...
                                'hSDgui', [], ...
                                'pushbuttonRegisterProbeToSurface', [], ...
                                'checkboxHideProbe', [], ...
                                'checkboxHideSprings', [], ...
                                'checkboxHideDummyOpts', [], ...
                                'checkboxHideMeasList', [], ...
                                'checkboxOptodeSDMode', [], ....
                                'menuItemProbeToCortex',[], ...
                                'menuItemOverlayHbConc',[], ...
                                'menuItemSaveRegisteredProbe', [], ...
                                'menuItemLoadPrecalculatedProfile', [], ...
                                'checkboxOptodeCircles', [], ...
                                'textSpringLenThresh', [], ...
                                'menuItemProbeCreate', [], ...
                                'menuItemProbeImport', [], ...
                                'textSize',12, ...
                                'axes', [] ...
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
               'springLenThresh',[3,10], ...
               'center',[], ...
               'orientation', '', ...
               'checkCompatability',[], ...
               'isempty',@isempty_loc, ...
               'copy',@copy_loc, ...
               'save',@save_loc, ...
               'prepObjForSave',[], ...
               'pullToSurfAlgorithm','center', ...
               'rhoSD_ssThresh', 15, ...
               'T_2digpts',eye(4), ...
               'T_2mc',eye(4) ...
              );
          
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
    probe.handles.menuItemProbeToCortex          = handles.menuItemProbeToCortex;
    probe.handles.menuItemOverlayHbConc            = handles.menuItemOverlayHbConc;
    probe.handles.editSpringLenThresh              = handles.editSpringLenThresh;
    probe.handles.textSpringLenThresh              = handles.textSpringLenThresh;
    probe.handles.menuItemLoadPrecalculatedProfile = handles.menuItemLoadPrecalculatedProfile;
    probe.handles.menuItemProbeCreate                = handles.menuItemProbeCreate;
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
    set(probe.handles.editSpringLenThresh,'string',num2str(probe.springLenThresh) );
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
function probe = copy_loc(probe, probe2, overwrite)
if isempty(probe2)
    return;
end
if probe2.isempty(probe2)
    return;
end
if ~similarProbes(probe, probe2)
    return;
end
if ~exist('overwrite','var')
    overwrite = 0;
end
probe = scaleFactor(probe);

if probe.registration.isempty(probe)
    probe.registration  = probe2.registration;
end
if isempty(probe.lambda)
    probe.lambda        = probe2.lambda;
end
if isempty(probe.srcpos) || overwrite
    probe.srcpos        = probe2.srcpos;
end
if probe.nsrc == 0
    probe.nsrc          = probe2.nsrc;
end
if probe.ndet == 0
    probe.ndet          = probe2.ndet;
end
if isempty(probe.detpos) || overwrite
    probe.detpos        = probe2.detpos;
end
if isempty(probe.optpos) || overwrite
    probe.optpos        = probe2.optpos;
end
if isempty(probe.optpos_reg)
    probe.optpos_reg    = probe2.optpos_reg;
end
if isempty(probe.ml)
    probe.ml            = probe2.ml;
end
if probe.noptorig == 0
    probe.noptorig      = probe2.noptorig;
end

probe.center        = probe2.center;
probe.orientation   = probe2.orientation;

if isfield(probe2,'SrcGrommetRot')
    probe.SrcGrommetRot = probe2.SrcGrommetRot;
end
if isfield(probe2,'DetGrommetRot')
    probe.DetGrommetRot = probe2.DetGrommetRot;
end
if isfield(probe2,'DummyGrommetRot')
    probe.DummyGrommetRot = probe2.DummyGrommetRot;
end




% ------------------------------------------------
function save_loc(probe)
if isempty(probe)
    return;
end
if probe.isempty(probe)
    return;
end
SD = convert2SD(probe);
if ~isempty(SD) && ~exist([probe.pathname, 'probe.SD'],'file')
    save([probe.pathname, 'probe.SD'],'-mat', 'SD');
end


% ------------------------------------------------
function probe = scaleFactor(probe)
if strcmp(guessUnit(probe), 'cm')
    probe.optpos    = 10 * probe.optpos;
    probe.srcpos    = 10 * probe.srcpos;
    probe.detpos    = 10 * probe.detpos;
    probe.registration.dummypos = 10 * probe.registration.dummypos;
end
if strcmp(guessUnit(probe.optpos_reg), 'cm')
    probe.optpos_reg = 10 * probe.optpos_reg;
end



% ------------------------------------------------
function u = guessUnit(probe)
u = '';
if isempty(probe)
    return;
end
if isempty(probe.isempty(probe))
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
    'refpts',initRefpts(), ...
    'isempty',@isempty_reg_loc, ...
    'init',@initRegistration ...
    );

