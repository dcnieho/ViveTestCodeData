% based on http://nghiaho.com/?page_id=671

function [R,t,qReflectionDetected] = rigid_transform_3D(A, B)
    if nargin ~= 2
	    error('Missing parameters');
    end

    assert(all(size(A) == size(B)))

    centroid_A = mean(A);
    centroid_B = mean(B);

    H = bsxfun(@minus,A,centroid_A)' * bsxfun(@minus,B,centroid_B);
    if 0
        % H is an unscaled covariance matrix (no need to scale for the SVD
        % below). H/N where N is the number of observations, is equal to:
        idx = nchoosek(1:6,2);
        idx(:,2) = idx(:,2)-3;
        idx(idx(:,1)>3|idx(:,2)<1,:) = [];
        m=zeros(3);
        for p=1:size(idx,1)
            t = cov(A(:,idx(p,1))-centroid_A(idx(p,1)),B(:,idx(p,2))-centroid_B(idx(p,2)));
            m(idx(p,1),idx(p,2)) = t(2,1);
        end
        H(:)./m(:)-size(A,1)+1  % should be tiny (or infinite, if cov is zero)
    end

    [U,S,V] = svd(H);

    R = V*U';

    qReflectionDetected = false;
    if det(R) < 0
        fprintf('Reflection detected\n');
        qReflectionDetected = true;
        V(:,3) = -V(:,3);
        R = V*U';
    end

    t = -R*centroid_A' + centroid_B';
end
