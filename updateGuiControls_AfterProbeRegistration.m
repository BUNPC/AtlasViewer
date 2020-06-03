function fwmodel = updateGuiControls_AfterProbeRegistration(probe, fwmodel, imgrecon, labelssurf)

if ~isempty(probe.optpos_reg) && AVUtils.ishandles(labelssurf.handles.surf)
    set(probe.handles.menuItemProbeToCortex, 'enable','on');
    set(probe.handles.menuItemOverlayHbConc, 'enable','on');    
else
    set(probe.handles.menuItemProbeToCortex, 'enable','off');
    set(probe.handles.menuItemOverlayHbConc, 'enable','off');    
end

if ~isempty(probe.optpos_reg)
    enableMCGenGuiControls(fwmodel, 'on');
else
    enableMCGenGuiControls(fwmodel, 'off');
end

if ~isempty(probe.optpos_reg) && ~isempty(probe.ml)
    if isempty(fwmodel.Adot) 
        if ~isempty(fwmodel.fluenceProfFnames)
            enableDisableMCoutputGraphics(fwmodel, 'on');
        else
            enableDisableMCoutputGraphics(fwmodel, 'off');
        end    
        enableImgReconGen(imgrecon, 'off');
        enableImgReconDisplay(imgrecon, 'off');
    else
        if size(probe.ml,1) ~= size(fwmodel.Adot,1)
            fwmodel.Adot = [];
            onoff = 'off';
        else
            onoff = 'on';            
        end
        enableDisableMCoutputGraphics(fwmodel, onoff);
        enableImgReconGen(imgrecon, onoff);
        enableImgReconDisplay(imgrecon, onoff);
    end
else
    enableDisableMCoutputGraphics(fwmodel, 'off');
    enableImgReconGen(imgrecon, 'off');
    enableImgReconDisplay(imgrecon, 'off');
end

