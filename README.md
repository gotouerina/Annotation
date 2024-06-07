# RepeatElements

## 01. Repeatmoderer

    BuildDatabase  -name  $name  $fasta
    Repeatmodeler -pa 20 -database $name    -LTRStruct


## 02.DeepTE

    grep "ltr" consensi.fa.classified |grep "Unknown" > ltr_unknown.list
    grep "rnd" consensi.fa.classified |grep "Unknown" > rnd_unknown.list
    grep '>' Parascalop-families.fa  |  grep -v 'Unknown' > known.list
    perl extract.pl ltr_unknown.list $family.fa > ltr_unknown.fa
    perl extract.pl rnd_unknown.list $family.fa > rnd_unknown.fa
    perl extract.pl known.list $family.fa > known.fa

## 03.RepeatMasker

    RepeatMasker Parascalops.v3.fa  -lib recalss.families.fa -e rmblast -xsmall -s -gff -pa 20
