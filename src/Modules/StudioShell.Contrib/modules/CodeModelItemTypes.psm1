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
#	CodeItemTypes submodule
#

function find-namespace
{
    param( 
        [parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string] 
        # the path to search
        $path, 
        
        [parameter(Mandatory=$true)]
        [alias("namespace")]
        [string[]] 
        # the name of the namespace to find; wildcards permitted
        $name 
    )

    process
    {
        $name | foreach-object {
            write-verbose "testing path $path for namespace $_"
            
            if( $path | join-path -child $_ | test-path )
            {
                $path | join-path -child $_ | get-item; 
            } 
            else
            {           
                get-childitem $path | `
                    select-namespace | `
                    select -exp pspath | `
                    find-namespace -name $_;          
            }
        }
    }
<# 
   .Synopsis 
    Locates a namespace code item at or under a specified starting path.
   .Example 
    find-namespace -path dte:/solution/codeModel/myProj -name "CodeOwls.*"
    retrieves all namespace code model nodes that start with "CodeOwls." in the myProj project
   .Inputs
    String.  The path to search.
   .Outputs
    Object.  The retrieved namespace code model node.
   .Notes 
    NAME: find-namespace
    AUTHOR: beefarino 
   #Requires -Version 2.0 
#> 

}
    
function find-type
{
    param( 
        [parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string] 
        # the path to search
        $path, 
        
        [parameter(Mandatory=$true)]
        [string[]] 
        # the name of the type to find; wildcards permitted
        $name 
    )

    process
    {           
        $name | foreach-object {
            write-verbose "testing path $path for class $_"

            if( $path | join-path -child $_ | test-path )
            {
                $path | join-path -child $_ | get-item; 
            } 
            else
            {           
                get-childitem $path | `
                    where { $_ -match 'class' -or $_ -match 'namespace' } | `
                    select -exp pspath | `
                    find-type -name $_;          
            }
        }
    }
<# 
   .Synopsis 
    Locates a type code item (class, struct, enum, or interface) at or under a specified starting path.
   .Example 
    find-type -path dte:/solution/codeModel/myProj -name "Program"
    retrieves all namespace code model nodes that start with "CodeOwls." in the myProj project
   .Inputs
    String.  The path to search.
   .Outputs
    Object.  The retrieved type code model node.
   .Notes 
    NAME: find-type
    AUTHOR: beefarino 
   #Requires -Version 2.0 
#> 
}

function find-member
{
    param( 
        [parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [string] 
        # the path to search
        $path, 
        
        [parameter()]
        [string[]] 
        # the name of the member to find; wildcards permitted
        $name 
    )

    process
    {
        $name | foreach-object {
            write-verbose "testing path $path for member $_"
    
            if( $path | join-path -child $_ | test-path )
            {
                $path | join-path -child $_ | get-item; 
            } 
            else
            {           
                get-childitem $path | `
                    select -exp pspath | `
                    find-member -name $_;          
            }
        }
    }
<# 
   .Synopsis 
    Locates a member code item (method, property, field, or event) at or under a specified starting path.
   .Example 
    find-member -path dte:/solution/codeModel/myProj -name "Main"
    retrieves all code model member nodes named 'Main' in the myProj project
   .Inputs
    String.  The path to search.
   .Outputs
    Object.  The retrieved type member code model node.
   .Notes 
    NAME: find-member
    AUTHOR: beefarino 
   #Requires -Version 2.0 
#> 
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
<# 
   .Synopsis 
    Selects objects from the pipeline that represent code type items (class, struct, enum, or interface).
   .Example 
    get-childitem dte:/solution/codeModel/myProj -rec | select-type
    isolates all types in the myProj project
   .Inputs
    Object.  The object to filter.
   .Outputs
    Object.  The input object, if it represents a type code model item.
   .Notes 
    NAME: select-type
    AUTHOR: beefarino 
   #Requires -Version 2.0 
#> 
}
    
function select-namespace 
{
    process
    {
        $input | where { $_.kind -match 'namespace' }
    }
<# 
   .Synopsis 
    Selects objects from the pipeline that represent code namespace items.
   .Example 
    get-childitem dte:/solution/codeModel/myProj -rec | select-namespace
    isolates all namespaces in the myProj project
   .Inputs
    Object.  The object to filter.
   .Outputs
    Object.  The input object, if it represents a namespace code model item.
   .Notes 
    NAME: select-namespace
    AUTHOR: beefarino 
   #Requires -Version 2.0 
#> }

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
<# 
   .Synopsis 
    Selects objects from the pipeline that represent code type member items (methods, properties, fields, events, and delegates).
   .Example 
    get-childitem dte:/solution/codeModel/myProj -rec | select-typeMember
    isolates all type members in the myProj project
   .Inputs
    Object.  The object to filter.
   .Outputs
    Object.  The input object, if it represents a type member code model item.
   .Notes 
    NAME: select-typeMember
    AUTHOR: beefarino 
   #Requires -Version 2.0 
#> 
}
