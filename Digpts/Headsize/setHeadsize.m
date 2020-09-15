function headsize = setHeadsize(headsize, headsizeParams)

% This function expects headsizeParams to be numeric strings of 
% head size in cm units 

headsize.HC = str2num(headsizeParams{1})*10;
headsize.NzCzIz = str2num(headsizeParams{2})*10;
headsize.LPACzRPA = str2num(headsizeParams{3})*10;

