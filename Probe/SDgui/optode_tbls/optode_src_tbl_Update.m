function optode_src_tbl_Update(handles)

OptPos       = sd_data_Get('SrcPos');
GrommetType  = sd_data_Get('SrcGrommetType');
GrommetRot  = sd_data_Get('SrcGrommetRot');
SrcMap       = sd_data_Get('SrcMap');
srcmap_show  = optode_src_tbl_srcmap_show_GetVal(handles);

% Generate table data
A           = get(handles.optode_src_tbl, 'data');
cnames      = get(handles.optode_src_tbl, 'ColumnName');
cwidth      = get(handles.optode_src_tbl, 'ColumnWidth');
ceditable   = get(handles.optode_src_tbl, 'ColumnEditable');
for ii = 1:size(OptPos,1)
    A{ii,1} = real2str(OptPos(ii,1));
    A{ii,2} = real2str(OptPos(ii,2));
    A{ii,3} = real2str(OptPos(ii,3));
    A{ii,4} = GrommetType{ii};
    A{ii,5} = GrommetRot{ii};
end
A(ii+1:end,:) = {''};     % Set the rest of the rows to empty string 

% If source map enabled add to table data the source map data
if srcmap_show
    nwl = sd_data_GetNwl();
    offset = size(OptPos, 2)+1;
    A(:, offset+1:end) = {''};
    for iWl = 1:nwl
        for iSrc = 1:size(SrcMap,2)
            A{iSrc, iWl+offset} = num2str(SrcMap(iWl, iSrc));
        end
        cnames{iWl+offset}    = ['l', num2str(iWl)];
        cwidth{iWl+offset} = 20;
        ceditable(iWl+offset) = logical(1);
    end
end

if get(handles.checkboxNinjaCap,'Value') == 0
    A(:,4:end) = [];
    cnames(4:end) = [];
    cwidth(4:end) = [];
    ceditable(4:end) = [];
else
    if length(cnames) == 3
        cnames{4} = 'Grommet Type';
        cnames{5} = 'Grommet Rot';
        cwidth{4} = 100;
        cwidth{5} = 100;
    end
end
% Update uitable with table data
set(handles.optode_src_tbl, 'Data',A, 'ColumnName',cnames, 'ColumnWidth',cwidth);
userdata.tbl_size = size(OptPos,1);
set(handles.optode_src_tbl, 'userdata',userdata);
