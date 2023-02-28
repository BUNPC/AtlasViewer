function imgrecon = showImgReconDisplay(imgrecon, hAxes, valLocErr, valRes, valHbO, valHbR)
if isempty(hAxes)
    hAxes = gca;
end

% Get the current selection
[img, hImg] = getImgRecon_DisplayPanelImage(imgrecon);
if strcmpi(valLocErr,'on') || strcmpi(valRes,'on') || strcmpi(valHbO,'on') || strcmpi(valHbR,'on')
    imgrecon = setImgReconColormap(imgrecon, hAxes, img);
    val = 'on';
else
    val = 'off';
end

set(imgrecon.handles.hLocalizationError, 'visible',valLocErr);
set(imgrecon.handles.hResolution, 'visible',valRes);
set(imgrecon.handles.hHbO, 'visible',valHbO);
set(imgrecon.handles.hHbR, 'visible',valHbR);
setImageDisplay_EmptyImage(hImg, val);


