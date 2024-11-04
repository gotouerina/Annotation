# RepeatElements Annotation

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

Then

    mkdir Un_ltr
    mkdir Un_rnd
    python3 /data/01/p1/user192/software/DeepTE/DeepTE.py -d working_ltr -o Un_ltr -i ltr_unknown.fa -sp M -m_dir /data/01/user214/RepeatWork/10.annotation/Parascalops/Metazoans_model  -fam LTR
    python3 /data/01/p1/user192/software/DeepTE/DeepTE.py -d working_rnd -o Un_rnd -i rnd_unknown.fa -sp M -m_dir /data/01/user214/RepeatWork/10.annotation/Parascalops/Metazoans_model 

    cd Un_Ltr; perl reclass.pl opt_DeepTE.fasta > ltr.fasta
    cd Un_rnd; perl reclass.pl opt_DeepTE.fasta > rnd.fasta
    cat Un_rnd/rnd.fasta Un_Ltr/ltr.fasta known.fa > recalss.families.fa
    

## 03.RepeatMasker

    RepeatMasker $fasta -lib recalss.families.fa -e rmblast -xsmall -s -gff -pa 20

# Denovo Prediction

##   01.Augustus

        mkdir fa-split; cd fa-split
        ln -s /path/to/$soft_mask
        perl split.pl $soft_mask && rm $soft_mask
        for i in fa-split/*.fa; do echo -e "/data/00/software/augustus/augustus-3.3.3/bin/augustus --softmasking=1 --species=human  $i > $i.out" >> augustus.sh; done #submit to slurm
        for i in fa-split/*.out; do echo -e "perl /data/01/user157/utils/ConvertFormat_augustus.pl $i  $i.gff" >> augustus2.sh ; done #submit to slurm
        cat fa-split/*.gff > augustus.gff3

##    02.GlimmerHmm (if you annotate animal genome, please ignore this step)

        for i in fa-split/*.fa; do echo -e "/data/00/software/GlimmerHMM/GlimmerHMM/bin/glimmerhmm_linux_x86_64   $i  -d /data/00/software/Gl2/software/genscan/HumanIso.simmerHMM/GlimmerHMM/trained_dir/human    -g  -o $i.gff" >> glimmerhmm.sh; done
        cat fa-split/*.gff > glimmerhmm.gff3
        perl /data/01/user203/project/guohuai/03.gene_predict/utils/ConvertFormat_glimmerhmm.pl  glimmerhmm.gff3 glimmerhmm.final.gff3
        
##    03.GenScan

        perl split_genescan.pl $soft_mask  genscan_temp 3000000
        for i in genscan_temp/*.fa; do echo -e " /data/00/user/user112/software/genscan/genscan /data/00/user/user112/software/genscan/HumanIso.smat   $i > $i.genescan "  >> genscan.sh; done #submit to slurm
        for i in genscan_temp/*.genescan; do echo -e "perl  /data/01/user194/yxj/shutu/yxj/01annotion/jiaoben/ConvertFormat_genscan.pl $i > $i.gff" >> genscan2.sh; done #submit to slurm
        cat genscan_temp/*.gff > genescan.raw.gff3
        cat genescan.raw.gff3 | perl -F'\t' -alne '$_ =~ m/(-.*)\s+genscan/; s/$1//g; print' >  genescan.final.gff3 

# Homology Prediction

         source /data/00/user/user157/miniconda3/bin/activate ; conda activate GeMoMa
         java -jar -Xmx80g /data/00/user/user157/miniconda3/envs/GeMoMa/share/gemoma-1.7.1-0/GeMoMa-1.7.1.jar CLI GeMoMaPipeline threads=40  t=$soft_mask   s=own  g=$ref.fasta  a=$ref.prefix   outdir=$out_dir     AnnotationFinalizer.r=NO tblastn=false  ## do this for at least three species!
         cd  $out_dir
         perl /data/01/user203/project/guohuai/03.gene_predict/utils/ConvertFormat_GeMoMa.pl  final_annotation.gff


# Transcript Prediction

        /data/00/software/hisat/hisat2-2.1.0/hisat2-build $soft_mask $index
        /data/00/software/hisat/hisat2-2.1.0/hisat2 --dta -p 20 -x $index -1 $R1.fq.gz  -2 $R2.fq.gz  | /data/00/software/samtools/samtools-1.15.1/samtools  sort -@ 10 >  trans.bam
        /data/00/software/stringtie/stringtie-2.2.1/stringtie -p 10 -o merged.gtf trans.bam
        /data/00/software/TransDecoder/TransDecoder-TransDecoder-v5.5.0/util/gtf_to_alignment_gff3.pl merged.gtf > transcripts.gff3
        /data/00/software/TransDecoder/TransDecoder-TransDecoder-v5.5.0/util/gtf_genome_to_cdna_fasta.pl merged.gtf  $soft_mask  > transcripts.fasta
        /data/00/software/TransDecoder/TransDecoder-TransDecoder-v5.5.0/TransDecoder.LongOrfs -t transcripts.fasta
        /data/00/software/TransDecoder/TransDecoder-TransDecoder-v5.5.0/TransDecoder.Predict -t trafnscripts.fasta
        /data/00/software/TransDecoder/TransDecoder-TransDecoder-v5.5.0/util/cdna_alignment_orf_to_genome_orf.pl transcripts.fasta.transdecoder.gff3  transcripts.gff3   transcripts.fasta  > transcripts.fasta.transdecoder.genome.gff3

And Pasapipeline is needed to be used for annotation 

        $PASAHOME/bin/seqclean  transcripts.fasta
        $PASAHOME/Launch_PASA_pipeline.pl \
           -c alignAssembly.config -C -R -g genome.fasta \
           -t all_transcripts.fasta.clean -T -u all_transcripts.fasta \
            --ALIGNERS blat,gmap --CPU 10
        And sample_mydb_pasa.pasa_assemblies.gff3 would be used in annotation


#    EvidenceModerler Merge

        cat transcripts.fasta.transdecoder.genome.gff3 genescan.final.gff3  glimmerhmm.final.gff3 augustus.gff3 > denovo.gff3
        cat $out_dir1/final_annotation.gff.for.evm  $out_dir2/final_annotation.gff.for.evm $out_dir3/final_annotation.gff.for.evm > homology.gff3
        /data/01/user214/RepeatWork/10.annotation/GSmole/08.EVM/EVidenceModeler-v2.1.0/EVidenceModeler  --genome $mask_soft.fasta  --sample_id $prefix  --gene_predictions denovo.gff3 --protein_alignments homology.gff3    --transcript_alignments transcripts.gff3   --segmentSize 1000000   --overlapSize 100000 --cpu 20 --weights weights.txt

#    Function Annotation

        diamond blastp -q $prefix.EVM.pep   -d uniprot_sprot.dmnd  -o diamond_output --evalue 1e-05  -p 10 --max-target-seqs 1
        
                

