#README#

**DISCLAIMER** I don't own the rights of the example images; they are taken from Google.

-------

A simple example on how to read a BMP header with Assembly (MASM32), without using external resource (I use only BITMAPINFOHEADER struct). In addition, for more clarity, I would show you how obtain the pixel array and apply some filters.

## What can I get from BMPInfo? ##

With BMPInfo you can get info about the header of the BMP and the DIB header. At this moment BMPInfo support only the basicly info and doesn't support the optional values.

In addition you can find some filters that you can apply on the pixel array obtained from the image.

This are the filters that you can test:
  - GrayScale;
  - Pixel inversion;
  - Contrast

The Contrast filter don't work really correctly; must be fixed (and the filters must be optimized).

**IMPORTANT!** please, make sure that your input image is at the same directory of the exe.

##Screenshots##

I must upload screnshot like PNGs because BMP is not supported here.

*The application*

![window.png](https://bitbucket.org/repo/MBodBM/images/1309479650-window.png)

*Original Image, without filter*

![tiger.png](https://bitbucket.org/repo/MBodBM/images/2452464261-tiger.png)

*Grayscale filter*

![output.png](https://bitbucket.org/repo/MBodBM/images/3522120128-output.png)

*Inversion filter*

![output.png](https://bitbucket.org/repo/MBodBM/images/3111072794-output.png)

*Contrast filter*

![output.png](https://bitbucket.org/repo/MBodBM/images/3754382431-output.png)
