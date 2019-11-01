function b = isFluenceProfEmpty(fluenceProf)

b=[];
for ii=1:length(fluenceProf)
    b(ii) = isFluenceProfEmptySingle(fluenceProf(ii));
end


% ---------------------------------------------------------------------
function b = isFluenceProfEmptySingle(fluenceProf)

b = true;
if isempty(fluenceProf)
    return;
end
if ~isfield(fluenceProf, 'intensities')
    b=[];
    return;
end
if ~isfield(fluenceProf, 'srcpos')
    b=[];
    return;
end
if isempty(fluenceProf.intensities)
    return;
end
if isempty(fluenceProf.srcpos)
    return;
end
b = false;


