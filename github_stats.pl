#!/usr/bin/perl
#=====================================================================#
# Program => github_stats.pl (In Perl 5.30)             version 1.0.0 #
#=====================================================================#
# Autor         => Fernando "El Pop" Romo          (pop@cofradia.org) #
# Creation date => 19/Jun/2024                                        #
#---------------------------------------------------------------------#
# Info => Simple script to show the repositories info using the       #
#         GitHub Developer API.                                       #
#---------------------------------------------------------------------#
# This code are released under the GPL 3.0 License. Any change must   #
# be report to the authors                                            #
#                     (c) 2024 - Fernando Romo                        #
#=====================================================================#
#use strict;
use JSON;
use LWP::UserAgent;
use Config::Simple;

my $Config = new Config::Simple('/etc/github_stats.conf');

my @reports  = ('clones', 'views');
my %projects = ();
my $user = $Config->param('github.user');
my %resume = ();
my %totals = ();

sub get_info {
    my $url = shift;
    my $json = '';
    my $ua = LWP::UserAgent->new(
        agent => 'GitHubStats/1.0',
        keep_alive => 1,
        env_proxy  => 1,
        ssl_opts => { verify_hostname => 0,
                      SSL_verify_mode => 0x00,
                    },
    );
    my $res = $ua->request(
        HTTP::Request->new(GET => $url,
            # Insert thee Authentication Headers requested by GitHub API
            HTTP::Headers->new('Accept' => 'application/vnd.github+json',
                               'Authorization' => 'Bearer '. $Config->param('github.token'),
                               'X-GitHub-Api-Version' => '2022-11-28'),
            ),
            sub {
                $json .= $_[0];
            }
        );
    undef $ua;
    return $json;
} #End get_info()

#-----------#
# Main body #
#-----------#

# Get Repositories from user
my $msg_ref = from_json(get_info("https://api.github.com/search/repositories?q=user:$user"));
if (ref($msg_ref->{items}) eq 'ARRAY') {
    for (my $i=0; $i <= (@{ $msg_ref->{items} } - 1) ; $i++) {
        $projects{$msg_ref->{items}->[$i]->{name}}{private} = "$msg_ref->{items}->[$i]->{private}";
        $projects{$msg_ref->{items}->[$i]->{name}}{forks} = $msg_ref->{items}->[$i]->{forks_count};
        $projects{$msg_ref->{items}->[$i]->{name}}{starts} = $msg_ref->{items}->[$i]->{stargazers_count};
        $projects{$msg_ref->{items}->[$i]->{name}}{created_at} = $msg_ref->{items}->[$i]->{created_at};
        $projects{$msg_ref->{items}->[$i]->{name}}{updated_at} = $msg_ref->{items}->[$i]->{updated_at};
    }
}

# Download each repository info (Clones and Views)
foreach my $project ( sort { "\U$a" cmp "\U$b" } keys %projects ) {
    foreach my $report (@reports) {
        my $msg_ref = from_json(get_info("https://api.github.com/repos/$user/$project/traffic/$report"));
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

# Detail
foreach my $project (sort { "\U$a" cmp "\U$b" } keys %resume) {
    print '-' x 49 . "\n";
    my $repo_type = 'Public';
    if ($projects{$project}{private}) {
        $repo_type = 'Private';
    }
    print sprintf("\| %-45s \|\n", $project);
    print '|' . ('-' x 47) . "\|\n";
    print sprintf("\|     Created: %-32s \|\n\|     Updated: %-32s \|\n",
                  $projects{$project}{created_at},
                  $projects{$project}{updated_at});
    print '|' . ('-' x 47) . "\|\n";
    print sprintf("\|     Starts: %5d Forks: %5d    ( %7s ) \|\n",
                  $projects{$project}{starts},
                  $projects{$project}{forks},
                  $repo_type);
    print '|' . ('-' x 47) . "\|\n";
    print '|               |     Views     |     Clones    |' . "\n";
    print '|  Date (Zulu)  |---------------|---------------|' . "\n";
    print '|               |   C   |   U   |   C   |   U   |' . "\n";
    print '|' . ('-' x 47) . "\|\n";
    foreach my $date (sort { "\U$a" cmp "\U$b" } keys %{$resume{$project}} ) {
        print sprintf("\|    %10s \| %5d \| %5d \| %5d \| %5d \|\n",
                      $date,
                      $resume{$project}{$date}{views}{count},
                      $resume{$project}{$date}{views}{uniques},
                      $resume{$project}{$date}{clones}{count},
                      $resume{$project}{$date}{clones}{uniques});
    }
    # Totals
    print '|' . ('-' x 47) . "\|\n";
    print sprintf("\|         Total \| %5d \| %5d \| %5d \| %5d \|\n",
                  $totals{$project}{views}{count},
                  $totals{$project}{views}{uniques},
                  $totals{$project}{clones}{count},
                  $totals{$project}{clones}{uniques});
    print '-' x 49 . "\n\n";

}
# End Main Body #