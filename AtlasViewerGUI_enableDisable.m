function AtlasViewerGUI_enableDisable(handles)
global atlasViewer

digpts       = atlasViewer.digpts;
refpts       = atlasViewer.refpts;
probe        = atlasViewer.probe;
headsurf     = atlasViewer.headsurf;
fwmodel      = atlasViewer.fwmodel;
imgrecon     = atlasViewer.imgrecon;
labelssurf   = atlasViewer.labelssurf;


if refpts.isempty(refpts)
    q = MenuBox('Warning: No reference points were found for this subject''s head. Do you want to select reference points?', {'YES','NO'});
    if q==1
        FindRefptsGUI();
    end
end

if isempty(digpts.refpts.pos) | isempty(refpts.pos) | isempty(headsurf.mesh.vertices)
    set(handles.menuItemRegisterAtlasToDigpts,'enable','off')
else
    set(handles.menuItemRegisterAtlasToDigpts,'enable','on')
end

% Set the GUI controls for post-probe-registration controls, 
% like fw model, image recon, hb overlay, 
fwmodel = updateGuiControls_AfterProbeRegistration(probe, fwmodel, imgrecon, labelssurf);

% check for MCXlab in path - JAY, WHERE SHOULD THIS GO?
if exist('mcxlab.m','file')
    set(handles.menuItemRunMCXlab,'enable','on');
else
    set(handles.menuItemRunMCXlab,'enable','off');
end

pos = get(handles.uipanelImageDisplay, 'position');
parent = get(handles.uipanelImageDisplay, 'position');
set(handles.uipanelProbeDesignEdit, 'parent',parent, 'position',pos);
