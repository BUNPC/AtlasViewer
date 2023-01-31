function refpts = extract_eeg_pts(refpts, mode)

% 
%  Function: 
%      
%         refpts = extract_eeg_pts(refpts)
%
%  Description:
%
%         Function determines the set of eeg points selected by user
%         (10-20, 10-10, 10-5, etc) and copies from refpts.eeg_system.curves to 
%         to the refpts.pos and refpts.labels, the ones that have a position 
%         associated with them. This then becomes the set of displayed 
%         eeg points.  
%
%

if ~exist('mode','var')
    mode = 'warning';
end

refpts.pos = [];
refpts.labels = {};
labels_missing = {};
warningmsg = {};

eeg_system_labels = {};
switch(refpts.eeg_system.selected)
    case '10-20'
        eeg_system_labels = refpts.eeg_system.labels.labels_10_20;
    case '10-10'
        eeg_system_labels = refpts.eeg_system.labels.labels_10_10;
    case '10-5'
        eeg_system_labels = refpts.eeg_system.labels.labels_10_5;
    case '10-2-5'
    case '10-1'
end

hwait = waitbar(0,sprintf('Extracting %s EEG reference points ...', refpts.eeg_system.selected));
kk = 1;
ll = 1;
curves = fieldnames(refpts.eeg_system.curves);
for ii=1:length(eeg_system_labels)
    for jj=1:length(curves)
        eval(sprintf('idx = find(strcmpi(refpts.eeg_system.curves.%s.labels, eeg_system_labels{ii}));', curves{jj}));
        if ~isempty(idx)
            eval(sprintf('nil = isempty(refpts.eeg_system.curves.%s.pos{idx});', curves{jj}));
            if ~nil
                eval(sprintf('refpts.pos(kk,:) = refpts.eeg_system.curves.%s.pos{idx};', curves{jj}));
                eval(sprintf('refpts.labels{kk} = refpts.eeg_system.curves.%s.labels{idx};', curves{jj}));
                kk=kk+1;
            else
                labels_missing{ll} = eeg_system_labels{ii};
                ll=ll+1;
            end
            break;
        end
        waitbar(ii/length(eeg_system_labels), hwait);
    end
end
close(hwait);

if ~isempty(labels_missing) & strcmpi(mode, 'warning')
    labels_missing_str = labels_missing{1};
    for ii=2:length(labels_missing)
        labels_missing_str = sprintf('%s, %s', labels_missing_str, labels_missing{ii});
        if mod(ii,10)==0
            labels_missing_str = sprintf('%s\n', labels_missing_str);
        end
    end
    warningmsg{1} = sprintf('The following %s points are missing:\n%s', refpts.eeg_system.selected, labels_missing_str);
    MenuBox(warningmsg{1},'OK');
    
    warningmsg{2} = sprintf('Use the Calculate menu item under Tool --> Reference Points to generate them.\n');
    MenuBox(warningmsg{2},'OK');
end


