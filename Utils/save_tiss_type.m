function save_tiss_type(filenm, tiss)

if isempty(tiss)
    return;
end

fid = fopen(filenm,'w');
if ischar(tiss)
    j = 1;
    k = find(tiss==':');
    if length(k)==0
        k=length(tiss)+1;
    end
    ntiss = length(k)+1;
    
    for ii=1:ntiss-1
        tiss = tiss(j:k(ii)-1);
        fprintf(fid,'%s\n',tiss);
        j = k(ii)+1;
    end
elseif iscell(tiss)
    for ii=1:length(tiss)
        fprintf(fid,'%s\n',tiss{ii});
    end
elseif isstruct(tiss)
    for ii=1:length(tiss)
        fprintf(fid,'%s\n',tiss(ii).name);
    end
end
fclose(fid);
