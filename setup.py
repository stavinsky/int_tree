from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize


with open("README.md", "r") as fh:
    long_description = fh.read()

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
    name='int_tree',
    version='0.0.1',
    author='Anton D. Stavinsky',
    author_email='stavinsky@gmail.com',
    description="Interval Tree supported uint128",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url='https://github.com/stavinsky/int_tree',
    ext_modules=cythonize(extensions),
    python_requires='>=3.6',
)
