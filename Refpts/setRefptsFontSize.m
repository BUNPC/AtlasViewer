function refpts = setRefptsFontSize(refpts)
if ~ishandles(refpts.handles.labels(1,1))
    return;
end
refpts.handles.textSize = get(refpts.handles.labels(1,1), 'fontsize');
