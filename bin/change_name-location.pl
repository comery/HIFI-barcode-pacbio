#!/usr/bin/perl -w 
use strict;
use FindBin '$Bin';
die "Usage: perl $0 <hiseq-vs-pb.all.fas> " unless (@ARGV == 1);
open IN,shift;
my %place;
open LA,"$Bin/../experiment_data/samples_location.tab" or die "$!";
while (<LA>) {
	chomp;
	my @aa = split;
	my $s = $aa[0];
	$s = sprintf ("%03d",$s);
	$place{$s} = $aa[1];
}


$/=">";<IN>;$/="\n";
while (<IN>) {
	chomp;
	my $id = $_;
	my @a = split /;/,$id;
	my @b = split /_/,$a[0];
	my $samp =  $b[0];
	$/=">";
	my $seq = <IN>;
	chomp $seq;
	if ($id =~ /size/) {
		print ">$place{$samp}_$b[1]\n$seq";
	}else {
		print ">$place{$samp}_$b[1] PB\n$seq";
	}

	$/ = "\n";
}


