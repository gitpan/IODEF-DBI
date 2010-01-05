package IODEF::IncidentID;

use strict;
use warnings;
use base 'IODEF::DBI';

__PACKAGE__->table('incidentid');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id incidentid content name instance restriction/);
__PACKAGE__->columns(Essential => qw/id incidentid content name restriction/);
__PACKAGE__->has_a(incidentid => 'IODEF::Incident');

1;
__END__
