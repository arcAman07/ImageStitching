function apply_ransac(matches, n_iters=20, eps=20)
    best_homography_inliers = []
    best_num_inliers = 0
    
    # for N times, use 8 points to estimate the homography
    for i in 1:n_iters
        # randomly pick 4 points from matches
        matches_sub = rand(matches, 4)

        # calculate the homography
        H_sub = compute_homography(matches_sub)

        # calculate the number of inliers.
        # apply the homography to all the points
        # in the first image. calculate descriptors.
        img1_points = [m[1] for m in matches]
        img2_points = [m[2] for m in matches]
        out = H_sub(img1_points)
        dists = [sqrt(x.I[1]^2 + x.I[2]^2) for x in (out - img2_points)]

        # if diff < epsilon, its an inliner
        inliner_indices = dists .< eps
        num_inliers = sum(inliner_indices)
        
        # if this is the best we got so far, store it
        # and all the inliers
        if num_inliers > best_num_inliers
            best_homography_inliers = matches[inliner_indices]
            best_num_inliers = num_inliers
        end
    end
    
    # calculate the new homography with all the inliers
    H = compute_homography(best_homography_inliers)
end