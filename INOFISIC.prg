// Programa.: INOFISIC.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Capturar el Inventario Fisico.
#include "FiveWin.ch"
//#include "btnget.ch"
//#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE InvFisico()
   LOCAL oA, oDlg, oLbx, oGet := ARRAY(6), lSalir := .f.
   LOCAL aBarra, aGrup := ArrayCombo( "GRUPO     " )
oA := TFisico() ; oA:NEW()
aBarra := { {|| oA:Editar( oLbx,.t. ) }, {|| oA:Editar( oLbx,.f. ) },;
            {|| oC:ArmarInf() }        , {|| oA:Borrar( oDlg,oLbx ) },;
            {|| oC:Ajustes(),  oC:::aLS[1] := 0, oGet[1]:SetFocus() },;
            {|| lSalir := .t., oA:oDlg:End() } }

aBarra := { {|| ReposEdita( oLbx,@oA:aLS,.t. ) },;
            {|| ReposEdita( oLbx,@oA:aLS,.f. ) },;
            {|| .t. }                    ,;
            {|| ReposBorra( oDlg,oLbx ) },;
            {|| ListoTot( oA:aLS,aGrup ) } ,;
            {|| lSalir := .t., oDlg:End() } }
DEFINE DIALOG oDlg FROM 0, 0 TO 330, 510 PIXEL;
   TITLE "Arqueos Fisicos de la Optica"
   @ 02, 00 SAY "Optica" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02, 92 GET oGet[1] VAR oA:aLS[1] OF oDlg PICTURE "@!"         ;
      VALID EVAL( {|| If( Busqueda( oApl:oEmp,oA:aLS[1] )         ,;
                      (oApl:nEmpresa := oApl:oEmp:OPTICA, .t. )   ,;
                      (MsgStop("Esta Optica NO EXISTE"), .f.) ) } );
      SIZE 26,12 PIXEL
   @ 02,120 SAY "GRUPO DESEADO"       OF oDlg RIGHT PIXEL SIZE 70,10
   @ 02,192 COMBOBOX oGet[2] VAR oA:aLS[2] ITEMS ArrayCol( aGrup,1 ) SIZE 50,99 ;
      OF oDlg PIXEL
   @ 16, 00 SAY "DIGITE AÑO Y MES [AAMM]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 16, 92 GET oGet[3] VAR oA:aLS[3] OF oDlg SIZE 30,12 PIXEL;
      VALID NtChr( oA:aLS[3],"P" )
   @ 16,152 CHECKBOX oGet[4] VAR oA:aLS[7] PROMPT "Codigo de Barra" OF oDlg ;
      WHEN oA:aLS[2] == 5  SIZE 60,12 PIXEL
   @ 30, 00 SAY "Nro. de Vitrina" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 30, 92 GET oGet[5] VAR oA:aLS[4] OF oDlg  PICTURE "@!!!";
      VALID EVAL( {|| oC:aLS[8] := aGrup[ oC:aLS[2],2 ]     ,;
                      oC:Buscar( oLbx,oGet ), .t. } )        ;
      SIZE 30,12 PIXEL UPDATE
   @ 30,152 SAY "Total Vitrina"   OF oDlg RIGHT PIXEL SIZE 60,10
   @ 30,216 SAY oGet[6] VAR oA:oArc:TVITRINA OF oDlg SIZE 40,12 PIXEL ;
      UPDATE COLOR nRGB( 255,0,0 )

   @ 62,10 LISTBOX oLbx FIELDS oC:oArd:CODIGO            ,;
                    TRANSFORM( oC:oArd:CANTIDAD,"99,999" );
      HEADERS "Código"+CRLF+"Artículo", "Cantidad";
      SIZES 180, 100 SIZE 280,86 ;
      OF oDlg UPDATE PIXEL       ;
      ON DBLCLICK EVAL( aBarra[2] )
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:nHeaderHeight := 28
    oLbx:GoTop()
    oLbx:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:aColSizes   := {120,80}
    oLbx:aHjustify   := {2,2}
    oLbx:aJustify    := {0,1}
    oLbx:ladjbrowse  := oLbx:lCellStyle  := .f.
    oLbx:ladjlastcol := .t.
    oLbx:bKeyDown := {|nKey| If(nKey == VK_ESCAPE, ( oGet[1]:SetFocus() ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(aBarra[1]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, EVAL(aBarra[2]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, EVAL(aBarra[4]),) ))) }
   MySetBrowse( oLbx, oA:oArd )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT;
  (oDlg:Move(80,1) ,;
   DefineBar( oDlg,oLbx,aBarra,90,18 ), oA:aLS[6] := oDlg);
   VALID lSalir
oA:oArc:Destroy()
oA:oArd:Destroy()
RETURN

//------------------------------------//
CLASS TFisico FROM TIMPRIME

 DATA aLS, lNew, oArc, oArd

 METHOD NEW( nX ) Constructor
 METHOD Buscar( oLbx,oGet )
 METHOD Borrar( oDlg,oLbx )
 METHOD Editar( oLbx,lNew )
 METHOD Graba( oDlg,oGet,bGrabar )
 METHOD Grabar( oLbx )
 METHOD ListoArq( oDlg )
 METHOD LaserArq( cQry,oDlg )
 METHOD ListoCod()
 METHOD LaserCod( hRes )
 METHOD Memo( nH,cQry )
ENDCLASS

//------------------------------------//
METHOD NEW( nX ) CLASS TFisico
If nX == NIL
   ::aLS  := { "   ",1,NtChr( DATE()-DAY(DATE()),"1" ),"   ",0,"",.t.,"1","",0 }
   ::oArc := oApl:Abrir( "fisicoc","optica, anomes, vitrina",.t.,,50 )
   ::oArd := oApl:Abrir( "fisicod","fisicoc_id",,,100 )
   ::oArd:Seek( { "fisicoc_id",0 } )
Else
  ::aEnc:= { .t., oApl:cEmpresa, oApl:oEmp:Nit,;
             "ARQUEO FISICO DEL INVENTARIO DE ","EN "+NtChr( NtChr( ::aLS[1],"F" ),"6" ),;
             { .F., 0.5,"","C O D I G O" }    , { .F., 2.4,"","D E S C R I P C I O N" } ,;
             { .T., 7.2,"Saldo"  ,"Anterior" }, { .T., 8.4,"Total"  ,"Entradas" },;
             { .T., 9.6,"Total"  ,"Ventas" }  , { .T.,10.8,"Devoluc","Entrada" } ,;
             { .T.,12.0,"Devoluc","Salida" }  , { .T.,13.2,"Ajuste" ,"Entrada" } ,;
             { .T.,14.4,"Ajuste" ,"Salida" }  , { .T.,15.6,"Devoluc","Cliente" } ,;
             { .T.,16.9,"Saldo"  ,"Actual" }  , { .T.,18.2,"Arqueo" ,"Fisico" }  ,;
             { .T.,19.5,"","Faltante" }       , { .T.,20.8,"","Sobrante" } }
//epsonlx-300II server
EndIf
RETURN NIL

//------------------------------------//
METHOD Buscar( oLbx,oGet ) CLASS TFisico
   LOCAL lSi := .f.
If VALTYPE( oGet ) == "L"
   If (lSi := oApl:oInv:Seek( {"codigo",::oArd:CODIGO} ))
      If LEFT( ::oArd:CODIGO,2 ) == "01"
         MsgStop( "Monturas no es por AQUI" )
         lSi := .f.
      ElseIf oGet
         ::oArd:CANTIDAD := oApl:oInv:PAQUETE
         ::oArd:PCOSTO   := oApl:oInv:PCOSTO
         ::oArd:PVENTA   := oApl:oInv:PVENTA
         ::oArd:INDIVA   := oApl:oInv:INDIVA
      EndIf
      oLbx:Update()
   Else
      MsgStop( "Este Código NO EXISTE !!!" )
   EndIf
Else
   If ::oArc:Seek( {"optica",oApl:nEmpresa,"anomes",::aLS[3],"vitrina",::aLS[4],"grupo",::aLS[8]} )
      oGet[5]:oJump := oLbx
      ::aLS[5] := ::oArc:ROW_ID
      //::aLS[5] := Buscar( {"fisicoc_id",::oArc:ROW_ID},"fisicod","SUM(cantidad)" )
   Else
      ::aLS[5] := 0
   EndIf
      ::oArd:Seek( { "fisicoc_id",::aLS[5] } )
      oGet[6]:Refresh()
      oLbx:Refresh()
      lSi := .t.
   EndIf
EndIf
RETURN lSi


//------------------------------------//
METHOD Borrar( oDlg,oLbx ) CLASS TFisico
   LOCAL aBor
If ::oArc:TVITRINA > 0
   If MsgNoYes( "Este Código "+::oArd:CODIGO,"Elimina" )
      aBor := { ::oArd:CANTIDAD,.f. }
      If (aBor[2] := ::oArd:Delete( .t.,1 ))
         PListbox( oLbx,::oArd )
      EndIf
      If aBor[2]
         ::oArc:TVITRINA -= aBor[1]
         ::oArc:Update( .f.,1 )
      EndIf
      oDlg:Update()
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Editar( oLbx,lNew ) CLASS TFisico
   LOCAL bGrabar, oDlg, oGet := ARRAY(4), cText := "Modificando Código"
   ::lNew := If( ::oArc:TVITRINA == 0, .t., lNew )
If ::lNew
   cText := "Nuevo Código"
   bGrabar := {|| ::Grabar( oLbx )              ,;
                  ::oArd:xBlanK()               ,;
                  oDlg:Update(), oDlg:SetFocus(),;
                  oGet[1]:SetFocus() }
   oLbx:GoBottom()
   ::oArd:xBlank() ; ::oArd:CANTIDAD := 1
Else
   bGrabar  := {|| ::Grabar( oLbx,lNew ), oLbx:Refresh(), oDlg:End() }
EndIf
   ::aLS[09]:= ::oArd:CODIGO
   ::aLS[10]:= ::oArd:CANTIDAD
DEFINE DIALOG oDlg TITLE cText FROM 0, 0 TO 07,40
   @ 02,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 60,10
   @ 02,62 GET oGet[1] VAR ::aLS[9] OF oDlg PICTURE "@K9";
      VALID Graba( oDlg,oGet,bGrabar ) SIZE 56,12 PIXEL UPDATE
   @ 16,00 SAY "Cantidad" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 16,62 GET oGet[2] VAR ::oArd:CANTIDAD OF oDlg PICTURE "9,999";
      VALID {|| If( ::oArd:CANTIDAD >  0, .t.                    ,;
        (MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>" ), .f.)) };
      WHEN ::aLS[8] # "1" SIZE 40,12 PIXEL UPDATE
   @ 32, 50 BUTTON oGet[3] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION ;
      (If( EMPTY( ::aLS[09] ) .OR. ::oArd:CANTIDAD <= 0               ,;
         (MsgStop("Imposible grabar este Código"), oGet[1]:SetFocus()),;
          EVAL(bGrabar) )) PIXEL
   @ 32,100 BUTTON oGet[4] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(260,230)
RETURN NIL

//------------------------------------//
METHOD Graba( oDlg,oGet,bGrabar ) CLASS TFisico
   LOCAL lSi := .t.
If ::aLS[8] == "6" .AND. ::aLS[7]
   If !(lSi := oApl:oPte:Seek( oApl:oArd:CODIGO ))
      If MsgYesNo( "Desea Crearlo","Código no Existe" )
         CodBarra( ::oArd:CODIGO )
         lSi := oApl:oPte:Seek( oApl:oArd:CODIGO )
      EndIf
   EndIf
   If lSi
      oApl:oArd:CODIGO := oApl:oPte:CODIGO
      oDlg:Update()
   EndIf
ElseIf ::aLS[8] == "1" .AND. !EMPTY(::aLS[8])
   ::oArd:CANTIDAD := 1
   EVAL(bGrabar)
   ::aLS[09]       := SPACE(12)
   lSi := .f.
EndIf
RETURN lSi

//------------------------------------//
METHOD Grabar( oLbx ) CLASS TFisico

If ::aLS[5] == 0
   ::oArc:OPTICA  := oApl:nEmpresa
   ::oArc:ANOMES  := ::aLS[3]
   ::oArc:VITRINA := ::aLS[4]
   ::oArc:GRUPO   := ::aLS[8]
   ::oArc:Append( .t. )
   ::aLS[5]       := ::oArc:ROW_ID
EndIf

If ::lNew
   ::aLS[10] := ::oArd:CANTIDAD
   ::oArd:FISICOC_ID := ::oArc:ROW_ID
   ::oArd:CODIGO     := ::aLS[9]
   ::oArd:Append( .t. )
   PListbox( oLbx,::oArd )
Else
   ::aLS[10] := ::oArd:CANTIDAD - ::aLS[10]
   ::oArd:CODIGO     := ::aLS[9]
   ::oArd:Update( .t.,1 )
EndIf
   ::oRpc:TVITRINA += aLS[10]
   ::oArc:Update( .f.,1 )
   ::aLS[6]:Update()
RETURN NIL

//------------------------------------//
PROCEDURE ListoTot( aLS,aGrup )
   LOCAL oDPrn, aGT := ARRAY(7), nK, nReg := FisC->(Recno())
oDPrn := TDosPrint():New( oApl:cPuerto,oApl:cImpres,{"TOTAL DE INVENTARIO",;
         "EN " + NtChr( NtChr( aLS[3],"F" ),"6" ),;
         "          VITRINA     CANTIDAD" },.t. )
AFILL( aGt,0 )
FisC->(dbSeek( STR(oApl:nEmpresa) + aLS[3],.t. ))
While FisC->OPTICA == oApl:nEmpresa .AND. ;
      FisC->ANOMES == aLS[3]        .AND. !FisC->(EOF())
   nK := ArrayValor( aGrup,FisC->GRUPO,,.t. )
   oDPrn:Titulo( 80 )
   oDPrn:Say( oDPrn:nL,12,FisC->VITRINA )
   oDPrn:Say( oDPrn:nL,23,TransForm(FisC->TVITRINA,"999,999") )
   oDPrn:Say( oDPrn:nL,32,aGrup[ nK,1 ] )
   oDPrn:nL++
   aGT[nK] += FisC->TVITRINA
   FisC->(dbSkip())
EndDo
oDPrn:Say( oDPrn:nL, 00,Replicate("_",80),,,1 )
FOR nK := 1 TO 7
   If aGt[nK] > 0
      oDPrn:Say(++oDPrn:nL,10,aGrup[ nK,1 ],,,1 )
      oDPrn:Say(  oDPrn:nL,23,TransForm(aGT[nK],"999,999" ) )
   EndIf
NEXT
oDPrn:NewPage()
oDPrn:End()
oApl:oRpc:Go(nReg)
RETURN
