function T = TransformationMatrix(Pf1,Pf2)
% T = TransformationMatrix(Pf1,Pf2)
% Karen Schroeder for Chestek Lab (thanks Karen!) 
% method from Accuracy in Stereotactic and Image Guidance by Hartov & Roberts
 
% We start with N points (MRI)
% Pf1 = [xf1,1 ... xf1,n
%        yf1,1 ... yf1,n
%        zf1,1 ... zf1,n]
% and N homologous points (stereotax)
% Pf2 = [xf2,1 ... xf2,n
%        yf2,1 ... yf2,n
%        zf2,1 ... zf2,n]
 
N = size(Pf1,2);
 
% Compute coordinate means
mf1 = mean(Pf1,2); mf2 = mean(Pf2,2);
 
% estimate scale factor between transformation
%K = mean(sqrt(ones(1,3)*(Pf2-mf2*ones(1,N)).^2)./sqrt(ones(1,3)*(Pf1-mf1*ones(1,N)).^2));
K = 1;
 
% compute Qf1 = Pf1 - (1n x mf1.'), Qf2 = Pf2 - (1n x mf2.')
% 1n is an N by 1 vector of ones
Qf1 = Pf1 -  mf1*ones(1,N);
Qf2 = Pf2 -  mf2*ones(1,N);
 
% H = Qf1 x Qf2.'
H = Qf1 * Qf2.';
 
% Then [U S V] = svd(H)
[U, S, V] = svd(H);

% U*S*V' = H
% (U*V')' = V*U'
 
% rotation matrix R: R = V x U.'
R = V * U.';
 
% Check that det(R) is positive. If not, last column of V should be negated
% and R recomputed
 
detR = det(R);
if detR < 0
    
    if detR < 0 && S(3,3) > 0.001
        waitfor(errordlg('Warning: detR1 < 0 and SVD all > 0. Large errors likely.'));
    end
    
    V(:,3) = -1 .* V(:,3);
    R = V * U.';
end
 
% translation vector
% t = mf2 - R x mf1
t = mf2 - K*R * mf1;
 
%transformation matrix
%     [  R(3x3)   t(3x1)
% T = 
%      0    0    0    1]
 
% apply scale factor to rotation matrix
T = [K*R t; 0 0 0 1];
