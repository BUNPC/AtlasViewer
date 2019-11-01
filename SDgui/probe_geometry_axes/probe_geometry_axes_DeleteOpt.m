function probe_geometry_axes_DeleteOpt(handles, isrc, idet)

% Mimic the process of deleting optodes manually throught the GUI table optode_src_tbl 
isrc = sort(isrc);
for ii=1:length(isrc)
    tbl_src_data = get(handles.optode_src_tbl, 'data');
    for jj=1:3
        tbl_src_data{isrc(ii),jj} = '';
    end
    set(handles.optode_src_tbl, 'data', tbl_src_data);
    eventdata.Indices(1) = isrc(ii);
    eventdata.Indices(2) = 3;
    optode_src_tbl_CellEditCallback(handles.optode_src_tbl, eventdata, handles);
    isrc=isrc-1;
end

% Mimic the process of deleting optodes manually throught the GUI table optode_det_tbl 
idet = sort(idet);
for ii=1:length(idet)
    tbl_det_data = get(handles.optode_det_tbl, 'data');
    for jj=1:3
        tbl_det_data{idet(ii),jj} = '';
    end
    set(handles.optode_det_tbl, 'data', tbl_det_data);
    eventdata.Indices(1) = idet(ii);
    eventdata.Indices(2) = 3;
    optode_det_tbl_CellEditCallback(handles.optode_det_tbl, eventdata, handles);
    idet=idet-1;
end

