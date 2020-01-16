struct ZygoteAD <: ADBackend end
ADBackend(::Val{:zygote}) = ZygoteAD
function setadbackend(::Val{:zygote})
    ADBACKEND[] = :zygote
end

function gradient_logp_reverse(
    backend::ZygoteAD,
    θ::AbstractVector{<:Real},
    vi::VarInfo,
    model::Model,
    sampler::AbstractSampler = SampleFromPrior(),
)

    # Specify objective function.
    function f(θ)
        new_vi = VarInfo(vi, sampler, θ)
        return getlogp(runmodel!(model, new_vi, sampler))
    end

    # Compute forward and reverse passes.
    l, ȳ = Zygote.pullback(f, θ)
    ∂l∂θ = ȳ(1)[1]

    return l, ∂l∂θ
end