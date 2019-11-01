function sd_file_panel_Clear(handles)
    hObject = handles.sd_file_panel;

    userdata=get(hObject,'userdata');
    h=userdata.h;
    delete(h);
    userdata.h=[];
    userdata.pathname=[];
    set(hObject,'userdata',userdata);
    sd_filename_edit_Set(handles,[]);
