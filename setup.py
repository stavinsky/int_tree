from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

extensions = [
    Extension(
        "int_tree",
        sources=["tree.pyx"],
        extra_compile_args=["-std=c++11", "-O3"],
        extra_link_args=["-std=c++11"],
        language='c++',
    ),
]
setup(
    name='Interval Tree',
    ext_modules=cythonize(extensions),
)
