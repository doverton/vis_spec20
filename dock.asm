; Window dock functions - dock_edge is essentially a function from the original 
; version of XMMS, hand-compiled (badly). Please visit http://www.xmms.org :-)

%include "dock.inc"

global winamp_dock

section .data

pszWinampMw db  'Winamp v1.x',0
pszWinampEq db  'Winamp EQ',0
pszWinampPe db  'Winamp PE',0
pszWinampMb db  'Winamp MB',0

section .code

; This function calculates whether or not to dock to specific edges
; of the window. The way to use this is to call it twice, the first
; time specify the arguments in the original order, the second time,
; swap all horizontal and vertical values. This code was adapted from
; the C code that XMMS uses for docking.
;
; The C function prototype for this is:
;
; void __cdecl dock_edge(int *x, int *y, int w, int h, int bx, int by, int bw, int bh, int sd);
;
; x  = pointer to the current x position
; y  = pointer to the current y position
; w  = width of the window you wish to dock
; h  = height of the window you wish to dock
; bx = x location of window to dock to
; by = y location of window to dock to
; bw = width of window to dock to
; bh = height of window to dock to
; sd = snap distance in pixels

dock_edge:
    push  ebp
    mov   ebp, esp
    push  ebx
    
    mov   eax, [ebp+8]      ; &x
    mov   edx, [ebp+16]     ; w
    mov   ebx, [ebp+24]     ; bx
    mov   ecx, [ebp+40]     ; sd
    add   edx, [eax]        ; edx = (w + *x)
    sub   ebx, ecx          ; ebx = bx - sd
    cmp   edx, ebx
    jle   near .outer_if_0_failed

    mov   ebx, [ebp+24]     ; bx -> ebx, ecx still = sd
    add   ebx, ecx          ; ebx = bx + sd
    cmp   edx, ebx          ; edx still = (w + *x)
    jge   .outer_if_0_failed
    
    mov   eax, [ebp+12]     ; eax = &y
    mov   ebx, [ebp+28]     ; ebx = by
    mov   edx, [ebp+20]     ; edx = h
    sub   ebx, edx          ; by -= h
    sub   ebx, ecx          ; by -= sd (ecx still = sd)
    mov   edx, [eax]        ; edx = *y
    cmp   edx, ebx          ; compare *y with by-h-sd
    jle   .outer_if_0_failed

    mov   ebx, [ebp+28]     ; ebx = by
    mov   eax, [ebp+36]     ; eax = bh
    add   ebx, eax          ; by += bh
    add   ebx, ecx          ; by += sd
    cmp   edx, ebx          ; comp *y with by+bh+sd
    jge   .outer_if_0_failed

    mov   eax, [ebp+8]      ; eax = &x
    mov   edx, [ebp+16]     ; edx = w
    mov   ebx, [ebp+24]     ; ebx = bx
    sub   ebx, edx          ; ebx = bx - w
    mov   [eax], ebx        ; *x = ebx

    mov   eax, [ebp+12]     ; eax = &y
    mov   ebx, [ebp+28]     ; ebx = by
    sub   ebx, ecx          ; ebx = by - sd
    mov   edx, [eax]        ; edx = *y
    cmp   edx, ebx          
    jle   .inner_if_0_failed 

    add   ebx, ecx          ; ebx = by
    add   ebx, ecx          ; ebx = by + sd
    cmp   edx, ebx        
    jge   .inner_if_0_failed
    
    sub   ebx, ecx          ; ebx = by
    mov   [eax], ebx        ; *y = ebx
		
.inner_if_0_failed:

    mov   ebx, [ebp+20]
    add   edx, ebx          ; edx = (*y + h)
    mov   ebx, [ebp+28]     ; ebx = by
    add   ebx, [ebp+36]     ; ebx += bh
    sub   ebx, ecx          ; ebx -= sd
    cmp   edx, ebx
    jle   .inner_if_1_failed

    add   ebx, ecx          ; ebx += sd
    add   ebx, ecx          ; ebx += sd : ebx = by + bh + sd
    cmp   edx, ebx
    jge   .inner_if_1_failed

    sub   ebx, ecx          ; ebx = by + bh
    mov   edx, [ebp+20]     ; edx = h
    sub   ebx, edx          ; ebx -= h
    mov   [eax], ebx        ; set it

.inner_if_1_failed:    
.outer_if_0_failed:

    mov   eax, [ebp+8]      ; eax = &x
    mov   ebx, [ebp+24]     ; ebx = bx
    mov   edx, [ebp+32]     ; edx = bw
    add   ebx, edx          ; ebx = bx + bw
    sub   ebx, ecx          ; ebx = bx + bw - sd
    mov   edx, [eax]        ; edx = *x
    cmp   edx, ebx
    jle   .outer_if_1_failed

    add   ebx, ecx          ; ebx = bx + bw
    add   ebx, ecx          ; ebx = bx + bw + sd
    cmp   edx, ebx
    jge   .outer_if_1_failed

    mov   eax, [ebp+12]     ; eax = &y
    mov   ebx, [ebp+28]     ; ebx = by
    mov   edx, [ebp+20]     ; edx = h
    sub   ebx, edx          ; ebx = by - h
    sub   ebx, ecx          ; ebx = by - h - sd
    mov   edx, [eax]        ; edx = *y
    cmp   edx, ebx
    jle   .outer_if_1_failed

    mov   ebx, [ebp+28]     ; ebx = by
    mov   eax, [ebp+36]     ; eax = bh
    add   ebx, eax          ; by += bh
    add   ebx, ecx          ; by += sd
    cmp   edx, ebx          ; comp *y with by+bh+sd
    jge   .outer_if_1_failed

    mov   eax, [ebp+8]      ; eax = &x
    mov   edx, [ebp+32]     ; edx = bw
    mov   ebx, [ebp+24]     ; ebx = bx
    add   ebx, edx          ; ebx = bx + bw
    mov   [eax], ebx        ; *x = ebx

    mov   eax, [ebp+12]     ; eax = &y
    mov   ebx, [ebp+28]     ; ebx = by
    sub   ebx, ecx          ; ebx = by - sd
    mov   edx, [eax]        ; edx = *y
    cmp   edx, ebx          
    jle   .inner_if_2_failed 

    add   ebx, ecx          ; ebx = by
    add   ebx, ecx          ; ebx = by + sd
    cmp   edx, ebx        
    jge   .inner_if_2_failed
    
    sub   ebx, ecx          ; ebx = by
    mov   [eax], ebx        ; *y = ebx
		
.inner_if_2_failed:

    mov   ebx, [ebp+20]
    add   edx, ebx          ; edx = (*y + h)
    mov   ebx, [ebp+28]     ; ebx = by
    add   ebx, [ebp+36]     ; ebx += bh
    sub   ebx, ecx          ; ebx -= sd
    cmp   edx, ebx
    jle   .inner_if_3_failed

    add   ebx, ecx          ; ebx += sd
    add   ebx, ecx          ; ebx += sd : ebx = by + bh + sd
    cmp   edx, ebx
    jge   .inner_if_3_failed

    sub   ebx, ecx          ; ebx = by + bh
    mov   edx, [ebp+20]     ; edx = h
    sub   ebx, edx          ; ebx -= h
    mov   [eax], ebx        ; set it

.inner_if_3_failed:
.outer_if_1_failed:

    pop   ebx
    mov   esp, ebp
    pop   ebp
    ret

; This function does exactly the same as the above on only it docks
; to all edges of the window. It works by calling the above function
; twice. The first time the parameters are in the original order, the
; second time the horizontal and vertical values are swapped.
;
; The C function prototype for this is:
;
; void __cdecl dock(int *x, int *y, int w, int h, int bx, int by, int bw, int bh, int sd);
;
; x  = pointer to the current x position
; y  = pointer to the current y position
; w  = width of the window you wish to dock
; h  = height of the window you wish to dock
; bx = x location of window to dock to
; by = y location of window to dock to
; bw = width of window to dock to
; bh = height of window to dock to
; sd = snap distance in pixels

dock:
    push  ebp
    mov   ebp, esp
    push  ebx
    push  esi
    push  edi

    ; first call

    mov   eax, [ebp+40]
    mov   ebx, [ebp+36]
    mov   ecx, [ebp+32]
    mov   edx, [ebp+28]
    mov   esi, [ebp+24]
    mov   edi, [ebp+20]

    push  eax
    push  ebx
    push  ecx
    push  edx
    push  esi
    push  edi

    mov   eax, [ebp+16]
    mov   ebx, [ebp+12]
    mov   ecx, [ebp+8]

    push  eax
    push  ebx
    push  ecx
    
    call  dock_edge    
    add   esp, 36
    
    ; second call, all x/y and w/h args reversed

    mov   eax, [ebp+40]   ; sd 
    mov   ebx, [ebp+36]   ; bh
    mov   ecx, [ebp+32]   ; bw
    mov   edx, [ebp+28]   ; by
    mov   esi, [ebp+24]   ; bx
    
    push  eax      ; sd
    push  ecx      ; bw
    push  ebx      ; bh
    push  esi      ; bx
    push  edx      ; by
    
    mov   eax, [ebp+20]   ; h
    mov   ebx, [ebp+16]   ; w
    mov   ecx, [ebp+12]   ; y
    mov   edx, [ebp+8]    ; x
    
    push  ebx  ; w
    push  eax  ; h
    push  edx  ; x
    push  ecx  ; y
    
    call  dock_edge    
    add  esp, 36

    pop   edi
    pop   esi
    pop   ebx
    mov   esp, ebp
    pop   ebp
    ret


; This function is a windows and winamp interface to the above
; functions. It takes the handle of the window you want to dock
; to the winamp windows, x & y pointers and a snapping distance.
; It doesn't attempt to move the window itself, this must be done
; afterwards using the x and y values. This is designed so that
; you can use it during a WM_WINDOWPOSCHANGING message. Set the
; x and y pointers to the respective values in the lpWndPos 
; structure and docking will be largely automatic. This function is
; not complete.
;
; The C function prototype for this is:
;
; void __cdecl winamp_dock(HWND hWnd, int* x, int* y, int sd);
;
; hWnd = handle of window to dock
; x    = pointer to new x value
; y    = pointer to new y value
; sd   = snapping distance

winamp_dock:

    push  ebp
    mov   ebp, esp
    push  esi
    push  edi

    %define hWnd  ebp+8
    %define x_ptr ebp+12
    %define y_ptr ebp+16
    %define sd    ebp+20

    sub   esp, 40

    ; local variables
    
    %define w    -4+ebp
    %define h    -8+ebp
    %define sw   -12+ebp
    %define sh   -16+ebp
    %define rect -32+ebp
    %define wnd  -36+ebp
    %define bvis -40+ebp
	
    lea   eax, [rect]
    push  eax
    mov   edx, [hWnd]
    push  edx
    call  GetWindowRect

    ; move width and height into w and h

    mov   eax, [rect+8]  ; rect.right
    mov   edx, [rect]    ; rect.left
    sub   eax, edx
    mov   [w], eax

    mov   eax, [rect+12] ; rect.bottom
    mov   edx, [rect+4]  ; rect.top
    sub   eax, edx
    mov   [h], eax

    ; get winamp window

    push  dword GWL_HWNDPARENT
    mov   eax, [hWnd]
    push  eax
    call  GetWindowLong
    mov   [wnd], eax

    ; find out if its visible
    ; and get its rectangle

    push  eax
    call  IsWindowVisible
    mov   dword [bvis], eax
    lea   eax, [rect]
    push  eax
    mov   edx, [wnd]
    push  edx
    call  GetWindowRect

    mov   eax, [bvis]
    test  eax, eax
    jz    .notvisible

    mov   eax, [ebp+20]  ; sd
    mov   ebx, [rect+12] ; rect.bottom
    mov   ecx, [rect+4]  ; rect.top
    sub   ebx, ecx
    mov   ecx, [rect+8]  ; rect.right
    mov   esi, [rect]    ; rect.left
    sub   ecx, esi
    mov   edx, [rect+4]  ; rect.top
    mov   edi, [h]

    push  eax
    push  ebx
    push  ecx
    push  edx
    push  esi
    push  edi

    mov   eax, [w]
    mov   ebx, [y_ptr]
    mov   ecx, [x_ptr]

    push  eax
    push  ebx
    push  ecx

    call  dock

    add   esp, 36
    
.notvisible:

    add   esp, 40

    pop   edi
    pop   esi
    mov   esp, ebp
    pop   ebp
    ret
