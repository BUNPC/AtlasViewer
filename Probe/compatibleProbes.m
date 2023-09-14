function b = compatibleProbes(probe1_0, probe2_0)
b = true;
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

% In comparing meas list compatibility, order does not matter
probe1.ml = sort(probe1.ml);
probe2.ml = sort(probe2.ml);

if ~isempty(probe1.ml) && ~isempty(probe2.ml)
    if size(probe1.ml,1) ~= size(probe2.ml,1)
        return;
    end
    if ~all(probe1.ml(:) == probe2.ml(:))
        return;
    end
end
b = true;

