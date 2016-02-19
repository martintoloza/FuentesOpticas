// Programa.: INOFISIC.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Capturar el Inventario Fisico.
#include "FiveWin.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE InvFisico()
   LOCAL oA, oDlg, oLbx, oGet := ARRAY(6), lSalir := .f.
   LOCAL aBarra, aGrup := ArrayCombo( "GRUPO     " )
oA := TFisico() ; oA:NEW()
aBarra := { {|| oA:Editar( oLbx,.t. ) }, {|| oA:Editar( oLbx,.f. ) } ,;
            {|| oA:Diskette() }        , {|| oA:Borrar( oDlg,oLbx ) },;
            {|| oA:ListoTot( aGrup ), oGet[1]:SetFocus() }           ,;
            {|| lSalir := .t., oDlg:End() } }
DEFINE DIALOG oDlg FROM 0, 0 TO 330, 510 PIXEL;
   TITLE "Arqueos Fisicos de la Optica"
   @ 16, 00 SAY "Optica" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 16, 92 GET oGet[1] VAR oA:aLS[1] OF oDlg PICTURE "@!"           ;
      VALID EVAL( {|| If( oApl:oEmp:Seek( {"localiz",oA:aLS[1]} )   ,;
                        ( oApl:nEmpresa := oApl:oEmp:OPTICA, .t. )  ,;
                        (MsgStop("Esta Optica NO EXISTE"), .f.) ) } );
      SIZE 24,10 PIXEL
   @ 16,120 SAY "GRUPO DESEADO"       OF oDlg RIGHT PIXEL SIZE 70,10
   @ 16,192 COMBOBOX oGet[2] VAR oA:aLS[2] ITEMS ArrayCol( aGrup,1 ) SIZE 50,99 ;
      OF oDlg PIXEL
   @ 28, 00 SAY "DIGITE AÑO Y MES [AAMM]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 28, 92 GET oGet[3] VAR oA:aLS[3] OF oDlg SIZE 30,10 PIXEL;
      VALID NtChr( oA:aLS[3],"P" )
   @ 28,152 CHECKBOX oGet[4] VAR oA:aLS[7] PROMPT "Codigo de Barra" OF oDlg ;
      WHEN oA:aLS[2] == 5  SIZE 60,12 PIXEL
   @ 40, 00 SAY "Nro. de Vitrina" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 40, 92 GET oGet[5] VAR oA:aLS[4] OF oDlg  PICTURE "@!!!";
      VALID EVAL( {|| oA:aLS[8] := aGrup[ oA:aLS[2],2 ]     ,;
                      oA:Buscar( oLbx,oGet ), .t. } )        ;
      SIZE 30,10 PIXEL UPDATE
   @ 40,152 SAY "Total Vitrina"   OF oDlg RIGHT PIXEL SIZE 60,10
   @ 40,216 SAY oGet[6] VAR oA:oArc:TVITRINA OF oDlg SIZE 40,10 PIXEL ;
      UPDATE COLOR nRGB( 255,0,0 )

   @ 62,50 LISTBOX oLbx FIELDS oA:oArd:CODIGO            ,;
                    TRANSFORM( oA:oArd:CANTIDAD,"99,999" );
      HEADERS "Código"+CRLF+"Artículo", "Cantidad";
      SIZES 400, 450 SIZE 150,86 ;
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
    oLbx:aColSizes   := {90,80}
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
   DefineBar( oDlg,oLbx,aBarra ), oA:aLS[6] := oDlg);
   VALID lSalir
oA:oArc:Destroy()
oA:oArd:Destroy()
oA:oCod:Destroy()
RETURN

//------------------------------------//
CLASS TFisico FROM TIMPRIME

 DATA aLS, lNew, oArc, oArd, oCod

 METHOD NEW( nX,cRut ) Constructor
 METHOD Buscar( oLbx,oGet )
 METHOD Borrar( oDlg,oLbx )
 METHOD Editar( oLbx,lNew )
 METHOD Graba( oDlg,oGet )
 METHOD Grabar( oLbx )
 METHOD GrabaCod( sCodB )
 METHOD Diskette()
 METHOD Espejo( aLS )
 METHOD ListoTot( aGrup )
 METHOD LaserTot( aGrup,aGT,hRes,nL )
ENDCLASS

//------------------------------------//
METHOD NEW( nX,cRut ) CLASS TFisico
If nX == NIL
   ::aLS  := { "   ",1,NtChr( DATE()-DAY(DATE()),"1" ),"   ",0,"",.t.,"1","",0 }
   ::oArc := oApl:Abrir( "fisicoc","optica, anomes, vitrina",.t.,,50 )
   ::oArd := oApl:Abrir( "fisicod","fisicoc_id",,,100 )
   ::oArd:Seek( { "fisicoc_id",0 } )
   ::oCod := oApl:Abrir( "cadcodig","codbarra",,,10 )
ElseIf VALTYPE( nX ) == "C"
      ::aLS[9] := ""
   If cRut # NIL
      ::aLS[9] := STRTRAN( oApl:cRuta1,"Bitmap",cRut )
   EndIf
   cRut := AbrirFile( 1,::aLS[9],nX )
   If (nX := RAT( "\", cRut )) > 0
      cRut := LEFT( cRut,nX )
   Else
      cRut := ::aLS[9]
   EndIf
Else
  ::aEnc:= { .t., oApl:cEmpresa, oApl:oEmp:Nit,;
             "TOTAL DE INVENTARIO","EN "+NtChr( NtChr( ::aLS[3],"F" ),"6" ),;
             { .F.,06.0,"VITRINA" }, { .T.,11.0,"CANTIDAD" } }
EndIf
RETURN cRut

//------------------------------------//
METHOD Buscar( oLbx,oGet ) CLASS TFisico
   LOCAL lSi := .f.
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
   bGrabar := {|| ::Grabar( oLbx )             ,;
                  ::oArd:xBlanK()              ,;
                  If( ::aLS[8] == "1"          ,;
                  oGet[1]:Settext(SPACE(12)), ),;
                  oDlg:Update()                ,;
                  oDlg:SetFocus()              ,;
                  oGet[3]:oJump := oGet[1]     ,;
                  oGet[1]:SetFocus() }
   oLbx:GoBottom()
   ::oArd:xBlank()
Else
   bGrabar  := {|| ::Grabar( oLbx ), oLbx:Refresh(), oDlg:End() }
   ::aLS[10]:= -::oArd:CANTIDAD
EndIf
   ::aLS[09]:= ::oArd:CODIGO
DEFINE DIALOG oDlg TITLE cText FROM 0, 0 TO 07,40
   @ 02,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 60,10
   @ 02,62 GET oGet[1] VAR ::aLS[9] OF oDlg PICTURE "999999999!!!";
      VALID ::Graba( oDlg,oGet ) SIZE 56,12 PIXEL UPDATE
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
METHOD Graba( oDlg,oGet ) CLASS TFisico
   LOCAL lSi := .t.
If ::aLS[8] == "6" .AND. ::aLS[7]
   If !(lSi := ::oCod:Seek( {"codbarra",::aLS[9]} ))
      If MsgYesNo( "Desea Crearlo","Código no Existe" )
         ::GrabaCod( ::aLS[9] )
         lSi := ::oCod:Seek( {"codbarra",::aLS[9]} )
      EndIf
   EndIf
   If lSi
      ::aLS[9] := ::oCod:CODIGO
      oDlg:Update()
   EndIf
ElseIf ::aLS[8] == "1" .AND. !EMPTY(::aLS[9])
   If Buscar( {"fisicoc_id",::aLS[5],"codigo",::aLS[9]},"fisicod","1",8,,4 ) == 0
      ::oArd:CANTIDAD := 1
      oGet[3]:Click()
   Else
      oGet[1]:Settext (SPACE(12) )
      lSi      := .f.
   EndIf
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
   ::oArd:CODIGO     := ::aLS[9]
If ::lNew
   ::aLS[10] := ::oArd:CANTIDAD
   ::oArd:FISICOC_ID := ::aLS[5]
   ::oArd:Append( .t. )
   PListbox( oLbx,::oArd )
Else
   ::aLS[10] += ::oArd:CANTIDAD
   ::oArd:Update( .t.,1 )
EndIf
   ::oArc:TVITRINA += ::aLS[10]
   ::oArc:Update( .f.,1 )
   ::aLS[6]:Update()
RETURN NIL

//------------------------------------//
METHOD GrabaCod( sCodB ) CLASS TFisico
   LOCAL bGrabar, lSi, oDlg, oGet := ARRAY(4)
bGrabar := {|| ::oCod:CODBARRA := sCodB       ,;
               If( lSi, ::oCod:Update( .t.,1 ),;
                        ::oCod:Append( .t. ) ),;
               sCodB := SPACE(12)             ,;
               oDlg:Update(), oDlg:SetFocus() }
DEFINE DIALOG oDlg TITLE "Códigos de Barra" FROM 0, 0 TO 07,40
   @ 02,00 SAY "Código Barra" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 02,62 GET oGet[1] VAR sCodB OF oDlg PICTURE "999999999!!!";
      VALID EVAL( {|| lSi := ::oCod:Seek( {"codbarra",sCodB} ),;
                      oDlg:Update(), .t. } ) SIZE 56,12 PIXEL UPDATE
   @ 16,00 SAY "Código Inven" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 16,62 GET oGet[2] VAR ::oCod:CODIGO OF oDlg PICTURE "999999999!!!";
      SIZE 56,12 PIXEL UPDATE
   @ 32, 50 BUTTON oGet[3] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION ;
      (If( EMPTY( sCodB ) .OR. LEN( ALLTRIM(::oCod:CODIGO) ) < 10     ,;
         (MsgStop("Imposible grabar este Código"), oGet[1]:SetFocus()),;
          EVAL(bGrabar) )) PIXEL
   @ 32,100 BUTTON oGet[4] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(260,230)
RETURN NIL

//------------------------------------//
METHOD Diskette() CLASS TFisico
   LOCAL oDlg, oGet := ARRAY(4), aCab := { ::aLS[1],::aLS[3],1 }
   LOCAL aGru := { "Todos","Monturas","Liquidos","Accesorios","L.Contacto" }
DEFINE DIALOG oDlg TITLE "Copiar a Diskette" FROM 0, 0 TO 08,40
   @ 02, 00 SAY "Optica" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 02, 92 GET oGet[1] VAR aCab[1] OF oDlg PICTURE "@!"             ;
      VALID EVAL( {|| If( oApl:oEmp:Seek( {"localiz",aCab[1]} )     ,;
                        ( oApl:nEmpresa := oApl:oEmp:OPTICA, .t. )  ,;
                        (MsgStop("Esta Optica NO EXISTE"), .f.) ) } );
      SIZE 26,12 PIXEL
   @ 16, 00 SAY "DIGITE AÑO Y MES [AAMM]" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 16, 92 GET oGet[2] VAR aCab[2] OF oDlg SIZE 30,12 PIXEL;
      VALID NtChr( aCab[2],"P" )
   @ 30, 00 SAY "GRUPO DESEADO"           OF oDlg RIGHT PIXEL SIZE 90,10
   @ 30, 92 COMBOBOX oGet[2] VAR aCab[3] ITEMS aGru SIZE 50,99 OF oDlg PIXEL
   @ 46, 50 BUTTON oGet[3] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION ;
      (aCab[3] := { "0","1","3","4","6" }[aCab[3]], ::Espejo( aCab ), oDlg:End() ) PIXEL
   @ 46,100 BUTTON oGet[4] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(260,230)
RETURN NIL

//------------------------------------//
METHOD Espejo( aLS ) CLASS TFisico
   LOCAL aRes, cRegis, cFile, cDir, hFile, hRes, nK, nL
aRes := "SELECT c.grupo, c.vitrina, d.codigo, d.cantidad "+;
        "FROM fisicod d, fisicoc c "                      +;
        "WHERE c.row_id = d.fisicoc_id"                   +;
         " AND c.optica = " + STR(oApl:nEmpresa,2)        +;
         " AND c.anomes = " + xValToChar( aLS[2] )        + If( aLS[3] == "0", "",;
         " AND c.grupo  = '"+ aLS[3] + "'" )              +;
         " ORDER BY c.grupo, c.vitrina"
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA GRABAR" )
   MSFreeResult( hRes )
   RETURN NIL
EndIf
cFile := "\" + CURDIR() + "\ARQUEO.TXT"
FERASE( cFile )
hFile := FCREATE( cFile,0 )
aLS[1]:= STR(oApl:nEmpresa,10) + " " + aLS[2] + " 0"
aLS[2]:= nL
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   cRegis := aLS[1] + aRes[1] + "   " + aRes[2] + " " +;
                      aRes[3] +     STR(aRes[4],8)
   FWRITE( hFile, cRegis + CRLF )
   nL --
EndDo
MSFreeResult( hRes )
FCLOSE( hFile )
cDir := ::NEW( "*.TXT","Arqueos" )
If LEFT(cDir,2) == "A:"
   If MsgYesNo( "Inserte un DISKETTE en la Unidad","Por Favor" )
      While .t.
         FCLOSE( FCREATE("a:\Check.Ctr", 0) )
         nK := FERROR()
         If nK == 5
            MsgStop("El disco está protegido contra escritura. Desprotéjalo y reintente." )
         ElseIf nK > 0
            MsgStop("Tengo problemas con el disquette o la Unidad. Por favor, compruébelos." )
         Else
            COPY FILE &(cFile) TO A:ARQUEO.TXT
            FERASE("A:\Check.Ctr")
            MsgInfo( "Arqueo con"+STR(aLS[2])+" Registros","Copia Hecha "+oApl:oEmp:LOCALIZ )
            EXIT
         EndIf
      EndDo
   EndIf
Else
   cRegis := cDir + "ARQUEO.TXT"
   FERASE( cRegis )
   COPY FILE &(cFile) TO &(cRegis)
   If cDir == ::aLS[9]
      MsgStop( "Está en la Carpeta "+ cDir,"El Archivo ARQUEO.TXT" )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD ListoTot( aGrup ) CLASS TFisico
   LOCAL aRes, aGT, hRes, nK, nL, oRpt
aRes := "SELECT vitrina, tvitrina, grupo "        +;
        "FROM fisicoc "                           +;
        "WHERE optica = " + STR(oApl:nEmpresa,2)  +;
         " AND anomes = " + xValToChar( ::aLS[3] )+;
         " ORDER BY grupo, vitrina"
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN NIL
EndIf
aGT  := { 0,0,0,0,0,0,0," " }
   ::NEW( 1 )
If oApl:nTFor == 2
   ::LaserTot( aGrup,aGT,hRes,nL )
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{ ::aEnc[4],::aEnc[5],;
          SPACE(20) + "VITRINA     CANTIDAD" },.t. )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   oRpt:Titulo( 80 )
   If aGT[8]  # aRes[3]
      aGT[8] := aRes[3]
      nK := ArrayValor( aGrup,aRes[3],,.t. )
      oRpt:Say( oRpt:nL,01,aGrup[ nK,1 ] )
   EndIf
   oRpt:Say( oRpt:nL,22,aRes[1] )
   oRpt:Say( oRpt:nL,33,TRANSFORM(aRes[2],"999,999") )
   oRpt:nL ++
   aGT[nK] += aRes[2]
   nL --
EndDo
MSFreeResult( hRes )
oRpt:Say( oRpt:nL, 00,REPLICATE("_",80),,,1 )
FOR nK := 1 TO 7
   If aGT[nK] > 0
      oRpt:Say(++oRpt:nL,10,aGrup[ nK,1 ],,,1 )
      oRpt:Say(  oRpt:nL,33,TRANSFORM(aGT[nK],"999,999" ) )
   EndIf
NEXT nK
oRpt:NewPage()
oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserTot( aGrup,aGT,hRes,nL ) CLASS TFisico
   LOCAL aRes, nK
 ::Init( ::aEnc[4], .f. ,, .F. ,,,, 5 )
 ::nMD := 12
   PAGE
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   ::Cabecera( .t.,0.42 )
   If aGT[8]  # aRes[3]
      aGT[8] := aRes[3]
      nK := ArrayValor( aGrup,aRes[3],,.t. )
      UTILPRN ::oUtil Self:nLinea, 1.5 SAY aGrup[ nK,1 ]
   EndIf
      UTILPRN ::oUtil Self:nLinea, 6.5 SAY aRes[1]
      UTILPRN ::oUtil Self:nLinea,11.0 SAY TRANSFORM(aRes[2],"999,999") RIGHT
   aGT[nK] += aRes[2]
   nL --
EndDo
MSFreeResult( hRes )
   ::Cabecera( .t.,0.4,2.52,12 )
FOR nK := 1 TO 7
   If aGT[nK] > 0
      UTILPRN ::oUtil Self:nLinea, 2.5 SAY aGrup[ nK,1 ]
      UTILPRN ::oUtil Self:nLinea,11.0 SAY TRANSFORM(aGT[nK],"999,999") RIGHT
      ::nLinea += 0.42
   EndIf
NEXT nK
   ENDPAGE
IMPRIME END .F.
RETURN NIL