#
#   Copyright (c) 2014 Code Owls LLC, All Rights Reserved.
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
#	VSSettings submodule
#

function export-VisualStudioSettings
{
    param( 
                
        [parameter(Mandatory=$true, Position=0)]
        [alias("filename")]
        [string] 
        # the name of the settings file to create
        $name 
    )

    process
    {
        if( $name -notmatch '\.vssettings' )
        {
            $name += '.vssettings';
        }

        $dte.executeCommand("Tools.ImportandExportSettings", "/export:$name");
        get-item 'DTE:\properties\Environment\Import and Export Settings\autosavefile' | select -exp value | split-path -Parent | Join-Path -ChildPath $name;

    }
<# 
   .Synopsis 
    Exports all Visual Studio settings to the specified settings file
   .Example 
    export-VisualStudioSettings -name "my.vssettings"
    saves all settings into the my.vssettings file 
   .Inputs
    String.  The name of the settings file.
   .Outputs
    Object.  The file object representing the settings file.
   .Notes 
    NAME: Export-VisualStudioSettings
    AUTHOR: beefarino 
   #Requires -Version 2.0 
#> 

}
    
function import-VisualStudioSettings
{
    param( 
                
        [parameter(Mandatory=$true, Position=0)]
        [alias("filename")]
        [string] 
        # the name of the settings file to import
        $name 
    )

    process
    {
        if( $name -notmatch '\.vssettings' )
        {
            $name += '.vssettings';
        }

        $dte.executeCommand("Tools.ImportandExportSettings", "/import:$name");

    }
<# 
   .Synopsis 
    Imports all Visual Studio settings from the specified settings file
   .Example 
    import-VisualStudioSettings -name "my.vssettings"
    loads all settings from the my.vssettings file 
   .Inputs
    String.  The name of the settings file.
   .Outputs
    None.
   .Notes 
    NAME: import-VisualStudioSettings
    AUTHOR: beefarino 
   #Requires -Version 2.0 
#> 
}

function get-VisualStudioSettingsFile
{
    param( 
                
        [parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [alias("filename")]
        [string] 
        # the name of the settings file; wildcards accepted
        $name ='*'
    )

    begin
    {
        $settingsFolder = get-item 'DTE:\properties\Environment\Import and Export Settings\autosavefile' | select -exp value | split-path -Parent;
    }
    process
    {                
        if([System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters( $name ) )
        {
            $wc = new-object System.Management.Automation.WildcardPattern $name
            ls $settingsFolder | where { $wc.IsMatch( $_ ) }
        }
        else
        {
            if( $name -notmatch '\.vssettings' )
            {
                $name += '.vssettings';
            }
        
            $settingsFolder | join-path -ChildPath $name | get-item;
        }

    }
<# 
   .Synopsis 
    Lists one or more Visual Studio settings files
   .Example 
    get-VisualStudioSettingsFile
    lists all settings files
   .Inputs
    String[].  The name of the settings file(s) to list; wildcards permitted
   .Outputs
    Object.  The file object representing the settings file.
   .Notes 
    NAME: get-VisualStudioSettingsFile
    AUTHOR: beefarino 
   #Requires -Version 2.0 
#> 

}
    
    