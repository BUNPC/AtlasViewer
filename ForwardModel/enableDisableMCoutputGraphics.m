function fwmodel = enableDisableMCoutputGraphics(fwmodel, onoff)

handles = fwmodel.handles;
if strcmp(onoff,'off')
    set(handles.menuItemGenerateLoadSensitivityProfile,'enable','off');
    set(handles.menuItemEnableSensitivityMatrixVolume,'enable','off');
elseif strcmp(onoff,'on')
    if ~isempty(fwmodel.Adot) | (~isempty(fwmodel.errMCoutput) & all(fwmodel.errMCoutput==3))
        set(handles.menuItemGenerateLoadSensitivityProfile,'enable','on');
        set(handles.menuItemEnableSensitivityMatrixVolume,'enable','on');
    end
end
