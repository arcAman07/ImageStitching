function merge_images(img1, new_img)
    axis1_size =
        max(axes(new_img)[1].val.stop, size(img1, 1)) -
        min(axes(new_img)[1].val.start, 1) + 1
    axis2_size =
        max(axes(new_img)[2].val.stop, size(img1, 2)) -
        min(axes(new_img)[2].val.start, 1) + 1
    
    # our new image is an offset array
    combined_image = OffsetArray(
        zeros(RGB{N0f8}, axis1_size, axis2_size), (
            min(0, axes(new_img)[1].val.start),
            min(0, axes(new_img)[2].val.start)))
    
    # we just put the image directly into the new combined canvas
    combined_image[1:size(img1, 1), 1:size(img1, 2)] = img1
    
    # merge all the pixels into the new image that are not black
    for i in indices(new_img, 1)
        for j in indices(new_img, 2)
            if new_img[i, j] != colorant"black"
                combined_image[i, j] = new_img[i, j]
            end
        end
    end
    combined_image
end