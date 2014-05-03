#!/usr/bin/env perl
use warnings;
use strict;
use Net::DBus;
use Net::Netrc;
use Nullroute::Lib qw(_debug _warn _err _die);
use constant SL_DOMAIN => "secondlife.com";
use constant SL_BUS_NAME => "com.secondlife.ViewerAppAPIService";
use constant SL_BUS_PATH => "/com/secondlife/ViewerAppAPI";

sub _log { print "-- ".shift."\n"; }

$::bus = Net::DBus->session;

my $exe;
my $uri;
my @sl_args;

$exe = shift @ARGV;
if (!defined $exe) {
	_die("missing executable path");
}
elsif (!-f $exe || !-x $exe) {
	_die("not an executable: $exe");
}

@sl_args = ("--novoice");
for my $arg (@ARGV) {
	if ($arg =~ /^@(.+)$/) {
		my $name = $1;
		my $domain = SL_DOMAIN;
		_debug("looking up login '$name' for '$domain' in .netrc");
		my $entry = Net::Netrc->lookup($domain, $name);
		if (!$entry || !defined $entry->{machine}) {
			_err("login '$name' not found in .netrc");
		} elsif (!defined $entry->{password}) {
			_err("password for '$name' missing from .netrc");
		} else {
			my @acct = defined($entry->{account})
					? split(/\s+/, $entry->{account})
					: split(/\s+/, $name);
			_debug("using account '@acct' from .netrc");
			push @sl_args,
				("--login", @acct, $entry->{password});
		}
	}
	elsif ($arg =~ m!^secondlife://!) {
		push @sl_args, ("--url", $uri = $arg);
	}
	else {
		push @sl_args, $arg;
	}
}

exit 1 if $::errors;

if (defined $uri) {
	if ($::bus->get_service_owner(SL_BUS_NAME)) {
		_log("activating existing viewer instance");

		eval {
			$::bus
			->get_service(SL_BUS_NAME)
			->get_object(SL_BUS_PATH)
			->GoSLURL($uri);
		};

		if ($@) {
			_warn("failed to contact the viewer: $@");
		} else {
			exit 0;
		}
	}
}

if ($::debug) {
	_debug("starting '$exe'");
	_debug(" - with arg '$_'") for @sl_args;
}

exec {$exe} ($exe, @sl_args);
