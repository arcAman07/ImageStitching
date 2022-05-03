using ImageBase
# Writing the adjoint for the fdiff function to make it differentiable( AD )

@adjoint function fdiff(A::AbstractArray{T,N}; kwargs...) where {T,N}
    y = ImageBase.fdiff!(similar(A, maybe_floattype(eltype(A))), A; kwargs...)
    final = similar(A, Tuple{eltype(A),eltype(A)})
    function pullback(Δ)
        fill!(final, (Δ, -Δ))
        return (final,)
    end
    return (y, pullback)
end

@adjoint function sumfinite(A::AbstractArray{T,N}; kwargs...) where {T,N}
    y = ImageBase.sumfinite(identity, A; kwargs...)
    final = similar(A, eltype(A))
    function pullback(Δ)
        fill!(final, Δ)
        return (final,)
    end
    return (y, pullback)
end

@adjoint function meanfinite(A::AbstractArray{T,N}; kwargs...) where {T,N}
    y = ImageBase.meanfinite(identity, A; kwargs...)
    final = similar(A, eltype(A))
    function pullback(Δ)
        fill!(final, Δ / length(A))
        return (final,)
    end
    return (y, pullback)
end

