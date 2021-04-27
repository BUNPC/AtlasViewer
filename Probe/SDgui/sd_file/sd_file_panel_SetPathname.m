function sd_file_panel_SetPathname(handles, pathname)

if isempty(pathname) || ~ischar(pathname)
    pathname = filesepStandard(pwd);
end

if get(handles.checkboxViewFilePath,'value')==1
    set(handles.editFolderName, 'visible','on');
    set(handles.textFolderName, 'visible','on');
else
    set(handles.editFolderName, 'visible','off');
    set(handles.textFolderName, 'visible','off');
end

% Make font smaller and text box bigger for really long paths
if ismac()
    fsize_orig = 12.0;
else
    fsize_orig = 9.0;
end

set(handles.editFolderName, 'units','characters');
pos = get(handles.editFolderName, 'position');
if length(pathname) > pos(3)
    fsize = fsize_orig-1;
else
    fsize = fsize_orig;
end
set(handles.editFolderName, 'string', filesepStandard(pathname), 'fontsize', fsize, 'units','normalized');
                          
