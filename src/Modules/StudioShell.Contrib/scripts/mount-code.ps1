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
#	mount-code
#


[CmdletBinding(DefaultParameterSetName='Member')]
param( 
	
    [parameter(ParameterSetName='File', Mandatory=$true)]
	[switch] 
	# when specified, mounts the file node for the selected code item
	$file,
    
    [parameter(ParameterSetName='Namespace', Mandatory=$true)]
	[switch] 
	# when specified, mounts the namespace for the selected code item
	$namespace,
    
    [parameter(ParameterSetName='Class', Mandatory=$true)]
    [alias( 'class','interface','struct','enum' )]
	[switch] 
	# when specified, mounts the class, interface, struct, or enum for the selected code item
    $type,
    
    [parameter(ParameterSetName='Member', Mandatory=$false)]
    [alias( 'method','property','field','event' )]
    [switch]
    # when specified, mounts the selected code item member (method, property, field, or event)
    $member
);

process
{      
    $items = get-childitem dte:/selectedItems/codeModel;
    
    if( -not $items )
    {
        write-error 'There is no currently selected code model object to mount';
        return;
    }
            
    $selectedNamespace = $items | select-namespace | select-object  -last 1;
    $selectedClass = $items | select-type | select-object -last 1;
    $item = $items | select-typeMember | select-object -last 1;
    
    write-verbose "namespace: $($selectedNamespace.name); type: $($selectedClass.Name); member: $($item.Name)";
    if( $namespace -and -not $selectedNamespace )
    {
        write-error "There is no namespace selected"
        return;
    }
    elseif( $type -and -not $selectedClass )
    {
        write-error "There is no type selected"
        return;
    }
    elseif( $member -and -not $item )
    {               
        write-error "There is no member selected"
        return;
    }      
   
    $targetitem = $item,$selectedClass,$selectedNamespace | select -first 1;
    write-verbose "locating selected item $($item.pspath)"
    
    # find the container project and item
    $targetprojectItem = $targetitem.projectItem;
    $project = $targetprojectItem.containingProject;
    $projectName = $project.Name;
    
    write-verbose "project name: $projectName; project item name : $($targetItem.name)"

    $projectItem = get-projectItem -codemodel -projectName $projectName -itemname $targetProjectItem.Name
    write-verbose "Found project item node $($projectItem.pspath)"
    
    if( $file )
    {
        write-verbose ("pushing location of container for " + $projectItem.filename)
        $projectItem.filename | split-path | push-location;
        return;
    }

    $projectItem = find-namespace -path $projectItem.pspath -name $selectedNamespace.Name;
    write-verbose "Namespace result: $($projectItem.pspath)"
    if( $namespace )
    {
        $projectItem.pspath | push-location;
        return;
    }

    $projectItem = find-type -path $projectitem.pspath -name $selectedClass.Name;
    write-verbose "Class result: $($projectItem.pspath)"
    if( $type )
    {
        $projectItem.pspath | push-location;
        return;
    }

    $projectItem = find-member -path $projectitem.pspath -name $item.name;
    write-verbose "Member results: $($projectItem.pspath)"
    
    $projectItem.pspath | push-location;
}

<#
.SYNOPSIS 
Mounts the code model element with the current input focus.

.DESCRIPTION
Mounts the code model element with the current input focus.

The host location is set to the path node representing the code model of the currently selected namespace,
type, or member, or to the path of the file containing the selected code model elements. 

.INPUTS
None.

.OUTPUTS
None.

.EXAMPLE
C:\PS> Mount-CodeModel -namespace

This example mounts the code model node for the namespace containing the currently focused code.

.EXAMPLE
C:\PS> Mount-CodeModel -file

This example mounts the code model node for the file containing the currently focused code.

.EXAMPLE
C:\PS> Mount-CodeModel -type

This example mounts the code model node for the type (class, struct, enum, or interface) containing the currently focused code.

.EXAMPLE
C:\PS> Mount-CodeModel -member

This example mounts the code model node for the currently focused method, property, event, or field code.

#>

