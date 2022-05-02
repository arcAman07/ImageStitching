# Writing the adjoint for the fdiff function to make it differentiable( AD )

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