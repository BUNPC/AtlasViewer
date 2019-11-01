function digpts = saveDigpts(digpts, mode)

if isempty(digpts) | isempty([digpts.srcpos; digpts.detpos; digpts.refpts.pos; digpts.pcpos])
    return;
end

if isempty(digpts.pathname)
    digpts.pathname = [pwd, '/'];
end

dirname = digpts.pathname;
if ~exist(dirname, 'dir')
    mkdir(dirname);
end
if ~exist('mode', 'var')
    mode='nooverwrite';
end

if ~exist([dirname 'digpts.txt'], 'file') | strcmp(mode, 'overwrite')
    % Save points: unapply T_2mc to get back to original dig pts
    digpts.srcpos = xform_apply(digpts.srcpos, inv(digpts.T_2mc));
    digpts.detpos = xform_apply(digpts.detpos, inv(digpts.T_2mc));
    digpts.refpts.pos = xform_apply(digpts.refpts.pos, inv(digpts.T_2mc));
    digpts.pcpos = xform_apply(digpts.pcpos, inv(digpts.T_2mc));
    fid = fopen([dirname 'digpts.txt'], 'w');
    for ii=1:size(digpts.refpts.pos,1)
        fprintf(fid, '%s: %0.2f %0.2f %0.2f\n', digpts.refpts.labels{ii}, digpts.refpts.pos(ii,1), digpts.refpts.pos(ii,2), digpts.refpts.pos(ii,3));
    end
    for ii=1:size(digpts.srcpos,1)
        fprintf(fid, 's%d: %0.2f %0.2f %0.2f\n', ii, digpts.srcpos(ii,1), digpts.srcpos(ii,2), digpts.srcpos(ii,3));
    end
    for ii=1:size(digpts.detpos,1)
        fprintf(fid, 'd%d: %0.2f %0.2f %0.2f\n', ii, digpts.detpos(ii,1), digpts.detpos(ii,2), digpts.detpos(ii,3));
    end
    for ii=1:size(digpts.pcpos,1)
        fprintf(fid, 'p%d: %0.2f %0.2f %0.2f\n', ii, digpts.pcpos(ii,1), digpts.pcpos(ii,2), digpts.pcpos(ii,3));
    end
    fclose(fid);
end

if ~exist([dirname 'digpts2mc.txt'], 'file') | strcmp(mode, 'overwrite')
    T_digpts2mc = digpts.T_2mc;
    save([dirname 'digpts2mc.txt'], 'T_digpts2mc', '-ascii');
end

