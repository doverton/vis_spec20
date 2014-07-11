; Imports for docking code

extern __imp__GetWindowLongA@8          ; user32.lib
extern __imp__GetWindowRect@8           ; user32.lib
extern __imp__IsWindowVisible@4         ; user32.lib
extern __imp__SystemParametersInfoA@16  ; user32.lib

%define GetWindowLong        [__imp__GetWindowLongA@8]
%define GetWindowRect        [__imp__GetWindowRect@8]
%define IsWindowVisible      [__imp__IsWindowVisible@4]
%define SystemParametersInfo [__imp__SystemParametersInfoA@16]

%define GWL_HWNDPARENT (-8)
%define SPI_GETWORKAREA 48
