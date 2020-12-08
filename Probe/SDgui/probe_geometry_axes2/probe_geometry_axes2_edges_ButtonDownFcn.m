function probe_geometry_axes2_edges_ButtonDownFcn(hObject, eventdata, handles)

   probe_geometry_axes2_data = get(get(hObject,'parent'),'userdata');
   edges                     = probe_geometry_axes2_data.edges;
   h_edges                   = edges.handles;

   linestyle = get(hObject,'linestyle');
   if strcmp(linestyle,'-')
      set(hObject,'linestyle','--');
      springflex = -1;
   elseif strcmp(linestyle,'--')
      set(hObject,'linestyle','-');
      userdata = get(hObject,'userdata');      
      x = userdata.xdata;
      y = userdata.ydata;
      z = userdata.zdata;
      springflex = dist3([x(1) y(1) z(1)],[x(2) y(2) z(2)]);
   end
   
   idx = eventdata;
   optode_spring_tbl_Update(handles,springflex,[idx 3])
   
   