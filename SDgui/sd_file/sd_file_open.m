function err = sd_file_open(filename, pathname, handles)
global filedata

err = 0;

% If SD has been edited but not saved, notify user there's unsaved changes
% before loading new file
if SDgui_EditsMade()
    msg{1} = 'SD data has been edited. Are you sure you want to load a new file and lose your changes? ';
    msg{2} = 'If you''re not sure, click ''No'' to return to main GUI and save your changes before ';
    msg{3} = 'loading a new file. Otherwise click ''Yes'' to proceed with loading new file';
    q = MenuBox([msg{:}], {'Yes','No'});
    if q==2
        return;
    end
end

SDgui_clear_all(handles);

% Load new SD file
[filedata, filename, err] = sd_file_load([pathname, filename], handles);
if err
    return;
end

SDgui_display(handles, filedata.SD)

set(handles.sd_filename_edit,'string',filename);

[~, fname,ext] = fileparts(filename);
SDgui_disp_msg(handles, sprintf('Loaded %s', [fname,ext]));

sd_file_panel_SetPathname(handles,pathname);
sd_filename_edit_Set(handles,filename);

