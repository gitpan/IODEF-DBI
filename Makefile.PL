use 5.010000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'IODEF::DBI',
    VERSION_FROM      => 'lib/IODEF/DBI.pm', # finds $VERSION
    PREREQ_PM         => {
        Class::DBI          => undef,
        XML::IODEF          => undef,
        OSSP::uuid          => undef,
        DateTime            => undef,
        XML::LibXML         => undef,
        Net::Abuse::Utils   => undef,
        LWP::Simple         => undef,
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/IODEF/DBI.pm', # retrieve abstract from module
       AUTHOR         => 'Wes Young <wes@barely3am.com>') : ()),
);
