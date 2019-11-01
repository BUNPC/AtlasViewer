function sd_file_panel_SetPathname(handles,pathname)

hObject = handles.sd_file_panel;

if isempty(pathname) || ~ischar(pathname)
    pathname = pwd;
end
pathname(pathname=='\') = '/';
if pathname(end) ~= '/'
    pathname(end+1) = '/';
end

if get(handles.checkboxViewFilePath,'value')==1
    set(handles.textViewFilePath, 'visible','on');
else
    set(handles.textViewFilePath, 'visible','off');
end

% Make font smaller and text box bigger for really long paths
if ismac()
    fsize_orig = 12.0;
else
    fsize_orig = 8.0;
end

set(handles.textViewFilePath, 'units','characters');
pos = get(handles.textViewFilePath, 'position');
if length(pathname) > pos(3)
    fsize = fsize_orig-1;
    align = 'left';
else
    fsize = fsize_orig;    
    align = 'center';
end
set(handles.textViewFilePath, 'string', pathname, 'fontsize', fsize, ...
                              'units','normalized', 'horizontalalignment',align);
                          
