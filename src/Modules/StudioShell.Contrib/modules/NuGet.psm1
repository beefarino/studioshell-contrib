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
#   NuGet functions module
#   
#   many thanks to Attila Hajdrik (@attilah) for pulling this together:
#     https://gist.github.com/attilah/539f5d7fe5f637bf9f0c

Add-Type -AssemblyName NugetConsole.Host.PowerShell
 
#
# These functions are from Nuget test sources, the key here is to get access to an IVsPackageSourceProvider instance.
#
 
function Get-Interface
{
    Param(
        $Object,
        [type]$InterfaceType
    )
    
    [NuGetConsole.Host.PowerShell.Implementation.PSTypeWrapper]::GetInterface($Object, $InterfaceType)
}
 
function Get-VSService
{
    Param(
        [type]$ServiceType,
        [type]$InterfaceType
    )
 
    $service = [Microsoft.VisualStudio.Shell.Package]::GetGlobalService($ServiceType)
    if ($service -and $InterfaceType) {
        $service = Get-Interface $service $InterfaceType
    }
 
    $service
}
 
function Get-VSComponentModel
{
    Get-VSService ([Microsoft.VisualStudio.ComponentModelHost.SComponentModel]) ([Microsoft.VisualStudio.ComponentModelHost.IComponentModel])
}
 
function Enable-NugetPackageRestore {
    if (!$dte.Solution -or !$dte.Solution.IsOpen) 
    {
        throw "No solution is available."
    }
 
    $componentService = Get-VSComponentModel
    
    # change active package source to "All"
    $packageSourceProvider = $componentService.GetService([NuGet.VisualStudio.IVsPackageSourceProvider])
    $packageSourceProvider.ActivePackageSource = [NuGet.VisualStudio.AggregatePackageSource]::Instance
    
    $packageRestoreManager = $componentService.GetService([NuGet.VisualStudio.IPackageRestoreManager])
    $packageRestoreManager.EnableCurrentSolutionForRestore($false)
}
 
export-moduleMember -Function enable-nugetpackagerestore;