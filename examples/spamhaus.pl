#!/usr/bin/perl -w

use strict;
use lib './lib';
use Error qw(:try);
use Data::Dumper;
use XML::IODEF;
use IODEF::Idx_IncidentID;
use DateTime;
use DateTime::Format::DateParse;
use XML::LibXML;
use Net::Abuse::Utils qw(:all);

my $file = '/tmp/spamhaus_drop.txt';
my $site_ref = 'http://www.spamhaus.org/sbl/sbl.lasso?query=';
my $dt = DateTime->from_epoch(epoch => time());

#system('wget --quiet http://www.spamhaus.org/drop/drop.lasso -O '.$file) == 0 or die "system wget failed: $?";

open(F,$file);
my $n = 0;
while (<F>){
    next if($_ =~ /^;/);
    next if($_ =~ /^\n/);
    my ($addr,$ref) = split(/ \; /,$_);
	$addr =~ s/(\n|\s+)//;
    $ref =~ s/\n$//;

    my $id = $ref;

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
    $iodef->add('IncidentDescription','Spamhaus DROP list data');

    $iodef->add('IncidentAlternativeIDIncidentID','http://www.spamhaus.org/sbl/sbl.lasso?query='.$ref);
    $iodef->add('IncidentAlternativeIDIncidentIDrestriction','public');
    $iodef->add('IncidentAlternativeIDIncidentIDname','spamhaus.org');
    $iodef->add('IncidentAlternativeIDIncidentIDinstance','http://www.spamhaus.org/sbl/sbl.lasso');

    $iodef->add('IncidentAssessmentConfidencerating','high');
    $iodef->add('IncidentAssessmentImpacttype','policy');
    $iodef->add('IncidentAssessmentImpacttype','ext-value');
    $iodef->add('IncidentAssessmentImpactext-type','spam');
    $iodef->add('IncidentAssessmentImpactcompletion','succeeded');
    $iodef->add('IncidentAssessmentImpactseverity','high');

    $iodef->add('IncidentEventDataExpectationaction','block-network');

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
    warn $iodef->out();
    warn IODEF::Message->insert({uuid => $uuid, message  => $iodef->out()});
    
    
    #last if $n++ == 3;
}
close(F);

