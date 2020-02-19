function optode_src_tbl_CellEditCallback(hObject, eventdata, handles)

tbl_data = get(hObject,'data');
ncoord = sd_data_GetCoordNum();
userdata = get(hObject, 'userdata');
tbl_size = userdata.tbl_size;
r = eventdata.Indices(1);
c = eventdata.Indices(2);
srcdata = zeros(1, ncoord);
l = zeros(1, ncoord);
action = '';


%%%% Error check
[tbl_data_det, tbl_size_det] = optode_det_tbl_get_tbl_data(handles);
if error_check_optode_tbls(hObject, tbl_data, tbl_data_det, r, c) ~= 0
    return;
end

%%%% Update source positions portion of data table
for i = 1:ncoord
    l(i) = length(tbl_data{r,i});
end
if all(l>0)
    
    for i = 1:ncoord
        srcdata(i) = str2double(tbl_data{r,i});
    end
    
    % Edit row
    if r <= tbl_size
        action = 'edit';

    % Add row
    elseif r > tbl_size
        action = 'add';
        if(r>tbl_size+1)
            tbl_data(tbl_size+1:r-1,:) = [];
            r = tbl_size+1;
        end
        tbl_size = tbl_size+1;        
        optode_dummy_tbl_UpdateNum(handles, tbl_size+tbl_size_det);
    end
    
    % Update Axes
    probe_geometry_axes_SrcUpdate(handles, srcdata(1:ncoord), r, action);
    probe_geometry_axes2_OptUpdate(handles, srcdata(1:ncoord), r, action, 'src');
    
elseif all(l==0)
    
    tbl_size = tbl_size-1;
    tbl_data(r,:) = [];
        
    % Update Axes
    probe_geometry_axes_SrcUpdate(handles, [], r, 'delete');
    probe_geometry_axes2_OptUpdate(handles, [], r, 'delete', 'src');
    optode_dummy_tbl_UpdateNum(handles, tbl_size+tbl_size_det);
    
else
    
    return 
    
end


%%%% Update SD

% SrcPos
sd_data_SetSrcPos(tbl_data(1:tbl_size,:))

% SrcMap
sd_data_SetSrcMap()

%%%% Add source map to table data
if get(handles.optode_src_tbl_srcmap_show, 'value')
    srcmap = sd_data_Get('SrcMap');
    nwl = sd_data_GetNwl();
    offset = ncoord+1;
    tbl_data(:, offset+1:end) = {''};
    for iWl = 1:nwl
        for iSrc = 1:tbl_size
            tbl_data{iSrc, iWl+offset} = num2str(srcmap(iWl, iSrc));
        end
    end
end

%%%% Update the data property of table object
set(hObject,'data',tbl_data);
userdata.tbl_size = tbl_size;
set(hObject,'userdata',userdata);

