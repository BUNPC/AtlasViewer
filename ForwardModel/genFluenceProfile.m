function fwmodel = genFluenceProfile(fwmodel, probe, iFirst, iLast, headvol, pialsurf, dirnameSubj)

% Compute volume sensitivity matrix from Monte Carlo simulations and then
% projects volume sensitivity onto pial mesh to obtain surface sensitivity
% matrix.
% Works with tMCimg output (.2pt files) and mcextreme outputs (.mc2 files).

% Written by Matteo Caffini
%
% Modified by Jay Dubb
%
% usage:
% call function fluenceProf in subject directory or registered atlas
% directory.

fwmodel = resetSensitivity(fwmodel,probe,dirnameSubj);
if dirnameSubj(end)~='/' && dirnameSubj(end)~='\'
    dirnameSubj(end+1)='/';
end
dirnameOut = [dirnameSubj 'fw/'];

if ~exist(dirnameOut,'dir')
    mkdir(dirnameOut);
end

% If probe isn't registered then can't generate sensitivity
if isempty(probe.optpos_reg)
    return;
end

fluenceProf = fwmodel.fluenceProf(1);

% Calculate mapping between volume and our mesh
[mapMesh2Vox, fwmodel] = projVoltoMesh_brain(fwmodel, dirnameOut);
if isempty(mapMesh2Vox)
    return;
end

nNodes = size(fwmodel.mesh.vertices,1);
maxNVoxPerNode = size(mapMesh2Vox,2);

nx = size(headvol.img,1);
ny = size(headvol.img,2);
nz = size(headvol.img,3);

nOpt = iLast-iFirst+1;
optpos_all = probe.optpos_reg(1:probe.noptorig, :);

nsrc = probe.nsrc;
ndet = probe.noptorig-nsrc;
nWav = fwmodel.nWavelengths;

if nOpt==0;
    return;
end


% Sensitivity values for low-res pial mesh for all measurement pair
fluenceAll = single(zeros(nOpt, nNodes, nWav));
optpos = single(zeros(nOpt,3));
normfactors = single(zeros(nOpt,nOpt));

% We don't want to reserve the whole matrix in memory (too large).
% rather append each channel's sensitivity to a file.
fl = single(zeros(nx,ny,nz));

% loop over measurements
for iW = 1:nWav
    % Get tissue absorption and replace voxels equal to that tissue value
    % with the tissue's absortion value. This will be used for calibration.
    headvol.img = uint8(headvol.img);
    mua = single(zeros(size(headvol.img)));
    tiss_seg_num = unique(headvol.img(find(headvol.img ~= 0)));
    for ii=1:length(tiss_seg_num)
        i_hseg = find(headvol.img == tiss_seg_num(ii));
        mua(i_hseg) = fwmodel.headvol.tiss_prop(ii).absorption(iW);
    end
    
    hwait = waitbar(0, sprintf('Loading %d optodes for wavelength %d...',nOpt, iW));
    for iO=iFirst:iLast
        iO_local = iO-iFirst+1;
        waitbar(iO_local/nOpt, hwait, sprintf('Loading optode %d of %d for wavelength %d', iO, iLast, iW));

        if iO<=nsrc
            filetype = 's';
            filenum = iO;
        else
            filetype = 'd';
            filenum = iO-nsrc;
        end

        % load fluence file for optode iO
        if strcmp(fwmodel.mc_appname, 'tMCimg')
            
            file = sprintf('%sfw%d.%s%d.2pt', dirnameOut, iW, filetype, filenum);
            if exist(file, 'file')
                fl = load_tMCimg_2pt(file, [nx ny nz 1]);
            end
            
        elseif strcmp(fwmodel.mc_appname, 'mcx')
            
            file = sprintf('%sfw%d.%s%d.inp.mc2', dirnameOut, iW, filetype, filenum);
            if exist(file, 'file')
                fl = loadmc2(file, [nx ny nz 1]);
            end
            
        end
        
        if fwmodel.normalizeFluence
            % calibrate fl_s
            fl = fl / fwmodel.nphotons;
            
            % First get the sum of the flux or exiting photons
            idx_n = find(fl<0);
            sum_n = sum(fl(idx_n));
            
            % zero out flux
            fl(idx_n) = 0;
            
            % Get the sum of all the photons absorbed inside the medium (i.e. fluence * mua_vol).
            idx_p = find(fl>0);
            sum_p = sum(fl(idx_p) .* mua(idx_p));
            
            % Apply the correction
            if sum_p~=0
                fl(idx_p) = fl(idx_p) * (1 - abs(sum_n)) / sum_p;
            else
                disp(sprintf('No photons launched into tissue from Src %d',iO))
                fl(idx_p) = 0;
            end
        end

        if ispc()
            % memory function only available on windows
            memory;
        end
        
        % Extract fluence values for the nodes of the low res mesh
        % (fluenceAll) from the fluence volume
        fluenceAll(iO_local,:,iW) = mean2(reshape(fl(mapMesh2Vox(:)), [nNodes,maxNVoxPerNode]), mapMesh2Vox);
        lst0 = fluenceAll(iO_local,:,iW)==0;
        fluenceAll(iO_local,lst0,iW) = eps;
        
        % Add position of optode to positions array
        file_inp = sprintf('%sfw%d.%s%d.inp', dirnameOut, iW, filetype, filenum);
        fid = fopen(file_inp,'rb');
        pos = textscan(fid, '%f %f %f', 1, 'headerlines', 2);
        optpos(iO_local,:) = [pos{1}, pos{2}, pos{3}];
        
        % Find and save normfactors to all detectors
        for ii=1:size(optpos_all,1)
            if ii==iO_local
                continue;
            end
            detpos = floor(optpos_all(ii,:));
            if fl(detpos(1),detpos(2),detpos(3))==0
                detpos = findNearestNonZeroNeighbor(detpos, 2, fl);
            end
            normfactors(iO_local,ii,iW) = fl(detpos(1),detpos(2),detpos(3));            
        end
        
        fclose(fid);
        
    end

    close(hwait);
end


fluenceProf.intensities = fluenceAll;
fluenceProf.srcpos = optpos;
fluenceProf.normfactors = normfactors;
fluenceProf.tiss_prop = fwmodel.headvol.tiss_prop;
fluenceProf.nphotons = fwmodel.nphotons;
if fluenceProf.index==1
    fluenceProf.voxPerNode = sum(mapMesh2Vox>1,2);
    fluenceProf.mesh = fwmodel.mesh;
end

filenm = sprintf('%sfluenceProf%d.mat', dirnameOut, fluenceProf.index);
saveFluenceProf(filenm, fluenceProf);




% -----------------------------------------------------------------
function neigh_pos = findNearestNonZeroNeighbor(pos, r, fl)
neigh_pos=pos;

dmin = 9999;
for kk=pos(3)-r:pos(3)+r
    for jj=pos(2)-r:pos(2)+r
        for ii=pos(1)-r:pos(1)+r
            if (dist3([ii,jj,kk], pos)<=dmin) & (fl(ii,jj,kk)>0)
                neigh_pos = [ii,jj,kk];
                dmin = dist3([ii,jj,kk], pos);
            end
        end
    end
end




% --------------------------------------------------------------
function m = mean2(fl, mapMesh2Vox)

m = size(fl,1);
for ii=1:size(fl,1)
    k = mapMesh2Vox(ii,:)>1;
    if ~all(k==0)
        m(ii) = mean(fl(ii,k));
    else        
        m(ii) = 0;
    end
end

