function hbconc = calcHbConcCmThreshold(hbconc)

n = 100;

if ~isempty(hbconc.HbO)
    k = find(hbconc.HbO~=0);
    if min(hbconc.HbO(k)) > 0
        hbconc.cmThreshold(1,1) = 0;
    else
        hbconc.cmThreshold(1,1) = min(hbconc.HbO(k));
    end
    if max(hbconc.HbO(k)) < 0
        hbconc.cmThreshold(1,2) = 0;
    else
        hbconc.cmThreshold(1,2) = mean(hbconc.HbO(k));
    end
end

if ~isempty(hbconc.HbR)
    k = find(hbconc.HbR~=0);
    if min(hbconc.HbR(k)) > 0
        hbconc.cmThreshold(2,1) = 0;
    else
        hbconc.cmThreshold(2,1) = min(hbconc.HbR(k));
    end
    if max(hbconc.HbR(k)) < 0
        hbconc.cmThreshold(2,2) = 0;
    else
        hbconc.cmThreshold(2,2) = mean(hbconc.HbR(k));
    end
end