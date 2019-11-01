function AtlasViewerGUI_enableDisable()
global atlasViewer

digpts       = atlasViewer.digpts;
refpts       = atlasViewer.refpts;
probe        = atlasViewer.probe;
headsurf     = atlasViewer.headsurf;
fwmodel      = atlasViewer.fwmodel;
imgrecon     = atlasViewer.imgrecon;
labelssurf   = atlasViewer.labelssurf;

if isempty(digpts.refpts.pos) | isempty(refpts.pos) | isempty(headsurf.mesh.vertices)
    set(atlasViewer.handles.menuItemRegisterAtlasToDigpts,'enable','off')
else
    set(atlasViewer.handles.menuItemRegisterAtlasToDigpts,'enable','on')
end

% Set the GUI controls for post-probe-registration controls, 
% like fw model, image recon, hb overlay, 
fwmodel = updateGuiControls_AfterProbeRegistration(probe, fwmodel, imgrecon, labelssurf);

