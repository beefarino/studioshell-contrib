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
	[switch] 
	# when specified, mounts the class for the selected code item
    $class,
    
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
                where { $_ -match 'class' } | `
                select -exp pspath | `
                find-class -name $name;          
        }
    }
    
     
    $items = get-childitem dte:/selectedItems/codeModel;
    
    if( -not $items )
    {
        write-error 'There is no currently selected code model object to mount';
        return;
    }
            
    $selectedNamespace = $items | where { $_.kind -match 'namespace' } | select -last 1;
    $selectedClass = $items | where { $_.kind -match 'class' } | select -last 1;
    $item = $items | where{ ( $_ -notmatch 'namespace' -and $_ -notmatch 'class' ) } | select -last 1;
    if( $namespace -and -not $selectedNamespace )
    {
        write-error "There is no namespace selected"
        return;
    }
    elseif( $class -and -not $selectedClass )
    {
        write-error "There is no class selected"
        return;
    }
    elseif( $member -and -not $item )
    {               
        write-error "There is no member selected"
        return;
    }      
   
    $item = $item,$selectedClass,$selectedNamespace | select -first 1;
    
    # find the container project and item
    $projectItem = $item.projectItem;
    $project = $projectItem.containingProject;
    $projectName = $project.Name;
    
    $projectNode = find-project -path dte:/solution/codemodel -name $projectName
    write-verbose "Found project node $($projectNode.PSPath)"
    
    $projectItem = find-projectItem -path $projectNode.pspath -name $projectItem.Name
    write-verbose "Found project item node $($projectItem.pspath)"
    
    $namespaceItem = find-namespace -path $projectItem.pspath -name $selectedNamespace.Name;
    write-verbose "Found namespace node $($namespaceItem.pspath)"
    
    if( $namespace )
    {
        set-location $namespaceItem.pspath;
        return;
    }
    
    $classItem = find-class -path $namespaceItem.pspath -name $selectedClass.Name;
    write-verbose "Found class node $($classItem.pspath)"
    
    if( $class )
    {
        set-location $classItem.pspath;
        return;
    }
    
    $p = ( $classItem.pspath | join-path -child $item.Name );
    write-verbose "Looking for member path $p ( $($classItem.pspath); $($item.name) )";
    $itemNode = get-item -path $p
    write-verbose "Found member item node $($itemNode.pspath)"
    
    set-location $itemNode.pspath
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

