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

# Writing the adjoint for the sumfinite function to make it differentiable( AD )

@adjoint function sumfinite(A::AbstractArray{T,N}; kwargs...) where {T,N}
    y = ImageBase.sumfinite(identity, A; kwargs...)
    final = similar(A, eltype(A))
    function pullback(Δ)
        fill!(final, Δ)
        return (final,)
    end
    return (y, pullback)
end

# Writing the adjoint for the meanfinite function to make it differentiable( AD )

@adjoint function meanfinite(A::AbstractArray{T,N}; kwargs...) where {T,N}
    y = ImageBase.meanfinite(identity, A; kwargs...)
    final = similar(A, eltype(A))
    function pullback(Δ)
        fill!(final, Δ / length(A))
        return (final,)
    end
    return (y, pullback)
end

# Writing the adjoint for the maximum_finite function to make it differentiable( AD )

@adjoint function maximum_finite(A::AbstractArray{T,N}; kwargs...) where {T,N}
    y = ImageBase.maximum_finite(identity, A; kwargs...)
    final = zeros(eltype(A), size(A))
    function pullback(Δ)
        index = last(findall(x -> x == y, A))
        final[index] = Δ
        return (final,)
    end
    return (y, pullback)
end

#Writing the adjoint for the minimum_finite function to make it differentiable( AD )

@adjoint function minimum_finite(A::AbstractArray{T,N}; kwargs...) where {T,N}
    y = ImageBase.minimum_finite(identity, A; kwargs...)
    final = zeros(eltype(A), size(A))
    function pullback(Δ)
        index = first(findall(x -> x == y, A))
        final[index] = Δ
        return (final,)
    end
    return (y, pullback)
end
