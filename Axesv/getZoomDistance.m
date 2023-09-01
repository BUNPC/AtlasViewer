function d = getZoomDistance()
global atlasViewer
p1 = get(atlasViewer.axesv.handles.axesSurfDisplay, 'CameraTarget');
p2 = get(atlasViewer.axesv.handles.axesSurfDisplay, 'CameraPosition');
d = uint64(dist3(p1, p2));

