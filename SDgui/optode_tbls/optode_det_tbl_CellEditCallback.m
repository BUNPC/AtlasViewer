function optode_det_tbl_CellEditCallback(hObject, eventdata, handles)

    tbl_data = get(hObject,'data') ;
    ncols=size(tbl_data,2);
    userdata = get(hObject, 'userdata');
    tbl_size = userdata.tbl_size;
    r=eventdata.Indices(1);
    c=eventdata.Indices(2);
    detdata=[];
    
    % Error check
    [tbl_data_src tbl_size_src]=optode_src_tbl_get_tbl_data(handles);
    if(error_check_optode_tbls(hObject,tbl_data,tbl_data_src,r,c) ~= 0)
        return;
    end

    % Otherwise we have legitimate data
    for i=1:ncols
        l(i)=length(tbl_data{r,i});
    end
    if(all(l>0))
        for i=1:ncols
            detdata(i)=str2num(tbl_data{r,i});
        end
        detdata = [str2num(tbl_data{r,1}) str2num(tbl_data{r,2}) str2num(tbl_data{r,3})];
        if(r<=tbl_size)
            action = 'edit';

            % Update SD 
            sd_data_SetDetPos(r,detdata);
        elseif(r>tbl_size)
            action = 'add';
            if(r>tbl_size+1)
                tbl_data(tbl_size+1:r-1,:)=[];
                r = tbl_size+1;
            end
            tbl_size=tbl_size+1;

            % Update SD 
            sd_data_AddDetPos(r,detdata);
            optode_dummy_tbl_UpdateNum(handles, tbl_size+tbl_size_src);
        end

        % Update Axes
        probe_geometry_axes_DetUpdate(handles,detdata,r,action);
        probe_geometry_axes2_OptUpdate(handles,detdata,r,action,'det');

    elseif(all(l==0) & r<=tbl_size)
        tbl_size=tbl_size-1;
        tbl_data(r,:)=[];

        % Update SD
        sd_data_DeleteDetPos(r);

        % Update Axes
        probe_geometry_axes_DetUpdate(handles,[],r,'delete');
        probe_geometry_axes2_OptUpdate(handles,[],r,'delete','det');
        optode_dummy_tbl_UpdateNum(handles, tbl_size+tbl_size_src);
    end
    set(hObject,'data',tbl_data);
    userdata.tbl_size = tbl_size;
    set(hObject,'userdata',userdata);

