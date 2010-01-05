#!/usr/bin/perl -w
use lib './lib';

die 'script not finished';

use strict;
use XML::RSS;
use LWP::Simple;
use Data::Dumper;
use Net::Abuse::Utils qw(:all);
use Regexp::Common qw/net/;

my $rep = '-2';
my $content;
my $file;

my $rss = XML::RSS->new();
my $url = 'https://zeustracker.abuse.ch/rss.php';


$content = get($url);
$rss->parse($content);

foreach my $item (@{$rss->{items}}){
    my ($host,$addr,$sbl,$status,$level,$as,$country) = split(/,/,$item->{description});
    $host =~ s/Host: //;
    $addr =~ s/ IP address: //;
    $as =~ s/ AS: //;
    $country =~ s/ country: //;
    my $guid = $item->{guid};
    my @recs = search(tag => $guid);
    unless(@recs){
        my $id;
        if($addr){
            $id = insert_address($addr,'-2');
            insert_tag('zeus',$id);
            insert_link($guid,$id);
        }
        my $hid = insert_domain($host,'-2',$id);
        insert_tag('zeus',$hid);
        insert_link($guid,$hid);
        warn 'inserted: '.$host;
    }
}

$content = get('https://zeustracker.abuse.ch/monitor.php?urlfeed=binaries');
$rss->parse($content);

foreach my $item (@{$rss->{items}}){
    my ($url,$status,$hash) = split(/,/,$item->{description});
    $url =~ s/URL: //;
    $status =~ s/ status: //;
    $hash =~ s/ MD5 hash: //;
    my $r = '-2';
    my $guid = $item->{guid};
    if($status eq 'offline'){ $r = '-1'; }
    my @recs = search(tag => $guid);
    unless(@recs){
        my $id = insert({
            category    => 'url',
            reputation  => $r,
            url         => $url,
            hash        => $hash,
            hashtype    => 'MD5',
            restriction => 'public',
        });
        warn 'inserted: '.$guid;
        my $lid = insert_link($guid,$id);
    }
}

$content = get('https://zeustracker.abuse.ch/removals.php?show=rss');
$rss->parse($content);

foreach my $item (@{$rss->{items}}){
    my ($host,$as,$asname,$desc) = split(/,/,$item->{description});
    $host =~ s/Host: //;
    my $guid = $item->{guid};
    my @recs = search(tag => $guid);
    unless(@recs){
        warn 'inserting: '.$host;
        if($host =~ /$RE{net}{IPv4}/){
            my $id = insert_address($host,0,$desc);
            insert_link($guid,$id);
        } else {
            my $id = insert_domain($host,0,undef,$desc);
            insert_link($guid,$id);
        }
    }
}

sub insert_address {
    my $addr = shift;
    my $r = shift;
    my $comments = shift;
    my ($as,$network,$ccode,$rir,$date) = get_asn_info($addr);
    my $desc;
    $desc = get_as_description($as) if($as);
    $as         = undef if(uc($as) eq 'NA');
    $network    = undef if(uc($network) eq 'NA');
    $ccode      = undef if(uc($ccode) eq 'NA');
    $rir        = undef if(uc($rir) eq 'NA');
    $date       = undef if(uc($date) eq 'NA');
    warn 'inserting '.$addr;
    return $aid;
}

sub insert_domain {
    my $host = shift;
    my $r = shift;
    my $id = shift;
    my $comments = shift;
    return $did;
}
