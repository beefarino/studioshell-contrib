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

[cmdletbinding()]
param( 
    [parameter( ValueFromPipeline=$true, Mandatory=$true )]
    [string]
    $path, 
    
    [parameter( Mandatory=$true )]
    $name  
)

process
{    
    write-debug "testing path $path for project item $name"
    
    if( $path | join-path -child $name | test-path )
    {
        $path | join-path -child $name | get-item; 
    } 
    else
    {           
        get-childitem $path | `
            where { test-projectFolder $_ } | `
            select -exp pspath | `
            find-projectItem -name $name;          
    }
}


<#
.SYNOPSIS 
Finds a project item in a project hive by its name.

.DESCRIPTION
Finds a project item in the project hive by its name.

This function recursively searches the project for the project item specified.

.INPUTS
String.  The root path to search

.OUTPUTS
None.

.EXAMPLE
C:\PS> find-projectitem -path dte:/solution/projects/MyProject -name MyClass.cs

This searches the MyProject project file hierarchy for the file named MyClass.cs
#>

