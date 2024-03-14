# using CategoricalArrays, DataFrames, GLM, StableRNGs, StatsBase
using CategoricalArrays, DataFrames, GLM, Random, StatsBase
using Base.Threads
import Base.Threads.@threads
# using ThreadsX

nreps = 100000
Random.seed!(123)

function make_data(n::Integer=1000)
    X = randn(n,10)
    eta = vec(sum(X, dims=2))
    y = eta .> 0
    X2 = X[:,1:9]
    return X2, y
end

function solve(i::Int64=1)
    X, y = make_data()
    fit = glm(X, y, Bernoulli())
    coefs = coef(fit)
    return coefs
end

outmat = zeros(nreps, 9)

iis = 1:nreps

# outvec = Threads.Atomic{Float64}(nreps*9)
# coefs = [Threads.Atomic{Float64}(0.0) for i in 1:9]
# outmat = Array{Float64,2}(undef, nreps, 9)
@threads for i in iis
    solution = solve()
    # for j in 1:9
        # Threads.atomic_add!(coefs[j], solution[j])
    # end

    outmat[i,:] = solve()
end

means = mean(outmat, dims=1)
print(means)

