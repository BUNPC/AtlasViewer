function imgrecon = enableImgReconGen(imgrecon, val)

set(imgrecon.handles.pushbuttonCalcMetrics_new, 'enable',val);
set(imgrecon.handles.menuItemImageReconGUI, 'enable',val);
