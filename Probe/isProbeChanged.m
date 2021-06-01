function result = isProbeChanged(probe_copy, probe)

result = 0;

% compare optpos_reg
if ~isequal(probe_copy.optpos_reg,probe.optpos_reg)
    result = 1;
    return
end

% compare measurement list
if ~isequal(probe_copy.ml,probe.ml)
    result = 1;
    return
end

% compare spring list
if ~isequal(probe_copy.registration.sl,probe.registration.sl)
    result = 1;
    return
end

% compare anchorg list
if ~isequal(probe_copy.registration.al,probe.registration.al)
    result = 1;
    return
end

% compare dummy optodes
if ~isequal(probe_copy.registration.dummypos,probe.registration.dummypos)
    result = 1;
    return
end

% compare grommet types
if ~isequal(probe_copy.SrcGrommetType,probe.SrcGrommetType)
    result = 1;
    return
end

if ~isequal(probe_copy.DetGrommetType,probe.DetGrommetType)
    result = 1;
    return
end

if ~isequal(probe_copy.DummyGrommetType,probe.DummyGrommetType)
    result = 1;
    return
end

% compare grommet rotation
if ~isequal(probe_copy.SrcGrommetRot,probe.SrcGrommetRot)
    result = 1;
    return
end

if ~isequal(probe_copy.DetGrommetRot,probe.DetGrommetRot)
    result = 1;
    return
end

if ~isequal(probe_copy.DummyGrommetRot,probe.DummyGrommetRot)
    result = 1;
    return
end

