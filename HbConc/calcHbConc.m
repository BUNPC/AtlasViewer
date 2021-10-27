function hbconc = calcHbConc(hbconc, probe)


if isempty(hbconc)
    return;
end
if isempty(hbconc.HbConcRaw)
    return;
end

% Error margin because input dialog where user fills in time range crops numbers 
% converting to string
EM = 1e-4;

% Find the channels for which to display Hb Conc
hbconc.Ch = str2num(get(hbconc.handles.editSelectChannel, 'string'));
if hbconc.Ch(1)==0 & hbconc.Ch(2)==0
    % iCh = 1:size(hbconc.HbConcRaw,3);
    ml = probe.ml;
    % mlAct = probe.ml(:,3);
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
elseif (tHRF(1)-tRangeMin)>EM && (tRangeMax-tHRF(end))>EM
    startIdx = 1; 
    endIdx = length(tHRF);
    MessageBox(sprintf('Invalid time range entered (%0.4f, %0.4f); Using whole tHRF range [%0.4f - %0.4f] ...', tRangeMin, tRangeMax, tHRF(1), tHRF(end)));
elseif (tHRF(1)-tRangeMin)>EM && (tRangeMax-tHRF(end))<EM
    startIdx = 1;
    [~, endIdx] = nearest_point(tHRF(:), tRangeMax, 1);
    MessageBox(sprintf('Invalid min limit entered (%0.4f);  will use min tHRF of %0.4f ...', tRangeMin, tHRF(1)));
elseif (tHRF(1)-tRangeMin)<EM && (tRangeMax-tHRF(end))>EM
    [~, startIdx] = nearest_point(tHRF(:), tRangeMin, 1);
    endIdx = length(tHRF);
    MessageBox(sprintf('Invalid max limit entered (%0.4f);  will use max tHRF of %0.4f ...', tRangeMax, tHRF(end)));
else
    [~, startIdx] = nearest_point(tHRF(:), tRangeMin, 1);
    [~, endIdx] = nearest_point(tHRF(:), tRangeMax, 1);
end
hbconc.config.tRangeMin = tHRF(startIdx);
hbconc.config.tRangeMax = tHRF(endIdx);
fprintf('Using tHRF range of [%0.4f - %0.4f]...\n', hbconc.config.tRangeMin, hbconc.config.tRangeMax);

hbconc.HbO = interpHbConc(hbconc.mesh.vertices,  hbconc.HbConcRaw(startIdx:endIdx, 1, :, iCond),  probe.ptsProj_cortex,  iCh);
hbconc.HbR = interpHbConc(hbconc.mesh.vertices,  hbconc.HbConcRaw(startIdx:endIdx, 2, :, iCond),  probe.ptsProj_cortex,  iCh);


