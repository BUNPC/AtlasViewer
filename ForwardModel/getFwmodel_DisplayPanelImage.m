function img = getFwmodel_DisplayPanelImage(fwmodel)

% Wavelength to display always one for now. TBD: Add feature to select
% between wavelengths
iW = 1;
if all(fwmodel.Adot(fwmodel.iCh(1),:,iW)==0)
    img = fwmodel.cmThreshold(1).*ones(size(sum(fwmodel.Adot(fwmodel.iCh,:,iW),1),2), 1);
else
    img = log10(sum(fwmodel.Adot(fwmodel.iCh,:,iW),1));
end

