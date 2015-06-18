/* TSButton Class, buttons paint routines
   Author: Manuel Mercado
   Last update: October 1st, 2002 */

#include "\CURSOSQL\INCLUDE\WinTen.h"   /* set your own path if needed */
#include "\BCC55\INCLUDE\Windows.h"
#include "\CURSOSQL\INCLUDE\ClipApi.h"  /* set your own path if needed */
#include "\BCC55\INCLUDE\StdLib.h"

void DrawBitmap( HDC hdc, HBITMAP hbm, WORD wCol, WORD wRow, WORD wWidth,
                 WORD wHeight, DWORD dwRaster ) ;
void DrawMasked( HDC hdc, HBITMAP hbm, WORD y, WORD x ) ;
void GoPoint( HDC, int, int ) ;
COLORREF MakeDarker( COLORREF, int ) ;
void VertSeparator( HDC, HWND, int, COLORREF, BOOL ) ;
void HorzSeparator( HDC, HWND, int, COLORREF, BOOL ) ;
void SBtnBox( HDC, RECT *, COLORREF, BOOL, int ) ;
void ColorDegrad( HDC hDC, RECT * rori, COLORREF cFrom, COLORREF cTo, int nDegType, int iRound ) ;
void SBtnRoundBox( HDC, RECT *, COLORREF, BOOL, BOOL ) ;
void cDrawBoxes( HDC, RECT *, int, LPSTR, HFONT, int, COLORREF, COLORREF, COLORREF, BOOL ) ;

//---------------------------------------------------------------------------//

#ifndef __HARBOUR__
	CLIPPER SBtnPaint( PARAMS ) // ( hWnd, hBitmaP, hPalette, lPressed,
   	                         //   hFont, cText, nPos, nClrText, nClrBack,
                               //   lMouseOver, lOpaque, hBrush, nRows, lW97,
                               //   lAdjust, lMenu, lMenuPress, lFocused,
                               //   lV22, lBorder, lBox, nClip, nClrTo, lHorz, lRound )
#else
   HARBOUR HB_FUN_SBTNPAINT( PARAMS )
#endif
{
   HWND  hWnd         = ( HWND ) _parnl( 1 ) ;
   HBITMAP hBitMap1   = ( HBITMAP ) _parnl( 2 ) ;
   HPALETTE hPalette1 = (HPALETTE) _parnl( 3 ) ;
   BOOL  bPressed     = _parl( 4 ) ;
   HFONT hFont        = ( HFONT ) _parnl( 5 ) ;
   LPSTR cText        = _parc( 6 ) ;
   int   nPos         = _parni( 7 ) ;
   COLORREF nClrText  =  _parnl( 8 ) ;
   COLORREF nClrBack  =  _parnl( 9 ) ;
   BOOL bMOver        = _parl( 10 ) ;
   BOOL bOpaque       = _parl( 11 ) ;
   HBRUSH wBrush      = ( HBRUSH ) _parni( 12 ) ;
   int  nRows         = _parni( 13 ) ;
   BOOL bW97          = _parl( 14 ) ;
   BOOL bAdjust       = _parl( 15 ) ;
   BOOL bMenu         = _parl( 16 ) ;
   BOOL bMPress       = _parl( 17 ) ;
   BOOL bFocused      = _parl( 18 ) ;
   BOOL bV22          = _parl( 19 ) ;
   BOOL bBorder       = _parl( 20 ) ;
   BOOL bBox          = _parl( 21 ) ;
   int  iClip         = _parni( 22 ) ;
   COLORREF nClrTo    = _parnl( 23 ) ;
   int nDegType       = _parni( 24 ) ;
   int iRound         = _parni( 25 ) ;
   HBITMAP hShape     = ( HBITMAP ) _parnl( 26 ) ;
   BOOL bRepaint      = _parl( 27 ) ;
   BOOL b3DInv        = ( ISLOGICAL( 28 ) ? ! _parl( 28 ) : FALSE ) ;
   BOOL b3D           = ( ISLOGICAL( 28 ) ? TRUE : FALSE ) ;
   COLORREF nClr3DL   = ( ISNUM( 29 ) ? _parnl( 29 ) : GetSysColor( COLOR_BTNHIGHLIGHT ) ) ;
   COLORREF nClr3DS   = ( ISNUM( 30 ) ? _parnl( 30 ) : GetSysColor( COLOR_BTNSHADOW ) ) ;
   int iTTop          = _parni( 31 ) ;
   int iTLeft         = _parni( 32 ) ;
   BOOL bTPos         = ISNUM( 31 ) ;
   BOOL bRound        = ( ISNUM( 25 ) && iRound > 0 ) ;

   RECT rct, rctt, rctm, rctb ;
   HBRUSH hBrush, hBOld ;
   BITMAP bm ;
   TEXTMETRIC tm ;
   HFONT hOldFont ;
   int nTop, nLeft, nBkOld, iROP, iType ;
   WORD nWidth, nHeight, ibmWidth ;
   COLORREF lBkColor ;
   HDC hDC = GetDC( hWnd ) ;
   HRGN hRgn, hRgn1, hOldRgn, hOldRg1 ;

   BOOL bBrush   = wBrush > 0 ;
   BOOL bDegrad  = nDegType > 0 ;

   bOpaque = ( bAdjust ? TRUE : bOpaque ) ;
   hOldFont = SelectObject( hDC, hFont ) ;
   GetClientRect( hWnd, &rctt ) ;
   GetClientRect( hWnd, &rctb ) ;
   GetClientRect( hWnd, &rct ) ;
   GetTextMetrics( hDC, &tm ) ;
 	SetTextColor( hDC, nClrText ) ;
   SetBkColor( hDC, nClrBack ) ;

   lBkColor   = GetBkColor( hDC ) ;
   hBrush     = CreateSolidBrush( lBkColor ) ;
   hBOld      = SelectObject( hDC, hBrush ) ;

   if( nPos > 0 && hBitMap1 > 0 )
	   GetObject( ( HGDIOBJ ) ( bV22 ? hBitMap1 : LOWORD( hBitMap1 ) ), sizeof( BITMAP ),( LPSTR ) &bm ) ;

   if( ! hShape )
   {
	   switch( iRound )
   	{
   		case 1 :  // round region
         	hRgn = CreateEllipticRgn( rct.left, rct.top, rct.right - rct.left + 1, rct.bottom - rct.top + 1 ) ;
	         break ;

   	   case 2 :  // round rect region
      	   hRgn = CreateRoundRectRgn( rct.left, rct.top,
         	                              rct.right - rct.left + 1,
            	                           rct.bottom - rct.top + 1, 16, 16 ) ;
	      	break ;

			case 0 :  // rectangular region
      	   hRgn = CreateRectRgn( rct.left, rct.top, rct.right - rct.left + 1, rct.bottom - rct.top + 1 ) ;
         	break ;
	   }
   }

   hOldRgn = SelectObject( hDC, hRgn ) ;

   if( ! hShape && ! bDegrad && ! bBrush )
   {
   	FillRect( hDC, &rct, hBrush ) ;
   }

   if( bDegrad && bRepaint )
   {
      if( bBox )
      {
      	rct.top += ( bBorder ? 2 : 1 ) ;
      	rct.left += ( bBorder ? 2 : 1 ) ;
      	rct.bottom -= ( bBorder ? 2 : 1 ) ;
      	rct.right -= ( bBorder ? 2 : 1 ) ;
      }

   	ColorDegrad( hDC, &rct, nClrBack, nClrTo, nDegType, iRound ) ;

      if( bBox )
      {
      	rct.top -= ( bBorder ? 2 : 1 ) ;
      	rct.left -= ( bBorder ? 2 : 1 ) ;
      	rct.bottom += ( bBorder ? 2 : 1 ) ;
      	rct.right += ( bBorder ? 2 : 1 ) ;
      }

   }

   if( hShape )
   {
     	DrawMasked( hDC, ( bV22 ? hShape : LOWORD( hShape ) ),
                  rct.top + ( bPressed ? 1 : 0 ), rct.left  + ( bPressed ? 1 : 0 ) ) ;
   }

   if( bBrush )
   {
      if( ! bRound )
      	FillRect( hDC, &rctb, wBrush ) ;
      else if( iRound == 2 )
      	FillRect( hDC, &rct, wBrush ) ;
   }

   if( bMenu )
   {
   	rctm.top    = rctb.top + 1 ;
      rctm.left   = rctb.right - 13 ;
      rctm.bottom = rctb.bottom - 1 ;
      rctm.right  = rctb.right ;


      if( ( ! bW97 && bRepaint ) || ( bW97 && bRepaint && ( bMOver || bMPress ) ) )
	      cDrawBoxes( hDC, &rctm, 8, "", 0, 0,
                     MakeDarker( bDegrad ? nClrBack : lBkColor, bMPress ? 64 : -64 ),
   	               MakeDarker( bDegrad ? nClrBack : lBkColor, bMPress ? -64 : 64 ),
                                 0, FALSE ) ;

      rctm.right  += ( bMPress ? 1 : 0 ) ;
      rctm.top    -= ( bMPress ? 1 : 0 ) ;
      rctm.bottom += ( bMPress ? 1 : 0 ) ;

      if( bRepaint )
      {
	      if( ! bDegrad || ( bDegrad && ( nDegType == 2 || nDegType == 4 || nDegType == 5 ) ) )
		      iROP = SetROP2( hDC, R2_NOT ) ;

      	GoPoint( hDC, rctm.right - 5, ( ( rctm.bottom - rctm.top + 1 ) / 2 ) - 1 ) ;
	      LineTo( hDC, rctm.right - 10, ( ( rctm.bottom - rctm.top + 1 ) / 2 ) - 1 ) ;
   	   GoPoint( hDC, rctm.right - 6, ( ( rctm.bottom - rctm.top + 1 ) / 2 ) ) ;
      	LineTo( hDC, rctm.right - 9, ( ( rctm.bottom - rctm.top + 1 ) / 2 ) ) ;
	      GoPoint( hDC, rctm.right - 7, ( ( rctm.bottom - rctm.top + 1 ) / 2 ) + 1 ) ;
   	   LineTo( hDC, rctm.right - 8, ( ( rctm.bottom - rctm.top + 1 ) / 2 ) + 1 ) ;

      	if( ! bDegrad || ( bDegrad && ( nDegType == 2 || nDegType == 4 || nDegType == 5 ) ) )
	      	SetROP2( hDC, iROP ) ;

      }

   }

   if( bBox && bRepaint )
   {
   	if( bBorder )
      {
         if( iRound != 1 )
         {
	         cDrawBoxes( hDC, &rct, iRound == 2 ? 10 : 9, "", 0, 0, 0, 0, 0, FALSE ) ;
         }
         else
	         SBtnRoundBox( hDC, &rct, 0, bPressed, TRUE ) ;

         rct.top++ ;
         rct.left++ ;
         rct.bottom-- ;
         rct.right-- ;
      }

      if( bPressed )
      	iType = ( iRound == 2 ? 6 : 3 ) ;
      else
      	iType = ( iRound == 2 ? 4 : 1 ) ;

      if( iRound != 1 )
      {
	      if( ! bW97 || ( bW97 && ( bMOver || bPressed ) ) )
         {
		      cDrawBoxes( hDC, &rct, iType, "", 0, 0,
      	               MakeDarker( bDegrad ? nClrBack : lBkColor, -64 ),
   	   	            MakeDarker( bDegrad ? nClrBack : lBkColor, 64 ), 0, FALSE ) ;
         }
      }
      else
         SBtnRoundBox( hDC, &rct, bDegrad ? nClrTo : nClrBack, bPressed, FALSE ) ;
   }

   if( bMenu )
   {
      rct.right  -= 12 ;
      rctt.right -= 12 ;
   }

	nHeight = ( nRows > 0 ? nRows * ( b3D ? ( tm.tmHeight + 2 ) : tm.tmHeight ) : tm.tmHeight + b3D ? 2 : 0 ) ;

   ibmWidth = ( iClip > 0 ? ( bm.bmWidth / 4 ) : bm.bmWidth ) ;

   switch( nPos )
   {
      case 1 :  // text on top
         nTop  = rct.top + nHeight + 5 ;
         nLeft = rct.left + ( ( rct.right - rct.left + 1 ) / 2 ) - ( ibmWidth / 2 ) - 1 ;
         break ;

      case 2 :  // text on left
         nTop  = ( ( rct.bottom - rct.top ) / 2 ) - ( bm.bmHeight / 2 ) ;
         nLeft = rct.right - ( 5 + ibmWidth ) ;
         break ;

      case 3 :  // text on bottom
         nTop  = rct.top + 5 ;
         nLeft = rct.left + ( ( rct.right - rct.left + 1 ) / 2 ) - ( ibmWidth / 2 ) - 1 ;
         break ;

      case 4 :   // text on right
         nTop  = ( ( rct.bottom - rct.top ) / 2 ) - ( bm.bmHeight / 2 ) ;
         nLeft = rct.left + 5 ;
         break ;

      case 5 :   // text on center
         if( ! hShape )
         {
         	nTop  = bAdjust ? rct.top : ( ( ( rct.bottom - rct.top ) / 2 ) - ( bm.bmHeight / 2 ) ) ;
         	nLeft = bAdjust ? rct.left : ( rct.left + ( ( rct.right - rct.left + 1 ) / 2 ) - ( ibmWidth / 2 ) - 1 ) ;
         }
         break ;
   }

   nWidth  = rct.right - rct.left + 1 ;
   nHeight = rct.bottom - rct.top + 1 ;

   if( nPos > 0 )
   {
	   nTop  += ( bPressed ? 1 : 0 ) ;
   	nLeft += ( bPressed ? 1 : 0 ) ;

      if( ( bV22 ? hBitMap1 : LOWORD( hBitMap1 ) ) )
   	{
         if( iClip > 0 )
         {
            hRgn1    = CreateRectRgn( nLeft, nTop, nLeft + ibmWidth, nTop + bm.bmHeight ) ;
            hOldRg1 = SelectObject( hDC, hRgn1 ) ;
         }
         if( bOpaque )
         {
            if( iClip > 0 )
            	DrawBitmap( hDC, ( bV22 ? hBitMap1 : LOWORD( hBitMap1 ) ), nTop,
                           nLeft - ( ibmWidth * ( iClip - 1 ) ), 0, 0, 0 ) ;
            else
            	DrawBitmap( hDC, ( bV22 ? hBitMap1 : LOWORD( hBitMap1 ) ), nTop, nLeft,
                           ( bAdjust ?  nWidth - 2 : 0 ), ( bAdjust ?  nHeight - 2 : 0 ), 0 ) ;
         }
         else
         {
            if( iClip > 0 )
            	DrawMasked( hDC, ( bV22 ? hBitMap1 : LOWORD( hBitMap1 ) ), nTop,
                           nLeft - ( ibmWidth * ( iClip - 1 ) ) ) ;
            else
            	DrawMasked( hDC, ( bV22 ? hBitMap1 : LOWORD( hBitMap1 ) ), nTop, nLeft ) ;
         }
         if( iClip > 0 )
         {
           DeleteObject( hRgn1 ) ;
           GetClientRect( hWnd, &rctm ) ;
           hRgn1 = CreateRectRgn( rctm.left, rctm.top, rctm.right, rctm.bottom ) ;
           SelectObject( hDC, hRgn1 ) ;
           SelectObject( hDC, hOldRg1 ) ;
           DeleteObject( hRgn1 ) ;
           DeleteObject( hOldRg1 ) ;
         }

      }

   }

   nHeight = ( nRows > 0 ? nRows * tm.tmHeight : tm.tmHeight ) ;

   if( ! bTPos )
   {
	   switch( nPos )
      {
      	case 0 :  // text only
         	rctt.top = ( ( rctt.bottom - rctt.top ) / 2 ) - ( nHeight / 2 ) - 2 ;
	         rctt.bottom = rctt.top + nHeight ;
   	   case 1 :  // text on top
      	   rctt.top += 1 ;
         	rctt.left += 5 ;
	         rctt.bottom = rctt.top + nHeight ;
   	      rctt.right -= 5 ;
      	   break ;

	      case 2 :  // text on left
   	      rctt.top = ( ( rctt.bottom - rctt.top ) / 2 ) - ( nHeight / 2 ) ;
      	   rctt.left += 5 ;
         	rctt.bottom = rctt.top + nHeight ;
	         rctt.right -= ( 5 + ibmWidth ) ;
   	      break ;

	      case 3 :  // text on bottom
   	      rctt.top += ( 5 + bm.bmHeight ) ;
      	   rctt.left += 5 ;
         	rctt.bottom = rctt.top + nHeight ;
	         rctt.right -= 5 ;
   	      break ;

      	case 4 :   // text on right
         	rctt.top = ( ( rctt.bottom - rctt.top ) / 2 ) - ( nHeight / 2 ) ;
	         rctt.left += ( 5 + ibmWidth ) ;
   	      rctt.bottom = rctt.top + nHeight ;
      	   rctt.right -= 5 ;
         	break ;

	      case 5 :  // text on center
   	      rctt.top = ( ( rctt.bottom - rctt.top ) / 2 ) - ( nHeight / 2 ) ;
      	   rctt.left += 5 ;
         	rctt.bottom = rctt.top + nHeight ;
	         rctt.right -= 5 ;
   	      break ;

   	}
   }
   else
   {
   	rctt.top    = iTTop ;
      rctt.left   = iTLeft ;
      rctt.bottom = iTTop + nHeight ;
   }

   if( bPressed )
   {
   	rctt.top++ ;
      rctt.left++ ;
   }

   nBkOld = SetBkMode( hDC, TRANSPARENT ) ;

   if( b3D )
   {
   	rctt.top    -= 1 ;
      rctt.left   -= 1 ;
      rctt.bottom -= 1 ;
      rctt.right  -= 1 ;

      SetTextColor( hDC, b3DInv ? nClr3DS : nClr3DL ) ;

      DrawText( hDC, cText, -1, &rctt,
                ( bTPos ? DT_LEFT : DT_CENTER ) | DT_TOP |
                ( nRows <= 1 ? DT_SINGLELINE : 0 ) ) ;

      rctt.top    += 2 ;
      rctt.left   += 2 ;
      rctt.bottom += 2 ;
      rctt.right  += 2 ;

      SetTextColor( hDC, b3DInv ? nClr3DL : nClr3DS ) ;

      DrawText( hDC, cText, -1, &rctt,
                ( bTPos ? DT_LEFT : DT_CENTER ) | DT_TOP |
                ( nRows <= 1 ? DT_SINGLELINE : 0 ) ) ;


      rctt.top    -= 1 ;
      rctt.left   -= 1 ;
      rctt.bottom -= 1 ;
      rctt.right  -= 1 ;

 		SetTextColor( hDC, nClrText ) ;

      DrawText( hDC, cText, -1, &rctt,
                ( bTPos ? DT_LEFT : DT_CENTER ) | DT_TOP |
                ( nRows <= 1 ? DT_SINGLELINE : 0 ) ) ;
   }
   else
   {
 		SetTextColor( hDC, nClrText ) ;

   	DrawText( hDC, cText, -1, &rctt,
                ( bTPos ? DT_LEFT : DT_CENTER ) | DT_TOP |
                ( nRows <= 1 ? DT_SINGLELINE : 0 ) ) ;
   }


   if( bFocused && bBox && !bRound )
   {
	   GetClientRect( hWnd, &rct ) ;
   	rct.top    += 3 ;
   	rct.left   += 3 ;
   	rct.bottom -= 3 ;
   	rct.right  -= 3 ;
      DrawFocusRect( hDC, &rct ) ;
   }

   DeleteObject( hRgn ) ;
   GetClientRect( hWnd, &rct ) ;
   hRgn = CreateRectRgn( rct.left, rct.top, rct.right, rct.bottom ) ;
   SelectObject( hDC, hRgn ) ;
   SelectObject( hDC, hOldRgn ) ;
   DeleteObject( hRgn ) ;
   DeleteObject( hOldRgn ) ;

   SetBkMode( hDC, nBkOld ) ;
   SelectObject( hDC, hOldFont ) ;
   SelectObject( hDC, hBOld ) ;
   DeleteObject( hBrush ) ;
   ReleaseDC( hWnd, hDC ) ;
}

//----------------------------------------------------------------------------//

void GoPoint( HDC hDC, int ix, int iy )
{
   POINT pt;

   #ifdef __FLAT__
      MoveToEx( hDC, ix, iy, &pt ) ;
   #else
      MoveTo( hDC, ix, iy );
   #endif
}

//----------------------------------------------------------------------------//

COLORREF MakeDarker( COLORREF nColor, int iFact )
{
   int iRed   = GetRValue( nColor ) ;
   int iGreen = GetGValue( nColor ) ;
   int iBlue  = GetBValue( nColor ) ;

   if( iRed > 0 )
   	iRed -= iFact ;

   if( iGreen > 0 )
   	iGreen -= iFact ;

   if( iBlue > 0 )
   	iBlue -= iFact ;

   iRed   = ( iRed < 0 ? 0 : iRed > 255 ? 255 : iRed ) ;
   iGreen = ( iGreen < 0 ? 0 : iGreen > 255 ? 255 : iGreen ) ;
   iBlue  = ( iBlue < 0 ? 0 : iBlue > 255 ? 255 : iBlue ) ;

   return RGB( iRed, iGreen, iBlue ) ;
}

//----------------------------------------------------------------------------//

void VertSeparator( HDC hDC, HWND hWnd, int ix, COLORREF nColor, BOOL b3D )
{
	RECT rct ;
   int iTop, iBot, inx = ix ;
   COLORREF nClr1, nClr2 ;
   HPEN hOldPen, hPen1, hPen2, hPen3 ;

   nClr2  = MakeDarker( nColor, -32 ) ;
   nClr1  = MakeDarker( nColor, 32 ) ;
   hPen1  = CreatePen( PS_SOLID, 1, nClr1 ) ;
   hPen2  = CreatePen( PS_SOLID, 1, nColor ) ;
   hPen3  = CreatePen( PS_SOLID, 1, nClr2 ) ;

   GetClientRect( hWnd, &rct ) ;

   iTop = rct.top + ( b3D ? 2 : 0 ) ;
   iBot = rct.bottom - ( b3D ? 1 : 0 ) ;

   hOldPen = SelectObject( hDC, hPen2 ) ;
   GoPoint( hDC, inx, iTop ) ;
   LineTo( hDC, inx++, iBot ) ;

   SelectObject( hDC, hPen3 ) ;
   GoPoint( hDC, inx, iTop ) ;
   LineTo( hDC, inx++, iBot ) ;

   SelectObject( hDC, hPen3) ;
   GoPoint( hDC, inx, iTop ) ;
   LineTo( hDC, inx++, iBot ) ;

   SelectObject( hDC, hPen2) ;
   GoPoint( hDC, inx, iTop ) ;
   LineTo( hDC, inx++, iBot ) ;

   SelectObject( hDC, hPen1 ) ;
   GoPoint( hDC, inx, iTop ) ;
   LineTo( hDC, inx++, iBot ) ;


   SelectObject( hDC, hOldPen ) ;
   DeleteObject( hPen1 ) ;
   DeleteObject( hPen2 ) ;
   DeleteObject( hPen3 ) ;
}

//----------------------------------------------------------------------------//

void HorzSeparator( HDC hDC, HWND hWnd, int iy, COLORREF nColor, BOOL b3D )
{
	RECT rct ;
   int iTop, iBot, iny = iy ;
   COLORREF nClr1, nClr2 ;
   HPEN hOldPen, hPen1, hPen2, hPen3 ;

   nClr2  = MakeDarker( nColor, -64 ) ;
   nClr1  = MakeDarker( nColor, 96 ) ;
   hPen1  = CreatePen( PS_SOLID, 1, nClr1 ) ;
   hPen2  = CreatePen( PS_SOLID, 1, nColor ) ;
   hPen3  = CreatePen( PS_SOLID, 1, nClr2 ) ;

   GetClientRect( hWnd, &rct ) ;

   iTop = rct.left + ( b3D ? 0 : 0 ) ;
   iBot = rct.right - ( b3D ? 0 : 0 ) ;

   hOldPen = SelectObject( hDC, hPen1 ) ;
   GoPoint( hDC, iTop, iny ) ;
   LineTo( hDC, iBot, iny++ ) ;

   SelectObject( hDC, hPen2 ) ;
   GoPoint( hDC, iTop, iny ) ;
   LineTo( hDC, iBot, iny++ ) ;

   SelectObject( hDC, hPen3 ) ;
   GoPoint( hDC, iTop, iny ) ;
   LineTo( hDC, iBot, iny++ ) ;

   GoPoint( hDC, iTop, iny ) ;
   LineTo( hDC, iBot, iny++ ) ;

   SelectObject( hDC, hPen2) ;
   GoPoint( hDC, iTop, iny ) ;
   LineTo( hDC, iBot, iny++ ) ;

   SelectObject( hDC, hPen1) ;
   GoPoint( hDC, iTop, iny ) ;
   LineTo( hDC, iBot, iny++ ) ;

   SelectObject( hDC, hOldPen ) ;
   DeleteObject( hPen1 ) ;
   DeleteObject( hPen2 ) ;
   DeleteObject( hPen3 ) ;
}

//----------------------------------------------------------------------------//

#ifndef __HARBOUR__
   CLIPPER MakeSepara( PARAMS ) //tor( hWnd, nxy, nColor, l3D, lVert )
#else
   HARBOUR HB_FUN_MAKESEPARATOR( PARAMS )
#endif
{
   HWND hWnd  = ( HWND ) _parni( 1 ) ;
   BOOL bVert = _parl( 5 ) ;

   HDC hDC = GetDC( hWnd ) ;

   if( bVert )
		VertSeparator( hDC, (HWND) _parni( 1 ), (int) _parni( 2 ), (COLORREF) _parnl( 3 ),
   	               (BOOL) _parl( 4 ) ) ;
   else
		HorzSeparator( hDC, (HWND) _parni( 1 ), (int) _parni( 2 ), (COLORREF) _parnl( 3 ),
   	               (BOOL) _parl( 4 ) ) ;

	ReleaseDC( hWnd, hDC ) ;
}

//----------------------------------------------------------------------------//

#ifndef __HARBOUR__
   CLIPPER SBtnLine( PARAMS ) // ( hWnd, nTop, nLeft, nBottom, nRight, nColor )
#else
   HARBOUR HB_FUN_SBTNLINE( PARAMS )
#endif
{
	HWND hWnd     = ( HWND ) _parni( 1 ) ;
   int iTop      = _parni( 2 ) ;
   int iLeft     = _parni( 3 ) ;
   int iBottom   = _parni( 4 ) ;
   int iRight    = _parni( 5 ) ;
   COLORREF nClr = _parnl( 6 ) ;

   HDC hDC = GetDC( hWnd ) ;
   HPEN hPen1, hPen2, hOldPen ;
   COLORREF nLight, nShadow ;
   nLight  = MakeDarker( nClr, -64 ) ;
   nShadow = MakeDarker( nClr, 64 ) ;

   hPen1  = CreatePen( PS_SOLID, 1, nLight ) ;
   hPen2  = CreatePen( PS_SOLID, 1, nShadow ) ;

   hOldPen = (HPEN) SelectObject( hDC, hPen2 ) ;
	GoPoint( hDC, iLeft, iTop ) ;
   LineTo( hDC, iRight, iBottom ) ;

   if( iTop == iBottom )
   { iTop++ ;
     iBottom++ ;
   }
   else
   {
     iLeft++ ;
     iRight++ ;
   }

   SelectObject( hDC, hPen1 ) ;
	GoPoint( hDC, iLeft, iTop ) ;
   LineTo( hDC, iRight, iBottom ) ;

   SelectObject( hDC, hOldPen ) ;
   DeleteObject( hPen1 ) ;
   DeleteObject( hPen2 ) ;
	ReleaseDC( hWnd, hDC ) ;
}

//---------------------------------------------------------------------------//

void SBtnBox( HDC hDC, RECT * rct, COLORREF lColor, BOOL bBorder, int iBox )
{
   HPEN hGray  = CreatePen( PS_SOLID, 1, MakeDarker( lColor, 64 ) ) ;
   HPEN hWhite = CreatePen( PS_SOLID, 1, MakeDarker( lColor, -96 ) ) ;
   HPEN hBlack = CreatePen( PS_SOLID, 1, RGB( 0, 0, 0 ) ) ;
   HPEN hOldPen ;
   int iTop   = rct->top ;
   int iLeft  = rct->left ;
   int iBot   = rct->bottom - 1 ;
   int iRight = rct->right - 1 ;

   hOldPen = SelectObject( hDC, hBlack ) ;

   if( bBorder )
   {
	   GoPoint( hDC, iLeft, iTop ) ;
      LineTo( hDC, iRight + 1, iTop ) ;
	   GoPoint( hDC, iRight, iTop ) ;
      LineTo( hDC, iRight, iBot + 1 ) ;
	   GoPoint( hDC, iRight, iBot ) ;
      LineTo( hDC, iLeft - 1, iBot ) ;
	   GoPoint( hDC, iLeft, iBot ) ;
      LineTo( hDC, iLeft, iTop - 1) ;
	   iLeft++ ;
   	iTop++ ;
	   iBot-- ;
   	iRight-- ;
   }

   if( iBox > 0 )
   {
      SelectObject( hDC, iBox == 1 ? hWhite : hGray ) ;
      GoPoint( hDC, iLeft, iBot - 1 ) ;
      LineTo( hDC, iLeft, iTop - 1 ) ;
      GoPoint( hDC, iLeft, iTop ) ;
      LineTo( hDC, iRight + 1, iTop ) ;
      SelectObject( hDC, iBox == 1 ? hGray : hWhite ) ;
      GoPoint( hDC, iLeft, iBot ) ;
      LineTo( hDC, iRight + 1, iBot) ;
      GoPoint( hDC, iRight, iBot ) ;
      LineTo( hDC, iRight, iTop - 1 ) ;
   }

   SelectObject( hDC, hOldPen ) ;
   DeleteObject( hGray ) ;
   DeleteObject( hWhite ) ;
   DeleteObject( hBlack ) ;
}

//---------------------------------------------------------------------------//

void ColorDegrad( HDC hDC, RECT * rori, COLORREF cFrom, COLORREF cTo, int iType, int iRound )
{
   int clr1r, clr1g, clr1b, clr2r, clr2g, clr2b ;
   signed int iEle, iRed, iGreen, iBlue, iTot, iHalf ;
   BOOL bHorz = ( iType == 2 || iType == 4 ) ;
   BOOL bDir ;
   RECT rct ;
   HPEN hOldPen, hPen ;
   LOGBRUSH lb ;
   HBRUSH hOldBrush, hBrush, hNull ;

   rct.top = rori->top ;
   rct.left = rori->left ;
   rct.bottom = rori->bottom ;
   rct.right = rori->right ;

 	iTot   = ( ! bHorz ? ( rct.bottom  - rct.top + 1 ) : ( rct.right - rct.left + 1 ) ) ;

   iHalf  = iTot / 2 ;
	lb.lbStyle = BS_NULL ;
	hNull  = CreateBrushIndirect(&lb) ;

   clr1r = GetRValue( cFrom ) ;
   clr1g = GetGValue( cFrom ) ;
   clr1b = GetBValue( cFrom ) ;

   clr2r = GetRValue( cTo ) ;
   clr2g = GetGValue( cTo ) ;
   clr2b = GetBValue( cTo ) ;

   iRed   =  abs( clr2r - clr1r ) ;
   iGreen =  abs( clr2g - clr1g ) ;
   iBlue  =  abs( clr2b - clr1b ) ;

   iRed   = ( iRed <= 0 ? 0 : ( iRed / iTot ) );
   iGreen = ( iGreen <= 0 ? 0 : ( iGreen / iTot ) ) ;
   iBlue  = ( iBlue <= 0 ? 0 : ( iBlue / iTot ) ) ;

   if( iType == 3 || iType == 4 )
   {
   	iRed   *= 2 ;
      iGreen *= 2 ;
      iBlue  *= 2 ;
   }

   if( iType == 5 )
   {
      rct.top  += ( ( rct.bottom - rct.top ) / 2 ) ;
      rct.left += ( ( rct.right - rct.left ) / 2 ) ;
      rct.top  -= ( ( rct.bottom - rct.top ) / 3 ) ;
      rct.bottom = rct.top + 2 ;
      rct.right  = rct.left + 2 ;
   }
   else
   {
   	if( ! bHorz )
	   	rct.bottom = rct.top + 1 ;
	   else
   		rct.right = rct.left + 1 ;
   }


   if( iType == 5 )
   {
	   hPen      = CreatePen( PS_SOLID, 1, RGB( clr2r, clr2g, clr2b ) ) ;
   	hOldPen   = SelectObject( hDC, hPen ) ;
		hBrush    = CreateSolidBrush( RGB( clr2r, clr2g, clr2b ) ) ;
   	hOldBrush = SelectObject( hDC, hBrush ) ;
      if( iRound == 1 )
	  		Ellipse( hDC, rori->left, rori->top, rori->right, rori->bottom ) ;
      else
	  		RoundRect( hDC, rori->left, rori->top, rori->right, rori->bottom, 16, 16 ) ;

   	SelectObject( hDC, hOldBrush ) ;
  	   DeleteObject( hBrush ) ;
   	SelectObject( hDC, hOldPen ) ;
  	   DeleteObject( hPen ) ;
	   hPen    = CreatePen( PS_SOLID, 2, RGB( clr1r, clr1g, clr1b ) ) ;
   	hOldPen = SelectObject( hDC, hPen ) ;
   	SelectObject( hDC, hNull ) ;
      if( iRound == 1 )
	  		Ellipse( hDC, rct.left, rct.top, rct.right, rct.bottom ) ;
      else
	  		RoundRect( hDC, rct.left, rct.top, rct.right, rct.bottom, 16, 16 ) ;

   }
   else
   {
	   hPen      = CreatePen( PS_SOLID, 1, RGB( clr1r, clr1g, clr1b ) ) ;
   	hOldPen   = SelectObject( hDC, hPen ) ;
		hBrush    = CreateSolidBrush( RGB( clr1r, clr1g, clr1b ) ) ;
   	hOldBrush = SelectObject( hDC, hBrush ) ;
   }

   for( iEle = 1; iEle < iTot; iEle++ )
   {

		if( iType > 2 && iType < 5 && iEle > iHalf )
      {
      	clr2r = GetRValue( cFrom ) ;
   		clr2g = GetGValue( cFrom ) ;
   		clr2b = GetBValue( cFrom ) ;
      }

      bDir = ( clr2r > clr1r ? TRUE : FALSE ) ;
      if( bDir )
      	clr1r += iRed ;
      else
      	clr1r -= iRed ;

      clr1r = ( clr1r < 0 ? 0 : clr1r > 255 ? 255 : clr1r ) ;

      bDir = ( clr2g > clr1g ? TRUE : FALSE  ) ;
      if( bDir )
      	clr1g += iGreen ;
      else
      	clr1g -= iGreen ;

      clr1g = ( clr1g < 0 ? 0 : clr1g > 255 ? 255 : clr1g ) ;

      bDir = ( clr2b > clr1b ? TRUE : FALSE  ) ;

      if( bDir )
      	clr1b += iBlue ;
      else
      	clr1b -= iBlue ;

      clr1b = ( clr1b < 0 ? 0 : clr1b > 255 ? 255 : clr1b ) ;

      if( iType == 5 )
      {
		      SelectObject( hDC, hOldBrush ) ;
   		   DeleteObject( hNull ) ;
				hNull  = CreateBrushIndirect(&lb) ;
		      SelectObject( hDC, hNull ) ;
   	      SelectObject( hDC, hOldPen ) ;
      		DeleteObject( hPen ) ;
   			hPen = CreatePen( PS_SOLID, 2, RGB( clr1r, clr1g, clr1b ) ) ;
	      	SelectObject( hDC, hPen ) ;
   	   if( iRound == 1 )
   			Ellipse( hDC, rct.left, rct.top, rct.right + 1, rct.bottom + 1 ) ;
	      else
   			RoundRect( hDC, rct.left, rct.top, rct.right + 1, rct.bottom + 1, 16, 16 ) ;

	      if( iRound == 1 )
   			Ellipse( hDC, rct.left, rct.top, rct.right + 1, rct.bottom + 1 ) ;
      	else
   			RoundRect( hDC, rct.left, rct.top, rct.right + 1, rct.bottom + 1, 16, 16 ) ;

	       	rct.top    -= ( rct.top <= rori->top ? 0 : 1 ) ;
   	    	rct.left   -= ( rct.left <= rori->left ? 0 : 1 );
      	 	rct.bottom +=  ( rct.bottom >= rori->bottom ? 0 : 1 ) ;
       		rct.right  +=  ( rct.right >= rori->right ? 0 : 1 ) ;
	   }
      else
      {
	      SelectObject( hDC, hOldBrush ) ;
   	   DeleteObject( hBrush ) ;
      	hBrush = CreateSolidBrush( RGB( clr1r, clr1g, clr1b ) ) ;
	      SelectObject( hDC, hBrush ) ;

      	FillRect( hDC, &rct, hBrush ) ;

      	if( ! bHorz )
      	{
	 			rct.top++ ;
   	   	rct.bottom++ ;
      	}
      	else
      	{
      		rct.left++ ;
         	rct.right++ ;
      	}
      }
   }
	SelectObject( hDC, hOldBrush ) ;
	SelectObject( hDC, hOldPen ) ;
   DeleteObject( hBrush ) ;
   DeleteObject( hPen ) ;
   DeleteObject( hNull ) ;
}

//---------------------------------------------------------------------------//

void SBtnRoundBox( HDC hDC, RECT * rct, COLORREF lColor, BOOL bPressed, BOOL bBlack )
{
   HPEN hGray  = CreatePen( PS_SOLID, 1, bBlack ? 0 : MakeDarker( lColor, 64 ) ) ;
   HPEN hWhite = CreatePen( PS_SOLID, 1, MakeDarker( lColor, -64 ) ) ;
   HPEN hOldPen ;
   RECT brct ;
   LOGBRUSH lb ;
   HBRUSH hNull, hbrOld ;
   POINT pO, pD ;

	lb.lbStyle = BS_NULL ;

	hNull  = CreateBrushIndirect(&lb) ;
	hbrOld = SelectObject(hDC, hNull) ;

   hOldPen = SelectObject( hDC, hGray ) ;

   brct.top = rct->top ;
   brct.left = rct->left ;
   brct.bottom = rct->bottom ;
   brct.right = rct->right ;

   pO.x = brct.left + ( ( brct.right - brct.left ) / 4 * 3 ) ;
   pO.y = brct.top ;
   pD.x = brct.left + ( ( brct.right - brct.left ) / 4 ) ;
   pD.y = brct.bottom ;

   if( ! bBlack )
	   SelectObject( hDC, bPressed ? hWhite : hGray ) ;

	Ellipse( hDC, brct.left, brct.top, brct.right, brct.bottom ) ;

   if( ! bBlack )
   {
	  	SelectObject( hDC, bPressed ? hGray : hWhite ) ;
  		Arc( hDC, brct.left, brct.top, brct.right, brct.bottom,  pO.x, pO.y, pD.x, pD.y ) ;
	}

   SelectObject( hDC, hOldPen ) ;
   SelectObject( hDC, hbrOld ) ;
   DeleteObject( hGray ) ;
   DeleteObject( hWhite ) ;
   DeleteObject( hNull ) ;
}

//---------------------------------------------------------------------------//

#ifndef __HARBOUR__
   CLIPPER DrawRadio( PARAMS )   // ( hDC, nTop, nLeft, cText, hFont, lChecked, nClrBtn,
                                 //   nClrText, nClrLight, nClrDark, lDisable, l3D,
                                 //   lFocused, nStyle, lDrawFocus, lTwice )
#else
   HARBOUR HB_FUN_DRAWRADIO( PARAMS )
#endif
{
   HDC hDC            = ( HDC ) _parni( 1 ) ;
   int iTop           = _parni( 2 ) ;
   int iLeft          = _parni( 3 ) ;
   LPSTR cText        = _parc( 4 ) ;
   HFONT hFont        =  ( HFONT ) _parni( 5 ) ;
   BOOL bSelect       = _parl( 6 ) ;
   COLORREF nClrBtn   = ( COLORREF ) _parnl( 7 ) ;
   COLORREF nClrText  = ( COLORREF ) _parnl( 8 ) ;
   COLORREF nClrLight = ( COLORREF ) _parnl( 9 ) ;
   COLORREF nClrDark  = ( COLORREF ) _parnl( 10 ) ;
   BOOL bDisable      = _parl( 11 ) ;
   BOOL b3DInv        = ( ISLOGICAL( 12 ) ? ! _parl( 12 ) : FALSE ) ;
   BOOL b3D           = ( ISLOGICAL( 12 ) ? TRUE : FALSE ) ;
   BOOL bFocus        = ( ISLOGICAL( 13 ) ? _parl( 13 ) : FALSE ) ;
   int iStyle         = _parni( 14 ) ;
   BOOL bDraw         = _parl( 15 ) ;
   BOOL bTwice        = _parl( 16 ) ;

   HFONT hOldFont = SelectObject( hDC, hFont ) ;

   COLORREF nClr2  = MakeDarker( nClrBtn, 48 ) ;
   COLORREF nClr3  = MakeDarker( nClrBtn, -48 ) ;

   HPEN hPDark  = CreatePen( PS_SOLID, 1, nClr2 ) ;
   HPEN hPNull  = CreatePen( PS_NULL, 0, 0 ) ;
   HPEN hPLight = CreatePen( PS_SOLID, 1, nClr3 ) ;
   HPEN hPBlack = CreatePen( PS_SOLID, 1, bDisable ? GetSysColor( COLOR_BTNSHADOW ) : 0 ) ;
   HPEN hPOld   = SelectObject( hDC, iStyle == 3 || iStyle != 4 ? hPBlack : hPDark ) ;

   LOGBRUSH lb ;
	HBRUSH hBNull ;
   HBRUSH hBBlack = CreateSolidBrush( bDisable ? GetSysColor( COLOR_BTNSHADOW ) : 0 ) ;
   HBRUSH hBGray  = CreateSolidBrush( bDisable ? GetSysColor( COLOR_BTNFACE ) : nClrBtn ) ;
   HBRUSH hBDisab = CreateSolidBrush( GetSysColor( COLOR_BTNSHADOW ) ) ;
   HBRUSH hBOld   = SelectObject( hDC, hBGray ) ;

   POINT aB[ 4 ] ;
   POINT aP[ 7 ] ;
   RECT rct ;
   int iBkOld ;
   TEXTMETRIC tm ;

   GetTextMetrics( hDC, &tm ) ;

	lb.lbStyle = BS_NULL ;
	hBNull  = CreateBrushIndirect( &lb ) ;

   rct.top    = iTop ;
   rct.left   = iLeft ;
   rct.bottom = rct.top + tm.tmHeight ;
   rct.right  = rct.left + GetTextExtent( hDC, cText, _parclen( 4 ) ) - tm.tmOverhang ;

   if( iStyle == 3 )
   {
		aP[ 0 ].x = 4 + iLeft ;
   	aP[ 0 ].y = iTop + 2;
      aP[ 1 ].x = 9 + iLeft ;
	   aP[ 1 ].y = 5 + iTop + 2 ;
   	aP[ 2 ].x = 4 + iLeft ;
      aP[ 2 ].y = 10 + iTop + 2 ;
	   aP[ 3 ].x = 4 + iLeft ;
   	aP[ 3 ].y = 7 + iTop + 2 ;
      aP[ 4 ].x = 0 + iLeft ;
	   aP[ 4 ].y = 7 + iTop + 2 ;
   	aP[ 5 ].x = 0 + iLeft ;
      aP[ 5 ].y = 3 + iTop + 2 ;
	   aP[ 6 ].x = 4 + iLeft ;
   	aP[ 6 ].y = 3 + iTop + 2 ;
	}
   else
   {
      aB[ 0 ].x = 6 + iLeft ;
      aB[ 0 ].y = iTop ;
      aB[ 1 ].x = 12 + iLeft ;
      aB[ 1 ].y = 6 + iTop ;
      aB[ 2 ].x = 6 + iLeft ;
      aB[ 2 ].y = 12 + iTop ;
      aB[ 3 ].x = iLeft ;
      aB[ 3 ].y = 6 + iTop ;
	}

   switch( iStyle )
   {
   case 3 :  // Pointer arrow

      if( bSelect )
      {
	      SelectObject( hDC, hPBlack ) ;
   	   SelectObject( hDC, hBGray ) ;

         Polygon( hDC, aP, sizeof( aP ) / sizeof( POINT ) ) ;
      }

      break ;
   case 4 :   // Check Box
      if( ! bDisable || ( bDisable && bSelect ) )
      {
	      SelectObject( hDC, hPDark ) ;
   		Rectangle( hDC, rct.left, rct.top, rct.left + 13, rct.top + 13 ) ;
      	SelectObject( hDC, hPLight ) ;
	      GoPoint( hDC, rct.left + 12, rct.top ) ;
   	   LineTo( hDC,  rct.left, rct.top ) ;
      	LineTo( hDC, rct.left, rct.top + 12 ) ;

	      if( bSelect )
   	   {
      	   SelectObject( hDC, hPBlack ) ;
	      	GoPoint( hDC, rct.left + 9, rct.top + 3 ) ;
   	      LineTo( hDC, rct.left + 2, rct.top + 10 ) ;
      	   LineTo( hDC, rct.left + 2, rct.top + 6 ) ;
	         LineTo( hDC, rct.left + 3, rct.top + 5 ) ;
   	      LineTo( hDC, rct.left + 3, rct.top + 10 ) ;
      	   LineTo( hDC, rct.left + 10, rct.top + 3 ) ;
	      }
      }
      break ;

   case 5 :   // Circle
      if( ! bDisable || ( bDisable && bSelect ) )
      {
	      SelectObject( hDC, bSelect ? hPLight : hPDark ) ;
   		Ellipse( hDC, rct.left + 1, rct.top + 1, rct.left + 12, rct.top + 12 ) ;
      	SelectObject( hDC, bSelect ? hPDark : hPLight ) ;
	   	Arc( hDC, rct.left + 1, rct.top + 1, rct.left + 12, rct.top + 12,  rct.left + 8, rct.top + 2, rct.left + 3, rct.top + 12 ) ;
   	   SelectObject( hDC, hBBlack ) ;
      	SelectObject( hDC, hPDark ) ;
	      if( bSelect )
   	   {
      	   Ellipse( hDC, rct.left + 4, rct.top + 4, rct.left + 9, rct.top + 9 ) ;
	      }
      }
      break ;

   case 6 :   // pressed rhombus

	   if( ! bDisable || ( bDisable && bSelect ) )
      {
         SelectObject( hDC, hBNull ) ;
    		Polygon( hDC, aB, sizeof( aB ) / sizeof( POINT ) ) ;
      	SelectObject( hDC, hBGray ) ;
      }
      break ;

   case 8 :   // pressed arrow pointer
      if( ! bDisable && bSelect )
      {
	      SelectObject( hDC, hPLight ) ;
   	   SelectObject( hDC, hBGray ) ;

         Polygon( hDC, aP, sizeof( aP ) / sizeof( POINT ) ) ;
      }

      break ;
   case 9 :   // pressed check box

	   if( ! bDisable || ( bDisable && bSelect ) )
      {
         SelectObject( hDC, hBNull ) ;
	      SelectObject( hDC, hPBlack ) ;
   		Rectangle( hDC, rct.left, rct.top, rct.left + 13, rct.top + 13 ) ;
      	SelectObject( hDC, hBGray ) ;
      }
      break ;

   case 10 :   // pressed circle

	   if( ! bDisable || ( bDisable && bSelect ) )
      {
         SelectObject( hDC, hBNull ) ;
	      SelectObject( hDC, hPBlack ) ;
	   	Ellipse( hDC, rct.left + 1, rct.top + 1, rct.left + 12, rct.top + 12 ) ;
      	SelectObject( hDC, hBGray ) ;
      }
      break ;

   default :   // rhombus

      SelectObject( hDC, hPDark ) ;
	   if( ! bDisable || ( bDisable && bSelect ) )
   		Polygon( hDC, aB, sizeof( aB ) / sizeof( POINT ) ) ;

   	if( ! bDisable || ( bDisable && bSelect ) )
	   {
        	if( iStyle != 1 )
         {
         	aB[ 0 ].y += 1 ;
  	         aB[ 1 ].x -= 1 ;
        	   aB[ 2 ].y -= 1 ;
           	aB[ 3 ].x += 1 ;
            SelectObject( hDC, hPDark ) ;
	   		Polygon( hDC, aB, sizeof( aB ) / sizeof( POINT ) ) ;
            aB[ 0 ].y -= 1 ;
            aB[ 1 ].x += 1 ;
        	   aB[ 2 ].y += 1 ;
           	aB[ 3 ].x -= 1 ;
         }

  			SelectObject( hDC, hPLight ) ;

		   switch( bSelect )
   		{
		      case FALSE :
               GoPoint( hDC, aB[ 0 ].x, aB[ 0 ].y ) ;
               LineTo( hDC, aB[ 3 ].x, aB[ 3 ].y ) ;
               LineTo( hDC, aB[ 2 ].x, aB[ 2 ].y ) ;
               if( iStyle != 1 )
               {
	               GoPoint( hDC, aB[ 0 ].x, aB[ 0 ].y + 1 ) ;
   	            LineTo( hDC, aB[ 3 ].x + 1, aB[ 3 ].y ) ;
      	         LineTo( hDC, aB[ 2 ].x, aB[ 2 ].y - 1 ) ;
               }
   		      break ;

	      	case TRUE :
               GoPoint( hDC, aB[ 0 ].x + 1, aB[ 0 ].y +  1) ;
               LineTo( hDC, aB[ 1 ].x, aB[ 1 ].y ) ;
               LineTo( hDC, aB[ 2 ].x - 1, aB[ 2 ].y + 1 ) ;
               if( iStyle != 1 )
               {
	               GoPoint( hDC, aB[ 0 ].x + 1 , aB[ 0 ].y + 2 ) ;
   	            LineTo( hDC, aB[ 1 ].x - 1, aB[ 1 ].y ) ;
      	         LineTo( hDC, aB[ 2 ].x - 1, aB[ 2 ].y ) ;
               }

   	            aB[ 0 ].y += 4 ;
      	         aB[ 1 ].x -= 4 ;
            	   aB[ 2 ].y -= 4 ;
               	aB[ 3 ].x += 4 ;

   	      	SelectObject( hDC, hPBlack ) ;
		         SelectObject( hDC, hBBlack ) ;

   	      	Polygon( hDC, aB, sizeof( aB ) / sizeof( POINT ) ) ;

      		   break ;
	   	}

   	}
      break ;
	}

   if( iStyle < 6 )
   {
	   rct.top    += 1 ;
   	rct.left   += 16 ;
	   rct.right  += 16 ;
   	rct.bottom += 1 ;

	   iBkOld = SetBkMode( hDC, TRANSPARENT ) ;

	   if( b3D )
   	{
      	rct.top    -= 1 ;
	      rct.left   -= 1 ;
   	   rct.bottom -= 1 ;
      	rct.right  -= 1 ;

	      SetTextColor( hDC, b3DInv ? nClrDark : nClrLight ) ;

   	   DrawText( hDC, cText, -1, &rct, DT_LEFT | DT_TOP | DT_SINGLELINE ) ;

      	rct.top    += 2 ;
	      rct.left   += 2 ;
   	   rct.bottom += 2 ;
      	rct.right  += 2 ;

	      SetTextColor( hDC, b3DInv ? nClrLight : nClrDark ) ;

   	   DrawText( hDC, cText, -1, &rct, DT_LEFT | DT_TOP | DT_SINGLELINE ) ;

      	rct.top    -= 1 ;
	      rct.left   -= 1 ;
   	   rct.bottom -= 1 ;
      	rct.right  -= 1 ;

	      SetTextColor( hDC, nClrText ) ;

   	   DrawText( hDC, cText, -1, &rct, DT_LEFT | DT_TOP | DT_SINGLELINE ) ;
	   }
   	else
	   {
   	   SetTextColor( hDC, nClrText ) ;

      	DrawText( hDC, cText, -1, &rct, DT_LEFT | DT_TOP | DT_SINGLELINE ) ;
	   }

      if( ( bFocus && ! bDisable && iStyle < 6 && bSelect ) || ( bFocus && bDraw ) )
	   {
   	   rct.top    -= 1 ;
      	rct.left   -= 1 ;
	      rct.bottom += 1 ;
         rct.right  += 1 ;

	  	   DrawFocusRect( hDC, &rct ) ;

      	if( bFocus && bDraw && bTwice )
		  	   DrawFocusRect( hDC, &rct ) ;

   	}
	}

   SetBkMode( hDC, iBkOld ) ;
   SelectObject( hDC, hOldFont ) ;
   SelectObject( hDC, hPOld ) ;
   SelectObject( hDC, hBOld ) ;

   DeleteObject( hPDark ) ;
   DeleteObject( hPLight ) ;
   DeleteObject( hPBlack ) ;
   DeleteObject( hPNull ) ;
   DeleteObject( hBBlack ) ;
   DeleteObject( hBGray ) ;
   DeleteObject( hBDisab ) ;
   DeleteObject( hBNull ) ;
}

//---------------------------------------------------------------------------//

#ifndef __HARBOUR__
   CLIPPER DrawBoxes( PARAMS )   // ( hDC, hWnd, nType, cText, hFont, nAlign, nClrLight,
                                 //   nClrDark, nClrLabel  )
#else
   HARBOUR HB_FUN_DRAWBOXES( PARAMS )
#endif
{

	HDC hDC            = ( HDC ) _parni( 1 ) ;
   HWND hWnd          = ( HWND ) _parni( 2 ) ;
	int iType          = _parni( 3 ) ;
   LPSTR cLabel        = _parc( 4 ) ;
   HFONT hFont        = ( HFONT ) _parni( 5 ) ;
   int iAlign         = ( ISNUM( 6 ) ? _parni( 6 ) : 0 ) ;
   COLORREF nClrLight = ( COLORREF ) ( ISNUM( 7 ) ? _parnl( 7 ) : MakeDarker( GetSysColor( COLOR_BTNFACE ), -48 ) ) ;
   COLORREF nClrDark  = ( COLORREF ) ( ISNUM( 8 ) ? _parnl( 8 ) : MakeDarker( GetSysColor( COLOR_BTNFACE ), 48 ) ) ;
   COLORREF nClrLabel = ( COLORREF ) ( ISNUM( 9 ) ? _parnl( 9 ) : GetSysColor( COLOR_BTNTEXT ) ) ;
   BOOL bLabel        = ( ISCHAR( 4 ) && _parclen( 4 ) > 0 ? TRUE : FALSE ) ;


   RECT rct ;
   GetClientRect( hWnd, &rct ) ;

   cDrawBoxes( hDC, &rct, iType, cLabel, hFont, iAlign, nClrLight, nClrDark, nClrLabel, bLabel ) ;

}

//---------------------------------------------------------------------------//

#ifndef __HARBOUR__
   CLIPPER DarkColor( PARAMS )   // ( nColor, nIncrement ) --> New Color
#else
   HARBOUR HB_FUN_DARKCOLOR( PARAMS )
#endif
{
	_retnl( MakeDarker( ( COLORREF ) _parnl( 1 ), _parni( 2 ) ) ) ;
}

//---------------------------------------------------------------------------//

#ifndef __HARBOUR__
   CLIPPER GetFontHei( PARAMS )   // ght( hDC, hFont ) --> Font Height
#else
   HARBOUR HB_FUN_GETFONTHEIGHT( PARAMS )
#endif
{
   HDC hDC     = ( HDC ) _parni( 1 ) ;
   HFONT hFont = ( HFONT ) _parni( 2 ) ;

   TEXTMETRIC tm ;
   HFONT hOldFont = SelectObject( hDC, hFont ) ;

   GetTextMetrics( hDC, &tm ) ;
   SelectObject( hDC, hOldFont ) ;

   _retni( tm.tmHeight ) ;
}

//---------------------------------------------------------------------------//

#ifndef __HARBOUR__
   CLIPPER DrawRectDo( PARAMS )   // tted( hDC, nTop, nLeft, nBottom,
                                  //       nRight )
#else
   HARBOUR HB_FUN_DRAWRECTDOTTED( PARAMS )
#endif
{
   HDC hDC     = ( HDC ) _parni( 1 ) ;
   int iTop    = _parni( 2 ) ;
   int iLeft   = _parni( 3 ) ;
   int iBottom = _parni( 4 ) ;
   int iRight  = _parni( 5 ) ;
   RECT rct ;

   rct.top    = iTop ;
   rct.left   = iLeft ;
   rct.bottom = iBottom ;
   rct.right  = iRight ;

   DrawFocusRect( hDC, &rct ) ;
}

//---------------------------------------------------------------------------//

void cDrawBoxes( HDC hDC, RECT * rrct, int iType, LPSTR cLabel, HFONT hFont, int iAlign,
                        COLORREF nClrLight, COLORREF nClrDark, COLORREF nClrLabel, BOOL bLabel )
{

   RECT rct, rctt ;
   TEXTMETRIC tm ;
   int iWidth, iBkOld ;
	HFONT hFOld ;
	HRGN hRgn, hOldRgn ;
   POINT aP[ 3 ] ;

   HPEN hPDark  = CreatePen( PS_SOLID, 1, nClrDark ) ;
   HPEN hPLight = CreatePen( PS_SOLID, 1, nClrLight ) ;
   HPEN hPBlack = CreatePen( PS_SOLID, 1, 0 ) ;
   HPEN hPOld   = SelectObject( hDC, iType == 1 || iType == 4 ? hPDark : hPLight ) ;
   LOGBRUSH lb ;
   HBRUSH hBNull, hBOld ;

   if( bLabel )
   	hFOld = SelectObject( hDC, hFont ) ;

	lb.lbStyle = BS_NULL ;
	hBNull     = CreateBrushIndirect( &lb ) ;

   GetTextMetrics( hDC, &tm ) ;
   rct.top    = rrct->top ;
   rct.left   = rrct->left ;
   rct.bottom = rrct->bottom ;
   rct.right  = rrct->right ;

   rct.right  -= ( iType == 2 || iType == 5 ? 1 : 0 ) ;
   rct.bottom -= ( iType == 2 || iType == 5 ? 1 : 0 ) ;
   rctt.top    = rct.top ;
   rctt.bottom = rctt.top + tm.tmHeight ;
   iWidth      = GetTextExtent( hDC, cLabel, _parclen( 4 ) ) ;

   if( bLabel )
   {
	   switch( iAlign )
   	{
   		case 0 :  // left aligned label
	        	rctt.left = rct.left + 9 ;
   	      rctt.right = rctt.left + iWidth ;
				break ;

	     	case 1 :  // centered label
   	     	rctt.left = rct.right - ( rct.right / 2 ) - ( iWidth / 2 ) ;
      	   rctt.right = rctt.left + iWidth ;
				break ;

   	  	case 2 :  // right aligned label
      	  	rctt.right = rct.right - 9 ;
         	rctt.left = rctt.right - iWidth ;
				break ;
	   }
   }

   rct.top += ( bLabel ? ( tm.tmHeight / 2 ) : 0 ) ;

	aP[ 0 ].x = rct.left ;
	aP[ 0 ].y = rct.top ;
   aP[ 1 ].x = rct.right ;
	aP[ 1 ].y = rct.top ;
	aP[ 2 ].x = rct.left ;
   aP[ 2 ].y = rct.bottom - 1 ;

   if( bLabel )
   {
 	  	iBkOld = SetBkMode( hDC, TRANSPARENT ) ;
   	SetTextColor( hDC, nClrLabel ) ;
      DrawText( hDC, cLabel, -1, &rctt, DT_LEFT | DT_TOP | DT_SINGLELINE ) ;
      SetBkMode( hDC, iBkOld ) ;
	   ExcludeClipRect( hDC, rctt.left, rct.top, rctt.right, rctt.bottom ) ;
   }

   if( iType == 1 || iType == 3 || iType == 4 || iType == 6 )
   	hRgn  = CreatePolygonRgn( aP, sizeof( aP ) / sizeof( POINT ), ALTERNATE ) ;

   hBOld = SelectObject( hDC, hBNull ) ;

   switch( iType )
	{
      case 1 : // white box
         SelectObject( hDC, hPDark ) ;
			Rectangle( hDC, rct.left, rct.top, rct.right, rct.bottom ) ;
         hOldRgn = SelectObject( hDC, hRgn ) ;
         SelectObject( hDC, hPLight ) ;

         if( bLabel )
		   	ExcludeClipRect( hDC, rctt.left, rct.top, rctt.right, rctt.bottom ) ;

			Rectangle( hDC, rct.left, rct.top, rct.right, rct.bottom ) ;
         break ;

      case 2 : // gray box
         rct.top    += 1 ;
         rct.left   += 1 ;
         rct.bottom += 1 ;
         rct.right  += 1 ;

         SelectObject( hDC, hPLight ) ;
			Rectangle( hDC, rct.left, rct.top, rct.right, rct.bottom ) ;

         rct.top    -= 1 ;
         rct.left   -= 1 ;
         rct.bottom -= 1 ;
         rct.right  -= 1 ;
         SelectObject( hDC, hPDark ) ;

         if( bLabel )
		   	ExcludeClipRect( hDC, rctt.left, rct.top, rctt.right, rctt.bottom ) ;

			Rectangle( hDC, rct.left, rct.top, rct.right, rct.bottom ) ;
         break ;

      case 3 : // black box
         SelectObject( hDC, hPLight ) ;
			Rectangle( hDC, rct.left, rct.top, rct.right, rct.bottom ) ;
         hOldRgn = SelectObject( hDC, hRgn ) ;
         SelectObject( hDC, hPDark ) ;

         if( bLabel )
		   	ExcludeClipRect( hDC, rctt.left, rct.top, rctt.right, rctt.bottom ) ;

			Rectangle( hDC, rct.left, rct.top, rct.right, rct.bottom ) ;
         break ;

      case 4 : // white round box
			RoundRect( hDC, rct.left, rct.top, rct.right, rct.bottom, 16, 16 ) ;
         hOldRgn = SelectObject( hDC, hRgn ) ;
         SelectObject( hDC, hPLight ) ;

         if( bLabel )
		   	ExcludeClipRect( hDC, rctt.left, rct.top, rctt.right, rctt.bottom ) ;

			RoundRect( hDC, rct.left, rct.top, rct.right, rct.bottom, 16, 16 ) ;
         break ;

      case 5 : // gray round box
         rct.top    += 1 ;
         rct.left   += 1 ;
         rct.bottom += 1 ;
         rct.right  += 1 ;
         SelectObject( hDC, hPLight ) ;
			RoundRect( hDC, rct.left, rct.top, rct.right, rct.bottom, 16, 16 ) ;
         rct.top    -= 1 ;
         rct.left   -= 1 ;
         rct.bottom -= 1 ;
         rct.right  -= 1 ;
         SelectObject( hDC, hPDark ) ;

         if( bLabel )
		   	ExcludeClipRect( hDC, rctt.left, rct.top, rctt.right, rctt.bottom ) ;

			RoundRect( hDC, rct.left, rct.top, rct.right, rct.bottom, 16, 16 ) ;
         break ;

      case 6 : // black Round box
         SelectObject( hDC, hPLight ) ;
			RoundRect( hDC, rct.left, rct.top, rct.right, rct.bottom, 16, 16 ) ;
         hOldRgn = SelectObject( hDC, hRgn ) ;
         SelectObject( hDC, hPDark ) ;

         if( bLabel )
		   	ExcludeClipRect( hDC, rctt.left, rct.top, rctt.right, rctt.bottom ) ;

			RoundRect( hDC, rct.left, rct.top, rct.right, rct.bottom, 16, 16 ) ;
         break ;

      case 7 : // horizontal line

         SelectObject( hDC, hPDark ) ;
         GoPoint( hDC, rct.left, rct.top ) ;
         LineTo( hDC, rct.right + 1, rct.top ) ;
         SelectObject( hDC, hPLight ) ;
         GoPoint( hDC, rct.left, rct.top + 1 ) ;
         LineTo( hDC, rct.right + 1, rct.top + 1 ) ;
         break ;

      case 8 : // vertical line

         SelectObject( hDC, hPDark ) ;
         GoPoint( hDC, rct.left, rct.top ) ;
         LineTo( hDC, rct.left, rct.bottom + 1 ) ;
         SelectObject( hDC, hPLight ) ;
         GoPoint( hDC, rct.left + 1 , rct.top ) ;
         LineTo( hDC, rct.left + 1, rct.bottom + 1 ) ;
         break ;

   	case 9 : // black rect
         SelectObject( hDC, hPBlack ) ;
			Rectangle( hDC, rct.left, rct.top, rct.right, rct.bottom ) ;
         break ;

      case 10 : // black Round rect
         SelectObject( hDC, hPBlack ) ;
			RoundRect( hDC, rct.left, rct.top, rct.right, rct.bottom, 16, 16 ) ;
         break ;
	}


   if( iType == 1 || iType == 3 || iType == 4 || iType == 6 )
   {
	   DeleteObject( hRgn ) ;
   	hRgn = CreateRectRgn( rct.left, rct.top, rct.right, rct.bottom ) ;
	   SelectObject( hDC, hRgn ) ;
   	SelectObject( hDC, hOldRgn ) ;
	   DeleteObject( hRgn ) ;
   	DeleteObject( hOldRgn ) ;
   }
   
   SelectObject( hDC, hPOld ) ;
   SelectObject( hDC, hBOld ) ;
   if( bLabel )
	   SelectObject( hDC, hFOld ) ;
   DeleteObject( hPLight ) ;
   DeleteObject( hPDark ) ;
   DeleteObject( hPBlack ) ;
   DeleteObject( hBNull ) ;
}

//---------------------------------------------------------------------------//

#ifndef __HARBOUR__
   CLIPPER DrawLimit( PARAMS )   // ( hDC, aPoint, nPenWidth )
#else
   HARBOUR HB_FUN_DRAWLIMIT( PARAMS )
#endif
{

   HDC hDC  = ( HDC ) _parni( 1 ) ;
   int iYo  = _parni( 2, 1 ) ;
   int iXo  = _parni( 2, 2 ) ;
   int iYd  = _parni( 2, 3 ) ;
   int iXd  = _parni( 2, 4 ) ;

   int iROP   = SetROP2( hDC, R2_NOT ) ;
   HPEN hPen  = CreatePen( PS_SOLID, 3, RGB( 128, 128, 128 ) ) ;
   HPEN hPOld = SelectObject( hDC, hPen ) ;

   GoPoint( hDC, iXo, iYo ) ;
   LineTo( hDC, iXd, iYd ) ;

   SetROP2( hDC, iROP ) ;
   SelectObject( hDC, hPOld ) ;
   DeleteObject( hPen ) ;
}
