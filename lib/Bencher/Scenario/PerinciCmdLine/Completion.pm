package Bencher::Scenario::PerinciCmdLine::Completion;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use App::GenPericmdCompleterScript qw(gen_pericmd_completer_script);
use Bencher::ScenarioUtil::Completion qw(make_completion_participant);
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

        # XXX _oddeven

        push @cmds, "oddeven-lite";
        $res = gen_pericmd_script(
            url => "/Perinci/Examples/Tiny/odd_even",
            cmdline => "Perinci::CmdLine::Lite",
            output_file => "$tempdir/oddeven-lite",
        );
        die "Can't create oddeven-lite: $res->[0] - $res->[1]"
            unless $res->[0] == 200;

        # XXX oddeven-lite-packed

        push @cmds, "oddeven-classic";
        $res = gen_pericmd_script(
            url => "/Perinci/Examples/Tiny/odd_even",
            cmdline => "Perinci::CmdLine::Classic",
            output_file => "$tempdir/oddeven-classic",
        );
        die "Can't create oddeven-classic: $res->[0] - $res->[1]"
            unless $res->[0] == 200;

        my $sc = $args{scenario};
        my $pp = $sc->{participants};

        splice @$pp, 0;

        for my $cmd (@cmds) {
            push @$pp, make_completion_participant(
                type => 'perl_code',
                name=>"$cmd optname_common_help",
                cmdline=>"$tempdir/$cmd --hel^",
            );
            push @$pp, make_completion_participant(
                type => 'perl_code',
                name=>"$cmd optname_common_version",
                cmdline=>"$tempdir/$cmd --vers^",
            );
            push @$pp, make_completion_participant(
                type => 'perl_code',
                name=>"$cmd optname_number",
                cmdline=>"$tempdir/$cmd --num^",
            );
            push @$pp, make_completion_participant(
                type => 'perl_code',
                name=>"$cmd optval_number",
                cmdline=>"$tempdir/$cmd --number ^",
            );
        }

        my $i = 0; for (@$pp) { $_->{seq} = $i++ }
    },
    #datasets => [
    #],
};

1;
# ABSTRACT:
