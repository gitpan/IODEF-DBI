package IODEF::Idx_Address_Asn;

use strict;
use warnings;
use base 'IODEF::DBI';

__PACKAGE__->table('idx_address_asn');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id messageid address description cc rir last_updated created/);
__PACKAGE__->columns(Essential => qw/id messageid address description cc rir last_updated created/);
__PACKAGE__->has_a(messageid   => 'IODEF::Message');
__PACKAGE__->sequence('idx_address_asn_id_seq');

1;

__END__
