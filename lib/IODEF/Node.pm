package IODEF::Node;

use strict;
use warnings;
use base 'IODEF::DBI';

__PACKAGE__->table('Node');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id systemid location datetime/);
__PACKAGE__->columns(Essential => qw/id systemid/);
__PACKAGE__->has_a(systemid => 'IODEF::System');
__PACKAGE__->might_have(address => 'IODEF::Address');
__PACKAGE__->sequence('node_id_seq');

1;
__END__
