function pushbuttonRotVerticalRight_Callback(hObject, eventdata, handles)
global atlasViewer;
axesv = atlasViewer.axesv;
headsurf = atlasViewer.headsurf;

ax=[];
for ii=1:length(axesv)
    if ishandles(axesv(ii).handles.pushbuttonRotVerticalRight)
        if hObject==axesv(ii).handles.pushbuttonRotVerticalRight
            ax=axesv(ii);
            break;
        end
    end
end
if ~isempty(ax)
    rotVerticalRight(ax);
end

% Rotating camera on it's axis does NOT change either of the viewing angle azimuth
% or elevation. There we do not need to update these angle and we do nothing more 
% here. 


