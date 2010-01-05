package IODEF::Idx_Address_Asn;

use strict;
use warnings;
use Net::Abuse::Utils qw(:all);
use base 'IODEF::DBI';

__PACKAGE__->table('idx_address_asn');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id incidentid addressid address description cc rir updated created/);
__PACKAGE__->columns(Essential => qw/id incidentid addressid address description cc rir updated created/);
__PACKAGE__->has_a(addressid    => 'IODEF::Address');
__PACKAGE__->has_a(incidentid   => 'IODEF::Incident');
__PACKAGE__->sequence('idx_address_asn_id_seq');

__PACKAGE__->add_trigger(before_create => \&getinfo);

sub getinfo {
    my $self = shift;
    
    my $addr = $self->address();

    my ($as,$network,$ccode,$rir,$date) = get_asn_info($addr);
    my $desc;
    $desc = get_as_description($as) if($as);

    $self->set(address          => $as);
    $self->set(description    => $desc) if($desc);
    $self->set(cc               => $ccode) if($ccode);
    $self->set(rir              => $rir) if($rir);
    $self->set(updated          => $date) if($date);
    $self->set(address          => $as) if($as);
}

1;

__END__
