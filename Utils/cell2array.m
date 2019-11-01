function a = cell2array(c)

a = [];
n = length(c(:));
type = class(c{1});

typelegal=0;
switch(type)
    case 'logical'
        typelegal=1;
    case 'single'
        typelegal=1;
    case 'double'
        typelegal=1;
    case 'char'
        typelegal=1;
    case 'uint8'
        typelegal=1;
    case 'uint16'
        typelegal=1;
    case 'uint32'
        typelegal=1;
    case 'int8'
        typelegal=1;
    case 'int16'
        typelegal=1;
    case 'int32'
        typelegal=1;
end
if typelegal==0
    return;
end
eval(sprintf('atemp = %s(zeros(n,1));', type));
for ii=1:length(c(:))
    try
        atemp(ii) = c{ii};
    catch
        return;
    end
end

dims = size(c);
dimsstr = '';
for jj=1:length(dims)
    if isempty(dimsstr)
        dimsstr = sprintf('%d', dims(jj));
    else
        dimsstr = sprintf('%s, %d ', dimsstr, dims(jj));
    end
end
eval(sprintf('a = reshape(atemp,%s);', dimsstr));

