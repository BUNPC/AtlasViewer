function optode_det_tbl_CellEditCallback(hObject, eventdata, handles)

if isempty(eventdata.Indices)
    return
end
r = eventdata.Indices(1);
c = eventdata.Indices(2);
tbl_data = get(hObject,'data');
userdata = get(hObject, 'userdata');
tbl_size = userdata.tbl_size;

ncoord = sd_data_GetCoordNum();
detdata = zeros(1, ncoord);
action = '';

% Error check
[tbl_data_src, tbl_size_src] = optode_src_tbl_get_tbl_data(handles);
if error_check_optode_tbls(tbl_data, tbl_data_src, r, c) ~= 0
    return;
end

% Otherwise we have legitimate data
[l, tbl_data] = optode_tbl_GetCellLengths(tbl_data, r);
if all(l>0)
    
    for i = 1:ncoord
        detdata(i) = str2double(tbl_data{r,i});
    end

    % Edit row
    if r<=tbl_size
        action = 'edit';        

    % Add row
    elseif r>tbl_size
        action = 'add';
        if r>tbl_size+1
            tbl_data(tbl_size+1:r-1, :) = [];
            r = tbl_size+1;
        end
        tbl_size = tbl_size+1;
        optode_dummy_tbl_UpdateNum(handles, tbl_size+tbl_size_src);
    end
    
    % Update Axes
    probe_geometry_axes_DetUpdate(handles, detdata, r, action);
    probe_geometry_axes2_OptUpdate(handles, detdata, r, action, 'det');
    
elseif all(l==0) && r<=tbl_size
    
    tbl_size = tbl_size-1;
    tbl_data(end+1,:) = {''};
    tbl_data(r,:) = [];
    
    % Update Axes
    probe_geometry_axes_DetUpdate(handles, [], r, 'delete');
    probe_geometry_axes2_OptUpdate(handles, [], r, 'delete', 'det');
    optode_dummy_tbl_UpdateNum(handles, tbl_size+tbl_size_src);
    
else
    
    return 
    
end


%%%% Update SD

% DetPos
sd_data_SetDetPos(tbl_data(1:tbl_size,:))

% GrommetType 
sd_data_SetDetGrommetType(tbl_data(1:tbl_size, ncoord+1))

% Update table
optode_tbl_Update(hObject, tbl_data, tbl_size, r, c);


