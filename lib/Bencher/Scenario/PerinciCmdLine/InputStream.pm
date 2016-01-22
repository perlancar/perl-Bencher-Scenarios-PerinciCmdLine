package Bencher::Scenario::PerinciCmdLine::InputStream;

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
    summary => 'Benchmark input stream vs raw Perl I/O',
    description => <<'_',

1mil lines input data, short line ("1"), each line is chomped.

Conclusion: about 4.7 times slower on my PC (1.6mil lines/sec vs 7.5mil).

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

        # produce a 1-mil line text file
        open my $fh, ">$tempdir/input";
        for (1..1000_000) { print $fh "$_\n" }
        close $fh;

        splice @$pp, 0;

        for my $cmdline (qw/rawperl Inline Lite Classic/) {
            my $progname = "count-lines-$cmdline";
            my $progpath = "$tempdir/$progname";
            if ($cmdline eq 'rawperl') {
                write_text($progpath, "#!$^X\n" . <<'_');
my $num = 0; while (<>) { chomp; $num++ } print $num, "\n";
_
                chmod 0755, $progpath;
            } else {
                my $res = gen_pericmd_script(
                    url => "/Perinci/Examples/Stream/count_lines",
                    cmdline => "Perinci::CmdLine::Lite",
                    output_file => $progpath,
                );
                die "Can't create $progpath: $res->[0] - $res->[1]"
                    unless $res->[0] == 200;
            }

            push @$pp, {
                type => 'command',
                name => $progname,
                cmdline => "$progpath < $tempdir/input",
            };
        }

        my $i = 0; for (@$pp) { $_->{seq} = $i++ }
    },
};

1;
# ABSTRACT:
