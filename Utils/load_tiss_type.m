function tiss = load_tiss_type(filenm)

tiss = {{}};
line = '';
if isempty(filenm)
    return;
end

fid = fopen(filenm,'r');
ii=1;
while 1
    line = fgetl(fid);
    if feof(fid)
        break;
    end
    tiss{ii,1} = line;
    ii=ii+1;
end
fclose(fid);
