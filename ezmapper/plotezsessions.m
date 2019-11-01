function plotezsessions(fstub,sessionid,type)

len=length(sessionid);
styles={'.','r.','g+','k+','c*','y*'};
oldsrclen=0;

if (nargin<3)
    type='src';
end
for i=1:len
    fname=sprintf('%s%d',fstub,sessionid(i));
    if(~exist(fname,'file'))
        warning(sprintf('file %s does not exist, skip',fname));
        continue;
    end
    ezs=parseezs(fname);
    [src,det]=remapoptodes(ezs);
    src=src(:,[1 3 2]);
    det=det(:,[1 3 2]);
    if(isempty(src) | isempty(det))
        continue; 
    end
    if(mod(i,2)==0 & oldsrclen>0 & oldsrclen*2==size(src,1))
        src=src(size(src,1)/2+1:end,:);
        det=det(size(det,1)/2+1:end,:);
        ezs.SrcPos=ezs.SrcPos(size(ezs.SrcPos,1)/2+1:end,:);
        ezs.DetPos=ezs.DetPos(size(ezs.DetPos,1)/2+1:end,:);
    end
    oldsrclen=size(src,1);
    if(strcmp(type,'det'))
        figure(1);hold on;view(3);axis equal;
        plot3(det(:,1),det(:,2),det(:,3),styles{i});
        figure(2);hold on;view(3);axis equal;
        plot3(ezs.DetPos(:,1),ezs.DetPos(:,2),ezs.DetPos(:,3),styles{i});
    else
        figure(1);hold on;view(3);axis equal;
        plot3(src(:,1),src(:,2),src(:,3),styles{i});
        figure(2);hold on;view(3);axis equal;
        plot3(ezs.SrcPos(:,1),ezs.SrcPos(:,2),ezs.SrcPos(:,3),styles{i});
    end
end
if(strcmp(type,'det'))
    figure(1);
    title('registered detector positions');
    figure(2);
    title('detector position raw data');
else
    figure(1);
    title('registered source positions');
    figure(2);
    title('source position raw data');
end
