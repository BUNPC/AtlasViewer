function hbconc = loadDataHbConc(hbconc, dataTree)

% Check if there's group acquisition data to load
if ~isempty(dataTree.currElem) && ~dataTree.currElem.IsEmpty()
    hbconc.HbConcRaw = dataTree.currElem.GetDcAvg();
    hbconc.tHRF      = dataTree.currElem.GetTHRF();
end
if length(hbconc.tHRF) >  1
    hbconc.config.tRangeMin = hbconc.tHRF(1);
    hbconc.config.tRangeMax = hbconc.tHRF(end);
end

