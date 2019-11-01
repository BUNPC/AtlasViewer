function digpts = getGroupDigpts(digpts, dirname)

dirs  = dir([dirname, '/*']);

kk=1;
for ii=1:length(dirs)
    
    % Skip all non-subject folders and files
    if ~dirs(ii).isdir
        continue;
    end
    if strcmp(dirs(ii).name, '.')
        continue;
    end
    if strcmp(dirs(ii).name, '..')
        continue;
    end
    
    % Skip all subject folders without dig pts
    if exist([dirs(ii).name, '/digpts.txt'], 'file') ~= 2
        continue;
    end
    
    % Found a subject folder with dig pts
    if kk==1
        digpts.digpts = initDigpts();
    else
        digpts.digpts(kk) = initDigpts();
    end
    digpts.digpts(kk) = getDigpts(digpts.digpts(kk), [dirname, dirs(ii).name]);    
    
    kk=kk+1;
end


% Check that all the digpts are of the same probe
if ~isempty(digpts.digpts)
       
    digpts1 = digpts.digpts(1);
    digpts1.handles = digpts.handles;
    digpts1.digpts  = digpts.digpts;
    
    for jj=2:length(digpts.digpts)
        if size(digpts.digpts(jj).srcpos,1) ~= size(digpts.digpts(1).srcpos,1)
            digpts.digpts = [];
            break;
        end
        if size(digpts.digpts(jj).detpos,1) ~= size(digpts.digpts(1).detpos,1)
            digpts.digpts = [];
            break;
        end
        
        % Calculate running mean of dig point positions 
        digpts1.refpts.pos = (digpts.digpts(jj).refpts.pos + ((jj-1) * digpts1.refpts.pos)) / jj;
        digpts1.srcpos     = (digpts.digpts(jj).srcpos  + ((jj-1) * digpts1.srcpos)) / jj;
        digpts1.detpos     = (digpts.digpts(jj).detpos + ((jj-1) * digpts1.detpos)) / jj;
        digpts1.pcpos      = (digpts.digpts(jj).pcpos + ((jj-1) * digpts1.pcpos)) / jj;
    end
    
    q = menu(sprintf('AtlasViewer has detected dig points in the current subject''s sub-folders.\nDo you want to load the mean of the group dig points?'), 'YES', 'NO');
    if q==1
        digpts = digpts1;
    else
        digpts.digpts = [];        
    end
end

