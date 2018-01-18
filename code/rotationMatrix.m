function m = rotationMatrix(rad)
%rotationMatrix generates a 2x2 rotation matrix
%
%input:
%rad ... angle in radians
    m = [cos(rad) -sin(rad); sin(rad) cos(rad)]; 
end