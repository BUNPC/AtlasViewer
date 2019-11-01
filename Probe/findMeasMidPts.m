function probe = findMeasMidPts(probe, mode)

if ~exist('mode','var') | isempty(mode)
    mode = 'subj';
end

if strcmp(mode, 'group')
    optpos_reg = probe.optpos_reg_mean;
else
    optpos_reg = probe.optpos_reg;    
end

if isempty(optpos_reg)
    return;
end
ml = probe.ml;
nsrc = probe.nsrc;
optpos_reg_s = optpos_reg(1:nsrc,:);
optpos_reg_d = optpos_reg(nsrc+1:end,:);
mlmp = [];
for ii=1:size(ml,1)
    s = optpos_reg_s(ml(ii,1),:);
    d = optpos_reg_d(ml(ii,2),:);
    mlmp(ii,:) = [s(1)+d(1), s(2)+d(2), s(3)+d(3)] / 2; 
end

if strcmp(mode, 'group')
    probe.mlmp_mean = mlmp;
else
    probe.mlmp = mlmp;
end

