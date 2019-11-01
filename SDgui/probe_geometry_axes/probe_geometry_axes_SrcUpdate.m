function probe_geometry_axes_SrcUpdate(handles,spos,i,event)

    hObject = handles.probe_geometry_axes;

    probe_geometry_axes_data = get(hObject,'userdata');
    optselect = probe_geometry_axes_data.optselect;
    h_nodes_s = probe_geometry_axes_data.h_nodes_s;
    h_nodes_d = probe_geometry_axes_data.h_nodes_d;
    h_nodes_dummy = probe_geometry_axes_data.h_nodes_dummy;
    edges = probe_geometry_axes_data.edges;
    h_edges = edges.handles;
    fs = probe_geometry_axes_data.fontsize;
    fc = probe_geometry_axes_data.fontcolor_s;

    % Get the source positions from the axes gui object
    optpos_det = getOptPosFromAxes(h_nodes_d);
    optpos_src = getOptPosFromAxes(h_nodes_s);
    optpos_dummy = getOptPosFromAxes(h_nodes_dummy);
    ml         = getMeasListFromAxes(optpos_src,optpos_det,h_edges);
    axes(hObject);
    switch lower(event)
    case {'add'}
        h_nodes_s(i)=text(spos(1),spos(2),spos(3),num2str(i),'color',fc(1,:),...
                          'fontweight','bold','fontsize',fs(1),...
                          'verticalalignment','middle','horizontalalignment','center');
        set(h_nodes_s(i),'hittest','off');
        set(h_nodes_s(i),'ButtonDownFcn','probe_geometry_axes_ButtonDownFcn');
        optselect.src(i)=0;
    case {'delete'}
        % Delete optode from axes
        for j=i:length(h_nodes_s)-1
            set(h_nodes_s(j+1),'string',num2str(j));
        end
        delete(h_nodes_s(i));
        h_nodes_s(i)=[];

        % Delete entry from source gui selection array
        optselect.src(i)=[];

        % Delete all edges representing measurement pairs 
        % associated with this optode
        if(~isempty(ml))
            j=find(ml(:,1)==i);
            delete(h_edges(j));
            if(~isempty(j)>0)
                h_edges(j)=[];
                ml(j,:)=[];
            end
            j=find(ml(:,1)>i);
            if(~isempty(j)>0)
                ml(j,1)=ml(j,1)-1;
            end
        end
    case {'edit'}
        % Draw new node position 
        set(h_nodes_s(i),'position',spos);

        % Since position of optode changed, update all edges 
        % for the measurement pairs associated with this optode
        if(~isempty(ml))
            j=find(ml(:,1)==i);
            for ii=1:length(j)
                k=ml(j(ii),2);
                dpos=optpos_det(k,:);
                set(h_edges(j(ii)),'xdata',[spos(1) dpos(1)],'ydata',[spos(2) dpos(2)],'zdata',[spos(3) dpos(3)]);
            end
        end

        % Redraw nodes that might have been obscured by 
        % the redrawn edges 
        [h_nodes_s h_nodes_d]=redraw_text_many(h_nodes_s,h_nodes_d);
    end

    % Draw grid to fit the updated probe
    optpos_src = getOptPosFromAxes(h_nodes_s);
    optpos=[optpos_src; optpos_det; optpos_dummy];
    resize_axes(hObject, optpos);
    axes_view=set_view_probe_geometry_axes(hObject,optpos);

    % Update SD data
    k = sd_data_SetMeasList(ml);
    h_edges(k) = h_edges;

    % Update object's user data
    probe_geometry_axes_data.optselect=optselect;
    probe_geometry_axes_data.edges.handles = h_edges;
    probe_geometry_axes_data.h_nodes_s = h_nodes_s;
    probe_geometry_axes_data.h_nodes_d = h_nodes_d;
    probe_geometry_axes_data.view = axes_view;
    probe_geometry_axes_data.threshold = set_threshold(optpos);
    set(hObject,'userdata',probe_geometry_axes_data);
