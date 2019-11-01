function wavelength_edit_Callback(hObject, eventdata, handles)
% hObject    handle to wavelength1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wavelength1_edit as text
%        str2double(get(hObject,'String')) returns contents of wavelength1_edit as a double

    set(hObject,'enable','off');
    set(hObject,'backgroundcolor',[.7 .7 .7]);
    set(hObject,'foregroundcolor',[0 0 0]);

    h(1) = handles.wavelength1_edit;
    h(2) = handles.wavelength2_edit;
    h(3) = handles.wavelength3_edit;

    wli = cell(3,1);
    wlo = cell(3,1);
    wli{1} = str2num(get(h(1),'string'));
    wli{2} = str2num(get(h(2),'string'));
    wli{3} = str2num(get(h(3),'string'));

    % Get lambda
    j=1;
    lambda=[];
    for i=1:length(wli)
        if(~isempty(wli{i}))
            lambda(j)=wli{i};
            wlo{j}=wli{i};
            j=j+1;
        end
    end

    % Update SD data
    nwl=sd_data_GetNwl();
    sd_data_Set('Lambda',lambda);
    if(nwl~=length(lambda))
        sd_data_SetSrcMapDefault(length(lambda)); 
        ml=sd_data_GetMeasList();
        sd_data_SetMeasList(ml);
    end   

    % Update gui
    for i=1:length(wlo)
        set(h(i),'string',wlo{i});
    end
    optode_src_tbl_srcmap_show_UpdateSrcTbl(handles);
