package IODEF::Idx_Address_Inet;

use strict;
use warnings;
use base 'IODEF::DBI';

__PACKAGE__->table('idx_address_inet');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id incidentid addressid address category created/);
__PACKAGE__->columns(Essential => qw/id incidentid addressid address category created/);
__PACKAGE__->has_a(addressid    => 'IODEF::Address');
__PACKAGE__->has_a(incidentid   => 'IODEF::Incident');
__PACKAGE__->sequence('idx_address_inet_id_seq');

1;

__END__
