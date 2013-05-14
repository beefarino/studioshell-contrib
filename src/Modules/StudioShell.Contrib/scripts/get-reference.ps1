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
    [parameter( Mandatory=$false, ValueFromPipelineByPropertyName=$true )]
    [string[]]
    # the name of the project containing the reference; wildcards permitted
    $projectName = @('*'),
    
    [parameter( Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=0 )]
    [alias('reference')]
    [string[]]
    # the name of the reference to retrieve; wildcards permitted
    $name
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
            write-verbose "testing path $path for reference $name"
            $referencePath = $path | join-path -child 'references';

            if( $referencePath | test-path )
            {
                $name | foreach {
                    $referencePath | join-path -child $_ | get-item; 
                }
            } 
        }
    }

    $projectName | get-project | select -exp pspath | find -name $name
}


<#
.SYNOPSIS 
Finds references in one or more projects.

.DESCRIPTION
Finds references in one or more projects.

This function searches projects matching the projectName parameter for the references specified.

.INPUTS
String.  The name of the reference to find.

.OUTPUTS
Object.  The matching references across all match projects.

.EXAMPLE
C:\PS> get-reference -projectName 'MyProject' -Name 'EntityFramework'

This example locates the reference to EntityFramework in the project named MyProject.

.EXAMPLE
C:\PS> get-reference -projectName '*' -Name 'Acme.*'

This example locates all references with a name starting with 'Acme.' across all projects.
#>

