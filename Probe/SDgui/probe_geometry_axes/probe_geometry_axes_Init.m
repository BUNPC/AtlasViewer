function probe_geometry_axes_Init(handles,optpos_src,optpos_det,optpos_dummy,ml)

% Function populates the gui axis and tables with data 
% from SD structure


    hObject = handles.probe_geometry_axes;

    axes(hObject);
    cla;
    zoom off;
    
    
    probe_geometry_axes_data = get(hObject,'userdata');
    fs = probe_geometry_axes_data.fontsize;
    fc_s = probe_geometry_axes_data.fontcolor_s;
    fc_d = probe_geometry_axes_data.fontcolor_d;
    edges = probe_geometry_axes_data.edges;

    % Initialize user selections 
    optselect.src=zeros(size(optpos_src,1),1);
    optselect.det=zeros(size(optpos_det,1),1);    

    h_nodes_s=[];
    h_nodes_d=[];
    h_nodes_dummy=[];
    h_edges=[];

    nmeas  = size(ml,1);
    optpos = [optpos_src; optpos_det; optpos_dummy];

    % Draw edges first before nodes 
    % by edges.
    if(~isempty(ml))
        h_edges=zeros(nmeas,1);
        for i=1:nmeas
            s=optpos_src(ml(i,1),:);
            d=optpos_det(ml(i,2),:);
            hold on;
            h_edges(i) = line([s(:,1) d(:,1)],[s(:,2) d(:,2)],[s(:,3) d(:,3)],'color',edges.color,...
                              'linewidth',edges.thickness,'hittest','off','ButtonDownFcn',...
                              'probe_geometry_axes_ButtonDownFcn');
        end
        i = sd_data_SetMeasList(ml);
        h_edges(i) = h_edges;
    end


    % Draw nodes over edges so that they're not obscured 
    axes_view='xy';
    if(~isempty(optpos))
        % Draw grid that fits the probe
        resize_axes(hObject, optpos);
        axes_view = set_view_probe_geometry_axes(hObject,optpos);

        for i=1:size(optpos_src,1)
            s=optpos_src(i,:);
            h_nodes_s(i)=text(s(1),s(2),s(3),num2str(i),'color',fc_s(1,:),...
                              'fontweight','bold','fontsize',fs(1),...
                              'verticalalignment','middle','horizontalalignment','center');
            set(h_nodes_s(i),'hittest','off');
            set(h_nodes_s(i),'ButtonDownFcn','probe_geometry_axes_ButtonDownFcn');
        end
        for j=1:size(optpos_det,1)
            d=optpos_det(j,:);
            h_nodes_d(j)=text(d(1),d(2),d(3),num2str(j),'color',fc_d(1,:),...
                              'fontweight','bold','fontsize',fs(1),...
                              'verticalalignment','middle','horizontalalignment','center');
            set(h_nodes_d(j),'hittest','off');
            set(h_nodes_d(j),'ButtonDownFcn','probe_geometry_axes_ButtonDownFcn');
        end
        for j=1:size(optpos_dummy,1)
            d=optpos_dummy(j,:);
            h_nodes_dummy(j)=text(d(1),d(2),d(3),num2str(j),'color',fc_d(1,:),...
                                  'fontweight','bold','fontsize',fs(1),'visible','off',...
                                  'verticalalignment','middle','horizontalalignment','center');                                  
        end

    end

    % Save user selections to axes user data 
    probe_geometry_axes_data.optselect=optselect;
    probe_geometry_axes_data.h_nodes_s=h_nodes_s;
    probe_geometry_axes_data.h_nodes_d=h_nodes_d;
    probe_geometry_axes_data.h_nodes_dummy=h_nodes_dummy;
    probe_geometry_axes_data.edges.handles=h_edges;
    probe_geometry_axes_data.view=axes_view;
    probe_geometry_axes_data.threshold = set_threshold(optpos);
    set(hObject,'userdata',probe_geometry_axes_data);

    if get(handles.radiobuttonSpringEnable,'value')==0
        probe_geometry_axes_Hide(handles,'on');
    else
        probe_geometry_axes_Hide(handles,'off');
    end
