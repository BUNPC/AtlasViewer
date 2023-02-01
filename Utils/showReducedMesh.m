function [nodeX, nNode, mesh] = showReducedMesh(mesh_orig, mesh_reduced)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if number of elements is too large. If greater than 40,000 then
% need to reduce
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fv = mesh_orig;
fvn = mesh_reduced;

mesh = fvn;

q = MenuBox( sprintf('The original pial surface has %d faces. It is recommended that this be less than 40,000 for best performance.\nShall I reduce this?',size(fv.faces,1)),{'Yes','No'});
if q==1
    hf = figure;
    
    % Plot the original
    subplot(1,2,1)
    h=trisurf( fv.faces, fv.vertices(:,1), fv.vertices(:,2), fv.vertices(:,3) );
    title( sprintf(' Original with %d faces', size(fv.faces,1)) )
    set(h,'linestyle','none')    
    light
    
    % Plot the reduced
    subplot(1,2,2)
    h=trisurf( fvn.faces, fvn.vertices(:,1), fvn.vertices(:,2), fvn.vertices(:,3) );
    title( sprintf(' New with %d faces', size(fvn.faces,1)) )
    set(h,'linestyle','none')
    light
    
    q = MenuBox('Accept this?',{'Yes','No'});
    if q==2
        q = MenuBox('Proceed with the original mesh? This could take a long time.',{'Yes','No'});
        if q==1
            mesh = fv;
        end
    end
    
    close(hf);
end

nodeX = mesh.vertices;
elem  = mesh.faces; 
nNode = size(nodeX,1);


