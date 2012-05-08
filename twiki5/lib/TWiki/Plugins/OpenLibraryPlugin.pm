# file       : TWiki::Plugins::OpenLibraryPlugin
# description: OpenLibraryPlugin entry 
#            : 
#            : 
# auther     : FrankSoong
# date       : Mon May 07 21:53:48 CST 2012 
# copyright  : GPL
# 
# =========================
package TWiki::Plugins::OpenLibraryPlugin;


use vars qw( $VERSION $RELEASE $pluginName $upperPluginName $NO_PREFS_IN_TOPIC 
             $DEBUG $WARNING $GREETING $SHORTDESCRIPTION );

use TWiki::Plugins::OpenLibraryPlugin::OpenLibraryMainPage;

use strict;


$VERSION = '0.1';
$RELEASE = '0.1';
$pluginName = 'OpenLibraryPlugin';
$upperPluginName = 'OPENLIBRARYPLUGIN';
$NO_PREFS_IN_TOPIC = 0;

$DEBUG = 0;
$WARNING = 0;
$GREETING = 'Hello';
$SHORTDESCRIPTION = 'Open Library plugin that does nothing at all';


sub initPlugin {
    my( $topic, $web, $user, $installWeb ) = @_;
    
    $GREETING = TWiki::Func::getPreferencesValue( "$upperPluginName"."_GREETING" ) || "Stub";    
    $SHORTDESCRIPTION = TWiki::Func::getPreferencesValue( "$upperPluginName"."_SHORTDESCRIPTION" ) || "Stub";    
    $DEBUG = TWiki::Func::getPreferencesValue( "$upperPluginName"."_DEBUG") || 0;
    $WARNING = TWiki::Func::getPreferencesValue( "$upperPluginName"."_WARNING") || 0;
    my $syntax = "context-free";
    
    # For testing
    TWiki::Func::registerTagHandler( 'HELLOWORLD', \&_HELLOWORLD, $syntax );
    TWiki::Func::registerTagHandler( 'HELLOSOMEONE', \&_HELLOSOMEONE, $syntax );    
    TWiki::Func::registerTagHandler( 'PREFSFROMSPEC', \&_PREFSFROMSPEC, $syntax );
    TWiki::Func::registerTagHandler( 'PREFSFROMTOPIC', \&_PREFSFROMTOPIC, $syntax );
    # end
 
    TWiki::Func::registerTagHandler( 'MAIN', \&_MAIN, $syntax );
    
    return 1;
}

sub _MAIN{
    my($session, $params, $theTopic, $theWeb, $meta) = @_;    
    my $instance = new TWiki::Plugins::OpenLibraryPlugin::OpenLibraryMainPage($session, $params);
    return before_handler_tag().$instance->show().after_handler_tag(); 
}


sub _PREFSFROMSPEC {
    my($session, $params, $theTopic, $theWeb, $meta) = @_;    
    my $greeting = $TWiki::cfg{Plugins}{OpenLibraryPlugin}{Greeting} || "Stub";    
    return $greeting;
}

sub _PREFSFROMTOPIC {
    my($session, $params, $theTopic, $theWeb, $meta) = @_;
    return "$GREETING <br> $SHORTDESCRIPTION <br> $DEBUG <br> $WARNING";
}


sub _HELLOWORLD {
    my($session, $params, $theTopic, $theWeb, $meta) = @_;  
    return "Hello World, OpenLibraryPlugin";
}


sub _HELLOSOMEONE {
    my($session, $params, $theTopic, $theWeb, $meta) = @_;
    
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

sub before_handler_tag{
    # stub
}

sub after_handler_tag{
    # stub
}


