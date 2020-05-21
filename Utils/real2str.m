function s = real2str(x, options, places)
if ~exist('options','var') || isempty(options)
    options = 'truncate';
end
if ~exist('places','var') || isempty(places)
    places = 1;
end

if strcmp(options, 'truncate')
    if round(x) == x
        s = sprintf('%d', x);
    elseif places==1
        s = sprintf('%0.1f', x);
    elseif places==2
        s = sprintf('%0.2f', x);
    elseif places==3
        s = sprintf('%0.3f', x);
    end
else
    s = num2str(x);
end

