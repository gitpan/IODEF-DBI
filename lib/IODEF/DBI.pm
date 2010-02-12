package IODEF::DBI;

use 5.010000;
use strict;
use warnings;
use base 'Class::DBI';

our $VERSION = '0.01_4';

# Preloaded methods go here.

__PACKAGE__->connection('DBI:Pg:database=iodef;host=localhost','postgres','',{ AutoCommit => 1} );

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

IODEF::DBI - Perl extension designed to create a simple storeage and indexing framework for XML based IODEF messages. 

=head1 SYNOPSIS

  my @recs = IODEF::Idx_Address_Inet->search_created_days(21);
  my $parser = XML::LibXML->new();

  foreach my $rec (@recs){
    my $msg = IODEF::Message->retrieve(uuid => $rec->messageid());
    my $doc = $parser->parse_string($msg->message());
    
    # do some XML::LibXML stuff
  }

=head1 DESCRIPTION

This module provides the glue between IODEF and Class::DBI. See examples/ directory for use.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Class::DBI, XML::IODEF, XML::LibXML

http://code.google.com/p/perl-tracker-dbi/

=head1 AUTHOR

Wes Young, E<lt>wes@barely3am.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Wes Young

=cut
