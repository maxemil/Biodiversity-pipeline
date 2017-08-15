#! /usr/bin/Rscript

########### Guilds #######################
samples = read.csv("$funguild",
                    header=F, sep="\\t", row.names=NULL,
                    col.names=c("Guild", "Count"))

samples = samples[order(samples\$Count),]

unassigned = samples\$Guild %in% c('Unassigned')
samples <- rbind(samples[unassigned,], samples[!unassigned,])

labels = sprintf("%s (%s)", samples\$Guild, samples\$Count)

pdf("${funguild}.pdf", height=10, width=10)
  dotchart(samples\$Count, label=labels, pch=20, xlab='# of species')
dev.off()
