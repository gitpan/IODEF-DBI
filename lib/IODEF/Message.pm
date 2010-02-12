package IODEF::Message;

use strict;
use warnings;
use base 'IODEF::DBI';
use XML::LibXML;
use Regexp::Common;
use Regexp::Common::net;
use IODEF::Idx_Address_Inet;
use IODEF::Idx_Address_Asn;
use IODEF::Idx_IncidentID;
use OSSP::uuid;

__PACKAGE__->table('messages');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid created message/);
__PACKAGE__->columns(Essential => qw/id uuid created message/);
__PACKAGE__->has_many(idx_inet => 'IODEF::Idx_Address_Inet');
__PACKAGE__->sequence('messages_id_seq');

__PACKAGE__->add_trigger(before_create  => \&check_uuid);
__PACKAGE__->add_trigger(after_create   => \&create_index_address);
__PACKAGE__->add_trigger(after_create   => \&create_index_incidentid);

sub check_uuid {
    my $self = shift;
    $self->set(uuid => gen_uuid()) unless($self->uuid());
}

sub create_index_incidentid {
    my $self = shift;

    my $parser = XML::LibXML->new();
    my $doc = $parser->parse_string($self->message());

    my @nodes = $doc->findnodes('//Incident/IncidentID');
    foreach my $node (@nodes){
        IODEF::Idx_IncidentID->insert({
            content     => $node->textContent(),
            name        => $node->getAttribute('name'),
            instance    => $node->getAttribute('instance'),
            messageid   => $self->uuid()
        });
    }

    @nodes = $doc->findnodes('//Incident/AlternativeID/IncidentID');
    foreach my $node (@nodes){
        IODEF::Idx_IncidentID->insert({
            content     => $node->textContent(),
            name        => $node->getAttribute('name'),
            instance    => $node->getAttribute('instance'),
            messageid   => $self->uuid()
        });
    }
}

sub create_index_address {
    my $self = shift;

    my $parser = XML::LibXML->new();
    my $doc = $parser->parse_string($self->message());

    my @nodes = $doc->findnodes('//Incident/EventData/Flow/System/Node/Address');
    foreach my $node (@nodes){
        my $content = $node->textContent();
        my $category = lc($node->getAttribute('category'));

        next unless($category || $content =~ /$RE{net}{IPv4}/);
        $category = 'ipv4-addr' unless($category);

        for($category){
            if(/asn/){
                IODEF::Idx_Address_Asn->insert({
                    messageid   => $self->uuid(),
                    address     => $content
                });
                # get additional info if needed
                last;
            }
            if(/^ipv(4|6)-(addr|net)/){
                IODEF::Idx_Address_Inet->insert({
                    messageid   => $self->uuid(),
                    address     => $content,
                });
                last;
            }
            ## dns / url stuff here
        }
    }
}

sub gen_uuid {
    my $uuid    = OSSP::uuid->new();

    $uuid->make('v4');
    my $str = $uuid->export('str');
    undef $uuid;
    return($str);
}

1;

__END__
