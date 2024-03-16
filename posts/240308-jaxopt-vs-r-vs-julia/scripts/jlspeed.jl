using Random, GLM, StatsBase, ArgParse
import Base.Threads.@threads

function parse_cmdline()
    parser = ArgParseSettings()

    @add_arg_table parser begin
        "nreps"
          help = "number of repetitions"
          required = false
          arg_type = Int
          default = 10
    end

    return parse_args(parser)
end

function make_data(n::Integer=1000)
    X_full = randn(n,10)
    eta = vec(sum(X_full, dims=2))
    y = eta .> 0 # vectorized greater than 0 comparison
    X = X_full[:,1:9]
    return X, y
end

function solve(i::Int64=1)
    X, y = make_data()
    fit = glm(X, y, Bernoulli())
    coefs = coef(fit)
    return coefs
end

function main()
    args = parse_cmdline()
    nreps = get(args, "nreps", 10)

    Random.seed!(240316)
    outmat = zeros(nreps, 9)

    @threads for i in 1:nreps # use @threads for multi-threading
        solution = solve()
        outmat[i,:] = solve()
    end

    means = mean(outmat, dims=1)
    print(means)
end

main()
