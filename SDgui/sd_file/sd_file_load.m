function [filedata, err] = sd_file_load(filename, handles)

filedata = [];
err = 0;
if isempty(handles)
    return;
end

file = dir(filename);
if isempty(file)
    err=2;
    SDgui_disp_msg(handles, sprintf('ERROR: file %s does not exist.', filename), err);
    return;
end

if file.isdir()
    err=1;
    SDgui_disp_msg(handles, sprintf('ERROR: %s is a folder. Please choose a file.', filename), err);
    return;
end

try
    filedata = load(filename,'-mat');
catch
    err=3;
    SDgui_disp_msg(handles, sprintf('ERROR: File %s is not in .mat format.', filename), err);
    return;
end

if ~isfield(filedata,'SD')
    err=4;
    SDgui_disp_msg(handles, sprintf('ERROR: SD data doesn''t exist or is corrupt in %s.', [fname,ext]), err);
    return;
end
