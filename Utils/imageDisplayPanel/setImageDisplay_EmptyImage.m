function setImageDisplay_EmptyImage(hImg, onoff)
global atlasViewer
if strcmp(onoff, 'on')
    if ishandles(atlasViewer.fwmodel.handles.surf0)
        if isempty(hImg)
	        set(atlasViewer.fwmodel.handles.surf0, 'visible','on');
	        createColorbar([], atlasViewer.fwmodel.handles.surf0.FaceVertexCData);
	        drawnow
		else
            turnOffAllOtherPatches(hImg);
		end
    end
end



% ---------------------------------------------------------------
function turnOffAllOtherPatches(hImg)
hc = get(get(hImg, 'parent'), 'children');
for ii = 1:length(hc)
    if strcmpi(hc(ii).Type, 'patch')
        if length(hImg.FaceVertexCData) ~= length(hc(ii).FaceVertexCData)
            continue;
        end
        set(hc(ii), 'visible','off');
    end
end
set(hImg, 'visible','on')
drawnow


