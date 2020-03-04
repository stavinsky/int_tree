from tree_big import Tree, RangeBig
from tqdm import tqdm


if __name__ == "__main__":
    tree = Tree()
    for i in tqdm(range(2**64, 2**64 + 100000000, 50)):
        r = RangeBig(i, i + 49)
        tree.insert(r)
    for i in tqdm(range(2**64, 2**64 + 100)):
        tree.get_ranges(i)

    print(2**64 + 500001)
    print(tree.get_ranges(2**64 + 500001))
