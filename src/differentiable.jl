using Zygote, ChainRules, ChainRulesCore
using ImageCore
using ImageCore.MappedArrays: of_eltype

fdiff(A::AbstractArray; kwargs...) = fdiff!(similar(A, maybe_floattype(eltype(A))), A; kwargs...)

@adjoint function 