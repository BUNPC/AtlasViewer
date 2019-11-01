function fwmodel = genSensitivityProfile(fwmodel,probe,headvol,pialsurf,headsurf,dirnameSubj)

% Compute volume sensitivity matrix from Monte Carlo simulations and then
% projects volume sensitivity onto pial mesh to obtain surface sensitivity
% matrix.
% Works with tMCimg output (.2pt files) and mcextreme outputs (.mc2 files).

% Written by Matteo Caffini
%
% Modified by Jay Dubb
%
% usage:
% call function Adot in subject directory or registered atlas
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
if isempty(probe.ml)
    menu('Error: Cannot generate sensitivity, because the measurement list is missing','OK');
    return;
end

[mc_output_ext, loadMCFuncPtr] = getMCoutputExt(fwmodel.mc_appname);

if isempty(fwmodel.Adot)

    [mapMesh2Vox, fwmodel]        = projVoltoMesh_brain(fwmodel, dirnameOut); 
    % [mapMesh2Vox_scalp, fwmodel]  = projVoltoMesh_scalp(fwmodel, dirnameOut);
   
    if isempty(mapMesh2Vox)
        return;
    end
    
    nNode = size(fwmodel.mesh.vertices,1);    
    % nNode_scalp = size(fwmodel.mesh_scalp.vertices,1);   
    
    nx = size(fwmodel.headvol.img,1);
    ny = size(fwmodel.headvol.img,2);
    nz = size(fwmodel.headvol.img,3);
        
    nMeas = size(probe.ml,1);
    if nMeas==0;
        return;
    end
    
    maxNVoxPerNode = size(mapMesh2Vox,2);
    % maxNVoxPerNode_scalp = size(mapMesh2Vox_scalp,2);
     
    nWav = fwmodel.nWavelengths;

    % Sensitivity values for low-res pial mesh for all measurement pair

    Adot = single(zeros(nMeas,nNode,nWav));
    % Adot_scalp = single(zeros(nMeas,nNode_scalp,nWav));

    
    % We don't want to reserve the whole matrix in memory (too large). 
    % rather append each channel's sensitivity to a file.
    A = single(zeros(nx,ny,nz));
    As = single(zeros(nx,ny,nz));
    Ad = single(zeros(nx,ny,nz));

    if fwmodel.AdotVolFlag
        fprintf('Warning: option to generate Adot 3 pt file enabled - May run out of memory\n');
        fid1 = fopen([dirnameOut 'AdotVol.3pt'],'wb');
        AdotVolSum = single(zeros(nx,ny,nz,nWav));
    end
    
    % loop over measurements
    hwait = waitbar(0,sprintf('Loading measurement %d of %d',0,nMeas*nWav));
    iM2 = 0;
    for iW = 1:nWav
        % Get tissue absorption and replace voxels equal to that tissue value
        % with the tissue's absortion value. This will be used for calibration.
        mua = single(zeros(size(fwmodel.headvol.img)));
        tiss_seg_num = unique(fwmodel.headvol.img(find(fwmodel.headvol.img ~= 0)));
        for ii=1:length(tiss_seg_num)
            i_hseg = find(fwmodel.headvol.img == tiss_seg_num(ii));
            mua(i_hseg) = fwmodel.headvol.tiss_prop(ii).absorption(iW);
        end
        
        for iM=1:nMeas
            iM2 = iM2 + 1;
            waitbar(iM2/(nMeas*nWav),hwait,sprintf('Loading measurement %d of %d',iM2,nMeas*nWav));
            
            % load 2pt for given measurement from mc2 mcextreme output
            iS = probe.ml(iM,1);
            fileS = sprintf('%sfw%d.s%d.%s', dirnameOut, iW, iS, mc_output_ext);
            As = loadMCFuncPtr(fileS, [nx ny nz 1]);
            
            iD = probe.ml(iM,2);
            fileD = sprintf('%sfw%d.d%d.%s', dirnameOut, iW, iD, mc_output_ext);
            Ad = loadMCFuncPtr(fileD, [nx ny nz 1]);
             
            if fwmodel.normalizeFluence
                
                % calibrate As
                As = As / fwmodel.nphotons;
                
                % First get the sum of the flux or exiting photons
                idx_n = find(As<0);
                sum_n = sum(As(idx_n));
                
                % zero out flux
                As(idx_n) = 0;
                
                % Get the sum of all the photons absorbed inside the medium (i.e. fluence * mua_vol).
                idx_p = find(As>0);
                sum_p = sum(As(idx_p) .* mua(idx_p));
                
                % Apply the correction
                if sum_p~=0
                    As(idx_p) = As(idx_p) * (1 - abs(sum_n)) / sum_p;
                else
                    disp(sprintf('No photons launched into tissue from Src %d',iS))
                    As(idx_p) = 0;
                end
                
                % calibrate Ad
                Ad = Ad / fwmodel.nphotons;
                
                % First get the sum of the flux or exiting photons
                idx_n = find(Ad<0);
                sum_n = sum(Ad(idx_n));
                
                % zero out flux
                Ad(idx_n) = 0;
                
                % Get the sum of all the photons absorbed inside the medium (i.e. fluence * mua_vol).
                idx_p = find(Ad>0);
                sum_p = sum(Ad(idx_p) .* mua(idx_p));
                
                % Apply the correction
                if sum_p~=0
                    Ad(idx_p) = Ad(idx_p) * (1 - abs(sum_n)) / sum_p;
                else
                    disp(sprintf('No photons launched into tissue form Det %d',iD))
                    Ad(idx_p) = 0;
                end
                
            end
                
            
            % Get normalized fluence at the source position for source and detector fluence files
            fileS_inp = sprintf('%sfw%d.s%d.inp', dirnameOut, iW, iS );
            fid = fopen(fileS_inp,'rb');
            srcpos = textscan(fid, '%f %f %f', 1, 'headerlines', 2);
            fclose(fid);
            normfactor_s = Ad(floor(srcpos{1}),floor(srcpos{2}),floor(srcpos{3}));
            if normfactor_s==0
                [~,i]=max(As(:));
                [srcpos{1},srcpos{2},srcpos{3}]=ind2sub(size(As),i);
                normfactor_s = Ad(floor(srcpos{1}),floor(srcpos{2}),floor(srcpos{3}));
            end
            
            fileD_inp = sprintf('%sfw%d.d%d.inp', dirnameOut, iW, iD );
            fid = fopen(fileD_inp);
            detpos = textscan(fid, '%f %f %f', 1, 'headerlines', 2);
            fclose(fid);
            normfactor_d = As(floor(detpos{1}),floor(detpos{2}),floor(detpos{3}));
            if normfactor_d==0
                [~,i]=max(Ad(:));
                [detpos{1},detpos{2},detpos{3}]=ind2sub(size(Ad),i);
                normfactor_d = As(floor(detpos{1}),floor(detpos{2}),floor(detpos{3}));
            end
            
            % Get Adot
            normfactor = (normfactor_s + normfactor_d)/2;
            if normfactor~=0
                A = (As.*Ad)/normfactor;
            else
                disp(sprintf('No photons detected between Src %d and Det %d',iS,iD))
                A = zeros(size(As));
            end
            if fwmodel.AdotVolFlag
                fwrite(fid1,A,'single');
                AdotVolSum(:,:,:,iW) = AdotVolSum(:,:,:,iW)+A;
            end

            if ispc() 
                % memory function only available on windows
                memory;
            end
            
            % Extract sensitivity values for the nodes of the low res mesh
            % (Adot) from the sensitivity matrix volume (A)
            Adot(iM,:,iW) = sum(reshape(A(mapMesh2Vox(:)), [nNode,maxNVoxPerNode]),2)';
            lst0 = Adot(iM,:,iW)==0;
            Adot(iM,lst0,iW) = eps;
            
            clear lst0
            
            %{
            Adot_scalp(iM,:,iW) = sum(reshape(A(mapMesh2Vox_scalp(:)), [nNode_scalp,maxNVoxPerNode_scalp]),2)';
            lst0 = Adot_scalp(iM,:,iW)==0;
            Adot_scalp(iM,lst0,iW) = eps;        
            %}
            
        end
    end
    close(hwait);
    tiss_prop = fwmodel.headvol.tiss_prop;
    nphotons = fwmodel.nphotons;
    save([dirnameOut 'Adot.mat'],'Adot', 'tiss_prop','nphotons');
    % save([dirnameOut 'Adot_scalp.mat'],'Adot_scalp','tiss_prop','nphotons');
    fwmodel.Adot = Adot;
    % fwmodel.Adot_scalp = Adot_scalp;
    if fwmodel.AdotVolFlag
        fclose(fid1);
        
        fid2 = fopen([dirnameOut 'AdotVolSum.3pt'],'wb');
        fwrite(fid2,AdotVolSum,'single');
        fclose(fid2);
    end
    
    q = menu('Sensitivity profile completed. Do you want to delete the MC output files to save disk space?','YES','NO');
    if q==1
        if ~isempty(mc_output_ext)
            delete([dirnameOut, '*.', mc_output_ext]);
        end
    end
    
end


