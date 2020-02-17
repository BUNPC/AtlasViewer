function wavelength_edit_Callback(hObject, eventdata, handles)

h(1) = handles.wavelength1_edit;
h(2) = handles.wavelength2_edit;
h(3) = handles.wavelength3_edit;

if isempty(eventdata)
    wli = cell(3,1);
    wlo = cell(3,1);
    wli{1} = str2num(get(h(1), 'string'));
    wli{2} = str2num(get(h(2), 'string'));
    wli{3} = str2num(get(h(3), 'string'));
    
    % Get lambda
    j=1;
    for i=1:length(wli)
        if(~isempty(wli{i}))
            lambda(j) = wli{i};
            wlo{j} = wli{i};
            j = j+1;
        end
    end
    
    % Update gui
    for i = 1:length(wlo)
        set(h(i), 'string',wlo{i});
    end
    optode_src_tbl_srcmap_show_UpdateSrcTbl(handles);
    
else
    
    lambda = sd_data_Get('Lambda');
    lambda(eventdata(2)) = eventdata(1);

end

% Update SD data
nwl = sd_data_GetNwl();
sd_data_Set('Lambda',lambda);
if(nwl ~= length(lambda))
    sd_data_SetSrcMapDefault(length(lambda));
    ml = sd_data_GetMeasList();
    sd_data_SetMeasList(ml);
end

