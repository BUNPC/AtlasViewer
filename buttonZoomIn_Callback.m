function buttonZoomIn_Callback(hObject, eventdata, handles)
global atlasViewer;
axesv = atlasViewer.axesv;
ax=[];
for ii=1:length(axesv)
    if AVUtils.ishandles(axesv(ii).handles.pushbuttonZoomIn)
        if hObject==axesv(ii).handles.pushbuttonZoomIn
            ax=axesv(ii);
            break;
        end
    end
end

camzoom(ax.handles.axesSurfDisplay, ax.zoomincr);
atlasViewer.axesv(ii) = ax;

