from tree_big import RangeBig, Tree, Node, BigInt
import pickle


def test_always_ascending():
    tree = Tree()
    for i in range(0, 100000, 50):
        r = RangeBig(i, i + 49)
        tree.insert(r)
    assert tree.get_ranges(5) == {RangeBig(0, 49)}


def test_always_descending():
    tree = Tree()
    for i in range(100000, 0, -50):
        r = RangeBig(i, i + 49)
        tree.insert(r)
    assert tree.get_ranges(50) == {RangeBig(50, 99)}


def test_range_pickle():
    r = RangeBig(0, 10)
    s = pickle.dumps(r)
    r1 = pickle.loads(s)
    assert r == r1


def test_node_pickle():
    r = RangeBig(0, 10)
    node = Node(r)
    s = pickle.dumps(node)
    node_1 = pickle.loads(s)
    assert node.key == node_1.key


def test_tree_pickle():
    tree = Tree()
    for i in range(100000, 0, -50):
        r = RangeBig(i, i + 49)
        tree.insert(r)
    s = pickle.dumps(tree)
    tree_1 = pickle.loads(s)
    assert tree_1.get_ranges(50) == set((RangeBig(50, 99),))


def test_big_int_comparsion():
    r1 = (0 << 64) + 0
    r2 = (0 << 64) + 0
    assert BigInt(r1) == BigInt(r2)
    assert BigInt(r1) >= BigInt(r2)
    assert BigInt(r2) <= BigInt(r1)

    r1 = (1 << 64) + 0
    r2 = (1 << 64) + 0
    assert BigInt(r1) == BigInt(r2)
    assert BigInt(r1) >= BigInt(r2)
    assert BigInt(r2) <= BigInt(r1)

    r1 = (1 << 64) + 1
    r2 = (1 << 64) + 1
    assert BigInt(r1) == BigInt(r2)
    assert BigInt(r1) >= BigInt(r2)
    assert BigInt(r2) <= BigInt(r1)

    r1 = (1 << 64) + 0
    r2 = (0 << 64) + 1
    assert BigInt(r1) > BigInt(r2)
    assert BigInt(r1) >= BigInt(r2)
    assert BigInt(r2) < BigInt(r1)
    assert BigInt(r2) <= BigInt(r1)

    r1 = (0 << 64) + 1
    r2 = (0 << 64) + 0
    assert BigInt(r1) > BigInt(r2)
    assert BigInt(r1) >= BigInt(r2)
    assert BigInt(r2) < BigInt(r1)
    assert BigInt(r2) <= BigInt(r1)


# def test_always_ascending_big():
#     tree = Tree()
#     for i in range(0, 100000, 50):
#         r = RangeBig(i, i + 49)
#         tree.insert(r)
#     assert tree.get_ranges(5) == {Range(0, 49)}
