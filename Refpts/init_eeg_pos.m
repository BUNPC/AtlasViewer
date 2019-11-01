function refpts = init_eeg_pos(refpts, pos, labels)

if ~exist('pos','var')
    pos = refpts.pos;    
end
if ~exist('labels','var')
    labels = refpts.labels;    
end

curves = fieldnames(refpts.eeg_system.curves);
for ii=1:length(labels)
    for jj=1:length(curves)
        eval(sprintf('idx = find(strcmpi(refpts.eeg_system.curves.%s.labels, labels{ii}));', curves{jj}));
        if ~isempty(idx)
            eval(sprintf('refpts.eeg_system.curves.%s.pos{idx,1} = pos(ii,:);', curves{jj}));
            break;
        end
    end
end

% get length of all curves
for jj=1:length(curves)
    eval(sprintf('[~,refpts.eeg_system.curves.%s.len] = curve_walk(refpts.eeg_system.curves.%s.pos);', curves{jj}, curves{jj}));
end

refpts = calcRefptsCircumf(refpts);

