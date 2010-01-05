package IODEF::Address;

use strict;
use warnings;
use base 'IODEF::DBI';
use IODEF::Idx_Address_Inet;
use IODEF::Idx_Address_Asn;

__PACKAGE__->table('address');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id nodeid vlan_num vlan_name category ext_category content/);
__PACKAGE__->columns(Essential => qw/id nodeid category content/);
__PACKAGE__->has_a(nodeid => 'IODEF::Node');
__PACKAGE__->sequence('address_id_seq');

__PACKAGE__->add_trigger(after_create => \&create_index);

sub create_index {
    my $self = shift;

    my $category = $self->category();
    warn $category;
    if(uc($category) =~ /^IPV/){
        # create index object
        my $id = IODEF::Idx_Address_Inet->insert({
            incidentid  => $self->nodeid->systemid->flowid->eventdataid->incidentid->id(),
            addressid   => $self->id(),
            category    => lc($category),
            address     => $self->content()
        });
        warn 'index: '.$id.' created';
        $id = IODEF::Idx_Address_Asn->insert({
            incidentid  => $self->nodeid->systemid->flowid->eventdataid->incidentid->id(),
            addressid   => $self->id(),
            address     => $self->content()
        });
        warn 'asn index: '.$id.' created';
    }
}
1;

__END__
