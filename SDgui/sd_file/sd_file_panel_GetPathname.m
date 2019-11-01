function pathname = sd_file_panel_GetPathname(handles)

pathname = get(handles.textViewFilePath, 'string');
if isempty(pathname)
    pathname = pwd;
end
pathname(pathname=='\') = '/';
if pathname(end) ~= '/'
    pathname(end+1) = '/';
end
