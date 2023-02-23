function h = createColorbar(cmThreshold, img)
global atlasViewer
h = [];
if nargin == 0
    return;
end
if ~exist('img','var')
    img = [];
end
if isempty(cmThreshold) && isempty(img)
    return;
end

if ~isempty(img)
    if ishandles(img)
        img = img.FaceVertexCData;
    end
    if ~isempty(cmThreshold)
        img(img < cmThreshold(1)) = cmThreshold(1); 
    end
    cmThreshold(1) = min(img);
    cmThreshold(2) = max(img);
end

% Colormap threshold error check
if cmThreshold(1) == cmThreshold(2)
    cmThreshold(1) = cmThreshold(1)-1;
    cmThreshold(2) = cmThreshold(2)+1;
end

% Get colormap threshold range
cmRange = cmThreshold(2) - cmThreshold(1);

% Create new colormap graphic
colormin = [.80, .80, .80];
h = colorbar;
set(h, 'visible','on');
if isempty(cmThreshold)
    return;
end
n = 100;
cm = jet(n);

% Determine which values to gray out
noValRange = 2;
if isempty(img)
    noVal = 0;
    k = floor((abs(noVal) * n) / cmRange);
else
    nbins = n;
    bins = histcounts(img, nbins, 'BinLimits',[min(img), max(img)]);
    [~, iBin] = max(bins);
    k = iBin;
    if bins(iBin) == length(img)
        noValRange = floor(n/2);
    end
end

% Gray out values in color map table
for ii = k-noValRange:k+noValRange
    if ii < 1
        kk = 1;
    elseif ii > n
        kk = n;
    else
        kk = ii;
    end
    cm(kk,:) = colormin;
end

colormap(cm);
caxis(cmThreshold);

% Set colormap thresholds edit box
set(atlasViewer.imgrecon.handles.editColormapThreshold,'string',sprintf('%0.2g %0.2g',cmThreshold(1), cmThreshold(2)));


