function labels = extract_eeg_labels(curves)

labels = struct('labels_10_20',{{}}, 'labels_10_10',{{}}, 'labels_10_5',{{}});
fields = fieldnames(curves);
for ii=1:length(fields)
    eval(sprintf('b = (curves.%s.selected == 1);', fields{ii}));
    if b==0
        continue;
    end
    eval(sprintf('labels.labels_10_20 = [labels.labels_10_20; curves.%s.labels(curves.%s.idx_10_20)];', fields{ii}, fields{ii}));
    eval(sprintf('labels.labels_10_10 = [labels.labels_10_10; curves.%s.labels(curves.%s.idx_10_10)];', fields{ii}, fields{ii}));
    eval(sprintf('labels.labels_10_5 = [labels.labels_10_5; curves.%s.labels(curves.%s.idx_10_5)];', fields{ii}, fields{ii}));
end 

k = find(strcmp(labels.labels_10_20, 'dummy'));
if ~isempty(k)
    labels.labels_10_20(k) = [];
end

k = find(strcmp(labels.labels_10_10, 'dummy'));
if ~isempty(k)
    labels.labels_10_10(k) = [];
end

k = find(strcmp(labels.labels_10_5, 'dummy'));
if ~isempty(k)
    labels.labels_10_5(k) = [];
end

