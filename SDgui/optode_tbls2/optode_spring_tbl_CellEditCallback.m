function optode_spring_tbl_CellEditCallback(hObject, eventdata, handles)

    if isempty(hObject)
         hObject = handles.optode_spring_tbl;
    end
    tbl_data = get(hObject,'data');
    ncols=size(tbl_data,2);
    userdata = get(hObject, 'userdata');
    tbl_size = userdata.tbl_size;
    r=eventdata.Indices(1);
    c=eventdata.Indices(2);
    
    for i=1:ncols
        l(i)=length(tbl_data{r,i});
    end
    
    
    if all(l>0)
        
        optpos = [sd_data_Get('SrcPos'); sd_data_Get('DetPos')];
        if isempty(optpos)
            ch=menu('Can''t add springs to empty probe. First create probe with at least 2 optodes','OK');
            return;
        end

        % Editing entry
        if(r<=tbl_size)   
            new_data = [str2num(tbl_data{r,1}) str2num(tbl_data{r,2}) str2num(tbl_data{r,3})];
            % probe_geometry_axes2_ButtonDownFcn([], new_data, handles);
            %sd_data_AddEditSpring(r,new_data);
            
        % Adding entry
        elseif(r>tbl_size)
            action = 'add';
            if(r>tbl_size+1)
                tbl_data(tbl_size+1:r-1,:)=[];
                r = tbl_size+1;
            end
            tbl_size=tbl_size+1;
            new_data = [str2num(tbl_data{r,1}) str2num(tbl_data{r,2}) str2num(tbl_data{r,3})];
            %sd_data_AddEditSpring(r,new_data);
        end
        
    % Deleting entry
    elseif(all(l==0) & r<=tbl_size)
        tbl_size=tbl_size-1;
        tbl_data(r,:)=[];
        
        % Update SD
        %sd_data_DeleteSpring(r);

        % Update Axes
        % probe_geometry_axes2_ButtonDownFcn([], r, handles)

    end

    userdata.tbl_size = tbl_size;
    set(hObject,'data',tbl_data,'userdata',userdata);
