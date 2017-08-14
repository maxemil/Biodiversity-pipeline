# Pipeline to characterize and analyse fungal microbiomes
## Installation & Getting started
* install nextflow

```
curl -s https://get.nextflow.io | bash
```

* pull the singularity image from the singularity hub

```
singularity pull shub://maxemil/Biodiversity-pipeline:master
```

* execute the pipeline with input.fasta, references.fasta (e.g. ) and information on the ecology of sequences

```
nextflow run maxemil/Biodiversity-pipeline --input_fasta input.fasta \
                      --reference_sequences references.fasta \
                      --environment_information ecology.tab \
                      --output_directory output \
                      -with-singularity maxemil-Biodiversity-pipeline-master.img
```

## Dependencies
### for the pipeline execution / container
* java >= 7
* nextflow (http://nextflow.io)
* singularity (recommended, http://singularity.lbl.gov/)

### Tools
* MALT (http://ab.inf.uni-tuebingen.de/software/malt/)
* MEGAN6 (http://ab.inf.uni-tuebingen.de/software/megan6/)
* FUNGuild (https://github.com/UMNFuN/FUNGuild)
* vsearch (https://github.com/torognes/vsearch)
* spaced words (http://spaced.gobics.de/)
* python3
  * pandas
  * numpy
  * requests
* R
  * vegan
  * picante
  * VennDiagram
