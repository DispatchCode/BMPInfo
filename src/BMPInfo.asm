include      c:\masm32\include\masm32rt.inc
include      bmp_header.inc


; #####################################################################################
; Description : A simple example on how to read a BMP header, without using external
;             : resource (I use only BITMAPINFOHEADER struct).
;             : In addition, for more clariry, I would show you how obtain the pixel
;             : array and apply some filters.
;             :
;             : The filters are a part of JIE (Java Image Effect) that I have written
;             : 2 years ago (the JIE project should be public soon)
; ----------------------------------------------------------------------------------
; Author      : Marco C. (DispatchCode)
; ----------------------------------------------------------------------------------
; License     : You can redistibute this code, but please, link this page and/or cite
;             : the author. Thanks.
; -----------------------------------------------------------------------------------
; Version     : 0.9 (Beta)
; -----------------------------------------------------------------------------------
;  !!!!! IMPORTANT NOTE !!!!!
;  
; The Contrast filter don't work really correctly; must be fixed (and the filters
; must be optimized).
;
; This are the filters that you can test:
;   - GrayScale;
;   - Pixel inversion;
;   - Contrast
;
; You can even run the program without select a filter, but only to obtain the information
; from the header. The output image will be named "output.bmp".
; For now there is support only for uncompressed bitmap.
; #####################################################################################






;
; ##################################################################################
.const

FILE_NAME_LENGTH    =                20


;
; ##################################################################################
.data

szDescription         db   9,9,9,"############################################################",13,10,
                           9,9,9,"# How to read a BMP [uncompressed] image, get information, #",13,10,
                           9,9,9,"# and manipulate it.                                       #",13,10,
                           9,9,9,"# ---------------------------------------------------------#",13,10,0
                          
szDescription1        db   9,9,9,"# Author: Marco 'DispatchCode' C.                          #",13,10,
                           9,9,9,"# ---------------------------------------------------------#",13,10,
                           9,9,9,"# You can use and redistribute this code, but please,      #",13,10,0
                          
szDescription2        db   9,9,9,"# link this page and/or cite the author. Thanks, and enjoy #",13,10,
                           9,9,9,"############################################################",13,10,13,10,0


szMenu                db   13,10,"Select on option:",13,10,
                           9,"1. Grayscale filter",13,10,
                           9,"2. Color Inversion",13,10,
                           9,"3. Contrast",13,10,
                           9,"4. Exit",13,10,0

                          
szBitmapHeader        db   9,9,"################################",13,10,
                           9,9,"#          BMP_HEADER          #",13,10,
                           9,9,"################################",13,10,13,10,0

                         
szBitmapInfoHeader    db   9,9,"################################",13,10,
                           9,9,"#       BITMPAINFOHEADER       #",13,10,
                           9,9,"################################",13,10,13,10,0
                          
                          
                           
crlf                  db     13,10,0
szFileNameOut         db     "output.bmp",0

szFileInput           db     "File name (with bmp extension): ",0


;
; ##################################################################################
.data?

dbChoice              db           4            dup(?)
dbFileName            db   FILE_NAME_LENGTH     dup(?)

dwByteRead            dw                            ?

hFile                 dd                            ?
hFileOut              dd                            ?
ddFileSize            dd                            ?
ddHeaderSize          dd                            ?
ddBaseFile            dd                            ?
ddPixelArraySize      dd                            ?
ddPixelsArrayOffset   dd                            ?
ddBR                  dd                            ?
ddBytesPerPixel       dd                            ?




; 
; ##################################################################################

.code
start:

  call     ClearScreenAndColor

  print   offset szDescription
  print   offset szDescription1
  print   offset szDescription2
  
  
  print  offset szFileInput
  invoke        StdIn, offset dbFileName, FILE_NAME_LENGTH
  
  
 
  invoke   CreateFile, addr dbFileName, GENERIC_READ ,FILE_SHARE_READ ,0, OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0 
  
  cmp      eax, INVALID_HANDLE_VALUE
  je       _exit
  
  mov      hFile, eax
  
  print    "File opened...",13,10
  
  invoke   GetFileSize, hFile, 0
  mov      ddFileSize, eax
  
  invoke   GetProcessHeap
  invoke   HeapAlloc, eax, HEAP_NO_SERIALIZE + HEAP_ZERO_MEMORY, ddFileSize
  mov      ddBaseFile, eax
  
  cmp      eax, NULL
  je       _exit
  
  invoke   ReadFile, hFile, ddBaseFile, ddFileSize, addr ddBR,0
  
  print    "File read!",13,10
  
  mov      esi, ddBaseFile
  assume   esi:ptr BMP_HEADER
  
  print  offset szBitmapHeader
  
  ; Print signature
  movzx    ebx, [esi].header_field
  mov      ddHeaderSize, ebx
  print    "File header: 0x"
  print    uhex$(ebx),13,10
  
  ; Print File size
  mov      ebx, [esi].file_size
  print    "File Size (byte): 0x"
  print    uhex$(ebx)
  print    " decimal: "
  print    str$(ebx)
  print    "byte",13,10
  
  ; Offset byte image
  mov      ebx, [esi].byte_offset
  print    "Offset byte matrix (pixel array): 0x"
  print    uhex$(ebx),13,10
  
  ; Pixel's array
  add      esi, [esi].byte_offset
  mov      ddPixelsArrayOffset, esi
  mov      eax, ddFileSize
  sub      eax, ddHeaderSize
  mov      ddPixelArraySize, eax

  print  offset  crlf
  
  comment*===================
   So, ok, here we basically have read the header information.
   Now it's time to read the DIB header with the most significant info.
  ===========================*
  
  print offset szBitmapInfoHeader
    
  mov      esi, ddBaseFile
  add      esi, 0Eh
  assume   esi:ptr BITMAPINFOHEADER
  
  ; Size of the DIB header
  mov      ebx, [esi].biSize
  print    "Byte for this structure: 0x"
  print    uhex$(ebx),13,10
  
  ; Width of the image (pixel)
  mov      ebx, [esi].biWidth
  print    "Width in pixels: "
  print    str$(ebx),13,10
  
  ; Height of the image (pixel)
  mov      ebx, [esi].biHeight
  print    "Height in pixels: "
  print    str$(ebx), 13, 10
  
  ; The number of planes
  movzx    ebx, [esi].biPlanes
  print    "Number of planes (must be set to 1): "
  print    str$(ebx),13,10
  
  ; The number of bit that defines each bits of the image
  movzx    ebx, [esi].biBitCount
  print    "bits-per-pixel: "
  print    str$(ebx),13,10
  shr      ebx, 3   ; bits to byte conversion
  mov      ddBytesPerPixel, ebx
    
  ; The type of compression
  mov      ebx, [esi].biCompression
  print    "Type of compression: "
  
  .IF     ebx == 0
    print    "BI_RGB [uncompressed]",13,10
  .ELSEIF ebx == 1
    print    "BI-RLE8 [The compression format is a 2-byte format consisting of a count byte followed by a byte containing a color index]",13,10
  .ELSEIF ebx == 2
    print    "BI_RLE4 [An RGB format that uses RLE compression for bitmaps with 4 bits per pixel. The compression uses a 2-byte format consisting of a count byte followed by two word-length color indexes.",13,10
  .ELSEIF ebx == 3
    print    "BI_BITFIELDS [Specifies that the bitmap is not compressed and that the color table consists of three DWORD color masks that specify the red, green," 
    print    " and blue components, respectively, of each pixel. This is valid when used with 16- and 32-bpp bitmaps",13,10
  .ELSEIF ebx == 4
    print    "BI_JPEG [JPEG Image]",13,10
  .ELSEIF ebx == 5
    print    "BI_PNG [PNG Image]",13,10
  .ENDIF
  
  ; Size in bytes of the image
  mov      ebx, [esi].biSizeImage
  print    "Size in bytes of the image (0 for BI_RGB): "
  print    str$(ebx),13,10
  
  ; The horizontal resolution in pixel-per-meter
  mov      ebx, [esi].biXPelsPerMeter
  print    "Resolution (horizontal) in pixel-per-meter: "
  print    str$(ebx),13,10
  
  ; The vertical resolution, in pixel-per-meter
  mov      ebx, [esi].biYPelsPerMeter
  print    "Resolution (vertical) in pixel-per-meter: "
  print    str$(ebx),13,10
  
  ; Number of the color indexes used in the color table
  mov      ebx, [esi].biClrUsed
  print    "The number of the color indexes used in the color table (if it is 0, uses the max numbers specified bi biBitCount): "
  print    str$(ebx), 13,10
  
  ; The number of color indexes required for displaying the image
  mov      ebx, [esi].biClrImportant
  print    "The number of color indexes required for displaying the image: "
  print    str$(ebx), 13,10
    
  print   offset  crlf
  
  comment @===================================================
     Now let's go with the most interesting part!
     What that we need to do now, is determine the
     RowSize of the pixel array.
     To accomplish that, we must use this calculus:
     
                (BitsPerPixel * ImageWeight + 31)
      RowSize = ----------------------------------  *  4
                              32
  
     This value is expressed in byte.
     Now what that we need to do is calculate the total amount of 
     memory for store the pixels array.
     
        ddPixelArraySize = RowSize * |ImageHeight|
  
      We need '|' because, how we have seen before, this value can
      be negative.
  
  =============================================================@
  
  xor        ebx, ebx
  movzx      ebx, [esi].biBitCount
  mov        eax, [esi].biWidth
  mul        ebx
  add        eax, 31
  shr        eax, 5
  shl        eax, 2
    
  
  mov        ebx, eax
  
  print      "RowSize: "
  print      str$(ebx)
  print      " byte",13,10
  
  mov        eax, ebx
  mov        ebx, [esi].biHeight
  mul        ebx
  
  mov        ebx, eax
  
  print      "ddPixelArraySize: "
  print      str$(ebx)
  print      " byte",13,10
  
  mov        ddPixelArraySize, ebx

_menu_is_hard:
  print offset szMenu
  invoke     StdIn, offset dbChoice, 4
  
  .IF     [dbChoice] == 31h
     call       GrayScale
  .ELSEIF [dbChoice] == 32h
     call       ColorInversion
  .ELSEIF [dbChoice] == 33h
     call       Contrast
  .ELSEIF [dbChoice] == 34h
     jmp        _exit
  .ELSE
     jmp        _menu_is_hard
  .ENDIF
  
  ; Create a new file for the elaborate image
  invoke     CreateFile, addr szFileNameOut, GENERIC_WRITE, FILE_SHARE_WRITE, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
  
  cmp        eax, INVALID_HANDLE_VALUE
  je         _exit
  
  mov        hFileOut, eax
  
  print      "File created!",13,10
  
  call       GetLastError
  .IF        eax == ERROR_ALREADY_EXISTS
    print      "File overwritten",13,10
  .ENDIF
  
  
  ; Write data 
  invoke     SetFilePointer, hFileOut, 0, NULL, FILE_BEGIN
  invoke     WriteFile, hFileOut, ddBaseFile ,ddFileSize, addr dwByteRead, NULL

  
  print      "Numbers of byte written: "
  movzx      ebx, dwByteRead
  print      str$(ebx),13,10
  
  
  invoke     CloseHandle, hFile
  invoke     CloseHandle, hFileOut
  
_exit:
  print  offset crlf
  
  inkey
  invoke     ExitProcess,0


  
comment *===========================================
             GrayScale filter implementation.
             A little optimization would be needed
         ==========================================*
  
GrayScale     PROC
  push       eax
  push       ebx
  push       edx
  push       edi

  mov        esi, ddPixelsArrayOffset
  xor        ecx, ecx
  
  .WHILE ecx < ebx
    xor        eax, eax
    
    movzx      edx, byte ptr [esi]
    movzx      eax, byte ptr [esi+1]
    add        eax, edx
    movzx      edx, byte ptr [esi+2]
    add        eax, edx
    
    xor        edx, edx
    mov        edi, ddBytesPerPixel
    
    div        edi
    
    mov        edi, eax
    mov        edx, eax
    shl        edi, 16
    shl        edx, 8
    or         eax, edi
    or         eax, edx
    
    mov word ptr [esi], ax
    shr        eax, 16
    mov byte ptr [esi+2], al
    
    add        ecx, ddBytesPerPixel
    add        esi, ddBytesPerPixel
  .ENDW
  
  pop        edi
  pop        edx
  pop        ebx
  pop        eax
  
  ret
GrayScale      ENDP
  
; ################################################################################
  
  

  comment *===============================
  
           Inversion of color pixels
            
          ================================*
  
ColorInversion    PROC

  push        eax
  push        ebx
  push        edx
  push        ebx

  mov         esi, ddPixelsArrayOffset
  xor         ecx, ecx
  
  .WHILE  ecx < ebx
    mov         al, 255
    sub         al, byte ptr [esi]
    mov  byte ptr [esi], al
    
    mov         al, 255
    sub         al, byte ptr [esi+1]
    mov byte ptr [esi+1], al
    
    mov         al, 255
    sub         al, byte ptr [esi+2]
    mov byte ptr [esi+2], al
  
    add        ecx, ddBytesPerPixel
    add        esi, ddBytesPerPixel
  
  .ENDW
  
  pop         ebx
  pop         edx
  pop         ebx
  pop         eax
  
  ret
  
ColorInversion    ENDP
  
  
  comment @============================================================
    Needs some improvements... This filter apply the 
    "Contrast" to the pixels.
    
    Pseudo-code:
          -------------------------------------
               IF channel < 128
                 channel = channel / 1.2
               ELSE
                 IF channel * 1.2 > 255
                   channel = 255
                 ELSE
                   channel = channel * 1.2
               ENDIF
          ---------------------------------------
          
    Because this operations take place on real number, we need the FPU.
    But I used an approximate calculus: 
    
          ---------------------------------------
               value = channel / 6
               
               IF channel < 128
                 channel = channel - value
               ELSE
                 channel = channel + value
               ENDIF
          ----------------------------------------
               
    An example can clarify the difference:
    First formula (I assume the channel above 128):
    
          ----------------------------------------
               channel = 100     ; initial value

               channel = 100 / 1.2 = 83,33333...
          ----------------------------------------
          
    With the second formula:
    
          ----------------------------------------
               channel = 100   ; initial value
               
               value = 100 / 6 = 16

               channel = 100 - 16 = 84
          ----------------------------------------
   
   Another example with channel greater than 128:
     First:
          ----------------------------------------
               channel = 215
               
               channel = 215 * 1.2 = 258 (next step set channel = 255)
          ----------------------------------------
     
     My approximation:
          ----------------------------------------
               channel = 215
               
               value = 215 / 6 = 35
               
               channel = 215 + 35 = 250
          ----------------------------------------
          
   =========================================================================@
  
  
  
Contrast    PROC

  push        eax
  push        ebx
  push        edx
  push        ebx

  mov         esi, ddPixelsArrayOffset
  xor         ecx, ecx
  
  .WHILE  ecx < ebx
    xor         edx, edx
    mov         edi, 6
    mov         al, byte ptr [esi]
    div         edi
    
    .IF byte ptr[esi] < 128
      sub         byte ptr [esi], al
    .ELSE
      push        ebx
      movzx       ebx, byte ptr [esi]
      add         eax, ebx
      pop         ebx
      
      .IF eax >= 255
        mov  byte ptr [esi], 255
      .ELSE
        mov  byte ptr [esi], al
      .ENDIF
      
    .ENDIF
    
    xor         edx, edx
    mov         edi, 6
    mov         al, byte ptr [esi+1]
    div         edi
    
    .IF byte ptr[esi+1] < 128
      sub         byte ptr [esi+1], al
    .ELSE
      push        ebx
      movzx       ebx, byte ptr [esi+1]
      add         eax, ebx
      pop         ebx
      
      .IF eax >= 255
        mov  byte ptr [esi+1], 255
      .ELSE
        mov  byte ptr [esi+1], al
      .ENDIF
    .ENDIF
    
    
    xor         edx, edx
    mov         edi, 6
    mov         al, byte ptr [esi+2]
    div         edi
    
    .IF byte ptr[esi+2] < 128
      sub         byte ptr [esi+2], al
    .ELSE
      push        ebx
      movzx       ebx, byte ptr [esi+2]
      add         eax, ebx
      pop         ebx
      
      .IF eax >= 255
        mov  byte ptr [esi+2], 255
      .ELSE
        mov  byte ptr [esi+2], al
      .ENDIF
    .ENDIF
    
    
    add        ecx, ddBytesPerPixel
    add        esi, ddBytesPerPixel
  
  .ENDW
  
  
  pop         ebx
  pop         edx
  pop         ebx
  pop         eax
  
  ret
  
Contrast    ENDP
  
  
  
  
  
  ; ########################
  ;       (IN)UTILITY      # 
  ; ########################
  
  
  
comment *===========================================

              Clear screen and set a new color
               
         ===========================================*
  
  
  
ClearScreenAndColor      proc

  LOCAL          coordScreen:COORD
  LOCAL          cCharsWritten:DWORD
  LOCAL          csbi:CONSOLE_SCREEN_BUFFER_INFO
  LOCAL          dwConSize:DWORD
  LOCAL          hStdout:HANDLE

  pushad

  
  invoke         GetStdHandle, STD_OUTPUT_HANDLE
  mov            hStdout, eax

  invoke         GetConsoleScreenBufferInfo, hStdout, addr csbi
  
  .IF eax == 0
    print       "Error 1"
    jmp          _exit_clear
  .ENDIF
  
  movzx          ebx, word ptr csbi.dwSize.y
  movzx          eax, word ptr csbi.dwSize.x
  mul            ebx
  
  mov            dwConSize, eax
  
  invoke         FillConsoleOutputCharacter, hStdout, ' ', dwConSize, 0, addr cCharsWritten
  
  .IF eax == 0
    print       "Error 2"
    jmp          _exit_clear
  .ENDIF
  
  
  invoke         GetConsoleScreenBufferInfo, hStdout, addr csbi
  
  .IF eax == 0
    print       "Error 3"
    jmp          _exit_clear
  .ENDIF

    invoke         FillConsoleOutputAttribute, hStdout, (BACKGROUND_BLUE or BACKGROUND_INTENSITY or FOREGROUND_INTENSITY), 65535, 0, addr cCharsWritten
    invoke         SetConsoleTextAttribute, hStdout, (BACKGROUND_BLUE or BACKGROUND_INTENSITY or FOREGROUND_RED or FOREGROUND_BLUE or FOREGROUND_GREEN or FOREGROUND_INTENSITY)
  
  .IF eax == 0
    print       "Error 4"
    invoke       GetLastError
    jmp          _exit_clear
  .ENDIF
  
  invoke         SetConsoleCursorPosition, hStdout, 0
  
_exit_clear:
  popad
  
  ret
ClearScreenAndColor      endp
  
  

END       start