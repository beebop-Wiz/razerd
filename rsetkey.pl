#!/usr/bin/perl

use strict;
use Time::HiRes qw(usleep);

chdir '~/.rsetkey';

my $file = "rsetkey.cfg";

my %cfvars;
my @rgb;


sub set_var {
    my $var = shift;
    my $r = shift;
    my $g = shift;
    my $b = shift;

    die "Unknown variable $var" unless exists $cfvars{$var};
    if($cfvars{$var}{"type"} eq "key") {
	$rgb[$cfvars{$var}{"row"}][$cfvars{$var}{"col"} * 3] = $r;
	$rgb[$cfvars{$var}{"row"}][$cfvars{$var}{"col"} * 3 + 1] = $g;
	$rgb[$cfvars{$var}{"row"}][$cfvars{$var}{"col"} * 3 + 2] = $b;
	#	print "$var [$r $g $b]\n";
    } elsif($cfvars{$var}{"type"} eq "list") {
	foreach my $subvar (@{$cfvars{$var}{"vars"}}) {
	    set_var($subvar, $r, $g, $b);
	}
    }
}

sub parse_file {
    my $file = shift;

    my $varspec = '([_a-zA-Z][_a-zA-Z0-9]*)';
    my $keyspec = '([0-9]+)\s*:\s*([0-9]+)';
    my $rgbspec = '\[\s*([0-2]?[0-9]?[0-9])\s+([0-2]?[0-9]?[0-9])\s+([0-2]?[0-9]?[0-9])\s*\]';
    while(<$file>) {
	chomp $_;
	#	print "> $_\n";
	if($_ =~ /$varspec\s*=\s*$keyspec/) {
	    $cfvars{$1} = {"type" => "key", "row" => $2, "col" => $3};
	    #	    print "$1 = $2 : $3\n";
	} elsif($_ =~ /$varspec\s+$rgbspec/) {
	    set_var($1, $2, $3, $4);
	} elsif($_ =~ /$varspec\s*=\s*((?:$varspec\s+)*$varspec)/) {
	    $cfvars{$1} = {"type" => "list", "vars" => [split /\s+/, $2]};
	    #	    print "$1 = " . (join " ", @{$cfvars{$1}{"vars"}}) . "\n";
	} elsif($_ =~ /include\s+(.*)/) {
	    my $fh;
	    open $fh, $1;
	    #	    print "include $1\n";
	    parse_file($fh);
	    close $fh;
	}
    }
}


sub load_colorscheme {
    my $file = shift;
    my $input;
    open $input, $file or die "Couldn't open $file: $!";

    my $ncol = 16;
    my $nrow = 6;

    for(my $i = 0; $i < $nrow; $i++) {
	$rgb[$i] = [(0, 0, 0) x $ncol];
    }

    parse_file($input);

    #print Dumper(%cfvars);

    my $ri = 0;

    foreach my $row (@rgb) {
	my $command_string = chr($ri++) . chr(0) . chr ($ncol - 1) . join "", map chr, @$row;
	open MCF, ">/sys/bus/hid/devices/0003:1532:020F.0003/matrix_custom_frame" or die "Couldn't write layout: $!";
	binmode MCF;
	binmode STDOUT;
	print MCF $command_string;
	#    print $command_string;
	open MEC, ">/sys/bus/hid/devices/0003:1532:020F.0003/matrix_effect_custom" or die "Couldn't set custom: $!";
	print MEC "\n";
	close MCF;
	close MEC;
	usleep(50000);
    }
}

sub set_profile {

    my $title = shift;
    
    my $fh;
    open $fh, $file;
    my $last;
    open $last, "/tmp/windowswitch";
    my $ltitle = <$last>;
    return if $ltitle eq $title;
    close $last;
    open $last, ">/tmp/windowswitch";
    print $last $title;
    

    while(<$fh>) {
	chomp;
	my @fields = split /:/;
	my $name_regex = $fields[0];
	my $colorscheme = $fields[1];
	if($title =~ /$name_regex/) {
	    load_colorscheme($colorscheme);
	    return;
	}
    }

    load_colorscheme("default.cm");
    close $fh;
}

my $xprop;
open $xprop, "xprop -root -spy|";

while(<$xprop>) {
    if(/_NET_ACTIVE_WINDOW\(WINDOW\): window id # (0x[0-9a-f]+)/) {
	my $name = `xdotool getwindowname $1`;
	set_profile($name);
    }
}
