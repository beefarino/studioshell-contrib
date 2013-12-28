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
    [parameter( Mandatory=$false, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true )]
    [string[]]
    # the name of the project containing the item; wildcards permitted
    $projectName = @('*'),
    
    [parameter( Mandatory=$true, Position=0 )]
    [alias('itemName')]
    [string[]]
    # the name of the project item to retrieve; wildcards permitted
    $name,
    
    [parameter()]
    [switch]
    # when specified, the code model node for the project item is returned; be default, the project item node is returned
    $codeModel  
)

process
{    
    function find()
    {
        param( 
            [parameter( ValueFromPipeline=$true, Mandatory=$true )]
            [string]
            $path,
            
            [parameter( Mandatory=$true )]
            [string[]]
            $name
        ) 

        process
        {
            write-verbose "testing path $path for item $name"
    
            $name | foreach {
                if( $path | join-path -child $_ | test-path )
                {
                    $path | join-path -child $_ | get-item; 
                } 

                get-childitem $path | `
                    select-folder | `
                    select -exp pspath | `
                    find -name $_;                      
            }
        }
    }

    $projectName | get-project -codeModel:$codeModel| select -exp pspath | find -name $name 
}


<#
.SYNOPSIS 
Retrieves a project item from a project hive by its name.

.DESCRIPTION
Retrieves a project item from a project hive by its name.

This function recursively searches the projects specified for the item(s) specified.

.INPUTS
String.  The name of the project to search for the item

.OUTPUTS
Object.  The project item.

.EXAMPLE
C:\PS> get-projectItem -projectName 'MyProject' -name 'Program.cs'

This example locates the project item for the code file Program.cs in the project named MyProject.


.EXAMPLE
C:\PS> get-projectItem -projectName 'MyProject' -name 'Program.cs' -codeModel

This example locates the code model item for the code file Program.cs in the project named MyProject.

.EXAMPLE
C:\PS> get-projectItem -name 'Acme.*'

This example finds all project items starting with the name 'Acme.' across all projects in the solution.
#>

