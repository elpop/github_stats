# github_stats
Simple script to show the repositories info using the GitHub API

![stats sample](https://raw.githubusercontent.com/elpop/github_stats/main/github_stats_sample.png)


## Install

1. Download file
  
    ```
    git clone https://github.com/elpop/github_stats.git
    ```  
    
2. Perl Dependencies

    [JSON](https://metacpan.org/pod/JSON)

    [LWP::UserAgent](https://metacpan.org/pod/LWP::UserAgent)
    
    [Config::Simple](https://metacpan.org/pod/Config::Simple)
        
    All the Perl Modules are available via [metacpan](https://metacpan.org) or install them via the "cpan" program in your system. Debian/Ubuntu and Fedora have packages for the required perl modules.
    
    for Fedora/Redhat:
    
    ```
    sudo dnf install perl-JSON perl-libwww-perl perl-LWP-Protocol-https perl-Config-Simple
    ```
    
    for Debian/Ubuntu:
    
    ```
    sudo apt-get install libjson-perl libwww-perl liblwp-protocol-https-perl libconfig-simple-perl
    ```
    
    On Mac OS:

    To compile some Perl modules, you need to install the 
    Xcode Command Line Tools:
 
    ```
    xcode-select --install
    ```

    Install with CPAN:
    
    ```
    sudo cpan -i JSON LWP::UserAgent LWP::Protocol::https Config::Simple
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
