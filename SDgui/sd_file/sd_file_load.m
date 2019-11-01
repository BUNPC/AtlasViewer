function [filedata, err] = sd_file_load(filename, handles)

filedata=[];
err = 0;
if isempty(handles)
    return;
end

[~, fname, ext] = fileparts(filename);

if exist(filename,'file')==7
    err=1;
    SDgui_disp_msg(handles, sprintf('ERROR: %s is a folder. Please choose a file.', [fname,ext]), err);
    return;
end

if isempty(filename) || exist(filename,'file')==0
    err=2;
    SDgui_disp_msg(handles, sprintf('ERROR: file %s does not exist.', [fname,ext]), err);
    return;
end

try
    filedata = load(filename,'-mat');
catch
    err=3;
    SDgui_disp_msg(handles, sprintf('ERROR: File %s is not in .mat format.', [fname,ext]), err);
    return;
end

if ~isfield(filedata,'SD')
    err=4;
    SDgui_disp_msg(handles, sprintf('ERROR: SD data doesn''t exist or is corrupt in %s.', [fname,ext]), err);
    return;
end
