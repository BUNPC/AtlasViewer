function hbconc = calcHbConc(hbconc, probe)

if isempty(hbconc)
    return;
end
if isempty(hbconc.HbConcRaw)
    return;
end


% Find the channels for which to display Hb Conc
str = get(hbconc.handles.editSelectChannel, 'string');
hbconc.Ch = str2num(str);
iCh = [];
if hbconc.Ch(1)==0 & hbconc.Ch(2)==0
  %  iCh = 1:size(hbconc.HbConcRaw,3);
    ml = probe.ml;
    mlAct = probe.ml(:,3);
    lst = find(ml(:,4)==1);
    rhoSD = zeros(length(lst),1);
    posM = zeros(length(lst),3);
        for iML = 1:length(lst)
            rhoSD(iML) = sum((probe.srcpos(ml(lst(iML),1),:) - probe.detpos(ml(lst(iML),2),:)).^2).^0.5;
            posM(iML,:) = (probe.srcpos(ml(lst(iML),1),:) + probe.detpos(ml(lst(iML),2),:)) / 2;
        end
    iCh = lst(find(rhoSD>=probe.rhoSD_ssThresh));
        %lstLL = lst(find(rhoSD>=probe.rhoSD_ssThresh & mlAct(lst)==1));
else
    iCh = find(probe.ml(:,1)==hbconc.Ch(1) & probe.ml(:,2)==hbconc.Ch(2), 1);
end
if isempty(iCh)
    return;
end

% Get condition 
str = get(hbconc.handles.editCondition, 'string');
hbconc.iCond = str2num(str);
iCond = hbconc.iCond;
if iCond<1 | iCond>size(hbconc.HbConcRaw,4)
    hbconc.HbO = [];
    hbconc.HbR = [];
    return;
end

tHRF = hbconc.tHRF;
tRangeMin = hbconc.config.tRangeMin;
tRangeMax = hbconc.config.tRangeMax;
if isempty(tHRF)
    startIdx = 1; 
    endIdx = length(tHRF);
elseif tRangeMin<tHRF(1) | tRangeMin>tHRF(end) | tRangeMax<tHRF(1) | tRangeMax>tHRF(end)
    startIdx = 1; 
    endIdx = length(tHRF);
    menu(sprintf('Invalid time rage entered; tHRF range [%0.1f - %0.1f]. Using whole tHRF...', tHRF(1), tHRF(end)), 'OK');
elseif tRangeMin >= tRangeMax
    startIdx = 1; 
    endIdx = length(tHRF);
    menu(sprintf('Invalid time rage entered; tHRF range [%0.1f - %0.1f]. Using whole tHRF...', tHRF(1), tHRF(end)), 'OK');
else
    [~, startIdx] = nearest_point(tHRF, tRangeMin, 1, 1);
    [~, endIdx] = nearest_point(tHRF, tRangeMax, 1, 1);
end
hbconc.HbO = interpHbConc(hbconc.mesh.vertices,  hbconc.HbConcRaw(startIdx:endIdx, 1, :, iCond),  probe.ptsProj_cortex,  iCh);
hbconc.HbR = interpHbConc(hbconc.mesh.vertices,  hbconc.HbConcRaw(startIdx:endIdx, 2, :, iCond),  probe.ptsProj_cortex,  iCh);

probe = setProbeDisplay(probe, [], [], iCh);

