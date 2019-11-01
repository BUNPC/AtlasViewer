function probe = drawMeasChannels(probe)

if isempty(probe.ml) || (probe.noptorig == 0) || isempty(probe.handles.hOptodes) 
    % warning('optode handles don''t exist. Can''t draw measurement channels list');
    return;
end

if ishandles(probe.handles.hMeasList)
    delete(probe.handles.hMeasList);
end

hMeasList = [];
for ii=1:size(probe.ml,1)
    isrc = probe.ml(ii,1);
    idet = probe.ml(ii,2);
    iopt1 = isrc;
    iopt2 = probe.nsrc+idet;
    if strcmpi('text',get(probe.handles.hOptodes(iopt1,1),'type'))
        o1 = get(probe.handles.hOptodes(iopt1,1),'position');
        o2 = get(probe.handles.hOptodes(iopt2,1),'position');
    elseif strcmpi('line',get(probe.handles.hOptodes(iopt1,1),'type'))
        x1 = get(probe.handles.hOptodes(iopt1,1),'xdata');
        y1 = get(probe.handles.hOptodes(iopt1,1),'ydata');
        z1 = get(probe.handles.hOptodes(iopt1,1),'zdata');
        x2 = get(probe.handles.hOptodes(iopt2,1),'xdata');
        y2 = get(probe.handles.hOptodes(iopt2,1),'ydata');
        z2 = get(probe.handles.hOptodes(iopt2,1),'zdata');
        o1 = [x1,y1,z1];
        o2 = [x2,y2,z2];
    end
    hMeasList(ii,1) = line([o1(1) o2(1)],[o1(2) o2(2)],[o1(3) o2(3)],'color','y','linewidth',2);
end
probe.handles.hMeasList = hMeasList;
