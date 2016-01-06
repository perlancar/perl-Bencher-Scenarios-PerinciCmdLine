package Bencher::Scenario::PerinciCmdLine::Completion;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::Any::IfLOG '$log';

use Bencher::ScenarioUtil::Completion qw(make_completion_participant);
use File::Temp;

our $scenario = {
    summary => 'Benchmark completion response time, to monitor regression',
    modules => {
    },
    participants => [
        make_completion_participant(
            name=>'optname_common_help',
            cmdline=>"CLI --hel^",
        ),
        make_completion_participant(
            name=>'optname_common_version',
            cmdline=>"CLI --vers^",
        ),
        make_completion_participant(
            name=>'optname_action',
            cmdline=>"CLI --acti^",
        ),
        make_completion_participant(
            name=>'optval_action',
            cmdline=>"CLI --action ^",
        ),
    ],
    #datasets => [
    #],
};

1;
# ABSTRACT:
