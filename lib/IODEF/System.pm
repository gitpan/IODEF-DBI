package IODEF::System;

use strict;
use warnings;
use base 'IODEF::DBI';

__PACKAGE__->table('System');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id flowid restriction category ext_category interface spoofed/);
__PACKAGE__->columns(Essential => qw/id flowid category restriction/);
__PACKAGE__->has_a(flowid => 'IODEF::Flow');
__PACKAGE__->sequence('system_id_seq');
1;
__END__
