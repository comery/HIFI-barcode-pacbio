#!/usr/bin/perl -w
use strict;

die "Usage: perl $0 <ccs_passes_15.lst> <data/reads_of_insert.fasta>" unless (@ARGV == 2);

my %hash;
open LIST, shift;
while (<LIST>) {
	chomp;
	$hash{$_} = 1;
}

open FA,shift;
$/=">";<FA>;$/="\n";
while (my  $id = <FA>){
	chomp $id;
	$/=">";
	my $seq = <FA>;
	chomp $seq;
	print ">$id\n$seq" if (exists $hash{$id});
	$/="\n";
}

close LIST;
close FA;


