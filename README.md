# studioshell-contrib

The intent of this project is to capture useful StudioShell operations as functions from the community.

# Contributing

The module is structured to allow extension in two ways:

1. Individual functions are added as script files in the /src/Modules/StudioShell.Contrib/scripts folder.  
Each script in this folder becomes a command when the StudioShell.Contrib module is imported.
1. Collections of functions are added as submodules in the /src/Modules/StudioShell.Contrib/modules folder.
Each module in this folder is imported when the StudioShell.Contrib module is imported, making their exported commands accessible 
in the user's session.

## General Acceptance Criteria

1. I can find your function using `get-command -module StudioShell.Contrib -noun <target>`, where `<target>` is the DTE or StudioShell 
object on which the function operates.  E.g., `get-command -module StudioShell.Contrib -noun project`
1. I can obtain complete help for your function using `get-help <commandname> -full`.  Help is considered "complete" when it includes:
    * a synposis section
    * a description section **if** the behavior of the function is not fully captured in the synopsis section
    * specific documentation for each parameter, including 
    * at least one example demonstrating each available parameter set
    * type and semantic specification of accepted pipeline inputs and outputs
1. I can use -whatif on your function if it performs any write, remove, or invoke operation.
1. I can use your function in the middle of a pipeline. 
1. I can use your function from any location in the StudioShell console.
1. I can use your function in **both** PowerShell v2.0 and v3.0 environments
