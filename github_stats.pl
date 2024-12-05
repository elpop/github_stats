#!/usr/bin/perl
#======================================================================#
# Program => github_stats.pl (In Perl 5.30)              version 1.0.0 #
#======================================================================#
# Autor         => Fernando "El Pop" Romo           (pop@cofradia.org) #
# Creation date => 19/Jun/2024                                         #
#----------------------------------------------------------------------#
# Info => Simple script to show the repositories info using the        #
#         GitHub Developer API.                                        #
#----------------------------------------------------------------------#
#        This code are released under the GPL 3.0 License.             #
#                                                                      #
#                     (c) 2024 - Fernando Romo                         #
#                                                                      #
# This program is free software: you can redistribute it and/or modify #
# it under the terms of the GNU General Public License as published by #
# the Free Software Foundation, either version 3 of the License, or    #
# (at your option) any later version.                                  #
#                                                                      #
# This program is distributed in the hope that it will be useful, but  #
# WITHOUT ANY WARRANTY; without even the implied warranty of           #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU    #
# General Public License for more details.                             #
#                                                                      #
# You should have received a copy of the GNU General Public License    #
# along with this program. If not, see <https://www.gnu.org/licenses/> #
#======================================================================#
use strict;
use JSON;           # read and write json
use LWP::UserAgent; # Web user agent class
use Getopt::Long;   # Handle the arguments passed to the program
use Config::Simple; # read config file

# Terminal Colors
use constant {
    RESET     => "\033[0m",
    BRIGHT    => "\033[1m",
    DIM       => "\033[2m",
    UNDERLINE => "\033[3m",
    BLINK     => "\033[5m",
    REVERSE   => "\033[7m",
    HIDDEN    => "\033[8m",

    FG_BLACK    => "\033[30m",
    FG_RED      => "\033[31m",
    FG_GREEN    => "\033[32m",
    FG_YELLOW   => "\033[33m",
    FG_BLUE     => "\033[34m",
    FG_MAGENTA  => "\033[35m",
    FG_CYAN     => "\033[36m",
    FG_WHITE    => "\033[37m",

    FG_BRIGHT_BLACK    => "\033[90m",
    FG_BRIGHT_RED      => "\033[91m",
    FG_BRIGHT_GREEN    => "\033[92m",
    FG_BRIGHT_YELLOW   => "\033[93m",
    FG_BRIGHT_BLUE     => "\033[94m",
    FG_BRIGHT_MAGENTA  => "\033[95m",
    FG_BRIGHT_CYAN     => "\033[96m",
    FG_BRIGHT_WHITE    => "\033[97m",

    BG_BLACK    => "\033[40m",
    BG_RED      => "\033[41m",
    BG_GREEN    => "\033[42m",
    BG_YELLOW   => "\033[43m",
    BG_BLUE     => "\033[44m",
    BG_MAGENTA  => "\033[45m",
    BG_CYAN     => "\033[46m",
    BG_WHITE    => "\033[47m",

    BG_BRIGHT_BLACK    => "\033[100m",
    BG_BRIGHT_RED      => "\033[101m",
    BG_BRIGHT_GREEN    => "\033[102m",
    BG_BRIGHT_YELLOW   => "\033[103m",
    BG_BRIGHT_BLUE     => "\033[104m",
    BG_BRIGHT_MAGENTA  => "\033[105m",
    BG_BRIGHT_CYAN     => "\033[106m",
    BG_BRIGHT_WHITE    => "\033[107m",

};

my %matrix_options = ('color' => { 'project'  => BG_RED    . BRIGHT . FG_BRIGHT_WHITE,
                                   'header'   => BG_WHITE  . BRIGHT . FG_BLACK,
                                   'header_2' => BG_BRIGHT_WHITE  . BRIGHT . FG_BLACK,
                                   'info'     => BG_BRIGHT_YELLOW . BRIGHT . FG_BLACK,
                                   'date'     => BG_BRIGHT_WHITE  . BRIGHT . FG_BLACK,
                                   'c'        => BG_BRIGHT_CYAN   . FG_BLACK,
                                   'u'        => BG_BRIGHT_WHITE  . FG_BLACK,
                                   'c_header' => BG_CYAN   . FG_BLACK,
                                   'u_header' => BG_WHITE  . FG_BLACK, }, );



my $Config = new Config::Simple('/etc/github_stats.conf');

my %options = ();
GetOptions(\%options,
           'text',
);

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
            # Insert the Authentication Headers requested by GitHub API
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

sub project_summary_text {
    my $project = shift;
    print '-' x 47 . "\n";
    my $repo_type = 'Public';
    if ($projects{$project}{private}) {
        $repo_type = 'Private';
    }
    print sprintf("\| %-31s ( %7s ) \|\n", $project, $repo_type);
    print '|' . ('-' x 45) . "\|\n";
    print sprintf("\|        Created: %-27s \|\n\|        Updated: %-27s \|\n",
                  $projects{$project}{created_at},
                  $projects{$project}{updated_at});
    print '|' . ('-' x 45) . "\|\n";
    print sprintf("\|  Starts: %-5d  Forks: %-5d  Issues: %-5d \|\n",
                  $projects{$project}{starts},
                  $projects{$project}{forks},
                  $projects{$project}{issues});
    if ( exists($resume{$project}) ) {
        # Detail
        print '|' . ('-' x 45) . "\|\n";
        print '|             |    Visitors   |    Clones     |' . "\n";
        print '| Date (Zulu) |---------------|---------------|' . "\n";
        print '|             |   V   |   U   |   C   |   U   |' . "\n";
        print '|-------------|-------|-------|-------|-------|' . "\n";
        foreach my $date (sort { "\U$a" cmp "\U$b" } keys %{$resume{$project}} ) {
            print sprintf("\| %10s  \| %5d \| %5d \| %5d \| %5d \|\n",
                          $date,
                          $resume{$project}{$date}{views}{count},
                          $resume{$project}{$date}{views}{uniques},
                          $resume{$project}{$date}{clones}{count},
                          $resume{$project}{$date}{clones}{uniques});
        }
        # Totals
        print '|-------------|-------|-------|-------|-------|' . "\n";
        print sprintf("\|      Totals \| %5d \| %5d \| %5d \| %5d \|\n",
                      $totals{$project}{views}{count},
                      $totals{$project}{views}{uniques},
                      $totals{$project}{clones}{count},
                      $totals{$project}{clones}{uniques});
    }
    print '-' x 47 . "\n\n";
} # End project_summary_text()

sub project_summary_ansi {
    my $project = shift;
    my $repo_type = 'Public';
    if ($projects{$project}{private}) {
        $repo_type = 'Private';
    }
    print sprintf($matrix_options{color}{project} . " %-28s (%7s ) " . RESET . "\n", $project, $repo_type);
    print sprintf($matrix_options{color}{header} . "    Created: %-27s ". RESET . "\n" .
                  $matrix_options{color}{header} . "    Updated: %-27s " . RESET . "\n",
                  $projects{$project}{created_at},
                  $projects{$project}{updated_at});
    print sprintf($matrix_options{color}{info} ." Starts: %-5d Forks: %-5d Issues: %-5d" . RESET . "\n",
                  $projects{$project}{starts},
                  $projects{$project}{forks},
                  $projects{$project}{issues});
    if ( exists($resume{$project}) ) {
        # Detail
        print $matrix_options{color}{header_2} . ' Date (Zulu)    Visitors       Clones    ' . RESET . "\n";
        print $matrix_options{color}{header} . '             ' .
                          $matrix_options{color}{c_header} . '   V   ' .
                          $matrix_options{color}{u_header} . '   U   ' .
                          $matrix_options{color}{c_header} . '   C   ' .
                          $matrix_options{color}{u_header} . '   U   ' .
                          RESET . "\n";
        foreach my $date (sort { "\U$a" cmp "\U$b" } keys %{$resume{$project}} ) {
            print sprintf($matrix_options{color}{date} . "  %10s " .
                          $matrix_options{color}{c} . " %5d " .
                          $matrix_options{color}{u} . " %5d " .
                          $matrix_options{color}{c} . " %5d " .
                          $matrix_options{color}{u} . " %5d " .
                          RESET . "\n",
                          $date,
                          $resume{$project}{$date}{views}{count},
                          $resume{$project}{$date}{views}{uniques},
                          $resume{$project}{$date}{clones}{count},
                          $resume{$project}{$date}{clones}{uniques});
        }
        # Totals
        print sprintf($matrix_options{color}{header} . '      Totals ' .
                      $matrix_options{color}{c_header} . " %5d " .
                      $matrix_options{color}{u_header} . " %5d " .
                      $matrix_options{color}{c_header} . " %5d " .
                      $matrix_options{color}{u_header} . " %5d " .
                      RESET . "\n",
                      $totals{$project}{views}{count},
                      $totals{$project}{views}{uniques},
                      $totals{$project}{clones}{count},
                      $totals{$project}{clones}{uniques});
    }
    print "\n";
} # End project_summary_ansi()

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
        $projects{$msg_ref->{items}->[$i]->{name}}{issues} = $msg_ref->{items}->[$i]->{open_issues_count};
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
    if ($options{'text'}) {
        project_summary_text($project);
    }
    else {
        project_summary_ansi($project);
    }
    %resume = ();
    %totals = ();
}

# End Main Body #