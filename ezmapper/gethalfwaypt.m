function [pt,bcutpos,bcutpos2]=gethalfwaypt(no,fc,lmp)

plane=lmp(2:4,:);
[bcutpos,bcutvalue,bcutedges]=qmeshcut(fc(:,1:3),no,no(:,1),plane);
[bcutpos,bcutedges]=removedupnodes(bcutpos,bcutedges);
bcutloop=extractloops(bcutedges);
bcutloop(isnan(bcutloop))=[];
bcutloop(end+1)=bcutloop(1);

plane=lmp([1 4 5],:);
[bcutpos2,bcutvalue2,bcutedges2]=qmeshcut(fc(:,1:3),no,no(:,1),plane);
[bcutpos2,bcutedges2]=removedupnodes(bcutpos2,bcutedges2);
bcutloop2=extractloops(bcutedges2);
bcutloop2(isnan(bcutloop2))=[];
bcutloop2(end+1)=bcutloop2(1);

bcutpos=bcutpos(bcutloop,:);
bcutpos2=bcutpos2(bcutloop2,:);

idx1=nearestptcurve(lmp(1,:),bcutpos2);
idx2=nearestptcurve(lmp(2,:),bcutpos);
idx3=nearestptcurve(lmp(3,:),bcutpos);
idx4=nearestptcurve(lmp(4,:),bcutpos);
idx4n=nearestptcurve(lmp(4,:),bcutpos2);
idx5=nearestptcurve(lmp(5,:),bcutpos2);


len1=bcutpos(1:end-1,:)-bcutpos(2:end,:);
len1=sqrt(sum((len1.*len1)'));

len2=bcutpos2(1:end-1,:)-bcutpos2(2:end,:);
len2=sqrt(sum((len2.*len2)'));


%[p,dlen]=findhalfway(2,4,[0.5 1.5 2*sqrt(2) 2],[0 0 0;0 0 0.5;0 0 2;0 2 0;0 0 0]);

[p,dlen]=findhalfway(idx2,idx4,len1,bcutpos);
pt.t1=p;
[p,dlen]=findhalfway(idx3,idx4,len1,bcutpos);
pt.t2=p;
[p,dlen]=findhalfway(idx1,idx4n,len2,bcutpos2);
pt.t3=p;
[p,dlen]=findhalfway(idx5,idx4n,len2,bcutpos2);
pt.t4=p;

%%
function idx=nearestptcurve(pt,curvept)
dist=curvept-repmat(pt(:)',size(curvept,1),1);
dist=sqrt(sum((dist.*dist)'));
[yy,idx]=min(dist);


%%
function [pt,dlen]=findhalfway(idx1,idx2,len,node)
i1=min(idx1,idx2);
i2=max(idx1,idx2);

len1=sum(len(i1:i2-1));
len2=sum(len(1:i1-1))+sum(len(i2:end));

if(len1<len2)
    ss=[0 cumsum(len(i1:i2))];
    pos=interp1(ss, i1:i2+1, len1/2);
    dlen=len1;
else
    len=[len,len(1:i1)];
    node=[node;node(2:i1+1,:)];
    ss=[0 cumsum(len(i2:i2+i1))];
    pos=interp1(ss, i2:i2+i1+1, len2/2);
    dlen=len2;
end
pt=node(floor(pos),:)+(pos-floor(pos))*(node(floor(pos)+1,:)-node(floor(pos),:));
