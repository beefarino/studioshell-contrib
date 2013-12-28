﻿#
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
    [parameter()]
    [switch]
    # when specified, the root code mode path node for the project is returned; when omitted, the project path node is returned
    $codeModel,

    [parameter( ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$false, Position=0 )]
    [alias( 'projectName' )]
    [string[]]
    # the name of the project; wildcards permitted
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
            [string]
            $name
        ) 

        process
        {
            write-debug "testing path $path for project $name"
    
            if( $path | join-path -child $name | test-path )
            {
                $path | join-path -child $name | get-item; 
            } 
            
            get-childitem $path | `
                select-solutionFolder | `
                select -exp pspath | `
                find -name $name;          
        
        }
    }

    $path = 'dte:/solution/projects';
    if( $codeModel )
    {
        $path = 'dte:/solution/codemodel';
    }

    $name | foreach { $path | find -name $_ }
}


<#
.SYNOPSIS 
Finds a project by its name.

.DESCRIPTION
Finds a project by its name.

This function recursively searches the solution and all solution folders for the project(s) specified.

.INPUTS
String.  The name of the project to find.

.OUTPUTS
None.

.EXAMPLE
C:\PS> get-project -name MyProject

This example finds the MyProject project node in the currently open solution.

.EXAMPLE
C:\PS> get-project -name MyProject -codemodel

This example finds the MyProject code model node in the currently open solution.


.EXAMPLE
C:\PS> get-project -name CodeOwls.*

This example finds all project nodes with names that begin with "CodeOwls." in the currently open solution.
#>

