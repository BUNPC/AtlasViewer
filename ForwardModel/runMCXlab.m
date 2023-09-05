function fwmodel = runMCXlab( fwmodel, probe, dirnameSubj)

% Check  that the MC app is a valid executable file
% from genMCinput.m
% ??? JUST REQUIRE MCXlab TO BE IN THE PATH AND ENABLE THIS MENU ITEM WHEN
% IT IS ???
% EVEN BETTER, SETPATHS CHECKS FOR IT IN A SUB_FOLDER
if ~exist([fwmodel.mc_exepath, '/', fwmodel.mc_exename], 'file')
    % Find MC application
    fwmodel = findMCapp(fwmodel);
    if isempty(fwmodel.mc_exename)
        return;
    end
    
    % Set MC options based on app type
    fwmodel = setMCoptions(fwmodel);
end

% If probe isn't registered then can't generate sensitivity
% from genSensitivityProfile.m
if isempty(probe.optpos_reg)
    MenuBox('Error: Cannot generate sensitivity, because theprobe isn''t registered to the head', 'OK');
    return;
end
if isempty(probe.ml)
    MenuBox('Error: Cannot generate sensitivity, because the measurement list is missing', 'OK');
    return;
end
iWav = unique(probe.ml(:,4));
lst = find(probe.ml(:,4)==iWav(1));
nMeas = length(lst);
if nMeas==0
    MenuBox('Error: Cannot generate sensitivity, because the measurement list is empty', 'OK');
    return;
end

% Adot already exists
% from genSensitivityProfile.m
if ~isempty( fwmodel.Adot)
    q = MenuBox('The Adot sensitivity profile has already been generated. Do you want to generate it again w MCXlab?', {'Yes','No'});
    if q==1
        fwmodel.Adot=[];
    elseif q==2
        return;
    end
end




hWait = waitbar(0,'Preparing to run MCXlab');


% Clean up old files
% from genMCinput.m
if ~isempty(dir([dirnameSubj, './fw/fw*.inp']))
    delete([dirnameSubj, './fw/fw*.inp']);
end
if ~isempty(dir([dirnameSubj, 'fw/fw_all.*']))
    delete([dirnameSubj, './fw/fw_all.*']);
end
if ~isempty(dir([dirnameSubj, './fw/fw*.2pt']))
    delete([dirnameSubj, './fw/fw*.2pt']);
end
if ~isempty(dir([dirnameSubj, './fw/fw*.mc2']))
    delete([dirnameSubj, './fw/fw*.mc2']);
end
if ~isempty(dir([dirnameSubj, './fw/fw*.his']))
    delete([dirnameSubj, './fw/fw*.his']);
end
if ~isempty(dir([dirnameSubj, 'fw/Adot.mat']))
    delete([dirnameSubj, 'fw/Adot.mat']);
end
if ~isempty(dir([dirnameSubj, 'fw/AdotVol.3pt']))
    delete([dirnameSubj, 'fw/AdotVol.3pt']);
end
if ~isempty(dir([dirnameSubj, 'fw/AdotVolAvg.3pt']))
    delete([dirnameSubj, 'fw/AdotVolAvg.3pt']);
end
if ~isempty(dir([dirnameSubj, '.', fwmodel.mc_appname]))
    delete([dirnameSubj, '.', fwmodel.mc_appname]);
end


% Set up 'fw' directory for output
% from genMCinput.m
if ~exist('./fw','dir')
    mkdir('./fw');
end
if dirnameSubj(end)~='/' && dirnameSubj(end)~='\'
    dirnameSubj(end+1)='/';
end
dirnameOut = [dirnameSubj 'fw/'];
% Sources and detector optode positions and number
% from genMCinput.m
nsrc = probe.nsrc;
nopt = probe.noptorig;
ndet = size(probe.optpos_reg(nsrc+1:nopt,:),1);
jj=1; kk=1;
for ii=1:nopt
    if ii<=nsrc
        optpos_src(jj,:) = probe.optpos_reg(ii,:);
        jj=jj+1;
    else
        optpos_det(kk,:) = probe.optpos_reg(ii,:);
        kk=kk+1;
    end
end
optpos = probe.optpos_reg(1:nopt,:);


% Tissue properties
% from genMCinput.m
tiss_prop = fwmodel.headvol.tiss_prop;
num_tiss = length(tiss_prop);
num_wavelengths = length(tiss_prop(1).scattering);


% Find head volume file path or save it to the fw for monte carlo app
% from genMCinput.m
segfilename = [dirnameOut 'headvol.vox'];
save_vox(segfilename, fwmodel.headvol);
segfilename = ['fw' filesep() 'headvol.vox']; % don't need the path in the batch file below since we run the batch file in the directory with the headvol.vox file


% Volume dimensions
% from genMCinput.m
[Dx Dy Dz] = size(fwmodel.headvol.img);
Sx_min = 1;
Sx_max = Dx;
Sy_min = 1;
Sy_max = Dy;
Sz_min = 1;
Sz_max = Dz;


% Time gates 
% from genMCinput.m
time_gates = fwmodel.timegates;

% Intensity in photons
% from genMCinput.m
num_phot = fwmodel.nphotons;


% Calculate source direction of initial photon propagation for each optode
% from genMCinput.m
Rx = fwmodel.headvol.center(1);
Ry = fwmodel.headvol.center(2);
Rz = fwmodel.headvol.center(3);
for i=1:size(optpos, 1)             
    x = optpos(i, 1);
    y = optpos(i, 2);
    z = optpos(i, 3);
    r = ((Rx-x)^2 + (Ry-y)^2 + (Rz-z)^2)^0.5;

    %%%% Vector from optode to center of seg
    optpos(i, 4) = (Rx-x)/r;
    optpos(i, 5) = (Ry-y)/r;
    optpos(i, 6) = (Rz-z)/r;
end


% Reset Sensitivity Profile and get mapMesh2Vox
% from genSensitivityProfile.m
fwmodel = resetSensitivity(fwmodel,probe,dirnameSubj);
[mapMesh2Vox, fwmodel]        = projVoltoMesh_brain(fwmodel, dirnameOut);
mesh = fwmodel.mesh;
save(fullfile(dirnameOut,'mesh_brain.mat'), 'mesh');
clear mesh

if isempty(mapMesh2Vox)
    close(hWait);
    return;
end

[mapMesh2Vox_scalp, fwmodel]        = projVoltoMesh_scalp(fwmodel, dirnameOut);
mesh_scalp = fwmodel.mesh_scalp;
save(fullfile(dirnameOut,'mesh_scalp.mat'), 'mesh_scalp');
clear mesh_scalp

if isempty(mapMesh2Vox_scalp)
    close(hWait);
    return;
end


% Init stuff ---- ALREADY DEFINED nx, ny, nz, nWav ABOVE BY Dx, Dy, Dz, num_wavelengths
%                 although nWav from from MeasList and num_wavelengths comes from tiss_prop 
% from genSensitivityProfile.m
nNode = size(fwmodel.mesh.vertices,1);
nNode_scalp = size(fwmodel.mesh_scalp.vertices,1);

%nx = size(fwmodel.headvol.img,1);
%ny = size(fwmodel.headvol.img,2);
%nz = size(fwmodel.headvol.img,3);

%iWav = unique(probe.ml(:,4));
%lst = find(probe.ml(:,4)==iWav(1));
%nMeas = length(lst);

maxNVoxPerNode = size(mapMesh2Vox,2);
maxNVoxPerNode_scalp = size(mapMesh2Vox_scalp,2);

%nWav = fwmodel.nWavelengths;

close(hWait)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run MCXlab for each optode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hWait = waitbar(0,sprintf('Running MCXlab for optode 0 of %d',(num_wavelengths*nopt)) );
 
flueMesh = zeros( nNode, nopt, num_wavelengths );
flueMesh_scalp = zeros( nNode_scalp, nopt, num_wavelengths );
flueDet = zeros( nopt, nopt, num_wavelengths ); % matrix for fluence detected at every optode from every other optode

for iWav = 1:num_wavelengths
    
    % setup mua distribution for calculating energy absorbed
    % IF WE ARE NOT SCALING BELOW, THEN THIS IS NOT NEEDED 
%     mua = single(zeros(size(fwmodel.headvol.img)));
%     tiss_seg_num = unique(fwmodel.headvol.img(find(fwmodel.headvol.img ~= 0)));
%     for ii=1:length(tiss_seg_num)
%         i_hseg = find(fwmodel.headvol.img == tiss_seg_num(ii));
%         mua(i_hseg) = tiss_prop(ii).absorption(iWav);
%     end
%     i_head = find(fwmodel.headvol.img>0);
    
    % Loop over number of optodes
    for ii=1:nopt
        
        waitbar( ((iWav-1)*nopt+ii)/(num_wavelengths*nopt), hWait, sprintf('Running MCXlab for optode %d of %d',((iWav-1)*nopt+ii),(num_wavelengths*nopt)) );
        
        clear cfg
        cfg.vol=fwmodel.headvol.img;
        
        cfg.tstart=time_gates(1,1);
        cfg.tend=time_gates(1,2);
        cfg.tstep=time_gates(1,3);
        
        while_flag = 1;
        while_count = 1;
        while while_flag
            cfg.srcdir=[optpos(ii, 4) optpos(ii, 5) optpos(ii, 6)];
            cfg.srcdir=cfg.srcdir/norm(cfg.srcdir);
            if while_count == 1
                cfg.srcpos=[optpos(ii, 1) optpos(ii, 2) optpos(ii, 3)];
            else
                cfg.srcpos = cfg.srcpos+cfg.srcdir;
            end

            cfg.detpos=[];

            cfg.issrcfrom0=1;
            cfg.isnormalized = 1;
            cfg.outputtype = 'fluence';

            cfg.prop=[         0         0    1.0000    1.0000 % background/air
                tiss_prop(1).absorption(iWav) tiss_prop(1).scattering(iWav) tiss_prop(1).anisotropy(1) tiss_prop(1).refraction(1)
                tiss_prop(2).absorption(iWav) tiss_prop(2).scattering(iWav) tiss_prop(2).anisotropy(1) tiss_prop(2).refraction(1)
                tiss_prop(3).absorption(iWav) tiss_prop(3).scattering(iWav) tiss_prop(3).anisotropy(1) tiss_prop(3).refraction(1)
                tiss_prop(4).absorption(iWav) tiss_prop(4).scattering(iWav) tiss_prop(4).anisotropy(1) tiss_prop(4).refraction(1) ];

            cfg.seed=floor(rand()*10e+7);
            cfg.nphoton=num_phot;
            cfg.issaveexit=1;

            [flue,detps]=mcxlab(cfg);
            
            min_val = min(flue.data(:));
            max_val = max(flue.data(:));

            if ~((min_val == 0 && max_val == 0))
                 while_flag = 0;
            end
            while_count =  while_count+1;
        end
        
        % Scale the flue
        % he gives me the energyabs... I guess I just get the scale factor
        % my multiplying the fluence by mua and sum over space
        % This gives me num_photos * cfg.tend which suggests he already
        % scales it to give something like number of photons per second.
        % Qianqian confirms normalization is num_photons * Vol_voxel * t_step
        % Looking at this more, I can get the same as tMCimg if I multiply
        % by t_step and divide by flue.stat.normalizer (which appears to
        % equal 1 / scale)
%         scale = flue.stat.energyabs / sum(flue.data(i_head) .* mua(i_head));
%         flue.data = flue.data * cfg.tstep / flue.stat.normalizer;
         flue.data = flue.data * cfg.tstep / flue.stat.normalizer;  % isfluence=1
        
        
        % Get fluence at all other optodes for Rytov approximation
        % I need to add source direction and ceil() and repeat if necessary
        % to get inside the tissue
        for jOpt = 1:nopt
            foo = 0;
            xx=optpos(jOpt,1); yy=optpos(jOpt,2); zz=optpos(jOpt,3);
            while foo==0
                xx = xx + optpos(jOpt,4);
                yy = yy + optpos(jOpt,5);
                zz = zz + optpos(jOpt,6);
                foo = flue.data( ceil(xx), ceil(yy), ceil(zz) );
            end
            flueDet(ii,jOpt,iWav) = foo;
        end
        
        
        % Project to the brain surface and scalp surface
        flueMesh(:,ii,iWav) = sum(reshape(flue.data(mapMesh2Vox(:)), [nNode,maxNVoxPerNode]),2);
        flueMesh_scalp(:,ii,iWav) = sum(reshape(flue.data(mapMesh2Vox_scalp(:)), [nNode_scalp,maxNVoxPerNode_scalp]),2);
        
    end
end

close(hWait)



% Construct the Adot matrix
% DO THIS ???
% don't forget to normalize by the detected fluence to get Rytov
% approximation
% and then save the result
% This doesn't (yet) support volumetric results (no one used this except John
% Spencer)
% We will want to add scalp as well
iM2 = 0;
Adot = single(zeros(nMeas,nNode,num_wavelengths));
Adot_scalp = single(zeros(nMeas,nNode_scalp,num_wavelengths));
hWait = waitbar(0,sprintf('Calculating Adot for measurement %d of %d',0,nMeas*num_wavelengths));
for iWav = 1:num_wavelengths
    for iM=1:nMeas
        iM2 = iM2 + 1;
        waitbar(iM2/(nMeas*num_wavelengths),hWait,sprintf('Calculating Adot for measurement %d of %d',iM2,nMeas*num_wavelengths));
        
        % load 2pt for given measurement from mc2 mcextreme output for
        % BRAIN
        iS = probe.ml(iM,1);
        As = flueMesh(:,iS,iWav);
        
        iD = probe.ml(iM,2);
        Ad = flueMesh(:,nsrc+iD,iWav);
        
        normfactor = (flueDet(iS,nsrc+iD,iWav) + flueDet(nsrc+iD,iS,iWav)) / 2;
        if normfactor~=0
            Adot(iM,:,iWav) = (As.*Ad)'/normfactor;
        else
            fprintf('No photons detected between Src %d and Det %d\n',iS,iD)
            Adot(iM,:,iWav) = zeros(size(As'));
        end
        
        % load 2pt for given measurement from mc2 mcextreme output for
        % SCALP
        iS = probe.ml(iM,1);
        As = flueMesh_scalp(:,iS,iWav);
        
        iD = probe.ml(iM,2);
        Ad = flueMesh_scalp(:,nsrc+iD,iWav);
        
        normfactor = (flueDet(iS,nsrc+iD,iWav) + flueDet(nsrc+iD,iS,iWav)) / 2;
        if normfactor~=0
            Adot_scalp(iM,:,iWav) = (As.*Ad)'/normfactor;
        else
            fprintf('No photons detected between Src %d and Det %d\n',iS,iD)
            Adot_scalp(iM,:,iWav) = zeros(size(As'));
        end
    end
end



tiss_prop = fwmodel.headvol.tiss_prop;
nphotons = fwmodel.nphotons;
save([dirnameOut 'Adot.mat'],'Adot', 'tiss_prop','nphotons');
save([dirnameOut 'Adot_scalp.mat'],'Adot_scalp','tiss_prop','nphotons');
fwmodel.Adot = Adot;
fwmodel.Adot_scalp = Adot_scalp;


% ??? SET GUI VISIBILITY??? BACK IN CALLBACK


close(hWait)

