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


[CmdletBinding()]
param( 
	[parameter(Mandatory=$false, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [alias( "Name" )]
	[string] 
	# the name or powershell path of the project to mount
	$project = ( get-childitem dte:/selectedItems/projects | select-object -first 1 -expand Name )
);

begin
{
    $unloadCommand = get-item dte:/commands/project.unloadproject
    $reloadCommand = get-item dte:/commands/project.reloadproject

    $solutionName = get-solutionName;

    $shellWindow = get-item 'dte:/windows/solution explorer';
    $shellWindow.Activate();

    $window = $dte.windows.item( $shellWindow.objectKind );
    $uiHierarchy = $window.object;
}

process
{       
    if( -not $project )
    {
        write-error 'No project name was specified, and there is no currently selected project to unload';
        return;
    }

    if( $project -is [string] )
    {
        $project = find-project dte:/solution/projects -name $project | select -exp Name;        
    }
        
    $uiPath = '{0}\{1}' -f $solutionName,$project;

    write-verbose "UI Path: [$uiPath]";

    $uiItem = $uiHierarchy.getItem( $uiPath );
    $uiItem.Select( 'vsUISelectionTypeSelect' );

    $unloadCommand | invoke-item;
    $reloadCommand | invoke-item;

}

<#
.SYNOPSIS 
Reloads the specified project.

.DESCRIPTION
Reloads the specified project.

.INPUTS
String.  The name of the project to reload.  If unspecified, the project currently selected in Solution Explorer is reloaded.

.OUTPUTS
None.

.EXAMPLE
C:\PS> Update-Project 

This example reloads the currently selected project.

.EXAMPLE
C:\PS> Update-Project -name MyProject

This example reloads the MyProject project.
#>

