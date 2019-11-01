function v = applyCoordTranspose(axes_order, v0)

v=[];

if axes_order(1)>0
    v(:,1) = v0(:,abs(axes_order(1))); 
else
    v(:,1) = -v0(:,abs(axes_order(1))); 
end
if axes_order(2)>0
    v(:,2) = v0(:,abs(axes_order(2))); 
else
    v(:,2) = -v0(:,abs(axes_order(2))); 
end
if axes_order(3)>0
    v(:,3) = v0(:,abs(axes_order(3))); 
else
    v(:,3) = -v0(:,abs(axes_order(3))); 
end
