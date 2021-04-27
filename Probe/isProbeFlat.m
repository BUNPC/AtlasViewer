function b = isProbeFlat(probe)
b = true;

if ~isempty(probe.optpos_reg)
    optpos = probe.optpos_reg;
else
    optpos = probe.optpos;
end
ncoord = size(optpos, 2);
for ii = 1:ncoord
    if length(unique(optpos(:,ii)))==1
        return;
    end
end
b = false;