struct Homography{T} <: CoordinateTransformations.Transformation
    H::SMatrix{3,3,T,9}
end

function Homography()
    return Homography{Float64}(SMatrix{3,3,Float64}([1 0 0; 0 1 0; 0 0 1]))
end

function Homography{T}() where {T}
    sc = UniformScaling{T}(1)
    m = Matrix(sc, 3, 3)
    return Homography{T}(SMatrix{3,3,T,9}(m))
end

function Base.show(io::IO, mime::MIME"text/plain", h::DiffImages.Homography{K}) where {K}
    println(io, "DiffImages.Homography{$K} with:")
    show(io, mime, h.H)
end