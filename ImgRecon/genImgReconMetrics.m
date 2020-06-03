function imgrecon = genImgReconMetrics(imgrecon, fwmodel, dirname)

Adot = fwmodel.Adot;
if isempty(Adot)
    return;
end

if ndims(Adot == 3);
    Adot = squeeze(Adot(:,:,1)); % took the first wavelength for now
end

lambda_reg = imgrecon.imageParams.Regularization;
sens_thresh = imgrecon.imageParams.Sensitivity_Threshold;
image_thresh = imgrecon.imageParams.Image_Threshold;

hwait = waitbar(0,'Calculating pseudo-Inverse...');

B = double(Adot * Adot');
pAinv = inv(B + lambda_reg*eigs(B,1)*eye(size(B)));

% Calculate localization error and resolution over all vertices with sensitivity
AdotSum = sum(Adot,1);
lstV = find(AdotSum>sens_thresh*max(AdotSum));

resolution = zeros(size(Adot,2),1);  % resolution metric
localizationError = zeros(size(Adot,2),1);     % localization error wrt centroid
%Lm = zeros(size(Adot,2),1);     % localization error wrt peak position

waitbar(0,hwait,'Calculating image metrics...');
numV = length(lstV);
for kk=1:length(lstV)
    waitbar(kk/numV,hwait);
    
    ii = lstV(kk);
    ptsO = [fwmodel.mesh.vertices(ii,1), fwmodel.mesh.vertices(ii,2), fwmodel.mesh.vertices(ii,3)];
    
    % calculate the image for a point absorber at the given vertex
    R = Adot' * pAinv * Adot(:,ii);
    
    % find all vertices in the reconstructed image
    lstR = find(R>image_thresh*max(R));
    
    pts = [fwmodel.mesh.vertices(lstR,1), fwmodel.mesh.vertices(lstR,2), fwmodel.mesh.vertices(lstR,3)];
    ptsC = sum(pts.*(R(lstR)*ones(1,3)),1) / sum(R(lstR));
    resolution(ii) = sum( sum((pts-ones(length(lstR),1)*ptsC).^2,2).^0.5 .* R(lstR),1) / sum(R(lstR));
    
    %    [foo,jj] = max(R);
    %    ptsM = [fwmodel.mesh.vertices(jj,1) fwmodel.mesh.vertices(jj,2),fwmodel.mesh.vertices(jj,3)];
    
    %    Lm(ii) = sum(([fwmodel.mesh.vertices(ii,1) fwmodel.mesh.vertices(ii,2) fwmodel.mesh.vertices(ii,3)] - ...
    %        ptsM).^2).^0.5;
    localizationError(ii) = sum(([fwmodel.mesh.vertices(ii,1) fwmodel.mesh.vertices(ii,2) fwmodel.mesh.vertices(ii,3)] - ...
        ptsC).^2).^0.5;
end
close(hwait);
imgrecon.localizationError = localizationError;
imgrecon.resolution        = resolution;

imgrecon.mesh = fwmodel.mesh;

save([dirname, 'imagerecon/metrics.mat'],'-mat', 'localizationError','resolution');

if AVUtils.ishandles(imgrecon.handles.hResolution)
    delete(imgrecon.handles.hResolution);
    imgrecon.handles.hResolution=[];
end
if AVUtils.ishandles(imgrecon.handles.hLocalizationError)
    delete(imgrecon.handles.hLocalizationError);
    imgrecon.handles.hLocalizationError=[];
end
