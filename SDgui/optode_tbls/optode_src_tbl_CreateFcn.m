function optode_src_tbl_CreateFcn(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
% hObject    handle to optode_src_tbl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    A=repmat({'' '' ''},100,1);
    cnames={'x','y','z'};
    cwidth={40,40,40};
    ceditable=logical([1 1 1]);
    
    % The addition of the class(eventdata) condition is for Matlab 2014b compatibility
    if ~isempty(eventdata) & ~isempty(handles) & eventdata==1 & ...
       ~strcmp(class(eventdata), 'matlab.ui.eventdata.ActionData') 
        srcmap=sd_data_Get('SrcMap');
        nwl=1;
        nSrcs=0;
        for j=1:nwl
            A(:,3+j)={''};
            for i=1:nSrcs
                A{i,3+j}=num2str(srcmap(j,i))
            end
            cnames{end+1}=['l' num2str(j)];
            cwidth{end+1}=20;
            ceditable(end+1)=logical(1);
        end
    end
    set(hObject,'Data',A,'ColumnName',cnames,'ColumnWidth',cwidth,'ColumnEditable',ceditable);
    userdata.tbl_size = 0;
    userdata.selection = [];
    set(hObject,'userdata',userdata);
