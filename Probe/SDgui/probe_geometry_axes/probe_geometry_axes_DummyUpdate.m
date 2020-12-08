function probe_geometry_axes_DummyUpdate(handles,opos1,i,event)

    hObject = handles.probe_geometry_axes;

    probe_geometry_axes_data = get(hObject,'userdata');
    h_nodes   = probe_geometry_axes_data.h_nodes_dummy;
    h_nodes_s = probe_geometry_axes_data.h_nodes_s;
    h_nodes_d = probe_geometry_axes_data.h_nodes_d;
    fs        = probe_geometry_axes_data.fontsize_dummy;
    fc        = probe_geometry_axes_data.fontcolor_dummy;

    % Get the source positions from the axes gui object
    optpos = getOptPosFromAxes([h_nodes_s h_nodes_d h_nodes]);
    nopt   = length(h_nodes);
    
    axes(hObject);
    
    switch lower(event)
    case {'add'}
        h_nodes(i)=text(opos1(1),opos1(2),opos1(3),num2str(i),'color',fc(1,:),'fontweight','bold',...
                        'fontsize',fs(1),'visible','off');
        set(h_nodes(i),'hittest','off');
        set(h_nodes(i),'ButtonDownFcn','probe_geometry_axes2_ButtonDownFcn');        
        
    case {'delete'}
        % Delete optode from axes
        for j=i:length(h_nodes)-1
            set(h_nodes(j+1),'string',num2str(j));
        end
        delete(h_nodes(i));
        h_nodes(i)=[];

    case {'edit'}
        % Draw new node position 
        set(h_nodes(i),'position',opos1);

        % Redraw nodes that might have been obscured by 
        % the redrawn edges 
        h_nodes=redraw_text_many(h_nodes);
               
    end
    
    % Draw grid to fit the updated probe
    optpos = getOptPosFromAxes([h_nodes_s h_nodes_d h_nodes]);
    resize_axes(hObject, optpos);
    axes_view=set_view_probe_geometry_axes(hObject,optpos);

    % Update object's user data
    probe_geometry_axes_data.h_nodes_dummy = h_nodes;
    probe_geometry_axes_data.view          = axes_view;
    set(hObject,'userdata',probe_geometry_axes_data);
