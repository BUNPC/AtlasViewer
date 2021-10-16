function refpts = init_eeg_pos(refpts, pos, labels) %#ok<*INUSL>

if ~exist('pos','var')
    pos = refpts.pos;     %#ok<*NASGU>
end
if ~exist('labels','var')
    labels = refpts.labels;    
end

curves = fieldnames(refpts.eeg_system.curves);
for ii = 1:length(labels)
    for jj = 1:length(curves)
        eval(sprintf('idx = find(strcmpi(refpts.eeg_system.curves.%s.labels, labels{ii}));', curves{jj}));
        if ~isempty(idx)
            eval(sprintf('refpts.eeg_system.curves.%s.pos{idx,1} = pos(ii,:);', curves{jj}));
            break;
        end
    end
end

% get length of all curves
for jj = 1:length(curves)
    eval(sprintf('[~,refpts.eeg_system.curves.%s.len] = curve_walk(refpts.eeg_system.curves.%s.pos);', curves{jj}, curves{jj}));
end

refpts = calcRefptsCircumf(refpts);

sphere = refpts.eeg_system.sphere;
filename = [getAppDir(), 'Refpts/10-5-System_Mastoids_EGI129.csd'];
if ispathvalid(filename)
    fprintf('Refpts: Found eeg system sphere file  %s\n', filename);
    [sphere.label, sphere.theta, sphere.phi, sphere.r, sphere.xc, sphere.yc, sphere.zc] = textread(filename,'%s %f %f %f %f %f %f','commentstyle','c++'); %#ok<DTXTRD>
else
    fprintf('Refpts: Did not find eeg system sphere file in  %s\n', getAppDir());
end
refpts.eeg_system.sphere = sphere;

