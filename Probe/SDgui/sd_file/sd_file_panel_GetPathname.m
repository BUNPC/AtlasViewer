function pathname = sd_file_panel_GetPathname(handles)
pathname = filesepStandard(get(handles.editFolderName, 'string'));
if isempty(pathname)
    pathname = filesepStandard(pwd);
end
