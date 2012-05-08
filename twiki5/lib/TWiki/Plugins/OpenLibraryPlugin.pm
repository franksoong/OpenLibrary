# Plugin for TWiki Collaboration Platform, http://TWiki.org/
#
# =========================
package TWiki::Plugins::OpenLibraryPlugin;


use strict;
use vars qw( $VERSION $RELEASE $GREETING $SHORTDESCRIPTIO $pluginName  $DEBUG $upperPluginName);
$VERSION = '0.1';
$RELEASE = '0.1';
$GREETING = 'ppp';
$SHORTDESCRIPTIO = 'Open Library plugin that does nothing at all';
$pluginName = 'OpenLibraryPlugin';
$upperPluginName = 'OPENLIBRARYPLUGIN';

sub initPlugin {
    my( $topic, $web, $user, $installWeb ) = @_;
    
    $GREETING = TWiki::Func::getPreferencesValue( 'OPENLIBRARYPLUGIN_GREETING' ) || "Hello Stub";
    
    $SHORTDESCRIPTIO = TWiki::Func::getPreferencesValue( 'OPENLIBRARYPLUGIN_SHORTDESCRIPTIO' ) || "Stub";
    
    $DEBUG = TWiki::Func::getPreferencesValue('OPENLIBRARYPLUGIN_Debug') || -1;
    
    TWiki::Func::registerTagHandler( 'HELLOWORLD', \&_HELLOWORLD );
    TWiki::Func::registerTagHandler( 'HELLOSOMEONE', \&_HELLOSOMEONE );
    
    TWiki::Func::registerTagHandler( 'PREFSFROMSPEC', \&_PREFSFROMSPEC );
    TWiki::Func::registerTagHandler( 'PREFSFROMTOPIC', \&_PREFSFROMTOPIC );
 
    return 1;
}

sub _PREFSFROMSPEC {
    my($session, $params, $theTopic, $theWeb) = @_;
    
    my $greeting = $TWiki::cfg{Plugins}{OpenLibraryPlugin}{Greeting} || "Hello";
    
    return "$greeting";
}

sub _PREFSFROMTOPIC {
    my($session, $params, $theTopic, $theWeb) = @_;

    
    return "$GREETING <br> $SHORTDESCRIPTIO";
}


sub _HELLOWORLD {
    my($session, $params, $theTopic, $theWeb) = @_;
  
    return "Hello World, OpenLibraryPlugin";
}


sub _HELLOSOMEONE {
    my($session, $params, $theTopic, $theWeb) = @_;
    
    my $defaulttext = $params->{_DEFAULT} || '';
    my $someoneelse = $params->{someoneelse} || '';
    my $yetanother = $params->{yetanother} || '';
    
    my $text = '';
    $text .= " $defaulttext" if $defaulttext;
    $text .= " and" if ($text && $someoneelse);
    $text .= " $someoneelse" if $someoneelse;
    $text .= " and" if ($text && $yetanother );
    $text .= " $yetanother" if $yetanother;
    $text = "Hello" . $text;
    
    return $text;
}

