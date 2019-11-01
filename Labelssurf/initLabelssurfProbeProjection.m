function labelssurf = initLabelssurfProbeProjection(labelssurf)

hLabelsSurf    = labelssurf.handles.surf;
idxL           = labelssurf.idxL;
colormaps      = labelssurf.colormaps;
idxCm          = labelssurf.colormapsIdx;

cm = colormaps(idxCm).col;
set(hLabelsSurf,'faceVertexCData',cm(idxL,:));
