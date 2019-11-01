function b = isHbConcSingleCond(hbconc)

b = [];
if ~exist('hbconc','var')
    return;
end
if isempty(hbconc)
    return;
end

b = (size(hbconc.HbConcRaw, 4) == 1);
