package IODEF::DBI;

use 5.010000;
use strict;
use warnings;
use base 'Class::DBI';
use XML::IODEF;
use IODEF::Incident;
use IODEF::IncidentID;
use IODEF::EventData;
use IODEF::Flow;
use IODEF::System;
use IODEF::Service;
use IODEF::Node;
use IODEF::Address;

our $VERSION = '0.01_1';

# Preloaded methods go here.

__PACKAGE__->connection('DBI:Pg:database=tracker;host=localhost','postgres','',{ AutoCommit => 1} );

our @classes = qw/Incident IncidentID IncidentData EventData System Service Node/;

sub insert_xml {
    my $self = shift;
    use Data::Dumper;
    my %args = (
        xml => undef,
        @_,
    );

    my $xml = $args{'xml'};
    unless($xml){
        return $self->SUPER::insert(%args);
    }
   
    my $iodef = XML::IODEF->new();
    $iodef->in($xml) || die('invalid xml doc');
    my $hash = $iodef->to_hash();

    die Dumper($hash);
    my @ids = @{$hash->{'IncidentIncidentID'}};
    if($#ids > 0){
        die('mod XML::IODEF does not handle multiple incidents well');
    }

    my $incidentid = IODEF::Incident->insert({
        purpose     => $iodef->get('Incidentpurpose'),
        restriction => $iodef->get('Incidentrestriction'),
    });

    IODEF::IncidentID->insert({
        incidentid  => $incidentid,
        content     => $iodef->get('IncidentIncidentID'),
        name        => $iodef->get('IncidentIncidentIDname'),
        instance    => $iodef->get('IncidentIncidentIDinstance'),
    });

    my $edid = IODEF::EventData->insert({
        incidentid  => $incidentid,
        restriction => $iodef->get('IncidentEventDatarestriction'),
        DetectTime  => $iodef->get('IncidentEventDataDetectTime'),
        StartTime   => $iodef->get('IncidentEventDataStartTime'),
        EndTime     => $iodef->get('IncidentEventDataEndTime'),
    });

    my $flowid = IODEF::Flow->insert({
        eventdataid     => $edid,
    });

    my $sid = IODEF::System->insert({
        flowid          => $flowid,
        restriction     => $iodef->get('IncidentEventDataFlowSystemrestriction'),
        category        => $iodef->get('IncidentEventDataFlowSystemcategory'),
        ext_category    => $iodef->get('IncidentEventDataFlowSystemext-category'),
        interface       => $iodef->get('IncidentEventDataFlowSysteminterface'),
        spoofed         => $iodef->get('IncidentEventDataFlowSystemspoofed'),
    });

   my $nodeid = IODEF::Node->insert({
        systemid    => $sid,
        location    => $iodef->get('IncidentEventDataFlowSystemNodeLocation'),
        datetime    => $iodef->get('IncidentEventDataFlowSystemNodeDateTime'),
    });

    my $aid = IODEF::Address->insert({
        nodeid          => $nodeid,
        category        => $iodef->get('IncidentEventDataFlowSystemNodeAddresscategory') || 'ipv4-addr',
        ext_category    => $iodef->get('IncidentEventDataFlowSystemNodeAddressext-category'),
        content         => $iodef->get('IncidentEventDataFlowSystemNodeAddress'),
    });

    return $incidentid;
}
1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

IODEF::DBI - Perl extension for blah blah blah

=head1 SYNOPSIS

  use IODEF::DBI;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for IODEF::DBI, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Class::DBI

http://code.google.com/p/perl-tracker-dbi/

=head1 AUTHOR

Wes Young, E<lt>wes@barely3am.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Wes Young

SEE LICENSE File

=cut
