import jax, jaxopt
jax.config.update('jax_platform_name', 'cpu') # make sure jax doesnt use a gpu if it's available
from jax import numpy as jnp, random, vmap, jit, lax
from jaxopt import LBFGS
from jaxopt.objective import binary_logreg
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument('nreps', nargs="?", type=int, default=int(10))
parser.add_argument('primitive', nargs="?", type=str, default="vmap")
parser.add_argument('nscan', nargs="?", type=int, default=int(0))

def make_data(k, n=int(1e3)):
    X_full = random.normal(k, (n,10)) # JAX needs explicit keys for psuedo random number generation
    eta = jnp.sum(X_full, axis=-1)
    y = eta > 0
    # return only first 9 column to have some noise
    X = X_full[:,:9]
    return (X, y)

# initialize a generic solver with the correct objective function
solver = LBFGS(binary_logreg)
# need to specify parameter initialization values
w_init = jnp.zeros((9,))

@jit # jit toggles just-in-time compilation, one of the main features of JAX
def solve(k):
    data = make_data(k)
    param, state = solver.run(w_init, data)
    return param

# make a scan version that doesn't store the full coefficients
def solve_scan(carry, x=None):
    k_old, param_old = carry
    k = random.split(k_old)[0]
    data = make_data(k)
    param, _ = solver.run(w_init, data)
    return (k, param_old + param), None

if __name__ == '__main__':
    args = parser.parse_args()
    k0 = random.PRNGKey(240316)
    if args.primitive == 'map':
        ks = random.split(k0, args.nreps)
        params = lax.map(solve, ks)
        means = jnp.mean(params, axis=0)
    elif args.primitive == 'vmap':
        if args.nscan > 0:
            n_per_vmap = int(args.nreps / args.nscan)
            def solve_fn(k):
                carry0 = (k, w_init)
                (_, params), _ = lax.scan(solve_scan, carry0, None, length=args.nscan)
                return params / args.nscan
        else:
            n_per_vmap = args.nreps
            solve_fn = solve
        ks = random.split(k0, n_per_vmap)
        params = vmap(solve_fn)(ks)
        means = jnp.mean(params, axis=0)
    elif args.primitive == 'scan':
        carry0 = (k0, w_init)
        (_, params), _ = lax.scan(solve_scan, carry0, None, length=args.nreps)
        means = params / args.nreps
    else:
        raise ValueError(f"unrecognized primitive: {args.primitive}, choose map, vmap or scan")
    print(means[0])


