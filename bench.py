from tree import Tree, Range
from tqdm import tqdm


if __name__ == "__main__":
    tree = Tree()
    for i in tqdm(range(0, 100000000, 50)):
        r = Range(i, i + 49)
        tree.insert(r)
    for i in tqdm(range(100)):
        tree.get_ranges(i)
    print(tree.get_ranges(500001))
