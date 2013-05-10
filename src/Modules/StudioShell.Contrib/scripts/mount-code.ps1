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
    [switch]
    $member
);

process
{      
    function find-namespace( [parameter(ValueFromPipeline=$true)][string] $path, [string] $name )
    {
        write-verbose "testing path $path for namespace $name"
    
        if( $path | join-path -child $name | test-path )
        {
            $path | join-path -child $name | get-item; 
        } 
        else
        {           
            get-childitem $path | `
                where { $_ -match 'namespace' } | `
                select -exp pspath | `
                find-namespace -name $name;          
        }
    }
    
    function find-class( [parameter(ValueFromPipeline=$true)][string] $path, [string] $name )
    {
        write-verbose "testing path $path for class $name"
    
        if( $path | join-path -child $name | test-path )
        {
            $path | join-path -child $name | get-item; 
        } 
        else
        {           
            get-childitem $path | `
                where { $_ -match 'class' -or $_ -match 'namespace' } | `
                select -exp pspath | `
                find-class -name $name;          
        }
    }

    function find-member( [parameter(ValueFromPipeline=$true)][string] $path, [string] $name )
    {
        write-verbose "testing path $path for member $name"
    
        if( $path | join-path -child $name | test-path )
        {
            $path | join-path -child $name | get-item; 
        } 
        else
        {           
            $r = get-childitem $path |`
                select -exp pspath;# | `
            $r | write-verbose ;
            $r|    find-member -name $name;          
        }
    }

    function select-type
    {
        process
        {
            $input | where { 
                $_.kind -match 'class' -or 
                $_.kind -match 'interface' -or
                $_.kind -match 'enum' -or
                $_.kind -match 'struct'                
            } 
        }
    }
    
    function select-namespace 
    {
        process
        {
            $input | where { $_.kind -match 'namespace' }
        }
    }

    function select-typeMember
    {
        process
        {
            $input | where {
                $_.kind -notmatch 'namespace' -and

                $_.kind -notmatch 'class' -and
                $_.kind -notmatch 'interface' -and
                $_.kind -notmatch 'enum' -and
                $_.kind -notmatch 'struct' -and                

                $_.kind -notmatch 'import'
            }
        }
    }
     
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

    $projectItem = find-projectItem -codemodel -projectName $projectName -itemname $targetProjectItem.Name
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

    $projectItem = find-class -path $projectitem.pspath -name $selectedClass.Name;
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
C:\PS> Mount-CodeModel -class

This example mounts the code model node for the class containing the currently focused code.

.EXAMPLE
C:\PS> Mount-CodeModel -member

This example mounts the code model node for the currently focused method, property, event, or field code.

#>

