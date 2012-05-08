package TWiki::Plugins::HelloWorldPlugin; 


use vars qw( $Demo $Debug );

sub initPlugin {
    my( $topic, $web, $user, $installWeb ) = @_;

    # check for Plugins.pm versions
    if( $TWiki::Plugins::VERSION < 1.1 ) {
        TWiki::Func::writeWarning( "Version mismatch between $pluginName and Plugins.pm" );
        return 0;
    }

    # Example code of how to get a preference value, register a variable handler
    # and register a RESTHandler. (remove code you do not need)

    # Set plugin preferences in LocalSite.cfg, like this:
    # $TWiki::cfg{Plugins}{EmptyPlugin}{ExampleSetting} = 1;
    # Always provide a default in case the setting is not defined in
    # LocalSite.cfg. See TWiki.TWikiPlugins for help in adding your plugin
    # configuration to the =configure= interface.
    my $setting = $TWiki::cfg{Plugins}{HelloWorldPlugin}{ExampleSetting} || 0;
    $debug = $TWiki::cfg{Plugins}{HelloWorldPlugin}{Debug} || 0;
    
    $Demo = TWiki::Func::getPreferencesValue( 'HELLOWORLDPLUGIN_DD' ) || "STUB";
    $Debug = TWiki::Func::getPreferencesValue( 'HELLOWORLDPLUGIN_Debug' ) || "STUB";
    

    # register the _EXAMPLEVAR function to handle %EXAMPLEVAR{...}%
    # This will be called whenever %EXAMPLEVAR% or %EXAMPLEVAR{...}% is
    # seen in the topic text.
    TWiki::Func::registerTagHandler( 'HelloWorld', \&_myHelloWorld );
    TWiki::Func::registerTagHandler( 'OUT', \&_OUT );

    # Allow a sub to be called from the REST interface using the provided alias.
    # To invoke, call /twiki/bin/rest/EmptyPlugin/example.
    # TWiki::Func::registerRESTHandler('example', \&_restExample);

    # Plugin correctly initialized
    return 1;
}


sub _OUT {
    my($session, $params, $theTopic, $theWeb, $meta, $textRef) = @_;

	return "$Demo <br> $Debug";
}

sub _myHelloWorld {
    my($session, $params, $theTopic, $theWeb, $meta, $textRef) = @_;
    # $session  - a reference to the TWiki session object (if you don't know
    #             what this is, just ignore it)
    # $params=  - a reference to a TWiki::Attrs object containing parameters.
    #             This can be used as a simple hash that maps parameter names
    #             to values, with _DEFAULT being the name for the default
    #             parameter.
    # $theTopic - name of the topic in the query
    # $theWeb   - name of the web in the query
    # $meta     - topic meta-data to use while expanding, can be undef (Since TWiki::Plugins::VERSION 1.4)
    # $textRef  - reference to unexpanded topic text, can be undef (Since TWiki::Plugins::VERSION 1.4)

    # Return: the result of processing the variable

    # For example, %EXAMPLEVAR{'existence' proof="thinking"}%
    # $params->{_DEFAULT} will be 'existence'
    # $params->{proof} will be 'thinking'

    return 'my test....soong!';
}




1;
