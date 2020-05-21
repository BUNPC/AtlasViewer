function [l, tbl_data] = optode_tbl_GetCellLengths(tbl_data, r, coordCols)
if ~exist('coordCols','var') || isempty(coordCols)
    ncoord = sd_data_GetCoordNum();
    coordCols = 1:ncoord;
end
coordCols = coordCols(1):coordCols(end)+1;

l = zeros(1, length(coordCols));
jj = 1;
for ii = coordCols
    if strcmpi(tbl_data{r,ii},'none')
        if all(l(1:jj-1)==0)
            tbl_data{r,ii} = '';
        end
    end
    l(jj) = length(tbl_data{r,ii});
    jj = jj+1;
end


