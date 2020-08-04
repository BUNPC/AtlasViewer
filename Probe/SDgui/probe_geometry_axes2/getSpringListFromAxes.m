function sl=getSpringListFromAxes(optpos, h_edges)

sl=zeros(length(h_edges),3);
for i=1:length(h_edges)
    x=get(h_edges(i),'xdata');
    y=get(h_edges(i),'ydata');
    z=get(h_edges(i),'zdata');
    p1=[x(1) y(1) z(1)];
    p2=[x(2) y(2) z(2)];
    [foo j]=nearest_point(optpos,p1);
    sl(i,1)=j;
    [foo k]=nearest_point(optpos,p2);
    sl(i,2)=k;
end
