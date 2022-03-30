function SD = sd_data_Init(SD0)
n = NirsClass();

SD = n.SD;

if nargin==0
    return;
end

SD = sd_data_Copy(SD, SD0);

