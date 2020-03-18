from int_tree import CTree as Tree


def test_always_ascending_insert():
    tree = Tree()
    ranges = list((i, i + 49) for i in range(0, 100000, 50))
    for r in ranges:
        tree.insert(r)

    assert tree.ranges_for_point(5) == [(0, 49)]
    assert sorted(ranges) == tree.items()


def test_always_descending():
    tree = Tree()
    ranges = list((i, i + 49) for i in range(100000, 0, -50))
    for i in ranges:
        tree.insert(i)
    assert tree.ranges_for_point(50) == [(50, 99)]
    assert sorted(ranges) == tree.items()
