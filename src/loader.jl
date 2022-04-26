using ImageFeatures, Images, FileIO, Pkg
img1 = load("C:/Users/amans/Downloads/stata-1.png")
img2 = load("C:/Users/amans/Downloads/stata-2.png")
println([img1 img2])
println(size(img1))