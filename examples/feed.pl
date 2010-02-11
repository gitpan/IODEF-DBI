#!/usr/bin/perl -w

use strict;

use lib './lib';
use XML::IODEF;
use XML::LibXML;
use IODEF::Message;
use IODEF::Idx_Address_Inet;

use Data::Dumper;

my @recs = IODEF::Idx_Address_Inet->search_created_days(21);

my $parser = XML::LibXML->new();
my $hash;
my $used;

my %used;
my $feed = 'address | system category | impact type | restriction | description | severity | confidence | expected action | report time | incident id | alternative id'."\n";
foreach my $rec (@recs){
    my $msg = IODEF::Message->retrieve(uuid => $rec->messageid());
    my $doc = $parser->parse_string($msg->message());

    my @nodes = $doc->findnodes('//Incident');
    foreach my $node (@nodes) {
        my $purpose = $node->getAttribute('purpose');
        my $restriction = $node->getAttribute('restriction') || 'private';
       
        # primary id
        my @ids = $doc->findnodes('//Incident/IncidentID');
        my $instance = $ids[0]->getAttribute('instance');
        my $id = $ids[0]->textContent();
        
        # alt id
        my @aids = $doc->findnodes('//Incident/AlternativeID/IncidentID');
        my $alt_instance = $aids[0]->getAttribute('instance');
        my $aid = $aids[0]->textContent();

        my $reporttime = $node->find('//ReportTime')->to_literal();
        my $desc = $node->find('//Description');
        my @impacts = $node->findnodes('//Assessment/Impact');
        my $severity = $impacts[0]->getAttribute('severity');
        my $type = $impacts[0]->getAttribute('type');
        if(lc($type) eq 'ext-value'){
            $type = $impacts[0]->getAttribute('ext-type');
        }
       
        my @confidence = $node->findnodes('//Assessment/Confidence');
        my $conf = $confidence[0]->getAttribute('rating') || 'low';
        if(lc($conf) eq 'numeric'){
            $conf = $confidence[0]->textContent();
        }

        my @actions = $node->findnodes('//Incident/EventData/Expectation/action');
        #my $action = $actions[0]->textContent() || 'investigate';
        my $action = 'investigate';

        my @systems = $node->findnodes('//EventData/Flow/System');
        foreach my $system (@systems){
            my $origin = $system->getAttribute('category') || '';
            my $sys_restriction = $system->getAttribute('restriction');
            my $sys_desc = $system->find('//System/Description');
            $desc = $sys_desc if($sys_desc);
            my @addresses = $system->findnodes('//Node/Address');
            my $addr_hash;
            foreach my $a (@addresses){
                my $addr = $a->textContent();
                my $a_cat = $a->getAttribute('category');
                push(@{$addr_hash->{$a_cat}},$addr);
            }
            my @addrs;
            if($addr_hash->{'ipv4-addr'}){
                @addrs = @{$addr_hash->{'ipv4-addr'}};
            } elsif (@addrs = @{$addr_hash->{'ipv4-net'}}){
                if($#addrs){ # simply looking for 'more-than-one'
                    my ($address,$mask) = split(/\//,$addrs[0]);
                    foreach my $x (1 ... $#addrs){
                        my ($a1,$m1) = split(/\//,$addrs[$x]);
                        if($m1 > $mask){
                            ($address,$mask) = ($a1,$m1);
                        }
                    }
                    @addrs = ($address.'/'.$mask);
                }
            }

            next unless(@addrs);

            foreach my $addr (@addrs){
                unless(exists($used{$addr})){
                    $feed .= $addr.' | '.$origin.' | '.$type.' | '.$restriction.' | '.$desc.' | '.$severity.' | '.$conf.' | '.$action.' | '.$reporttime.' | '.'https://'.$instance.'/id/'.$id.' | '.$aid."\n";
                    $used{$addr} = $id;
                }
            }
        }
    }
}
warn $feed;
