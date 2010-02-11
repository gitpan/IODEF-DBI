#!lusr/bin/perl -w

use strict;
use lib './lib';

use IODEF::Message;
use XML::IODEF;
use XML::LibXML;
use OSSP::uuid;
use Data::Dumper;

my $iodef = XML::IODEF->new();

$iodef->add('IncidentIncidentID','7777');
$iodef->add('IncidentIncidentIDname','example.com');
$iodef->add('Incidentpurpose','other');
$iodef->add('Incidentrestriction','private');
$iodef->add('IncidentEventDataAssessmentConfidencerating','high');

$iodef->add('IncidentEventDatarestriction','private');
$iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','ipv4-addr');
$iodef->add('IncidentEventDataFlowSystemcategory','source');
$iodef->add('IncidentEventDataFlowSystemNodeAddress','128.205.1.1');
$iodef->add('IncidentEventDataFlowSystemNodeNodeRole','bad-actor');

$iodef->add('IncidentEventDataFlowSystemNodeAddress','128.205.1.2');
$iodef->add('IncidentEventDataFlowSystemcategory','source');

$iodef->add('IncidentEventDataFlowSystemServicePort','6667');
$iodef->add('IncidentEventDataFlowSystemServiceip_protocol','UDP');

$iodef->add('IncidentEventDataDetectTime','2008-01-01 00:00:00:00Z');

my $msg = $iodef->out();
my $parser = XML::LibXML->new();
my $d = $parser->parse_string($msg);

#my $query = '//Incident/IncidentID/text()';
#my @e = $d->findnodes($query);
#warn $e[0]->data();
#@e = $d->findnodes('//Incident/IncidentID');
#warn $e[0]->getAttribute('name');
#warn $e[0]->getAttribute('instance') if($e[0]->getAttribute('instance'));

#foreach my $system ($d->findnodes($query)){
#    warn $system;
#}

#die;
my $r = IODEF::Message->insert({
    uuid    => gen_uuid(),
    message => $msg,
});

warn $r.' created';

sub gen_uuid {
    my $uuid    = OSSP::uuid->new();

    $uuid->make('v4');
    my $str = $uuid->export('str');
    undef $uuid;
    return($str);
}
