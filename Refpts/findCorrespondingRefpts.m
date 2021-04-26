function [rp_atlas, rp_subj] = findCorrespondingRefpts(r1, r2)

rp_atlas = [];
rp_subj = [];

r1 = makeLandmarksBackwardCompatible(r1);
r2 = makeLandmarksBackwardCompatible(r2);

jj=1;
for ii=1:length(r1.labels)
    kk = find(strcmpi(r1.labels{ii}, r2.labels));
    if ~isempty(kk)
        rp_atlas(jj,:) = r1.pos(ii,:);
        rp_subj(jj,:)  = r2.pos(kk,:);
        jj=jj+1;
    end
end

