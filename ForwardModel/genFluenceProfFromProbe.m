function [d, k, p, kk, dd] = genFluenceProfFromProbe(probename, dirnameSubj)

%
% Example Usage:
%
%
%  [d, k, p, kk, dd] = genFluenceProfFromProbe('probe_reg2.txt',getAtlasDir);
%

if ~exist('dirnameSubj','var') && isempty(dirnameSubj)
    dirnameSubj = pwd;
end
if dirnameSubj(end)~='/' && dirnameSubj(end)~='\'
    dirnameSubj(end+1)='/';
end

fwmodel  = initFwmodel();
headsurf = initHeadsurf();
pialsurf = initPialsurf();
headvol  = initHeadvol();
probe    = initProbe();

headvol  = getHeadvol(headvol, dirnameSubj);
headsurf = getHeadsurf(headsurf, dirnameSubj);
pialsurf = getPialsurf(pialsurf, dirnameSubj);
probe.optpos_reg = load(probename, '-ascii');
fwmodel  = getFwmodel(fwmodel, dirnameSubj, pialsurf, headsurf, headvol, probe);

if exist([fwmodel.fluenceProfFnames{1},'.orig'], 'file')
    movefile([fwmodel.fluenceProfFnames{1},'.orig'], fwmodel.fluenceProfFnames{1});
end

% Given current probe, Generate fleunce profiles
fprintf('\n');
fprintf('Find nearest optodes in each file to probe optodes.\n');
p = zeros(size(probe.optpos_reg,1), 3, length(fwmodel.fluenceProfFnames));
kk = zeros(size(probe.optpos_reg,1), length(fwmodel.fluenceProfFnames));
dd = zeros(size(probe.optpos_reg,1), length(fwmodel.fluenceProfFnames));
for jj=1:length(fwmodel.fluenceProfFnames)
    prof = loadFluenceProf(fwmodel.fluenceProfFnames{jj});
    [p(:,:,jj), kk(:,jj), dd(:,jj)] = nearest_point(prof.srcpos, probe.optpos_reg);
end
[d,k] = min(dd,[],2);

fprintf('\n');
fprintf('Assign nearest optodes among all the fluence files to decimated fluence profile.\n');
for jj=1:length(fwmodel.fluenceProfFnames)
    prof = loadFluenceProf(fwmodel.fluenceProfFnames{jj});
    if jj==1
        fwmodel.fluenceProfDecim.tiss_prop = prof.tiss_prop;
        fwmodel.fluenceProfDecim.nphotons = prof.nphotons;
        fwmodel.fluenceProfDecim.voxPerNode = prof.voxPerNode;
        fwmodel.fluenceProfDecim.mesh = prof.mesh;
        fwmodel.fluenceProfDecim.index = 1;
        fwmodel.fluenceProfDecim.last = true;
    end
    if isempty(find(k==jj))
        continue;
    end
    fwmodel.fluenceProfDecim.intensities = [fwmodel.fluenceProfDecim.intensities; prof.intensities(k==jj,:)];
    fwmodel.fluenceProfDecim.normfactors = [fwmodel.fluenceProfDecim.normfactors; prof.normfactors(k==jj,:)];
    fwmodel.fluenceProfDecim.srcpos = [fwmodel.fluenceProfDecim.srcpos; prof.srcpos(k==jj,:)];  
end

% Save decimated file to first fluence profile name.
fprintf('\n');
fprintf('Saving decimated fleunce to %s.\n', fwmodel.fluenceProfFnames{1});
movefile(fwmodel.fluenceProfFnames{1}, [fwmodel.fluenceProfFnames{1},'.orig']);
fluenceProfDecim = fwmodel.fluenceProfDecim;
save(fwmodel.fluenceProfFnames{1}, '-struct', 'fluenceProfDecim');


