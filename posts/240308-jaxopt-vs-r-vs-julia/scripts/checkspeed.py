import jax, jaxopt
# jax.config.update('jax_platform_name', 'cpu')
from jax import numpy as jnp, random, vmap, jit, lax
from jaxopt import LBFGS
from jaxopt.objective import binary_logreg
import time
from functools import wraps

from argparse import ArgumentParser
parser = ArgumentParser()
parser.add_argument('nreps', type=int)
parser.add_argument('--nscan', type=int, default=int(1))

def make_data(k, n=int(1e3)):
    kx, ke = random.split(k)
    x = random.normal(kx, (n,10))
    eta = jnp.sum(x, axis=-1)
    y = eta > 0
    # return only first 9 column to have some noise
    X = x[:,:9]
    return (X, y)

solver = LBFGS(binary_logreg)

@jit
def solve(k):
    w_init = jnp.zeros((9,))
    # solver = LBFGS(binary_logreg)
    data = make_data(k)
    param, state = solver.run(w_init, data)
    return param

def run_exp(k, nreps=2):
    ks = random.split(k, nreps)
    params = vmap(solve)(ks)
    return params

if __name__ == '__main__':
    args = parser.parse_args()
    ntotal = args.nreps * args.nscan
    print(f"running {ntotal} experiments, scanning over {args.nscan}")
    k0 = random.PRNGKey(0)
    if args.nscan > 1:
        ks = random.split(k0, args.nscan)
        def scannable(carry, k):
            params = run_exp(k, args.nreps)
            return carry, params
        _, param = lax.scan(scannable, None, ks)
        print(jnp.mean(param, axis=(0,1)))
    else:
        param = run_exp(k0, args.nreps)
        print(jnp.mean(param, axis=0))


