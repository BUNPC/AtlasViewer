function [rp_atlas, rp_subj] = findCorrespondingRefpts(refpts, digpts)

refpts = makeLandmarksBackwardCompatible(refpts);
[digpts.refpts.pos, digpts.refpts.labels] = makeLandmarksBackwardCompatible(digpts.refpts.pos, digpts.refpts.labels);

jj=1;
for ii=1:length(refpts.labels)
    kk = find(strcmpi(refpts.labels{ii},digpts.refpts.labels));
    if ~isempty(kk)
        rp_atlas(jj,:) = refpts.pos(ii,:);
        rp_subj(jj,:)  = digpts.refpts.pos(kk,:);
        jj=jj+1;
    end
end

