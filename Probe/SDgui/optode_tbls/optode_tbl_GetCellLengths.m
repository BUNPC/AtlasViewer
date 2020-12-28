function [l, tbl_data] = optode_tbl_GetCellLengths(tbl_data, r, coordCols, handles)
if ~exist('coordCols','var') || isempty(coordCols)
    ncoord = sd_data_GetCoordNum();
    coordCols = 1:ncoord;
end
if ~exist('handles','var')
    handles = [];
end

%if get(handles.checkboxNinjaCap,'value')==1
    grommetTypeIdx = coordCols(end)+1; % add columns grommet type and grommet rotation
    grommetRotIdx = coordCols(end)+2; % add columns grommet type and grommet rotation
%else
%    grommetTypeIdx = coordCols(end)+0; % Do Not add columns grommet type and grommet rotation
%end
coordGrommetCols = coordCols(1):grommetRotIdx;
offsetIdx = coordCols(1)-1;

l = zeros(1, length(coordGrommetCols));
jj = 1;
for ii = coordGrommetCols
    if ii>ncoord %strcmpi(tbl_data{r,ii},'none')
        if all(l(1:ncoord)==0)
            tbl_data{r,ii} = '';
        end
    end
    l(jj) = length(tbl_data{r,ii});
    jj = jj+1;
end

% Ninja Cap checkbox is not set then automatically set grommetTYpe to none
if all(l(coordCols-offsetIdx) > 0) && isempty(tbl_data{r,grommetTypeIdx})
%    if ~isempty(handles) && ~get(handles.checkboxNinjaCap, 'value')
        ch = sd_data_GetGrommetChoices();
        tbl_data{r, grommetTypeIdx} = ch{1};
        l(grommetTypeIdx-offsetIdx) = length(ch{1});
%    end
end

% Ninja Cap checkbox is not set then automatically set grommetRot to '0'
if all(l(coordCols-offsetIdx) > 0) && isempty(tbl_data{r,grommetRotIdx})
%    if ~isempty(handles) && ~get(handles.checkboxNinjaCap, 'value')
        ch = '0';
        tbl_data{r, grommetRotIdx} = ch;
        l(grommetRotIdx-offsetIdx) = length(ch);
%    end
end


