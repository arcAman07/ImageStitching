
# Writing the adjoint for the fdiff function to make it differentiable( AD )

@adjoint function fdiff(A::AbstractArray{T,N}; kwargs...) where {T,N}
    e = eltype(A)
    y = fdiff!(similar(A, maybe_floattype(eltype(A))), A; kwargs...)
    final = similar(A, Tuple{eltype(A),eltype(A)})
    function pullback(Δ)
        fill!(final, (Δ, -Δ))
        return (final,)
    end
    return (y, pullback)
end