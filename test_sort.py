# flake8: noqa

def _split(source, dest):
    l = len(source)
    if l == 0:
        return
    if l == 1:
        dest.append(source[0])
        return
    dest.append(source[l//2 ])
    _split(source[:l//2  ], dest)
    _split(source[l//2 + 1: ], dest)


def split(source: list):
    dest = list()
    _split(source, dest)
    return dest



if __name__ == "__main__":
    s = list(range(30))
    r = split(s)
    print(r)
    assert s == sorted(r)
