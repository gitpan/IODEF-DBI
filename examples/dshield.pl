#!/usr/bin/perl -w

die 'script not finished';

use strict;
use lib './lib';
use Error qw(:try);
use Data::Dumper;
use Net::Abuse::Utils qw(:all);

my $file = '/tmp/dshield.txt';
my $site_ref = 'http://feeds.dshield.org/block.txt';

#system('wget --quiet http://feeds.dshield.org/block.txt -O '.$file) == 0 or die "system wget failed: $?";

open(F,$file);
my $n = 0;
while (<F>){
    next if($_ =~ /^(#|Start|\s+)/);
    my @a = split(/\s+/,$_);
    my $addr = $a[0].'/'.$a[2];
  
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

