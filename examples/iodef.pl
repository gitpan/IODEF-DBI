#!lusr/bin/perl -w

use strict;
use lib './lib';

use IODEF::DBI;
use XML::IODEF;
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
$iodef->add('IncidentEventDataFlowSystemNodeAddress','10.205.1.1');
$iodef->add('IncidentEventDataFlowSystemNodeNodeRole','bad-actor');

$iodef->add('IncidentEventDataFlowSystemNodeAddress','10.205.1.2');
$iodef->add('IncidentEventDataFlowSystemcategory','source');

$iodef->add('IncidentEventDataFlowSystemServicePort','6667');
$iodef->add('IncidentEventDataFlowSystemServiceip_protocol','UDP');

$iodef->add('IncidentEventDataDetectTime','2008-01-01 00:00:00:00Z');
IODEF::DBI->insert_xml(xml => $iodef->out());
