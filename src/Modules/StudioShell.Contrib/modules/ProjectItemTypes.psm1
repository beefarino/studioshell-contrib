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

function test-solutionFolder( [parameter( ValueFromPipeline=$true, Position=0 )] $project )
{
    process
    {
        $project.kind -match '66A26720-8FB5-11D2-AA7E-00C04F688DDE'
    }
}

function test-projectFolder( [parameter( ValueFromPipeline=$true, Position=0 )] $project )
{
    process
    {
        $project.kind -match '6BB5F8EF-4483-11D3-8BCF-00C04F8EC28C'
    }
}

function test-folder( [parameter( ValueFromPipeline=$true, Position=0 )] $project )
{
    process
    {
        ( test-solutionFolder $project ) -or ( test-projectFolder $project )
    }
}
