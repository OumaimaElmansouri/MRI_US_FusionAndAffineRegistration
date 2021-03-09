 function warpedImage = applyElasticTransformation(image, Tx, Ty)

    % Find update points on moving image
    [x,y] = ndgrid(0:(size(image,1)-1), 0:(size(image,2)-1)); % coordinate image
    x_prime = x+Tx; % updated x values (1st dim, rows)
    y_prime = y+Ty; % updated y values (2nd dim, cols)
    
    % Interpolate updated image
    warpedImage = interpn(x,y,image,x_prime,y_prime,'linear',0); % moving image intensities at updated points
    
    
   