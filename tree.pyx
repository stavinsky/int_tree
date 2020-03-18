# cython: language_level=3
# distutils: language = c++
# distutils: sources = ./ctree/ctree.cpp

from libcpp.vector cimport vector

cdef extern from "ctree/ctree.h":
    ctypedef unsigned long long u128;
    cdef struct Range:
        u128 first
        u128 last
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
        vector[Ranges] items() except +


cdef class PTree:
    cdef Tree tree
    def __cinit__(self):
        self.tree = Tree()
    def insert(self, r):
        cdef Range _range = Range(r[0], r[1])
        self.tree.insert(_range)
    def bulk_insert(self, list rs):
        cdef u128 f, l
        cdef Range r
        for f,l in rs:
            self.tree.insert(Range(f,l))
    def items(self):
        return self.tree.items()
    def ranges_for_point(self, point):
        return self.tree.ranges_for_point(point)


def test():
    cdef Range r = Range(1, 10)
    print(r.first, r.last)
    tree = PTree()
    tree.insert((1, 10))
    # print(tree.ranges_for_point(3))
    print(tree.items())


