#cython: language_level=3

cdef class Range(object):
    cdef public unsigned long first
    cdef public unsigned long last

    def __init__(self, first, last):
        self.first = first
        self.last = last

    def __contains__(self, unsigned long ip):
        return self.first <= ip and self.last >= ip

    def __eq__(self, other):
        return self.first == other.first and self.last == other.last

    def __repr__(self,):
        return f"Range({self.first}, {self.last})"

    def __hash__(self):
        return hash((self.first, self.last))


cdef class Node(object):
    cdef public Node left
    cdef public Node right
    cdef public unsigned long key
    cdef public set ranges
    cdef public short height
    def __init__(self, _range):
        self.left = None
        self.right = None
        self.ranges = set((_range,))
        self.key = _range.first
        self.height = 1


cdef class Tree(object):
    cdef Node root
    def __init__(self,):
        self.root = None

    cpdef int get_height(self, Node node):
        if not node:
            return 0
        return node.height

    cpdef int get_balance(self, node):
        if not node:
            return 0
        return self.get_height(node.left) - self.get_height(node.right)

    def insert(self, _range):
        if  self.root is None:
            self.root = Node(_range)
        self.root = self._insert(self.root, _range)

    cpdef Node _insert(self, node, _range):
        if not node:
            return Node(_range)
        if node.key in _range:
            node.ranges.add(_range)
            return node
        cdef unsigned long _key = _range.first
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

    cpdef set get_ranges(self, ip):
        return self._get_ranges(self.root, ip)

    cpdef set _get_ranges(self, node, ip):
        if int(ip) == node.key:
            return node.ranges
        ranges = set()
        for _range in node.ranges:
            if <int>ip in _range :
                ranges.add(_range)
        if int(ip) < node.key:
            if node.left:
                ranges.update(self._get_ranges(node.left, ip))
            return ranges
        if int(ip) > node.key:
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

    cdef Node left_rotate(self, node):
        cdef Node y = node.right
        cdef Node T2 = y.left
        y.left = node
        node.right = T2

        node.height = 1 + max(self.get_height(node.left),
                         self.get_height(node.right))
        y.height = 1 + max(self.get_height(y.left),
                         self.get_height(y.right))
        return y

    cdef Node right_rotate(self, node):
        cdef Node y = node.left
        cdef Node T3 = y.right
        y.right = node
        node.left = T3
        node.height = 1 + max(self.get_height(node.left),
                        self.get_height(node.right))
        y.height = 1 + max(self.get_height(y.left),
                        self.get_height(y.right))
        return y
