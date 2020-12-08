function sd_file_nirsFixError(ml)
global SD
global filedata

ml2 = [];
if ~isempty(filedata.SD.MeasList)
    ml2 = filedata.SD.MeasList(filedata.SD.MeasList(:,4)==1, 1:2);
end
if size(ml,1) == size(ml2,1)
   if all(ml(:)==ml2(:))
       return
   end
end
if ~isfield(filedata,'d')
    return;
end
if size(filedata.SD.SrcPos,1)~=size(SD.SrcPos,1)
    return
end
if size(filedata.SD.DetPos,1)~=size(SD.DetPos,1)
    return
end
if ~all(filedata.SD.DetPos(:)==SD.DetPos(:))
    return
end
if ~all(filedata.SD.SrcPos(:)==SD.SrcPos(:))
    return
end
ichs = zeros(1,size(SD.MeasList(:,1),1));
for ii = 1:size(SD.MeasList(:,1),1)
    for jj = 1:size(ml,1)
        if SD.MeasList(ii,1) == ml(jj,1) && SD.MeasList(ii,2) == ml(jj,2)
            ichs(ii) = 1;
        end
    end
end
filedata.d(:,ichs==0) = [];
filedata.ml = ml;


