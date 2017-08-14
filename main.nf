#!/usr/bin/env nextflow

def startup_message() {
    log.info "=========================================================="
    log.info "                   Biodiversity Pipeline"
    log.info "Author                         : Max Emil Schön"
    log.info "email                          : max-emil.schon@icm.uu.se"
    log.info "=========================================================="
    log.info "Input fastA file            : $params.input_fasta"
    log.info "reference sequences         : $params.reference_sequences"
    log.info "environmental information   : $params.environment_information"
    log.info "output directory            : $params.output_directory"
    log.info ""
}

startup_message()

Channel.from(file(params.reference_sequences)).into { reference_sequences_taxonomy ; reference_sequences_chimera }
input_sequences = Channel.from(file(params.input_fasta))
environment_information = Channel.from(file(params.environment_information))

process buildDatabase {
  input:
  file references from reference_sequences_taxonomy

  output:
  file "REFDB" into malt_index

  script:
  """
  /local/one/people/MaxEmil/Biodiversity/malt/malt-build --input $references \
                                          --sequenceType DNA \
                                          --index REFDB \
                                          --acc2taxonomy $workflow.projectDir/nucl_acc2tax-May2017.abin \
                                          -fwo --threads 20
  #/usr/local/malt/malt-build
  """
}


process checkChimeras {
  input:
  file seqs from input_sequences
  file reference_sequences from reference_sequences_chimera

  output:
  file "${seqs.baseName}.nochimeras" into seqs_nochim
  file "${seqs.baseName}.chimeras" into seqs_chim

  publishDir "${workflow.launchDir}/${params.output_directory}", mode: 'copy'
  
  script:
  """
  $workflow.projectDir/binaries/vsearch --uchime_ref $seqs \
                                        --db $reference_sequences \
                                        --nonchimeras ${seqs.baseName}.nochimeras \
                                        --chimeras ${seqs.baseName}.chimeras
  """
}

seqs_nochim.into{ input_sequences_cluster; input_sequences_distance; input_sequences_classify }

process classifySequences {
  input:
  file seqs from input_sequences_classify
  file "REFDB" from malt_index

  output:
  file "${seqs.baseName}.rma" into classified_sequences

  publishDir "${workflow.launchDir}/${params.output_directory}", mode: 'copy'

  script:
  """
  /local/one/people/MaxEmil/Biodiversity/malt/malt-run --mode BlastN \
                                            --inFile $seqs \
                                            --index REFDB \
                                            --output ${seqs.baseName}.rma \
                                            -t 20 --verbose
                                            # \
                                            # --topPercent 2 -wlca
                                            # --alignments ${seqs.baseName}.txt \
                                            # --format Text
                                            # -b 100 \
                                            # --maxAlignmentsPerQuery 15 \
  """

}

process extractTaxonomy {
  input:
  file rma from classified_sequences

  output:
  file "${rma.baseName}.assignments" into sequence_taxonomy

  publishDir "${workflow.launchDir}/${params.output_directory}", mode: 'copy'

  script:
  """
  printf "SequenceID\ttaxonomy\n" > ${rma.baseName}.assignments
  /usr/local/megan/tools/rma2info -i $rma \
                                  -r2c Taxonomy \
                                  -p >> ${rma.baseName}.assignments
  """
}


process funGuild {
  input:
  file assignments from sequence_taxonomy

  output:
  file "${assignments.baseName}.guilds.txt" into sequence_guilds

  stageInMode 'copy'
  publishDir "${workflow.launchDir}/${params.output_directory}", mode: 'copy'

  script:
  """
  sed -i 's/\\t.*\\[K/\\tK/g;s/\\]\\ /__/g;s/\\ \\[//g' $assignments
  python2 /local/one/people/MaxEmil/MacExchange/scripts/FUNGuild-master/Guilds_v1.0.py \
        -otu $assignments \
        -db fungi
  """
}

process clusterSequences {
  input:
  file seqs from input_sequences_cluster

  output:
  file "motu_info.txt" into motu_info_file
  file "sequence_names.txt" into sequences_names_long

  publishDir "${workflow.launchDir}/${params.output_directory}", mode: 'copy'

  script:
  """
  $workflow.projectDir/binaries/vsearch --cluster_fast $seqs \
                                        --id 0.97 \
                                        --sizeorder \
                                        --uc ${seqs.baseName}.uc
  grep -v '^C' Endophytes.uc| cut -f 2,9 | sort -n > motu_info.txt
  cut -f2 motu_info.txt | sort > sequence_names.txt
  """
}


process spacedWordDistances {
  input:
  file seqs from input_sequences_distance

  output:
  file "${seqs.baseName}.dist" into sequence_distances

  publishDir "${workflow.launchDir}/${params.output_directory}", mode: 'copy'

  script:
  """
  $workflow.projectDir/binaries/spaced -o ${seqs.baseName}.dist $seqs
  """
}

motu_info_file.into {motu_info_file_distance ; motu_info_file_samples}

process aggregateSpecies {
  input:
  file seqs_dist from sequence_distances
  file "motu_info.txt" from motu_info_file_distance
  file "sequence_names.txt" from sequences_names_long

  output:
  file "${seqs_dist.baseName}_MOTU.dist" into motu_distances

  publishDir "${workflow.launchDir}/${params.output_directory}", mode: 'copy'

  script:
  template "aggregate_species.py"
}


process aggregateSamples {
  input:
  file environment from environment_information
  file "motu_info.txt" from motu_info_file_samples

  output:
  file "aggregate.sample" into aggregate_samples

  publishDir "${workflow.launchDir}/${params.output_directory}", mode: 'copy'

  script:
  template "aggregate_samples.py"

}


process phylogeneticCommunityAnalysis {
  input:
  file "aggregate.sample" from aggregate_samples
  file "MOTU.dist" from motu_distances

  output:
  file 'ecology_diversity.pdf' into diversity_pdf
  file 'venn.tiff' into venn_tiff

  publishDir "${workflow.launchDir}/${params.output_directory}", mode: 'copy'

  script:
  template "phylogenetic_community.R"
}
