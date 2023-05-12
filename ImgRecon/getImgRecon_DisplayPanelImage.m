function [img, hImg] = getImgRecon_DisplayPanelImage(imgrecon)
img = [];
hImg = [];
choices = get(imgrecon.handles.popupmenuImageDisplay, 'string');
iSelect = get(imgrecon.handles.popupmenuImageDisplay, 'value');
if isempty(choices)
    return;
end
selection = choices{iSelect};

% If selection is not image recon then exit
if isempty(findstr(lower(selection), 'recon'))
    if isempty(findstr(lower(selection), 'localization'))
        if isempty(findstr(lower(selection), 'resolution'))
            return;
        end
    end
end

% Find the image data represented by the colormap

switch(selection)
    case {'Localization Error'}
        img = imgrecon.localizationError;
        hImg = imgrecon.handles.hLocalizationError;
    case {'Resolution'}
        img = imgrecon.resolution;
        hImg = imgrecon.handles.hResolution;
    case {'HbO Recon'}
        img = imgrecon.Aimg_conc.HbO;
        hImg = imgrecon.handles.hHbO;
    case {'HbR Recon'}
        img = imgrecon.Aimg_conc.HbR;
        hImg = imgrecon.handles.hHbR;
end


