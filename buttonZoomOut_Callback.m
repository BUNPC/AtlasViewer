
% For some bizarre reason this callback name 
% pushbuttonZoomOut_Callback does not work - the callback 
% never called for which ever object has it as it's callback 
% value
function buttonZoomOut_Callback(hObject, eventdata, handles)
global atlasViewer;
axesv = atlasViewer.axesv;
ax=[];
for ii=1:length(axesv)
    if AVUtils.ishandles(axesv(ii).handles.pushbuttonZoomOut)
        if hObject==axesv(ii).handles.pushbuttonZoomOut
            ax=axesv(ii);
            break;
        end
    end
end

camzoom(ax.handles.axesSurfDisplay, 1/ax.zoomincr);
atlasViewer.axesv(ii) = ax;


