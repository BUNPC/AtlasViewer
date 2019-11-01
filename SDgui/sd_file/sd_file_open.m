function err = sd_file_open(filename, pathname, handles)

global filedata;

% Load new SD file
[filedata, err] = sd_file_load([pathname filename], handles);
if err
    return;
end

% Initialize SD object with data from SD file
% then fix any errors in the SD file data
sd_data_Init(filedata.SD);

err = sd_data_ErrorFix();
if err
    return;
end

% Now we're ready to use the SD data
SrcPos   = sd_data_Get('SrcPos');
SrcMap   = sd_data_Get('SrcMap');
DetPos   = sd_data_Get('DetPos');
DummyPos = sd_data_Get('DummyPos');
ml       = sd_data_GetMeasList();
sl       = sd_data_GetSpringList();
al       = sd_data_GetAnchorList();
Lambda   = sd_data_Get('Lambda');
SpatialUnit   = sd_data_Get('SpatialUnit');

set(handles.sd_filename_edit,'string',filename);

%%%%%%%% DRAW PROBE GEOMETRY IN THE GUI AXES %%%%%%%
probe_geometry_axes_Init(handles,SrcPos,DetPos,DummyPos,ml);

%%%%%%%% DRAW PROBE GEOMETRY IN THE GUI AXES2 %%%%%%%
probe_geometry_axes2_Init(handles,[SrcPos; DetPos; DummyPos],...
    size([SrcPos; DetPos],1),sl);


%%%%%%%% Initialize source, detector and dummy optode tables in SD %%%%%%%
optode_src_tbl_Init(handles,SrcPos,SrcMap);
optode_det_tbl_Init(handles,DetPos);
optode_dummy_tbl_Init(handles,DummyPos,size([SrcPos; DetPos],1));

%%%%%%%% Initialize optode spring tables in the to SD %%%%%%%
optode_spring_tbl_Init(handles,sl);

%%%%%%%% Initialize optode anchor points tables in SD %%%%%%%
optode_anchor_tbl_Init(handles,al);

%%%%%%%% Initialize Spatial Unit
%    if strcmpi(SpatialUnit,'cm')
%        set( handles.popupmenuSpatialUnit, 'value',1);
%    else
%        set( handles.popupmenuSpatialUnit, 'value',2);
%    end

%%%%%%%% Initialize Lambda Panel %%%%%%%
if(length(Lambda)>0)
    wavelength1_edit_Update(handles,Lambda(1));
else
    wavelength1_edit_Update(handles,[]);
end
if(length(Lambda)>1)
    wavelength2_edit_Update(handles,Lambda(2));
else
    wavelength2_edit_Update(handles,[]);
    h_edges=[];
end
if(length(Lambda)>2)
    wavelength3_edit_Update(handles,Lambda(3));
else
    wavelength3_edit_Update(handles,[]);
end

[~, fname,ext] = fileparts(filename);
SDgui_disp_msg(handles, sprintf('Loaded %s', [fname,ext]));

sd_file_panel_SetPathname(handles,pathname);
sd_filename_edit_Set(handles,filename);


