# cython: language_level=3
# distutils: language = c++
# distutils: sources = ./ctree/ctree.cpp

from libcpp.vector cimport vector
# from libcpp.pair import pair
from libcpp.utility cimport pair

cdef extern from "ctree/ctree.h":
    ctypedef unsigned long long u128;
#     cdef struct Range:
#         u128 first
#         u128 last
    ctypedef pair[u128, u128] Range
    ctypedef vector[Range] Ranges
    cdef struct Node:
        Node* left
        Node* right
        u128 key
        unsigned char height
        Ranges ranges
    ctypedef void (*func)(u128* acc ,Node* node)
    cdef cppclass Tree:
        Tree() except +
        void insert(Range) nogil except +
        Ranges ranges_for_point(u128) except +
        Ranges items() except +


cdef class CTree:
    cdef Tree tree
    def __cinit__(self):
        self.tree = Tree()
    def insert(self, r):
        cdef Range _range = Range(r[0], r[1])
        self.tree.insert(_range)
    def bulk_insert(self, list rs):
        cdef Range r
        for r in rs:
            self.tree.insert(r)
    def items(self):
        return self.tree.items()
    def ranges_for_point(self, point):
        return self.tree.ranges_for_point(point)


def test():
    cdef Range r = Range(1, 10)
    print(r)
    tree = CTree()
    tree.insert((1, 10))
    print(tree.items())


