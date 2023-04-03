function A = optodes_tbl_copy_data(A, OptPos, GrommetType, GrommetRot, optid)
if ~exist('optid','var')
    optid = 0;
end
k = 0;
for ii = 1:size(OptPos,1)
    if optid > 0
        k = 1;
        A{ii,k} = num2str(optid+ii);
    end
    A{ii,1+k} = real2str(OptPos(ii,1));
    A{ii,2+k} = real2str(OptPos(ii,2));
    A{ii,3+k} = real2str(OptPos(ii,3));
    A{ii,4+k} = GrommetType{ii};
    if iscell(GrommetRot)
        A{ii,5+k} = GrommetRot{ii};
    else
        A{ii,5+k} = GrommetRot(ii);
    end
end
A(ii+1:end,:) = {''};     % Set the rest of the rows to empty string 
