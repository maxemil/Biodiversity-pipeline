#! /usr/bin/Rscript
library(picante)
library(vegan)

sample.dat = read.csv('aggregate.sample', sep='\t', header=TRUE, row.names=1)
dist.dat = read.csv('MOTU.dist', sep='\t', header=TRUE, row.names=1)

######## Phylogenetic Community Measures ###########
ses.mntd(sample.dat, dist.dat, null.model="sample.pool", runs=9999, iterations=1000, abundance.weighted=FALSE)
ses.mpd(sample.dat, dist.dat, null.model="sample.pool", runs=9999, iterations=1000, abundance.weighted=FALSE)

######## Diversity metrics ##########
rn = renyi(sample.dat, hill=TRUE)
unit = 5
pdf('ecology_diversity.pdf',height=unit,width=length(rownames(sample.dat))*unit)
	plot(rn, layout=c(length(rownames(sample.dat)), 1),ylab='Diversity',xlab='Order of diversity')
dev.off()

####### species overlap ########
library(VennDiagram)
if (length(rownames(sample.dat)) < 5 ) {
  conditions = list()
  for (row in rownames(sample.dat)) {
    conditions[[row]] = colnames(sample.dat)[which(sample.dat[row,1:length(sample.dat)]>0)]
  }
  venn.diagram(conditions,
                scaled = FALSE,
                filename='venn.tiff')
}
