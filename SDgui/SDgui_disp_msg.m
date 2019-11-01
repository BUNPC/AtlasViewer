function SDgui_disp_msg(handles, msg, status)

% Set default args
if ~exist('status','var')
    status=0;
end

colstatusgood = [0.25, 0.60, 0.10];
colstatuserr  = [0.90, 0.20, 0.10];
if ismac || islinux
    fsize_orig = 12;
else
    fsize_orig = 8;
end

% Default prop values
col = colstatusgood;
fsize = fsize_orig;
alignment = 'center';

% Save original property values
units_orig = get(handles.textFileLoadSave, 'units');
set(handles.textFileLoadSave, 'units','char');
pos = get(handles.textFileLoadSave, 'position');

% Set parameters for handle
if status~=0
    col = colstatuserr;
end
if length(msg) > pos(3)
    fsize = fsize-1;
    alignment = 'left';
end
set(handles.textFileLoadSave, 'string',msg, 'fontsize', fsize, ...
                              'foregroundcolor',col, 'units',units_orig, ...
                              'horizontalalignment',alignment);
