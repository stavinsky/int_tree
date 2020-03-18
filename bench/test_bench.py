from int_tree import CTree as Tree


def test_insertions(benchmark):
    ranges = range(0, 50 * 6000000, 50)
    ranges = list((i, i + 101) for i in ranges)

    def test_f():
        tree = Tree()
        for i in ranges:
            tree.insert(i)
    benchmark(test_f)


def test_bulk_insertions(benchmark):
    ranges = range(0, 50 * 6000000, 50)
    ranges = list((i, i + 101) for i in ranges)

    def test_f():
        tree = Tree()
        tree.bulk_insert(ranges)
    benchmark(test_f)
