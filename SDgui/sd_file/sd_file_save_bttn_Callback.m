function sd_file_save_bttn_Callback(hObject, eventdata, handles)

filename0 = sd_filename_edit_Get(handles);
pathname0 = sd_file_panel_GetPathname(handles);

if isempty(filename0)
    SDgui_disp_msg(handles, 'ERROR: No file specified', -1)
    return;
end

% Convert pathname to full path and filename to file name ONLY (no path
% info at all)
if exist([pathname0, filename0], 'file')~=2
    [pname, fname, ext] = fileparts(filename0);
    pathname = fullpath([pathname0, pname]);
    [pname, fname, ext] = fileparts([pathname, fname, ext]);
else
    [pname, fname, ext] = fileparts(fullpath([pathname0, filename0]));
end
pathname = [pname, '/'];
filename = [fname, ext];

if exist(pathname, 'dir')~=7
    SDgui_disp_msg(handles, 'ERROR: Save directory doesn''t exist', -1)
    
    % Change directory
    [filename, pathname] = uiputfile('*.*','Save SD file', filename);
    if(filename == 0)
        set(handles.sd_filename_edit, 'string', filename);
        return;
    end
end

if exist([pathname, filename],'file')==2
    q = menu('File already exists. Do you want to overwrite it?','Yes','No');
    if q==2
        return;
    end
end
sd_file_save(filename, pathname, handles);

