#
#   Copyright (c) 2013 Code Owls LLC, All Rights Reserved.
#
#   Licensed under the Apache License, version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#     http://opensource.org/licenses/Apache-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#


[CmdletBinding(DefaultParameterSetName='MountCM')]
param( 
	[parameter(Mandatory=$false, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [alias( "Name" )]
	[string] 
	# the name or powershell path of the project to mount
	$project = ( get-childitem dte:/selectedItems/projects | select-object -first 1 -expand Name ),
    
    [parameter(ParameterSetName='MountFS', Mandatory=$true)]
	[switch] 
	# when specified, mounts the filesystem location of the project
	$fileSystem,
    
    [parameter(ParameterSetName='MountCM', Mandatory=$false)]
	[switch] 
	# when specified, mounts the codemodel location of the project
	$codeModel     
);

process
{       
    if( -not $project )
    {
        write-error 'No project name was specified, and there is no currently selected project to mount';
        return;
    }
    
    if( $fileSystem )
    {
        $item = get-item dte:/solution/projects/$project;
        set-location ( $item.fileName | split-path );   
        return;     
    }
    
    set-location ( join-path "dte:/solution/codemodel" -child $project );
    
}

<#
.SYNOPSIS 
Mounts the file system or code model location of the project.

.DESCRIPTION
Mounts the file system or code model location of the project.

.INPUTS
String.  The name of the project to mount.  If unspecified, the project currently selected in Solution Explorer is mounted.

.OUTPUTS
None.

.EXAMPLE
C:\PS> Mount-Project 

This example mounts the code model for the currently selected project.

.EXAMPLE
C:\PS> Mount-Project -fileSystem

This example mounts the file system folder containing the selected project.

.EXAMPLE
C:\PS> Mount-Project -name MyProject -codeModel

This example mounts the root code model path of the project named MyProject.
#>

