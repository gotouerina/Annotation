#! /usr/bin/perl
# Linux System Repeat Annotation Scripts for Animal
use File::Path;
mkpath("01.RepeatMasker");
mkpath("02.RepeatModeler");
mkpath("03.TRF");
mkpath("04.EDTA");
use strict;
use warnings;
my $genome = shift;
my $prefix = shift;
my $dir = `pwd`;
chomp $dir;
open O1, "> 01.RepeatMasker/masker.sh" or die "Usage: perl $0 $genome $prefix";
open O2, "> 02.RepeatModeler/modeler.sh" or die "Usage: perl $0 $genome $prefix";
open O3, "> 03.TRF/trf.sh" or die "Usage: perl $0 $genome $prefix";
open O4, "> 04.EDTA/edta.sh" or die "Usage: perl $0 $genome $prefix";
system("cd 01.RepeatMasker/; ln -s ../$genome ");
system("cd 02.RepeatModeler/; ln -s ../$genome");
system("cd  03.TRF; ln -s ../$genome");
system("cd 04.EDTA; ln -s ../$genome");
print O1 "singularity exec -B $dir ../Repeat.sif  RepeatMasker  -pa 30 -pa 30 -nolow -norna -no_is -gff -species rattus  $genome";
print O2 "singularity exec -B  $dir  ../Repeat.sif BuildDatabase -name $prefix $genome\nsingularity exec -B $dir/02.RepeatModeler ../Repeat.sif RepeatModeler -pa 50 -database $prefix\nsingularity exec -B $dir/02.RepeatModeler  ../Repeat.sif RepeatMasker genome -lib $prefix\-families.fa  -e rmblast -xsmall -s -gff -pa 30";
print O3 "singularity exec -B $dir ../Repeat.sif trf $genome  2 7 7 80 10 50 500 -f -d -m";
print O4 "singularity exec -B $dir  ../Repeat.sif EDTA.pl  --genome $genome -t 10  --species others --sensitive 0";
close O1;
close O2;
close O3;
close O4;
# Next, Merge the Gff file and 
# cat *.gff > all.gff
# sortBed -i all.gff > all.sort.gff
# bedtools merge -i all.sort.gff > all.mask.bed
# bedtools maskfasta -fi $genome  -bed all.mask.bed -soft -fo $prefix.softmask.fasta
