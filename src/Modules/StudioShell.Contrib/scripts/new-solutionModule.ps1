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
    [parameter()]
    [switch]
    # when specified, any existing solution module will be overwritten
    $force
)

process
{    
    write-verbose "adding solution module to current solution"
    
    $sln = get-item dte:/solution;
    
    if( -not $sln.isOpen )
    {
        write-warning "There is no open solution to which to add a solution module";
        return;
    } 
        
    $modulePath = $sln.FullName -replace '\.sln$','.psm1';

    if( ( test-path $modulePath ) )
    {
        if(-not $force )
        {
            $r = $PSCmdlet.ShouldContinue(
                "A solution module exists at path $modulePath.  If you continue, this existing module will be overwritten.  Continue?",
                "Solution Module Already Exists"
            );

            if( -not $r )
            {
                write-error "A solution module already exists at path $modulePath; use the -force parameter to overwrite this existing solution module";
                return;
            }
        }

        remove-item $modulePath -force;
        remove-item -path ( join-path 'dte:/solution/projects/solution items'  ($modulePath | split-path -leaf )) -force;
    }

    $slnName = ( $sln.FullName | split-path -leaf ) -replace '\..+$','';
    
    @"
# StudioShell solution module for ${slnName}
# 

`$menuItems = @(
    # list any menu items your module adds here
    #
    # e.g.:
    # new-item dte:/commandbars/help -name 'about my module' -value { 'Module ${slnName}' | out-outputpane; invoke-item dte:/windows/output; }
);

# this function is called automatically when your solution is unloaded
function unregister-${slnName}
{
    # remove any added menu items;
    `$menuItems | remove-item;
}
"@ | out-file -filepath $modulePath;

    if( -not ( test-path 'dte:/solution/projects/solution items' ) )
    {
        new-item -path 'dte:/solution/projects/solution items' -type folder;
    }
    new-item -path 'dte:/solution/projects/solution items' -filepath $modulePath;
}


<#
.SYNOPSIS 
Adds a new solution module to the currently open solution.

.DESCRIPTION
Adds a new solution module to the currently open solution.

.INPUTS
None.

.OUTPUTS
None.

.EXAMPLE
C:\PS> New-SolutionModule

This example adds a blank solution module to the current solution.
#>

