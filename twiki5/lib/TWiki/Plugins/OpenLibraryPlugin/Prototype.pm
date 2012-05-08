# file       : TWiki::Plugins::OpenLibraryPlugin::Prototype
# description: Prototype the base class for OpenLibraryPlugin
#            : 
#            : 
# auther     : FrankSoong
# date       : Mon May 07 21:53:48 CST 2012 
# copyright  : GPL
# 
# =========================
package TWiki::Plugins::OpenLibraryPlugin::Prototype;

use vars qw( $pluginName $DEBUG $WARNING );

# For dump data
use Data::Dumper;
use strict;


sub new {
    my ($className, $session, $attributes) = @_;
    my $this = bless( {className=>$className}, $className);
    $this->init();
    return $this;    
}

sub init{
    my ($this) = @_; 
    $this->get_config();
    $this->{debug} = $DEBUG || 0;
    $this->{warning} = $WARNING || 0;
    $this->{pluginName} = $pluginName || "stub";
}

sub get_config{
    my ($this) = @_; 
}

sub test_class_name{
    my $this = shift;
    return "$this->{className}";
}


sub debug{
    my ($this, $text) = @_;
    if( defined $this->{debug} and $this->{debug} > 0){
        TWiki::Func::writeDebug( "$text" );
    }
}

1;
