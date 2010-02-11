package IODEF::Idx_Address_Inet;

use strict;
use warnings;
use Net::Abuse::Utils qw(:all);
use base 'IODEF::DBI';

__PACKAGE__->table('idx_address_inet');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id messageid address created/);
__PACKAGE__->columns(Essential => qw/id messageid address created/);
__PACKAGE__->has_a(messageid   => 'IODEF::Message');
__PACKAGE__->sequence('idx_address_inet_id_seq');

__PACKAGE__->set_sql('created_days' => qq{
    SELECT __ESSENTIAL__
    FROM __TABLE__
    WHERE created >= (date(now()) - ?::integer)
    ORDER BY created DESC
});

1;

__END__
