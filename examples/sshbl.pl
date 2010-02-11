#!/usr/bin/perl -w

use strict;
use lib './lib';
use Data::Dumper;
use XML::IODEF;
use IODEF::Message;
use DateTime;
use IODEF::Message;
use IODEF::Idx_IncidentID;
use Net::Abuse::Utils qw(:all);

my $time;
my $file = '/tmp/sshbl.txt';
my $site_ref = 'http://www.sshbl.org/lists/date.txt';

#system('wget --quiet http://www.sshbl.org/lists/date.txt -O '.$file) == 0 or die "system wget failed: $?";

open(F,$file);
my $n = 0;
while (<F>){
    next if($_ =~ /^#/);
    my @a = split(/\s+/,$_);
    my $addr = $a[0]; my $ts = $a[1];

    my $dt = DateTime->from_epoch(epoch => $ts);

    my $id = $addr.'_'.$dt->dmy();

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

    $iodef->add('IncidentIncidentID',$uuid);
    $iodef->add('Incidentrestriction','private');
    $iodef->add('IncidentIncidentIDname','ren-isac.net');
    $iodef->add('IncidentIncidentIDinstance','ses.ren-isac.net');
    $iodef->add('IncidentReportTime',$dt->ymd().'T'.$dt->hms().'Z');
    $iodef->add('IncidentDescription','sshbl block list');
    
    $iodef->add('IncidentAlternativeIDIncidentID',$id);
    $iodef->add('IncidentAlternativeIDIncidentIDname','sshbl.org');
    $iodef->add('IncidentAlternativeIDIncidentIDinstance',$site_ref);
    $iodef->add('IncidentAlternativeIDIncidentIDrestriction','public');
    
    $iodef->add('Incidentpurpose','mitigation');
    
    $iodef->add('IncidentEventDataFlowSystemcategory','target');
    $iodef->add('IncidentEventDataFlowSystemNodeNodeRolecategory','ext-value');
    $iodef->add('IncidentEventDataFlowSystemNodeNodeRoleext-category','honeypot');
    $iodef->add('IncidentEventDataFlowSystemcategory','source');
    $iodef->add('IncidentEventDataFlowSystemrestriction','public');
    $iodef->add('IncidentEventDataFlowSystemNodeAddress',$addr);
    $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','ipv4-addr');
    $iodef->add('IncidentEventDataFlowSystemService',6);
    $iodef->add('IncidentEventDataFlowSystemServicePort','22');
    $iodef->add('IncidentEventDataFlowSystemServiceApplicationname','SSH');
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
    $iodef->add('IncidentAssessmentImpactcompletion','succeeded');
    $iodef->add('IncidentAssessmentImpacttype','admin');
    $iodef->add('IncidentAssessmentImpactcompletion','failed');
    $iodef->add('IncidentAssessmentConfidencerating','low');
    $iodef->add('IncidentAssessmentImpactseverity','medium');
    
    warn $iodef->out();
    warn  IODEF::Message->insert({uuid => $uuid, message => $iodef->out()});
}
close(F);

