function probe_geometry_axes2_OptUpdate(handles,opos1,i,event,mode)

    hObject = handles.probe_geometry_axes2;

    probe_geometry_axes2_data = get(hObject,'userdata');
    optselect                 = probe_geometry_axes2_data.optselect;
    h_nodes                   = probe_geometry_axes2_data.h_nodes;
    edges                     = probe_geometry_axes2_data.edges;
    h_edges                   = edges.handles;
    noptorig                  = probe_geometry_axes2_data.noptorig;
    fs                        = probe_geometry_axes2_data.fontsize;
    if strcmp(mode,'dummy')
       fc       = probe_geometry_axes2_data.fontcolor_dummy;
    else
       fc       = probe_geometry_axes2_data.fontcolor;
    end

    % Get the source positions from the axes gui object
    optpos = getOptPosFromAxes(h_nodes);
    nopt   = length(h_nodes);
    sl     = sd_data_GetSpringList();
    al     = sd_data_GetAnchorList();
        
    axes(hObject);
    

    if strcmp(mode,'dummy')
        i=i+noptorig;
        visible='on';
    elseif strcmp(mode,'det')
        nsrc = sd_data_Get('nsrcs');
        i=i+nsrc;
        
        % For mode='src' or 'det', this function is called when the src or det tbls 
        % are edited by the user, ie. when we're in 'Add Springs'. When this event 
        % happens we want to also modify this axes (axes2) but since we're not in 
        % 'Add Springs' mode we don't want any of it's nodes made visible.
        visible='off';
    elseif strcmp(mode,'src')

        % For mode='src' or 'det', this function is called when the src or det tbls 
        % are edited by the user, ie. when we're in 'Add Springs'. When this event 
        % happens we want to also modify this axes (axes2) but since we're not in 
        % 'Add Springs' mode we don't want any of it's nodes made visible.
        visible='off';
    end

    switch lower(event)
    case {'add'}
        % Before adding new optode, make room for it by increment 
        % all optode numbers greater the new optode.
        for k=nopt:-1:i
            h_nodes(k+1)=h_nodes(k);              
            set(h_nodes(k+1), 'string',num2str(k+1));
            optselect(k+1)=optselect(k);
        end
        
        % Now add new optode
        h_nodes(i)=text(opos1(1),opos1(2),opos1(3),num2str(i),'color',fc(1,:),...
                        'fontweight','bold','fontsize',fs(1),'visible',visible,...
                        'verticalalignment','middle','horizontalalignment','center');
        uistack(h_nodes(i),'top');
        set(h_nodes(i),'hittest','off');
        set(h_nodes(i),'ButtonDownFcn','probe_geometry_axes2_ButtonDownFcn');
        optselect(i)=0;
        
        % If optode was inserted to optode list in the middle rather 
        % (as when a source is added) all optodes with greater or equal 
        % indices have to be incremented. Same idea as making room new optode 
        % in h_nodes and optselect above.
        if ~isempty(sl)
            [i1 i2] = find(sl(:,[1,2]) >= i);
            for k=1:length(i1)
                sl(i1(k),i2(k)) = sl(i1(k),i2(k))+1;
            end
        end

        if ~isempty(al)
            for k=1:size(al,1)
                if str2num(al{k,1}) >= i
                    al{k,1} = num2str(str2num(al{k,1})+1);
                end
            end
        end
        
        if strcmp(mode,'src') || strcmp(mode,'det')
            noptorig = noptorig+1;
        end
        
    case {'delete'}
        % Delete optode from axes
        for j=i:length(h_nodes)-1
            set(h_nodes(j+1),'string',num2str(j));
        end
        delete(h_nodes(i));
        h_nodes(i)=[];

        % Delete entry from source gui selection array
        optselect(i)=[];

        % Delete all edges representing measurement pairs 
        % associated with this optode
        if(~isempty(sl))

            % Delete from anchor list
            j=find(sl(:,1)==i | sl(:,2)==i);
            delete(h_edges(j));
            h_edges(j)=[];
            sl(j,:)=[];
            
            % There's one less optode: so for all indices in sl 
            % greater than the index for the deleted optode, 
            % decrement index to reflect one less optode.
            j=find(sl(:,1) > i);
            sl(j,1) = sl(j,1)-1;
            k=find(sl(:,2) > i);
            sl(k,2) = sl(k,2)-1;
            
            %for ii=1:length(j)
            %    sl(j(ii),k(ii)) = sl(j(ii),k(ii))-1;
            %end
            
            % Delete from anchor list
            [i1 i2]=find(strcmp(al,num2str(i)));
            al(i1,:)=[];
                  
            % There's one less optode: so for all indices in al 
            % greater than the index for the deleted optode, 
            % decrement index to reflect one less optode.
            for k=1:size(al,1)
                if str2num(al{k,1}) > i
                    al{k,1} = num2str(str2num(al{k,1})-1);
                end
            end
        end
        
        if strcmp(mode,'src') || strcmp(mode,'det')
            noptorig = noptorig-1;
        end
        
    case {'edit'}
        % Draw new node position 
        set(h_nodes(i),'position',opos1);

        % Since position of optode changed, update all edges 
        % for the measurement pairs associated with this optode
        if(~isempty(sl))
            j=find(sl(:,1)==i);
            for ii=1:length(j)
                opos2=optpos(sl(j(ii),2),:);
                
                pts(1,:) = points_on_line(opos1,opos2,0.20);
                pts(2,:) = points_on_line(opos2,opos1,0.20);
                p1 = pts(1,:);
                p2 = pts(2,:);
                userdata.xdata = [opos1(1) opos2(1)];
                userdata.ydata = [opos1(2) opos2(2)];
                userdata.zdata = [opos1(3) opos2(3)];                
                set(h_edges(j(ii)),'xdata',[p1(1) p2(1)], 'ydata',[p1(2) p2(2)], 'zdata',[p1(3) p2(3)],...
                                   'userdata',userdata);

                % Recalculate distance for all springs with node i if it's
                % a stiff spring
                if sl(j(ii),3)>=0
                   sl(j(ii),3) = dist3(opos1, opos2);
                end
            end
            
            k=find(sl(:,2)==i);
            for ii=1:length(k)
                opos2=optpos(sl(k(ii),1),:);
                
                pts(1,:) = points_on_line(opos2,opos1,0.20);
                pts(2,:) = points_on_line(opos1,opos2,0.20);
                p1 = pts(1,:);
                p2 = pts(2,:);
                userdata.xdata = [opos2(1) opos1(1)];
                userdata.ydata = [opos2(2) opos1(2)];
                userdata.zdata = [opos2(3) opos1(3)];                
                set(h_edges(k(ii)),'xdata',[p2(1) p1(1)], 'ydata',[p2(2) p1(2)], 'zdata',[p2(3) p1(3)],...
                                   'userdata',userdata);

                % Recalculate distance for all springs with node i if it's
                % a stiff spring
                if sl(k(ii),3)>=0
                   sl(k(ii),3) = dist3(opos2, opos1);
                end
            end
        end

        % Redraw nodes that might have been obscured by 
        % the redrawn edges 
        % h_nodes=redraw_text_many(h_nodes);
        uistack(h_edges,'bottom');
    end
    
    % Update tables so that they match what new drawn in axes2
    optode_spring_tbl_Update(handles,sl);
    optode_anchor_tbl_Update(handles,al);
    
    % Update SD data
    [sl k] = sd_data_SetSpringList(sl);
    sd_data_SetAnchorList(al);
    h_edges(k) = h_edges;

    % Draw grid to fit the updated probe
    optpos = getOptPosFromAxes(h_nodes);
    resize_axes(hObject, optpos);
    axes_view=set_view_probe_geometry_axes2(hObject,optpos);

    % Update object's user data
    probe_geometry_axes2_data.optselect     = optselect;
    probe_geometry_axes2_data.edges.handles = h_edges;
    probe_geometry_axes2_data.h_nodes       = h_nodes;
    probe_geometry_axes2_data.view          = axes_view;
    probe_geometry_axes2_data.threshold     = set_threshold(optpos);
    probe_geometry_axes2_data.noptorig      = noptorig;
    set(hObject,'userdata',probe_geometry_axes2_data);
