package Bencher::Scenario::PerinciCmdLine::ResultStream;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use File::Slurper qw(write_text);
use File::Temp qw(tempdir);
use Perinci::CmdLine::Gen qw(gen_pericmd_script);

my $tempdir;

our $scenario = {
    summary => 'Benchmark result stream vs raw Perl I/O',
    description => <<'_',

Conclusion: about 2.5 times slower on my PC (1.2mil lines/sec vs 3mil).

_
    modules => {
    },
    precision => 2,
    participants => [
    ],
    before_list_participants => sub {
        my %args = @_;

        return if $tempdir;
        my $keep = $ENV{DEBUG_KEEP_TEMPDIR} ? 1:0;
        $tempdir = tempdir(CLEANUP => !$keep);

        my $sc = $args{scenario};
        my $pp = $sc->{participants};

        splice @$pp, 0;

        for my $cmdline (qw/rawperl Inline Lite Classic/) {
            my $progname = "produce-ints-$cmdline";
            my $progpath = "$tempdir/$progname";
            if ($cmdline eq 'rawperl') {
                write_text($progpath, "#!$^X\n" . <<'_');
for (1..$ARGV[1]) { print ++$i, "\n" }
_
                chmod 0755, $progpath;
            } else {
                my $res = gen_pericmd_script(
                    url => "/Perinci/Examples/Stream/produce_ints",
                    cmdline => "Perinci::CmdLine::Lite",
                    output_file => $progpath,
                );
                die "Can't create $progpath: $res->[0] - $res->[1]"
                    unless $res->[0] == 200;
            }

            push @$pp, {
                type => 'command',
                name => $progname,
                cmdline => "$progpath --num 1000000 > /dev/null",
            };
        }

        my $i = 0; for (@$pp) { $_->{seq} = $i++ }
    },
};

1;
# ABSTRACT:
