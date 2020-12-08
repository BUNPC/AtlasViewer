function SDgui_display(handles, SDo)

% Initialize SD object with data from SD file
% then fix any errors in the SD file data
sd_data_Init(SDo);

err = sd_data_ErrorFix();
if err
    return;
end

% Now we're ready to use the SD data
SrcPos       = sd_data_Get('SrcPos');
DetPos       = sd_data_Get('DetPos');
DummyPos     = sd_data_Get('DummyPos');
ml           = sd_data_GetMeasList();
sl           = sd_data_GetSpringList();
al           = sd_data_GetAnchorList();
Lambda       = sd_data_Get('Lambda');
SpatialUnit  = sd_data_Get('SpatialUnit');

%%%%%%%% DRAW PROBE GEOMETRY IN THE GUI AXES %%%%%%%
probe_geometry_axes_Init(handles,SrcPos,DetPos,DummyPos,ml);

%%%%%%%% DRAW PROBE GEOMETRY IN THE GUI AXES2 %%%%%%%
probe_geometry_axes2_Init(handles,[SrcPos; DetPos; DummyPos],...
    size([SrcPos; DetPos],1),sl);


%%%%%%%% Initialize source, detector and dummy optode tables in SD %%%%%%%
optode_src_tbl_Update(handles);
optode_det_tbl_Update(handles);
optode_dummy_tbl_Update(handles);

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
if length(Lambda)>0
    wavelength1_edit_Update(handles,Lambda(1));
else
    wavelength1_edit_Update(handles,[]);
end
if length(Lambda)>1
    wavelength2_edit_Update(handles,Lambda(2));
else
    wavelength2_edit_Update(handles,[]);
end
if length(Lambda)>2
    wavelength3_edit_Update(handles,Lambda(3));
else
    wavelength3_edit_Update(handles,[]);
end

% Set ninja cap checkbox if any of the grommet types set to None
if sd_data_AnyGrommetTypeSet()
    set(handles.checkboxNinjaCap, 'value',1)
end

% Set spatial unit dropdown menu
strs = get(handles.popupmenuSpatialUnit, 'string');
idx = find(strcmp(strs, SpatialUnit));
if ~isempty(idx) && (idx <= length(strs))
    set(handles.popupmenuSpatialUnit, 'value', idx);
end


