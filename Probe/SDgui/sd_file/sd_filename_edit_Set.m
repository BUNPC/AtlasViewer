function sd_filename_edit_Set(handles, filename)
if ~isempty(filename)
    [~, fname, ext] = fileparts(filename);
    filename = [fname, ext];
end
set(handles.sd_filename_edit, 'string',filename);

