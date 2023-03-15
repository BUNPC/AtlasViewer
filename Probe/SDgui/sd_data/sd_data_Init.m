function SD = sd_data_Init(SD0, units)
SD = [];
if ~exist('SD0','var')
    SD0 = [];
end
if ~exist('units','var')
    units = '';
end
n = NirsClass(SD0);
if ~isempty(units)
    n.SetProbeSpatialUnit(units);
end
if isempty(n)
    return;
end
SD = n.SD;

