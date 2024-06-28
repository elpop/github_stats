# github_stats
Simple script to show the repositories info using the GitHub API

![stats ansi](https://raw.githubusercontent.com/elpop/github_stats/main/github_stats_ansi.png)

![stats text](https://raw.githubusercontent.com/elpop/github_stats/main/github_stats_text.png)


## Install

1. Download file
  
    ```
    git clone https://github.com/elpop/github_stats.git
    ```  
    
2. Perl Dependencies

    [JSON](https://metacpan.org/pod/JSON)

    [LWP::UserAgent](https://metacpan.org/pod/LWP::UserAgent)
    
    [Config::Simple](https://metacpan.org/pod/Config::Simple)
    
    [Getopt::Long](https://metacpan.org/pod/Getopt::Long)
        
    All the Perl Modules are available via [metacpan](https://metacpan.org) or install them via the "cpan" program in your system. Debian/Ubuntu and Fedora have packages for the required perl modules.
    
    for Fedora/Redhat:
    
    ```
    sudo dnf install perl-JSON perl-libwww-perl perl-LWP-Protocol-https perl-Config-Simple perl-Getopt-Long
    ```
    
    for Debian/Ubuntu:
    
    ```
    sudo apt-get install libjson-perl libwww-perl liblwp-protocol-https-perl libconfig-simple-perl
    sudo cpan -i Getopt::Long
    ```
    
    On Mac OS:

    To compile some Perl modules, you need to install the 
    Xcode Command Line Tools:
 
    ```
    xcode-select --install
    ```

    Install with CPAN:
    
    ```
    sudo cpan -i JSON LWP::UserAgent LWP::Protocol::https Config::Simple Getopt::Long
    ```

3. Obtain your Github Token

   In order to work with the program, you must obtain a developer API access token from Github:
   
   [Managing your personal access tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)

4. Copy and edit **etc/github_stats.conf** 

    ```
    sudo cp etc/github_stats.conf /etc/.
    ```
    
    ```
    sudo vim etc/github_stats.conf
    ```
    
    Change the values according your user and Github Access Token:
    
    ```
    [github]
    user = 'YOUR_GITHUB_USER'
    token = 'YOUR_GITHUB_TOKEN'    
    ```
    
5. Put it on your search path
    
    Copy the github_stats.pl program somewhere in your search path:
    
    ```
    sudo cp github_stats.pl /usr/local/bin/.
    ```

## Sponsor the project

Please [sponsor this project](https://github.com/sponsors/elpop), to pay my high debt on credit cards :)
