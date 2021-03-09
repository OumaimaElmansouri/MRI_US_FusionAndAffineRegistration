

function g=make_gaussian_filter(sz,sigma)

szh = (sz(2)-1)/2;
szw = (sz(1)-1)/2;

x = -szh:szh;
y = -szw:szw;

[X,Y] = meshgrid(x,y);
g=exp(-(X.^2 + Y.^2)/(2*sigma^2));

g=g/sum(g(:));

   clear szh szw x y X Y
