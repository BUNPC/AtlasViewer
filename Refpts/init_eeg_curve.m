function p = init_eeg_curve(labels, idxs)

if ~exist('idxs', 'var')
    idxs = {[],[],[]};
end

n = length(labels);

if ~isempty(idxs{1})
    if idxs{1}(end)<0
        idx_10_20 = idxs{1}(1:end-1);
    else
        idx_10_20 = idxs{1}(1):idxs{1}(2):n-idxs{1}(3);
    end
else
    idx_10_20 = [];
end

if ~isempty(idxs{2})
    if idxs{2}(end)<0
        idx_10_10 = idxs{2}(1:end-1);
    else
        idx_10_10 = idxs{2}(1):idxs{2}(2):n-idxs{2}(3);
    end
else
    idx_10_10 = [];
end

if ~isempty(idxs{3})
    if idxs{3}(end)<0
        idx_10_5 = idxs{3}(1:end-1);
    else
        idx_10_5 = idxs{3}(1):idxs{3}(2):n-idxs{3}(3);
    end
else
    idx_10_5 = [];
end

p = struct('pos',{cell(length(labels),1)}, 'labels',{labels}, 'idx_10_20',idx_10_20, 'idx_10_10',idx_10_10, 'idx_10_5',1:n, 'selected',1, 'len',0);

