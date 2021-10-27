function hbconc = getHbConc(hbconc, dirname, pialsurf, probe, dataTree)

if isempty(hbconc)
    return;
end

if iscell(dirname)
    for ii=1:length(dirname)
        hbconc = getHbConc(hbconc, dirname{ii}, pialsurf, probe);
        if ~hbconc.isempty(hbconc)
            return;
        end
    end
    return;
end

if isempty(dirname)
    return;
end

if dirname(end)~='/' && dirname(end)~='\'
    dirname(end+1)='/';
end

hbconc.mesh = pialsurf.mesh;

hbconc = loadDataHbConc(hbconc, dataTree);

if ~hbconc.isempty(hbconc)
    hbconc.pathname = dirname;
end

if ~isempty(hbconc.HbConcRaw)
    if ~isempty(probe.ml) & ~isempty(probe.optpos_reg)
        enableHbConcGen(hbconc, 'on');
        if ishandles(hbconc.handles.HbO) | ishandles(hbconc.handles.HbR)
            enableHbConcDisplay(hbconc, 'on');
        else
            enableHbConcDisplay(hbconc, 'off');
        end
    else
        enableHbConcGen(hbconc, 'off');
        enableHbConcDisplay(hbconc, 'off');
    end
else
    enableHbConcGen(hbconc, 'off');
    enableHbConcDisplay(hbconc, 'off');    
end