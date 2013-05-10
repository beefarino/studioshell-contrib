#
#   Copyright (c) 2011 Code Owls LLC, All Rights Reserved.
#
#   Licensed under the Microsoft Reciprocal License (Ms-RL) (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#     http://www.opensource.org/licenses/ms-rl
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
# 
# 	psake build script for StudioShell.Contrib
#

properties {
	$config = 'Debug'; 	
	$local = './_local';
    $nugetSource = "./src/NuGet";
	$moduleSource = "./src/Modules";
    $projectName = "StudioShell.Contrib";
    $version = '1.0.0.0';
    $currentReleaseNotesPath = "./README.md";
};

framework '4.0'
$private = "this is a private task not meant for external use";

set-alias nuget ( './lib/nuget.exe' | resolve-path | select -expand path );

function get-packageDirectory
{
	return "." | resolve-path | join-path -child "/bin";
}

function get-nugetPackageDirectory
{
    return "." | resolve-path | join-path -child "/bin/$config/NuGet";
}

function get-modulePackageDirectory
{
    return "." | resolve-path | join-path -child "/bin/$config/Modules";
}

function create-PackageDirectory( [Parameter(ValueFromPipeline=$true)]$packageDirectory )
{
    process
    {
        write-verbose "checking for package path $packageDirectory ..."
        if( !(Test-Path $packageDirectory ) )
    	{
    		Write-Verbose "creating package directory at $packageDirectory ...";
    		mkdir $packageDirectory | Out-Null;
    	}
    }    
}

task default -depends Install;

# private tasks

task __VerifyConfiguration -description $private {
	Assert ( @('Debug', 'Release') -contains $config ) "Unknown configuration, $config; expecting 'Debug' or 'Release'";
	
	Write-Verbose ("packageDirectory: " + ( get-packageDirectory ));
}

task __CreatePackageDirectory -description $private {
	get-packageDirectory | create-packageDirectory;		
}

task __CreateModulePackageDirectory -description $private {
	get-modulePackageDirectory | create-packageDirectory;		
}

task __CreateNuGetPackageDirectory -description $private {
    $p = get-nugetPackageDirectory;
    $p  | create-packageDirectory;
    @( 'tools','lib','content' ) | %{join-path $p -child $_ } | create-packageDirectory;
}

task __CreateLocalDataDirectory -description $private {
	if( -not ( Test-Path $local ) )
	{
		mkdir $local | Out-Null;
	}
}

task EnforceUTF8Encoding -description "re-encodes text files to UTF8 (to prevent being seen as binary by Git)" {
	$f = ls -rec -inc *.ps1,*.psm1,*.psd1,*.txt;
    $f | foreach{ $s = $_ | get-content; $s | out-file -file $_ -encoding UTF8 }
}

# primary targets

task Package -depends __PackageModule -description "assembles distributions in the source hive"

# clean tasks

task CleanNuGet -depends __CreateNuGetPackageDirectory -description "clears the nuget package staging area" {
    get-nugetPackageDirectory | 
        ls | 
        ?{ $_.psiscontainer } | 
        ls | 
        remove-item -recurse -force;
}

task CleanModule -depends __CreateModulePackageDirectory -description "clears the module package staging area" {
    get-modulePackageDirectory | 
        remove-item -recurse -force;
}

# package tasks

task PackageModule -depends CleanModule,__CreateModulePackageDirectory -description "assembles module distribution file hive" -action {
	$mp = get-modulePackageDirectory;
	
	# copy module src hive to distribution hive
	Copy-Item $moduleSource -container -recurse -Destination $mp -Force;	
}

task PackageNuGet -depends PackageModule,__CreateNuGetPackageDirectory,CleanNuGet -description "assembles the nuget distribution" {
    $output = get-packageDirectory;
    $mp = get-modulePackageDirectory;
	$ngp = get-nugetPackageDirectory;
    $tools = join-path $ngp 'tools';
	$content = Join-Path $ngp 'content';
    $specFileName = "$projectName.nuspec";
    $spec = join-path $ngp $specFileName;
    
	#prepare the nuget distribution area
	Write-Verbose "preparing nuget distribution hive ...";
	
	# copy module distribution hive to nuget tools folder
    ls $mp | copy-item -dest $tools -recurse -force;
	# copy nuget source scripts to tools folder
    ls $nugetSource -filter *.ps1 | copy-item -dest $tools -force;
	# copy nuget reame to content folder
    ls $nugetSource -filter *.txt | copy-item -dest $content -force;
	# copy nuget nuspec file to nuget package folder
    ls $nugetSource -filter *.nuspec | copy-item -dest $ngp -force;
    
	#update the releasenotes and version info in the nuspec file
	Write-Verbose "updating release notes and version info in nuspec file...";
	
	# load the nuspec file contents
    $c = gc $spec;
	# replace $id$ placeholder with assembly version info from addin assembly
    $c = $c -replace '\$id\$', $version;
	# replace $relnotes$ token with contents of current release notes help topic
    $c = $c -replace '\$relnotes\$', ( ( gc $currentReleaseNotesPath ) | Out-String );
	# reformat the spec file contents and write nuspec file
    $c = $c -join "`n";
    $c | out-file $spec -force;
    
    # pack the nuget distribution   
	Write-Verbose "packing nuget distribution ...";
    pushd $ngp;
    nuget pack $specFileName -outputdirectory $output
    popd;
}

# install tasks

task Uninstall -description "uninstalls the module from the local user module repository" {
	$modulePath = $Env:PSModulePath -split ';' | select -First 1 | Join-Path -ChildPath $projectName;
	if( Test-Path $modulePath )
	{
		Write-Verbose "uninstalling $projectName from local module repository at $modulePath";
		
		$modulePath | ri -Recurse -force;
	}
}

task Install -depends InstallModule -description "installs the module and add-in to the local machine";

task InstallModule -depends PackageModule -description "installs the module to the local user module repository" {
	$packagePath = get-modulePackageDirectory;
	$modulePath = $Env:PSModulePath -split ';' | select -First 1;
	Write-Verbose "installing $projectName from local module repository at $modulePath";
	
	ls $packagePath | Copy-Item -recurse -Destination $modulePath -Force;	
}

