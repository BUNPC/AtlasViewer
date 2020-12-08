function pos=sd_file_panel_GetPos(handles)

    hObject = handles.sd_file_panel;
    
    % Save pathname in sd_file_panel
    set(hObject,'units','pixels');
    pos = get(hObject,'position');
    set(hObject,'units','normalized');



