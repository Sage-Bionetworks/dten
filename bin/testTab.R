#!/usr/bin/env Rscript

library(synapser)
synLogin()

df<- data.frame(Name = c("foo", "arg", "zap", "bah", "bnk", "xyz"),  Chromosome = c(1, 2, 2, 1, 1, 1),  Start = c(12345, 20001, 30033, 40444, 51234, 61234),  End = c(126000, 20200, 30999, 41444, 54567, 68686), Strand = c("+", "+", "-", "-", "+", "+"),TranscriptionFactor = c(F, F, F, F, T, F))

parid='syn16941818'
tbl=synStore(synapser::synBuildTable(values=df,name='test table',parid))
synDelete(tbl$schema)
