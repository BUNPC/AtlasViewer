function probe = setProbeFontSize(probe)
if ~ishandles(probe.handles.hOptodes)
    return;
end
probe.handles.textSize = get(probe.handles.hOptodes(1), 'fontsize');
