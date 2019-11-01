function [A,b,newsrc,newdet]=regoptodes(datafile,atlaspath,srclen,detlen,iter,ishead)
%
% [A,b,newsrc,newdet]=regoptodes(datafile,atlaspath,srclen,detlen,iter,ishead)
%
% optimizing the registration matrix in an EzMapper session by an 
%   optode-to-surface fitting
%


%% loading the atlas mesh

[no,fc]=readoff([atlaspath filesep 'head.off']);

aidx=[3645,1831,394,365,424];  % landmark vertex index
lmp=[-105.4000         0  -25.1600  % landmark coordinates
   11.8500   90.5600  -53.3800
    7.9000  -89.4400  -52.5100
   14.3000         0  108.1000
  100.4000         0  -25.1600];

%% loading ezmapper session data file

ezs=parseezs(datafile);

[src,det]=remapoptodes(ezs);
src=src(:,[1 3 2]);
det=det(:,[1 3 2]);

%% setting default input values

if(nargin<3) srclen=size(src,1); end
if(nargin<4) detlen=size(det,1); end
if(nargin<5) iter=20; end
if(nargin<6) ishead=1; end

if(size(src,1)>srclen)
   warning(sprintf('source data is longer than expected [%d of %d]\n'...
           ,srclen,size(src,1)));
end
if(size(det,1)>detlen)
   warning(sprintf('detector data is longer than expected [%d of %d]\n'...
           ,detlen,size(det,1)));
end

if(size(src,1)<srclen)
   warning(sprintf('source data is shorter than expected [%d of %d]\n'...
           ,srclen,size(src,1)));
   srclen=size(src,1);
end
if(size(det,1)<detlen)
   warning(sprintf('detector data is shorter than expected [%d of %d]\n'...
           ,detlen,size(det,1)));
   detlen=size(det,1);
end


%% perform the point-to-mesh fitting
if(ishead)
    pp=[src(1:srclen,:);det(1:detlen,:);lmp];
else
    pp=[src(end-srclen+1:end,:);det(end-detlen+1:end,:);lmp];
end
pmask=-1*ones(size(pp,1),1);
pmask(end-4:end)=aidx;

optmask=[1 0 0 0 1 0 0 0 1 1 1 1];

[A,b,newpos]=regpt2surf(no,fc,pp,pmask,eye(3),[0 0 0],optmask,iter);
newsrc=newpos(1:srclen,:);
newdet=newpos(srclen+1:srclen+detlen,:);

%% plotting the results

figure;
hc=plotmesh(no,fc,'facealpha',0.5,'linestyle','none','facecolor',[1 1 1]*0.8);
camlight; lighting phong;
hold on
plotmesh(newsrc,'r.');
plotmesh(newdet,'b.');
