function status = genMultWavelengthSimInFluenceFiles(fwmodel, nWl)

%
% Example usage:
%   
%    genMultWavelengthSimInFluenceFiles(atlasViewer.fwmodel)
%
%

status = 0;

if ~exist('nWl','var') | isempty(nWl)
    nWl = 2;
end

if isstruct(fwmodel)
    fluenceProfFnames = fwmodel.fluenceProfFnames;
else
    fluenceProfFnames{1} = fwmodel;
end

for ii=1:length(fluenceProfFnames)
    
    [s, readonly] = loadFluenceProf(fluenceProfFnames{ii});
    
    nWlactual = size(s.intensities,3);
    d = nWl - nWlactual; 
    if d>0
        
        if readonly
            fprintf('Cannot generate simulated wavelength data; "%s" is read only\n', fluenceProfFnames{ii});
            continue;
        end
        
        for iW=nWlactual+1:nWl
            
            s.intensities(:,:,iW) = s.intensities;
            s.normfactors(:,:,iW) = s.normfactors;
            for jj=1:length(s.tiss_prop)
                s.tiss_prop(jj).scattering(iW) = s.tiss_prop(jj).scattering(1);
                s.tiss_prop(jj).absorption(iW) = s.tiss_prop(jj).absorption(1);
                s.tiss_prop(jj).anisotropy(iW) = s.tiss_prop(jj).anisotropy(1);
                s.tiss_prop(jj).refraction(iW) = s.tiss_prop(jj).refraction(1);
            end
            
        end
        
        intensities = s.intensities;
        normfactors = s.normfactors;
        tiss_prop = s.tiss_prop;
        
        fprintf('Saving %d wavelength simulation in %s\n', nWl, fluenceProfFnames{ii});
        save(fluenceProfFnames{ii}, '-append', 'intensities', 'normfactors', 'tiss_prop');
    end
    
end

