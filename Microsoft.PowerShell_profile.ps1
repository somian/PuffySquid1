
# Messing around with this pretty frequently.  This is file:
# %USERPROFILE%\My Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

function Color-Cons 
 {
      # 2.0
      $panda = $Host.Version
      $host.ui.rawui.backgroundcolor = 0
      $host.ui.rawui.foregroundcolor = 7
      $Host.UI.RawUI.WindowTitle = "Windows PowerShell $panda ($env:USERNAME)"
 }

function get-fso-File([string]$pth) {
   BEGIN { $fso = New-Object -ComObject Scripting.FileSystemObject }
 PROCESS {
 $juy = ""
 Try {
        $fso.getFile($pth)
 } catch {
     If ($_.Exception.GetType().Name -eq "MethodInvocationException") {
         Write-Verbose "The parameter passed was maybe not a file ...: $pth"
       # examine the exception fully, fwiw:
       # $_.Exception.GetType() | get-Member
     Try {
        $bwoo = $fso.getFolder($pth)
        $juy  = $bwoo.ShortPath
       } catch {  # strange:  >>>>System.__ComObject C:/DOCUME~1/singsong<<<<
           $BadNews = $_.Exception
           Write-Verbose "The parameter passed was not a file nor a folder, or something went wrong ...: $pth"
           If ($BadNews.GetType().Name -eq "MethodInvocationException") {
               Write-Host "Another exception. The parameter DOLLA-pth is : >>>>>" + $pth.fullname + "<<<<<"
           } Else {
               $phew = $BadNews.GetType().Name
               Write-Host "The bad news had to do with: $phew"
           }
       }
     }
 } Finally {
               If ( "$juy" ) { Write-Verbose "We are returning $juy" }
               Else {          Write-Verbose "We may not return something useful now, but ..." }
           }
 # Fall-back ^^^^^^
   $juy  # return whatever it is we have
 }
}


function get-skwige([string]$oh) {
    $zok = $oh
    $r = get-fso-File $zok
    $r = $r.replace( '\' , '/' )
    $r
}


#  # Examine ENVIRONMENT
$noWant = @("LOGONSERVER") # , "PATHEXT")
    Get-ChildItem Env: |Where-Object {$_.Name -like "*PROGRAM*" -OR $_.Name -like "*DATA*" -OR $_.Name -like "*ALL*"}
# &&&&& # HEY, thanks, #PowerShell @ Freenode
$eAsTable = [Environment]::GetEnvironmentVariables()
$hong = @()
# $eAsTable.Keys | % { "eparam = $_ ,  " + $eAsTable.Item($_) } | Where-Object {$_.Name -like "*CONEMU*" } 
foreach ($he in $eAsTable.GetEnumerator()) {
    $eek = $he.Name
    $vee = $he.Value
    If ( $noWant -iContains "$eek" )        { $hong = $hong + "$eek" }
  ElseIf ( "$eek" -Match ".*PROCESSOR.*" )  { $hong = $hong + "$eek" }
  ElseIf ( "$eek" -Match ".*ConEmuWorkD.*") { $hong = $hong + "$eek" }
}
# If ($hong.Count) { $hong }
If ($hong.Count) {
   Push-Location
   Set-Location "Env:"
   ForEach ($vamp in $hong) {
       $var_named = '$env:' + "$vamp"
       Clear-Item ".\$vamp"    # BOOM :-)
       write-Host "Cleared env var. $var_named"
   }
   Pop-Location
   Start-Sleep -Milliseconds 10000 ; clear-Host
     # Display of Env for a little while, then clear the console.
}


# If : because we are running Vim (a vim process is our parent)
Get-ChildItem Env: |Where-Object {
If ($_.Name -like "*VIM*") {
     & "C:\Documents and Settings\singsong\My Documents\WindowsPowerShell\GVim.Powershell_profile.ps1"
     Clear-Host
} Else {
  $histlog = Register-EngineEvent -SourceIdentifier ([System.Management.Automation.PsEngineEvent]::Exiting) -Action {Get-History | Export-Clixml $env:APPDATA\PowerShell\history.xml}
# Run console colors setup
  Color-Cons

  Function canonfodda([string]$epathval) {
    $arfl = $epathval
    $arfl = $arfl.replace('\', '/')
    $arfl
  }

  Function exec-gvim-right( ) {
  $argstr = $args -Join ' '
  $uProf= $env:USERPROFILE
  $h = (Get-Host).PrivateData
  $h.WarningForegroundColor = "White"
  If ("$uProf") {
     $uprol = get-skwige "$uProf"
     $env:VIMINIT = 'let $MYVIMRC="' + "$uprol/CONFIG/Vim7-vimrc" + '" |source $MYVIMRC'
  # Nice to do more Env munging, so:
     $Env:APPDATA = get-fso-file "$Env:AppData"
     $Env:ProgramFiles = get-fso-file "$Env:ProgramFiles"
     $Env:CommonProgramFiles = get-fso-file "$Env:CommonProgramFiles"

  # Test for the path we want to link a junction to
  #   *APPDATA* must exist.
  # C:\DOCUME~1\singsong\APPLIC~1
    $ourVim = ''
    If (Test-Path "$Env:APPDATA") {
        $save_bw_APPDATA = "$env:APPDATA"
        $munge_APPD = "$Env:APPDATA".replace('\' ,'/')
        $ourVim = join-Path "$Env:APPDATA" 'VimFiles' }
    $vimSyn = join-Path "$ourVim" -childPath 'vim74\syntax'
    If ((Test-Path "$ourVim") -AND (Get-Item "$ourVim").Attributes.ToString().Contains("ReparsePoint")) {
      Write-Verbose "Confirmed that $vimSyn is existing"
    }
      ElseIf ( -NOT (test-Path "$vimSyn" )) { Install-Junction -Link "$ourVim" -Target 'C:\AABS-Editor-Vim\7_4_27\vim' -Force }

  # otherwise junction.exe to dir here: junction.exe /accepteula "$ourVim" "C:\AABS-Editor-Vim\7_4_27\vim"
  # OR use
  #   Install-Junction [-Link] <String> [-Target] <String> [-Force] 
  #-# Returns a System.IO.DirectoryInfo object for the junction, if one is created.
    If (test-Path $vimSyn) {
    # 'C:\AABS-Editor-Vim\7_4_27\vim' 'vim74' 'syntax' 
    # 
    # It is not standard to set $VIM but we will do it.
    #
  # ---------------------- SET $Env:VIM ( $VIM ) --------------------
             $munge_VIM = "$Env:VIM".replace('\' ,'/')
             $Env:VIM = "$munge_Vim"
             $Env:VIMUSERDIR = "$munge_Vim"
             $Env:VIMRUNTIME = join-Path "$ourVim" 'vim74'
                 # inform user here
             Write-Verbose "VIM being set to $munge_Vim"
             Write-Verbose "and thus runtime as $Env:VIMRUNTIME"
          # VIMRUNTIME ??? should should eq "$Env:VIM\\runtime" ??? 
         } else {
             $Env:VIMUSERDIR = "$Env:APPDATA\VimFiles"
         }
    }

  # -------- MODIFY THE ENVIRON THAT CHILD PROCESS INHERITS ---------
   # $env: ... TODO
     $env:ProgramFiles       = canonfodda( $Env:ProgramFiles )
     $env:CommonProgramFiles = canonfodda( $Env:CommonProgramFiles )

     $env:APPDATA = "$munge_APPD"
  # ---------------------- START GVIM -------------------------------
     Start-Process -FilePath "C:\AABS-Editor-Vim\7_4_27\vim\vim74\gvim.exe"  -ArgumentList "-N -p $argstr"
     $env:APPDATA = $save_bw_APPDATA
  }

  Set-Alias -Name "GVim" exec-gvim-right -Description "Run Gui Vim editor"
  Function gtAD {
     pushd "$env:APPDATA"
  }
# Save history to file
$histlog = Register-EngineEvent -SourceIdentifier ([System.Management.Automation.PsEngineEvent]::Exiting) -Action {Get-History | Export-Clixml $env:APPDATA\PowerShell\history.xml}
#  ---- Clear-Host
} }  # Close "Where-Object"
