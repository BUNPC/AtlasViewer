function pushbuttonRotUp_Callback(hObject, eventdata, handles)
global atlasViewer;
axesv = atlasViewer.axesv;
headsurf = atlasViewer.headsurf;

ax=[];
for ii=1:length(axesv)
    if AVUtils.ishandles(axesv(ii).handles.pushbuttonRotUp)
        if hObject==axesv(ii).handles.pushbuttonRotUp
            ax=axesv(ii);
            break;
        end
    end
end
if ~isempty(ax)
    rotUp(ax);
end

[az_new, el_new] = getViewAngles(ax.handles.axesSurfDisplay, headsurf.orientation);
set(ax.handles.editViewAnglesAzimuth, 'string', sprintf('%0.2f', az_new));
set(ax.handles.editViewAnglesElevation, 'string', sprintf('%0.2f', el_new));

updateViewAngles(ii, az_new, el_new);
