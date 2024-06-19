#!/usr/bin/perl
use strict;
use JSON;
use LWP::UserAgent;
use Config::Simple;

my %Config;
Config::Simple->import_from('/etc/github_stats.conf', \%Config) or die Config::Simple->error();

my @reports  = ('clones', 'views');
my %resume = ();
my %totals = ();

sub get_stats {
    my ($url,$target) = @_;
    my $json = '';
    my $ua = LWP::UserAgent->new(
        agent => 'GitStats/1.0',
        keep_alive => 1,
        env_proxy  => 1,
        ssl_opts => { verify_hostname => 0,
                      SSL_verify_mode => 0x00,
                    },
    );
    my $res = $ua->request(
        HTTP::Request->new(GET => $url,
            HTTP::Headers->new('Accept' => 'application/vnd.github+json',
                               'Authorization' => "Bearer $Config{'github.token'}",
                               'X-GitHub-Api-Version' => '2022-11-28'),
            ),
            sub {
                $json .= $_[0];
            }
        );
    undef $ua;
    return $json;
}

foreach my $project ( @{ $Config{'github.repositories'} } ) {
    foreach my $report (@reports) {
        my $msg_ref = from_json(get_stats("https://api.github.com/repos/$Config{'github.user'}/$project/traffic/$report"));
        if (ref($msg_ref->{$report}) eq 'ARRAY') {
            for (my $i=0; $i <= (@{ $msg_ref->{$report} } - 1) ; $i++) {
                my ($timestamp) = split(/T/,$msg_ref->{$report}->[$i]->{timestamp});
                $resume{$project}{$timestamp}{$report}{count}   = $msg_ref->{$report}->[$i]->{count};
                $resume{$project}{$timestamp}{$report}{uniques} = $msg_ref->{$report}->[$i]->{uniques};
                $totals{$project}{$report}{count}   += $msg_ref->{$report}->[$i]->{count};
                $totals{$project}{$report}{uniques} += $msg_ref->{$report}->[$i]->{uniques};
            }
        }
    }
}

print '-' x 49 . "\n";
print '| Project       |     Views     |     Clones    |' . "\n";
print '|---------------|---------------|---------------|' . "\n";
print '|        Date   |   C   |   U   |   C   |   U   |' . "\n";

foreach my $project (sort { "\U$a" cmp "\U$b" } keys %resume) {
    print '|' . ('-' x 47) . "\|\n";
    print sprintf("\| %-45s \|\n",$project);
    print '|' . ('-' x 47) . "\|\n";
    foreach my $date (sort { "\U$a" cmp "\U$b" } keys %{$resume{$project}} ) {
        print sprintf("\|    %10s \| %5d \| %5d \| %5d \| %5d \|\n",
                      $date, 
                      $resume{$project}{$date}{views}{count},
                      $resume{$project}{$date}{views}{uniques},
                      $resume{$project}{$date}{clones}{count},
                      $resume{$project}{$date}{clones}{uniques});
    }
    print '|' . ('-' x 47) . "\|\n";
    print sprintf("\|         Total \| %5d \| %5d \| %5d \| %5d \|\n",
                  $totals{$project}{views}{count},
                  $totals{$project}{views}{uniques},
                  $totals{$project}{clones}{count},
                  $totals{$project}{clones}{uniques});
}
print '-' x 49 . "\n";
