function [filedata, filename, err] = sd_file_load(filename, handles)

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

if file.isdir
    err=1;
    SDgui_disp_msg(handles, sprintf('ERROR: %s is a folder. Please choose a file.', filename), err);
    return;
end

try
    [filedata, filename] = loadFile(filename);
catch
    err=3;
    SDgui_disp_msg(handles, sprintf('ERROR: File %s is not in .mat format.', filename), err);
    return;
end

if ~isfield(filedata,'SD')
    [~, fname, ext] = fileparts(filename);
    err=4;
    SDgui_disp_msg(handles, sprintf('ERROR: SD data doesn''t exist or is corrupt in %s.', [fname,ext]), err);
    return;
end




% ----------------------------------------------------------------------
function [filedata, filename] = loadFile(filename)
filedata = [];
[~, ~, ext] = fileparts(filename);
if strcmpi(ext,'.SD') || strcmpi(ext,'.nirs')
    filedata = load(filename,'-mat');
elseif strcmp(ext, '.snirf')
    if ~exist('SnirfClass','class')
        return;
    end
    snirf = SnirfClass(filename);
    nirs = NirsClass(snirf);
    filedata.SD = nirs.SD;
end
filedata.SD = sd_data_Init(filedata.SD);

