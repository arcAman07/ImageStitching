module ImageStitching

using ImageCore,
    Zygote,
    ImageTransformations,
    StaticArrays,
    CoordinateTransformations,
    Interpolations,
    ChainRulesCore,
    LinearAlgebra,
    Rotations

using Zygote: @adjoint
using ChainRulesCore: NoTangent

using Reexport
using Base.Cartesian: @nloops
@reexport using ImageCore
using ImageCore.OffsetArrays

include("homography.jl")
include("loader.jl")
include("ransac.jl")
include("merge.jl")
include("utilities.jl")

end

