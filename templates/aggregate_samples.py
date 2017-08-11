#! /usr/bin/env python3
import numpy as np
import pandas as pd
import re

def atoi(text):
    return int(text) if text.isdigit() else text

def natural_keys(text):
    return [ atoi(c) for c in re.split('(\\d+)', text) ]

motus = pd.read_csv("motu_info.txt", sep='\t', names=['MOTU', 'ID'], dtype=str)
ecology = pd.read_csv("$environment", sep='\t', names=['ID', 'Ecology'], dtype=str)

merged = pd.merge(motus, ecology, on='ID')
merged['count'] = 1
merged['MOTU'] = "MOTU_" + merged['MOTU']

pivoted_table = merged.pivot_table(index='Ecology', columns='MOTU',
                                    aggfunc=np.sum,
                                    values='count', fill_value=0.0)

MOTUs = list(set(merged['MOTU']))
MOTUs.sort(key=natural_keys)

sorted_df = pivoted_table.reindex_axis(MOTUs, axis=1)
sorted_df.to_csv("aggregate.sample", sep='\t')
