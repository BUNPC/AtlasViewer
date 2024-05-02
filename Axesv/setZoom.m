function setZoom(haxes, d1)
cp0 = get(haxes, 'cameraposition');
ct0 = get(haxes, 'cameratarget');
va = cp0-ct0;
d0 = dist3(cp0, ct0);
k = d1/d0; 
cp_new = ct0 + (va * k);
v_up = get(haxes, 'cameraupvector');
if angleBetweenVectors(abs(va), abs(v_up))==0
    v_up = [va(2), va(1), va(3)];
end
set(haxes, 'cameraupvector',v_up);
set(haxes, 'cameraposition',cp_new);

