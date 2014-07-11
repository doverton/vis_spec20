Spectrum Analyser for Winamp
============================

This is a copy of an old winamp 2.x plugin I wrote years ago when I was
messing with x86 assembly. I have since realised that the compiler does
a significantly better job of this than me :-)

Uploaded for your entertainment...


Below is the original readme.txt:

This is the source code for Spectrum Analyser 2.0.3 for Winamp,
Copyright (C) 2001 David Overton (david@insomniavisions.com).
Website: http://www.insomniavisions.com.

This source may be redistributed in its original form, or a 
modified form provided that this file and all headers in the
source files remain.

Disclamer: While this software works fine on our computers, 
don't blame us if it trashes your hard disk and causes your
monitor to explode.

-- BUILD INSTRUCTIONS --

To build this you will need a copy of the Netwide Assembler (nasm).
This is available from http://nasm.2y.net

You will also need a resource compiler (such as the one distributed
with Microsoft Visual C++), a linker compatible with the Microsoft
import libraries (such as the microsoft linker) and the import
libraries "kernel32.lib", "user32.lib" and "gdi32.lib".

The command lines to build (assuming nasm, link, rc and the lib files
are in the path) are:

nasm -f win32 vis_spec20.asm -o vis_spec20.obj
nasm -f win32 dock.asm -o dock.obj
rc /fo vis_spec20.res /r vis_spec20.rc
link vis_spec20.obj dock.obj vis_spec20.res kernel32.lib user32.lib gdi32.lib /dll /noentry /opt:nowin98 /opt:ref /export:winampVisGetHeader /out:vis_spec20.dll

This should produce a 15.5 K DLL which you should then copy to your
winamp\plugins directory.

-- NOTES --

The skin bitmap is 8-bit RLE compressed to ensure minimum size. 
If you modify it, ensure that you save it to this specification if you 
want to keep the final size of the DLL down.

If you want to use a different linker and import libraries you can 
modify the .inc files. Right now they use extern to declare the actual
imports (ie extern __imp__GetWindowLongA@8), and then a macro
to define the actual name (ie %define GetWindowLong [__imp__GetWindowLongA@8])
Since it is done this way, modify the imports and the defines to 
use a different linker and libraries (such as the borland linker).
You shouldn't need to touch the source.




