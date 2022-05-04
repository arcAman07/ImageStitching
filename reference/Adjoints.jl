using Pkg

Pkg.add("ImageBase")

using ImageBase

A = [2 4 8; 3 9 27; 4 16 64]

fdiff(A,dims=1)

fdiff(A,dims=2)

fdiff(A,dims=3)

using Zygote

using Zygote: @adjoint

mul(a, b) = a*b;

@adjoint mul(a, b) = mul(a, b), c̄ -> (c̄*b, c̄*a)

mul(2,3)

gradient(mul, 2, 3)

using Zygote, ChainRules, ChainRulesCore
using ImageCore
using ImageCore.MappedArrays: of_eltype

# ImageBase.fdiff(A::AbstractArray; kwargs...) = fdiff!(similar(A, maybe_floattype(eltype(A))), A; kwargs...)

# function fdiff!(dst::AbstractArray, src::AbstractArray;
#         dims=_fdiff_default_dims(src),
#         rev=false,
#         boundary::Symbol=:periodic)
#     isnothing(dims) && throw(UndefKeywordError(:dims))
#     axes(dst) == axes(src) || throw(ArgumentError("axes of all input arrays should be equal. Instead they are $(axes(dst)) and $(axes(src))."))
#     N = ndims(src)
#     1 <= dims <= N || throw(ArgumentError("dimension $dims out of range (1:$N)"))

#     src = of_eltype(maybe_floattype(eltype(dst)), src)
#     r = axes(src)
#     r0 = ntuple(i -> i == dims ? UnitRange(first(r[i]), last(r[i]) - 1) : UnitRange(r[i]), N)
#     r1 = ntuple(i -> i == dims ? UnitRange(first(r[i])+1, last(r[i])) : UnitRange(r[i]), N)

#     d0 = ntuple(i -> i == dims ? UnitRange(last(r[i]), last(r[i])) : UnitRange(r[i]), N)
#     d1 = ntuple(i -> i == dims ? UnitRange(first(r[i]), first(r[i])) : UnitRange(r[i]), N)

#     if rev
#         dst[r1...] .= view(src, r1...) .- view(src, r0...)
#         if boundary == :periodic
#             dst[d1...] .= view(src, d1...) .- view(src, d0...)
#         elseif boundary == :zero
#             dst[d1...] .= zero(eltype(dst))
#         else
#             throw(ArgumentError("Wrong boundary condition $boundary"))
#         end
#     else
#         dst[r0...] .= view(src, r1...) .- view(src, r0...)
#         if boundary == :periodic
#             dst[d0...] .= view(src, d1...) .- view(src, d0...)
#         elseif boundary == :zero
#             dst[d0...] .= zero(eltype(dst))
#         else
#             throw(ArgumentError("Wrong boundary condition $boundary"))
#         end
#     end

#     return dst
# end

B=2

# @adjoint ImageBase.fdiff(A::AbstractArray; kwargs...) = fdiff!(similar(A, maybe_floattype(eltype(A))), A; kwargs...)

function add(a,b)
    return a+b
end

function subtract(a,b)
    return a-b
end

subtract(2,1)

add(1,2)

gradient(add,1,2)

gradient(subtract,2,1)

y, back =  Zygote.pullback(add,1,2)

z, back1 = Zygote.pullback(subtract,2,1)

back

N=2
dims=2

r = axes(A)

r[1]

r0 = ntuple(i -> i == dims ? UnitRange(first(r[i]), last(r[i]) - 1) : UnitRange(r[i]), N)

r1 = ntuple(i -> i == dims ? UnitRange(first(r[i])+1, last(r[i])) : UnitRange(r[i]), N)

d0 = ntuple(i -> i == dims ? UnitRange(last(r[i]), last(r[i])) : UnitRange(r[i]), N)

d1 = ntuple(i -> i == dims ? UnitRange(first(r[i]), first(r[i])) : UnitRange(r[i]),N)

dst::AbstractArray{T,N}

B = [2 4 8 1; 3 9 27 2; 4 16 64 3]

c= similar(B, eltype(B))

d= similar(A,Tuple{eltype(A),eltype(A)})

size(d)[1]

function pull(Δ)
for i in range(1,size(d)[1]), j in range(1,size(d)[2])
        d[i,j] = (Δ,-Δ)
end
end

final = similar(B,Tuple{})

# fill!(final,(c̄,-c̄))

size(A)[2]

@adjoint function fdiff(A::AbstractArray{T,N}; kwargs...) where {T,N}
    e = eltype(A)
    y = fdiff!(similar(A, maybe_floattype(eltype(A))), A; kwargs...)
    final = similar(A,Tuple{eltype(A),eltype(A)})
    function pullback(Δ)
        fill!(final,(Δ,-Δ))
    return (final,)
    end
    return (y,pullback)
end

fdiff(A,dims=1)

using Images, TestImages
img = Gray.(testimage("house"))

img1 = RGB.(img)

corners = imcorner(img)
img_copy = RGB.(img)
img_copy[corners] .= RGB(1.0, 0.0, 0.0)
img_copy

corners = imcorner(img, Percentile(98.5))
img_copy2 = RGB.(img)
img_copy2[corners] .= RGB(1.0, 0.0, 0.0)
img_copy2

A

minimum_finite(A)

maximum_finite(A)

sumfinite(A)

ImageBase.meanfinite(A)

varfinite(A)

sumfinite(identity, A)

@adjoint function fdiff(A::AbstractArray{T,N}; kwargs...) where {T,N}
    y = fdiff!(similar(A, maybe_floattype(eltype(A))), A; kwargs...)
    final = similar(A,Tuple{eltype(A),eltype(A)})
    function pullback(Δ)
        fill!(final,(Δ,-Δ))
    return (final,)
    end
    return (y,pullback)
end

meanfinite(A; kwargs...) = meanfinite(identity, A; kwargs...)

if Base.VERSION >= v"1.1"
    function meanfinite(f, A; kwargs...)
        s = ImageBase.sumfinite(f, A; kwargs...)
        n = sum(IfElse(isfinite, x->true, x->false), A; kwargs...)   # TODO: replace with `Returns`
        return s./n
    end
else
    function meanfinite(f, A; kwargs...)
        s = ImageBase.sumfinite(f, A; kwargs...)
        n = sum(IfElse(isfinite, x->true, x->false).(A); kwargs...)
        return s./n
    end
end

@adjoint function sumfinite(A::AbstractArray{T,N}; kwargs...) where {T,N}
    y = ImageBase.sumfinite(identity, A; kwargs...)
    final = similar(A,eltype(A))
    function pullback(Δ)
        fill!(final,Δ)
        return (final,)
    end
    return (y,pullback)
end

@adjoint function meanfinite(A::AbstractArray{T,N}; kwargs...) where {T,N}
    y = ImageBase.sumfinite(identity, A; kwargs...)
    final = similar(A,eltype(A))
    function pullback(Δ)
        fill!(final,Δ/length(A))
        return (final,)
    end
    return (y,pullback)
end

length(A)

b = gradient(ImageBase.meanfinite,A)

c = gradient(ImageBase.varfinite, A)

C = [2 4 8 1; 3 9 64 2; 4 16 64 1]

y = similar(A,eltype(A))

fill!(y,1.0)

b = Tuple(y)

typeof(b)

A

C

maximum_finite(C)

findall(C .== 64)

indexArray = first(findall( x -> x == 64, C ))

A[indexArray] = 1

A

first(indexArray)

last(indexArray)

prod(A)

findall(C .== 1)

zeros(eltype(A),size(A))

@adjoint function meanfinite(A::AbstractArray{T,N}; kwargs...) where {T,N}
    y = ImageBase.sumfinite(identity, A; kwargs...)
    final = similar(A,eltype(A))
    function pullback(Δ)
        fill!(final,Δ/length(A))
        return (final,)
    end
    return (y,pullback)
end

@adjoint function maximum_finite(A::AbstractArray{T,N}; kwargs...) where {T,N}
    y = ImageBase.maximum_finite(identity, A; kwargs...)
    final = zeros(eltype(A),size(A))
    function pullback(Δ)
        index = last(findall( x -> x == y, A ))
        final[index] = Δ
        return (final,)
    end
    return (y,pullback)
end

@adjoint function minimum_finite(A::AbstractArray{T,N}; kwargs...) where {T,N}
    y = minimum_finite(identity, A; kwargs...)
    final = zeros(eltype(A),size(A))
    function pullback(Δ)
        index = first(findall( x -> x == y, A ))
        final[index] = Δ
        return (final,)
    end
    return (y,pullback)
end

gradient(minimum_finite, C)

e = gradient(maximum_finite, C)

C

e


