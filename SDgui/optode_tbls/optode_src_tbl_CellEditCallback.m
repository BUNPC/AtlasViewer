function optode_src_tbl_CellEditCallback(hObject, eventdata, handles)

    tbl_data = get(hObject,'data');
    ncols=size(tbl_data,2);
    userdata = get(hObject, 'userdata');
    tbl_size = userdata.tbl_size;
    r=eventdata.Indices(1);
    c=eventdata.Indices(2);
    srcdata=[];
    
    % Error check
    [tbl_data_det tbl_size_det]=optode_det_tbl_get_tbl_data(handles);
    if(error_check_optode_tbls(hObject,tbl_data,tbl_data_det,r,c) ~= 0)
        return;
    end

    for i=1:ncols
        l(i)=length(tbl_data{r,i});
    end
    if(all(l>0))
        
        for i=1:ncols
            srcdata(i)=str2num(tbl_data{r,i});
        end        
        if(r<=tbl_size)
            action = 'edit';

            % Update SD 
            sd_data_SetSrcPos(r,srcdata(1:3));
            if(ncols>3)
                sd_data_SetSrcMapEntry(r,srcdata(4:end));
            end
        elseif(r>tbl_size)
            action = 'add';
            if(r>tbl_size+1)
                tbl_data(tbl_size+1:r-1,:)=[];
                r = tbl_size+1;
            end
            tbl_size=tbl_size+1;

            % Update SD 
            sd_data_AddSrcPos(r,srcdata(1:3));
            if(ncols==3)
                sd_data_SetSrcMapEntry(r);
            else
                sd_data_SetSrcMapEntry(r,srcdata(4:end));
            end            
            optode_dummy_tbl_UpdateNum(handles, tbl_size+tbl_size_det);
        end

        % Update Axes
        probe_geometry_axes_SrcUpdate(handles,srcdata(1:3),r,action);
        probe_geometry_axes2_OptUpdate(handles,srcdata(1:3),r,action,'src');
        
    elseif(all(l==0) & r<=tbl_size)
        
        tbl_size=tbl_size-1;
        tbl_data(r,:)=[];   

        % Update SD
        sd_data_DeleteSrcPos(r);
        sd_data_DeleteSrcMapEntry(r);

        % Update Axes
        probe_geometry_axes_SrcUpdate(handles,[],r,'delete');
        probe_geometry_axes2_OptUpdate(handles,[],r,'delete','src');
        optode_dummy_tbl_UpdateNum(handles, tbl_size+tbl_size_det);
        
    end
    set(hObject,'data',tbl_data);
    userdata.tbl_size = tbl_size;
    set(hObject,'userdata',userdata);
