function stats = initStats(d)
global MEAN_DIST_THRESH;
global MAX_DIST_THRESH;
global STD_DIST_THRESH;

if ~exist('d','var')
    d = [];
end
stats = struct( ...
                'mean',initStat(mean(d), MEAN_DIST_THRESH), ...
                'max',initStat(max(d), MAX_DIST_THRESH), ...
                'std',initStat(std(d(:),1,1), STD_DIST_THRESH) ...
               );


% --------------------------------------------------
function s = initStat(value, threshold)
if ~exist('value','var')
    value = [];
end
if ~exist('threshold','var')
    threshold = -1;
end
if ~isempty(value) && ~isnan(value)
    s = struct('pass',value<threshold, 'value',value, 'threshold',threshold);
else
    s = struct('pass',false, 'value',-1, 'threshold',threshold);
end

