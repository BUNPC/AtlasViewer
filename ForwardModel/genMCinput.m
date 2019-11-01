%
%  
% Usage:
%
%   genMCinput(fwmodel, probe, dirnameSubj)
%
%
% Example 1:
%   
%   genMCinput(fwmodel, probe, dirnameSubj);
%
%
%

function fwmodel = genMCinput(fwmodel, probe, dirnameSubj)

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

if ~exist('./fw','dir')
    mkdir('./fw');
end
if dirnameSubj(end)~='/' && dirnameSubj(end)~='\'
    dirnameSubj(end+1)='/';
end
dirnameOut = [dirnameSubj 'fw/'];


% Check again that the MC app is a valid executable file
if ~exist([fwmodel.mc_exepath, '/', fwmodel.mc_exename], 'file')
    % Find MC application
    fwmodel = findMCapp(fwmodel);
    if isempty(fwmodel.mc_exename)
        return;
    end
    
    % Set MC options based on app type
    fwmodel = setMCoptions(fwmodel);
end

% Sources and detector optode positions and number
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
tiss_prop = fwmodel.headvol.tiss_prop;
num_tiss = length(tiss_prop);
num_wavelengths = length(tiss_prop(1).scattering);

% Find head volume file path or save it to the fw for monte carlo app
segfilename = [dirnameOut 'headvol.vox'];
save_vox(segfilename, fwmodel.headvol);

% Volume dimensions
[Dx Dy Dz] = size(fwmodel.headvol.img);
Sx_min = 1;
Sx_max = Dx;
Sy_min = 1;
Sy_max = Dy;
Sz_min = 1;
Sz_max = Dz;


% Time gates 
time_gates = fwmodel.timegates;

% Intensity in photons
num_phot = fwmodel.nphotons;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate file names by appending the optode name and 
% .inp extension and then open the file for IO.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ispc()
    fid_batch   = fopen([dirnameOut, 'fw_all.bat'], 'wt');
    fprintf(fid_batch, 'echo 0 > "%s/.fw_all_start"\n', dirnameOut);
    stopFileCmdStr = sprintf('echo. 2>"%s/.fw_all_stop"\n', dirnameOut);
else
    fid_batch = fopen([dirnameOut, 'fw_all.csh'], 'wt');
    fprintf(fid_batch, 'touch "%s/.fw_all_start"\n', dirnameOut);
    stopFileCmdStr = sprintf('touch "%s/.fw_all_stop"\n', dirnameOut);
end


for iWav = 1:num_wavelengths
    j=1;
    for i=1:nsrc
        inp_file = [dirnameOut 'fw' num2str(iWav) '.s' num2str(i)];
        inp_ext = '.inp';
        inp_file_actual = [inp_file, inp_ext];
        if strcmp(fwmodel.mc_appname, 'tMCimg')
            inp_file_app = inp_file;
        elseif strcmp(fwmodel.mc_appname, 'mcx')
            inp_file_app = inp_file_actual;
        end
        
        fprintf(fid_batch, '"%s/%s" %s "%s"\n',   fwmodel.mc_exepath, fwmodel.mc_exename, fwmodel.mc_options, inp_file_app);
        fprintf(fid_batch, 'echo %d > "%s/.fw_all_start"\n', j, dirnameOut);
        
        %%%% Append extension to file name to create file.
        inp_files(j,iWav) = {inp_file_actual};
        optpos(j,:) = optpos_src(i,:);
        j=j+1;
    end
    
    for i=1:ndet
        inp_file = [dirnameOut 'fw' num2str(iWav) '.d' num2str(i)];
        inp_ext = '.inp';
        inp_file_actual = [inp_file, inp_ext];
        if strcmp(fwmodel.mc_appname, 'tMCimg')
            inp_file_app = inp_file;
        elseif strcmp(fwmodel.mc_appname, 'mcx')
            inp_file_app = inp_file_actual;
        end
        
        fprintf(fid_batch, '"%s/%s" %s "%s"\n',   fwmodel.mc_exepath, fwmodel.mc_exename, fwmodel.mc_options, inp_file_app);
        fprintf(fid_batch, 'echo %d > "%s/.fw_all_start"\n', j, dirnameOut);
        
        %%%% Append extension to input file name to create file.
        inp_files(j,iWav) = {inp_file_actual};
        optpos(j,:) = optpos_det(i,:);
        j=j+1;
    end
end

fprintf(fid_batch, stopFileCmdStr);
if ispc()
    fprintf(fid_batch, 'exit\n');
end
        
% Calculate source direction of initial photon propagation for each optode
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create and write the data to each .inp file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for iWav = 1:num_wavelengths
    for ii=1:nopt
        fid = fopen(inp_files{ii,iWav}, 'wt');
        seed = -floor(rand()*10e+7);
        fprintf(fid, '%d\n', num_phot);
        fprintf(fid, '%d\n', seed);
        fprintf(fid, '%0.1f %0.1f %0.1f\n', optpos(ii, 1), optpos(ii, 2), optpos(ii, 3));
        fprintf(fid, '%0.2f %0.2f %0.2f\n', optpos(ii, 4), optpos(ii, 5), optpos(ii, 6));
        fprintf(fid, '%e %e %e\n', time_gates(1,1), time_gates(1,2), time_gates(1,3));
        fprintf(fid, '%s\n', segfilename);
        fprintf(fid, '1 %d %d %d\n', Dx, Sx_min, Sx_max);
        fprintf(fid, '1 %d %d %d\n', Dy, Sy_min, Sy_max);
        fprintf(fid, '1 %d %d %d\n', Dz, Sz_min, Sz_max);
        fprintf(fid, '%d\n', num_tiss);
        for k=1:num_tiss
            fprintf(fid, '%g %g %g %g\n', tiss_prop(k).scattering(iWav), tiss_prop(k).anisotropy(1), ...
                tiss_prop(k).absorption(iWav), tiss_prop(k).refraction(1));
        end
        fprintf(fid, '%d %d\n', nopt-1, 1);
        for m=1:nopt
            if (m ~= ii)
                fprintf(fid, '%0.1f\t%0.1f\t%0.1f\n', optpos(m, 1), optpos(m, 2), optpos(m, 3));
            end
        end
        fclose(fid);
    end
end

fclose(fid_batch);

