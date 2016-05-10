#!/usr/bin/perl

use strict;
use warnings;

my $debug = 0;

my @contacts         = ('root');
my $mailCmd          = '/bin/mail -s "MySQL replication status" '.join(' ', @contacts);

my $IOThreadStatus   = 0;
my $IOThreadCheckCmd = '/usr/bin/mysql -e \'show slave status\G\' -B | grep \'Slave_IO_Running\'';

my $SQLThreadStatus = 0;
my $SQLThreadCheckCmd = '/usr/bin/mysql -e \'show slave status\G\' -B | grep \'Slave_SQL_Running\'';

# ------------------------------------------------------------------------------
# functions
# ------------------------------------------------------------------------------
sub getMysqlThreadStatus($) {
  my $command   = shift;
  my $status    = "";

  debug("Running $command\n");
  my $output = `$command 2>&1`;
  if ($output =~ /^\s+\w+\s*:\s+(Yes|No)$/ ) {
    $status = lc($1);
    debug('Found the status and it was \''.$status."\'\n");
  }
  else {
    debug("The status lookup didn't executed succesfully\n");
    debug("OUTPUT : $output\n");
  }

  if ($status =~ /^yes$/)   { debug("returning 1\n"); return 1; }
  elsif ($status =~ /^no$/) { debug("returning 0 - no\n"); return 0; }
  else                      { debug("returning 0 - default\n"); return 0; }
}

sub debug($) {
  my $msg = shift();
  $debug && print(getLoggingTime().' [DEBUG] '.$msg);
}

sub getLoggingTime() {

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
    my $nice_timestamp = sprintf ( "%04d%02d%02d %02d:%02d:%02d",
                                   $year+1900,$mon+1,$mday,$hour,$min,$sec);
    return $nice_timestamp;
}

sub sendErrorMail($) {
  my $msg = shift;
  debug("Using email command from the env : $mailCmd\n");
  `echo "$msg" | $mailCmd`;
}

# ------------------------------------------------------------------------------
# MAIN
# ------------------------------------------------------------------------------
debug("Looking for mysql slave status\n");
debug("IO Thread\n");
$IOThreadStatus = getMysqlThreadStatus($IOThreadCheckCmd);
debug("IO Thread Status : $IOThreadStatus\n");
debug("SQL Thread\n");
$SQLThreadStatus= getMysqlThreadStatus($SQLThreadCheckCmd);
debug("SQL Thread Status : $SQLThreadStatus\n");

my $exitStatus = ($IOThreadStatus && $SQLThreadStatus);

if ($exitStatus) {
  print("MySQL Replication is OK\n");
  exit($exitStatus);
}
else {
  sendErrorMail("MySQl Replication is NOT RUNNING !\n");
  die("MySQl Replication is NOT RUNNING !\n");
}
