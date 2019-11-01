function probe_geometry_axes2_ButtonDownFcn(hObject, eventdata, handles)

   if isempty(hObject)
       hObject = handles.probe_geometry_axes2;
   end
    
   probe_geometry_axes2_data = get(hObject,'userdata');
   optselect                 = probe_geometry_axes2_data.optselect;
   h_nodes                   = probe_geometry_axes2_data.h_nodes;
   edges                     = probe_geometry_axes2_data.edges;
   h_edges                   = edges.handles;
   axes_view                 = probe_geometry_axes2_data.view;
   fs                        = probe_geometry_axes2_data.fontsize;
   fc                        = probe_geometry_axes2_data.fontcolor;
   fc_dummy                  = probe_geometry_axes2_data.fontcolor_dummy;
   threshold                 = probe_geometry_axes2_data.threshold;
   noptorig                  = probe_geometry_axes2_data.noptorig;
    
   % Set threshold level
   l = 2;
   
   optpos = getOptPosFromAxes(h_nodes);
   if isempty(optpos)
       return;
   end
   
   sl = sd_data_GetSpringList();
   k = [];
   j = [];
   pos2=[];
   pos1=[];

    % The addition of the class(eventdata) condition is for Matlab 2014b compatibility
    if isempty(eventdata) | strcmp(class(eventdata), 'matlab.graphics.eventdata.Hit')
        
       pos = get(hObject,'currentpoint');
       p = get_pt_from_buttondown(pos,optpos,axes_view);
   
       % Check if a node was already selected
       k=find(optselect);
       if ~isempty(k) 
           pos2 = optpos(k,:);
       end
       
        % Check if a node was selected with the
        optposTmp = optpos; optposTmp(:,3)=0; pTmp=p; pTmp(:,3)=0; % did this because we don't select points in 3D
       [foo j d]=nearest_point(optposTmp,pTmp);
       if ~isempty(j) && d<threshold(l)
           optselect(j) = ~optselect(j);
           if optselect(j)==1 && j<=noptorig
               set(h_nodes(j),'fontweight','bold','fontsize',fs(2),'color',fc(2,:));
           elseif optselect(j)==0 && j<=noptorig
               set(h_nodes(j),'fontweight','bold','fontsize',fs(1),'color',fc(1,:));
           elseif optselect(j)==1 && j>noptorig
               set(h_nodes(j),'fontweight','bold','fontsize',fs(2),'color',fc_dummy(2,:));
           elseif optselect(j)==0 && j>noptorig
               set(h_nodes(j),'fontweight','bold','fontsize',fs(1),'color',fc_dummy(1,:));
           end
           pos1 = optpos(j,:);
       end
   
   elseif ~isempty(sl)
       
       k=eventdata(1);
       j=eventdata(2);
       
       pos1 = optpos(k,:);
       pos2 = optpos(j,:);
   end
    
   % If 2 nodes were selected, draw a line between them 
   if ~isempty(pos2) & ~isempty(pos1)

       if(~isempty(sl))
           i=find((sl(:,1)==j & sl(:,2)==k) | (sl(:,1)==k & sl(:,2)==j));
       else
           i=[];
       end
       
       % Check whether the spring alreasy exists in sl
       if isempty(i) && j~=k
           
           n=length(h_edges);
           
           pos1_0 = pos1;
           pos2_0 = pos2;
           pts(1,:) = points_on_line(pos2,pos1,0.20);
           pts(2,:) = points_on_line(pos1,pos2,0.20);
           userdata.xdata = [pos2(1) pos1(1)];
           userdata.ydata = [pos2(2) pos1(2)];
           userdata.zdata = [pos2(3) pos1(3)];
           pos2 = pts(1,:);
           pos1 = pts(2,:);
           h_edges(n+1) = line([pos2(1,1) pos1(1,1)],[pos2(1,2) pos1(1,2)],[pos2(1,3) pos1(1,3)],...
                               'color',edges.color,'linewidth',edges.thickness,'userdata',userdata);
           sl(end+1,:) = [k j dist3(pos2_0,pos1_0)];


           % We want the optodes to be drawn over the new edge
           % so redraw the two the are involved in the measurement 
           % pair
           h_nodes(k)=redraw_text(h_nodes(k));
           h_nodes(j)=redraw_text(h_nodes(j));
            
           % Update SD Spring List
           [sl i]=sd_data_SetSpringList(sl);
           h_edges(i) = h_edges;

           % Update optode spring table showing new spring list
           kk=find((sl(:,1)==k & sl(:,2)==j));
           optode_spring_tbl_Update(handles,sl,kk,'add');
           
           set(h_edges(kk),'ButtonDownFcn',sprintf('probe_geometry_axes2_edges_ButtonDownFcn(gcbo,[%d],guidata(gcbo))',kk));
           for ii=kk+1:n+1
               set(h_edges(ii),'ButtonDownFcn',sprintf('probe_geometry_axes2_edges_ButtonDownFcn(gcbo,[%d],guidata(gcbo))',ii));
           end

       elseif ~isempty(i) 
            
           for jj=i+1:length(h_edges)
              set(h_edges(jj),'ButtonDownFcn',sprintf('probe_geometry_axes2_edges_ButtonDownFcn(gcbo,[%d],guidata(gcbo))',jj-1));
           end
           delete(h_edges(i));
           h_edges(i)=[];

           % Update optode spring table showing new spring list
           optode_spring_tbl_Update(handles,sl,i,'delete');
           
       end


       optselect([k,j])=0;
       if j<=noptorig
           set(h_nodes(j),'fontweight','bold','fontsize',fs(1),'color',fc(1,:));
       else
           set(h_nodes(j),'fontweight','bold','fontsize',fs(1),'color',fc_dummy(1,:));
       end
       if k<=noptorig
           set(h_nodes(k),'fontweight','bold','fontsize',fs(1),'color',fc(1,:));
       else
           set(h_nodes(k),'fontweight','bold','fontsize',fs(1),'color',fc_dummy(1,:));
       end
    
   end


   % Save the changes the user made
   probe_geometry_axes2_data.optselect=optselect;
   probe_geometry_axes2_data.edges.handles=h_edges;
   probe_geometry_axes2_data.h_nodes = h_nodes;
   set(hObject,'userdata',probe_geometry_axes2_data);

