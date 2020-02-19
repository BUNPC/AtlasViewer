function ncoord = sd_data_GetCoordNum()

n(1) = size(sd_data_Get('SrcPos'), 2);
n(2) = size(sd_data_Get('DetPos'), 2);
ncoord = max(n);
if ncoord==0
    ncoord = 3;
end

