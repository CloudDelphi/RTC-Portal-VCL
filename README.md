RTC Portal VCL

http://www.realthinclient.com

Copyright (c) 2003-2017 RealThinClient components

All Rights reserved.

--------------------------------
********************************

1.) Installing Portal components and compiling Demos

2.) RTC Portal Host with a Video Mirror Driver

3.) Emulating Ctrl+Alt+Del

4.) Disclaimer

********************************
--------------------------------

--------------------------------------------------------
1.) INSTALLING Portal components and COMPILING Portal Demos
--------------------------------------------------------

RTC Portal is compatible with Delphi 7 - 10.2 for the Win32 platform.

To be able to open and compile the RTC Portal projects, 
you will need to install the RealThinClient SDK v9 or later.

There are two editions of the RTC SDK v9 available.

A) RTC SDK *Starter* edition is available here:
  > http://www.realthinclient.com/download/

Starter editons of the RTC SDK include all components from the
commercial RTC SDK release, but are limited to 10 connections and
can ONLY be used to compile Win32 Projects with Delphi 7 - 10.2

B) Full *commercial* RTC SDK version can be ordered here:
  > http://www.realthinclient.com/priceorder/

To intall the RealThinClient SDK, please follow the instructions
from the "readme.txt" file in the RealThinClient SDK package.

Once RealThinClient SDK is installed, please unpack all RTC Portal files
into a folder of your choice, but NOT into the RealThinClient SDK folder.

To make RTC Portal Lib files accessible from all RTC Portal projects,
select "Tools / Environment Options" from the Delphi menu, then open
the "Library" tab and add the full path to the "Lib" folder as "Library path".

Once you are finished with the above setup, you should open the package
file "rtcPortal.dpk" from the "Lib" folder, compile and install it.

After that, you will be able to compile all projects from the "Demos" folder.

-----------------------------------------------
2.) RTC Portal Host with a Video Mirror Driver
-----------------------------------------------

RTC Portal Host can use the DemoForge Mirage Driver for faster screen capture.

DemoForge Mirage Driver is available directly from DemoForge:
> http://www.demoforge.com/dfmirage.htm


-----------------------------------------------
3.) Emulating Ctrl+Alt+Del
-----------------------------------------------

For the abbility to emulate <Ctrl+Alt+Del> when the Host is running as a Windows Service,
the "aw_sas32.dll" file has to be placed in the same folder as the RTC HOST executable.

"aw_sas32.dll" was developed by Jose Pascoa and can be dowloaded here:

https://softltd.wordpress.com/simulate-ctrl-alt-del-in-windows-vista-7-and-server-2008/

... or here:
https://softltd.wordpress.com/

-----------------------------------------------
4.) Disclaimer
-----------------------------------------------

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT SUPPORT AND WITHOUT WARRANTY OF ANY KIND, 
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS 
OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
