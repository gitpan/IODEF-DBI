package IODEF::Service;

use strict;
use warnings;
use base 'IODEF::DBI';

__PACKAGE__->table('Service');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id systemid ip_protocol port portlist protocode prototype protoflags/);
__PACKAGE__->columns(Essential => qw/id systemid ip_proto port/);
__PACKAGE__->has_a(systemid => 'IODEF::System');

1;
__END__
