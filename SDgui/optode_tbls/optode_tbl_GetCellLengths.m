function [l, tbl_data] = optode_tbl_GetCellLengths(tbl_data, r, ncoord)

l = zeros(1, ncoord+1);
for ii = 1:ncoord+1
    if strcmpi(tbl_data{r,ii},'none')
        if all(l(1:ii-1) == 0)
            tbl_data{r,ii} = '';
        end
    end
    l(ii) = length(tbl_data{r,ii});
end



