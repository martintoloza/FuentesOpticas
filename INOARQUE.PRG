// Programa.: INOARQUE.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Arqueo fisico al inventario
#include "FiveWin.ch"
#include "btnget.ch"
#include "Utilprn.CH"

MEMVAR oApl

PROCEDURE InoArque()
   LOCAL oDlg, oGet := ARRAY(5)
   LOCAL oA := TArqueo()
oA:New()
DEFINE DIALOG oDlg TITLE "Arqueo Fisico al Inventario" FROM 0, 0 TO 07,42
   @ 02, 00 SAY "Optica" OF oDlg RIGHT PIXEL SIZE 96,10
   @ 02, 98 GET oGet[1] VAR oA:aLS[1] OF oDlg PICTURE "@!"         ;
      VALID Eval( {|| If( oApl:oEmp:Seek( {"localiz",oA:aLS[1]} ) ,;
                      (oApl:nEmpresa := oApl:oEmp:OPTICA,.t. )    ,;
                      (MsgStop("Esta Optica NO EXISTE"), .f.) ) } );
      SIZE 24,12 PIXEL
   @ 16, 00 SAY  "DIGITE AÑO Y MES [AAMM]" OF oDlg RIGHT PIXEL SIZE 96,10
   @ 16, 98 GET oGet[2] VAR oA:aLS[2] OF oDlg SIZE 36,12 PIXEL;
      VALID NtChr( oA:aLS[2],"P" )
   @ 32, 10 BUTTON oGet[3] PROMPT "&Aceptar"   SIZE 44,12 OF oDlg ACTION;
      ( oA:Arqueos(), oGet[3]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   @ 32, 60 BUTTON oGet[4] PROMPT "&Cancelar"  SIZE 44,12 OF oDlg CANCEL;
      ACTION ( oDlg:End() ) PIXEL
   @ 32,110 BUTTON oGet[5] PROMPT "&Historial" SIZE 44,12 OF oDlg ACTION;
      ( oA:ArqueHis(), oGet[5]:oJump := oGet[1], oGet[1]:SetFocus() ) PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED

oA:oArq:Destroy()
RETURN

//----Actualiza Arqueos de Opticas----//
PROCEDURE InoArqOp()
   LOCAL n, oA, oDlg, oGet := ARRAY(4)
 oA := TArqueo()
 oA:aLS := { UPPER( AbrirFile( 1 ) ),"",NtChr( DATE()-DAY(DATE())-1,"1" ),.t. }
n := RAT( "\", oA:aLS[1] )
oA:aLS[2] := If( n > 0 .AND. n < LEN( oA:aLS[1] )      ,;
               RIGHT( oA:aLS[1], LEN( oA:aLS[1] ) - n ),;
                 If( ( n := AT( ":", oA:aLS[1] ) ) > 0 ,;
                   RIGHT( oA:aLS[1], LEN( oA:aLS[1] ) - n ), oA:aLS[1] ) )
If EMPTY( oA:aLS[1] ) .OR. RIGHT( oA:aLS[1],3 ) # "TXT"
   MsgStop( "No Escogio ningun Archivo o no es un .TXT" )
   RETURN
EndIf
DEFINE DIALOG oDlg TITLE "Actualiza Arqueos de Opticas" FROM 0, 0 TO 06,40
   @ 02, 00 SAY "DIGITE AÑO Y MES [AAMM]" OF oDlg RIGHT PIXEL SIZE 96,10
   @ 02, 98 GET oGet[1] VAR oA:aLS[3] OF oDlg SIZE 36,12 PIXEL;
      VALID NtChr( oA:aLS[3],"P" ) ;
      WHEN oA:aLS[2] # "ARQUEO.TXT"
   @ 16,40 BUTTON oGet[2] PROMPT "Actualizo" SIZE 44,12 OF oDlg ACTION;
      ( oGet[2]:Disable(), oA:ActuArque( oDlg ), oDlg:End() ) PIXEL
   @ 16,90 BUTTON oGet[3] PROMPT "Cancelar"  SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 32,10 SAY oGet[4] VAR oA:aLS[2] OF oDlg PIXEL SIZE 90,12 ;
      UPDATE COLOR nRGB( 128,0,255 )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN

//------------------------------------//
PROCEDURE InoLiArq( lResu )
   LOCAL aRep, oA, oBar, oGet := ARRAY(7)
   LOCAL aGru := { {"Montura","01"},{"Liquidos","03"},{"Accesorios","04"},;
                   {"L.Contacto","60"} }
   DEFAULT lResu := .f.
 oA := TArqueo()
 oA:aLS := { NtChr( DATE(),"1" ),1,oApl:nTFor,.t.,"","","" }
   aRep := { {|| oA:ListoArq( oApl:aWHija[1] ) },"Listo el Arqueo Fisico" }
If lResu
   aRep := { {|| oA:ListoCod( oApl:aWHija[1] ) },"Listar Codigos del Arqueo" }
EndIf
If oApl:aWHija[1] == NIL
   DEFINE WINDOW oApl:aWHija[1] OF oApl:oWnd NOMINIMIZE NOMAXIMIZE ;
          TITLE aRep[2] ;
          FROM 0,0 TO 220,400 PIXEL MDICHILD
   DEFINE BUTTONBAR oBar OF oApl:aWHija[1] SIZE 25,25 _3D

   DEFINE BUTTON OF oBar RESOURCE "Exit3" NOBORDER;
          ACTION oApl:aWHija[1]:End() TOOLTIP "Salida"
   @ 30, 00 SAY "DIGITE AÑO Y MES [AAMM]" OF oApl:aWHija[1] RIGHT PIXEL SIZE 180,16
   @ 30,186 GET oGet[1] VAR oA:aLS[1] OF oApl:aWHija[1] SIZE 54,18 PIXEL;
      VALID NtChr( oA:aLS[1],"P" )
   @ 60, 00 SAY "ESCOJA EL GRUPO DESEADO" OF oApl:aWHija[1] RIGHT PIXEL SIZE 180,16
   @ 60,186 COMBOBOX oGet[2] VAR oA:aLS[2] ITEMS ArrayCol( aGru,1 ) SIZE 90,99 ;
      OF oApl:aWHija[ 1 ] PIXEL
   @ 90, 00 SAY "TIPO DE IMPRESORA"   OF oApl:aWHija[1] RIGHT PIXEL SIZE 180,16
   @ 90,186 COMBOBOX oGet[3] VAR oA:aLS[3] ITEMS { "Matriz","Laser" } SIZE 80,90 ;
      OF oApl:aWHija[1] PIXEL
   @ 90,280 CHECKBOX oGet[4] VAR oA:aLS[4] PROMPT "Vista &Previa" OF oApl:aWHija[1];
      SIZE 94,16 PIXEL
   @ 120,186 BUTTON oGet[5] PROMPT "&Aceptar"  SIZE 60,20 OF oApl:aWHija[1] ACTION ;
      ( oA:aLS[5] := aGru[oA:aLS[2],2], oGet[5]:Disable(),;
        EVAL( aRep[1] )               , oGet[5]:Enable() ,;
        oGet[5]:oJump := oGet[1]      , oGet[1]:SetFocus() ) PIXEL
   @ 150, 10 SAY  oGet[6] VAR oA:aLS[6] OF oApl:aWHija[1] PIXEL SIZE 180,18 ;
      UPDATE COLOR nRGB( 0,255,0 )
   @ 150,200 SAY  oGet[7] VAR oA:aLS[7] OF oApl:aWHija[1] PIXEL SIZE  80,18 ;
      UPDATE COLOR nRGB( 160,19,132 )
   ACTIVAGET(oGet)

   ACTIVATE WINDOW oApl:aWHija[1] ;
      ON INIT (oGet[1]:SetFocus());
      VALID ( oApl:aWHija[1] := NIL, .t. )
Else
   oApl:aWHija[1]:SetFocus()
EndIf
RETURN

//------------------------------------//
CLASS TArqueo FROM TIMPRIME

 DATA aLS, oArq

 METHOD NEW() Constructor
 METHOD ArqueHis()
 METHOD Arqueos()
 METHOD Buscar( oAr )
 METHOD ActuArque( oDlg )
 METHOD ListoArq( oDlg )
 METHOD LaserArq( cQry,oDlg )
 METHOD ListoCod()
 METHOD LaserCod( hRes )
 METHOD Memo( nH,cQry )
ENDCLASS

//------------------------------------//
METHOD New() CLASS TArqueo

 ::aLS  := { "   ",NtChr( DATE(),"1" ),oApl:nEmpresa,TInv(), }
 ::oArq := oApl:Abrir( "cadarque","optica, codigo, anomes",.t.,,50 )
 ::aLS[4]:New( ,.f. )

RETURN NIL

//------------------------------------//
METHOD ArqueHis() CLASS TArqueo
   LOCAL oDlg, oGet := ARRAY(1), oLbx, cCod := SPACE(12)
::oArq:Seek( { "optica",oApl:nEmpresa,"codigo",cCod } )
DEFINE DIALOG oDlg TITLE "HISTORIAL ARQUEO " + ::aLS[1] FROM 0, 0 TO 15,43
   @ 02,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 66,10
   @ 02,70 GET oGet[1] VAR cCod OF oDlg PICTURE "999999999!!!"         ;
      VALID If( oApl:oInv:Seek( {"codigo",cCod} )                     ,;
              (::oArq:Seek( { "optica",oApl:nEmpresa,"codigo",cCod } ),;
               oLbx:GoBottom(), oDlg:Update(), .t. )                  ,;
              ( MsgStop( "Este Código NO EXISTE !!!" ), .f. ) )        ;
      SIZE 50,12 PIXEL
   @ 20,06 LISTBOX oLbx FIELDS ::oArq:ANOMES            ,;
                               ::oArq:VITRINA           ,;
                    TRANSFORM( ::oArq:CANTIDAD,"99,999" );
      HEADERS "Periodo", "Vitrina", "Cantidad";
      SIZE 150,90 OF oDlg UPDATE PIXEL
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:nHeaderHeight := 28
    oLbx:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:aColSizes  := {60,60,60}
    oLbx:aHjustify  := {2,2,2}
    oLbx:aJustify   := {0,0,1}
    oLbx:lCellStyle := oLbx:ladjbrowse := .f.
    oLbx:ladjlastcol:= .t.
   MySetBrowse( oLbx, ::oArq )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN NIL

//------------------------------------//
METHOD Arqueos() CLASS TArqueo
   LOCAL oDlg, oGet := ARRAY(7), bGrabar
   LOCAL oAr := ::aLS[4]
bGrabar := {|| If( ::oArq:lOK,                          ;
                 ( ::oArq:Update(), oGet[7]:Disable() ),;
                 ( ::oArq:OPTICA := oApl:nEmpresa      ,;
                   ::oArq:ANOMES := ::aLS[2]           ,;
                   ::oArq:Append() ) ), ::oArq:xBlank(),;
               oDlg:Update(), oDlg:SetFocus() }
::aLS[5] := CTOD( NtChr( NtChr( ::aLS[2],"F" ),"4" ) )
::oArq:xBlank()
oAr:oDb:Seek( {"codigo",::oArq:CODIGO} )
DEFINE DIALOG oDlg TITLE "ARQUEO " + ::aLS[1] FROM 0, 0 TO 10,50
   @ 02,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 66,10
   @ 02,70 BTNGET oGet[1] VAR oAr:xVar OF oDlg PICTURE "999999999!!!";
      VALID If( ::Buscar( oAr )                                     ,;
              (If( ::oArq:lOK,  oGet[7]:Enable()                    ,;
                 ( oGet[7]:Disable(), ::oArq:CODIGO := oAr:xVar ) ) ,;
                oDlg:Update(), .t. ), .f. )                          ;
      SIZE 56,12 PIXEL UPDATE  RESOURCE "BUSCAR"                     ;
      ACTION EVAL({|| If(oAr:Mostrar(), (oAr:xVar := oAr:oDb:CODIGO ,;
                        oGet[1]:Refresh(), oGet[1]:lValid(.f.)),)})
   @ 16,50 SAY oGet[2] VAR oAr:oDb:DESCRIP OF oDlg PIXEL SIZE 140,12 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 30,00 SAY "Cantidad" OF oDlg RIGHT PIXEL SIZE 66,8
   @ 30,70 GET oGet[3] VAR ::oArq:CANTIDAD OF oDlg PICTURE "9,999";
      VALID {|| If( ::oArq:CANTIDAD <= 0, ;
          (MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>" ), .f.),;
          (If( oAr:oDb:GRUPO == "1" .AND. ::oArq:CANTIDAD > 1,;
          (MsgStop( "En Montura la Cantidad debe ser 1","<< OJO >>"),.f.), .t.))) };
      SIZE 40,12 PIXEL UPDATE
   @ 44,00 SAY  "Vitrina" OF oDlg RIGHT PIXEL SIZE 66,8
   @ 44,70 GET oGet[4] VAR ::oArq:VITRINA OF oDlg PICTURE "@!";
      SIZE 30,12 PIXEL UPDATE
   @ 60, 40 BUTTON oGet[5] PROMPT "&Grabar"   SIZE 44,12 OF oDlg ACTION;
      (If( EMPTY( ::oArq:CODIGO ) .OR. ::oArq:CANTIDAD <= 0           ,;
         (MsgStop("Imposible grabar este CODIGO"), oGet[1]:SetFocus()),;
          EVAL(bGrabar) )) PIXEL
   @ 60, 90 BUTTON oGet[6] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 60,140 BUTTON oGet[7] PROMPT "&Borrar"   SIZE 44,12 OF oDlg ACTION;
      (DelRecord( ::oArq ), oGet[7]:Disable(), oDlg:SetFocus()) PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT (oGet[7]:Disable(), oDlg:Move(240,200) )
RETURN NIL

//------------------------------------//
METHOD Buscar( oAr ) CLASS TArqueo
   LOCAL cEstado, lSi := oAr:oDb:Seek( {"codigo",oAr:xVar} )
::oArq:Seek( { "optica",oApl:nEmpresa,"codigo",oAr:xVar,"anomes",::aLS[2] } )
If !lSi .AND. !::oArq:lOK .AND. LEFT( oAr:xVar,2 ) == "01"
   cEstado := STUFF( oAr:xVar,4,1, If( SUBSTR( oAr:xVar,4,1 ) == "1", "2", "1" ) )
   lSi := oAr:oDb:Seek( {"codigo",cEstado} )
EndIf
If lSi
   If oAr:oDb:GRUPO == "1"
      cEstado := ArrayValor( oApl:aOptic,STR(oAr:oDb:OPTICA,2) ) +;
                 " En Rep." + NtChr( oAr:oDb:FECREPOS,"2" )
      oAr:xVar:= oAr:oDb:CODIGO
      If oAr:oDb:OPTICA # oApl:nEmpresa
         lSi := MsgNoYes( cEstado,"Montura esta en" )
      Else
         If oAr:oDb:FECREPOS > ::aLS[5]
            lSi := MsgNoYes( cEstado,"Montura es de un mes Posterior" )
         ElseIf oAr:oDb:SITUACION $ "DV"
            lSi := MsgNoYes( NtChr(oAr:oDb:FACTUVEN,"0") + " en " + ;
                             NtChr(oAr:oDb:FECVENTA,"2"),"Montura Vendida Fact." )
         EndIf
      EndIf
   EndIf
Else
   If ::oArq:lOK
      lSi := .t.
   Else
      MsgStop( oAr:xVar + " NO EXISTE","Este Código" )
   EndIf
EndIf
RETURN lSi

//------------------------------------//
METHOD ActuArque( oDlg ) CLASS TArqueo
   LOCAL aDBF := { { "CEL", "C", 150, 0 } }
   LOCAL oArq, cRuta := "\" + CURDIR() + "\"
dbCREATE( "ARQUEO",aDbf )
If !AbreDbf( "Tem","ARQUEO",,cRuta,.f. )
   BorraFile( "ARQUEO",{"DBF"},cRuta )
   RETURN NIL
EndIf
aDBF := { 1,"",0,"",0,(::aLS[2] # "ARQUEO.TXT") }
oDlg:SetText( "<< ESPERE >> ACTUALIZANDO ARQUEO "+::aLS[2] )
::aLS[2]:= STRTRAN( ::aLS[1],"TXT","ULT" )
APPEND FROM &(::aLS[1]) SDF
Tem->(dbGoTop())
If !oApl:lEnLinea
   ERASE  &(::aLS[2])
   RENAME &(::aLS[1]) TO &(::aLS[2])
   If aDBF[6]
      oApl:oEmp:Seek( { "localiz",LEFT( ::aLS[2],AT(".",::aLS[2])-1 ) } )
      aDBF[1] := oApl:oEmp:OPTICA
      aDBF[2] := ::aLS[3]
      oApl:oEmp:Seek( { "optica",oApl:nEmpresa } )
   EndIf
   oArq := oApl:Abrir( "cadarque","optica, codigo, anomes",.t. )
   While !Tem->(EOF())
      If aDBF[6]
         aDBF[3] := VAL( StrToken( Tem->CEL,3,"," ) )
         aDBF[4] :=      StrToken( Tem->CEL,1,"," )
         ::aLS[2]:=      StrToken( Tem->CEL,2,"," )
         ::aLS[3]:= LEFT( ::aLS[2],2 )
      Else
         If LEFT( Tem->CEL,1 ) # " " .OR. SUBSTR( Tem->CEL,09,2 ) == "  "
            Tem->(dbSkip())
            LOOP
         EndIf
         aDBF[1] := VAL( SUBSTR( Tem->CEL,09,02 ) )
         aDBF[2] :=      SUBSTR( Tem->CEL,12,06 )
         aDBF[3] := VAL( SUBSTR( Tem->CEL,43,5 ) )
         aDBF[4] :=      SUBSTR( Tem->CEL,24,03 )
         ::aLS[2]:= TRIM(SUBSTR( Tem->CEL,28,10 ) )
         ::aLS[3]:=      SUBSTR( Tem->CEL,19,2 )
      EndIf
      If LEN( ::aLS[2] ) <= 6
         If ::aLS[3] # "01" .AND. LEFT( ::aLS[2],2 ) == "02"
            ::aLS[2] := ::aLS[3] + "02" + PADL(STUFF(::aLS[2],1,2,""),6,"0" )
         Else
            ::aLS[2] := ::aLS[3] + "01" + PADL( ::aLS[2],6,"0" )
         EndIf
      EndIf
      ::aLS[2] += "  "
      oDlg:Update()
      If !oApl:oInv:Seek( {"codigo",::aLS[2]} ) .AND. LEFT( ::aLS[2],2 ) == "01"
         ::aLS[2] := STUFF( ::aLS[2],4,1,If( SUBSTR( ::aLS[2],4,1 ) == "1", "2", "1" ) )
      EndIf
      If oArq:Seek( { "optica",aDBF[1],"codigo",::aLS[2],"anomes",aDBF[2] } )
         oArq:CANTIDAD += aDBF[3]  ; oArq:Update()
      Else
         oArq:xBlank()
         oArq:OPTICA   := aDBF[1]; oArq:CODIGO   := ::aLS[2]
         oArq:ANOMES   := aDBF[2]; oArq:CANTIDAD := aDBF[3]
         oArq:VITRINA  := aDBF[4]
         oArq:Append()
         aDBF[5] ++
      EndIf
      Tem->(dbSkip())
   EndDo
   oArq:Destroy()
   MsgInfo( "Se Adicionaron"+STR(aDBF[5])+" Registros" )
   aDBF := {"DBF","TXT"}
ElseIf oApl:nTFor == 1
   oArq := TDosPrint()
   oArq:New( oApl:cPuerto,oApl:cImpres,,.t.,,2 )
   oArq:SetFont( oArq:cFontI,141 )
   oArq:nL := oArq:nPage := 1
   While !Tem->(EOF())
      If aDBF[1]  > oArq:nLength
         aDBF[1] := 0
         oArq:NewPage()
         oArq:nL := 1
      Endif
      oArq:Say( oArq:nL,00,SUBSTR(Tem->CEL,2) )
      oArq:nL ++
      aDBF[1] ++
      Tem->(dbSkip())
   EndDo
   oArq:NewPage()
   oArq:End()
   aDBF := {"DBF"}
Else
   ::Init( "ARQUEO FISICO", .f. ,, !::aLS[4] ,,, ::aLS[4], 5 )
   ::aEnc   := { .t. }
   ::nLinea := 0.60
    PAGE
   While !Tem->(EOF())
      ::aEnc[1] := ::Separator( 0.40 )
      UTILPRN ::oUtil Self:nLinea, 00 SAY SUBSTR(Tem->CEL,2)
      Tem->(dbSkip())
   EndDo
    ENDPAGE
   ::EndInit( .F. )
   aDBF := {"DBF"}
EndIf
Tem->(dbCloseArea())
BorraFile( "ARQUEO",aDBF,cRuta )
RETURN NIL

//------------------------------------//
METHOD ListoArq( oDlg ) CLASS TArqueo
   LOCAL aRA, aRS, cQry, hRes, nL, lOK := .t.
   LOCAL oRpt, aCA := { 0,0,0,0,0,0,0,0,0,"" }
::aLS[6] := If( ::aLS[5] == "60", "90", ::aLS[5] )
cQry := "SELECT codigo, 0, 0, 0, 0, 0, 0, 0, 0, 'A', cantidad FROM cadarque "+;
        "WHERE optica = " + LTRIM(STR(oApl:nEmpresa)) +;
    " AND LEFT(codigo,2) >= " + ::aLS[5]              +;
    " AND LEFT(codigo,2) <= " + ::aLS[6]              +;
         " AND anomes = '"    + ::aLS[1] + "'"
hRes := ::Memo( 0,cQry )
If MSNumRows( hRes ) == 0
   MsgInfo( "NO HAY ARQUEO","EN "+::aLS[1] )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[3] == 2
   MSFreeResult( hRes )
   ::LaserArq( cQry,oDlg )
   RETURN NIL
EndIf
MSFreeResult( hRes )
aCA[09] := Seconds()
aCA[10] := NtChr( NtChr( ::aLS[1],"F" )-1,"1" )
hRes := ::Memo( 1,cQry )
nL   := MSNumRows( hRes )
::aLS[6] := "Por Favor Espere Mientras Comparo" + STR(nL)
oDlg:Update()
cQry := {"MONTURAS","LIQUIDOS","ACCESORIOS","L.CONTACTO"}[::aLS[2]]
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"ARQUEO FISICO DEL INVENTARIO DE " + cQry,;
         "EN " + NtChr( NtChr( ::aLS[1],"F" ),"6" ),SPACE(37) +;
         "  SALDO   TOTAL    TOTAL DEVOLUC DEVOLUC  AJUSTE  AJUSTE DEVOLUC   SALDO   ARQUEO",;
         "C O D I G O- -D E S C R P C I O N--  ANTERIOR ENTRADA  VENTAS ENTRADA"+;
         " SALIDAS ENTRADA SALIDAS CLIENTE   ACTUAL  FISICO FALTANTE SOBRANTE"},::aLS[4],,2 )
While nL > 0
   If lOK
      aRA := MyReadRow( hRes )
      AEVAL( aRA, {| xV,nP | aRA[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If (nL --) > 1
      aRS := MyReadRow( hRes )
      AEVAL( aRS, {| xV,nP | aRS[nP] := MyClReadCol( hRes,nP ) } )
   Else
      aRS := aRA
   EndIf
   If aRA[1] == aRS[1]
      If TRIM(aRA[10]) == "A"
         AEVAL( aRS, {| xV,nP | aRA[nP] := xV },2,9 )
      Else
         aRA[11] := aRS[11]
      EndIf
      lOK := .t.
   Else
      lOK := .f.
   EndIf
   ::aLS[7] := aRA[1] ; oDlg:Update()
   If ::aLS[1] == aRA[10]
      aCA[6] := SaldoInv( aRA[1],aCA[10],1 )
   Else
      aCA[6] := aRA[9]             //Existencia Anterior
      AFILL( aRA,0,2,7 )
   EndIf

   aCA[7] := aRA[11] - aRA[9]      //Cantidad - Existencia
   aCA[8] := If( aCA[7] == 0 .AND. ::aLS[5] == "01", 0, 1 )
   If aRA[09] == 0 .AND. ;
      aRA[11] == 0 .AND. ::aLS[5] == "01"
      aCA[06] := 0
   EndIf
   If aCA[6] # 0 .OR. aRA[9] # 0 .OR. aCA[7] > 0
      oRpt:Titulo( 136 )
      If aCA[8] == 1
         oApl:oInv:Seek( {"codigo",aRA[01]} )
         oRpt:Say( oRpt:nL, 00,aRA[01] )
         oRpt:Say( oRpt:nL, 12,LEFT(oApl:oInv:DESCRIP,26) )
         oRpt:Say( oRpt:nL, 39,TRANSFORM(aCA[06],   "99,999") )
         oRpt:Say( oRpt:nL, 47,TRANSFORM(aRA[02],"@Z 99,999") )
         oRpt:Say( oRpt:nL, 55,TRANSFORM(aRA[03],"@Z 99,999") )
         oRpt:Say( oRpt:nL, 63,TRANSFORM(aRA[04],"@Z 99,999") )
         oRpt:Say( oRpt:nL, 71,TRANSFORM(aRA[05],"@Z 99,999") )
         oRpt:Say( oRpt:nL, 79,TRANSFORM(aRA[06],"@Z 99,999") )
         oRpt:Say( oRpt:nL, 87,TRANSFORM(aRA[07],"@Z 99,999") )
         oRpt:Say( oRpt:nL, 95,TRANSFORM(aRA[08],"@Z 99,999") )
         oRpt:Say( oRpt:nL,104,TRANSFORM(aRA[09],   "99,999") )
         oRpt:Say( oRpt:nL,112,TRANSFORM(aRA[11],   "99,999") )
         If aCA[7] < 0
            oRpt:Say( oRpt:nL,121,TRANSFORM(ABS(aCA[7]),"99,999") )
            aCA[4] += ABS(aCA[7])
         ElseIf aCA[7] > 0
            oRpt:Say( oRpt:nL,130,TRANSFORM(ABS(aCA[7]),"99,999") )
            aCA[5] += ABS(aCA[7])
         EndIf
         If oApl:oInv:GRUPO == "1"
            cQry := If( oApl:oInv:OPTICA == oApl:nEmpresa, "" ,;
                        ArrayValor( oApl:aOptic,STR(oApl:oInv:OPTICA,2) ) )
            oRpt:nL++
            oRpt:Titulo( 134 )
            oRpt:Say( oRpt:nL,00,"REPO." + STR(oApl:oInv:NUMREPOS) + "  " + ;
                       DTOC(oApl:oInv:FECREPOS) )
            oRpt:Say( oRpt:nL,28,"FACT." + STR(oApl:oInv:FACTUVEN) + "  " + ;
                       DTOC(oApl:oInv:FECVENTA) + "  " + cQry )
         EndIf
         oRpt:nL++
      EndIf
      aCA[1] += aCA[06]
      aCA[2] += aRA[09]
      aCA[3] += aRA[11]
   EndIf
   If lOK
      nL --
   Else
      aRA := aRS
   EndIf
EndDo
::aLS[6] := "Ha tardado " + STR( Seconds() - aCA[9] )
oDlg:Update()
If oRpt:nPage > 0
   oRpt:Titulo( 136 )
   oRpt:Say(  oRpt:nL, 00,REPLICATE("_",136),,,1 )
   oRpt:Say(++oRpt:nL, 15,"TOTALES",,,1 )
   oRpt:Say(  oRpt:nL, 39,TRANSFORM(aCA[1],"99,999") )
   oRpt:Say(  oRpt:nL,104,TRANSFORM(aCA[2],"99,999") )
   oRpt:Say(  oRpt:nL,112,TRANSFORM(aCA[3],"99,999") )
   oRpt:Say(  oRpt:nL,121,TRANSFORM(aCA[4],"99,999") )
   oRpt:Say(  oRpt:nL,130,TRANSFORM(aCA[5],"99,999") )
EndIf
oRpt:NewPage()
oRpt:End()
MSFreeResult( hRes )
RETURN NIL

//------------------------------------//
METHOD LaserArq( cQry,oDlg ) CLASS TArqueo
   LOCAL aRA, aRS, hRes, nL, lOK := .t.
   LOCAL aCA := { 0,0,0,0,0,0,0,0,0,"" }
aCA[09] := Seconds()
aCA[10] := NtChr( NtChr( ::aLS[1],"F" )-1,"1" )
hRes := ::Memo( 1,cQry )
nL   := MSNumRows( hRes )
 ::aLS[6] := "Por Favor Espere Mientras Comparo" + STR(nL)
oDlg:Update()
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit,;
             "ARQUEO FISICO DEL INVENTARIO DE ","EN "+NtChr( NtChr( ::aLS[1],"F" ),"6" ),;
             { .F., 0.5,"","C O D I G O" }    , { .F., 2.4,"","D E S C R I P C I O N" } ,;
             { .T., 7.2,"Saldo"  ,"Anterior" }, { .T., 8.4,"Total"  ,"Entradas" },;
             { .T., 9.6,"Total"  ,"Ventas" }  , { .T.,10.8,"Devoluc","Entrada" } ,;
             { .T.,12.0,"Devoluc","Salida" }  , { .T.,13.2,"Ajuste" ,"Entrada" } ,;
             { .T.,14.4,"Ajuste" ,"Salida" }  , { .T.,15.6,"Devoluc","Cliente" } ,;
             { .T.,16.9,"Saldo"  ,"Actual" }  , { .T.,18.2,"Arqueo" ,"Fisico" }  ,;
             { .T.,19.5,"","Faltante" }       , { .T.,20.8,"","Sobrante" } }
 ::aEnc[4] += {"MONTURAS","LIQUIDOS","ACCESORIOS","L.CONTACTO"}[::aLS[2]]
 ::Init( ::aEnc[4], .f. ,, !::aLS[4] ,,, ::aLS[4], 5 )
 ::nMD := 20.8
  DEFINE FONT ::aFnt[5] NAME ::cFont SIZE 0,-7  OF ::oPrn
  PAGE
While nL > 0
   If lOK
      aRA := MyReadRow( hRes )
      AEVAL( aRA, {| xV,nP | aRA[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If (nL --) > 1
      aRS := MyReadRow( hRes )
      AEVAL( aRS, {| xV,nP | aRS[nP] := MyClReadCol( hRes,nP ) } )
   Else
      aRS := aRA
   EndIf
   If aRA[1] == aRS[1]
      If TRIM(aRA[10]) == "A"
         AEVAL( aRS, {| xV,nP | aRA[nP] := xV },2,9 )
      Else
         aRA[11] := aRS[11]
      EndIf
      lOK := .t.
   Else
      lOK := .f.
   EndIf
   ::aLS[7] := aRA[1] ; oDlg:Update()
   If ::aLS[1] == aRA[10]
      aCA[6] := SaldoInv( aRA[1],aCA[10],1 )
   Else
      aCA[6] := aRA[9]             //Existencia Anterior
      AFILL( aRA,0,2,7 )
   EndIf

   aCA[7] := aRA[11] - aRA[9]      //Cantidad - Existencia
   aCA[8] := If( aCA[7] == 0 .AND. ::aLS[5] == "01", 0, 1 )
   If aRA[09] == 0 .AND. ;
      aRA[11] == 0 .AND. ::aLS[5] == "01"
      aCA[06] := 0
   EndIf
   If aCA[6] # 0 .OR. aRA[9] # 0 .OR. aCA[7] > 0
      If aCA[8] == 1
         oApl:oInv:Seek( {"codigo",aRA[01]} )
         ::Cabecera( .t.,0.42 )
         UTILPRN ::oUtil Self:nLinea, 0.5 SAY aRA[01]
         UTILPRN ::oUtil Self:nLinea, 2.4 SAY LEFT(oApl:oInv:DESCRIP,26)
         UTILPRN ::oUtil Self:nLinea, 7.2 SAY TRANSFORM(aCA[06],   "99,999") RIGHT
         UTILPRN ::oUtil Self:nLinea, 8.4 SAY TRANSFORM(aRA[02],"@Z 99,999") RIGHT
         UTILPRN ::oUtil Self:nLinea, 9.6 SAY TRANSFORM(aRA[03],"@Z 99,999") RIGHT
         UTILPRN ::oUtil Self:nLinea,10.8 SAY TRANSFORM(aRA[04],"@Z 99,999") RIGHT
         UTILPRN ::oUtil Self:nLinea,12.0 SAY TRANSFORM(aRA[05],"@Z 99,999") RIGHT
         UTILPRN ::oUtil Self:nLinea,13.2 SAY TRANSFORM(aRA[06],"@Z 99,999") RIGHT
         UTILPRN ::oUtil Self:nLinea,14.4 SAY TRANSFORM(aRA[07],"@Z 99,999") RIGHT
         UTILPRN ::oUtil Self:nLinea,15.6 SAY TRANSFORM(aRA[08],"@Z 99,999") RIGHT
         UTILPRN ::oUtil Self:nLinea,16.9 SAY TRANSFORM(aRA[09],   "99,999") RIGHT
         UTILPRN ::oUtil Self:nLinea,18.2 SAY TRANSFORM(aRA[11],   "99,999") RIGHT
         If aCA[7] < 0
            UTILPRN ::oUtil Self:nLinea,19.5 SAY TRANSFORM(ABS(aCA[7]),"99,999") RIGHT
            aCA[4] += ABS(aCA[7])
         ElseIf aCA[7] > 0
            UTILPRN ::oUtil Self:nLinea,20.8 SAY TRANSFORM(ABS(aCA[7]),"99,999") RIGHT
            aCA[5] += ABS(aCA[7])
         EndIf
         If oApl:oInv:GRUPO == "1"
            cQry := If( oApl:oInv:OPTICA == oApl:nEmpresa, "" ,;
                        ArrayValor( oApl:aOptic,STR(oApl:oInv:OPTICA,2) ) )
            ::Cabecera( .t.,0.42,0.84 )
            UTILPRN ::oUtil Self:nLinea, 0.8 SAY "REPO." + STR(oApl:oInv:NUMREPOS) + "  " +;
                                                 DTOC(oApl:oInv:FECREPOS)
            UTILPRN ::oUtil Self:nLinea, 4.3 SAY "FACT." + STR(oApl:oInv:FACTUVEN) + "  " +;
                                                 DTOC(oApl:oInv:FECVENTA) + "  " + cQry
         EndIf
      EndIf
      aCA[1] += aCA[06]
      aCA[2] += aRA[09]
      aCA[3] += aRA[11]
   EndIf
   If lOK
      nL --
   Else
      aRA := aRS
   EndIf
EndDo
MSFreeResult( hRes )
::aLS[6] := "Ha tardado " + STR( Seconds() - aCA[9] )
oDlg:Update()
If ::nPage > 0
   ::Cabecera( .t.,0.3,0.45,20.8 )
   UTILPRN ::oUtil Self:nLinea, 3.0 SAY "T O T A L E S ======>"
   UTILPRN ::oUtil Self:nLinea, 7.2 SAY TRANSFORM(aCA[1],"99,999") RIGHT
   UTILPRN ::oUtil Self:nLinea,16.9 SAY TRANSFORM(aCA[2],"99,999") RIGHT
   UTILPRN ::oUtil Self:nLinea,18.2 SAY TRANSFORM(aCA[3],"99,999") RIGHT
   UTILPRN ::oUtil Self:nLinea,19.5 SAY TRANSFORM(aCA[4],"99,999") RIGHT
   UTILPRN ::oUtil Self:nLinea,20.8 SAY TRANSFORM(aCA[5],"99,999") RIGHT
EndIf
  ENDPAGE
 ::EndInit( .F. )
RETURN NIL

//------------------------------------//
METHOD ListoCod() CLASS TArqueo
   LOCAL aC, aRes, hRes, nL, oRpt
hRes := ::Memo( 2 )
If MSNumRows( hRes ) == 0
   MsgInfo( "NO HAY ARQUEO","EN "+::aLS[1] )
   MSFreeResult( hRes )
   RETURN NIL
ElseIf ::aLS[3] == 2
   ::LaserCod( hRes )
   RETURN NIL
EndIf
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"CODIGOS DEL ARQUEO FISICO",;
          "EN " + NtChr( NtChr( ::aLS[1],"F" ),"6" ) },::aLS[4] )
aC   := { 1,0 }
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If EMPTY(aRes[4])
      aRes[4] := " N.E"
   ElseIf aRes[5] # oApl:nEmpresa
      aRes[4] := " " + ArrayValor( oApl:aOptic,STR(aRes[5],2) )
   EndIf
//   Etiqueta( aRes[2] )
   oRpt:Titulo( 78 )
   oRpt:Say( oRpt:nL,aC[1],aRes[1] +"-" +SUBSTR( aRes[2],5,6 ) + aRes[4] )
   aC[1] += 16
   aC[2] += aRes[3]
   If aC[1] > 65
      aC[1] := 1
      oRpt:nL++
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
   oRpt:nL += If( aC[1] == 1, 0, 1 )
   oRpt:Say(  oRpt:nL,01,REPLICATE("_",78) )
   oRpt:Say(++oRpt:nL,15,"TOTALES" )
   oRpt:Say(  oRpt:nL,45,TRANSFORM(aC[2],"99,999") )
 oRpt:NewPage()
 oRpt:End()
RETURN NIL

//------------------------------------//
METHOD LaserCod( hRes ) CLASS TArqueo
   LOCAL aC, aRes, nL
aC := { 1.0,0 }
nL := MSNumRows( hRes )
 ::aEnc := { .t., oApl:cEmpresa, oApl:oEmp:Nit,;
             "CODIGOS DEL ARQUEO FISICO","EN "+NtChr( NtChr( ::aLS[1],"F" ),"6" ),;
             { .F., 1.0,"C O D I G O S" } }
 ::Init( ::aEnc[4], .f. ,, !::aLS[4] ,,, ::aLS[4], 2 )
  PAGE
   ::Cabecera( .t.,0.42 )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If EMPTY(aRes[4])
      aRes[4] := " N.E"
   ElseIf aRes[5] # oApl:nEmpresa
      aRes[4] := " " + ArrayValor( oApl:aOptic,STR(aRes[5],2) )
   EndIf
   UTILPRN ::oUtil Self:nLinea, aC[1] SAY aRes[1] +"-" +SUBSTR( aRes[2],5,6 ) + aRes[4]
   aC[1] += 4.0
   aC[2] += aRes[3]
   If aC[1] > 17.0
      aC[1] := 1.0
      ::Cabecera( .t.,0.42 )
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
   ::Cabecera( .t.,0.3,0.45,20 )
   UTILPRN ::oUtil Self:nLinea, 2.0 SAY "TOTALES"
   UTILPRN ::oUtil Self:nLinea, 6.0 SAY TRANSFORM(aC[2],"99,999")
  ENDPAGE
 ::EndInit( .F. )
RETURN NIL

//------------------------------------//
METHOD Memo( nH,cQry ) CLASS TArqueo
   LOCAL hRes
If nH == 1
   cQry := "SELECT s.codigo, s.entradas, s.salidas, s.devol_e, s.devol_s, "  +;
           "s.ajustes_e, s.ajustes_s, s.devolcli, s.existencia, s.anomes, 0 "+;
           "FROM cadinvme s "                                        +;
           "WHERE s.optica = " + LTRIM(STR(oApl:nEmpresa))           +;
       " AND LEFT(s.codigo,2) >= " + ::aLS[5]                        +;
       " AND LEFT(s.codigo,2) <= " + ::aLS[6]                        +;
            " AND s.anomes = (SELECT MAX(m.anomes) FROM cadinvme m " +;
                             "WHERE m.optica = s.optica"             +;
                              " AND m.codigo = s.codigo"             +;
                              " AND m.anomes <= '" + ::aLS[1] + "')" +;
       " AND (s.existencia <> 0 OR  s.anomes = '"  + ::aLS[1] + "')" +;
       " UNION " + cQry + " ORDER BY codigo"
ElseIf nH == 2
   cQry := "SELECT a.vitrina, a.codigo, a.cantidad, i.grupo, i.optica "+;
           "FROM cadarque a LEFT JOIN cadinven i "         +;
            "USING( codigo ) "                             +;
           "WHERE a.optica = " + LTRIM(STR(oApl:nEmpresa)) +;
            " AND LEFT(codigo,2) = '01'"                   +;
            " AND a.anomes = '" + ::aLS[1] + "' ORDER BY vitrina"
EndIf
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry, ),;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
RETURN hRes