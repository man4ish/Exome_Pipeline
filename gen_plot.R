coverage<-read.table ("sorted.coverage",header=FALSE)
library(reshape)
coverage.new<-rename(coverage,c(V1="Chr", V2="locus", V3="depth"))

png(filename = "target_hist.png", width = 480, height = 480)
hist(coverage.new$depth,xlim=c(0,300),breaks=300,col="blue", main="Histogram", xlab="Sequence depth")
dev.off();

png(filename = "coverage.png", width = 480, height = 480);
plot(ecdf(coverage.new$depth),main="Coverage Plot", col="red", xlab="Cumulative coverage depth")
dev.off()
