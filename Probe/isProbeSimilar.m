function b = isProbeSimilar(SD, dataTree, digpts)
b = [];
b1 = ~similarProbes(digpts, SD);
b2 = ~similarProbes(dataTree, SD);
if isempty(b1) && isempty(b2)
    return
end
if ~isempty(b1)
    b = b1;
    return;
end
if ~isempty(b2)
    b = b2;
    return;
end



% ---------------------------------------------------------------------
function b = similarProbes(probe1_0, probe2_0)
b = [];
if isempty(probe1_0)
    return;
end
if isempty(probe2_0)
    return;
end
probe1 = extractProbe(probe1_0);
probe2 = extractProbe(probe2_0);
if probe1.isempty(probe1)
    return;
end
if probe2.isempty(probe2)
    return;
end

b = false;
if size(probe1.srcpos,1) ~= size(probe2.srcpos,1)
    return;
end
if size(probe1.detpos,1) ~= size(probe2.detpos,1)
    return;
end
if size(probe1.ml,1) ~= size(probe2.ml,1)
    return;
end
ds1 = distmatrix(probe1.optpos);
ds2 = distmatrix(probe2.optpos);
b = true;


