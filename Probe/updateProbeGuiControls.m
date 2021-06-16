function probe = updateProbeGuiControls(probe, headobj)

% Error checking
if ~exist('probe','var')
    MessageBox('WARNING: probe object is missing')
    return
end
if ~exist('headobj','var')
    MessageBox('WARNING: head surface object is missing. Probe cannot be registered.')
    return
end

% Set probe control handles 
if ~isempty(probe.optpos)
    
    set(probe.handles.checkboxHideProbe,'enable','on');
    set(probe.handles.checkboxOptodeSDMode,'enable','on');
    set(probe.handles.checkboxOptodeCircles,'enable','on');
    if ~isempty(probe.ml)
        set(probe.handles.checkboxHideMeasList,'enable','on');
    else
        set(probe.handles.checkboxHideMeasList,'enable','off');
    end
    
    % Registration GUI controls
    if probeHasSpringRegistration(probe)
        if ~isempty(probe.registration.sl)
            set(probe.handles.checkboxHideSprings,'enable','on');
        else
            set(probe.handles.checkboxHideSprings,'enable','off');
        end
        if ~isempty(probe.registration.dummypos)
            set(probe.handles.checkboxHideDummyOpts,'enable','on');
        else
            set(probe.handles.checkboxHideDummyOpts,'enable','off');
        end
    else
        set(probe.handles.checkboxHideSprings,'enable','off');
        set(probe.handles.checkboxHideDummyOpts,'enable','off');
    end
    
    % Figure out if the probe is pre-registered. That is, it is either in
    % position to be pulled toward the head or if we can register it using
    % springs and anchor points, if they exist. The button
    % pushbuttonRegisterProbeToSurface is used for both cases but has to be
    % enabled
    if isPreRegisteredProbe(probe, headobj) || probeHasSpringRegistration(probe) || probeHasLandmarkRegistration(probe)
        set(probe.handles.pushbuttonRegisterProbeToSurface,'enable','on');
    elseif ~probeHasDigptsRegistration(probe)
        msg{1} = sprintf('\nWARNING: Loaded probe lacks registration data. In order to register it\n');
        msg{2} = sprintf('to head surface you need to add registration data. You can manually add\n');
        msg{3} = sprintf('registration data using SDgui application.\n\n');
        fprintf([msg{:}]);
        set(probe.handles.pushbuttonRegisterProbeToSurface,'enable','off');
    end
    
    
else
    
    set(probe.handles.checkboxHideProbe,'enable','off');
    set(probe.handles.checkboxOptodeSDMode,'enable','off');
    set(probe.handles.checkboxOptodeCircles,'enable','off');
    set(probe.handles.checkboxHideMeasList,'enable','off');
    
    % Registration GUI controls
    set(probe.handles.checkboxHideSprings,'enable','off');
    set(probe.handles.checkboxHideDummyOpts,'enable','off');
    set(probe.handles.pushbuttonRegisterProbeToSurface,'enable','off');
    
end

if ~isempty(probe.optpos_reg)
    set(probe.handles.menuItemSaveRegisteredProbe,'enable','on');
    set(probe.handles.menuItemProbeToCortex, 'enable','on');
    set(probe.handles.menuItemOverlayHbConc, 'enable','on');
else
    set(probe.handles.menuItemSaveRegisteredProbe,'enable','off');
    set(probe.handles.menuItemProbeToCortex, 'enable','off');
    %set(probe.handles.menuItemOverlayHbConc, 'enable','off');
end


% Get handles to probe controls
probe.hideProbe     = get(probe.handles.checkboxHideProbe,'value');
probe.hideSprings   = get(probe.handles.checkboxHideSprings,'value');
probe.hideDummyOpts = get(probe.handles.checkboxHideDummyOpts,'value');
probe.hideMeasList  = get(probe.handles.checkboxHideMeasList,'value');


