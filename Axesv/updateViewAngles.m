function updateViewAngles(ii, az, el)
global atlasViewer

atlasViewer.axesv(ii).azimuth   = az;
atlasViewer.axesv(ii).elevation = el;

