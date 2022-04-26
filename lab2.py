from copy import copy, deepcopy 

possibilities = [0.74, 0.14, 0.56, 0.35, 0.20, 0.21]
linkMatrix = [[False, False, True, True, True, False],
              [False, False, True, True, False, True],
              [False, False, False, True, True, True],
              [False, False, False, False, True, True],
              [False, False, False, False, False, False],
              [False, False, False, False, False, False]]

for i in possibilities:
    if i <= 0 or i > 1:
        print("Wrong possibslity")
        exit(1)

n = len(possibilities)
if n < 1:
    print("Empty scheme")
    exit(1)
if len(linkMatrix) != n:
    print("Wrong link matrix")
    exit(1)
else:
    for i in linkMatrix:
        if i.count(True) + i.count(False) != n:
            print("wrong link matrix")
            exit(1)

transposedMatrix = list(zip(*linkMatrix))
startVertexes = []
endVertexes = []
for i in range(len(transposedMatrix)):
    if transposedMatrix[i].count(False) == n:
        startVertexes.append(i)
for i in range(len(linkMatrix)):
    if linkMatrix[i].count(False) == n:
        endVertexes.append(i)
if not startVertexes or not endVertexes:
    print("No start or end element")
    exit(1)

ways = []
way = []


def findWays(vertex, prevVertex):
    if prevVertex != n:
        if linkMatrix[vertex][prevVertex:].count(True) > 0:
            index = linkMatrix[vertex].index(True, prevVertex)
            way.append(index)
            findWays(index, 0)
        else:
            if linkMatrix[vertex].count(False) == n:
                ways.append(copy(way))
            way.remove(vertex)
            if way:
                findWays(way[-1], vertex + 1)
    else:
        way.remove(vertex)
        if way:
            findWays(way[-1], vertex + 1)


def breakOrNot(a, b):
    if a == 0:
        return 1 - b
    if a == 1:
        return b


def composition(massive):
    result = 1
    for elem in massive:
        result *= elem
    return result


if n == 1:
    possibility = possibilities[0]
else:
    for i in startVertexes:
        way.append(i)
        findWays(i, 0)
    if not ways:
        print("No ways found")
        exit(1)

    else:
        goodWays = []
        for i in ways:
            goodStates = [[]]
            for j in range(n):
                if j in i:
                    for k in range(len(goodStates)):
                        goodStates[k].append(1)
                else:
                    goodStates.extend(deepcopy(goodStates))
                    for k in range(int(len(goodStates) / 2)):
                        goodStates[k].append(0)
                        goodStates[-k - 1].append(1)
            for k in goodStates:
                if k not in goodWays:
                    goodWays.append(k)
        possibility = 0
        for i in goodWays:
            possibility += composition(list(map(breakOrNot, i, possibilities)))
print("Імовірність безвідмовної роботи системи протягом 10 годин = {}".format(possibility))