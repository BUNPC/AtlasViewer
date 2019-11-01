function refpts = getRefpts(refpts, dirname0)

if iscell(dirname0)
    for ii=1:length(dirname0)
        refpts = getRefpts(refpts, dirname0{ii});
        if ~refpts.isempty(refpts)
            return;
        end
    end
    return;
end

if isempty(dirname0)
    return;
end

if dirname0(end)~='/' && dirname0(end)~='\'
    dirname0(end+1)='/';
end

dirname = [dirname0, 'anatomical/'];

if exist([dirname, 'refpts.mat'],'file')

    load([dirname, 'refpts.mat'],'-mat');
    
else

    if ~isempty(refpts.pos)
        return;
    end
    if ishandles(refpts.handles.labels)
        return;
    end
    
    % Find ref point files 
    [refpts_fn,refpts_labels_fn] = findRefptsFile(dirname);
    if isempty(refpts_fn) | isempty(refpts_labels_fn)        
        fprintf('Note: No ref points file found in %s\n', dirname);
        return;
    end
    
    % See if labels file matches ref points file 
    if ~matchRefptsFilenames(refpts_fn,refpts_labels_fn)
        menu('Warning: Ref points file and ref points labels file don''t match. Ref points not loaded.','OK');
        return;        
    end
    
    % Found a ref pts file we can use
    rp = load([dirname refpts_fn],'-ascii');
    if exist([dirname, 'refpts2vol.txt'],'file')
        T_2vol = load([dirname, 'refpts2vol.txt'],'-ascii');
    else
        T_2vol = eye(4);
    end        
    rp = xform_apply(rp,T_2vol);
    rp_labels = {};
    
    fid = fopen([dirname refpts_labels_fn],'rt');
    if fid~=-1
        for ii=1:size(rp,1)
            rp_labels{ii} = fgetl(fid);
        end
        fclose(fid);
    end
    rp_labels = removeSpaces(rp_labels);

    % Get the eeg system standard being used by the refpts, based on the
    % LPA, RPA ear anatomy
    ear_refpts_anatomy = getRefptsEarAnatomy(rp, rp_labels);
    refpts = setRefptsEarAnatomy(refpts, ear_refpts_anatomy);

    % Add the positions of points found in refpts files to eeg positions. 
    % This (i.e., refpts.eeg_system.curves.<curvename>.pos) will be the entire set
    % of available reference points. This set can be increased or
    % recalculated using refpts.calcRrefpts().
    refpts = init_eeg_pos(refpts, rp, rp_labels);
    
    % Determine set of active reference points based on the selected and
    % configured eeg_system
    refpts = set_eeg_active_pts(refpts);
        
    refpts.T_2vol = T_2vol;

    if length(refpts.labels)>=5
        set(refpts.handles.menuItemShowRefpts,'enable','on');
    else
        set(refpts.handles.menuItemShowRefpts,'enable','off');    
    end
    
    if length(refpts.labels)>=50 & length(refpts.labels)<=100
        refpts.size = 9;
    elseif length(refpts.labels)>100
        refpts.size = 8;
    end
    
    [nz,iz,rpa,lpa,cz] = getLandmarks(refpts);
    [refpts.orientation, refpts.center] = getOrientation(nz, iz, rpa, lpa, cz);
      
end

if ~refpts.isempty(refpts)
    refpts.pathname = dirname0;
end




% ----------------------------------------------------------------------
function [refpts_fn,refpts_labels_fn] = findRefptsFile(dirname)

refpts_fn = '';
refpts_labels_fn = '';
if exist([dirname 'refpts.txt'],'file') && exist([dirname 'refpts_labels.txt'],'file')
    refpts_fn = 'refpts.txt';
    refpts_labels_fn = 'refpts_labels.txt';
else
    %%% Else...for backward compatibility 

    % Search for other possible ref pts files
    files = dir([dirname 'refpts*.txt']);
    for ii=1:length(files)
        % check for file name with prefix refpts but no 'label' string in the
        % file name then its our refpts file name.
        if isempty(findstr(files(ii).name, '_label')) & ...
           ~strcmp(files(ii).name, 'refpts2vol.txt')

            refpts_fn = files(ii).name;
            
        % Else if 'label' string does exist in the file name then its our
        % refpts labels file name.
        elseif ~isempty(findstr(files(ii).name, '_label'))
            
            refpts_labels_fn = files(ii).name;
            
        end
    end
    
end



% ----------------------------------------------------------------------
function b = matchRefptsFilenames(refpts_fn,refpts_labels_fn)

b = 1;

% Check to see that ref pts files (pts and labels) match eachother
k1 = findstr(refpts_labels_fn, '_labels');
k2 = [];
if isempty(k1)
    k2 = findstr(refpts_labels_fn, '_label');
end

refpts_fn_match = refpts_labels_fn;
if ~isempty(k1)
    refpts_fn_match(k1:k1+6) = [];
elseif ~isempty(k2)
    refpts_fn_match(k2:k2+5) = [];
else
    b = 0;
    return;
end

b = strcmp(refpts_fn, refpts_fn_match);




% ----------------------------------------------------------------------
function foos = removeSpaces( boos )

foos = {};
for ii=1:length(boos)
    kk=0;
    for jj=1:length(boos{ii})
        if boos{ii}(jj)~=' ';
            kk=kk+1;
            foos{ii}(kk) = boos{ii}(jj);
        end
    end
end

