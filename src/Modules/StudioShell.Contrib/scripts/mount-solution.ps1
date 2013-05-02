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
#	StudioShell.Contrib module definition file
#


[CmdletBinding(DefaultParameterSetName='MountCM')]
param( 
	[parameter(ParameterSetName='MountFS', Mandatory=$true)]
	[switch] 
	# when specified, mounts the filesystem location of the solution
	$fileSystem,
    
    [parameter(ParameterSetName='MountCM', Mandatory=$false)]
	[switch] 
	# when specified, mounts the codemodel location of the solution
	$codeModel,
    
    [parameter(ParameterSetName='MountPI', Mandatory=$true)]
	[switch] 
	# when specified, mounts the project items location of the solution
	$projects
);

process
{
    $slnPath = "dte:/solution";
    
	if( $fileSystem )
    {
        $sln = get-item dte:/solution;
        if( -not $sln.isOpen )
        {
            write-error 'The solution folder cannot be mounted because no solution is open';
            return;
        }
        
        $slnPath = $sln.FullName | split-path;
        
    }
    elseif( $projects )
    {
        $slnPath = "dte:/solution/projects";
    }    
    else
    {
        $slnPath = "dte:/solution/codemodel";
    }
    
    set-location $slnPath;
}

<#
.SYNOPSIS 
Mounts the file system, code model, or projects location of the current solution.

.DESCRIPTION
Mounts the file system, code model, or projects location of the current solution.

.INPUTS
None.

.OUTPUTS
None.

.EXAMPLE
C:\PS> Mount-Solution 

This example mounts the projects node for the currently open solution.

.EXAMPLE
C:\PS> Mount-Solution -fileSystem

This example mounts the current file system folder containing the open solution.

.EXAMPLE
C:\PS> Mount-Solution -codeModel

This example mounts the root code model path of the current solution.
#>

