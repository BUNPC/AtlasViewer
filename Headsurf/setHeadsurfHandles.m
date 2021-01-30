function headsurf = setHeadsurfHandles(headsurf, handles)

    headsurf.handles.radiobuttonShowHead = handles.radiobuttonShowHead;
    set(headsurf.handles.radiobuttonShowHead,'enable','off');

    headsurf.handles.editTransparency = handles.editHeadTransparency;
    set(headsurf.handles.editTransparency,'enable','off');

    headsurf.handles.menuItemProbeCreate = handles.menuItemProbeCreate;
    set(headsurf.handles.menuItemProbeCreate,'enable','off');

    headsurf.handles.menuItemProbeImport = handles.menuItemProbeImport;
    set(headsurf.handles.menuItemProbeImport,'enable','off');

    headsurf.handles.axes = handles.axesSurfDisplay;
    
    