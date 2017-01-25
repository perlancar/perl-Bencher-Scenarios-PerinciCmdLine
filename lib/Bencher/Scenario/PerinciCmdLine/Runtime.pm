package Bencher::Scenario::PerinciCmdLine::Runtime;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use App::GenPericmdCompleterScript qw(gen_pericmd_completer_script);
use File::Temp qw(tempdir);
use Perinci::CmdLine::Gen qw(gen_pericmd_script);

my $tempdir;

our $scenario = {
    summary => 'Benchmark completion response time, to monitor regression',
    modules => {
    },
    participants => [
    ],
    before_list_participants => sub {
        my %args = @_;

        return if $tempdir;
        my $keep = $ENV{DEBUG_KEEP_TEMPDIR} ? 1:0;
        $tempdir = tempdir(CLEANUP => !$keep);

        my $res;

        my @cmds;

        push @cmds, "hello-inline";
        $res = gen_pericmd_script(
            url => "/Perinci/Examples/Tiny/hello_naked",
            cmdline => "Perinci::CmdLine::Inline",
            output_file => "$tempdir/hello-inline",
        );
        die "Can't create hello-inline: $res->[0] - $res->[1]"
            unless $res->[0] == 200;

        push @cmds, "hello-lite";
        $res = gen_pericmd_script(
            url => "/Perinci/Examples/Tiny/hello_naked",
            cmdline => "Perinci::CmdLine::Lite",
            output_file => "$tempdir/hello-lite",
        );
        die "Can't create hello-lite: $res->[0] - $res->[1]"
            unless $res->[0] == 200;

        # XXX hello-lite-packed

        push @cmds, "hello-classic";
        $res = gen_pericmd_script(
            url => "/Perinci/Examples/Tiny/hello_naked",
            cmdline => "Perinci::CmdLine::Classic",
            output_file => "$tempdir/hello-classic",
        );
        die "Can't create hello-classic: $res->[0] - $res->[1]"
            unless $res->[0] == 200;

        my $sc = $args{scenario};
        my $pp = $sc->{participants};

        splice @$pp, 0;

        for my $cmd (@cmds) {
            push @$pp, {
                type => 'perl_code',
                name => "$cmd help",
                summary => 'Run command --help',
                code => sub {
                    my $out = `$tempdir/$cmd --help`;
                    die "Backtick failed: $?" if $?;
                    $out;
                }
            };
            push @$pp, {
                type => 'perl_code',
                name => "$cmd version",
                summary => 'Run command --version',
                code => sub {
                    my $out = `$tempdir/$cmd --version`;
                    die "Backtick failed: $?" if $?;
                    $out;
                }
            };
            push @$pp, {
                type => 'perl_code',
                name => "$cmd",
                summary => 'Run command',
                code => sub {
                    my $out = `$tempdir/$cmd`;
                    die "Backtick failed: $?" if $?;
                    $out;
                }
            };
        }

        my $i = 0; for (@$pp) { $_->{seq} = $i++ }
    },
    #datasets => [
    #],
};

1;
# ABSTRACT:
