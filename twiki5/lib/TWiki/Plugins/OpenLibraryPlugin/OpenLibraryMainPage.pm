# file       : TWiki::Plugins::OpenLibraryPlugin::OpenLibraryMainPage
# description: OpenLibraryMainPage
#            : 
#            : 
# auther     : FrankSoong
# date       : Mon May 07 21:53:48 CST 2012 
# copyright  : GPL
# 
# =========================
package TWiki::Plugins::OpenLibraryPlugin::OpenLibraryMainPage;

use base TWiki::Plugins::OpenLibraryPlugin::Prototype;
use strict;

sub new {
    my ($className, $session, $attributes) = @_;
    my $this = bless( {className=>$className}, $className);
    $this->init();
    return $this;
}

sub init{
    my $this = shift;    
}

sub get_data{
    my $this = shift;   
}

sub show{
    my $this = shift;
    $this->show_content(); 
}


sub show_content{
    my $this = shift;
    return "<div>$this->{pluginName} 11</div>";
}




1;
