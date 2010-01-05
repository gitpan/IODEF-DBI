package IODEF::Flow;

use strict;
use warnings;
use base 'IODEF::DBI';

__PACKAGE__->table('Flow');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id eventdataid/);
__PACKAGE__->columns(Essential => qw/id eventdataid/);
__PACKAGE__->has_a(eventdataid => 'IODEF::EventData');
__PACKAGE__->sequence('flow_id_seq');
1;
__END__
