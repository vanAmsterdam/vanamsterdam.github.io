import jax, jaxopt
jax.config.update('jax_platform_name', 'cpu') # make sure jax doesnt use a gpu if it's available
from jax import numpy as jnp, random, vmap, jit, lax
from jaxopt import LBFGS
from jaxopt.objective import binary_logreg
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument('nreps', nargs="?", type=int, default=int(10))

def make_data(k, n=int(1e3)):
    X_full = random.normal(k, (n,10)) # JAX needs explicit keys for psuedo random number generation
    eta = jnp.sum(X_full, axis=-1)
    y = eta > 0
    # return only first 9 column to have some noise
    X = X_full[:,:9]
    return (X, y)

# initialize a generic solver with the correct objective function
solver = LBFGS(binary_logreg)
w_init = jnp.zeros((9,))

def solve(k):
    # need to specify parameter initialization values
    data = make_data(k)
    param, state = solver.run(w_init, data)
    return param

# scan is a jax optimized way of looping
def scannable_solve(carry, k):
    params = solve(k)
    return carry, params

if __name__ == '__main__':
    args = parser.parse_args()
    k0 = random.PRNGKey(240316)
    ks = random.split(k0, args.nreps)
    _, params = lax.scan(scannable_solve, None, ks)
    # params = vmap(solve)(ks) # vmap vectorizes computations
    # params = vmap(solve)(ks) # vmap vectorizes computations
    means = jnp.mean(params, axis=0)
    print(means[0])

