#cython: language_level=3
DEF H = 2**64 - 1
from cpython.object cimport Py_LT, Py_LE, Py_EQ, Py_GE, Py_GT, Py_NE
from cython import auto_pickle
ctypedef unsigned long long u64

@auto_pickle(True)
cdef class BigInt:
    cdef u64 _high
    cdef u64 _low

    def __init__(self, value ):
        self._high = value>>64 & H
        self._low = value & H

    cdef inline u64 high(self):
        return self._high

    cdef inline u64 low(self):
        return self._low

    @staticmethod
    cdef BigInt from_high_low(u64  high, u64 low):
        cdef BigInt r = BigInt.__new__(BigInt)
        r._high = high
        r._low = low
        return r
    def __richcmp__(BigInt x, BigInt y, int op):
        cdef:
            u64 x_high = x.high()
            u64 x_low = x.low()
            u64 y_high = y.high()
            u64 y_low = y.low()
        if op == Py_LT:
            return (x_high < y_high) |  ((x_high == y_high) & (x_low < y_low))
        elif op == Py_LE:
            return ((x_high == y_high) & (x_low == y_low)) | ((x_high < y_high) | ((x_high == y_high) & (x_low < y_low)))
        elif op == Py_EQ:
            return (x_high == y_high) & (x_low == y_low)
        elif op == Py_NE:
            return (x_high != y_high) & (x_low != y_low)
        elif op == Py_GT:
            return (x_high > y_high) | ((x_high == y_high) & (x_low > y_low))
        elif op == Py_GE:
            return ((x_high == y_high) & (x_low == y_low)) | ((x_high > y_high) | ((x_high == y_high) & (x_low > y_low)))
        return False

    def __hash__(self):
        return hash((self._high, self._low))

    def __repr__(self):
        r = (int(self._high) << 64) + self._low
        return f"{r}"

    def __sub__(BigInt x, BigInt y):
        if x < y:
            raise NotImplementedError()
        cdef u64 m_high = 0
        cdef u64 m_low = 0
        m_high = x.high() - y.high()
        m_low = x.low() - y.low()
        if x.low() < y.low():
            m_high = m_high - 1
        return BigInt.from_high_low(m_high, m_low)

    cdef BigInt half(self):
        return BigInt.from_high_low(self._high >> 1, self._low >> 1)

    def __add__(BigInt x, BigInt y):
        cdef:
            u64 x_high = x.high()
            u64 x_low = x.low()
            u64 y_high = y.high()
            u64 y_low = y.low()
            u64 r_low = 0
            u64 r_high = 0
            BigInt result
        r_high = x_high + y_high
        r_low =  x_low + y_low
        if r_low < r_high:
            r_low = r_low + 1
        return BigInt.from_high_low(r_high, r_low)

cdef class RangeBig(object):
    cdef BigInt _first
    cdef BigInt _last

    def __init__(self, first, last):
        self._first = BigInt(first)
        self._last = BigInt(last)

    def __contains__(self, BigInt ip):
        return (self._first <= ip) & (self._last >= ip)

    def __eq__(self, RangeBig other):
        return (self._first == other.first) & (self._last == other.last)

    def __repr__(self,):
        return f"Range({self._first}, {self._last})"

    def __hash__(self):
        return hash((
            self._first.low,
            self._first.high,
            self._last.low,
            self._last.high
            ))
    @property
    def first(self):
        return self._first
    @property
    def last(self):
        return self._last

    @property
    def middle(self):
        cdef BigInt half
        half = self._last - self._first
        half = half.half()
        return self._first + half

cdef class Node(object):
    cdef Node _left
    cdef Node _right
    cdef BigInt _key
    cdef public set ranges
    cdef short _height
    def __init__(self, _range):
        self.left = None
        self.right = None
        self.ranges = set((_range,))
        self._key = _range.middle
        self._height = 1

    @property
    def left(self):
        return self._left

    @left.setter
    def left(self, value):
        self._left = value

    @property
    def right(self):
        return self._right

    @right.setter
    def right(self, value):
        self._right = value

    @property
    def height(self):
        return self._height

    @height.setter
    def height(self, value):
        self._height = value

    @property
    def key(self):
        return self._key

cdef class Tree(object):
    cdef Node root
    def __init__(self,):
        self.root = None

    cdef int get_height(self, Node node):
        if not node:
            return 0
        return node.height

    cdef int get_balance(self, Node node):
        if not node:
            return 0
        return self.get_height(node.left) - self.get_height(node.right)

    def insert(self, _range):
        if  self.root is None:
            self.root = Node(_range)
        self.root = self._insert(self.root, _range)

    cdef Node _insert(self, Node node, RangeBig _range):
        if not node:
            return Node(_range)
        if node.key in _range:
            node.ranges.add(_range)
            return node
        cdef BigInt _key = _range.first
        if _range.last < node.key:
            node.left = self._insert(node.left, _range)

        else:
            node.right = self._insert(node.right, _range)

        node.height = 1 + max(self.get_height(node.left), self.get_height(node.right))
        cdef int balance = self.get_balance(node)


        if balance > 1 and _key < node.left.key:
            return self.right_rotate(node)

        if balance < -1 and _key > node.right.key:
            return self.left_rotate(node)

        if balance > 1 and _key > node.left.key:
            node.left = self.left_rotate(node.left)
            return self.right_rotate(node)

        if balance < -1 and _key < node.right.key:
            node.right = self.right_rotate(node.right)
            return self.left_rotate(node)

        return node

    def get_ranges(self, ip):
        ip = BigInt(ip)
        return self._get_ranges(self.root, ip)

    cdef set _get_ranges(self, Node node, BigInt ip):
        if ip == node.key:
            return node.ranges
        ranges = set()
        for _range in node.ranges:
            if ip in _range :
                ranges.add(_range)
        if ip < node.key:
            if node.left:
                ranges.update(self._get_ranges(node.left, ip))
            return ranges
        if ip > node.key:
            if node.right:
                ranges.update(self._get_ranges(node.right, ip))
            return ranges

    def print_tree(self,):
        self._print_tree(self.root)

    def _print_tree(self, node):
        if node is None:
            return
        if node.left:
            self._print_tree(node.left)
        print( node.ranges, node.height),
        if node.right:
            self._print_tree(node.right)

    cdef Node left_rotate(self, Node node):
        cdef Node y = node.right
        cdef Node T2 = y.left
        y.left = node
        node.right = T2

        node.height = 1 + max(self.get_height(node.left),
                         self.get_height(node.right))
        y.height = 1 + max(self.get_height(y.left),
                         self.get_height(y.right))
        return y

    cdef Node right_rotate(self, Node node):
        cdef Node y = node.left
        cdef Node T3 = y.right
        y.right = node
        node.left = T3
        node.height = 1 + max(self.get_height(node.left),
                        self.get_height(node.right))
        y.height = 1 + max(self.get_height(y.left),
                        self.get_height(y.right))
        return y

    def stat(self):
        return self._stat(self.root)

    def _stat(self, node):
        if node is None:
            return list()
        l = list()
        if node.left:
            l.extend(self._stat(node.left))
        l.append((node.ranges, node.height, node.key))
        if node.right:
            l.extend(self._stat(node.right))
        return l

#    def optimize(self):
#        self._optimize(self.root)
#
#    def _optimize(self, node):
#        if node is None:
#            return
#        for r in self.ranges:
#            if node.left.key in r:
#
#                break


