function [err, SD1] = sd_data_ErrorFix(SD1)
global SD

if ~exist('SD1','var')
    SD1 = SD;
else
    SD = SD1;
end
err = false;

if sd_data_IsEmpty()
    return
end

n = NirsClass(SD);
SD = n.SD;

