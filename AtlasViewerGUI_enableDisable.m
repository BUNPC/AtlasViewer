function AtlasViewerGUI_enableDisable()
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
    set(atlasViewer.handles.menuItemRegisterAtlasToDigpts,'enable','off')
else
    set(atlasViewer.handles.menuItemRegisterAtlasToDigpts,'enable','on')
end

% Set the GUI controls for post-probe-registration controls, 
% like fw model, image recon, hb overlay, 
fwmodel = updateGuiControls_AfterProbeRegistration(probe, fwmodel, imgrecon, labelssurf);

