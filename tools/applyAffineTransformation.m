function Ireg = applyAffineTransformation(image, T)

% Make center of the image transformation coordinates 0,0
[x,y]=ndgrid(0:(size(image,1)-1),0:(size(image,2)-1));
xd=x-(size(image,1)/2); yd=y-(size(image,2)/2);

% Calculate the backwards transformation fields
Tx = ((size(image,1)/2) + T(1,1) * xd + T(1,2) *yd + T(1,3) * 1)-x;
Ty = ((size(image,2)/2) + T(2,1) * xd + T(2,2) *yd + T(2,3) * 1)-y;


% Transform the input image
Ireg= applyElasticTransformation(image, Tx, Ty);
