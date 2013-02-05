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
#	StudioShell.Contrib primary module 
#

$local:root = $myInvocation.MyCommand.Path | split-path;
write-debug "local module root path is $local:root"

ls $local:root/scripts/*.ps1 | foreach {
	$local:c = ( get-content -path $_.pspath ) -join "`n";	
	$local:n = $_.Name -replace '.{4}$','';
	
    write-verbose "defining module function ${local:n}"
	$local:fxn = "function $local:n`n{`n$local:c`n}";
	    
	write-debug $local:fxn
	invoke-expression $local:fxn;
}

ls $local:root/modules/*.psm1 | foreach {
    write-debug "importing submodule $_"
    import-module $_;
}
