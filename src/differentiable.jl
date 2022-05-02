using Zygote, ChainRules, ChainRulesCore
using ImageCore
using ImageCore.MappedArrays: of_eltype

export
    fdiff, fdiff!

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

function fdiff!(dst::AbstractArray, src::AbstractArray;
        dims=_fdiff_default_dims(src),
        rev=false,
        boundary::Symbol=:periodic)
    isnothing(dims) && throw(UndefKeywordError(:dims))
    axes(dst) == axes(src) || throw(ArgumentError("axes of all input arrays should be equal. Instead they are $(axes(dst)) and $(axes(src))."))
    N = ndims(src)
    1 <= dims <= N || throw(ArgumentError("dimension $dims out of range (1:$N)"))

    src = of_eltype(maybe_floattype(eltype(dst)), src)
    r = axes(src)
    r0 = ntuple(i -> i == dims ? UnitRange(first(r[i]), last(r[i]) - 1) : UnitRange(r[i]), N)
    r1 = ntuple(i -> i == dims ? UnitRange(first(r[i])+1, last(r[i])) : UnitRange(r[i]), N)

    d0 = ntuple(i -> i == dims ? UnitRange(last(r[i]), last(r[i])) : UnitRange(r[i]), N)
    d1 = ntuple(i -> i == dims ? UnitRange(first(r[i]), first(r[i])) : UnitRange(r[i]), N)

    if rev
        dst[r1...] .= view(src, r1...) .- view(src, r0...)
        if boundary == :periodic
            dst[d1...] .= view(src, d1...) .- view(src, d0...)
        elseif boundary == :zero
            dst[d1...] .= zero(eltype(dst))
        else
            throw(ArgumentError("Wrong boundary condition $boundary"))
        end
    else
        dst[r0...] .= view(src, r1...) .- view(src, r0...)
        if boundary == :periodic
            dst[d0...] .= view(src, d1...) .- view(src, d0...)
        elseif boundary == :zero
            dst[d0...] .= zero(eltype(dst))
        else
            throw(ArgumentError("Wrong boundary condition $boundary"))
        end
    end

    return dst
end

@adjoint function fdiff(A::AbstractArray{T,N}; kwargs...) where {T,N}
    e = eltype(A)
    y = fdiff!(similar(A, maybe_floattype(eltype(A))), A; kwargs...)
    final = similar(A,Tuple{eltype(A),eltype(A)})
    function pullback(Δ)
        for i in range(1,size(final)[1]), j in range(1,size(final)[2])
            final[i,j] = (Δ,-Δ)
        end
    return final
    end
    return (y,pullback)
end