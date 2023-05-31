function digpts = genDigptsFromRefpts(refpts, dt, nW)
digpts = initDigpts();
if ~exist('dt','var') || isempty(dt)
    dt = 30;
end
if ~exist('nW','var') || isempty(nW)
    nW = 2;
end
SD = genProbeFromRefpts(refpts, dt, nW, 'landmarks');
digpts.srcpos = SD.SrcPos;
digpts.detpos = SD.DetPos;
kk = 1;
for ii = 1:length(SD.Landmarks.labels)
    switch(lower(SD.Landmarks.labels{ii}))
        case 'nz'
            digpts.refpts.pos(kk,:) = SD.Landmarks.pos(ii,:);
            digpts.refpts.labels{kk} = SD.Landmarks.labels{ii};
            kk = kk+1;
        case 'iz'
            digpts.refpts.pos(kk,:) = SD.Landmarks.pos(ii,:);
            digpts.refpts.labels{kk} = SD.Landmarks.labels{ii};
            kk = kk+1;
        case {'rpa'}
            digpts.refpts.pos(kk,:) = SD.Landmarks.pos(ii,:);
            digpts.refpts.labels{kk} = SD.Landmarks.labels{ii};
            kk = kk+1;
        case {'lpa'}
            digpts.refpts.pos(kk,:) = SD.Landmarks.pos(ii,:);
            digpts.refpts.labels{kk} = SD.Landmarks.labels{ii};
            kk = kk+1;
        case {'a2'}
            digpts.refpts.pos(kk,:) = SD.Landmarks.pos(ii,:);
            digpts.refpts.labels{kk} = 'rpa';
            kk = kk+1;
        case {'a1'}
            digpts.refpts.pos(kk,:) = SD.Landmarks.pos(ii,:);
            digpts.refpts.labels{kk} = 'lpa';
            kk = kk+1;
        case {'ar'}
            digpts.refpts.pos(kk,:) = SD.Landmarks.pos(ii,:);
            digpts.refpts.labels{kk} = 'rpa';
            kk = kk+1;
        case {'al'}
            digpts.refpts.pos(kk,:) = SD.Landmarks.pos(ii,:);
            digpts.refpts.labels{kk} = 'lpa';
            kk = kk+1;
        case 'cz'
            digpts.refpts.pos(kk,:) = SD.Landmarks.pos(ii,:);
            digpts.refpts.labels{kk} = SD.Landmarks.labels{ii};
            kk = kk+1;
    end
end
digpts = saveDigpts(digpts, 'overwrite');



