function optode_dummy_tbl_CellEditCallback(hObject, eventdata, handles)

if isempty(eventdata.Indices)
    return
end
r = eventdata.Indices(1);
c = eventdata.Indices(2);
tbl_data = get(hObject,'data');
userdata = get(hObject, 'userdata');
tbl_size = userdata.tbl_size;

coordColIdx = 2;
coordCols = coordColIdx : coordColIdx + sd_data_GetCoordNum()-1;
dummydata = [];noptreal = sd_data_Get('nsrcs') + sd_data_Get('ndets');

% Error check
if(c <= 4)
    if(error_check_optode_dummy_tbl(hObject, tbl_data, r, c) ~= 0)
        return;
    end
end

% Test to see if a row was added or deleted
[l, tbl_data] = optode_tbl_GetCellLengths(tbl_data, r, coordCols);
if(all(l>0))
    j=1;
    for i = coordCols
        dummydata(j) = str2num(tbl_data{r,i});
        j = j+1;
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
        tbl_data{r,1} = num2str(noptreal+tbl_size);
    end
    
    % Update Axes
    probe_geometry_axes2_OptUpdate(handles, dummydata(1:3), r, action, 'dummy');
    
    % This is done purely for synching axes sizes (axes1 and axes2)
    % which are calculated from the max/min positions of all the
    % optodes including dummy ones. Basically the same dummy optodes are
    % part of the axes1 but we don't want them to be visible in axes1.
    probe_geometry_axes_DummyUpdate(handles, dummydata(1:3), r, action);
    
elseif all(l==0) && r<=tbl_size
    
    for ii=r+1:tbl_size
        tbl_data{ii,1} = num2str(str2num(tbl_data{ii,1})-1);
    end
    tbl_size = tbl_size-1;
    tbl_data(r,:) = [];
    
    % Update Axes
    probe_geometry_axes2_OptUpdate(handles, [], r, 'delete', 'dummy');
    
    % This is done purely for synching axes sizes (axes1 and axes2)
    % which are calculated from the max/min positions of all the
    % optodes including dummy ones. Basically the same dummy optodes are
    % part of the axes1 but we don't want them to be visible in axes1.
    probe_geometry_axes_DummyUpdate(handles, [], r, 'delete');
    
else
    
    return 
    
end

% Update SD
sd_data_SetDummyPos(tbl_data(1:tbl_size, coordCols));

% GrommetType 
sd_data_SetDummyGrommetType(tbl_data(1:tbl_size, coordCols(end)+1))

%%%% Add source map to table data
userdata.tbl_size = tbl_size;
set(hObject,'data',tbl_data,'userdata',userdata);
