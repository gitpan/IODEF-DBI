package IODEF::Idx_IncidentID;

use strict;
use warnings;
use base 'IODEF::DBI';

__PACKAGE__->table('idx_incidentid');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id messageid content name instance created/);
__PACKAGE__->columns(Essential => qw/id messageid content name instance created/);
__PACKAGE__->has_a(messageid   => 'IODEF::Message');
__PACKAGE__->sequence('idx_incidentid_id_seq');

1;

__END__
