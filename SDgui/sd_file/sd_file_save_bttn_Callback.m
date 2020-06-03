function sd_file_save_bttn_Callback(hObject, eventdata, handles)

errmsg = '';

filename0 = sd_filename_edit_Get(handles);
pathname0 = sd_file_panel_GetPathname(handles);

% Convert pathname to full path and filename to file name ONLY (no path
% info at all)
if exist([pathname0, filename0], 'file')~=2
    [pname, fname, ext] = fileparts(filename0);
    pathname = AVUtils.fullpath([pathname0, pname]);
    [pname, fname, ext] = fileparts([pathname, fname, ext]);
else
    [pname, fname, ext] = fileparts(AVUtils.fullpath([pathname0, filename0]));
end
pathname = AVUtils.filesepStandard(pname);
filename = [fname, ext];

% Check for errors
if isempty(filename)
    errmsg = 'ERROR: File name invalid';
elseif isempty(dir(pathname))
    errmsg = 'ERROR: Save directory doesn''t exist';
end

% If there are errors, open windows explorer to let user enter file name 
if ~isempty(errmsg)
    SDgui_disp_msg(handles, errmsg, -1)
    
    % Change directory
    [filename, pathname] = uiputfile('*.*','Save SD file', filename);
    if(filename == 0)
        return;
    end
end

if exist([pathname, filename],'file')==2
    q = AVUtils.MenuBox('File already exists. Do you want to overwrite it?', {'Yes','No'});
    if q==2
        return;
    end
end

sd_file_save(filename, pathname, handles);

