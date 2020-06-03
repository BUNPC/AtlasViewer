function imgrecon = resetImgRecon(imgrecon)

set(imgrecon.handles.pushbuttonCalcMetrics_new, 'enable','off');
% set(imgrecon.handles.editColormapThreshold, 'enable','off');
% set(imgrecon.handles.textColormapThreshold, 'enable','off');
if AVUtils.ishandles(imgrecon.handles.hLocalizationError)
    delete(imgrecon.handles.hLocalizationError);
    imgrecon.handles.hLocalizationError = [];
end
if AVUtils.ishandles(imgrecon.handles.hResolution)
    delete(imgrecon.handles.hResolution);
    imgrecon.handles.hResolution = [];
end
imgrecon = setImgReconColormap(imgrecon, []);

imgrecon.localizationError = [];
imgrecon.resolution = [];

