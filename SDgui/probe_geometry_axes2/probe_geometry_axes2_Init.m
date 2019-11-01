function probe_geometry_axes2_Init(handles,optpos,noptorig,sl)

% Function populates the gui axis and tables with data 
% from SD structure


   hObject = handles.probe_geometry_axes2;

   % Make the axes the current axes 
   axes(hObject);
   cla;

   probe_geometry_axes2_data = get(hObject,'userdata');
   fs        = probe_geometry_axes2_data.fontsize;
   fc        = probe_geometry_axes2_data.fontcolor;
   fc_dummy  = probe_geometry_axes2_data.fontcolor_dummy;
   edges     = probe_geometry_axes2_data.edges;


   % Initialize user selections 
   optselect=zeros(size(optpos,1),1);

   h_nodes=[];
   h_edges=[];
   nspr  = size(sl,1);
    
   % Draw edges first before nodes 
   if(~isempty(sl))
       h_edges=zeros(nspr,1);
       for i=1:nspr
           o1=optpos(sl(i,1),:);
           o2=optpos(sl(i,2),:);
           hold on;
           pts(1,:) = points_on_line(o1,o2,0.20);
           pts(2,:) = points_on_line(o2,o1,0.20);
           userdata.xdata = [o1(1) o2(1)];
           userdata.ydata = [o1(2) o2(2)];
           userdata.zdata = [o1(3) o2(3)];
           o1 = pts(1,:);
           o2 = pts(2,:);
           if sl(i,3)>0
               linestyle='-';
           elseif sl(i,3)==-1
               linestyle='--';
           end
           h_edges(i) = line([o1(:,1) o2(:,1)],[o1(:,2) o2(:,2)],[o1(:,3) o2(:,3)],'color',edges.color,...
                             'linewidth',edges.thickness,'linestyle',linestyle,'userdata',userdata,'visible','off',...
                             'ButtonDownFcn',sprintf('probe_geometry_axes2_edges_ButtonDownFcn(gcbo,[%d],guidata(gcbo))',i));
       end
   end


   % Draw nodes over edges so that they're not obscured 
   axes_view='xy';
   if(~isempty(optpos))
       % Draw grid that fits the probe
       resize_axes(hObject, optpos);
       axes_view=set_view_probe_geometry_axes2(hObject,optpos);

       for i=1:size(optpos,1)
           o=optpos(i,:);
           if i<=noptorig
               col=fc;
           else
               col=fc_dummy;
           end
           h_nodes(i)=text(o(1),o(2),o(3),num2str(i),'color',col(1,:),...
                           'fontweight','bold','fontsize',fs(1),...
                           'verticalalignment','middle','horizontalalignment','center');                           
           set(h_nodes(i),'hittest','off');
           set(h_nodes(i),'ButtonDownFcn','probe_geometry_axes2_ButtonDownFcn');
       end
    end

    % Save user selections to axes user data 
    probe_geometry_axes2_data.optselect=optselect;
    probe_geometry_axes2_data.h_nodes=h_nodes;
    probe_geometry_axes2_data.edges.handles=h_edges;
    probe_geometry_axes2_data.view=axes_view;
    probe_geometry_axes2_data.view=axes_view;
    probe_geometry_axes2_data.noptorig = noptorig;
    probe_geometry_axes2_data.threshold = set_threshold(optpos);
    set(hObject,'userdata',probe_geometry_axes2_data);


    if get(handles.radiobuttonSpringEnable,'value')==0
        probe_geometry_axes2_Hide(handles,'off');
    else
        probe_geometry_axes2_Hide(handles,'on');
    end
