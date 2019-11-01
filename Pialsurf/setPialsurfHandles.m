function pialsurf = setPialsurfHandles(pialsurf, handles)

pialsurf.handles.editTransparency = handles.editBrainTransparency;
set(pialsurf.handles.editTransparency,'enable','off');

pialsurf.handles.radiobuttonShowPial = handles.radiobuttonShowPial;
set(pialsurf.handles.radiobuttonShowPial,'enable','off');

pialsurf.handles.axes = handles.axesSurfDisplay;

