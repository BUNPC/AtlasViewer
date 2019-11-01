function optode_src_tbl_srcmap_show_Callback(hObject, eventdata, handles)
% --- Executes on button press in optode_tbl_src_map_hide.
% hObject    handle to optode_tbl_src_map_hide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of optode_tbl_src_map_hide

val=get(hObject,'value');
tbl_data = optode_src_tbl_get_tbl_data(handles);
ncols=size(tbl_data,2);
tbl_size = optode_src_tbl_GetSize(handles);
cnames={'x','y','z'};
cwidth={40,40,40};
ceditable=logical([1 1 1]);
if(val==0)
    tbl_data=tbl_data(:,1:3);
else
    srcmap=sd_data_Get('SrcMap');
    nwl_prev=ncols-3;
    nwl=sd_data_GetNwl();
    nSrcs=sd_data_Get('nSrcs');
    for j=1:nwl
        tbl_data(:,3+j)={''};
        for i=1:nSrcs
            tbl_data{i,3+j}=num2str(srcmap(j,i));
        end
        cnames{end+1}=['l' num2str(j)];
        cwidth{end+1}=20;
        ceditable(end+1)=logical(1);
    end
    
    % If there used to be more wavelengths than currently 
    % delete the extra columns in table representing the deleted
    % wavelengths
    if(nwl_prev > nwl)
        tbl_data(:,3+nwl+1:3+nwl_prev)=[];
    end
end
set(handles.optode_src_tbl,'Data',tbl_data,'ColumnName',cnames,'ColumnWidth',...
    cwidth,'ColumnEditable',ceditable);
