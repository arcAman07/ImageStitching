function draw_points(image, mask; c::Colorant=colorant"yellow")
    new_image = copy(image);
    new_image[mask] .= c;
    return new_image;
end

function draw_points(image::AbstractArray, mask::Keypoints; c::Colorant=colorant"yellow")
    new_image = copy(image)
    new_image[mask] .= c
    return new_image
end

function get_descriptors(img::AbstractArray)
    brisk_params = BRISK()
    features = Features(Keypoints(imcorner(img, method=harris)))
    desc, ret_features = create_descriptor(Gray.(img), features, brisk_params)
end

function match_points(img1::AbstractArray, img2::AbstractArray, threshold::Float64=0.1)
    desc_1, ret_features_1 = get_descriptors(img1)
    desc_2, ret_features_2 = get_descriptors(img2)
    matches = match_keypoints(Keypoints(ret_features_1), Keypoints(ret_features_2), desc_1, desc_2, threshold)
    return matches
end

function draw_matches(img1, img2, matches)
    grid = [img1 img2]
    offset = CartesianIndex(0, size(img1, 2))
    for m in matches
        #         line!(grid, m[1], m[2] + offset)
        draw!(grid, LineTwoPoints(m[1], m[2] + offset), RGB{N0f8}(1, 1, 1))
    end
    grid
end