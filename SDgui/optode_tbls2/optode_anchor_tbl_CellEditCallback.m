function optode_anchor_tbl_CellEditCallback(hObject, eventdata, handles)

    tbl_data = get(hObject,'data');
    ncols=size(tbl_data,2);
    userdata = get(hObject, 'userdata');
    tbl_size = userdata.tbl_size;
    tbl_data_prev = userdata.tbl_data;
    r=eventdata.Indices(1);
    c=eventdata.Indices(2);
    
    optpos_src = sd_data_Get('SrcPos');
    optpos_det = sd_data_Get('DetPos');
    optpos_dummy = sd_data_Get('DummyPos');
    
    optpos = [optpos_src; optpos_det; optpos_dummy];
    nopt = size(optpos,1);
    
    % Error check
    if optode_anchor_tbl_ErrCheck(tbl_data,tbl_size,r,c,nopt)
        set(hObject,'data',tbl_data_prev);
        return;
    end

    for i=1:ncols
        l(i)=length(tbl_data{r,i});
    end
    
    if all(l>0)
        
        % Editing entry
        if(r<=tbl_size)            
            action = 'edit';

        % Adding entry
        elseif(r>tbl_size)
            action = 'add';

            if(r>tbl_size+1)
                tbl_data(tbl_size+1:r-1,:)=[];
                r = tbl_size+1;
            end
            tbl_size=tbl_size+1;

        end
        
        sd_data_SetAnchorList(tbl_data,tbl_size);

    % Deleting entry
    elseif(all(l==0) & r<=tbl_size)

        tbl_size=tbl_size-1;
        tbl_data(r,:)=[];
        
        sd_data_SetAnchorList(tbl_data,tbl_size);
        
    end


    set(hObject,'data',tbl_data);
    userdata.tbl_size = tbl_size;
    userdata.tbl_data = tbl_data;
    set(hObject,'userdata',userdata);
