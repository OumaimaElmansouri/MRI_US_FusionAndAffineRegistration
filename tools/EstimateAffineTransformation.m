function M= EstimateAffineTransformation(Imoving,Istatic, type_affine)


% Convert the inputs to double
Imoving=im2double(Imoving);
Istatic=im2double(Istatic);

% Resize the moving image to fit the static image
if(sum(size(Istatic)-size(Imoving))~=0)
    Imoving = imresize(Imoving,size(Istatic),'bicubic');
end

% Make smooth images for histogram and fast affine registration
ISmoving=imgaussian(Imoving,2.5,[10 10]);
ISstatic=imgaussian(Istatic,2.5,[10 10]);



disp('Start Affine registration'); drawnow; 
    % Parameter scaling of the Translation, Rotation, Resize and Shear
    scale=[1 1 1 0.01 0.01 1e-4 1e-4];
    % Set initial affine parameters
    x=[0 0 0 100 100 0 0];


for refine_itt=1:2
    if(refine_itt==2)
        ISmoving=Imoving; ISstatic=Istatic;
    end
	% Use struct because expanded optimset is part of the Optimization Toolbox.
    optim=struct('GradObj','off','GoalsExactAchieve',1,'Display','iter','MaxIter',100,'MaxFunEvals',1000,'TolFun',1e-14,'DiffMinChange',1e-6);   
	x=fminlbfgs(@(x)affine_registration_error(x,scale,ISmoving,ISstatic,type_affine),x,optim);            
end

% Scale the translation, resize and rotation parameters to the real values
x=x.*scale;


    % Make the affine transformation matrix
M=make_transformation_matrix(x(1:2),x(3),x(4:5));    

 
 
 
 