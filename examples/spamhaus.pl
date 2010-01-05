#!/usr/bin/perl -w

use strict;
use lib './lib';
use Error qw(:try);
use Data::Dumper;
use Net::Abuse::Utils qw(:all);

my $file = '/tmp/spamhaus_drop.txt';
my $site_ref = 'http://www.spamhaus.org/sbl/sbl.lasso?query=';

#system('wget --quiet http://www.spamhaus.org/drop/drop.lasso -O '.$file) == 0 or die "system wget failed: $?";

open(F,$file);
my $n = 0;
while (<F>){
    next if($_ =~ /^;/);
    next if($_ =~ /^\n/);
    my ($addr,$ref) = split(/ \; /,$_);
	$addr =~ s/(\n|\s+)//;
    $ref =~ s/\n$//;

    unless(@recs){

        my ($as,$network,$ccode,$rir,$date) = get_asn_info($addr);
        my $desc;
        $desc = get_as_description($as) if($as);
        $as         = undef if(uc($as) eq 'NA');
        $network    = undef if(uc($network) eq 'NA');
        $ccode      = undef if(uc($ccode) eq 'NA');
        $rir        = undef if(uc($rir) eq 'NA');
        $date       = undef if(uc($date) eq 'NA');

    }
}
close(F);

