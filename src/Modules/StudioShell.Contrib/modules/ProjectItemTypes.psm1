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
#	ProjectItemTypes submodule
#

function test-solutionFolder
{
    param ( 
        [parameter( ValueFromPipeline=$true, Position=0 )] 
        # the object to test
        $project 
    )

    process
    {
        $project.kind -match '66A26720-8FB5-11D2-AA7E-00C04F688DDE'
    }
<# 
   .Synopsis 
    Returns true when the input is a solution folder object
   .Example 
    get-item dte:\solution\projects\scripts | test-solutionFolder
    Returns true if "scripts" represents a solution folder
   .Inputs
    Object.  the object to test
   .Outputs
    true if the object is a solution folder; false otherwise
   .Notes 
    NAME: test-solutionFolder 
    AUTHOR: beefarino 
   #Requires -Version 2.0 
#> 
}

function test-projectFolder
{
    param ( 
        [parameter( ValueFromPipeline=$true, Position=0 )] 
        # the object to test
        $project 
    )

    process
    {
        $project.kind -match '6BB5F8EF-4483-11D3-8BCF-00C04F8EC28C'
    }
<# 
   .Synopsis 
    Returns true when the input is a project folder object
   .Example 
    get-item dte:\solution\projects\myProj\items | test-projectFolder
    Returns true if "items" represents a project-level folder
   .Inputs
    Object.  the object to test
   .Outputs
    true if the object is a project folder; false otherwise
   .Notes 
    NAME: test-projectFolder 
    AUTHOR: beefarino 
   #Requires -Version 2.0 
#>
}

function test-folder
{
    param ( 
        [parameter( ValueFromPipeline=$true, Position=0 )] 
        # the object to test
        $item 
    )

    process
    {
        ( test-solutionFolder $item) -or ( test-projectFolder $item)
    }
<# 
   .Synopsis 
    Returns true when the input is a project or solution folder 
   .Example 
    get-item dte:\solution\projects\myProj\items | test-folder
    Returns true if "items" represents a project-level or solution-level folder
   .Inputs
    Object.  the object to test
   .Outputs
    true if the object is a folder; false otherwise
   .Notes 
    NAME: test-folder 
    AUTHOR: beefarino 
   #Requires -Version 2.0 
#>
}

function select-folder
{
    process
    {
        $input | where-object { $_ | test-folder }
    }
<# 
   .Synopsis 
    Isolates solution and project folders in pipeline input.
   .Example 
    dir -rec dte:/solution/projects | select-folder
    Returns all solution and project folders in the current solution 
   .Inputs
    Object.  the object to filter
   .Outputs
    The input object, if it is a project or solution folder
   .Notes 
    NAME: select-folder 
    AUTHOR: beefarino 
   #Requires -Version 2.0 
#>
}

function select-solutionFolder
{
    process
    {
        $input | where-object { $_ | test-solutionFolder }
    }
<# 
   .Synopsis 
    Isolates solution folders in pipeline input.
   .Example 
    dir dte:/solution/projects | select-solutionFolder
    Returns all top-level solution folders in the current solution 
   .Inputs
    Object.  the object to filter
   .Outputs
    The input object, if it is a solution folder
   .Notes 
    NAME: select-solutionFolder 
    AUTHOR: beefarino 
   #Requires -Version 2.0 
#>
}

function select-projectFolder
{
    process
    {
        $input | where-object { $_ | test-projectFolder }
    }
<# 
   .Synopsis 
    Isolates project folders in pipeline input.
   .Example 
    dir -rec dte:/solution/projects/myProject | select-projectFolder
    Returns all project folders in the MyProject project
   .Inputs
    Object.  the object to filter
   .Outputs
    The input object, if it is a project folder
   .Notes 
    NAME: select-projectFolder 
    AUTHOR: beefarino 
   #Requires -Version 2.0 
#>
}