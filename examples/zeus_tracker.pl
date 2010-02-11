#!/usr/bin/perl -w
use lib './lib';

use strict;
use LWP::Simple;
use Data::Dumper;
use Net::Abuse::Utils qw(:all);
use DateTime;
use XML::IODEF;
use IODEF::Message;

my $url = 'http://www.abuse.ch/zeustracker/blocklist.php?download=ipblocklist';
my $alt_id = 'https://zeustracker.abuse.ch/monitor.php?search=';

my $content = get($url);
my $dt = DateTime->from_epoch(epoch => time());

my @feed = split(/\n/,$content);
foreach my $line (@feed){
    next if($line =~ /^(#|$)/);

    my $addr = $line;

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

    $iodef->add('Incidentpurpose','mitigation');
    $iodef->add('Incidentrestriction','private');

    $iodef->add('IncidentIncidentID',$uuid);
    $iodef->add('IncidentIncidentIDname','ren-isac.net');
    $iodef->add('IncidentIncidentIDinstance','ses.ren-isac.net');
    $iodef->add('IncidentIncidentIDrestriction','private');
    $iodef->add('IncidentReportTime',$dt->ymd().'T'.$dt->hms().'Z');
    $iodef->add('IncidentDescription','zeustracker block list - ip');

    $iodef->add('IncidentAlternativeIDIncidentID',$alt_id.$addr);
    $iodef->add('IncidentAlternativeIDIncidentIDrestriction','public');
    $iodef->add('IncidentAlternativeIDIncidentIDname','abuse.ch');
    $iodef->add('IncidentAlternativeIDIncidentIDinstance','zeustracker.abuse.ch');

    $iodef->add('IncidentAssessmentConfidencerating','medium');
    $iodef->add('IncidentAssessmentImpacttype','ext-value');
    $iodef->add('IncidentAssessmentImpactext-type','botnet controller');
    $iodef->add('IncidentAssessmentImpactseverity','medium');

    $iodef->add('IncidentEventDataExpectationaction','investigate');

    $iodef->add('IncidentEventDataFlowSystemcategory','intermediate');
    $iodef->add('IncidentEventDataFlowSystemDescription','zeus controller');

    $iodef->add('IncidentEventDataFlowSystemNodeAddress',$addr);
    $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','ipv4-addr');
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
    warn $iodef->out();
    warn IODEF::Message->insert({uuid => $uuid, message  => $iodef->out()});
}


