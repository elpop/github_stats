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
use Data::Dumper;

my $Config = new Config::Simple('/etc/github_stats.conf');

my @reports  = ('clones', 'views');
my @projects = $Config->param('github.repositories');
my $user = $Config->param('github.user');
my %resume = ();
my %totals = ();

sub get_stats {
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
} #End get_stats()

#-----------#
# Main body #
#-----------#

# Download each repository info (Clones and Views)
foreach my $project ( @projects ) {
    foreach my $report (@reports) {
        my $msg_ref = from_json(get_stats("https://api.github.com/repos/$user/$project/traffic/$report"));
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

# Report Header
print '-' x 49 . "\n";
print '| Project       |     Views     |     Clones    |' . "\n";
print '|---------------|---------------|---------------|' . "\n";
print '|        Date   |   C   |   U   |   C   |   U   |' . "\n";

# Detail
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
    # Totals
    print '|' . ('-' x 47) . "\|\n";
    print sprintf("\|         Total \| %5d \| %5d \| %5d \| %5d \|\n",
                  $totals{$project}{views}{count},
                  $totals{$project}{views}{uniques},
                  $totals{$project}{clones}{count},
                  $totals{$project}{clones}{uniques});
}
print '-' x 49 . "\n";

# End Main Body #
