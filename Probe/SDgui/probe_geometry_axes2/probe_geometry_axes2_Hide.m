function probe_geometry_axes2_Hide(handles,val)

hObject = handles.probe_geometry_axes2;

probe_geometry_axes2_data = get(hObject,'userdata');
h_edges     = probe_geometry_axes2_data.edges.handles;
h_nodes     = probe_geometry_axes2_data.h_nodes;
h_lm        = probe_geometry_axes2_data.h_lm;

set(h_nodes,'visible',val);
set(h_edges,'visible',val);
set(h_lm,'visible',val);
set(hObject,'visible',val);
set(get(hObject,'xlabel'), 'visible',val)
set(get(hObject,'ylabel'), 'visible',val)
set(get(hObject,'zlabel'), 'visible',val)

