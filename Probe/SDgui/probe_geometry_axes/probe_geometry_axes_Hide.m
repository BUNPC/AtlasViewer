function probe_geometry_axes_Hide(handles,val)

hObject = handles.probe_geometry_axes;

probe_geometry_axes_data = get(hObject,'userdata');
h_edges = probe_geometry_axes_data.edges.handles;
h_nodes_s = probe_geometry_axes_data.h_nodes_s;
h_nodes_d = probe_geometry_axes_data.h_nodes_d;
h_lm      = probe_geometry_axes_data.h_lm;

set(h_nodes_s,'visible',val);
set(h_nodes_d,'visible',val);
set(h_edges,'visible',val);
set(h_lm,'visible',val);
set(hObject,'visible',val);
set(get(hObject,'xlabel'), 'visible',val)
set(get(hObject,'ylabel'), 'visible',val)
if get(handles.radiobuttonView3D, 'value')
    set(get(hObject,'zlabel'), 'visible',val)
end
