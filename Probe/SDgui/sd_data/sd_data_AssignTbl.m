function a = sd_data_AssignTbl(a, tbl)

if isempty(tbl)
    a = [];
end
ncoord = sd_data_GetCoordNum('');
for ir = 1:size(tbl,1)
    for ic = 1:ncoord
        a(ir,ic) = str2double(tbl{ir,ic});
    end
end
a(ir+1:end,:) = [];
