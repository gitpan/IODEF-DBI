package IODEF::EventData;

use strict;
use warnings;
use base 'IODEF::DBI';

__PACKAGE__->table('EventData');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id incidentid eventdataid restriction StartTime EndTime DetectTime/);
__PACKAGE__->columns(Essential => qw/id starttime endtime detecttime restriction/);
__PACKAGE__->might_have(system => 'IODEF::System');
__PACKAGE__->might_have(service => 'IODEF::Service');
__PACKAGE__->might_have(incidentid => 'IODEF::Incident');
__PACKAGE__->might_have(eventdataid => 'IODEF::EventData');
__PACKAGE__->sequence('eventdata_id_seq');
1;
__END__
