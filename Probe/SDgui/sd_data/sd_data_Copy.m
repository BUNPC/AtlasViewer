function SD2 = sd_data_Copy(SD2, SD1)
n = NirsClass(SD2);
n.CopyProbe(SD1);
SD2 = n.SD;

