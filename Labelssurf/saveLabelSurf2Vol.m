function saveLabelSurf2Vol(headvol)
% Author:Sreekanth Kura (skura@bu.edu)

% I am assuming imported anatomy will be saved in RAS orientation. 
S = size(headvol.img);
T = headvol.T_2ras;
Tras_2vol = T;
for u = 1:3
    if sum(Tras_2vol(u,1:3)) == -1
        Tras_2vol(u,4) = S(u);
    else
        Tras_2vol(u,4) = 0;
    end
end

Tras_mni = (Tras_2vol'*T')';
Tmni_ras = inv(Tras_mni);
dirname = [headvol.pathname, '/anatomical/'];
filename = [dirname 'labelssurf2vol.txt'];
writematrix(Tmni_ras,filename,'Delimiter',' ')