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

process
{
    $sln = get-item dte:/solution;
    if( $sln.isOpen )
    {
        $sln.fullname -replace '^.+\\([^\\.]+).sln$','$1'
    }
}

<#
.SYNOPSIS 
Returns the name of the current solution.

.DESCRIPTION
Returns the name of the current solution.

.INPUTS
None.

.OUTPUTS
String.  The name of the current solution.

.EXAMPLE
C:\PS> Get-SolutionName

This example returns the name of the currently loaded solution, or nothing if no solution is loaded.
#>

