function [l, tbl_data] = optode_tbl_GetCellLengths(tbl_data, r, coordCols, handles)
if ~exist('coordCols','var') || isempty(coordCols)
    ncoord = sd_data_GetCoordNum();
    coordCols = 1:ncoord;
end
if ~exist('handles','var')
    handles = [];
end

grommetTypeIdx = coordCols(end)+1;
coordGrommetCols = coordCols(1):grommetTypeIdx;
offsetIdx = coordCols(1)-1;

l = zeros(1, length(coordGrommetCols));
jj = 1;
for ii = coordGrommetCols
    if strcmpi(tbl_data{r,ii},'none')
        if all(l(1:jj-1)==0)
            tbl_data{r,ii} = '';
        end
    end
    l(jj) = length(tbl_data{r,ii});
    jj = jj+1;
end

% Ninja Cap checkbox is not set then automatically set grommetTYpe to none
if all(l(coordCols-offsetIdx) > 0) && isempty(tbl_data{r,grommetTypeIdx})
    if ~isempty(handles) && ~get(handles.checkboxNinjaCap, 'value')
        ch = sd_data_GetGrommetChoices();
        tbl_data{r, grommetTypeIdx} = ch{1};
        l(grommetTypeIdx-offsetIdx) = length(ch);
    end
end



