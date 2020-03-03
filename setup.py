from distutils.core import setup
from Cython.Build import cythonize

setup(name='Interval Tree',
      ext_modules=cythonize("tree.pyx"))
