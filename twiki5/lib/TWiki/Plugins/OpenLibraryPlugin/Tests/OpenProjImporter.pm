# Copyright (C) 2008 HengSoft
# Author: Frank Soong
# This file implement the XMLParser && OpenProjImporter
# =========================
package TWiki::Plugins::OpenToolChainPlugin::Import::OpenProjImporter;

use base TWiki::Plugins::OpenToolChainPlugin::Prototype;
use TWiki::Plugins::OpenToolChainPlugin::Util;
# for manipulate xml
# use lib qw(/var/www/html/twiki/lib);
use XML::Parser;
use XML::SimpleObject;
use XML::SimpleObject::LibXML;


use TWiki::Plugins::OpenToolChainPlugin::Import::FileData;
use TWiki::Plugins::OpenToolChainPlugin::Create::CreateProject;
use TWiki::Plugins::OpenToolChainPlugin::Create::CreateFeature;
use TWiki::Plugins::OpenToolChainPlugin::Create::CreateTask;

# For dump data
use Data::Dumper;
use strict;


#Function            :new
#Author              :FrankS
#Description         :New and init an Object
#Input               :Nothing
#Output              :Reference of this 
sub new {
    my ($className, $session, $attributes) = @_;
    my $this = bless( {className=>$className}, $className);
    $this->{session}    = $session; 
    $this->{topic}      = $session->{topicName};
    $this->{web}        = $session->{webName};
    $this->{attributes} = $attributes;
    $this->{query}      = $session->{cgiQuery};
    $this->{file}       = '';
    $this->{rawdata}    = [];
    $this->{resourcedata}=[];
    $this->{data}       = [];

    $this->{deubg_flag}              =1;    
	$this->init();
    return $this;
}


sub init{
	my ($this)=@_;
	$this->getConfigure();	
	$this->{js_dir}	         = TWiki::Func::getUrlHost().TWiki::Func::getPubUrlPath().'/TWiki/OpenToolChainPlugin/js';
	$this->{actionUrl}       = TWiki::Func::getScriptUrl($this->{session}->{webName}, $this->{session}->{topicName}, 'ajax');
    $this->{prepareData}     = "_prepareData"; 
    $this->{importData}      = "_importData"; 
    $this->{file_options}    = '<option></option>';
    #for js tips 
    $this->{errortype}       = { hiererchy_exceed_error   =>  {errorcode => 'W101',},
                                 xml_file_format_error    =>  {errorcode => 'E102',},
                                 project_name_conflict    =>  {errorcode => 'W103',},
                                 resource_nonlegal        =>  {errorcode => 'E104',},
                                 project_no_resource      =>  {errorcode => 'E105',},
                                 feature_no_resource      =>  {errorcode => 'E106',},
                                 other_error              =>  {errorcode => 'E107',},   };
    $this->initJS(); 
    $this->setFileOptions();
	return ;
}


sub show{
	my ($this) = @_;
	my $ret = "<h2>Improt From OpenProj</h2>";
	$ret .= $this->showPanel();
	$ret .= $this->showLog();	
	#$ret .= "<script>alert('heh');</script>";
	return $ret;
}
	
sub showPanel{
	my ($this) = @_;
	my $ret = '';
	$ret .=<<"EOF";
<div style="border-style: solid; border-width: 1px; padding: 15px" id="import_ui_design">
	<table style='border-width: 0px;'><tr class='bg' >
		<td style='width:150px;'><b>Choose Import File: </b></td>
		<td align='right'><select id='import_file' style='width:100%;' onchange='_onchange(this)'>$this->{file_options}</select></td>
	</tr><tr>
		<td><b>You have chosen file:</b><div id='file_name_div' align='center' style='color:green;' ></div></td>
		<td align='right'><button id='import_fire' onclick='_import("import_file")'>Begin To Import...</button></td>
	</tr></table>	
</div>
EOF
	return $ret;
}

sub showLog{
	my ($this) = @_;  # //display:none;
	my $ret = '';
	$ret .=<<"EOF";
<div id='import_log_div' style="display:none;padding: 15px 0px 0 0;"> 
	<textarea id='import_log' rows=10 wrap='soft' style='width:100%;'></textarea>
</div>
EOF
	return $ret;
}
	
=cut
	$this->setFile('www.xml');
	$this->parseXMLData();
	$this->buildTree();
	$ret.=Dumper( @{$this->{rawdata}} )."<br><br><br>";
	$ret.=Dumper( @{$this->{data}} );
	my $content={};
	$ret.=$this->parseTree($this->{data},$content);
=cut

sub _importData{
	my ($this) = @_;
	my $ret = "IMPORT IS FINISHED!\n";
	my $file = $this->{query}->param("file");
	my $project = [];
	$this->setFile($file);
	$this->parseXMLData();
	$this->buildTree();
=cut	
	$project = $this->doImport();
	my $temp = &arrayToStr($project);
	$ret = $temp  ?  "You have import [$temp] to Project Management!"   :   "You have import nothing to Project Management!";	
	
=cut	
	#next session, you should do check again
	if ( $this->checkTree() ){
		# pass
		$project = $this->doImport();
		my $temp = &arrayToStr($project);
		$ret .= $temp  ?  "You have import [$temp] to Project Management!"   :   "You have import nothing to Project Management!";	
		#my $content={};
		#$ret .= "IMPORT SUCCESSED!\n";
		#$ret .= $this->parseTree($this->{data},$content);			
	} else {
		# fail, so check the error,  this can not be happen.
	
	}	
	print CGI::header();
	print $ret;
}

sub _prepareData{
	my ($this) = @_;
	my $ret = '';
	my $file = $this->{query}->param("file");
	$this->setFile($file);
	$this->parseXMLData();
	$this->buildTree();
	$this->checkTree();
		
	if ( $this->{errortype}->{resource_nonlegal}->{value} ) {
		$ret .= $this->{errortype}->{resource_nonlegal}->{error_info};
		#goto END;
		$ret .= 'gnoos,';
	}
	if ( $this->{errortype}->{project_no_resource}->{value} ) {
		$ret .= $this->{errortype}->{project_no_resource}->{error_info};
		#goto END;
		$ret .= 'gnoos,';
	}
	if ( $this->{errortype}->{feature_no_resource}->{value} ) {
		$ret .= $this->{errortype}->{feature_no_resource}->{error_info};
		#goto END;
		$ret .= 'gnoos,';
	}
	if ( $this->{errortype}->{hiererchy_exceed_error}->{value} ) {
		$ret .= $this->{errortype}->{hiererchy_exceed_error}->{error_info};
		#goto END;
		$ret .= 'gnoos,';
	}
	if ( $this->{errortype}->{project_name_conflict}->{value} ) {
		$ret .= $this->{errortype}->{project_name_conflict}->{error_info};
		#goto END;
		$ret .= 'gnoos,';
	}	
	
	$ret =~ s/gnoos,$//g if $ret;
	#END:
	print CGI::header();
	print $ret;
}

sub checkTree{
	my ($this) = @_;
	return 1  if  $this->checkProject() && $this->checkResource();	
	return 0;
}
sub checkResource{
	my ($this) = @_;
	my ($st,$res);
	#step1: check illegal for all resource
	#step2: check project have assignment
	#step3: check feature have assignment
=cut	
	foreach my $item ( @{$this->{resourcedata}} ){	
	    $st = "SELECT COUNT(*) count FROM profiles WHERE realname = '$item'";
	    $res = $this->execute($st);
	    if ( ! $res->[0]->{count} ) {
	        $this->{errortype}->{resource_nonlegal}->{value} = 1;
	        $this->{errortype}->{resource_nonlegal}->{error_info} = 
	        "ERROR: Resource: $item is not exists in the database, please replace with an illegal resource name.";
	        return 0;
	    }
	}
=cut	
	#check all the project resource
	foreach my $pitem ( @{$this->{data}} ){	
		foreach my $item ( @{$pitem->{assignto}} ){
	    	$st = "SELECT COUNT(*) count FROM profiles WHERE realname = '$item'";
	    	$res = $this->execute($st);
	    	if ( ! $res->[0]->{count} ) {
	        	$this->{errortype}->{resource_nonlegal}->{value} = 1;
	        	$this->{errortype}->{resource_nonlegal}->{error_info} = 
	        	"ERROR[$this->{errortype}->{resource_nonlegal}->{errorcode}]: Resource [$item] is not exists in company, please check and replace with an illegal resource name.";
	       		return 0;
	    	}
		}
	}
	foreach my $item ( @{$this->{data}} ){		    
	    if ( !  scalar @{$item->{assignto}} ) {
	        $this->{errortype}->{project_no_resource}->{value} = 1;
	        $this->{errortype}->{project_no_resource}->{error_info} = 
	        "ERROR[$this->{errortype}->{project_no_resource}->{errorcode}]: Project [$item->{name}] has no resource assignment, please assign resource for this project.";
	        return 0;
	    }
	}
	foreach my $pitem ( @{$this->{data}} ){		    
	    if (defined $pitem->{child}){
	        my $feature = $pitem->{child};
			foreach my $fitem ( @$feature ){
			    if ( !  scalar @{$fitem->{assignto}} ) {
	                $this->{errortype}->{feature_no_resource}->{value} = 1;
	                $this->{errortype}->{feature_no_resource}->{error_info} = 
	                "ERROR[$this->{errortype}->{feature_no_resource}->{errorcode}]: Feature [$fitem->{name}] has no resource assignment, please assign resource for this feature.";	                
	                return 0;
	            }			
			}
	    }
	}	
	return 1;
}
sub checkProject{
	my ($this) = @_;
	my ($st,$res);
	my $filter = {};
	my @data   = ();
	my $duplicatestr = '';
	my @duplicate    = ();
	foreach my $pitem ( @{$this->{data}} ){	
	    $st = "SELECT COUNT(*) count FROM projects WHERE name='$pitem->{name}'";
	    $res = $this->execute($st);
	    if ( $res->[0]->{count} ) {	
	    	push @duplicate, $pitem->{name};
	        $duplicatestr .= "$pitem->{name}, ";
	        $this->{errortype}->{project_name_conflict}->{value} = 1;	        
	        #return 0;	        
	        #fill the filter	        
	        $filter->{$pitem->{name}} = 1;
	    }
	}	
	#filter the data
	foreach my $pitem ( @{$this->{data}} ){	
		push @data, $pitem if ! $filter->{$pitem->{name}};		
	}
	$duplicatestr = &cutTail($duplicatestr)  if $duplicatestr;
	$st           = (scalar @duplicate)>1   ?   
					"Projects [$duplicatestr] were already exist, you can insist to continue, but these projects will be ignored."   :   
					"Project [$duplicatestr] was already exists, you can insist to continue, but this project will be ignored.";
	$this->{errortype}->{project_name_conflict}->{project_name} = \@duplicate;
	$this->{errortype}->{project_name_conflict}->{error_info} = 
	"WARNING[$this->{errortype}->{project_name_conflict}->{errorcode}]: $st";
	
	$this->{data} = \@data;	
	return 1;
}

sub doImport{
	my ($this) = @_;
	my ($session, $attributes) = ( $this->{session}, $this->{attributes} );
	my ($project_legal, $feature_legal, $task_legal, )= ('', '', '');
	my @imProjects = ();
	#step0 new create
	#step1 foreach project, create
	#step2 foreach feature, create
	#step3 foreach task,    create
	$this->{create_project} = new TWiki::Plugins::OpenToolChainPlugin::Create::CreateProject($session, $attributes,$this);
	$this->{create_feature} = new TWiki::Plugins::OpenToolChainPlugin::Create::CreateFeature($session, $attributes,$this);
	$this->{create_task}    = new TWiki::Plugins::OpenToolChainPlugin::Create::CreateTask($session, $attributes,$this);
	foreach my $pitem ( @{$this->{data}} ){	
		$this->{project_name}                   = $pitem->{name}; $project_legal=$pitem->{name}; $project_legal =~ s/\W+//g;
		$this->{project_forecaststartdate}      = $pitem->{pstart};
		$this->{project_forecastenddate}        = $pitem->{pend};
		$this->{project_forecasteffort}         = $pitem->{peffort};
		$this->{project_assignlist}             = $pitem->{assignto};  #is an aray
		$this->{project_group}                  = $project_legal."PGroup";
		$this->{project_id}                     = $this->{create_project}->CreateDBItem();
		#$this->_debug("go to project now:"."$this->{project_name}  projectid: $this->{project_id}");
		$this->{create_project}->CreateSelfTopic($this->{project_id}) if $this->{project_id};		
		if (defined $pitem->{child}){
			#$this->_debug(" features:".Dumper(@{$pitem->{child}}));
			my $feature = $pitem->{child};
			foreach my $fitem ( @$feature ){					
				$this->{feature_name}                   = $fitem->{name};$feature_legal=$fitem->{name}; $feature_legal =~ s/\W+//g;
				$this->{feature_forecaststartdate}      = $fitem->{pstart};
				$this->{feature_forecastenddate}        = $fitem->{pend};
				$this->{feature_forecasteffort}         = $fitem->{peffort};
				$this->{feature_assignlist}             = $fitem->{assignto};  #is an aray	
				$this->{feature_group}                  = $feature_legal."_".$project_legal."FGroup";			
				$this->{feature_id}                     = $this->{create_feature}->CreateDBItem();
				#$this->_debug("go to feature now:"."$this->{feature_name},   projectid: $this->{project_id}, featureid: $this->{feature_id}");
				$this->{create_feature}->CreateSelfTopic($this->{feature_id}) if $this->{feature_id};				
				if (defined $fitem->{child}){
					my $task = $fitem->{child};
					foreach my $titem ( @$task ){
						$this->{task_name}                   = $titem->{name};$task_legal=$titem->{name}; $task_legal =~ s/\W+//g;
						$this->{task_forecaststartdate}      = $titem->{pstart};
						$this->{task_forecastenddate}        = $titem->{pend};
						$this->{task_forecasteffort}         = $titem->{peffort};
						$this->{task_assignlist}             = $titem->{assignto};  #is an aray	
						$this->{task_group}                  = $task_legal."_".$feature_legal."_".$project_legal."TGroup";							
						$this->{task_id}                     = $this->{create_task}->CreateDBItem();
						#$this->_debug("go to task now:"."$this->{task_name}  ,projectid: $this->{project_id},   featureid: $this->{feature_id}   taskid: $this->{task_id}");
						$this->{create_task}->CreateSelfTopic($this->{task_id}) if $this->{task_id};
					}
				}
			}
		}
		push @imProjects, $pitem->{name};
	}
	return \@imProjects;
}

sub setFile{
	my ($this,$file)=@_;
	my $relativeDir = $TWiki::cfg{PubDir};
	$this->{file}= "$relativeDir/$this->{session}->{webName}/$this->{session}->{topicName}/$file";
	#"./../../www.xml";
	#$this->{file}="/var/www/html/www.xml";
}

sub parseTree{
	my ($this,$data,$ret)=@_;
	foreach my $item (@{$data}){
		$ret->{content}.=$item->{name}."\n";
		$ret->{content}.=$item->{type}."\n";
		$ret->{content}.=$item->{level}."\n";
		$ret->{content}.=$item->{pstart}."\n";
		$ret->{content}.=$item->{pend}."\n";
		$ret->{content}.=$item->{peffort}."\n";
		my $n=@{$item->{assignto}};
		if ($n>0){	
			foreach my $name (@{$item->{assignto}}){
				$ret->{content}.=$name."\n";	
			}
			$ret->{content}.="\n";
		}else{
			$ret->{content}.="noname"."\n\n";	
		}
							
		# recusive
		if (defined $item->{child}){
			$this->parseTree($item->{child},$ret);
		}	
	}
	return $ret->{content};
}



sub parseXMLData{
	my ($this) = @_;
	my ($taskid,$name,$pstart,$pend,$peffort,$assignto);
	my ($assign_taskid,$assign_resource);
	my ($userid,$username);
	my (@task,$taskItem);
	my ($level,$type);
	my (@resource);
	
	my $parser = XML::Parser->new(ErrorContext => 2, Style => "Tree");
	my $xso    = XML::SimpleObject->new( $parser->parsefile($this->{file}) );
	#my $xso     = new LibXML (file => "$this->{file}");

	
	foreach my $item ( $xso->child('Project')->child('Tasks')->child('Task') ){
		#clear zero
		$peffort = 0;
		
		$taskid=$item->child('ID')->{_VALUE};
		$name=$item->child('Name')->{_VALUE};
		#$pstart=$item->child('CreateDate')->{_VALUE};
		$pstart=$item->child('Start')->{_VALUE};	
		$pend  =$item->child('Finish')->{_VALUE};
		#$peffort=$item->child('Duration')->{_VALUE};
		$level=$item->child('OutlineLevel')->{_VALUE};
		if($level>3){
			$this->{errortype}->{hiererchy_exceed_error}->{value}=1;
			$this->{errortype}->{hiererchy_exceed_error}->{error_info}=
			"WARNING[$this->{errortype}->{hiererchy_exceed_error}->{errorcode}]: Your XML file has a hierarchy more than 3, you can insist to continue, but the information that level exceed 3 will be lost.";
			next;
			#TWiki::Func::writeDebug("Take Care:Your XML file has a hierarchy more than 3, the information level exceed 3 will be lost, but you can insist to continue....");		
		}
		
		my @assigngroup=();
		
		foreach my $assign ($xso->child('Project')->child('Assignments')->child('Assignment')){
			$assign_taskid=$assign->child('TaskUID')->{_VALUE};
			$assign_resource=$assign->child('ResourceUID')->{_VALUE};
			if ($taskid == $assign_taskid){
				#calculate the assign,effort,physical
				$peffort += &parseEffort( $assign->child('Work')->{_VALUE} );
				
				#next if $assign_resource<0 ;  #indicate no resource				
				#for the assign to
				foreach my $resource ($xso->child('Project')->child('Resources')->child('Resource')){
					$userid=$resource->child('ID')->{_VALUE};
					$username=$resource->child('Name')->{_VALUE};		
					if ($assign_resource == $userid){
						push @assigngroup,$username;				
					}			
				}
				
			}
		}
		$assignto=\@assigngroup;
		
		$pstart = &parseDate($pstart);
		$pend   = &parseDate($pend);
		#$peffort= &parseEffort($peffort);
		
		$type = "project" if  $level==1;
		$type = "feature" if  $level==2;
		$type = "task"    if  $level==3;
		
		$taskItem ={name     =>$name,
					type     =>$type,
					level    =>$level,
					pstart   =>"$pstart",
					pend     =>"$pend",
					peffort  =>"$peffort",
					assignto =>$assignto};
		push @task,$taskItem;		
	}
	#end mark	
	#this task is useless,no need to judge or check, just to keep buildTree to run smoothly
	$taskItem={     name     =>"end",
					type     =>"project",
					level    =>1,
					pstart   =>"end",
					pend     =>"end",
					peffort  =>"end",
					assignto =>"end"};
	push @task,$taskItem;
	$this->{rawdata}=\@task;
	#$this->_debug("soong2: ".Dumper(@task));
	
	#matine an resource array
	foreach my $resource ($xso->child('Project')->child('Resources')->child('Resource')){
		$userid=$resource->child('ID')->{_VALUE};
		$username=$resource->child('Name')->{_VALUE}; 
		push @resource, $username;
	}
	shift @resource;    # remove the first one
	$this->{resourcedata} = \@resource;
}

#step1: task     built
#step2: feature  built
#step3: project  built
#step4: effort   built, for each leveal
sub buildTree{
	my ($this)    = @_;
	my $pround     = 0;
	my $fround     = 0;
	
	
	my (%pitem,%fitem,%pre_pitem,%pre_fitem);
	my (@projects,@features,@tasks);
	foreach my $item (@{$this->{rawdata}}){		
		if ($item->{type} eq "project"){
			# re count again
			$pround += 1;
			%pre_pitem=%pitem; 
		    %pitem=%$item;		    
		}
		
		if ($item->{type} eq "feature"){
			# re count again	
			$fround += 1;
			%pre_fitem=%fitem;		
		    %fitem=%$item;	
		}
		
		if ($item->{type} eq "task"){							
		    my %titem=%$item;	
		    push @tasks,\%titem;    	
		}
		
		# if $round==2, construct the subtree
		if ( $fround==2 ){
			my @t=@tasks;
			if ($#tasks>=0){
				# array not null
				$pre_fitem{child}=\@t;
			}
			my %temp=%pre_fitem;		
			push @features,\%temp;
			@tasks=();				
			%pre_fitem=();					
			$fround=1;
		}
		
		# if $round==2, construct the subtree
		if ( $pround==2 ) {
			
			if ($fround==1) {
				# push last feature
				if ($#tasks>=0){
					# array not null
					my @t=@tasks;
					$fitem{child}=\@t;					
				}				
				my %temp=%fitem;	
				push @features,\%temp;
					
				@tasks=();
			}
			
			# push last project
			my %temp2=%pre_pitem;
			if ($#features>=0){
				# array not null
				my @f=@features;
				$temp2{child}=\@f;
			}			
			push @projects,\%temp2;
			
			@features=();
			%pre_pitem=();				
			$pround=1;
			$fround=0;
		}	
	}
	#$this->{data}=\@projects;
	#$this->_debug("soong1: ".Dumper(@projects));
	$this->effortAdjustment(\@projects);
	$this->featureResourceAdjustment(\@projects);
	$this->{data} = $this->resourceAdjustment(\@projects);
}

sub effortAdjustment{
	my ($this,$data)    = @_;
	foreach my $pitem ( @$data ){
		if (defined $pitem->{child}){
			my $feffort = 0;
			my $feature = $pitem->{child};
			foreach my $fitem ( @$feature ){								
				if (defined $fitem->{child}){
					my $teffort = 0;
					my $task = $fitem->{child};
					foreach my $titem ( @$task ){
						$teffort += $titem->{peffort};
					}
					$fitem->{peffort} = $teffort;
				}
				$feffort += $fitem->{peffort};
			}
			$pitem->{peffort} = $feffort;
		}
	}
	return $data;
}

#new req: Feature LEADER should be assigned, or will be Project PM by default 
sub featureResourceAdjustment{
	my ($this,$data)    = @_;
	foreach my $pitem ( @$data ){
		my @passigns = @{$pitem->{assignto}};
		if (defined $pitem->{child}){			
			my $feature = $pitem->{child};
			foreach my $fitem ( @$feature ){
				my @fassigns = @{$fitem->{assignto}};
				if ( !scalar @fassigns &&  scalar @passigns ){
					push @fassigns,$passigns[0];
					$fitem->{assignto} = \@fassigns;
				}				
			}
		}
	}
	return $data;
}

sub resourceAdjustment{
	my ($this,$data)    = @_;
	foreach my $pitem ( @$data ){
		my @passigns = @{$pitem->{assignto}};
		if (defined $pitem->{child}){			
			my $feature = $pitem->{child};
			foreach my $fitem ( @$feature ){
				my @fassigns = @{$fitem->{assignto}};					
				if (defined $fitem->{child}){					
					my $task = $fitem->{child};
					foreach my $titem ( @$task ){
						push @fassigns, @{$titem->{assignto}};
					}
					$fitem->{assignto} = $this->uniqueArray(\@fassigns);					
				}
				push @passigns, @{$fitem->{assignto}};
			}
			$pitem->{assignto} = $this->uniqueArray(\@passigns);
		}
	}
	return $data;
}

sub uniqueArray{
	my ($this,$data)    = @_;
	my $sifter = {};
	my $buffer = [];
	return [] if ! scalar @$data;
	foreach my $item (@$data){
		if ( !$sifter->{$item} ){
			$sifter->{$item} = 1;
			push @$buffer, $item;
		}
	}
	return $buffer;
}


#=================== PRIVATE FUNCTION =======================================
#                    
#=================== PRIVATE FUNCTION =======================================

sub createAttachmentList{
    my ( $topicString, $webString ) = @_;

    my @files         = ();

    my @webs   = ();
    my @topics = ();
    if ( $webString eq '*' ) {
        @webs = TWiki::Func::getListOfWebs();
    }
    else {
        @webs = split( /[\s,]+/, $webString );
    }
    foreach my $web (@webs) {
        my @topics = ();
        if ( $topicString eq '*' ) {
            @topics = TWiki::Func::getTopicList($web);
        }
        else {
            @topics = split( /[\s,]+/, $topicString );
        }

        foreach my $attachmentTopic (@topics) {
            my @topicFiles =
              createAttachmentListForTopic( $attachmentTopic, $web );
            foreach my $attachment (@topicFiles) {
                my $fd = TWiki::Plugins::OpenToolChainPlugin::Import::FileData->new(
                    $attachmentTopic, $web, $attachment );
                push @files, $fd;
            }
        }
    }
    # TWiki::Func::writeDebug("soong new1: ".Dumper(@files));
    return @files;
}
sub createAttachmentListForTopic {
    my ( $topic, $web ) = @_;

    my ( $meta, $text ) = TWiki::Func::readTopic( $web, $topic );
    return $meta->find("FILEATTACHMENT");
}
sub makeHashFromString {
    my ($text) = @_;

    my %hash = ();

    return %hash if !defined $text || !$text;

    my $re = '\b[\w\._\-\+\s]*\b';
    my @elems = split( /\s*($re)\s*/, $text );
    foreach (@elems) {
        $hash{$_} = 1;
    }
    return %hash;
}
sub getFileList{ 
	my ( $this ) = @_;	
	my ( $session, $params, $topic, $web ) = ($this->{session},0,$this->{session}->{topicName},$this->{session}->{webName});
	my @files =
      createAttachmentList( $topic, $web );

    my @file;
    # store once for re-use in loop
    my $pubUrl = TWiki::Func::getUrlHost().TWiki::Func::getPubUrlPath();
    foreach my $fileData (@files) {
        my $attachmentTopic    = $fileData->{'topic'};
        my $attachmentTopicWeb = $fileData->{'web'};
        my $attachment         = $fileData->{'attachment'};
        my $filename = $attachment->{name};
        my $fileExtension = getFileExtension($filename);
        my $attrSize    = $attachment->{size};
        my $attrUser    = $attachment->{user};
        my $attrComment = $attachment->{comment};
        my $attrAttr    = $attachment->{attr};
        push @file, $filename;
    
    }
    return \@file;
}
sub getFile{
	my ( $this, $filename) = @_;
	my $user = TWiki::Func::getWikiName();
    my $wikiUserName = TWiki::Func::userToWikiName( $user, 1 );
    my $store = $this->{session}->{store};
	my $attachmentExists = $store->attachmentExists( $this->{session}->{webName}, $this->{session}->{topicName}, $filename );
	if ($attachmentExists) {
		my $stream =
                  $store->getAttachmentStream( $wikiUserName,
                  $this->{session}->{webName}, $this->{session}->{topicName}, $filename );
        if ($stream) {
        	#TWiki::Func::writeDebug("soong new9: ".Dumper($$stream));
        	return $stream;
        }
    }
}     

sub getFileExtension {
    my ($filename) = @_;

    my $extension = $filename;
    $extension =~ s/^.*?\.(.*?)$/$1/g;
    return lc $extension;
}

sub getFileOptions{
	my ($this) = @_;
	my $ret = '';
	my $file = $this->getFileList();
	return ''  unless ( scalar @$file );
	foreach my $item (@$file){
		$ret .= "<option>$item</option>";
	}
	return $ret;
}

sub setFileOptions{
	my ($this) = @_;
	$this->{file_options} .= $this->getFileOptions();
}



sub initJS{
	my ($this) = @_;
	my $script=<<"EOF";
	<script type="text/javascript">
function _onchange(_obj){
	//alert(_obj.value);
	document.getElementById("file_name_div").innerHTML = _obj.value;
}
function _getFullPath(obj){	
	if(obj){
		//ie
		if (window.navigator.userAgent.indexOf("MSIE")>=1){
			obj.select();
			return document.selection.createRange().text;
		}
		//firefox
		else if(window.navigator.userAgent.indexOf("Firefox")>=1){
			if(obj.files){
				return obj.files.item(0).getAsDataURL();
			}
			return obj.value;
		}
		return obj.value;
	}
}
function _getName(filePath){
	var listArray = filePath.split('/');
	listArray.reverse();
	return listArray[0];
}
function _import(fileid, file, warningSwitchTable){	
	if (fileid){
		var _obj = document.getElementById(fileid);	
		file     = _obj.value;		
		// test file format
		var fileReg  = /.*\.xml\$/;
		if ( ! fileReg.test(file) ) { alert("File format is not right, please choose a xml file to import!"); return; };	
		// test confirm
		if( !confirm('Are you sure to import file [' + file + '] to Project Management now?' ) ){ return; }
	}
	
	if (!warningSwitchTable){
		warningSwitchTable = _initSwitchTable(warningSwitchTable,2);
	}
		
	var para = "file=" + file;
	var _log_obj = document.getElementById('import_log');
	_log_obj.value += '----------------------------------------------------\\n';
	
	// prepare	
	var xmlHttp = _getXmlHttpObject();
	if(xmlHttp == null){
		alert("Your explorer dosn't support ajax");
		return;
	}
	xmlHttp.onreadystatechange=function(){
		if(xmlHttp.readyState==4){
			var res  = xmlHttp.responseText;
			if (res) {
				var set = new Array();
				set     = res.split('gnoos,');
				for (var item in set){
					var buffer     =  set[item];
					_log_obj.value += buffer + '\\n'; 
					_log_obj.scrollTop = _log_obj.scrollHeight;
					
					// handle error
					var temp          = buffer;
					if ( buffer && /^ERROR/.test(buffer) ){				
						var reg       = /^ERROR\\[(.*)\\]:.*/;
						var errorcode = temp.replace(reg,'\$1');				
						if ( errorcode == "$this->{errortype}->{resource_nonlegal}->{errorcode}"   || 
					 		 errorcode == "$this->{errortype}->{project_no_resource}->{errorcode}" || 
				     		 errorcode == "$this->{errortype}->{feature_no_resource}->{errorcode}" ) {
							 alert( buffer );
							 return;
						}				
					}
					// handle warning	
					else if ( buffer && /^WARNING/.test(buffer) ){
						var reg       = /^WARNING\\[(.*)\\]:.*/;
						var errorcode = temp.replace(reg,'\$1');				
						if ( errorcode == "$this->{errortype}->{hiererchy_exceed_error}->{errorcode}" ){
							if( !confirm(buffer) ) { 
								return;
							}							
						}
						if ( errorcode == "$this->{errortype}->{project_name_conflict}->{errorcode}" ){
							if( !confirm(buffer) ) { 
								return; 
							}							
						}
					}
				}
			}
					
			var xmlHttp2 = _getXmlHttpObject();
			if(xmlHttp2 == null){
				alert("Your explorer dosn't support ajax");
				return;
			}
			xmlHttp2.onreadystatechange=function(){
				if(xmlHttp2.readyState==4){	
					var buffer = xmlHttp2.responseText;		
					_log_obj.value += buffer + '\\n';
					_log_obj.scrollTop = _log_obj.scrollHeight;	
					alert(buffer);											
				}
			}
			var url = "$this->{actionUrl}" + "?ajaxclass=$this->{className}" + "&oper=$this->{importData}" + "&" + para;
			xmlHttp2.open("GET",url,true);
			xmlHttp2.send(null);

		}			                  	 
	}
	var url = "$this->{actionUrl}" + "?ajaxclass=$this->{className}" + "&oper=$this->{prepareData}" + "&" + para;
	//alert(url);
	xmlHttp.open("GET",url,true);
	xmlHttp.send(null);
}


function _initSwitchTable( num ){
	var table = new Array();
	for( var i=0; i<num; i++ ){
		table[i] = 0;
	}
	return table;
}


function _getXmlHttpObject()
{
	var xmlHttp = null;
	try
	{
		xmlHttp = new XMLHttpRequest();
	}
	catch(e)
	{
		try
		{
			xmlHttp = new ActiveXObject("Msxml2XMLHTTP");
		}
		catch(e)
		{
			xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
		}
	}
	return xmlHttp;
}
	</script>	
EOF
	TWiki::Func::addToHEAD('IMPORT_FUNCTION', $script);
	return;
}


sub _debug{
	my ($this,$str)=@_;
	if ($this->{deubg_flag}!=0){
		TWiki::Func::writeDebug( "$str" );
	}
}

sub parseDate{
	my $indate = shift;
	return '' unless $indate;
	$indate =~ s/(\d{4}-\d{2}-\d{2}).*/$1/g;
	return $indate;
}
sub parseEffort{
	my $ineffort = shift;
	return 0 unless $ineffort;
	$ineffort =~ s/.*?(\d*)H.*/$1/g;
	return $ineffort;
}

sub cutTail{
	my $str = shift;
	return '' if !$str;
	$str =~ s/, $//g;
	return $str;
}

sub arrayToStr{
	my $array = shift;
	my $str = '';
	return '' if !scalar @$array;
	foreach my $item (@$array){
		$str .= "$item, ";	
	}
	$str = &cutTail($str);
	return $str;
}



1;



