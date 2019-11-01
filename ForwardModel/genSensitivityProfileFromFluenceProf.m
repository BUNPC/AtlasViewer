function fwmodel = genSensitivityProfileFromFluenceProf(fwmodel, probe, T_vol2mc, dirnameSubj)

fwmodel = resetSensitivity(fwmodel,probe,dirnameSubj);
if ~exist('fw','dir')
    mkdir('fw');
end
if dirnameSubj(end)~='/' && dirnameSubj(end)~='\'
    dirnameSubj(end+1)='/';
end
dirnameOut = [dirnameSubj 'fw/'];

nFluenceProfPerFile0 = fwmodel.nFluenceProfPerFile;

probe.srcpos = probe.optpos_reg(1:probe.nsrc,:);
probe.detpos = probe.optpos_reg(probe.nsrc+1:probe.noptorig,:);

nMeas = size(probe.ml,1);
hwait = waitbar(0, sprintf('Loading measurement %d of %d', 0, nMeas));
for ii=1:nMeas
    waitbar(ii/nMeas, hwait, sprintf('Loading measurement %d of %d for wavelength %d', ii, nMeas));
    
    fwmodel.Ch = probe.ml(ii,1:2);
    
    % Display src and det selections
    fprintf('Selected [S%d, D%d]\n', fwmodel.Ch(1), fwmodel.Ch(2));
       
    % Find fluence profiles of the selected optodes
    [fwmodel, iFluenceSrc, iFluenceDet] = findSelectedOptodeFluences(fwmodel, probe, T_vol2mc);

    % Update number of wavelengths based on the number in the fluence
    % profiles
    fwmodel.nWavelengths = size(fwmodel.fluenceProf(1).intensities,3);

    if fwmodel.Ch(1) & fwmodel.Ch(2)
        fwmodel = genSensitivityProfile(fwmodel, probe, iFluenceSrc, iFluenceDet);
    end   
end
close(hwait);

Adot = fwmodel.Adot;
save([dirnameOut 'Adot.mat'],'Adot');

fwmodel.Ch = [0,0];
fwmodel.nFluenceProfPerFile = nFluenceProfPerFile0;



% ---------------------------------------------------------------------------------------------
function [fwmodel, iFluenceSrc, iFluenceDet] = findSelectedOptodeFluences(fwmodel, probe, T_vol2mc)

iFluenceSrc = 0;
iFluenceDet = 0;

% Find fluence of currently selected optode

% For a course fluence profile and a short separation channel there is a good chance of 
% choosing the same profile optode index for source and detector which would 
% not make sense - it would be as if the channel would be between it and itself - we
% therefore choose the second closest optode index for the detector. 
ith_closest = 1;
while (iFluenceSrc==iFluenceDet) & (ith_closest<3)
    if fwmodel.Ch(1)
        [fwmodel, iFluenceSrc] = findOptodeFluence(fwmodel, 'S', probe, T_vol2mc);
    end
    if fwmodel.Ch(2)
        [fwmodel, iFluenceDet] = findOptodeFluence(fwmodel, 'D', probe, T_vol2mc, ith_closest);
    end
    if iFluenceSrc==iFluenceDet
        fprintf('Source and detector approximated by the same fluence profile. Will search for the next closest profile.\n');
    end
    ith_closest=ith_closest+1;
end



% ---------------------------------------------------------------------------------------------
function [fwmodel, iFluence] = findOptodeFluence(fwmodel, opttype, probe, T_vol2mc, ith_closest)

if ~exist('ith_closest','var')
    ith_closest = 1;
end

DISPLAY=0;

% Output parameters
iFluence = 0;

fluenceProfFnames = fwmodel.fluenceProfFnames;

% Parameters of the best profile
fluenceProfBest   = initFluenceProf();
iFluenceBest      = 0;
distmin           = 1e6;

pos = [];
jj = [];

% Get position(s) of clicked optode(s)
if opttype=='S'
    pos = xform_apply(probe.srcpos(fwmodel.Ch(1),:), inv(T_vol2mc));
    optSelected = ['S',num2str(fwmodel.Ch(1))];
    jj=1;
elseif opttype=='D'
    pos = xform_apply(probe.detpos(fwmodel.Ch(2),:), inv(T_vol2mc));
    optSelected = ['D',num2str(fwmodel.Ch(2))];
    jj=2;
end

% Search through all the fluence profiles for the one that contains the
% closest optode (and asscoated fluence) to our selected optode.  
for ii=1:length(fluenceProfFnames)
        
    % Load only what we need from the fluence profile to avoid hogging
    % memory and speed up the search
    fluenceProf = loadFluenceProf(fluenceProfFnames{ii}, 'srcpos','index','mesh','voxPerNode');
    
    optpos = fluenceProf.srcpos;
    [~,iFluence,dist1] = nearest_point(optpos, pos, ith_closest);
    
    if ii==1
        fluenceProf.mesh.vertices = xform_apply(fluenceProf.mesh.vertices, T_vol2mc);
    end
    
if DISPLAY
    iF = iFluence;
    p = xform_apply(optpos, T_vol2mc);
    hold on;
    hp = plot3(p(:,1), p(:,2), p(:,3), '.r', 'markersize',10);
    hp_closest = plot3(p(iF,1), p(iF,2), p(iF,3), '.g', 'markersize',20);
    pause(1);
    delete(hp);
    delete(hp_closest);
end

    if dist1<distmin
        fluenceProfBest = fluenceProf;
        iFluenceBest = iFluence;
        distmin = dist1;
    end
end

% Now load the whole profile, either from the cache or file
fwmodel = loadFluenceProfCached(fwmodel, fluenceProfBest, jj);
iFluence = iFluenceBest;




% -------------------------------------------------------------------------------
function fwmodel = genSensitivityProfile(fwmodel, probe, iFluenceSrc, iFluenceDet)

base = fwmodel.nFluenceProfPerFile;

if iFluenceSrc==0 | iFluenceDet==0
    return;
end

if ~isempty(probe) & ~isempty(probe.ml)
    iMeas = find(probe.ml(:,1)==fwmodel.Ch(1) & probe.ml(:,2)==fwmodel.Ch(2), 1);
else
    iMeas=1;
end

%%%% Get the fluence distribution for source and detector %%%%

% First check if there's a profile already cached

%{
% Caching code needs more work. See loadFluenceProfCached.
if isFluenceProfEmpty(fwmodel.fluenceProf(1))
    i=2; j=2;
elseif isFluenceProfEmpty(fwmodel.fluenceProf(2))
    i=1; j=1;
else
    i=1; j=2;
end
%}

i=1; j=2;

for iW=1:fwmodel.nWavelengths
    As = fwmodel.fluenceProf(i).intensities(iFluenceSrc,:,iW);
    As(isnan(As))=0;  % A MC appliaction might generate NaN values. Set them to zeros
    
    Ad = fwmodel.fluenceProf(j).intensities(iFluenceDet,:,iW);
    Ad(isnan(Ad))=0;  % A MC appliaction might generate NaN values. Set them to zeros
    
    voxPerNode = reshape(fwmodel.voxPerNode, [size(As,1), size(As,2)]);
    
    iF_s = fwmodel.fluenceProf(i).index;
    iF_d = fwmodel.fluenceProf(j).index;
    
    % Get normalized fluence at the detector position in the sources fluence
    % profile
    normfactor_d = 1;
    if ~isempty(fwmodel.fluenceProf(i).normfactors)
        normfactor_d = fwmodel.fluenceProf(i).normfactors(iFluenceSrc, (iF_d-1)*base + iFluenceDet, iW);
    end
    
    % Get normalized fluence at the source position in the detectors fluence
    % profile
    normfactor_s = 1;
    if ~isempty(fwmodel.fluenceProf(j).normfactors)
        normfactor_s = fwmodel.fluenceProf(j).normfactors(iFluenceDet, (iF_s-1)*base + iFluenceSrc, iW);
    end
    
    fprintf('iFluenceSrc = %d\n', iFluenceSrc);
    fprintf('iFluenceDet = %d\n', iFluenceDet);
    fprintf('iF_d = %d, iNorm_d = %d, normfactor_d = %0.3g\n', iF_d, (iF_d-1)*base + iFluenceDet, normfactor_d);
    fprintf('iF_s = %d, iNorm_s = %d, normfactor_s = %0.3g\n', iF_s, (iF_s-1)*base + iFluenceSrc, normfactor_s);
    fprintf('\n')
    
    % Get Adot
    normfactor = (normfactor_s + normfactor_d)/2;
    if normfactor~=0
        fwmodel.Adot(iMeas,:,iW) = (As.*Ad.*voxPerNode)/normfactor;
    else
        disp(sprintf('No photons detected between Src %d and Det %d',fwmodel.Ch(1),fwmodel.Ch(2)))
        fwmodel.Adot(iMeas,:,iW) = zeros(size(As));
    end
end





% -------------------------------------------------------------------
function fwmodel = loadFluenceProfCached(fwmodel, fluenceProfBest, jj)

%{
% Caching code needs more work.
if (fwmodel.fluenceProf(1).index == fluenceProfBest.index) & ~isFluenceProfEmpty(fwmodel.fluenceProf(1))
    fwmodel.fluenceProf(2) = initFluenceProf();
    return;
end
if (fwmodel.fluenceProf(2).index == fluenceProfBest.index) &  ~isFluenceProfEmpty(fwmodel.fluenceProf(2))
    fwmodel.fluenceProf(1) = initFluenceProf();
    return;
end
%}
fwmodel.fluenceProf(jj)  = loadFluenceProf(fwmodel.fluenceProfFnames{fluenceProfBest.index});


