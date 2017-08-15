#! /usr/bin/env python3

guilds = {}

with open("${funguild.baseName}",'w') as handle:
    with open("$funguild") as f:
        for line in f:
            if not line.startswith('SequenceID'):
                line = line.split('\t')
                try:
                    guilds[line[5]] = guilds[line[5]] + 1
                except:
                    guilds[line[5]] = 1

    for k in guilds.keys():
        if k == "-":
            print("\t".join(['Unassigned', str(guilds[k])]), file=handle)
        else:
            print("\t".join([k, str(guilds[k])]), file=handle)
