function sd_file_save(filename, pathname, handles)
global filedata;

[~,~,ext] = fileparts(filename);


% Check file path for errors
if exist(pathname,'dir')~=7
    msg = sprintf('Error: couldn''t save SD file - directory doesn''t exist');
    SDgui_disp_msg(handles, msg, -1, 'messagebox');
    return;
end

% Check SD data for errors
[msgErrors, msgWarnings] = sd_data_ErrorCheck(handles);
if ~isempty(msgErrors)
    msgs = {...
        sprintf('Cannot save file because of the following errors:\n\n'), ...
        msgErrors, ...        
        sprintf('\nPlease fix these then try saving again.\n') ...
        };
    SDgui_disp_msg(handles, [msgs{:}], -1, 'messagebox');
    return;
end

% Check SD data for warnings
if ~isempty(msgWarnings)
    msgs = {...
        msgWarnings, ...        
        sprintf('Are you sure you want to save?\n\n'), ...
        };
    q = SDgui_disp_msg(handles, [msgs{:}], -1, 'menubox', {'YES','NO'});
    if q == 2        
        return;
    end
end



sd_data_ErrorFix();
SD = sd_data_Get('all');
if ~isempty(ext) && strcmp(ext,'.nirs')
    sd_file_save2nirs([pathname, filename]);
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
        MenuBox(msg,'ok');
        return;
    end
end
sd_filename_edit_Set(handles,filename);

SDgui_disp_msg(handles, sprintf('Save %s', filename));

sd_filename_edit_Set(handles,filename);
sd_file_panel_SetPathname(handles,pathname);

