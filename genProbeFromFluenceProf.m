function genProbeFromFluenceProf(fwmodel)

fid = fopen('./probe.txt','w');

for ii=1:length(fwmodel.fluenceProfFnames)
    prof = loadFluenceProf(fwmodel.fluenceProfFnames{ii});
    for jj=1:size(prof.srcpos,1)
        s = prof.srcpos(jj,:);
        fprintf(fid, '%0.1f\t%0.1f\t%0.1f\n', s(1), s(2), s(3));
    end
end

fclose(fid);