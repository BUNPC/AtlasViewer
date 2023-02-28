function setImageDisplay_EmptyImage(img, onoff)
global atlasViewer
if strcmp(onoff, 'on')
    if isempty(img) && ishandles(atlasViewer.fwmodel.handles.surf0)
        set(atlasViewer.fwmodel.handles.surf0, 'visible','on');
        createColorbar([], atlasViewer.fwmodel.handles.surf0.FaceVertexCData);
        drawnow
    elseif ishandles(atlasViewer.fwmodel.handles.surf0)
        set(atlasViewer.fwmodel.handles.surf0, 'visible','off');
        drawnow
    end
else
%     if ishandles(atlasViewer.fwmodel.handles.surf0)
%         set(atlasViewer.fwmodel.handles.surf0, 'visible','off');
%         drawnow
%     end
end
