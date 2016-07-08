// Programa.: INOAJUST.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Ajustes al Inventario
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

PROCEDURE InoAjust()
   LOCAL oA, oDlg, oLbx, lSalir := .f.
   LOCAL aBarra, aDev := { "" }
oA := TAjuste() ; oA:New()
AEVAL( oA:aCab[5], {|aVal| AADD( aDev, aVal[1] ) } )
aBarra := { {|| oA:Editar( oLbx,.t. ) }, {|| oA:Editar( oLbx,.f. ) }   ,;
            {|| oA:New( 0 ) }          , {|| oA:Borrar( oLbx,oA:aCab[4] ) },;
            {|| ListAjus( {oA:aCab[2], oA:aCab[2], "S", oApl:nUS       ,;
                           oA:aCab[1],"S",.f.} ), oA:oG[1]:SetFocus() },;
            {|| oA:New( 1 ), lSalir := .t., oDlg:End() } }
DEFINE DIALOG oDlg FROM 0, 0 TO 320, 580 PIXEL;
   TITLE "Ajustes al Inventario"
   @ 16, 00 SAY "Optica"               OF oDlg RIGHT PIXEL SIZE 60,10
   @ 16, 62 GET oA:oG[1] VAR oA:aCab[3] OF oDlg PICTURE "@!"          ;
      VALID EVAL( {|| If( oApl:oEmp:Seek( {"localiz",oA:aCab[3]} )   ,;
                        ( nEmpresa( .t. ), oA:aCab[1] := 0           ,;
                          oA:aCab[6] := oApl:oEmp:AJUSTES + 1        ,;
                          oA:oG[2]:Refresh(), oA:oG[3]:Refresh(),.t.),;
                        (MsgStop("Esta Optica NO EXISTE"), .f.) ) } ) ;
      SIZE 24,10 PIXEL UPDATE
   @ 28,00 SAY "Numero de Ajuste" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 28,52 GET oA:oG[2] VAR oA:aCab[1]  OF oDlg PICTURE "999999999" ;
      VALID ( oA:Buscar( oLbx,,oDlg ) )  SIZE 40,10 PIXEL
   @ 28, 90 SAY "Sgte. Ajuste"    OF oDlg RIGHT PIXEL SIZE 50,10
   @ 28,142 SAY oA:oG[3] VAR oA:aCab[6] OF oDlg PIXEL SIZE 44,10 ;
      UPDATE COLOR nRGB( 255,0,0 )
   @ 40, 00 SAY "Fecha [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 40, 52 GET oA:oG[4] VAR oA:aCab[2] OF oDlg ;
      VALID oA:CambiaFec()                      ;
      WHEN oA:aPrv[2] SIZE 34,10 PIXEL UPDATE
   @ 40, 90 SAY "Nro. Items"       OF oDlg RIGHT PIXEL SIZE 50,10
   @ 40,142 SAY oA:oG[5] VAR oA:nSec OF oDlg SIZE 40,12 PIXEL UPDATE

   @ 56,06 LISTBOX oLbx FIELDS oA:oAju:CODIGO            ,;
                    LeerCodig( oA:oAju:CODIGO )          ,;
                    TRANSFORM( oA:oAju:CANTIDAD,"9,999" ),;
                         aDev[ oA:oAju:TIPO+1 ]          ,;
                               oA:oAju:INDICA             ;
      HEADERS "Código"+CRLF+"Artículo", "Descripción", "Cantidad", "Tipo", "Ind";
      SIZES 400, 450 SIZE 280,100 ;
      OF oDlg UPDATE PIXEL        ;
      ON DBLCLICK EVAL( aBarra[2] )
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:GoTop()
    oLbx:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:nHeaderHeight := 28
    oLbx:aColSizes   := {90,240,90,96,10}
    oLbx:aHjustify   := {2,2,2,2,2}
    oLbx:aJustify    := {0,0,1,0,2}
    oLbx:ladjbrowse  := oLbx:lCellStyle := .f.
    oLbx:ladjlastcol := .t.
    oLbx:bKeyDown := {|nKey| If(nKey == VK_ESCAPE, ( oA:oG[1]:SetFocus() ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=82, CambiaIndica( oA:oAju ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(aBarra[1]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, EVAL(aBarra[2]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, EVAL(aBarra[4]),) )))) }
   MySetBrowse( oLbx,oA:oAju )
   ACTIVAGET(oA:oG)
ACTIVATE DIALOG oDlg ON INIT ;
   ( oDlg:Move(80,1), DefineBar( oDlg,oLbx,aBarra ) );
   VALID lSalir
oA:oAju:Destroy()
RETURN

//------------------------------------//
CLASS TAjuste FROM TContabil

 DATA aCab, aPrv, oAju, oCA
 DATA nSec          INIT 0
 DATA oG            INIT ARRAY(5)

 METHOD New( nCon ) Constructor
 METHOD Buscar( oLbx,aEd,oDlg )
 METHOD Borrar( oLbx,nReg )
 METHOD CambiaFec()
 METHOD Editar( oLbx,lNew )
 METHOD Grabar( oLbx,lNew )
 METHOD Ajustar( cCodi,nMov,nCanti,nPC )

ENDCLASS

//------------------------------------//
METHOD New( nCon ) CLASS TAjuste

If nCon == NIL
   ::aCab := { 0,DATE(),oApl:oEmp:TITULAR,0,"",oApl:oEmp:AJUSTES+1,0,0,0,0,0,.f.,"" }
   ::aPrv := Privileg( "AJUSTES" )
   ::oAju := oApl:Abrir( "cadajust","codigo",.t.,,100 )
   ::oAju:Seek( { "optica",oApl:nEmpresa,"numero",::aCab[1] } )
   ::oCA  := TInv() ; ::oCA:New( ,.f. )
   ::aCab[5] := Buscar( { "clase","ajustes" },"cadcausa","nombre, movto",2,"tipo" )
Else
      ::aCab[12] := If( nCon == 0 .AND. ::aCab[1] > 0, .t., ::aCab[12] )
   If ::aCab[12] .AND. !oApl:lEnLinea
      ::aLS[02] := ::aLS[3] := ::aCab[2]
      ::aLS[11] := ::aCab[1]
      ::Ajustes()
   EndIf
      ::aCab[12] := .f.
EndIf
RETURN NIL

//------------------------------------//
METHOD Buscar( oLbx,aEd,oDlg ) CLASS TAjuste
   LOCAL lSi := .t.
If VALTYPE( oLbx ) == "C"
   If (lSi := oApl:oInv:Seek( {"codigo",oLbx} ))
      If oApl:oInv:GRUPO  == "1" .AND. oApl:oInv:OPTICA # oApl:nEmpresa .OR.;
         (oApl:oInv:MONEDA == "C" .AND. oApl:oInv:SITUACION $ "DV")
         oLbx := If( oApl:oInv:MONEDA == "C" .AND. oApl:oInv:SITUACION $ "DV",;
           ("EN CONSIGNACION " + {"Vendida","Devuelta"}[AT(oApl:oInv:SITUACION,"VD")]),;
           ("Esta en " + ArrayValor( oApl:aOptic,STR(oApl:oInv:OPTICA,2) )) )
         If oApl:lEnLinea
            MsgStop( oLbx,"Montura esta" )
            lSi := .f.
         Else
            lSi := MsgNoYes( oLbx,"Montura esta" )
         EndIf
      EndIf
   Else
      MsgStop( "Este Código NO EXISTE !!!",oLbx )
   EndIf
Else
   ::New( 1 )
         lSi := .f.
   If Rango( ::aCab[1],0,::aCab[6] )
      If !::oAju:Seek( {"optica",oApl:nEmpresa,"numero",::aCab[1]},"secuencia",.t. ) .AND. ::aCab[1] > 0
         MsgStop( "Este Ajuste NO EXISTE !!" )
      Else
         If ::oAju:lOK
            ::oG[2]:oJump := oLbx
            ::aCab[2] := ::oAju:FECHA
         Else
            ::aCab[2] := DATE()
         EndIf
         ::aCab[04] := ::oAju:nRowCount
         ::aCab[11] := oApl:oEmp:PRINCIPAL
         ::aCab[12] := .f. //::oAju:lOK
         ::aCab[13] := NtChr( ::aCab[2],"1" )
         ::nSec := MAX( ::oAju:SECUENCIA,::oAju:nRowCount )
         oDlg:Update()
         oLbx:Refresh() ; oLbx:GoTop()
         lSi := .t.
      EndIf
   EndIf
EndIf
RETURN lSi

//------------------------------------//
METHOD Borrar( oLbx,nReg ) CLASS TAjuste
   LOCAL aBor, oMC
If !CierreInv( ::aCab[2],"AJUSTES" )
   If ::aPrv[3] .AND. nReg > 0
      If ::oAju:INDICA == "B"
         MsgInfo( "Ya esta Borrado",::oAju:CODIGO )
      ElseIf MsgNoYes( "Este Código "+::oAju:CODIGO,"Elimina" )
         aBor := { ::oAju:CODIGO,::oAju:TIPO,::oAju:CANTIDAD,::oAju:PCOSTO }
         If ::oAju:INDICA == "E"
            ::oAju:INDICA := "B" ; ::oAju:Update( .f.,1 )
            ::Ajustar( aBor[1],aBor[2],-aBor[3],aBor[4] )
            ::aCab[12] := .t.
         ElseIf ::oAju:Delete( .t.,1 )
            PListbox( oLbx,::oAju )
            ::Ajustar( aBor[1],aBor[2],-aBor[3],aBor[4] )
            ::aCab[4] --
            ::aCab[12] := .t.
         EndIf
         nReg := ::aCab[4]
      EndIf
   EndIf
   If nReg == 0 .AND. !oApl:lEnLinea
      If ::aCab[2] >= CTOD("01.05.2011")
         aBor := " AND COMPROBANTE = " + LTRIM(STR(::aCab[1]))+;
                 " AND DESCRIPCION = 'AJUSTES POR SOBRANTES Y FALTANTES -"+;
                   TRIM(oApl:oEmp:LOCALIZ) +;
                "' AND FECHA = " + ::INF(::aCab[2])
      Else
         aBor := " AND COMPROBANTE = " + PADL( LTRIM(STR(oApl:nEmpresa)),6,"9" )
      EndIf
         aBor := "SELECT CONSECUTIVO FROM movto_c "            +;
                 "WHERE CODIGO_EMP = " + LTRIM(STR(::aCab[11]))+;
                  " AND ANO_MES    = " + ::aCab[13]            +;
                  " AND TIPO       = '9'" + aBor
      ConectaOn()
      oMC := TDbOdbc()
      oMC:New( aBor,oApl:oODbc )
      oMC:End()
      If !oMC:lEof
         aBor := "WHERE CODIGO_EMP  = " + LTRIM(STR(::aCab[11]))+;
                  " AND ANO_MES     = " + ::aCab[13]            +;
                  " AND CONSECUTIVO = " + LTRIM(STR( oMC:FieldGet(1) ))
         oApl:oOdbc:Execute( "DELETE FROM movto_d " + aBor )
         oApl:oOdbc:Execute( "DELETE FROM movto_c " + aBor )
      EndIf
      ::aCab[12] := .f.
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD CambiaFec() CLASS TAjuste
   LOCAL aFE, lSI := .t.
If EMPTY( ::aCab[2] )
   MsgStop( "No puede ir en Blanco","FECHA" )
   lSI := .f.
Else
   If ::aCab[1] > 0
      aFE := { ::oAju:FECHA,::aCab[2],1 }
      If CierreInv( aFE[1],"AJUSTES" )
         ::aCab[2] := aFE[1]
         ::oG[4]:Refresh()
         ::oG[4]:oJump := ::oG[2]
         ::oG[2]:SetFocus()
      Else
         If (LEFT( DTOS(aFE[1]),6 ) != LEFT( DTOS(aFE[2]),6 ))
            ::oAju:dbEval( {|o| aFE[3] := ::aCab[5][o:TIPO,2]                          ,;
                                Actualiz( o:CODIGO,-o:CANTIDAD,aFE[1],aFE[3],o:PCOSTO ),;
                                Actualiz( o:CODIGO, o:CANTIDAD,aFE[2],aFE[3],o:PCOSTO ),;
                                o:FECHA := ::aCab[2], o:Update( .f.,1 ) } )
         Else
            Guardar( "UPDATE cadajust SET fecha = " + xValToChar(::aCab[2])+;
                    " WHERE optica = " + LTRIM(STR(oApl:nEmpresa))         +;
                      " AND numero = " + LTRIM(STR(::aCab[1])),"cadajust" )
         EndIf
         ::aCab[2] := aFE[1]
         ::Borrar( ,0 )
         ::aCab[2] := aFE[2]
         MsgInfo( "El cambio de Fecha","HECHO" )
      EndIf
   EndIf
   ::aCab[13]:= NtChr( ::aCab[2],"1" )
EndIf
RETURN lSI

//------------------------------------//
METHOD Editar( oLbx,lNew ) CLASS TAjuste
   LOCAL oDlg, oGet := ARRAY(8), bGrabar, oE := Self
   LOCAL cTit := "Modificando Ajuste"
lNew := If( ::aCab[4] <= 0, .t., lNew )
If CierreInv( ::aCab[2],"AJUSTES" )
   RETURN NIL
ElseIf lNew
   cTit    := "Nuevo Ajuste"
   bGrabar := {|| ::Grabar( oLbx,lNew )         ,;
                  ::oAju:xBlank(), ::aCab[4] ++ ,;
                  oDlg:Update(), oDlg:SetFocus() }
   oLbx:GoBottom() ; ::oAju:xBlank()
Else
   bGrabar := {|| ::Grabar( oLbx,lNew ), oLbx:Refresh(), oDlg:End() }
   ::aCab[07] := ::oAju:CODIGO
   ::aCab[08] := ::oAju:TIPO
   ::aCab[09] := ::oAju:CANTIDAD
   ::aCab[10] := ::oAju:PCOSTO
EndIf
oApl:oInv:Seek( {"codigo",::oAju:CODIGO} )
oApl:aInvme[1] := 0
DEFINE DIALOG oDlg TITLE cTit + STR(::aCab[4]) FROM 0, 0 TO 11,46
   @ 02,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 66,10
   @ 02,70 BTNGET oGet[1] VAR oE:oAju:CODIGO OF oDlg PICTURE "999999999!!!";
      VALID If( oE:Buscar( oE:oAju:CODIGO,lNew )      ,;
              ( SaldoInv( oE:oAju:CODIGO,::aCab[13] ) ,;
                oE:oAju:PCOSTO := oApl:aInvme[2]      ,;
                oE:oAju:PVENTA := oApl:oInv:PVENTA    ,;
                oDlg:Update(), .t.), .f. )             ;
      SIZE 56,10 PIXEL  RESOURCE "BUSCAR"              ;
      ACTION EVAL({|| If(oE:oCA:Mostrar(), (oE:oAju:CODIGO := oE:oCA:oDb:CODIGO,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
   @ 14, 50 SAY   oGet[2] VAR oApl:oInv:DESCRIP OF oDlg PIXEL SIZE 90,12 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 28, 00 SAY "Cantidad" OF oDlg RIGHT PIXEL SIZE 66,8
   @ 28, 70 GET oGet[3] VAR ::oAju:CANTIDAD OF oDlg PICTURE "9,999";
      VALID {|| If( ::oAju:CANTIDAD <= 0, ;
          (MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>" ), .f.),;
          (If( oApl:oInv:GRUPO == "1" .AND. ::oAju:CANTIDAD > 1,;
          (MsgStop( "En Montura la Cantidad debe ser 1","<< OJO >>"),.f.), .t. ))) };
      SIZE 40,10 PIXEL UPDATE
   @ 28,120 SAY oGet[4] VAR oApl:aInvme[1] OF oDlg PIXEL SIZE 40,10 PICTURE "[9,999]";
      UPDATE COLOR "GR/W"
   @ 40, 00 SAY "Tipo de Ajuste" OF oDlg RIGHT PIXEL SIZE 66,8
   @ 40,70 COMBOBOX oGet[5] VAR ::oAju:TIPO ITEMS ArrayCol( ::aCab[5],1 ) SIZE 68,99 ;
      OF oDlg PIXEL UPDATE ;
      VALID {|| If( oApl:oInv:GRUPO == "1", ;
          (If( ::oAju:TIPO == 1 .AND. oApl:aInvme[1] > 0,;
             (MsgStop("No Puedo hacer Ajuste-Sobrante con Existencia"),.f.),;
           If( ::oAju:TIPO >= 2 .AND. oApl:aInvme[1] = 0,;
             (MsgStop("No Puedo hacer Ajuste-Faltante sin Existencia"),.f.),;
               .t. ))), .t.) }
   @ 52,00 SAY "Precio Costo"  OF oDlg RIGHT PIXEL SIZE 66,10
   @ 52,70 GET oGet[6] VAR ::oAju:PCOSTO   OF oDlg PICTURE "999,999,999.99";
      SIZE 40,10 PIXEL UPDATE
   @ 66, 70 BUTTON oGet[7] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION;
      (If( EMPTY(::oAju:CODIGO) .OR. ::oAju:CANTIDAD <= 0       ,;
         (MsgStop("Imposible grabar este AJUSTE"), oGet[1]:SetFocus()),;
          EVAL(bGrabar) )) PIXEL
   @ 66,120 BUTTON oGet[8] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
   If !::aPrv[1]
      oGet[7]:Disable()
   EndIf
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
RETURN NIL

//------------------------------------//
METHOD Grabar( oLbx,lNew ) CLASS TAjuste

If lNew
   If ::aCab[1] == 0
      ::aCab[1] := SgteNumero( "ajustes",oApl:nEmpresa,.t. )
      ::aCab[6] := ::aCab[1] + 1
      ::oG[2]:Refresh()
      ::oG[3]:Refresh()
   EndIf
   ::aCab[12]    := .t.
   ::oAju:OPTICA := oApl:nEmpresa
   ::oAju:NUMERO := ::aCab[1]
   ::oAju:FECHA  := ::aCab[2]
   ::oAju:SECUENCIA := ++::nSec
   ::oAju:Append( .t. )
   ::Ajustar( ::oAju:CODIGO,::oAju:TIPO,::oAju:CANTIDAD,::oAju:PCOSTO )
   ::oG[5]:Refresh()
   PListbox( oLbx,::oAju )
Else
   If ::aCab[07] # ::oAju:CODIGO   .OR.;
      ::aCab[08] # ::oAju:TIPO     .OR.;
      ::aCab[09] # ::oAju:CANTIDAD .OR.;
      ::aCab[10] # ::oAju:PCOSTO
      ::Ajustar( ::aCab[07],::aCab[08],-::aCab[09],::aCab[10] )
      ::aCab[09] := 0
      ::aCab[12] := .t.
      If ::oAju:INDICA == "E"
         ::oAju:INDICA := "C"
      EndIf
   EndIf
   ::oAju:Update( .t.,1 )
   ::Ajustar( ::oAju:CODIGO,::oAju:TIPO,::oAju:CANTIDAD-::aCab[09],::oAju:PCOSTO )
EndIf
RETURN NIL

//------------------------------------//
METHOD Ajustar( cCodi,nMov,nCanti,nPC ) CLASS TAjuste
   LOCAL aD := { 0,0,CTOD(""),"E" }
If !oApl:oEmp:TACTUINV .AND.;
   nCanti # 0 .AND. LEFT( cCodi,2 ) # "05"
   nMov := ::aCab[5][nMov,2]       //5_Sobrante, 6_Faltante y Robo
   oApl:oInv:Seek( {"codigo",cCodi} )
   If oApl:oInv:GRUPO == "1" .AND. oApl:oInv:OPTICA == oApl:nEmpresa
      If nMov == 6 .AND. nCanti > 0
         aD := { ::oAju:PCOSTO,::aCab[1],::aCab[2],"V" }
      EndIf
      oApl:oInv:PVENDIDA := aD[1]; oApl:oInv:FACTUVEN  := aD[2]
      oApl:oInv:FECVENTA := aD[3]; oApl:oInv:SITUACION := aD[4]
      oApl:oInv:Update( .f.,1 )
   EndIf
   Actualiz( cCodi,nCanti,::aCab[2],nMov,nPC )
EndIf
RETURN NIL

//------------------------------------//
PROCEDURE InoLiAju()
   LOCAL oDlg, oGet := ARRAY(9)
   LOCAL aAju := { DATE(),DATE(),"S",oApl:nUS,0,"S",.f. }
DEFINE DIALOG oDlg FROM 0, 0 TO 180,370 PIXEL;
   TITLE "Listo los Ajustes al Inventario"
   @ 02, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02, 92 GET oGet[1] VAR aAju[1] OF oDlg  SIZE 44,10 PIXEL
   @ 14, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 14, 92 GET oGet[2] VAR aAju[2] OF oDlg ;
      VALID aAju[2] >= aAju[1] SIZE 44,10 PIXEL
   @ 26, 00 SAY "CON PRECIO DE COSTO S/N"  OF oDlg RIGHT PIXEL SIZE 90,10
   @ 26, 92 GET oGet[3] VAR aAju[3] OF oDlg PICTURE "!"    SIZE 10,10 PIXEL;
      VALID aAju[3] $ "SN"
   @ 38, 00 SAY "VALOR  DEL  DOLAR" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 38, 92 GET oGet[4] VAR aAju[4] OF oDlg PICTURE "9,999" SIZE 30,10 PIXEL
   @ 50, 00 SAY "DOCUMENTO Default Todos"  OF oDlg RIGHT PIXEL SIZE 90,10
   @ 50, 92 GET oGet[5] VAR aAju[5] OF oDlg PICTURE "99999999" SIZE 44,10 PIXEL
   @ 62, 00 SAY "# DE AJUSTES SEPARADOS"   OF oDlg RIGHT PIXEL SIZE 90,10
   @ 62, 92 GET oGet[6] VAR aAju[6] OF oDlg PICTURE "!" ;
      VALID If( aAju[6] $ "SN", .t., .f. )   SIZE 08,10 PIXEL
   @ 62,140 CHECKBOX oGet[7] VAR aAju[7] PROMPT "Vista Previa" OF oDlg ;
      SIZE 60,10 PIXEL
   @ 76, 70 BUTTON oGet[8] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[8]:Disable(), ListAjus( aAju ), oDlg:End() ) PIXEL
   @ 76,120 BUTTON oGet[9] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION ( oDlg:End() ) PIXEL
   @ 82, 02 SAY "[INOAJUST]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
STATIC PROCEDURE ListAjus( aLS )
   LOCAL aAju, aGrp, aLis, nC, nL, nK, hRes, oRpt
aLis := "SELECT a.codigo, a.cantidad, a.tipo, a.pcosto, a.pventa"+;
             ", i.grupo, i.descrip, i.moneda, a.numero, a.fecha "+;
        "FROM cadinven i, cadajust a "             +;
        "WHERE a.codigo = i.codigo"                +;
         " AND a.optica = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND a.fecha >= " + xValToChar( aLS[1] ) +;
         " AND a.fecha <= " + xValToChar( aLS[2] ) + If( aLS[5] > 0,;
         " AND a.numero = " + LTRIM(STR(aLS[5])), "" ) +;
         " AND a.indica <> 'B' ORDER BY a.numero, a.codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,aLis ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgStop( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN
EndIf
 aLis := MyReadRow( hRes )
 AEVAL( aLis, { | xV,nP | aLis[nP] := MyClReadCol( hRes,nP ) } )
 aLS[3] := If( aLS[3] == "S", 1,0 )
 aLS[5] := 0
 aAju := { 0,0,0,0,0,0,0,0,0,0,aLis[6] }
 aGrp := ArrayCombo( "GRUPO" )
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"AJUSTES AL INVENTARIO","" ,;
          "  NUMERO   F E C H A  C O D I G O-  D E S C R I P C "+;
          "I O N---------  FALTANTE  SOBRANTE   PRECIO COSTO  PRECIO VENTA"},aLS[7],1,2 )
While nL > 0
   aLis[4] := Dolar_Peso( aLS[2],aLis[4],aLis[8] ) * aLS[3]
   If aLis[3] >= 2
      nC := 71 ; nK := 1
   Else
      nC := 80 ; nK := 4
   EndIf
   oRpt:Titulo( 115 )
   If aLS[5]  # aLis[9]
      aLS[5] := aLis[9]
      oRpt:Say( oRpt:nL,00,STR(aLis[9],8) )
      oRpt:Say( oRpt:nL,09,NtChr( aLis[10],"2" ) )
   EndIf
   oRpt:Say( oRpt:nL, 22,aLis[1] )
   oRpt:Say( oRpt:nL, 36,aLis[7] )
   oRpt:Say( oRpt:nL, nC,TRANSFORM(aLis[2],"9,999" ))
   oRpt:Say( oRpt:nL, 87,TRANSFORM(aLis[4],"999,999,999.99" ))
   oRpt:Say( oRpt:nL,104,TRANSFORM(aLis[5],"999,999,999" ))
   oRpt:nL ++
   aAju[nK]   +=  aLis[2]
   aAju[nK+1] += (aLis[2] * aLis[4])
   aAju[nK+2] += (aLis[2] * aLis[5])
   If (nL --) > 1
      aLis := MyReadRow( hRes )
      AEVAL( aLis, { | xV,nP | aLis[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aAju[11] # aLis[6]
      SubTotal( oRpt,@aAju,aGrp,.f. )
      aAju[11] := aLis[6]
   EndIf
   If nL == 0 .OR. (aLS[5] # aLis[9] .AND. aLS[6] == "S")
      SubTotal( oRpt,@aAju,aGrp,.t. )
   EndIf
EndDo
MSFreeResult( hRes )
   oRpt:End()
RETURN

//------------------------------------//
STATIC PROCEDURE SubTotal( oRpt,aAju,aGrp,lFin )
If lFin
   oRpt:Titulo( 115 )
   oRpt:Say(  oRpt:nL, 36,"TOTAL FALTANTES",,,1 )
   oRpt:Say(  oRpt:nL, 85,TRANSFORM(aAju[07],"9,999,999,999.99" ))
   oRpt:Say(  oRpt:nL,102,TRANSFORM(aAju[08],"9,999,999,999" ))
   oRpt:Say(++oRpt:nL, 36,"TOTAL SOBRANTES",,,1 )
   oRpt:Say(  oRpt:nL, 85,TRANSFORM(aAju[09],"9,999,999,999.99" ))
   oRpt:Say(  oRpt:nL,102,TRANSFORM(aAju[10],"9,999,999,999" ))
   oRpt:NewPage()
   oRpt:nPage := 0
   oRpt:nL    := oRpt:nLength + 1
   AFILL( aAju,0,7,4 )
Else
   If aAju[1] > 0 .OR. aAju[4] > 0
      aAju[11] := ArrayValor( aGrp,aAju[11] )
      oRpt:Say(  oRpt:nL, 35,REPLICATE("_",80),,,1 )
      oRpt:Say(++oRpt:nL, 36,"TOTAL " + aAju[11],,,1 )
      oRpt:Say(  oRpt:nL, 71,TRANSFORM(aAju[1],"9,999" ))
      oRpt:Say(  oRpt:nL, 85,TRANSFORM(aAju[2],"9,999,999,999.99" ))
      oRpt:Say(  oRpt:nL,102,TRANSFORM(aAju[3],"9,999,999,999" ))
      oRpt:Say(++oRpt:nL, 80,TRANSFORM(aAju[4],"9,999" ),,,1)
      oRpt:Say(  oRpt:nL, 85,TRANSFORM(aAju[5],"9,999,999,999.99" ))
      oRpt:Say(  oRpt:nL,102,TRANSFORM(aAju[6],"9,999,999,999" ))
      oRpt:Say(++oRpt:nL, 35,REPLICATE("_",80),,,1 )
      oRpt:nL += 2
      aAju[07] += aAju[2]
      aAju[08] += aAju[3]
      aAju[09] += aAju[5]
      aAju[10] += aAju[6]
   EndIf
   AFILL( aAju,0,1,6 )
EndIf
RETURN