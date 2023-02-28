function SD = sd_data_Init(SD0)
if ~exist('SD0','var')
    SD0 = [];
end
n = NirsClass(SD0);
SD = n.SD;

