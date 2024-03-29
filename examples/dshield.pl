#!/usr/bin/perl -w

use strict;
use lib './lib';
use Data::Dumper;
use XML::IODEF;
use IODEF::Message;
use DateTime;
use Net::Abuse::Utils qw(:all);
use IODEF::Idx_IncidentID;

my $file = '/tmp/dshield.txt';
my $site_ref = 'http://feeds.dshield.org/block.txt';

#system('wget --quiet http://feeds.dshield.org/block.txt -O '.$file) == 0 or die "system wget failed: $?";

open(F,$file);
my $n = 0;
while (<F>){
    next if($_ =~ /^(#|Start|\s+)/);
    my @a = split(/\s+/,$_);
    my $addr = $a[0].'/'.$a[2];

    my $dt = DateTime->from_epoch(epoch => time());

    my $id = $addr.'_'.$dt->ymd();

    my @recs = IODEF::Idx_IncidentID->search(instance => $site_ref, content => $id);
    next if($recs[0]);

    my ($as,$network,$ccode,$rir,$date) = get_asn_info($addr);
    my $desc;
    $desc = get_as_description($as) if($as);

    $as         = undef if($as && $as eq 'NA');
    $network    = undef if($network && $network eq 'NA');
    $ccode      = undef if($ccode && $ccode eq 'NA');
    $rir        = undef if($rir && $rir eq 'NA');
    $date       = undef if($date && $date eq 'NA');
    $desc       = undef if($desc && $desc eq 'NA');

    my $iodef = XML::IODEF->new();
    my $uuid = IODEF::Message::gen_uuid();

    $iodef->add('Incidentrestriction','private');
    $iodef->add('Incidentpurpose','mitigation');
    $iodef->add('IncidentReportTime',$dt->ymd().'T'.$dt->hms().'Z');
    $iodef->add('IncidentDescription','dshield block list');

    $iodef->add('IncidentIncidentID',$uuid);
    $iodef->add('IncidentIncidentIDname','ren-isac.net');
    $iodef->add('IncidentIncidentIDinstance','ses.ren-isac.net');

    $iodef->add('IncidentAlternativeIDIncidentID',$id);
    $iodef->add('IncidentAlternativeIDIncidentIDname','dshield.org');
    $iodef->add('IncidentAlternativeIDIncidentIDinstance',$site_ref);
    $iodef->add('IncidentAlternativeIDIncidentIDrestriction','public');

    $iodef->add('IncidentEventDataExpectationaction','investigate');

    $iodef->add('IncidentEventDataFlowSystemcategory','target');
    $iodef->add('IncidentEventDataFlowSystemNodeNodeRolecategory','ext-value');
    $iodef->add('IncidentEventDataFlowSystemNodeNodeRoleext-category','honeypot');

    $iodef->add('IncidentEventDataFlowSystemcategory','source');
    $iodef->add('IncidentEventDataFlowSystemNodeAddress',$addr);
    $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','ipv4-net');
    if($network){
        $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','ipv4-net');
        $iodef->add('IncidentEventDataFlowSystemNodeAddress',$network);
    }
    if($as){
        $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','asn');
        $iodef->add('IncidentEventDataFlowSystemNodeAddress',$as);
    }
    if($ccode){
        $iodef->add('IncidentEventDataFlowSystemAdditionalDatadtype','string');
        $iodef->add('IncidentEventDataFlowSystemAdditionalDatameaning','country code');
        $iodef->add('IncidentEventDataFlowSystemAdditionalData',$ccode);
    }
    if($desc){
        $iodef->add('IncidentEventDataFlowSystemAdditionalDatameaning','asn description');
        $iodef->add('IncidentEventDataFlowSystemAdditionalData',$desc);
    }
    

    $iodef->add('IncidentAssessmentImpacttype','recon');
    $iodef->add('IncidentAssessmentImpactseverity','low');
    $iodef->add('IncidentAssessmentConfidencerating','medium');

   warn  IODEF::Message->insert({uuid => $uuid, message => $iodef->out()});
}
close(F);

