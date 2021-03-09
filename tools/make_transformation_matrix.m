function M=make_transformation_matrix(t,r,s,h)
% This function make_transformation_matrix.m creates an affine 
% 2D or 3D transformation matrix from translation, rotation, resize and shear parameters
%
% M=make_transformation_matrix.m(t,r,s,h)
%
% inputs (2D),
%   t: vector [translateX translateY]
%   r: vector [rotate]   (rotation clockwise about the origin)
%   s: vector [resizeX resizeY]
%   h: vector [ShearXY, ShearYX]

% outputs,
%   M: 2D or 3D affine transformation matrix
%
% examples,
%   M=make_transformation_matrix([2 3],[1.0 1.1],2);

% Process inputs
	if(~exist('r','var')||isempty(r)), r=0; end
	if(~exist('s','var')||isempty(s)), s=[1 1]; end
	if(~exist('h','var')||isempty(h)), h=[0 0]; end


% Calculate affine transformation matrix

    M=mat_tra_2d(t)*mat_siz_2d(s)*mat_rot_2d(r)*mat_shear_2d(h); 



function M=mat_rot_2d(r)
	M=[cos(r) sin(r) 0; -sin(r) cos(r) 0; 0 0 1];
   
function M=mat_siz_2d(s)
	M=[s(1) 0 0; 0 s(2) 0; 0 0 1];
function M=mat_shear_2d(h)
	M=[1 h(1) 0; h(2) 1 0; 0 0 1];
	      
function M=mat_tra_2d(t)
	M=[1 0 t(1); 0 1 t(2); 0 0 1];
   
   
   



