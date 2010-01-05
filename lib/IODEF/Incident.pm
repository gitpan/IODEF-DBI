package IODEF::Incident;

use strict;
use warnings;
use base 'IODEF::DBI';

__PACKAGE__->table('incident');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id purpose ext_purpose lang restriction/);
__PACKAGE__->columns(Essential => qw/id purpose restriction/);
__PACKAGE__->might_have(IncidentID => 'IODEF::IncidentID');
__PACKAGE__->might_have(EventData => 'IODEF::EventData');

1;
__END__
