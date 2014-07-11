; vis_spec20.inc - import functions and constants for
; use in vis_spec20.asm.

extern __imp__GetModuleHandleA@4    ; kernel32.lib
extern __imp__LocalAlloc@8          ; kernel32.lib
extern __imp__LocalFree@4           ; kernel32.lib
extern __imp__ExitProcess@4         ; kernel32.lib
extern __imp__MessageBoxA@16        ; user32.lib
extern __imp__MessageBeep@4         ; user32.lib
extern __imp__TranslateMessage@4    ; user32.lib
extern __imp__DispatchMessageA@4    ; user32.lib
extern __imp__CreateWindowExA@48    ; user32.lib
extern __imp__DestroyWindow@4       ; user32.lib
extern __imp__PostQuitMessage@4     ; user32.lib
extern __imp__RegisterClassExA@4    ; user32.lib
extern __imp__DefWindowProcA@16     ; user32.lib
extern __imp__LoadIconA@8           ; user32.lib
extern __imp__LoadCursorA@8         ; user32.lib
extern __imp__LoadBitmapA@8         ; user32.lib
extern __imp__ShowWindow@8          ; user32.lib
extern __imp__UpdateWindow@4        ; user32.lib
extern __imp__GetMessageA@16        ; user32.lib
extern __imp__PostMessageA@16       ; user32.lib
extern __imp__UnregisterClassA@8    ; user32.lib
extern __imp__BeginPaint@8          ; user32.lib
extern __imp__EndPaint@8            ; user32.lib
extern __imp__GetDC@4               ; user32.lib
extern __imp__ReleaseDC@8           ; user32.lib
extern __imp__InvalidateRect@12     ; user32.lib
extern __imp__PtInRect@12           ; user32.lib
extern __imp__GetCursorPos@4        ; user32.lib
extern __imp__ScreenToClient@8      ; user32.lib
extern __imp__SetCapture@4          ; user32.lib
extern __imp__ReleaseCapture@0      ; user32.lib
extern __imp__Rectangle@20          ; gdi32.lib
extern __imp__CreateCompatibleDC@4  ; gdi32.lib
extern __imp__DeleteDC@4            ; gdi32.lib
extern __imp__DeleteObject@4        ; gdi32.lib
extern __imp__SelectObject@8        ; gdi32.lib
extern __imp__BitBlt@36             ; gdi32.lib
extern __imp__GetPixel@12           ; gdi32.lib
extern __imp__SetPixel@16           ; gdi32.lib
extern __imp__StretchDIBits@52      ; gdi32.lib

%define GetModuleHandle    [__imp__GetModuleHandleA@]
%define LocalAlloc         [__imp__LocalAlloc@8]
%define LocalFree          [__imp__LocalFree@4]
%define WriteFile          [__imp__WriteFile@20]
%define GetStdHandle       [__imp__GetStdHandle@4]
%define MessageBox         [__imp__MessageBoxA@16]
%define MessageBeep        [__imp__MessageBeep@4]
%define TranslateMessage   [__imp__TranslateMessage@4]
%define DispatchMessage    [__imp__DispatchMessageA@4]
%define CreateWindowEx     [__imp__CreateWindowExA@48]
%define DestroyWindow      [__imp__DestroyWindow@4]
%define PostQuitMessage    [__imp__PostQuitMessage@4]
%define RegisterClassEx    [__imp__RegisterClassExA@4]
%define DefWindowProc      [__imp__DefWindowProcA@16]
%define LoadIcon           [__imp__LoadIconA@8]
%define LoadCursor         [__imp__LoadCursorA@8]
%define LoadBitmap         [__imp__LoadBitmapA@8]
%define ShowWindow         [__imp__ShowWindow@8]
%define UpdateWindow       [__imp__UpdateWindow@4]
%define GetMessage         [__imp__GetMessageA@16]
%define PostMessage        [__imp__PostMessageA@16]
%define UnregisterClass    [__imp__UnregisterClassA@8]
%define GetCursorPos       [__imp__GetCursorPos@4]
%define ScreenToClient     [__imp__ScreenToClient@8]
%define BeginPaint         [__imp__BeginPaint@8]
%define EndPaint           [__imp__EndPaint@8]
%define Rectangle          [__imp__Rectangle@20]
%define CreateCompatibleDC [__imp__CreateCompatibleDC@4]
%define DeleteDC           [__imp__DeleteDC@4]
%define DeleteObject       [__imp__DeleteObject@4]
%define GetDC              [__imp__GetDC@4]
%define ReleaseDC          [__imp__ReleaseDC@8]
%define PtInRect           [__imp__PtInRect@12]
%define InvalidateRect     [__imp__InvalidateRect@12]
%define SelectObject       [__imp__SelectObject@8]
%define BitBlt             [__imp__BitBlt@36]
%define SetCapture         [__imp__SetCapture@4]
%define ReleaseCapture     [__imp__ReleaseCapture@0]
%define GetPixel           [__imp__GetPixel@12]
%define SetPixel           [__imp__SetPixel@16]
%define StretchDIBits      [__imp__StretchDIBits@52]
%define ExitProcess        [__imp__ExitProcess@4]

%define CS_DBLCLKS           0x00000008
%define WM_CREATE            0x00000001
%define WM_DESTROY           0x00000002
%define IDI_APPLICATION      0x00007F00
%define IDC_ARROW            0x00007F00
%define COLOR_WINDOW         0x00000005
%define WS_OVERLAPPEDWINDOW  0x00cf0000
%define SW_SHOW              0x00000005
%define MB_ICONERROR         0x00000010
%define WS_CHILD             0x40000000
%define BS_PUSHBUTTON        0x00000000
%define WS_VISIBLE           0x10000000
%define MB_ICONINFORMATION   0x00000040

%define WS_NOCAPTION         0x80000000
%define WS_EX_TOOLWINDOW     0x00000080

%define HT_CAPTION           0x00000002
%define SRCCOPY              0x00CC0020
%define WA_INACTIVE          0x00000000

%define LPTR                 0x00000040
%define WM_LBUTTONDOWN       0x00000201
%define WM_NCLBUTTONDOWN     0x000000A1
%define WM_PAINT             0x0000000F
%define WM_ACTIVATE          0x00000006
%define WM_LBUTTONUP         0x00000202
%define WM_MOUSEMOVE         0x00000200
%define WM_WINDOWPOSCHANGING 0x00000046

%define DIB_RGB_COLORS       0x00000000
%define BI_RGB               0x00000000

%define IDB_SKIN             101
%define DEFAULT_WIDTH        275
%define DEFAULT_HEIGHT       116
%define TITLE_HEIGHT          14
%define CLOSE_WIDTH            9
%define CLOSE_HEIGHT           9
%define CLOSE_LEFT           264
%define CLOSE_TOP              3
%define SKIN_COLOURS_LEFT     18
%define SKIN_COLOURS_TOP     130
%define SKIN_CLOSE_LEFT        0
%define SKIN_CLOSE_TOP       130
%define BLITTER_WIDTH        262
%define BLITTER_HEIGHT        95
%define BLITTER_LEFT           7
%define BLITTER_TOP           15

%define BUFFER_SIZE          (BLITTER_WIDTH*BLITTER_HEIGHT*4)
%define SCANLINE_WIDTH       (BLITTER_WIDTH*4)
%define BACK_COLOUR          (95*4)
%define GRID_COLOUR          (96*4)
%define PEAK_COLOUR          (97*4)

%define SIZE_OF_BITMAPINFOHEADER 40

