function q = SDgui_disp_msg(handles, msg, status, dst, args)

q = 0;

% Set default args
if ~exist('status','var') || isempty(status)
    status=0;
end
if ~exist('dst','var') || isempty(dst)
    dst = 'guionly';
end

colstatusgood = [0.25, 0.60, 0.10];
colstatuserr  = [0.90, 0.20, 0.10];

% Default prop values
col = colstatusgood;

% Save original property values
units_orig = get(handles.textFileLoadSave, 'units');
set(handles.textFileLoadSave, 'units','char');
pos = get(handles.textFileLoadSave, 'position');

% Set parameters for handle
if status~=0
    col = colstatuserr;
end
set(handles.textFileLoadSave, 'string',msg, 'foregroundcolor',col, 'units',units_orig);

if strcmp(dst, 'messagebox')
    MessageBox(msg);
end
if strcmp(dst, 'menubox')
    q = MenuBox(msg, args, [], 80);
end
                          