
:: Forked & majorly improved from a script written by Dave Benham and originally posted at
:: http://www.dostips.com/forum/viewtopic.php?f=3&t=7990&start=15#p53278
:: Please read the following to properly obfuscate:
::
::
:: Drag the unobfuscated file into batfuscator.bat to obfuscate.
::
::
::   The source file should consist of pure ASCII - no extended ASCII allowed.
::
::    The source file must contain lines less that 100 characters.
::
::     The source file must be in the exact same folder as the obfuscator.
::
::      Obfuscation cannot contain characters such as: ./:/!/*/)/(/,/; <between others>
::
::
::  For optimal obfuscation, the source code should adhere to these rules:
::
::    - Labels should be enclosed in braces:
::        :{Label}
::        goto {Label}
::        call :{Label}
::
::    - User defined variable names should be enclosed in braces:
::        set "{VarName}=value"
::        echo %{VarName}% or %{VarName}:find=replace%  etc.
::        echo !{VarName}! or !{VarName}:find=replace!  etc.
::
::    - Standard "variable" names like %comspec%, %random%, etc. should NOT be
::      enclosed in braces. Such variables will not be obfuscated. If possible,
::      use delayed  expansion instead. For eample - !comspec!, !random!, etc.
::      Variable names within delayed expansion are obfuscated.
::
::    - Text that should remain human readable within the resultant code should
::      be enclosed in {: }
::        {:This text is not obfuscated}
::
::    - Text that should have the ROT13 cipher applied, but not encoded as
::      %HiByte%, should be enclosed in {< }
::        {< This text has the ROT13 cipher applied only }
::
::    - Comments of the form %=Comment=% should be enclosed within braces
::        %={ ROT13 will be applied to this comment }=%
::
::    - Remember to use /M if text between braces spans multiple lines
::
::  When the obfuscated code is run, the current code page is stored, and the
::  code executes within a child cmd.exe process using code page 708. Any
::  command line arguments are passed without changes as long as all poison
::  characters are quoted. The use of escaped poison characters on the command
::  line is complicated and therefore discouraged.
::
::  Upon termination, the code page is restored to the original value and the
::  original environment is restored.


@echo off&title batfuscator v0.2

SETLOCAL DISABLEDELAYEDEXPANSION
IF "%~1"=="" echo [-] Missing input file&timeout /T 99999 /NOBREAK>NUL
IF not exist "JREPL.bat" echo [-] JREPL not located&timeout /T 99999 /NOBREAK>NUL
IF /I "%~x1" neq ".bat" IF /I "%~x1" neq ".cmd" echo [-] Invalid file type&timeout /T 99999 /NOBREAK>NUL
 SET "in=%~1"
IF not defined in title  &echo [-] Missing input file&timeout /T 99999 /NOBREAK>NUL
 SET "out=%~2"
IF not defined out SET "out=%~dpn1_obfuscated%~x1"

SETLOCAL ENABLEDELAYEDEXPANSION
for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t1=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100"
echo [+] batfuscator v0.2&timeout /t 1 /nobreak>NUL
echo [*] Generating random straightline sequence...
  SET RNDL=5
  SET RNDA=1lI
  SET RNDS=%RNDA%987654321
:rndll
IF NOT "%RNDS:~18%"=="" SET RNDS=%RNDS:~9%& SET /A _Len+=9& GOTO :RNDLL
  SET _tmp=%RNDS:~9,1%
  SET /A _Len=_Len+_tmp
  SET RNDLC=0
  SET RNDAM=
:rndlo
  SET /A RNDLC+=1
  SET _RND=%Random%
  SET /A _RND=_RND%%%_Len%
  SET RNDAM=!RNDAM!!RNDA:~%_RND%,1!
IF !RNDLC! lss %RNDL% goto RNDLO
SETLOCAL DISABLEDELAYEDEXPANSION&goto :obfuscator

:write
echo.
echo.
echo @echo off^&(IF defined @lo@ goto !hi:~0,1!)^&SETlocal disableDelayedExpansion^&for /f "delims=: tokens=2" %%%%A in ('chcp') do SET "@chcp@=chcp %%%%A>nul"^&chcp 708^>nul^&SET ^^^^"@args@=%%*"
echo SET "@lo@=!lo!"
echo SET "@hi@=!hi!"
echo (SETlocal enableDelayedExpansion^&for /l %%%%N in (0 1 93) do SET "^!@hi@:~%%%%N,1^!=^!@lo@:~%%%%N,1^!")^&cmd /c ^^^^^""%%~f0" ^^!@args@^^!"
echo %%@chcp@%%^&exit /b
echo :!hi:~0,1!
jrepl "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"^
      "nopqrstuvwxyzabcdefghijklmNOPQRSTUVWXYZABCDEFGHIJKLM"^
      %/m% /t "" /p "{[^:}][^}]*}" | jrepl find repl %/m% /t @ /v /x /jq
exit /b

:obfuscator
SETLOCAL DISABLEDELAYEDEXPANSION
echo [*] Creating variables...
  SET "find={[:<][^}]*}|^[^:\r\n]?[ \t=,;\xFF]*:[^ \t:\r\n+]*[ \t:\r\n+]?|%%%%|%%\*|%%(?:~[fdpnxsatz]*(?:\$[^:\r\n]+:)?)?[0-9]|%%[^%%\r\n]+%%|%%@[\x20-\x24\x26-\x7E]"
  SET "repl=$txt=$0@$txt='%%'+String.fromCharCode($0.charCodeAt(0)+129)+'%%'+'%%I1IlllIl%%'+'%%lIl1lIl%%'+'%%I%RNDAM%l%%'+'%%lI1IIl1l%%'+'%%lIl1lIl%%'+'%%lI1I11I%%'+'%%l%RNDAM%I%%'"

SETLOCAL ENABLEDELAYEDEXPANSION
echo [*] Replacing characters...
SET "str1="
SET "x=x"
FOR %%A in (2 3 4 5 6 7) do @for %%B in (0 1 2 3 4 5 6 7 8 9 A B C D E F) do SET "str1=!str1!\x%%A%%B"
  SET "str1=%str1:~0,-4%"
  SET "str1=%str1:\x22=%\x22"
  SET "str1=%str1:\x24\x25=DDDD%"
call jrepl x str1 /M /X /V /S X /rtn lo
SET "lo=!lo:DDDD=$!"

SET "str2="
FOR %%A in (A B C D E F) do @for %%B in (0 1 2 3 4 5 6 7 8 9 A B C D E F) do SET "str2=!str2!\x%%A%%B"
  SET "str2=%str2:~4%"
  SET "str2=%str2:\xA3=%\xA3"
  SET "str2=%str2:\xA6=%"
call jrepl x str2 /M /X /V /S X /rtn hi
call :write <"!in!" >"!out!"

SET "target.exe=%~dpn1_obfuscated.exe"
  SET "batch_file=%~f1"
  SET "bat_name=%~n1_obfuscated%~x1"
  SET "bat_dir=%~dp1"
SET "sed=%temp%\2exe.sed"
echo [*] Packing file...
copy /Y "%~f0" "%sed%" >nul
(
    (echo()
    (echo(AppLaunched=cmd /c "%bat_name%")
    (echo(TargetName=%target.exe%)
    (echo(FILE0="%bat_name%")
    (echo([SourceFiles])
    (echo(SourceFiles0=%bat_dir%)
    (echo([SourceFiles0])
    (echo(%%FILE0%%=)
)>>"%sed%"

iexpress /N /Q /M %sed%
echo [*] Deleting junk ^& renaming files...
  del /F /Q "%sed%"
  del /F /Q %~n1_obfuscated.bat
  ren %~n1_obfuscated.exe %~n1_obfuscated.bat
for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do (
    set /a "t2=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100, tDiff=t2-t1, tDiff+=((~(tDiff&(1<<31))>>31)+1)*8640000"
)
set /a time="!tdiff!*10"
echo.
echo Obfuscation completed in %time%ms
pause>NUL
exit /B 0

[Version]
Class=IEXPRESS
SEDVersion=3
[Options]
PackagePurpose=InstallApp
ShowInstallProgramWindow=0
HideExtractAnimation=1
UseLongFileName=1
InsideCompressed=0
CAB_FixedSize=0
CAB_ResvCodeSigning=0
RebootMode=N
InstallPrompt=%InstallPrompt%
DisplayLicense=%DisplayLicense%
FinishMessage=%FinishMessage%
TargetName=%TargetName%
FriendlyName=%FriendlyName%
AppLaunched=%AppLaunched%
PostInstallCmd=%PostInstallCmd%
AdminQuietInstCmd=%AdminQuietInstCmd%
UserQuietInstCmd=%UserQuietInstCmd%
SourceFiles=SourceFiles

[Strings]
InstallPrompt=
DisplayLicense=
FinishMessage=
FriendlyName=-
PostInstallCmd=<None>
AdminQuietInstCmd=
