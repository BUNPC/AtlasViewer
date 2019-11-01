function probe_geometry_axes2_Hide(handles,val)

    hObject = handles.probe_geometry_axes2;

    probe_geometry_axes2_data = get(hObject,'userdata');
    h_edges = probe_geometry_axes2_data.edges.handles;
    h_nodes = probe_geometry_axes2_data.h_nodes;
    
    set(h_nodes,'visible',val);
    set(h_edges,'visible',val);
    set(hObject,'visible',val);

