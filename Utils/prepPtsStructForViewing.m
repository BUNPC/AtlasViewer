function pts = prepPtsStructForViewing(pos,nsrc,mode,col,siz,str)

pts = repmat(struct('pos',[0 0 0],'col',[1 0 0],'size',10,'str','i','type',''), size(pos,1), 1);

% Parse args
if ~exist('nsrc','var') || isempty(nsrc)
    nsrc = size(pos,1);
    ndet = 0;
else
    ndet = size(pos,1)-nsrc;
end
if ~exist('mode','var') || isempty(mode)
    mode = 'probenum';
end
if ~exist('col','var') || isempty(col)
    if strncmp(mode,'probe',5)
        col(1,:) = [1 0 0];
        col(2,:) = [0 0 1];
        type = {'s','d'};
    elseif strncmp(mode,'refpts',6)
        col(1,:) = [0 0 0];
        col(2,:) = [0 0 0];
        type = {'r','r'};
    end
else
    col(2,:) = col(1,:);
    type = {'r','r'};
end
if ~exist('siz','var') || isempty(siz)
    siz = 11;
end
if ~exist('str','var') || isempty(str)
    str = '';
end

% Generate arrays from args for every pos
if size(pos,1)<200
    sizetxt = siz;
    sizecir = siz*2;
else
    sizetxt = siz/2;
    sizecir = siz;
end
if ndet>0
    colarr = [repmat(col(1,:),nsrc,1); repmat(col(2,:),ndet,1)];
    typearr = [repmat(type{1},nsrc,1); repmat(type{2},ndet,1)];
else
    colarr = repmat(col(1,:),nsrc,1);
    typearr = repmat(type{1},nsrc,1);
end
if isempty(str)
    csrc = str2cell(num2str(1:nsrc),' ');
    csrc(strcmp(csrc,'')) = [];

    cdet = str2cell(num2str(1:ndet),' ');
    cdet(strcmp(cdet,'')) = [];
    
    strarr = [csrc; cdet];
else
    strarr = str;
end


% Assign arrays to every point
for ii=1:size(pos)
    pts(ii).pos  = pos(ii,:);
    pts(ii).textsize = sizetxt;
    pts(ii).circlesize = sizecir;
    pts(ii).col  = colarr(ii,:);
    pts(ii).type = typearr(ii);
    pts(ii).str  = strarr{ii};
end

