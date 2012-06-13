#!/usr/bin/perl

use strict;
use warnings;

#'<:encoding(utf8)'
open FILE, "$ARGV[0]" or die $!;
undef $/;
my $msg=<FILE>;
close(FILE);

# automatic commit messages e.g. merge commits of the form:
# Merge branch 'develop'
# bypass service hooks so they don't need to be explicitly allowed.
if ( $msg =~ /
	(
	^KOKU-\d{1,5}:\ [\w\ ]{10,60}$	# subject line (required)
	(\n\n\w.*)?						# empty line + long description (optional)
	(^\#[^\r\n]*$)*					# automatically included comments (optional)
	)
	/mx ) {
  exit(0);
}

exit(1);
