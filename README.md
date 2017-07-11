*HIFI-BARCODES-PACBIO-PIPELIN* User's Guide

===================================================
========= Requirements ============================
===================================================
(1) software 
 -PicBio smrtanalysis | http://www.pacb.com/products-and-services/analytical-software/smrt-analysis/

(2) programming language
 - standard perl
 - standard python(python2 is ok)

(3) perl module
 - Bio::Perl( exactlly Bio::Seq )

(4) main perl and python scripts in scr/
 - 1.primer_like_extract.pl
 - 2.cluster_count_passes_length.pl
 - ccs_passes.py | download from: https://github.com/PacificBiosciences/Bioinformatics-Training/raw/master/scripts/ccs_passes.py
 - fish_ccs.pl

--------------------------------------------------
DATA requirements:

(1) pacbio original H5 file input
 - 01.data/
 	-*.h5
(2) primers list
 -	primer.lst
	primer.lst  like this:
 			for     GGTCAACAAATCATAAAGATATTGG
			rev     TAAACTTCAGGGTGACCAAAAAATCA
(3) index(barcodes for identifying samples) list
 -  index.xls
	index.xls like this:
			001     AAAGC
			002     AACAG
			003     AACCT
			004     AACTC
			005     AAGCA
			006     AAGGT
			007     AAGTG
			008     AATGG

===================================================
=========== Overview of steps =====================
===================================================

If you installed PacBio smrtanalysis, I suppose you know the  setup.sh path, 
more about Pacbio Data : http://www.pacb.com/wp-content/uploads/SMRT-Link-User-Guide-v4.0.0.pdf
e.g.
setup_path='/path/PicBio/smrtanalysis/current/etc/setup.sh'

#---------------------------step 1 extract CCS from h5 files-----------------------------
Input:
	- my_inputs.fofn
Output:
	-- log
	 |
	 |_data--*.ccs.fasta
	 |      |_*.ccs.fastq
	 |      |_*.ccs.h5
	 |      |_reads_of_insert.fasta
	 |      |_reads_of_insert.fastq
	 |      |_slots.pickle
	 |
	 |_workflow
	 |
	 |_results

 my_inputs.fofn contains files list of Pacbio H5 file in 01.data/
 like this:
 	./01.data/m170506_092957_42199_c101149142550000001823255607191735_s1_p0.1.bax.h5
	./01.data/m170506_092957_42199_c101149142550000001823255607191735_s1_p0.bas.h5
	./01.data/m170506_092957_42199_c101149142550000001823255607191735_s1_p0.3.bax.h5
	./01.data/m170506_092957_42199_c101149142550000001823255607191735_s1_p0.2.bax.h5

run:
source $setup_path
fofnToSmrtpipeInput.py my_inputs.fofn > my_inputs.xml
smrtpipe.py --params=settings.xml xml:input.xml

#---------------------------step 2 extract passes number from CCS h5 files---------------
Input:
	- /data/*.ccs.h5 
Output:
	- ccs_passes.lst

run:
source $setup_path
python scr/ccs_passes.py  data/*.ccs.h5 >ccs_passes.lst

#---------------------------step 3 filtering CCS by passes number (>15)------------------
Input:
	- ccs_passes.lst
	- data/reads_of_insert.fasta
Output:
	- ccs_passes_15.fa

run:
awk '$2>=15{print $1}' ccs_passes.lst >ccs_passes_15.lst
perl ./scr/fish_ccs.pl ccs_passes_15.lst data/reads_of_insert.fasta >ccs_passes_15.fa

#---------------------------step 4 assigning CCS  to samples by index--------------------
Input:
	- primer.fa
	- index.xls
	- ccs_passes_15.fa
Output: "outdir" name is up to you, here is 02.assignment/
	- 02.assignment/
					|_assign.log.txt
					|
					|_ccs.successfully_assigned.fa
					|
					|_check.ccs_passes_15.fa.log

run:
perl ./scr/primer_like_extract.pl -p ./primer.fa -index ./index.xls -fa ccs_passes_15.fa -cm 2 -cg 1 -o outdir

#---------------------------step 5 clustering CCS of each sample to find best one-------
Input:
	- ccs.successfully_assigned.fa
	- check.ccs_passes_15.fa.log
	- ccs_passes.lst
Output:
	- cluster.top1.fas
	- cluster.id.txt
	- cluster.all.fa

run:
Change to 02.assignment/ and run:
perl ../scr/cluster_lens_count.pl -ccs ../ccs_passes_15.fa -pattern check.ccs_passes_15.fa.log -passes ccs_passes.lst

ALL DONE!
---------------------------------------------------------------------------------------------------------------
So, cluster.top1.fas is final result!


