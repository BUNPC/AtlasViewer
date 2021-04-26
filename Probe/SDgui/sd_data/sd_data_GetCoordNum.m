function ncoord = sd_data_GetCoordNum(data3D)

n(1) = size(sd_data_Get(['SrcPos', data3D]), 2);
n(2) = size(sd_data_Get(['DetPos', data3D]), 2);
ncoord = max(n);
if ncoord==0
    ncoord = 3;
end

