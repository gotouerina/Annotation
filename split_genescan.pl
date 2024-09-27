use strict;
use warnings;
use Bio::SeqIO;

my $file=shift;
my $outdir=shift;
my $minlen=shift // 'no';
die "perl $0 inputfile outputdir length\nFor the length paramenter means split contigs if it is too long. While setting to 'no' means no split\n" if (! $outdir);
`mkdir -p $outdir` if(!-e "$outdir");
my $in=Bio::SeqIO->new(-file=>$file,-format=>'fasta');
while(my $s=$in->next_seq){
	    my $id=$s->id;
	        my $seq=uc($s->seq);
		    $id=~s/\|/_/g;
		        my $len=length($seq);
			    if ($minlen eq "no"){
				            my $outfile="$outdir/$id.fa";
					            open(OUT,"> $outfile")||die("Cannot creat $outfile!\n");
						            print OUT ">$id\n$seq\n";
							            close OUT;
								        }elsif($len<=$minlen){
										        my $outfile="$outdir/$id.fa";
											        open(OUT,"> $outfile")||die("Cannot creat $outfile!\n");
												        print OUT ">$id\n$seq\n";
													        close OUT;
														    }else{
															            foreach (my $i=0;$i<$len;$i=$i+$minlen){
																	                my $seqlen=$minlen;
																			            $seqlen=$len-$i if $i+$minlen > $len;
																				                my $outfile="$outdir/$id-$i.fa";
																						            open(OUT,">$outfile")||die("Cannot creat $outfile!\n");
																							                my $newseq=substr($seq,$i,$seqlen);
																									            print OUT ">$id-$i\n$newseq\n";
																										                close OUT;
																												        }
																													    }
																												    }

