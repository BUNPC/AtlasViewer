function v = genInterpSurface(fv)

v0 = fv.vertices;
f0 = fv.faces;

h = waitbar(0,sprintf('Finding new vertices ...'));
v = zeros(4*length(f0),3);
kk=1;
for ii=1:length(f0)
    p1 = v0(f0(ii,1),:);
    p2 = v0(f0(ii,2),:);
    p3 = v0(f0(ii,3),:);
    mp1 = [p1(1)+(p2(1)-p1(1))/2,  p1(2)+(p2(2)-p1(2))/2, p1(3)+(p2(3)-p1(3))/2];
    mp2 = [p1(1)+(p3(1)-p1(1))/2,  p1(2)+(p3(2)-p1(2))/2, p1(3)+(p3(3)-p1(3))/2];
    mp3 = [p2(1)+(p3(1)-p2(1))/2,  p2(2)+(p3(2)-p2(2))/2, p2(3)+(p3(3)-p1(3))/2];
    
    r = rand(4,1);
    
    v(kk,  :) = p1+(mp3-p1)*r(1);
    v(kk+1,:) = p3+(mp1-p3)*r(2);
    v(kk+2,:) = p2+(mp2-p2)*r(3);
    v(kk+3,:) = v0(f0(ii,floor(3*r(4))+1),:);
      
    kk=kk+4;

    if mod(ii,1000)==0
        waitbar(ii/length(f0), h);
    end
end

% v = [v0; v];
close(h)