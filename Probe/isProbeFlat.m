function b = isProbeFlat(SD)
b = true;

if isfield(SD, 'SrcPos') && isfield(SD, 'DetPos') 
    optpos = [SD.SrcPos; SD.DetPos];
else
    optpos = SD.optpos;
end
ncoord = size(optpos, 2);
for ii = 1:ncoord
    if length(unique(optpos(:,ii)))==1
        return;
    end
end
b = false;