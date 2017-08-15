#! /usr/bin/env python3
import numpy as np
import pandas as pd
from collections import defaultdict

mat = []
motu = defaultdict(list)

with open("$seqs_dist") as f:
    for line in f:
        line = line.split()
        mat.append(line)

mat = mat[1:]
mat = np.array(mat)
names = pd.read_csv("sequence_names.txt", header=None)
mat = mat[:,1:]
mat = mat.astype(np.float64)

(mat.transpose(1, 0) == mat).all()

with open ("motu_info.txt") as f:
    for line in f:
        line = line.strip().split('\t')
        motu[line[0]].append(line[1])

species_mat = np.zeros((len(motu),len(motu)))

for m1 in motu.keys():
    for m2 in motu.keys():
        if m1 != m2:
            sel = mat[np.in1d(names,motu[str(m1)]),]
            sel = sel[:,np.in1d(names,motu[str(m2)])]
            species_mat[int(m1),int(m2)] = sel.mean()
        else:
            species_mat[int(m1),int(m2)] = 0

motus = ["MOTU_%s" % i for i in range(0,len(motu))]
species_mat = pd.DataFrame(species_mat, columns=motus, index=motus)

species_mat.to_csv("${seqs_dist.baseName}_MOTU.dist" , sep='\\t')
