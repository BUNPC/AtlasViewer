function b = sd_data_Equal(SD1, SD2)
nirs1 = NirsClass(SD1);
nirs2 = NirsClass(SD2);
b = nirs1 == nirs2;
