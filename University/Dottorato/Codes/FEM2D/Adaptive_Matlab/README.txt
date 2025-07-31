The code accompanying "Understanding and Implementing the Finite
Element Method" by Mark S. Gockenbach (SIAM, 2006) is contained in
four directories:

   1. version1: linear Lagrange triangles
   2. version2: Lagrange triangles of arbitrary degree
   3. version3: isoparametric elements of arbitrary degree
   4. adaptive: local refinement, a posteriori error estimates, etc.

All four directories should be on your MATLAB path.  Use statements like
     addpath('/home/math/msgocken/fem/version1')
     addpath('/home/math/msgocken/fem/version2')
     addpath('/home/math/msgocken/fem/version3')
     addpath('/home/math/msgocken/fem/adaptive')
I add these to my startup.m file for simplicity.

Each directory contains examples illustrating the use of the code:

   1. version1:
         Example1a: Solves a BVP with a known solution on a single
                    mesh and computes the error in the solution.
         Example1b: Invokes TestConv1 to illustrate the convergence
                    of the finite element method on the BVP from
                    Example1a.
         Example1c: Solves a BVP on a given mesh, then refines the
                    mesh uniformly and solves again.  Compares the
                    two solutions to estimate the error.

   2. version2:
         Example2a: Solves a BVP with a known solution using cubic
                    Lagrange triangles and computes the error in the
                    solution.
         Example2b: Invokes TestConv2 to illustrate the convergence
                    of the finite element method on the BVP from
                    Example2a (cubic elements).
         Example2b: Invokes TestConv2 to illustrate the convergence
                    of the finite element method on a domain with a
                    curved boundary (nonisoparametric cubic elements)

   3. version3:
         Example3a: Solves a BVP with a known solution on a domain
                    with a curved boundary using isoparametric cubic
                    Lagrange triangles; computes the error in the
                    solution.
         Example3b: Invokes TestConv to illustrate the convergence
                    of the finite element method on the BVP from
                    Example3a (isoparametric cubic elements).
         Example3c: Same as Example2c but uses isoparametric elements.

   4. adaptive:
         AdaptiveExample1: Invokes Solve to apply an adaptive algorithm
                           to a BVP with a known solution (sharp peak
                           in the interior).
         AdaptiveExample2: Invokes Solve to apply an adaptive algorithm
                           to a BVP with an unknown solution (transition
                           from Dirichlet to Neumann conditions).
