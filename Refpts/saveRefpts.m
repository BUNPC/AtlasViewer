function refpts = saveRefpts(refpts, T_vol2mc, mode)

if isempty(refpts) | isempty(refpts.pos)
    return;
end

dirname = [refpts.pathname, '/anatomical/'];
if ~exist(dirname, 'dir')
    mkdir(dirname);
end
if ~exist('T_vol2mc','var') | isempty(T_vol2mc)
    T_vol2mc = eye(4);
end
if ~exist('mode', 'var') | isempty(mode)
    mode='nooverwrite';
end

if ~isempty(refpts.handles.selected)
    for ii=1:size(refpts.handles.selected,1)
        if ishandles(refpts.handles.selected(ii))
            delete(refpts.handles.selected(ii));
            refpts.handles.selected(ii) = -1;
        end
    end
end

T_2vol = refpts.T_2vol;

% mode = 'nosave';
if strcmp(mode,'nosave')
    return;
end

if ~exist('./anatomical','dir')
    q = menu('About to overwrite ref points in Atlas (non-subject folder). Is this OK?','OK','CANCEL');
    if q==2
        return;
    end
end

% Get all eeg points whose position has been found, not just the selected
% ones in refpts.pos and refpts.labels. In refpts.txt we
% should have all the ones that were found. BUT we don't want to change 
% anything about the current selection of displayed eeg points in the current 
% AtlasViewer session, therefore save in a temporary local variable,
% refpts_all. 
refpts_all = refpts;
refpts_all.eeg_system.selected = '10-5';
refpts_all = set_eeg_active_pts(refpts_all, 'nowarning');

if exist([dirname,'refpts.txt'],'file') & strcmp(mode,'overwrite')
    msg = 'Old refpts.txt were moved to refpts.txt.bak';
    % menu(msg,'OK');
    fprintf('%s\n', msg);
    movefile([dirname, 'refpts.txt'], [dirname, 'refpts.txt.bak']);
    if exist([dirname,'refpts_labels.txt'],'file')
        movefile([dirname, 'refpts_labels.txt'], [dirname, 'refpts_labels.txt.bak']);
    end
    if exist([dirname,'refpts2vol.txt'],'file')
        movefile([dirname, 'refpts2vol.txt'], [dirname, 'refpts2vol.txt.bak']);
    end
end

if ~exist([dirname 'refpts2vol.txt'], 'file') | strcmp(mode, 'overwrite')
    save([dirname 'refpts2vol.txt'], 'T_2vol', '-ascii');
end

if ~exist([dirname 'refpts.txt'], 'file') | strcmp(mode, 'overwrite')
    % Unapply T_2vol to get back to original ref pts
    pos = refpts_all.pos;
    pos = xform_apply(pos, inv(T_vol2mc * T_2vol));
    save([dirname 'refpts.txt'], 'pos', '-ascii');
end

if ~exist([dirname 'refpts_labels.txt'], 'file') | strcmp(mode, 'overwrite')
    fd = fopen([dirname 'refpts_labels.txt'], 'wt');
    for ii=1:length(refpts_all.labels)
        fprintf(fd, '%s\n', refpts_all.labels{ii});
    end
    fclose(fd);
end


% Unapply T_2vol to get back to original ref pts
pos = refpts.cortexProjection.pos;
if ~isempty(pos)
    pos = xform_apply(pos, inv(T_vol2mc * T_2vol));
    save([dirname 'refpts_projection.txt'], 'pos', '-ascii');
end

