using Zygote, ChainRules, ChainRulesCore
using ImageCore
using ImageCore.MappedArrays: of_eltype

export
    fdiff, fdiff!,
    fdiv, fdiv!,
    fgradient, fgradient!,
    flaplacian, flaplacian!


"""
    fdiff(A::AbstractArray; dims::Int, rev=false, boundary=:periodic)
A one-dimension finite difference operator on array `A`. Unlike `Base.diff`, this function doesn't
shrink the array size.
Take vector as an example, it computes `(A[2]-A[1], A[3]-A[2], ..., A[1]-A[end])`.
# Keywords
- `rev::Bool`
  If `rev==true`, then it computes the backward difference
  `(A[end]-A[1], A[1]-A[2], ..., A[end-1]-A[end])`.
- `boundary`
  By default it computes periodically in the boundary, i.e., `:periodic`.
  In some cases, one can fill zero values with `boundary=:zero`.
# Examples
```jldoctest; setup=:(using ImageBase.FiniteDiff: fdiff)
julia> A = [2 4 8; 3 9 27; 4 16 64]
3×3 $(Matrix{Int}):
 2   4   8
 3   9  27
 4  16  64
julia> diff(A, dims=2) # this function exists in Base
3×2 $(Matrix{Int}):
  2   4
  6  18
 12  48
julia> fdiff(A, dims=2)
3×3 $(Matrix{Int}):
  2   4   -6
  6  18  -24
 12  48  -60
julia> fdiff(A, dims=2, rev=true) # reverse diff
3×3 $(Matrix{Int}):
  -6   2   4
 -24   6  18
 -60  12  48
julia> fdiff(A, dims=2, boundary=:zero) # fill boundary with zeros
3×3 $(Matrix{Int}):
  2   4  0
  6  18  0
 12  48  0
```
See also [`fdiff!`](@ref) for the in-place version.
"""
fdiff(A::AbstractArray; kwargs...) = fdiff!(similar(A, maybe_floattype(eltype(A))), A; kwargs...)

"""
    fdiff!(dst::AbstractArray, src::AbstractArray; dims::Int, rev=false, boundary=:periodic)
The in-place version of [`fdiff`](@ref)
"""

@adjoint function 