// Programa.: INOLIART.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Listo ingreso de monturas a bodega
#include "FiveWin.ch"

MEMVAR oApl

PROCEDURE InoLiCod( lResu )
   LOCAL oDlg, oGet := ARRAY(9), aOpc := { DATE(),DATE(),"S",0,.f.,"",0 }
   LOCAL aRep := { {|| ListoCod( aOpc ) },"Listo Códigos de Monturas Nuevas" }
   DEFAULT lResu := .f.
If lResu
   aRep := { {|| ListoEtq( aOpc,oDlg ) },"Etiquetas Para Monturas" }
EndIf
DEFINE DIALOG oDlg TITLE aRep[2] FROM 0, 0 TO 12,60
   @ 02, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 02,102 GET oGet[1] VAR aOpc[1] OF oDlg  SIZE 40,12 PIXEL
   @ 16, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 16,102 GET oGet[2] VAR aOpc[2] OF oDlg ;
      VALID aOpc[2] >= aOpc[1] SIZE 40,12 PIXEL
   @ 30, 00 SAY   "CON PRECIO COSTO <S/N>" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 30,102 GET oGet[3] VAR aOpc[3] OF oDlg PICTURE "!";
      VALID If( aOpc[3] $ "NS", .t., .f. )             ;
      WHEN !lResu  SIZE 08,12 PIXEL
   @ 30,160 SAY oGet[4] VAR aOpc[6] OF oDlg PIXEL SIZE 80,18 ;
      UPDATE COLOR nRGB( 160,19,132 )
   @ 44, 00 SAY "CODIGO  INICIAL  MONTURA" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 44,102 GET oGet[5] VAR aOpc[4] OF oDlg PICTURE "999999";
      WHEN  lResu  SIZE 32,12 PIXEL
   @ 58, 00 SAY "# DEL INGRESO  (0 Todos)" OF oDlg RIGHT PIXEL SIZE 100,10
   @ 58,102 GET oGet[6] VAR aOpc[7] OF oDlg PICTURE "99999" SIZE 32,12 PIXEL
   @ 58,160 CHECKBOX oGet[7] VAR aOpc[5] PROMPT "Vista &Previa" OF oDlg ;
      SIZE 60,12 PIXEL  WHEN !lResu
   @ 74, 50 BUTTON oGet[8] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[8]:Disable(), EVAL( aRep[1] ), oGet[8]:Enable()         ,;
        oGet[8]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 74,100 BUTTON oGet[9] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 80, 02 SAY "[INOLICOD]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
STATIC PROCEDURE ListoCod( aLS )
   LOCAL aGT, oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"INGRESO DE MONTURAS A BODEGA",;
         NtChr( aLS[1],"3" ),SPACE(72) +;
         "---PRECIO--- ---PRECIO--- ---PRECIO--- FACTUR --FECHA---  NUMERO",;
         "C O D I G O- PROVEEDOR--- ---MARCA---- REFERENCIA------- TAMANO MAT SEX "+;
         "---COSTO---- ---VENTA---- ---PUBLICO-- PROVEE --RECIBO-- INGRESO" },aLS[5],,2 )
aGT := { "grupo","1","fecrecep >= ",aLS[1],"fecrecep <= ",aLS[2] }
If aLS[7] > 0
   AEVAL( { "ingreso",aLS[7] }, {|cVal| AADD( aGT,cVal ) } )
EndIf
oApl:oInv:Seek( aGT,"fecrecep, SUBSTR(codigo,5,6)" )
aGT := { 0,0,0,0,0 }

While !oApl:oInv:Eof()
   oApl:oNit:Seek( {"codigo_nit",oApl:oInv:CODIGO_NIT} )
   oRpt:Titulo( 136 )
   oRpt:Say( oRpt:nL, 00,oApl:oInv:CODIGO )
   oRpt:Say( oRpt:nL, 13,  LEFT(oApl:oNit:NOMBRE,12) )
   oRpt:Say( oRpt:nL, 26,  LEFT(oApl:oInv:DESCRIP,oApl:oInv:MARCA),12 )
   oRpt:Say( oRpt:nL, 39,SUBSTR(oApl:oInv:DESCRIP,oApl:oInv:MARCA+2),17 )
   oRpt:Say( oRpt:nL, 57,oApl:oInv:TAMANO )
   oRpt:Say( oRpt:nL, 65,oApl:oInv:MATERIAL )
   oRpt:Say( oRpt:nL, 69,oApl:oInv:SEXO )
   If aLS[3] == "S"
      oRpt:Say( oRpt:nL, 73,TRANSFORM(oApl:oInv:PCOSTO,"999,999,999") )
   EndIf
   oRpt:Say( oRpt:nL, 86,TRANSFORM(oApl:oInv:PVENTA,"999,999,999") )
   oRpt:Say( oRpt:nL, 99,TRANSFORM(oApl:oInv:PPUBLI,"999,999,999") )
   oRpt:Say( oRpt:nL,111,oApl:oInv:FACTUPRO )
   oRpt:Say( oRpt:nL,118,oApl:oInv:FECRECEP )
   oRpt:Say( oRpt:nL,130,STR(oApl:oInv:INGRESO,6) )
   oRpt:nL++
   aGT[1] += oApl:oInv:PCOSTO
   aGT[2] += oApl:oInv:PVENTA
   aGT[3] += oApl:oInv:PPUBLI
   aGT[4] ++
   oApl:oInv:Skip(1):Read()
   oApl:oInv:xLoad()
EndDo
If aGt[4] > 0
   oRpt:Say(  oRpt:nL,00,REPLICATE("_",136),,,1 )
   oRpt:Say(++oRpt:nL,03,TRANSFORM(aGT[4],   "9,999"),,,1 )
   oRpt:Say(  oRpt:nL,73,TRANSFORM(aGT[1], "999,999,999" ) )
   oRpt:Say(  oRpt:nL,86,TRANSFORM(aGT[2], "999,999,999" ) )
   oRpt:Say(  oRpt:nL,98,TRANSFORM(aGT[3],"9999,999,999" ) )
EndIf
oRpt:NewPage()
oRpt:End()
RETURN

//------------------------------------//
STATIC PROCEDURE ListoEtq( aLS,oDlm )
   LOCAL oDlg, oG, nF
If (nF := FILE( oApl:cRuta2+"CODIGOS.DBF" ))
   If MsgYesNo( "Los Códigos Anteriores",">>> BORRAR <<<" )
      BorraFile( "CODIGOS",{"DBF","N0","PXX","IXX"} )
      nF := .f.
   EndIf
EndIf
If !nF
   oG := { { "VITRINA","C", 3,0 },{ "CODIGO","C",12,0 },{ "VALOR","C",11,0 } }
   dbCREATE( oApl:cRuta2+"CODIGOS",oG )
EndIf
If !AbreDbf( "Tem","CODIGOS",,,.f. )
   MsgInfo( "NO SE PUEDEN CREAR CODIGOS" ) ; RETURN
EndIf
nF := 1
If aLS[4] == 999999
   aLS[6] := SPACE(12)
   oG := ARRAY(4)
   DEFINE DIALOG oDlg FROM 0, 0 TO 07,60
      @ 02,00 SAY   "Código Artículo" OF oDlg RIGHT PIXEL SIZE 64,10
      @ 02,66 GET oG[1] VAR aLS[6] OF oDlg SIZE 52,12 PIXEL;
         VALID If( oApl:oInv:Seek( {"codigo",aLS[6]} )    ,;
                 ( nF := 1, oDlg:Update(), .t. )          ,;
                 ( MsgStop( "Este Código NO EXISTE !!!" ), .f. ))
      @ 02,120 SAY oG[2] VAR oApl:oInv:DESCRIP OF oDlg PIXEL SIZE 96,10;
         UPDATE COLOR nRGB( 128,0,255 )
      @ 16,00 SAY "Cantidad Etiqueta" OF oDlg RIGHT PIXEL SIZE 64,10
      @ 16,66 GET oG[3] VAR nF     OF oDlg PICTURE "999";
         WHEN LEFT( aLS[6],2 ) # "01" SIZE 30,12 PIXEL UPDATE
      @ 32,50 BUTTON oG[4] PROMPT "Aceptar" SIZE 44,12 OF oDlg ACTION;
         (Etiqueta(nF,""), aLS[6] := SPACE(12), oG[4]:oJump := oG[1], oG[1]:SetFocus()) PIXEL
      ACTIVAGET(oG)
   ACTIVATE DIALOG oDlg CENTERED
Else
   oG := { "grupo","1","fecrecep >= ",aLS[1],"fecrecep <= ",aLS[2] }
   If aLS[7] > 0
      AEVAL( { "ingreso",aLS[7] }, {|cVal| AADD( oG,cVal ) } )
   EndIf
   oApl:oInv:Seek( oG,"fecrecep, SUBSTR(codigo,5,6)" )
   oG := { 64,0,"" }
   If ( nF := Tem->(LASTREC()) ) > 0
      oG[2] := INT( nF / 64 )
      oG[1] := nF - If( nF > 64, (oG[2] * 64), 0 )
      oG[1] += If( oG[1] == 0, 64, 0 )
      If nF % 64  > 0
         oG[3] := LTRIM(STR(++oG[2]))
      EndIf
   EndIf
   //MsgInfo( "nF="+STR(nF,4)+" [1]="+STR(oG[1],4)+" [2]="+STR(oG[2],4),oG[3] )
   While !oApl:oInv:Eof()
      If oG[1] == 64
         oG[1] := 0
         oG[3] := LTRIM(STR(++oG[2]))
      EndIf
      aLS[6] := oApl:oInv:CODIGO
       oG[1] ++
      oDlm:Update() ; Etiqueta( 1,oG[3] )
      oApl:oInv:Skip(1):Read()
      oApl:oInv:xLoad()
   EndDo
EndIf
MsgInfo( STR(Tem->(LastRec()))+" Etiquetas",">>> VAN <<<" )
Tem->(dbCloseArea())
RETURN

STATIC PROCEDURE Etiqueta( nC,xV )
   LOCAL nF, cV
cV := If( oApl:oInv:GRUPO # "1", "", TRANSFORM(oApl:oInv:PPUBLI,"999,999,999") )
FOR nF := 1 TO nC
   Tem->(dbAppend())
   Tem->CODIGO := oApl:oInv:CODIGO
   Tem->VITRINA:= xV ; Tem->VALOR  := cV
NEXT nF
RETURN

//------------------------------------//
PROCEDURE InoFalta()
   LOCAL aBit, aCla := {}, aOpc, bCla, hRes, nL
   LOCAL oDlg, oLbx, oGet := ARRAY(5)
   LOCAL aItem := { "Facturas","Reposiciones","Devoluciones","N.Credito","Concurso" }
aOpc := "SELECT nombre_cla, nombre, clase_mate, tipo_mater "    +;
        "FROM cadtlist WHERE clase_mate <> 'S' AND activo = '0'"+;
        " ORDER BY tipo_mater DESC"
hRes := If( MSQuery( oApl:oMySql:hConnect,aOpc ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aOpc := MyReadRow( hRes )
   AEVAL( aOpc, { | xV,nP | aOpc[nP] := MyClReadCol( hRes,nP ) } )
   AADD( aCla, { 2,aOpc[2] + " " + aOpc[1],aOpc[3] + aOpc[4] } )
   nL --
EndDo
MSFreeResult( hRes )
aBit := { LoadBitmap( GetResources(), "OK" ),;
          LoadBitmap( GetResources(), "THIS" ) }
aOpc := { DATE(),DATE(),5 }
bCla := {|nA| aCla[nA,1] := If( aCla[nA,1] == 2, 1, 2 ),;
              oDlg:Update(), oLbx:Refresh(), oLbx:SetFocus() }
DEFINE DIALOG oDlg TITLE "DOCUMENTOS FALTANTES" FROM 0, 0 TO 20,80
   @ 40,00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 40,82 GET oGet[1] VAR aOpc[1] OF oDlg  SIZE 40,10 PIXEL
   @ 52,00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 52,82 GET oGet[2] VAR aOpc[2] OF oDlg ;
      VALID aOpc[2] >= aOpc[1] SIZE 40,10 PIXEL
   @ 64,00 SAY "ESCOJA GRUPO DESEADO"     OF oDlg RIGHT PIXEL SIZE 80,10
   @ 64,82 COMBOBOX oGet[3] VAR aOpc[3] ITEMS aItem SIZE 44,99 ;
      OF oDlg PIXEL

   @ 02,130 LISTBOX oLbx FIELDS "", "" ;
      HEADERS "", "LENTES OFTALMICOS"  ;
      SIZE 180,145         ;
      FIELDSIZES 16, 200   ;
      OF oDlg PIXEL UPDATE ;
      ON CLICK ( EVAL(bCla,oLbx:nAt) )
    oLbx:nClrBackHead := oApl:nClrBackHead
    oLbx:nLineStyle:= 2
    oLbx:nClrLine  := nRgb(184,196,224)
    oLbx:nAt       := 1
    oLbx:bLine     := {|| { aBit[ aCla[oLbx:nAt,1] ],;
                            aCla[oLbx:nAt][2] } }
    oLbx:bGoTop    := {|| oLbx:nAt := 1 }
    oLbx:bGoBottom := {|| oLbx:nAt := EVAL( oLbx:bLogicLen ) }
    oLbx:bSkip     := {|nWant,nOld| nOld := oLbx:nAt, oLbx:nAt += nWant,;
                        oLbx:nAt := MAX( 1, MIN( oLbx:nAt, EVAL( oLbx:bLogicLen ) ) ),;
                        oLbx:nAt - nOld }
    oLbx:bLogicLen := {|| LEN( aCla ) }
    oLbx:bKeyDown  := {|nKey| If( nKey=VK_RETURN, EVAL(bCla,oLbx:nAt), ) }

   @ 80, 30 BUTTON oGet[4] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[4]:Disable(), ListoCTL( aOpc,aCla ), oGet[4]:Enable(),;
        oGet[4]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 80, 80 BUTTON oGet[5] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 130, 02 SAY "[INOLICOD]" OF oDlg PIXEL SIZE 32,10
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED ON INIT (Empresa() )
RETURN

//------------------------------------//
STATIC PROCEDURE ListoCTL( aLS,aCla )
   LOCAL aRes, hRes, nL, oRpt
   LOCAL aDF := { 0,0,"FACTURA" }
If aLS[3] == 1
   aRes := "SELECT numfac FROM cadfactu "               +;
           "WHERE optica = "  +LTRIM(STR(oApl:nEmpresa))+;
            " AND fechoy >= " + xValToChar( aLS[1] )    +;
            " AND fechoy <= " + xValToChar( aLS[2] )    +;
            " AND tipo <> 'Z' ORDER BY numfac"
ElseIf aLS[3] == 2
   aDF[3] := "REPOSICION"
   aRes := "SELECT numrep FROM cadrepoc "               +;
           "WHERE fecharep >= " + xValToChar( aLS[1] )  +;
            " AND fecharep <= " + xValToChar( aLS[2] )  +;
            " ORDER BY numrep"
ElseIf aLS[3] == 3
   aDF[3] := "DEVOLUCION"
   aRes := "SELECT documen FROM caddevoc "              +;
           "WHERE optica = "  +LTRIM(STR(oApl:nEmpresa))+;
            " AND fechad >= " + xValToChar( aLS[1] )    +;
            " AND fechad <= " + xValToChar( aLS[2] )    +;
            " ORDER BY documen"
ElseIf aLS[3] == 4
   aDF[3] := "N.CREDITO"
   aRes := "SELECT numero FROM cadnotac "               +;
           "WHERE optica = "  +LTRIM(STR(oApl:nEmpresa))+;
            " AND fecha >= " + xValToChar( aLS[1] )     +;
            " AND fecha <= " + xValToChar( aLS[2] )     +;
            " ORDER BY numero"
Else
   Concurso( aLS,aCla )
   RETURN
EndIf
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"DOCUMENTOS FALTANTES"," DESDE "+;
         NtChr(aLS[1],"2") +" HASTA " +NtChr(aLS[2],"2"),aDF[3] },.t. )
aRes := MyReadRow( hRes )
aDF[1] := aDF[2] := aDF[3] := MyClReadCol( hRes,1 )
While nL > 0
  If aDF[2]  < aDF[3]
      oRpt:Titulo( 78 )
      oRpt:Say( oRpt:nL,02,STR(aDF[2],9) )
      oRpt:nL++
      aDF[2] ++
      LOOP
   Else
      aDF[2] ++
   EndIf
   If (nL --) > 1
      aRes   := MyReadRow( hRes )
      aDF[3] := MyClReadCol( hRes,1 )
   EndIf
   If nL == 0
      oRpt:Say(++oRpt:nL,15,"Primer Documento Digitado : " + STR(aDF[1]),,,1 )
      oRpt:Say(++oRpt:nL,15,"Ultimo Documento Digitado : " + STR(aDF[3]),,,1 )
   EndIf
EndDo
MSFreeResult( hRes )
oRpt:NewPage()
oRpt:End()
RETURN

//------------------------------------//
STATIC PROCEDURE Concurso( aLS,aCla )
   LOCAL aRes, cQry, hRes, nL, oRpt
aRes := cQry := ""
FOR nL := 1 TO LEN( aCla )
   If aCla[nL,1] == 1
      aRes += ("'" +  aCla[nL,3] + "', ")
/*
      If AT(  LEFT( aCla[nL,3],1 ),aRes ) == 0
         aRes += ( "'" +  LEFT( aCla[nL,3],1 ) + "', " )
      EndIf
      If AT( RIGHT( aCla[nL,3],2 ),cQry ) == 0
         cQry += ( "'" + RIGHT( aCla[nL,3],2 ) + "', " )
      EndIf
*/
   EndIf
NEXT nL
If LEN( aRes ) > 7
   aRes := "IN(" + LEFT( aRes,LEN(aRes)-2 )+ ")"
Else
   aRes :=  "= " + LEFT( aRes,LEN(aRes)-2 )
EndIf
/*
If LEN( cQry ) > 5
   cQry := "IN(" + LEFT( cQry,LEN(cQry)-2 )+ ")"
Else
   cQry :=  "= " + LEFT( cQry,LEN(cQry)-2 )
EndIf
         " AND SUBSTRING(d.descri,37,1) " + aRes       +;
         " AND SUBSTRING(d.descri,39,2) " + cQry       +;
*/
aRes := "SELECT 'F', c.numfac, c.orden, c.remplaza, d.descri, d.cantidad "+;
        "FROM cadventa d, cadfactu c "                 +;
        "WHERE d.codart  = '0201'"                     +;
         " AND CONCAT(SUBSTRING(d.descri,37,1),"       +;
                     "SUBSTRING(d.descri,39,2)) "+ aRes+;
         " AND c.optica  = d.optica"                   +;
         " AND c.numfac  = d.numfac"                   +;
         " AND c.optica  = " +LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fechoy >= " + xValToChar( aLS[1] )    +;
         " AND c.fechoy <= " + xValToChar( aLS[2] )    +;
         " AND c.indicador <> 'A'"
cQry := STRTRAN(aRes,"venta" ,"antid")
cQry := STRTRAN(cQry,"factu" ,"antic")
cQry := STRTRAN(cQry,"numfac","numero")
cQry := STRTRAN(cQry,"fechoy","fecha")
cQry := STRTRAN(cQry,"remplaza","numfac")
aRes += " UNION " + STRTRAN(cQry,"'F'","'A'")
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes )
   RETURN
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"LENTES OFTALMICOS",;
         "DESDE "+ NtChr( aLS[1],"2" )+ " HASTA "+ NtChr( aLS[2],"2" ),;
         "   FACTURA        ORDEN D E S C R I P C I O N-------------------          CANT."},.t. )
cQry := { 0,0,"",0,"" }
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes,{|xV,nP| aRes[nP] := MyClReadCol( hRes,nP ) } )
     cQry[3] := SUBSTR( aRes[5],37,1 ) + RIGHT( aRes[5],2 )
   If (cQry[4] := ASCAN( aCla, { |x| x[3] == cQry[3] } )) > 0
      aRes[5] := aCla[cQry[4],2]
   EndIf
   oRpt:Titulo( 80 )
   If cQry[1]  # aRes[2]
      cQry[1] := aRes[2]
      cQry[5] := If( aRes[1] == "F" .AND. aRes[4] > 0, "-A", "" )
      oRpt:Say( oRpt:nL, 0,aRes[1] + STR(aRes[2],9) + cQry[5] )
      oRpt:Say( oRpt:nL,13,STR(aRes[3]) )
   EndIf
      oRpt:Say( oRpt:nL,24,    aRes[5] )
      oRpt:Say( oRpt:nL,74,STR(aRes[6],5) )
      oRpt:nL++
   cQry[2] += If( cQry[5] == "", aRes[6], 0 )
   nL --
EndDo
MSFreeResult( hRes )
 oRpt:Say( oRpt:nL,32,"TOTAL LENTES ===>" )
 oRpt:Say( oRpt:nL,74,STR(cQry[2],5) )
 oRpt:NewPage()
 oRpt:End()
RETURN