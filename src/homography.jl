struct Homography{T} <: CoordinateTransformations.Transformation
    H::SMatrix{3,3,T,9}
end