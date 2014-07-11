%include "vis_spec20.inc"

%define  MAX_INCREASE 20
%define  MAX_DECREASE 5

global winampVisGetHeader
extern winamp_dock

section .data

; Various strings that are used in the program. Mainly for
; descriptions and message box text.

pszDesc     db  'Spectrum Analyser 2.0.3',0
pszModule   db  'Spectrum Analyser (Engine 1.6.1)',0
pszAbout    db  'Spectrum Analyser Version 2.0.3 (x86) (Engine 1.6.1)',13,10
            db  'Copyright (C)2001 Insomnia Visions',0
pszWndClass db  '61736D_RootWindow',0

pszRegError db  'Unable to register window class',0
pszWndError db  'Unable to create main window',0

; The Vis Header - a winampVisHeader structure. See the vis.h in 
; the winamp SDK for the C style definition of this.

pHeader     dd  0x101, pszDesc, OnGetModule

; The Vis Module - a winampVisModule structure. Here we define 
; all the things that will remain constant throughout. This saves 
; us moving the data in when the program is run. See vis.h in the 
; winamp SDK for the C style definition of this.

pModule     dd  pszModule, 0, 0, 0, 0,  1,1,   1, 0
            times 0x900 db 0
            dd  OnConfig, OnInit, OnRender, OnQuit, 0

prcWindow   dd 0, 0, DEFAULT_WIDTH, DEFAULT_HEIGHT
prcTitle    dd 0, 0, DEFAULT_WIDTH, TITLE_HEIGHT
prcClose    dd CLOSE_LEFT, CLOSE_TOP, 
            dd CLOSE_WIDTH+CLOSE_LEFT, CLOSE_HEIGHT+CLOSE_TOP
bConfig     dd 0
bMouseDown  dd 0

pRemapData  db   0, 10, 25, 40, 80,120,140,158,164,169,174,178,182,186,189,
            db 191,194,197,199,201,203,205,207,209,210,211,213,214,215,216,
            db 218,219,220,221,222,223,223,224,225,226,227,228,228,229,230,
            db 230,231,231,232,232,233,233,234,234,235,235,236,236,237,237,
            db 237,238,238,239,239,239,240,240,240,241,241,241,241,242,242,
            db 242,242,243,243,243,243,244,244,244,244,244,245,245,245,245,
            db 245,246,246,246,246,246,246,247,247,247,247,247,247,247,247,
            db 248,248,248,248,248,248,248,248,249,249,249,249,249,249,249,
            db 249,249,249,250,250,250,250,250,250,250,250,250,250,250,250,
            db 251,251,251,251,251,251,251,251,251,251,251,251,251,251,251,
            db 252,252,252,252,252,252,252,252,252,252,252,252,252,252,252,
            db 252,252,252,252,252,252,253,253,253,253,253,253,253,253,253,
            db 253,253,253,253,253,253,253,253,253,253,253,253,253,253,253,
            db 253,253,253,253,253,253,254,254,254,254,254,254,254,254,254,
            db 254,254,254,254,254,254,254,254,254,254,254,254,254,254,254,
            db 254,254,254,254,254,254,254,254,254,254,254,255,255,255,255,
            db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
            db 255

%define g_hWndParent  [pModule+4];
%define g_hInstance   [pModule+8];
%define SpectrumData  36

section .bss

uSrcBlt     resd 1
hWindow     resd 1
wcx         resd 0x0C    ; WNDCLASSEX structure
 
hSkinBitmap resd 1       ; skin bitmap handle
hSkinDC     resd 1       ; skin device context

pBih        resd 1       ; pointer to BITMAPINFO structure
pPixels     resd 1       ; pointer to pixels
pPalette    resd 98      ; palette pointer, 0-94 = bars, 95=back, 96=grid, 97=peak
pPoint      resd 2       
pBarBuffer  resd 1       ; pointer to bar buffer

section .code


; winampVisGetHeader - this is the function that winamp will
; look for when it loads the library. It simply returns a pointer
; to the (already initialised) winampVisHeader structure.

winampVisGetHeader:
    mov   eax, pHeader
    ret


; OnGetModule - this function is pointed to by the winampVisHeader
; structure. Once winamp loads the header it will call this function.
; The function takes one 32-bit integer argument which represents the
; module number. A pointer to the corresponding module for the index 
; must be returned. This enables winamp to count the number of modules
; in the plugin. We only have one module so we return a pointer to that
; if index is zero and null if it's anything else.

OnGetModule:
    mov   eax, [esp+4]
    test  eax, eax
    jz    RetModule
    xor   eax, eax
    ret
RetModule: 
    mov   eax, pModule
    ret


; OnConfig - this function is called when the user clicks the
; "Config" button for the plugin. Right now since the config
; dialog hasn't been made we just show an about box.

OnConfig:
    mov   eax, [bConfig]
    or    eax, eax
    jnz   EndConfig
    mov   dword [bConfig], 1
    push  dword MB_ICONINFORMATION
    push  dword pszModule
    push  dword pszAbout
    push  dword g_hWndParent
    call  MessageBox
    mov   dword [bConfig], 0
EndConfig:
    ret


; OnInit - this is called when the user wants to start the plugin.
; Initialisation and window creation should be carried out here.
; The function should return zero on success and non zero on failure.

OnInit:
    mov   eax, g_hInstance

    ; initialise window class structure

    mov   dword [wcx], 48
    mov   dword [wcx+4], CS_DBLCLKS
    mov   dword [wcx+8], WindowProc
    mov   dword [wcx+12], 0
    mov   dword [wcx+16], 0
    mov   dword [wcx+20], eax,
    mov   dword [wcx+24], 0
    push  dword IDC_ARROW
    push  dword 0
    call  LoadCursor
    mov   dword [wcx+28], eax
    mov   dword [wcx+32], COLOR_WINDOW
    mov   dword [wcx+36], 0
    push  dword pszWndClass
    pop   dword [wcx+40]
    mov   dword [wcx+44], 0
    
    ; register the window class

    push  dword wcx
    call  RegisterClassEx
    or    eax, eax
    jnz   MakeWindow

    ; unable to register class so say so

    push  dword MB_ICONERROR
    push  dword pszModule
    push  dword pszRegError
    push  dword g_hWndParent
    call  MessageBox

    ; return error

    mov   eax, 1
    ret
    
MakeWindow:

    ; attempt to create the window

    push  dword 0
    push  dword g_hInstance
    push  dword 0
    push  dword g_hWndParent
    push  dword DEFAULT_HEIGHT
    push  dword DEFAULT_WIDTH
    push  dword 0
    push  dword 0
    push  dword WS_NOCAPTION
    push  dword pszModule
    push  dword pszWndClass
    push  dword WS_EX_TOOLWINDOW
    call  CreateWindowEx
    or    eax, eax
    jnz   DisplayWindow

    ; unable to create the window
    ; so first unregister the window class

    push  dword g_hInstance
    push  dword pszWndClass
    call  UnregisterClass
    
    ; and then let the user know about it

    push  dword MB_ICONERROR
    push  dword pszModule
    push  dword pszWndError
    push  dword g_hWndParent

    ; and quit

    mov   eax, 1
    ret

DisplayWindow:
    
    ; save window handle

    mov   [hWindow], eax

    ; create the DC

    push  dword 0
    call  CreateCompatibleDC
    mov   [hSkinDC], eax

    ; load the skin

    push  dword 0
    call  LoadSkin

    ; do the mandatory show and update 

    push  dword SW_SHOW
    push  dword [hWindow]
    call  ShowWindow
    push  dword [hWindow]
    call  UpdateWindow

    ; allocate some memory for the pixels and the
    ; bitmap info header, then initialise the
    ; bitmap info header
    
    push  dword BUFFER_SIZE
    push  dword LPTR
    call  LocalAlloc
    mov   [pPixels], eax

    push  dword 40 ;sizeof(BITMAPINFOHEADER)
    push  dword LPTR
    call  LocalAlloc
    mov   [pBih], eax
    mov   eax, [pBih]
    mov   dword [eax], 40
    mov   dword [eax+4], BLITTER_WIDTH
    mov   dword [eax+8], BLITTER_HEIGHT
    mov   dword [eax+12], 1
    mov   dword [eax+14], 32
    mov   dword [eax+16], BI_RGB
    mov   dword [eax+20], BUFFER_SIZE
    mov   dword [eax+24], 0
    mov   dword [eax+28], 0
    mov   dword [eax+32], 0
    mov   dword [eax+36], 0

    push  dword 576
    push  dword LPTR
    call  LocalAlloc
    mov   [pBarBuffer], eax

    ; success so return zero

    xor   eax, eax
    ret


; OnQuit - this is called when the user stops the plugin. Things
; like memory deallocation and destruction of windows should take
; place here. The function is not expected to return anything.

OnQuit:
    ; destroy the window

    mov   eax, [hWindow]
    push  eax
    call  DestroyWindow

    ; unregister the window class

    mov   eax, g_hInstance
    push  eax
    mov   eax, pszWndClass
    push  eax
    call  UnregisterClass

    ; free up the skin
    call FreeSkin

    ; delete the Skin DC and free memory

    mov   eax, [hSkinDC]
    push  eax
    call  DeleteDC
    mov   eax, [pPixels]
    push  eax
    call  LocalFree
    mov   eax, [pBih]
    push  eax
    call  LocalFree
    mov   eax, [pBarBuffer]
    push  eax
    call  LocalFree
    
    ; beep for now just for feedback    

    push  dword MB_ICONERROR
    call  MessageBeep
    ret


; OnRender - this is called every few milliseconds (the exact time
; is set in the winampVisModule structure). The plugin should render
; the visualisation data into graphics and display them here. Nothing
; too time consuming should occur or things will start to slow down.

OnRender:
    push  ebx
    push  esi
    push  edi

    ; first erase what's in the buffer already by drawing on it 
    ; in the background colour

    mov   eax, [pPalette+BACK_COLOUR]
    mov   ebx, [pPixels]
    mov   ecx, BUFFER_SIZE
    add   ecx, ebx
.eraseLoop:
    sub   ecx, 4
    mov   [ecx], eax
    cmp   ecx, ebx
    jg    .eraseLoop

    ; loops - edi represents the x loop, ecx represents the y loop
    ; the formula for calculating x/y offsets is:
    ; offset = mem + y * scanline_width + x. the edi loop decrements
    ; by 4 each time.

    mov   edi, SCANLINE_WIDTH
.outerLoop:
    sub   edi, 4

    ; get height of bar and first test it for zero. If it
    ; is then there is no point in wasting processing time
    ; on it so skip the loop

    
    shr   edi, 2
    mov   al, [pModule+SpectrumData+edi]
    
    ; then remap the data to the levels defined at the start
    ; of the app

    and   eax, 0xff    
    add   eax, pRemapData
    mov   al, [eax]
    and   eax, 0xff

    ; get the old value into ecx

    mov   esi, [pBarBuffer]           ; bar buffer pointer => esi
    mov   cl,  [esi+edi]              ; current bar => cl
    and   ecx, 0xff

    ; now fix the data
    
    cmp   eax, ecx
    jle   .else
    
    cmp   ecx, 0xff
    je    .endif
    sub   eax, ecx    ; change => eax
    cmp   eax, MAX_INCREASE
    jle   .use_real_value_0
    mov   eax, MAX_INCREASE
.use_real_value_0:
    mov   edx, ecx
    add   edx, eax
    cmp   edx, 0xff
    jg    .inner_else_0
    add   ecx, eax
    jmp   short .inner_endif_0
.inner_else_0:
    mov   ecx, 0xff
.inner_endif_0:
    jmp   short .endif
.else
    test  ecx, ecx
    jz   .endif

    mov   edx, ecx
    sub   edx, eax
    mov   eax, edx     ; change => eax

    cmp   eax, MAX_DECREASE
    jle   .use_real_value_1
    mov   eax, MAX_DECREASE
.use_real_value_1:

    mov   edx, ecx
    sub   edx, eax
    cmp   edx, 0
    jl    .inner_else_1
    sub   ecx, eax
    jmp   short .inner_endif_1
.inner_else_1:
    xor   ecx, ecx
.inner_endif_1:
.endif
    mov   [esi+edi], cl
    mov   al, cl
    shl   edi, 2
    test  al, al
    jz    .endLoop

    and   eax, 0xff    

    ; now correct al so it is between the range of zero and
    ; BLITTER_HEIGHT.

    mov   cl,  BLITTER_HEIGHT
    and   eax, 0xff
    and   ecx, 0xff
    mul   ecx
    mov   cl,  0xff
    and   ecx, 0xff
    div   ecx
    and   eax, 0xff

    ; test it again and go to the end of the inner loop if
    ; it is zero. 

    test  eax, eax
    jz    .endLoop

    mov   esi, eax
    mov   ecx, eax
.innerLoop:
    dec   ecx

    mov   eax, SCANLINE_WIDTH
    mul   ecx
    add   eax, ebx
    add   eax, edi

    ; this code generates the "fire style" bar look

    mov   edx, BLITTER_HEIGHT
    sub   esi, ecx
    sub   edx, esi
    add   esi, ecx
    dec   edx
    shl   edx, 2
    mov   edx, [pPalette+edx]

    ; this code generates the "normal style" bar look
    ; mov   edx, [pPalette+ecx*4]
 
    ; this code generates the "line style" bar look
    ; mov   edx, [pPalette+esi*4]

    ; set the pixel into memory

    mov   dword [eax], edx

    test  ecx, ecx
    jnz   .innerLoop
.endLoop
    test  edi, edi
    jnz   near .outerLoop
.endOuterLoop
    
    ; finally draw the buffer to the screen using the
    ; StretchDIBits function.

    mov   eax, [hWindow]
    push  eax
    call  GetDC
    push  eax
    push  dword SRCCOPY
    push  dword DIB_RGB_COLORS
    mov   ebx, [pBih]
    push  ebx
    mov   ebx, [pPixels]
    push  ebx
    push  dword BLITTER_HEIGHT
    push  dword BLITTER_WIDTH
    push  dword 0
    push  dword 0
    push  dword BLITTER_HEIGHT
    push  dword BLITTER_WIDTH
    push  dword BLITTER_TOP
    push  dword BLITTER_LEFT
    push  eax
    call  StretchDIBits
    pop   eax
    push  eax
    mov   eax, [hWindow]
    push  eax
    call  ReleaseDC

    ; restore saved registers and return zero

    pop   edi
    pop   esi
    pop   ebx
    xor   eax, eax
    ret   


; The window procedure

WindowProc:
    mov  eax, [esp+8] ; uMsg
    mov  ebx, [esp+4] ; hWnd

    ; filter the messages we want
    cmp  eax, WM_DESTROY   
    je   near OnMsgDestroy
    cmp  eax, WM_LBUTTONDOWN
    je   near OnMsgLButtonDown
    cmp  eax, WM_LBUTTONUP
    je   near OnMsgLButtonUp
    cmp  eax, WM_PAINT
    je   near OnMsgPaint
    cmp  eax, WM_ACTIVATE
    je   near OnMsgActivate
    cmp  eax, WM_MOUSEMOVE
    je   near OnMsgMouseMove
    cmp  eax, WM_WINDOWPOSCHANGING
    je   near OnMsgWindowPosChanging

    ; do the default
    jmp     DefWindowProc
OnMsgDestroy:
    push dword 0
    call PostQuitMessage
    jmp  RetWindowProc
OnMsgLButtonDown:
    push dword pPoint
    call GetCursorPos
    push dword pPoint
    push ebx
    call ScreenToClient
    push dword [pPoint+4]
    push dword [pPoint]
    push dword prcClose
    call PtInRect
    or   eax, eax
    jnz  .CloseButton
    push dword [pPoint+4]
    push dword [pPoint]
    push dword prcTitle
    call PtInRect
    or   eax, eax
    jz   .MouseDown
    push dword 0
    push dword HT_CAPTION
    push dword WM_NCLBUTTONDOWN
    push dword ebx
    call PostMessage
    jmp  RetWindowProc
.MouseDown
    mov  dword [bMouseDown], 1
    push ebx
    call SetCapture
    jmp  RetWindowProc
.CloseButton
    mov  dword [bMouseDown], 1
    push ebx
    call SetCapture
    push dword 1
    call PaintCloseButton
    jmp  RetWindowProc
OnMsgLButtonUp
    call ReleaseCapture
    mov  dword [bMouseDown], 0
    push dword pPoint
    call GetCursorPos
    push dword pPoint
    push ebx 
    call ScreenToClient
    push dword [pPoint+4]
    push dword [pPoint]
    push dword prcClose
    call PtInRect
    or   eax, eax
    jz   near RetWindowProc
    push dword 0
    call PaintCloseButton
    push dword 0
    call PostQuitMessage
    jmp  RetWindowProc
OnMsgMouseMove:
    mov  eax, [bMouseDown]
    or   eax, eax
    jz   near RetWindowProc
    push dword pPoint
    call GetCursorPos
    push dword pPoint
    push ebx 
    call ScreenToClient
    push dword [pPoint+4]
    push dword [pPoint]
    push dword prcClose
    call PtInRect
    or   eax, eax
    jz   .UnhiliteClose
    push dword 1
    call PaintCloseButton
    jmp  RetWindowProc
.UnhiliteClose
    push dword 0
    call PaintCloseButton
    jmp  RetWindowProc
OnMsgActivate:
    mov  eax, [esp+12]  ; wParam
    cmp  eax, WA_INACTIVE
    jne   .Activate
    mov  dword [uSrcBlt], TITLE_HEIGHT
    jmp  .Repaint
.Activate
    mov  dword [uSrcBlt], 0
    jmp  .Repaint
.Repaint
    push dword 0
    push dword prcTitle
    push ebx       ; hWnd
    call InvalidateRect
OnMsgPaint:
    ; reserve space for the PAINTSTRUCT
    sub  esp, 64
    push esp
    push ebx
    call BeginPaint
    push dword SRCCOPY
    push dword [uSrcBlt]
    push dword 0
    push dword [hSkinDC]
    push dword TITLE_HEIGHT
    push dword DEFAULT_WIDTH
    push dword 0
    push dword 0
    push dword [esp+32]
    call BitBlt
    push dword SRCCOPY
    push dword (TITLE_HEIGHT*2)
    push dword 0
    push dword [hSkinDC]
    push dword DEFAULT_HEIGHT
    push dword DEFAULT_WIDTH
    push dword TITLE_HEIGHT
    push dword 0
    push dword [esp+32]
    call BitBlt
    push esp
    push ebx
    call EndPaint
    add  esp, 64
    jmp  RetWindowProc
OnMsgWindowPosChanging:
    push ebx
    mov  ebx, [esp+8]  ; hWnd
    mov  eax, [esp+20] ; lParam
    lea  ecx, [eax+12] ; lpWndPos->y
    lea  edx, [eax+8]  ; lpWndPos->x
    push dword 10
    push ecx
    push edx
    push ebx
    call winamp_dock
    add  esp, 16
    pop  ebx
    jmp  RetWindowProc
RetWindowProc:
    xor  eax, eax
    ret  16

; LoadSkin - loads the current skin file - expects one arg, either the name
; of a bitmap or null for the default skin. It expects the hSkinDC device
; context to exist. LoadSkin uses the stdcall calling convention.

LoadSkin:
    mov  eax, [esp+4]
    or   eax, eax
    jz   BaseSkin
    mov  eax, 0
    ret  4
BaseSkin:
    ; check that we need to free the skin bitmap
    mov  eax, [hSkinBitmap]
    or   eax, eax
    jz   SkinFree
    call FreeSkin
SkinFree:
    ; load the base skin bitmap
    push dword IDB_SKIN
    push dword g_hInstance
    call LoadBitmap
    mov  [hSkinBitmap], eax
    
    ; and select it into the device context
    push eax
    push dword [hSkinDC]
    call SelectObject
    mov  [hSkinBitmap], eax
    call ReadColours
    ; return true
    mov  eax, 1
    ret 4

; FreeSkin does not expect any arguments

FreeSkin:
    push dword [hSkinBitmap]    ; reselect
    push dword [hSkinDC]
    call SelectObject
    mov  [hSkinBitmap], eax
    push dword [hSkinBitmap]    ; delete the bitmap
    call DeleteObject
    ret    

; ReadColours reads in the colours from the skin bitmap and 
; saves them in the colour palette.

ReadColours
    xor   ecx, ecx
.LoopStart
    cmp   ecx, 98
    je   .LoopEnd
    mov   eax, SKIN_COLOURS_LEFT
    add   eax, ecx
    push  ecx
    push  dword SKIN_COLOURS_TOP
    push  eax
    push  dword [hSkinDC]
    call  GetPixel
    
    ; About here I noticed something odd. The R and B components
    ; of the bars were comming out the wrong way round.
    ; The problem is that GetPixel returns an 0xBBGGRR00 format
    ; and 32-bit bitmaps expect and 0xRRGGBB00 format. 
    ; This corrects the problem

    mov   cx, ax   ; low 16 bits in cx
    shr   eax, 16  ; shift the top bit to the bottom bit
    xchg  cl, al  ; exchange red and blue bytes
    shl   eax, 16  ; shift back into top bit
    mov   ax, cx   ; put modified bottom back

    ; back to original code
 
    pop   ecx
    mov   dword [pPalette+ecx*4], eax
    inc   ecx
    jmp  .LoopStart
.LoopEnd
    ret

; PaintCloseButton expects 1 argument, a dword value.
; If the value is 1, the button is highlighted,
; if the value is zero, the button is unhighlighted

PaintCloseButton 
    push  ebp
    mov   ebp, esp
    push  ebx
    mov   eax, [ebp+8]
    or    eax, eax
    jz    .UnHilite
    mov   ebx, SKIN_CLOSE_LEFT+CLOSE_WIDTH
    jmp   .Paint
.UnHilite
    mov   ebx, SKIN_CLOSE_LEFT
.Paint
    sub   esp, 4
    push  dword [hWindow]
    call  GetDC
    mov   [esp], eax
    push  dword SRCCOPY
    push  dword SKIN_CLOSE_TOP
    push  ebx
    push  dword [hSkinDC]
    push  dword CLOSE_HEIGHT
    push  dword CLOSE_WIDTH
    push  dword CLOSE_TOP
    push  dword CLOSE_LEFT
    push  dword [esp+32]
    call  BitBlt
    push  dword [esp]
    push  dword [hWindow]
    call  ReleaseDC
    add   esp, 4
    pop   ebx
    mov   esp, ebp
    pop   ebp
    ret  4


