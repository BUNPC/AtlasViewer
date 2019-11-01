function hbconc = showHbConcDisplay(hbconc, hAxes, valHbO, valHbR)

if isempty(hAxes)
    hAxes=gca;
end

if strcmp(valHbO,'on') | strcmp(valHbR,'on')
    hbconc = setHbConcColormap(hbconc, hAxes);
else
    hbconc = setHbConcColormap(hbconc, []);
end

set(hbconc.handles.HbO,'visible',valHbO);
set(hbconc.handles.HbR,'visible',valHbR);

