# Breeding Experiment- Mate Choice

## analysis notes

Analysis of reproduction. ie, fertilizaiton, hatching, etc. for both choice and no choice:
`reproduction_analysis.R`


Analysis of mate choice.
`mate_choice.R`


## Analyze environmental parameters

All data from https://eyesonthebay.dnr.maryland.gov/bay_cond/LongTermData.cfm

The stations used are: 

BW population, Point lookout: LE2.3	Lower Potomac River	Point Lookout	38.0215	-76.3477	1984 - 2022
FW population:, Piscataway Park:  TF2.1	Middle Potomac River	Off Piscataway	38.7065	-77.0486	1986 - 2022

And raw data is found in: `data/environmental_params.csv`

With analysis found: `environmental_params.R`

# Genetic analysis

if you're replicating this analysis, you can skip down to `Align to genome`. These initial steps are just processing the raw data.

downloaded on 2017-03-28. `download.sh`

## add to NCBI

BioProject ID:      PRJNA872341

`sra_upload.sh`

## demultiplex
 
need to demultiplex, rename. 

demultiplex, leaving rad site:
- `demultiplex.sh`
- `count.demultiplex.sh`

Rename all individuals

`rename_generate.R`

than 

`rename.sh`


# Align to genome 

mark duplicates, align using bwa-mem 0.7.12.

`bwa.align.sh`


# check coverage

generate bed file to check coverage of first read only, using only the 20th base in the probe.

```bash
cat MUMMICHOG-probes-120-stringent.bed | cut -f 1 | sed 's/:/  /g' | awk 'BEGIN { OFS = "\t" }{gsub("-","_",$1)}1' | awk 'BEGIN { OFS = "\t" }{gsub("-","\t",$2)}1' | cut -f 1-2 | awk 'BEGIN { OFS = "\t" }{print $1, ($2+19)}' | awk 'BEGIN { OFS = "\t" }{print $1, $2, ($2 + 1)}'  > probes.20pos.bed

```

calculate coverage at each probe across all individuals:

`coverage.probe.sh`


Calculate coverage for each individual. use 20th base in bed file as above. 

## number of reads per indiv

`coverage.indiv.sh`

then analyze with:
`coverage.indiv.R`


Look at the effect of gc content

```bash
cd ~/Documents/Breeding_2015/rapture/design-results-new

cat MUMMICHOG-probes-120-filtration.txt | awk '$11 == "pass"' |cut -f 1-2 > gc_content.txt


```

```r
library(scales)
coverage <- read.table(~"~/Documents/Breeding_2015/rapture/coverage.probe.txt", header=FALSE)
gc <- read.table("~Documents/Breeding_2015/rapture/gc_content.txt", header=FALSE)

df <- data.frame(
			scaffold=coverage$V1,
			start=coverage$V2,
			stop=coverage$V3,
			cover=coverage$V4,
			ac=(100-gc$V2))


pdf("~/Documents/Breeding_2015/Figures/GC_content_coverage.pdf")
plot(df$ac, df$cover/500,
	col=alpha('black', 0.5), pch=19, 
	ylab='coverage', xlab='Bait AC content')
dev.off()



```

indiv coverage

```r
setwd("~/breeding/summary_files/coverage/")
print(files <- list.files(pattern="BW-Combo1"))
print(labs <- gsub("\\.bam|\\.depth\\.txt", "", files, perl=TRUE))

cov <- list()
cov_cumul <- list()
for (i in 30:length(files)) {
    cov[[i]] <- read.table(files[i])
    cov_cumul[[i]] <- matrix(ncol=2, nrow=nrow(cov[[i]])) 
    cov_cumul[[i]][,1] <- cov[[i]][,2]
    cov_cumul[[i]][,2] <- 1-cumsum(cov[[i]][,5])
}

library(RColorBrewer)
cols <- brewer.pal(length(cov), "Dark2")

plot(cov[[30]][, 2], cov_cumul[[30]][,2], type='n', xlab="Depth", ylab="Fraction of capture target bases \u2265 depth", ylim=c(0,1.0), main="Target Coverage")
abline(v = 20, col = "gray60")
abline(v = 50, col = "gray60")
abline(v = 80, col = "gray60")
abline(v = 100, col = "gray60")
abline(h = 0.50, col = "gray60")
abline(h = 0.90, col = "gray60")
axis(1, at=c(20,50,80), labels=c(20,50,80))
axis(2, at=c(0.90), labels=c(0.90))
axis(2, at=c(0.50), labels=c(0.50))


for (i in 200:238) points(cov[[i]][, 2], cov_cumul[[i]][,2], type='l', lwd=3, col=cols[i])

# Add a legend using the nice sample labeles rather than the full filenames.
legend("topright", legend=labs[1:8], col=cols, lty=1, lwd=4)


#look at prop of samples with specific coverages


coverage <- matrix(nrow=100, ncol=length(cov))

for (indiv in 1:length(cov)){
	for (i in 1:100){
		a <- which(cov_cumul[[indiv]][,1] == i)
		if (length(a) > 0){
			coverage[i,indiv]<- cov_cumul[[indiv]][a,2]
		}
		else{}
	}
}

pdf("~/breeding/summary_files/avg_probe_coverage.pdf", width=10, height=7)
par(mar=c(5,6,4,2))
boxplot(coverage, row=1:100, use.cols=FALSE, outpch=NA,
	boxlty = 1, boxlwd= 0.9,
	whisklwd= 0.4,
	xlab="Coverage",
	ylab="average proportion of probes exceeding \n specified coverage")

dev.off()

```

## call variants

call all variants:

`freebayes.bw.combo1.sh`, repeat for all. These are found under `freebayes/`

merge variants, bc split by scaffold at this point.

`cat.var.sh`

- FW-Combo1: 59510
- FW-Combo2: 56963
- FW-Combo4: 77265
- FW-Combo5: 85706
- BW-Combo1: 76084
- BW-Combo2: 74982
- BW-Combo3: 89765
- BW-Combo4: 84812
- BW-Combo5: 45367


### Filter vcf for quality

minimum genotype quality=30
biallelic spns only
min  depth=10
max depth=110
max missing prop= 0.9
remove missing indivs- 117 offspring with < 5x coverage. 3 parents below this cutoff, but not removed. 

`filter.1.sh`

snps remaining:
- FW-Combo1: 5957
- FW-Combo2: 5397
- FW-Combo4: 5581
- FW-Combo5: 5611
- BW-Combo1: 5047
- BW-Combo2: 4941
- BW-Combo3: 5786
- BW-Combo4: 5236
- BW-Combo5: 6567
- all: 2627

calculate missing per indiv

`missing.sh`

### filter by parents to get rid of monomorphic sites

first make vcf with only parents. 

`filter.2.sh`

- FW-Combo1: 5202
- FW-Combo2: 5014
- FW-Combo4: 5033
- FW-Combo5: 5400
- BW-Combo1: 4040
- BW-Combo2: 4210
- BW-Combo3: 5088
- BW-Combo4: 4756
- BW-Combo5: 5825
- all: 2347 #### this is the total number of snps for the popgen, etc.

```bash
zcat ~/breeding/variants/BW-Combo1.parent.vcf.gz | grep -v '^#' | cut -f 1-2 > ~/breeding/variants/parent.BW-Combo1.snp
zcat ~/breeding/variants/BW-Combo2.parent.vcf.gz | grep -v '^#' | cut -f 1-2 > ~/breeding/variants/parent.BW-Combo2.snp
zcat ~/breeding/variants/BW-Combo3.parent.vcf.gz | grep -v '^#' | cut -f 1-2 > ~/breeding/variants/parent.BW-Combo3.snp
zcat ~/breeding/variants/BW-Combo4.parent.vcf.gz | grep -v '^#' | cut -f 1-2 > ~/breeding/variants/parent.BW-Combo4.snp
zcat ~/breeding/variants/BW-Combo5.parent.vcf.gz | grep -v '^#' | cut -f 1-2 > ~/breeding/variants/parent.BW-Combo5.snp
zcat ~/breeding/variants/FW-Combo1.parent.vcf.gz | grep -v '^#' | cut -f 1-2 > ~/breeding/variants/parent.FW-Combo1.snp
zcat ~/breeding/variants/FW-Combo2.parent.vcf.gz | grep -v '^#' | cut -f 1-2 > ~/breeding/variants/parent.FW-Combo2.snp
zcat ~/breeding/variants/FW-Combo4.parent.vcf.gz | grep -v '^#' | cut -f 1-2 > ~/breeding/variants/parent.FW-Combo4.snp
zcat ~/breeding/variants/FW-Combo5.parent.vcf.gz | grep -v '^#' | cut -f 1-2 > ~/breeding/variants/parent.FW-Combo5.snp
zcat ~/breeding/variants/all.parent.vcf.gz | grep -v '^#' | cut -f 1-2 > parent.all.snp
```


### use parent list to pull out snps from 

`filter.3.sh`

same numbers as from `filter.2.sh`

### Convert to plink:

pruned by ld: `toplink.sh`

snps remaining after ld filter
- FW-Combo1: 2491
- FW-Combo2: 2246
- FW-Combo4: 2300
- FW-Combo5: 2474
- BW-Combo1: 2122
- BW-Combo2: 2006
- BW-Combo3: 2305
- BW-Combo4: 2103
- BW-Combo5: 2603
- all: 1606



#### subset all to the different combos

Use the snp set found across all individuals, subset down.

FW-Combo5-PL-F-8 needs to be removed because it appears to be mis-labeled. 

`subset.sh`



# PCA

use all, pull out only parents. then run pca. 

from all file, grep out parents

`pca.sh`

`pca.R`



# fst

from file: `~/breeding/variants/all.parent.vcf.gz`

get individuals for groupings

```bash

zcat ~/breeding/variants/all.parent.vcf.gz | grep '^#' | tail -n 1 | cut -f 10- |sed 's/\t\t*/\n/g' | grep 'PP' > ~/breeding/scripts/pp.indivs

zcat ~/breeding/variants/all.parent.vcf.gz | grep '^#' | tail -n 1 | cut -f 10- |sed 's/\t\t*/\n/g' | grep 'PL' > ~/breeding/scripts/pl.indivs

```

`fst.sh`


# colony: 


 prepare an input file called “Colony2.dat” which includes all of the parameter values and contains all of the data required by Colony program.

 the same data as for the Windows GUI mode described in section 3 are required. However, the difference is that all the data must be put in a single pure text input file in the following order and format. 



use the following R package: `https://github.com/thierrygosselin/stackr/blob/master/R/write_colony.R`


```bash
scp -P 2022 'rsbrenna@farm.cse.ucdavis.edu:/home/rsbrenna/breeding/variants/*.tfam' ~/Documents/Breeding_2015/colony/
scp -P 2022 'rsbrenna@farm.cse.ucdavis.edu:/home/rsbrenna/breeding/variants/*.tped' ~/Documents/Breeding_2015/colony/

cd ~/Documents/Breeding_2015/colony

# convert to numbered format
sed -i '' 's/A/01/g' *.tped
sed -i '' 's/C/02/g' *.tped
sed -i '' 's/G/03/g' *.tped
sed -i '' 's/T/04/g' *.tped


# reformatting the fam files to include pop in first column.
awk 'BEGIN{OFS=" "}{print substr($1,1,9),$2,$3,$4,$5,$6}' all.tfam > all.tfam.1
awk 'BEGIN{OFS=" "}{print substr($1,1,9),$2,$3,$4,$5,$6}' BW-Combo1.tfam > BW-Combo1.tfam.1
awk 'BEGIN{OFS=" "}{print substr($1,1,9),$2,$3,$4,$5,$6}' BW-Combo2.tfam > BW-Combo2.tfam.1
awk 'BEGIN{OFS=" "}{print substr($1,1,9),$2,$3,$4,$5,$6}' BW-Combo3.tfam > BW-Combo3.tfam.1
awk 'BEGIN{OFS=" "}{print substr($1,1,9),$2,$3,$4,$5,$6}' BW-Combo4.tfam > BW-Combo4.tfam.1
awk 'BEGIN{OFS=" "}{print substr($1,1,9),$2,$3,$4,$5,$6}' BW-Combo5.tfam > BW-Combo5.tfam.1
awk 'BEGIN{OFS=" "}{print substr($1,1,9),$2,$3,$4,$5,$6}' FW-Combo1.tfam > FW-Combo1.tfam.1
awk 'BEGIN{OFS=" "}{print substr($1,1,9),$2,$3,$4,$5,$6}' FW-Combo2.tfam > FW-Combo2.tfam.1
awk 'BEGIN{OFS=" "}{print substr($1,1,9),$2,$3,$4,$5,$6}' FW-Combo4.tfam > FW-Combo4.tfam.1
awk 'BEGIN{OFS=" "}{print substr($1,1,9),$2,$3,$4,$5,$6}' FW-Combo5.tfam > FW-Combo5.tfam.1
mv all.tfam.1 all.tfam
mv BW-Combo1.tfam.1 BW-Combo1.tfam
mv BW-Combo2.tfam.1 BW-Combo2.tfam
mv BW-Combo3.tfam.1 BW-Combo3.tfam
mv BW-Combo4.tfam.1 BW-Combo4.tfam
mv BW-Combo5.tfam.1 BW-Combo5.tfam
mv FW-Combo1.tfam.1 FW-Combo1.tfam
mv FW-Combo2.tfam.1 FW-Combo2.tfam
mv FW-Combo4.tfam.1 FW-Combo4.tfam
mv FW-Combo5.tfam.1 FW-Combo5.tfam

#scp -P 2022 'rsbrenna@farm.cse.ucdavis.edu:/home/rsbrenna/breeding/variants/*.parent.vcf' ~/Documents/Breeding_2015/colony/

#scp -P 2022 'rsbrenna@farm.cse.ucdavis.edu:/home/rsbrenna/breeding/variants/*.offspring.vcf' ~/Documents/Breeding_2015/colony/


```

make colony files:

had to do some funny installs for old packages to make this work.

```r

#devtools::install("/Users/rbrennan/Documents/Breeding_2015/stackr-0.4.6")
#install.packages("/Users/rbrennan/Documents/Breeding_2015/rmetasim_3.1.14.tar.gz", repos = NULL, type="source")

library(stackr)

setwd("~/Documents/Breeding_2015/colony/")
filelist = list.files(pattern = "*.tfam")
files <- substring(filelist, 1,9)
files[1] <- c("all")

for (i in files){

	write_colony(data=paste(i,".tped", sep=""),
  	whitelist.markers = NULL, monomorphic.out = FALSE, snp.ld = NULL,
  	common.markers = FALSE, maf.thresholds = NULL, maf.pop.num.threshold = 0,
  	maf.approach = "SNP", maf.operator = "OR", max.marker = NULL,
  	sample.markers = NULL, pop.select = NULL, allele.freq = NULL,
  	inbreeding = 1, mating.sys.males = 0, mating.sys.females = 0,
  	clone = 0, run.length = 2, analysis = 2, allelic.dropout = 0,
  	error.rate = 0.001, print.all.colony.opt = TRUE,
  	verbose = TRUE, parallel.core = parallel::detectCores() - 1,
  	filename = paste(i, ".colony", sep=""))
}

```

Then create colony input files using the following bash script.

make sure to run the following in bash, not zsh


```bash

cd ~/Documents/Breeding_2015/colony


for i in all BW-Combo1 BW-Combo2 BW-Combo3 BW-Combo4 BW-Combo5 FW-Combo1 FW-Combo2 FW-Combo4 FW-Combo5 all; do

	echo "starting $i"

	#pull out header
	cat ${i}.colony | head -n 26 > ${i}.head
	# pull out offspring
	cat ${i}.colony | grep 'Combo' | grep -v 'Output file name' | grep -v '\-M\-' | grep -v '\-F\-'  > ${i}.offspring
	# pull out male parents 
	cat ${i}.colony | grep '\-M\-' > ${i}.male
	cat ${i}.colony | grep '\-F\-' > ${i}.female

	# tail.txt is the ending for each

	# get number of males and females
	male=$(cat ${i}.male| wc -l)
	male_num=$(echo ${male} | cut -d' ' -f1)

	female=$(cat ${i}.female | wc -l)
	female_num=$(echo $female|cut -d' ' -f1)

	# subtract num males and females from total num in line 3:
	total_num=$(cat ${i}.head | sed -n '3p' | cut -f 1 -d " ")
	new_num=$(echo "$(($total_num - $female_num - $male_num))")

	# replace old number with new number
	sed -i '' "3s/$total_num/$new_num/"  ${i}.head

	# add empty line after all males.
	echo "" >> ${i}.male

	echo -e  "\n1 1                ! Prob. of dad/mum included in the candidates \n$male_num	 $female_num                    ! Numbers of candidate males & females \n"> ${i}.male.female

	cat ${i}.head ${i}.offspring ${i}.male.female ${i}.male ${i}.female tail.txt > ${i}.colony.dat

	sed -i '' "s/My first COLONY run/${i}.colony/g" ${i}.colony.dat
	sed -i '' "s/offspring.colony/colony/g" ${i}.colony.dat

	#change analysis to pairwise
	sed -i '' '20s/^1/0/' ${i}.colony.dat

	#remove intermediate files
	rm ${i}.male
	rm ${i}.female
	rm ${i}.head
	rm ${i}.offspring
	#rm ${i}.male.female

	echo "finished $i"


done

sed -i '' 's/NW_//g' *.colony.dat


```


all `*.colony.dat` files then need to be transferred to cluster

running colony

`colony.sh`


takes a while to run



# Colony Results


pairwise: PairwisePaternity, PairwiseMaternity
Full likelihood: .Paternity, all.colony.Maternity
Full likelihood parent pair: ParentPair


`colony_results_processing.R`



## mate choice

`calc_mateChoice.R`



# analyze reproduction data

`reproduction_analysis.R`

# analyze mate choce

`mate_choice_analysis.R`



