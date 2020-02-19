function wavelength_edit_Callback(hObject, eventdata, handles)

wstr{1} = get(handles.wavelength1_edit, 'string');
wstr{2} = get(handles.wavelength2_edit, 'string');
wstr{3} = get(handles.wavelength3_edit, 'string');

lambda = [];

kk = 1;
for ii=1:length(wstr)
    if isnumber(wstr{ii})
        lambda(kk) = str2double(wstr{ii});
        kk = kk+1;
    else
        eval( sprintf('set(handles.wavelength%d_edit, ''string'','''')', ii) )
    end
end

% Update SD data
sd_data_Set('Lambda',lambda);
sd_data_SetSrcMapDefault(length(lambda));
ml = sd_data_GetMeasList();
sd_data_SetMeasList(ml);

optode_src_tbl_Update(handles);