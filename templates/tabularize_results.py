#! /usr/bin/env python3

import pandas as pd
from ete3 import NCBITaxa


ncbi = NCBITaxa()

funguild = pd.read_csv("$funguild", sep='\\t', index_col="SequenceID")
motu_info = pd.read_csv("$motu_info", sep='\\t', names=["MOTU", "SequenceID"], index_col="SequenceID")
sequence_species = pd.read_csv("$sequence_species", sep='\\t', index_col="SequenceID")
environment = pd.read_csv("$environment", sep='\\t', names=["SequenceID", "${environment.simpleName}"], index_col="SequenceID")
sequence_path = pd.read_csv("$taxonomy", sep='\\t', index_col="SequenceID")
sequence_path.columns = ['taxonomy_path']

sequence_species['species'] = sequence_species['taxonomy'].apply(lambda x: ncbi.get_taxid_translator([x])[x])

mergedf = pd.merge(sequence_species, funguild[['Guild', 'Trophic Mode']],
                            left_index=True, right_index=True)
mergedf = pd.merge(motu_info, mergedf, left_index=True, right_index=True)

mergedf = pd.merge(mergedf, environment, left_index=True, right_index=True, how='outer')
mergedf = pd.merge(mergedf, sequence_path, left_index=True, right_index=True)

mergedf.to_csv("${sequence_species.baseName}.tab", sep='\\t')
