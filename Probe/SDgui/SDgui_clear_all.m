
function SDgui_clear_all(handles)
global SD

% Clear central data object first
SD = sd_data_Init();

if ~exist('handles','var') || isempty(handles)
    return;
end

% Clear Axes
probe_geometry_axes_Clear(handles);

% Clear Axes2
probe_geometry_axes2_Clear(handles);

% Clear source optode table
optode_src_tbl_Clear(handles);

% Clear detector optode table
optode_det_tbl_Clear(handles);

% Clear detector optode table
optode_dummy_tbl_Clear(handles);

% Clear position probe related optode table
optode_spring_tbl_Clear(handles);
optode_anchor_tbl_Clear(handles);

% Clear SD file panel
sd_file_panel_Clear(handles);

% Clear Lambda panel
wavelength1_edit_Update(handles, 690);
wavelength2_edit_Update(handles, 830);
wavelength3_edit_Update(handles, []);

SDgui_disp_msg(handles, '');



