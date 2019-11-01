function editDegRotation_Callback(hObject, eventdata, handles)
global atlasViewer;
axesv = atlasViewer.axesv;
ax=[];
for ii=1:length(axesv)
    if ishandles(axesv(ii).handles.editDegRotation)
        if hObject==axesv(ii).handles.editDegRotation            
            val = str2num(get(hObject,'string'));
            axesv(ii).rotation.degrees = val;
            atlasViewer.axesv(ii) = axesv(ii);
        end
    end
end



