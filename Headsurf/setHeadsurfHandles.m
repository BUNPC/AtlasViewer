function headsurf = setHeadsurfHandles(headsurf, handles)

    headsurf.handles.radiobuttonShowHead = handles.radiobuttonShowHead;
    set(headsurf.handles.radiobuttonShowHead,'enable','off');

    headsurf.handles.editTransparency = handles.editHeadTransparency;
    set(headsurf.handles.editTransparency,'enable','off');

    headsurf.handles.menuItemMakeProbe = handles.menuItemMakeProbe;
    set(headsurf.handles.menuItemMakeProbe,'enable','off');

    headsurf.handles.menuItemImportProbe = handles.menuItemImportProbe;
    set(headsurf.handles.menuItemImportProbe,'enable','off');

    headsurf.handles.axes = handles.axesSurfDisplay;
    
    