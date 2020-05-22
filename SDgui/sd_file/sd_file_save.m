function sd_file_save(filename, pathname, handles)
global filedata;

[~,~,ext] = fileparts(filename);
if exist(pathname,'dir')~=7
    msg = sprintf('Error: couldn''t save SD file - directory doesn''t exist');
    SDgui_disp_msg(handles, msg, -1, 'messagebox');
    return;
end
if isempty(sd_data_Get('Lambda'))
    msg = sprintf('Error: could not save file - need to set Lamda');
    SDgui_disp_msg(handles, msg, -1, 'messagebox');
    return;
end
[err, msgs] = sd_data_ErrorCheck();
if err
    msgs = {...
        sprintf('Cannot save file because of the following errors:\n\n'), ...
        msgs, ...        
        sprintf('\nPlease fix these then try saving again.\n') ...
        };    
    SDgui_disp_msg(handles, [msgs{:}], -1, 'messagebox');
    return;
end

sd_data_ErrorFix();
SD = sd_data_Get('all');
if ~isempty(ext) && strcmp(ext,'.nirs')
    filedata.SD = SD;
    sd_file_save2nirs([pathname, filename], filedata);
else
    try
        [~, ~, ext] = fileparts(filename);
        if isempty(ext)
            filename = [filename, '.SD'];
        end
        filedata.SD = SD;
        save([pathname, filename],'SD','-mat');
    catch ME
        msg = sprintf('Error: %s', ME.message);
        SDgui_disp_msg(handles, msg, -1);
        menu(msg,'ok');
        return;
    end
end
sd_filename_edit_Set(handles,filename);

SDgui_disp_msg(handles, sprintf('Save %s', filename));

sd_filename_edit_Set(handles,filename);
sd_file_panel_SetPathname(handles,pathname);

