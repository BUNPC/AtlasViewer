function digpts = initDigpts(handles)
global cfg 

if ~exist('handles','var')
    handles = [];
end

digpts(1) = struct( ...
    'name', 'digpts', ...
    'pathname', '', ...
    'handles',struct( ...
        'hSrcpos',[], ...
        'hDetpos',[], ...
        'hOptodes',[], ...
        'hPcpos',[], ...
        'hRefpts',[], ...
        'radiobuttonShowDigpts', [], ...
        'menuItemRegisterAtlasToDigpts', [], ...
        'axes',[] ...
    ), ...
    'refpts', initRefpts(), ...
    'srcpos',[], ...
    'detpos',[], ...
    'dummypos',[], ...
    'pcpos',[], ...
    'T_2mc',eye(4), ...
    'T_2xyz',eye(4), ...
    'T_2ref',eye(4), ...
    'T_2refras',eye(4), ...
    'T_2vol',eye(4), ...
    'center',[], ...
    'orientation', '', ...
    'checkCompatability',@checkDigptsCompatability, ...
    'isempty',@isempty_loc, ...
    'isemptyProbe',@isemptyProbe_loc, ...
    'copyProbe',@copyProbe_loc, ...
    'prepObjForSave',[], ...
    'digpts',[], ...
    'headsize', initHeadsize(handles), ...
    'config',cfg ...
    );

if ~isempty(handles)
    if isfield(handles, 'radiobuttonShowDigpts')
        digpts.handles.radiobuttonShowDigpts = handles.radiobuttonShowDigpts;
        set(digpts.handles.radiobuttonShowDigpts,'enable','off');
        set(digpts.handles.radiobuttonShowDigpts,'value',0);
    end
    if isfield(handles, 'menuItemRegisterAtlasToDigpts')
        digpts.handles.menuItemRegisterAtlasToDigpts = handles.menuItemRegisterAtlasToDigpts;
    end
    if isfield(handles, 'axesSurfDisplay')
        digpts.handles.axes = handles.axesSurfDisplay;
    end
end




% ----------------------------------------------------------------
function digpts = checkDigptsCompatability(digpts)

if ~isstruct(digpts.refpts) & isfield(digpts, 'labels')
    refpts = digpts.refpts;
    labels = digpts.labels;
    
    digpts.refpts = initRefpts();
    digpts = rmfield(digpts, 'labels');
    
    digpts.refpts.pos = refpts;
    digpts.refpts.labels = labels;
end



% --------------------------------------------------------------
function b = isempty_loc(digpts)

b = true;
if isempty(digpts)
    return;
end

if ~isempty(digpts.refpts.pos) & ~isempty(digpts.refpts.labels)
    b = false;
end
if ~isempty(digpts.srcpos)
    b = false;
end
if ~isempty(digpts.detpos)
    b = false;
end
if ~digpts.headsize.isempty(digpts.headsize)
    b = false;
end
if ~isempty(digpts.pcpos)
    b = false;
end




% --------------------------------------------------------------
function b = isemptyProbe_loc(digpts)

b = true;
if isempty(digpts)
    return;
end
if ~isempty(digpts.srcpos)
    b = false;
end
if ~isempty(digpts.detpos)
    b = false;
end



% --------------------------------------------------------------
function digpts = copyProbe_loc(digpts, probe)
if isempty(probe.optpos_reg)
    return;
end

srcpos = probe.optpos_reg(1:probe.nsrc, :);
detpos = probe.optpos_reg(probe.nsrc+1:probe.nsrc+probe.ndet,:);

digpts.srcpos = xform_apply(srcpos, inv(digpts.T_2vol));
digpts.detpos = xform_apply(detpos, inv(digpts.T_2vol));

if ~isempty(probe.registration.refpts) && ~probe.registration.refpts.isempty(probe.registration.refpts)
    digpts.refpts = probe.registration.refpts;
end

