function o = getOrientationCompl(o)

% Get complement of orientation in o

for ii=1:3
    if o(ii)=='L'
        o(ii)='R';
    elseif o(ii)=='R'
        o(ii)='L';
    elseif o(ii)=='S'
        o(ii)='I';
    elseif o(ii)=='I'
        o(ii)='S';
    elseif o(ii)=='A'
        o(ii)='P';
    elseif o(ii)=='P'
        o(ii)='A';
    end
end
