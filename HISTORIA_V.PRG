// Programa.: HISTORIA.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Creacion y Manto. de Historias Clinicas.
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

PROCEDURE Historia()
   LOCAL oDlgA, oLbxA, oDp, oGet := ARRAY(7)
   LOCAL aAna, bAyuda, nMemo, oX
oX  := THistorias() ;  oX:NEW()
oDp := TPer()       ; oDp:New()

oApl:oAna:xBlank()
nMemo := oX:nHisto := 0
bAyuda:= {|| If( oDp:Mostrar( ,3,oDp:xVar ) ,;
               ( oDp:xVar := oDp:oDb:NROIDEN,;
                 oGet[1]:Refresh() ), ) }
 oApl:oMot:Seek( {"tipo","01"} )
DEFINE DIALOG oDlgA RESOURCE "DlgAnamnesi"
   REDEFINE SAY            VAR oX:nSigte ID 20 OF oDlgA UPDATE COLOR "B+/W"
   REDEFINE SAY            VAR oX:nHisto ID 22 OF oDlgA UPDATE
   REDEFINE BTNGET oGet[1] VAR oDp:xVar  ID  2 OF oDlgA        ;
      RESOURCE "BUSCAR"                                        ;
      ACTION EVAL( bAyuda )                                    ;
      VALID EVAL( {|| If( EMPTY(oDp:xVar), (EVAL(bAyuda), .f.),;
                     (If( oDp:Buscar( oDp:xVar,"nroiden",.t. ),;
                        ( oX:Ayuda( oGet )                    ,;
                          aAna := ACLONE( oApl:oAna:axBuffer ),;
                          oDlgA:setText( oX:cNom )            ,;
                          oDlgA:Update(), .t. )               ,;
                        ( EVAL( bAyuda ), .f. ) ) ) ) } )
   REDEFINE BTNGET oGet[2] VAR oApl:oAna:FEC_HISTOR ID  4 OF oDlgA RESOURCE "Calendar" ;
      ACTION (oApl:oAna:FEC_HISTOR := MsgDate(), oGet[2]:Refresh(), oGet[2]:SetFocus());
      WHEN !oX:aHis[2] UPDATE
   REDEFINE LISTBOX oLbxA FIELDS oApl:oMot:DESCRIPCIO ;
      HEADERS "" COLOR CLR_BLACK, RGB( 255, 255, 235) ;
      ON CLICK oX:Observacion( oGet[nMemo],2 )        ;
      ID 5 OF oDlgA ;
      WHEN nMemo > 0
    oLbxA:GoTop()
    oLbxA:cToolTip   := "Haga Click sobre el Criterio"
   MySetBrowse( oLbxA,oApl:oMot )

   REDEFINE GET oGet[3] VAR oApl:oAna:APERSONAL  ID  7 OF oDlgA MEMO;
      VALID oX:Cambios( 2,oApl:oAna:APERSONAL,aAna[6] ) UPDATE
    oGet[3]:bGotFocus := { || oGet[3]:SetSel( 0, 0 ),;
                              oGet[3]:Goto( oGet[3]:GetLineCount() ),;
                              __Keyboard( CHR( VK_END ) ), nMemo := 3 }
   REDEFINE GET oGet[4] VAR oApl:oAna:AFAMILIAR  ID  9 OF oDlgA MEMO;
      VALID oX:Cambios( 2,oApl:oAna:AFAMILIAR,aAna[7] ) UPDATE
    oGet[4]:bGotFocus := { || nMemo := 4 }
   REDEFINE GET oGet[5] VAR oApl:oAna:ESTREFOD   ID 11 OF oDlgA UPDATE;
      VALID oX:Cambios( 2,oApl:oAna:ESTREFOD  ,aAna[09] )
    oGet[5]:bGotFocus := { || nMemo := 0 }
   REDEFINE GET oGet[6] VAR oApl:oAna:ESTREFOI   ID 13 OF oDlgA UPDATE;
      VALID oX:Cambios( 2,oApl:oAna:ESTREFOI  ,aAna[10] )
    oGet[6]:bGotFocus := { || nMemo := 0 }
   REDEFINE GET oGet[7] VAR oApl:oAna:OBSERV_HIS ID 15 OF oDlgA UPDATE;
      VALID oX:Cambios( 2,oApl:oAna:OBSERV_HIS,aAna[08] )
    oGet[7]:bGotFocus := { || nMemo := 0 }

   REDEFINE LISTBOX oX:oLbxC FIELDS   ;
           STR( oApl:oCtl:CONTROL )  ,;
         NtChr( oApl:oCtl:FECHA,"2" ),;
         ArrayValor( oApl:aOptic,STR(oApl:oCtl:OPTICA,2) );
      HEADERS "Control No.", "Fecha", "Optica" ;
      ID 17 OF oDlgA UPDATE
    oX:oLbxC:bGotFocus := { || nMemo := 0 }
    oX:oLbxC:nClrBackHead  := oApl:nClrBackHead
    oX:oLbxC:nClrForeHead  := oApl:nClrForeHead
    oX:oLbxC:SetColor(oApl:nClrFore,oApl:nClrBack)
    oX:oLbxC:nClrBackFocus := oApl:nClrBackFocus
    oX:oLbxC:nClrForeFocus := oApl:nClrForeFocus
    oX:oLbxC:nHeaderHeight := 16
    oX:oLbxC:GoTop()
    oX:oLbxC:oFont      := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oX:oLbxC:aColSizes  := {60,70,30}
    oX:oLbxC:aHjustify  := {2,2,2}
    oX:oLbxC:aJustify   := {1,1,2}
    oX:oLbxC:lCellStyle := oX:oLbxC:ladjbrowse := .f.
    oX:oLbxC:ladjlastcol:= .t.
    oX:oLbxC:cToolTip := "[F2] Ayuda de Teclas"
    oX:oLbxC:bKeyDown := {|nKey| If(nKey=VK_RETURN, oX:Consulta( oApl:oCtl:CONTROL )   ,;
                                 If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT,;
                                                 oX:Consulta( 0 )    ,;
                                 If(nKey=VK_F2,  oX:Ayuda()          ,;
                                 If(nKey=VK_F3, (oX:ListaHis( oDlgA ), oGet[1]:SetFocus()),;
                                 If(nKey=VK_F5,  oX:ListaHis( oDlgA ,oApl:oCtl:CONTROL )  ,;
                                 If(nKey=VK_F6,  oX:ListaHis( oDlgA,,oApl:oCtl:CONTROL )  ,;
                                 If(nKey=VK_F7, HisLiRef( oX:nHisto,,3 ),;
                                 If(nKey=VK_F8, HisLiRef( oX:nHisto,,2 ),;
                                 If(nKey=VK_F9,  oX:Organiza( 1 )       ,;
                                 If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE,;
                                    oX:BorrarCtl( oApl:oCtl:CONTROL ), ) ))))))))) }
//                               If(nKey=VK_F7, HisRXFin( oX:nHisto ),;
//                               If(nKey=VK_F8, HisLCont( oX:nHisto ),;
   MySetBrowse( oX:oLbxC,oApl:oCtl )

   REDEFINE BUTTON ID 18 OF oDlgA CANCEL ACTION oX:Consulta( 0 )
   REDEFINE BUTTON ID 19 OF oDlgA CANCEL ACTION oX:Consulta( oApl:oCtl:CONTROL )
   REDEFINE BUTTON ID 23 OF oDlgA CANCEL ACTION HisLiRXF( oX:nHisto,oApl:oCtl:CONTROL )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlgA CENTER ON INIT;
   ( oX:DefBar( oDlgA,oDp,oGet )   ,;
     oGet[1]:oBtn:cToolTip := "[F2] Ayuda de Historias" )
oDp:oPr:oDb:Destroy()
 oX:oL:Cerrar()
RELEASE oX
RETURN

//------------------------------------//
CLASS THistorias

 DATA aAdi AS ARRAY INIT { " "   ,"0.25","0.50","0.75","1.00","1.25",;
                           "1.50","1.75","2.00","2.25","2.50","2.75",;
                           "3.00","3.25","3.50","3.75","4.00" }
 DATA aAvc AS ARRAY INIT { " "   ,"0.50","0.75","1.00","1.25","1.50",;
                           "1.75","2.00","3.00","4.00","5.00","6.00" }
 DATA aAvl AS ARRAY INIT { " " ,"10","13","15","20","25","30","40","50","60","70","80",;
                           "90","100","150","200","300","400","500","600","800","900" ,;
                           "10-","13-","15-","20-","25-","30-","40-","50-","60-","70-",;
                           "80-","90-","100-","150-","200-","300-","400-" }
 DATA aCil AS ARRAY INIT { " " }
 DATA aEsf AS ARRAY INIT { " ","0.00" }
 DATA aHis AS ARRAY INIT { .f.,.f.,.f.,.f.,.f.,.f.,.f.,.f.,.f.,;
                           .f.,.f.,.f.,.f.,.f.,.f.,.f.,.f.,.f. }
 DATA aOjo AS ARRAY INIT { {"Derecho 1","D"},{"Izquierdo 1","I"},;
                           {"Derecho 2","d"},{"Izquierdo 2","i"},{"Ambos Ojos","A"} }
 DATA nPH           INIT 9
 DATA oBtn          INIT ARRAY(5)
 DATA aCba, aCtl, aQue, aPrv, cNom, nHisto, nSigte, oL, oLbxC

 METHOD NEW() Constructor
 METHOD Ayuda( oGet )
 METHOD Consulta( nCtl )
 METHOD Diagnostico( aDG,oLbx,nD )
 METHOD VNumeros( sDato )
 METHOD MotivosCons()
 METHOD AgudezaVisu()
 METHOD CorreccionU()
 METHOD ExamenExter()
 METHOD Queratometr()
 METHOD Retinoscopi()
 METHOD Oftalmocopi()
 METHOD Observacion( oGet,nP )
 METHOD BorrarCtl( nCtl )
 METHOD BorrarDat( oTB,nP,oLbx )
 METHOD Cambios( nP,xGet,xVar,lVacio )
 METHOD Cancelar( aOld,oTB,nB,nP,lCan )
 METHOD Grabando( oDlg,aDG,cTD )
 METHOD Organiza( xOrg )
 METHOD CambiaCtl( oBase,nCtl1,nCtl2,nCtlB )
 METHOD ListaHis( oDlg,nCtl,nDesde )
 METHOD DefBar( oDlg,oDp,oGet )
ENDCLASS

//------------------------------------//
METHOD NEW( lCtl ) CLASS THistorias
   LOCAL aPod, cDocID, nCB
If lCtl == NIL
   oApl:oEmp:Seek( {"localiz",oApl:oEmp:TITULAR} )
   aPod := Buscar( "SELECT * FROM hispoder","CM",,8 )
   If LEN( aPod ) == 0
      //          PC   ,PCT,CB  ,CBT,ESF_D,ESF_A,CIL_A
      aPod := { 0,36.00,194,7.10,40 ,0.25 ,22   ,10.0 }
   EndIf

   ::aPrv := Privileg( "HISTORIAS" )
   ::aQue := ARRAY( aPod[3] ) //PCT (60-PC*8+2)
   ::aCba := ARRAY( aPod[5] ) //CBT
   ::aCba[1] := ::aQue[1] := " "
   nCB := aPod[4]             //CB
   AEVAL( ::aCba, {|cVal,nI| ::aCba[nI] := STR(nCB,4,2), nCB += .05 },2 )
   nCB := aPod[2]             //PC
   AEVAL( ::aQue, {|cVal,nI| ::aQue[nI] := LEFT(STR(nCB,6,3),5), nCB += .125},2 )
   FOR nCB := aPod[6] TO aPod[7] STEP .25
      cDocID := LTRIM( STR( nCB,5,2 ) )
      AADD( ::aEsf, "+"+cDocID )
      AADD( ::aEsf, "-"+cDocID )
      If nCB <= aPod[8]
         AADD( ::aCil, "-"+cDocID )
      EndIf
   NEXT nCB
    oApl:oCtl:Seek( {"optica",oApl:nEmpresa,"nro_histor",0,"control = ",1} )
   ::nSigte := oApl:oEmp:NRO_HISTOR + 1
   ::oL   := TRip() ; ::oL:New( 7 )
Else
   If lCtl
      oApl:oCtl:OBSERV_DIA := ALLTRIM( oApl:oCtl:OBSERV_DIA )
      oApl:oCtl:MOTIVO_CON := ALLTRIM( oApl:oCtl:MOTIVO_CON )
   EndIf
      oApl:oAgv:OBSERV_AV  := ALLTRIM( oApl:oAgv:OBSERV_AV )
      oApl:oAgv:OBSERV_RXU := ALLTRIM( oApl:oAgv:OBSERV_RXU )
      oApl:oExa:EXAMEN_EXT := ALLTRIM( oApl:oExa:EXAMEN_EXT )
      oApl:oQue:OBSERV_OT  := ALLTRIM( oApl:oQue:OBSERV_OT )
      oApl:oRet:OBSERV_RT  := ALLTRIM( oApl:oRet:OBSERV_RT )
      oApl:oOft:OBSERV_OF  := ALLTRIM( oApl:oOft:OBSERV_OF )
EndIf
RETURN NIL

//------------------------------------//
METHOD Ayuda( oGet ) CLASS THistorias

If oGet == NIL
   oGet := "[F3] Historia Completa"              + CRLF +;
           "[F5] Imprime un Control"             + CRLF +;
           "[F6] Desde X Control hasta el Final" + CRLF +;
           "[F7] Historial RX Final"             + CRLF +;
           "[F8] Historial LContacto"            + CRLF +;
           "[Ctrl] + [Enter] Insertar Linea en las Notas"
   MsgStop( oGet,"<<< AYUDA >>>" )
Else
   AEVAL( ::aHis,{|cV,nI| ::aHis[nI] := .f. } )
   ::cNom     := XTRIM(oApl:oHis:NOMBRES) + oApl:oHis:APELLIDOS
   ::nHisto   := oApl:oHis:NRO_HISTOR
   ::aHis[1]  := .t.
   ::aHis[2]  := oApl:oAna:Seek( {"nro_histor",::nHisto} )
   ::aHis[11] := !::aHis[2]
   oApl:oAna:APERSONAL := ALLTRIM( oApl:oAna:APERSONAL )
   oApl:oAna:AFAMILIAR := ALLTRIM( oApl:oAna:AFAMILIAR )
   ::Organiza()
   ::oLbxC:GoBottom()
   oGet[3]:Refresh()
   oGet[4]:Refresh()
   If ::aHis[2]
      ::oBtn[2]:Disable()
      oGet[1]:oJump := ::oLbxC
   Else
      ::oBtn[2]:Enable()
      oApl:oAna:FEC_HISTOR := DATE()
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Consulta( nCtl ) CLASS THistorias
   LOCAL oDlgC, oRxf, oLco, oSub, oGet := ARRAY(14)
   LOCAL nLC, aRX := {}, aLC := {}, aSJ := {}
   LOCAL bGraba, oC := Self
If nCtl == 0
   ::oLbxC:GoBottom()
   nCtl := oApl:oCtl:CONTROL + 1
   oApl:oCtl:xBlank()
   ::aCtl := ACLONE( oApl:oCtl:axBuffer )
   oApl:oCtl:FECHA   := DATE()
   ::aHis[03] := ::aHis[9] := .f.
   ::aHis[12] := .t.
Else
   ::aCtl := ACLONE( oApl:oCtl:axBuffer )
   ::aHis[03] := .t. ; ::aHis[12] := .f.
   ::aHis[09] := (oApl:nEmpresa != oApl:oCtl:OPTICA)
EndIf
bGraba := { |nP| ::aHis[18] := If(  ::aHis[09], .f.,;
                               If( !::aHis[nP], .t., ::aPrv[2] ) ) }
::aHis[4] := oApl:oAgv:Seek( {"optica",oApl:nEmpresa,"nro_histor",::nHisto,"control",nCtl} )
::aHis[5] := oApl:oExa:Seek( {"optica",oApl:nEmpresa,"nro_histor",::nHisto,"control",nCtl} )
::aHis[6] := oApl:oQue:Seek( {"optica",oApl:nEmpresa,"nro_histor",::nHisto,"control",nCtl} )
::aHis[7] := oApl:oRet:Seek( {"optica",oApl:nEmpresa,"nro_histor",::nHisto,"control",nCtl} )
::aHis[8] := oApl:oOft:Seek( {"optica",oApl:nEmpresa,"nro_histor",::nHisto,"control",nCtl} )
             oApl:oDgn:Seek( {"optica",oApl:nEmpresa,"nro_histor",::nHisto,"control",nCtl},"ladolente" ) //9
While !oApl:oDgn:Eof()
   ::oL:oDb:Seek( {"codigo",oApl:oDgn:CODIGO} )    //TIPOLO y ODTIPOLC, OITIPOLC
   If oApl:oDgn:TIPODGN == "R"
      AADD( aRX, { oApl:oDgn:LADOLENTE,oApl:oDgn:CODIGO  ,::oL:oDb:NOMBRE  ,;
                   oApl:oDgn:ESFERA   ,oApl:oDgn:CILINDRO,oApl:oDgn:EJE    ,;
                   oApl:oDgn:ADICION  ,oApl:oDgn:AVL     ,oApl:oDgn:AVC    ,;
                   oApl:oDgn:DP_CB, "","", "", "", "", "",oApl:oDgn:ROW_ID , .f. } )
   ElseIf oApl:oDgn:TIPODGN == "C"
      AADD( aLC, { oApl:oDgn:LADOLENTE,oApl:oDgn:CODIGO  ,::oL:oDb:NOMBRE  ,;
                   oApl:oDgn:ESFERA   ,oApl:oDgn:CILINDRO,oApl:oDgn:EJE    ,;
                   oApl:oDgn:ADICION  ,oApl:oDgn:AVL     ,oApl:oDgn:AVC    ,;
                   oApl:oDgn:DP_CB    ,oApl:oDgn:DIAMETRO,oApl:oDgn:ECENTRO,;
                   oApl:oDgn:EBORDE   ,oApl:oDgn:ZOPTICA ,oApl:oDgn:TIPOADD,;
                   oApl:oDgn:CBASE    ,oApl:oDgn:ROW_ID , .f. } )
   Else
      AADD( aSJ, { oApl:oDgn:LADOLENTE, ""               , ""              ,;
                   oApl:oDgn:ESFERA   ,oApl:oDgn:CILINDRO,oApl:oDgn:EJE    ,;
                   oApl:oDgn:ADICION  ,oApl:oDgn:AVL     ,oApl:oDgn:AVC    ,;
                   "",""              ,"", "", "", "", "",oApl:oDgn:ROW_ID , .f. } )
   EndIf
   oApl:oDgn:Skip(1):Read()
   oApl:oDgn:xLoad()
EndDo
If LEN( aRX ) == 0
   AADD( aRX,{ "D","      ","","","","   ","","    ","    ","         ","","","","","","",0, .f. } )
EndIf
If LEN( aLC ) == 0
   AADD( aLC,{ "D","      ","","","","   ","","    ","    ","","      ","     ","     ",;
               "     ","",SPACE(12),0, .f. } )
EndIf
If LEN( aSJ ) == 0
   AADD( aSJ,{ "D","","","","","   ","","    ","    ","","","","","","","",0, .f. } )
EndIf
::NEW( .t. )

DEFINE DIALOG oDlgC RESOURCE "Consulta" TITLE ;
   "RX Final de " + ::cNom COLOR nRGB( 214,223,247 )
   REDEFINE SAY VAR ::nHisto         ID  1 OF oDlgC COLOR "B+/W"
   REDEFINE SAY VAR nCtl             ID  3 OF oDlgC COLOR "B+/W"
   REDEFINE GET oApl:oCtl:FECHA      ID  5 OF oDlgC ;
      VALID ::Cambios( 3,oApl:oCtl:FECHA,::aCtl[4] )
   REDEFINE COMBOBOX oApl:oCtl:DOCTOR ITEMS oApl:aDoctor ID 7 OF oDlgC;
      VALID ::Cambios( 3,oApl:oCtl:DOCTOR,::aCtl[5] )
   REDEFINE LISTBOX oRxf        ;
      FIELDS "", "", "", "", "", "", "", "", ""  ;
      HEADERS "D/I","Tipo de Lente", "Esfera", "Cilindro", "Eje", ;
              "Adición", "A.V.Lejos", "A.V.Cerca", "D.Pupilar";
      ID  9 OF oDlgC UPDATE
    oRxf:nClrBackHead  := oApl:nClrBackHead
    oRxf:nClrForeHead  := oApl:nClrForeHead
    oRxf:SetColor(oApl:nClrFore,oApl:nClrBack)
    oRxf:nClrBackFocus := oApl:nClrBackFocus
    oRxf:nClrForeFocus := oApl:nClrForeFocus
    oRxf:nHeaderHeight := 20
    oRxf:oFont      := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oRxf:aColSizes  := {20,118,54,54,40,50,54,54,50}
    oRxf:aHjustify  := {2,2,2,2,2,2,2,2,2}
    oRxf:aJustify   := {2,0,1,1,1,1,1,1,1}
    oRxf:lCellStyle := oRxf:ladjbrowse := .f.
    oRxf:ladjlastcol:= .t.
    oRxf:cToolTip   := "[Insert] = Nuevo RX, [Enter] = Modificar, [Control]+[Delete] = Borrar"
    oRxf:nAt        := 1
    oRxf:bLine      := { || { aRX[oRxf:nAt][1], aRX[oRxf:nAt][3], aRX[oRxf:nAt][04],;
                              aRX[oRxf:nAt][5], aRX[oRxf:nAt][6], aRX[oRxf:nAt][07],;
                              aRX[oRxf:nAt][8], aRX[oRxf:nAt][9], aRX[oRxf:nAt][10] } }
    oRxf:bGoTop     := { || oRxf:nAt := 1 }
    oRxf:bGoBottom  := { || oRxf:nAt := EVAL( oRxf:bLogicLen ) }
    oRxf:bSkip      := { | nWant, nOld | nOld := oRxf:nAt, oRxf:nAt += nWant,;
                          oRxf:nAt := MAX( 1, MIN( oRxf:nAt, EVAL( oRxf:bLogicLen ) ) ),;
                          oRxf:nAt - nOld }
    oRxf:bLogicLen  := { || LEN( aRX ) }
    oRxf:cAlias     := "Array"
    oRxf:bKeyDown := {|nKey| If(nKey = VK_RETURN, ::Diagnostico( @aRX,oRxf,1,.f. ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, oGet[12]:Click(),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, ::BorrarDat( @aRX,9,oRxf ), ) ) ) }
   REDEFINE LISTBOX oLco        ;
      FIELDS "", "", "", "", "", "", "", "", ""  ;
      HEADERS "D/I","Tipo de Lente", "Curv.Base", "Diametro", "Esfera",;
              "Cilindro", "Eje", "Adición", "A.V.Lejos";
      ID 11 OF oDlgC UPDATE
    oLco:nClrBackHead  := oApl:nClrBackHead
    oLco:nClrForeHead  := oApl:nClrForeHead
    oLco:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLco:nClrBackFocus := oApl:nClrBackFocus
    oLco:nClrForeFocus := oApl:nClrForeFocus
    oLco:nHeaderHeight := 20
    oLco:oFont      := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLco:aColSizes  := {20,118,54,54,50,50,40,50,50}
    oLco:aHjustify  := {2,2,2,2,2,2,2,2,2}
    oLco:aJustify   := {2,0,1,1,1,1,1,1,1}
    oLco:lCellStyle := oLco:ladjbrowse := .f.
    oLco:ladjlastcol:= .t.
    oLco:cToolTip   := "[Insert] = Nuevo LC, [Enter] = Modificar, [Control]+[Delete] = Borrar"
    oLco:nAt        := 1
    oLco:bLine      := { || { aLC[oLco:nAt][01], aLC[oLco:nAt][3], aLC[oLco:nAt][10],;
                              aLC[oLco:nAt][11], aLC[oLco:nAt][4], aLC[oLco:nAt][05],;
                              aLC[oLco:nAt][06], aLC[oLco:nAt][7], aLC[oLco:nAt][08] } }
    oLco:bGoTop     := { || oLco:nAt := 1 }
    oLco:bGoBottom  := { || oLco:nAt := EVAL( oLco:bLogicLen ) }
    oLco:bSkip      := { | nWant, nOld | nOld := oLco:nAt, oLco:nAt += nWant,;
                          oLco:nAt := MAX( 1, MIN( oLco:nAt, EVAL( oLco:bLogicLen ) ) ),;
                          oLco:nAt - nOld }
    oLco:bLogicLen  := { || LEN( aLC ) }
    oLco:cAlias     := "Array"
    oLco:bKeyDown := {|nKey| If(nKey = VK_RETURN, ::Diagnostico( @aLC,oLco,2,.f. ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, oGet[13]:Click(),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, ::BorrarDat( @aLC,9,oLco ), ) ) ) }
   //Subjetivo
   REDEFINE LISTBOX oSub        ;
      FIELDS "", "", "", "", "", "", ""  ;
      HEADERS "D/I", "Esfera", "Cilindro", "Eje",;
              "Adición", "A.V.Lejos", "A.V.Cerca";
      ID 13 OF oDlgC UPDATE
    oSub:nClrBackHead  := oApl:nClrBackHead
    oSub:nClrForeHead  := oApl:nClrForeHead
    oSub:SetColor(oApl:nClrFore,oApl:nClrBack)
    oSub:nClrBackFocus := oApl:nClrBackFocus
    oSub:nClrForeFocus := oApl:nClrForeFocus
    oSub:nHeaderHeight := 20
    oSub:oFont      := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oSub:aColSizes  := {20,54,54,40,54,54,54}
    oSub:aHjustify  := {2,2,2,2,2,2,2}
    oSub:aJustify   := {2,1,1,1,1,1,1}
    oSub:lCellStyle := oSub:ladjbrowse := .f.
    oSub:ladjlastcol:= .t.
    oSub:cToolTip   := "[Insert] = Nuevo Subjetivo, [Enter] = Modificar, [Control]+[Delete] = Borrar"
    oSub:nAt        := 1
    oSub:bLine      := { || { aSJ[oSub:nAt][1], aSJ[oSub:nAt][4], aSJ[oSub:nAt][5],;
                              aSJ[oSub:nAt][6], aSJ[oSub:nAt][7], aSJ[oSub:nAt][8],;
                              aSJ[oSub:nAt][9] } }
    oSub:bGoTop     := { || oSub:nAt := 1 }
    oSub:bGoBottom  := { || oSub:nAt := EVAL( oSub:bLogicLen ) }
    oSub:bSkip      := { | nWant, nOld | nOld := oSub:nAt, oSub:nAt += nWant,;
                          oSub:nAt := MAX( 1, MIN( oSub:nAt, EVAL( oSub:bLogicLen ) ) ),;
                          oSub:nAt - nOld }
    oSub:bLogicLen  := { || LEN( aSJ ) }
    oSub:cAlias     := "Array"
    oSub:bKeyDown := {|nKey| If(nKey = VK_RETURN, ::Diagnostico( @aSJ,oSub,3,.f. ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, oGet[14]:Click(),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, ::BorrarDat( @aSJ,9,oSub ), ) ) ) }

   REDEFINE GET oApl:oCtl:FCHPROXCON ID 15 OF oDlgC;
      VALID ::Cambios( 3,oApl:oCtl:FCHPROXCON,::aCtl[12] )
   REDEFINE GET oApl:oCtl:MEDICAMENT ID 17 OF oDlgC;
      VALID ::Cambios( 3,oApl:oCtl:MEDICAMENT,::aCtl[10] )
   REDEFINE GET oApl:oCtl:REMITIR    ID 19 OF oDlgC;
      VALID ::Cambios( 3,oApl:oCtl:REMITIR,::aCtl[11] )
   REDEFINE GET oApl:oCtl:OBSERV_DIA ID 22 OF oDlgC MEMO;
      VALID ::Cambios( 3,oApl:oCtl:OBSERV_DIA,::aCtl[13] )
   REDEFINE GET oApl:oCtl:FAMILIAR   ID 24 OF oDlgC PICTURE "@!";
      VALID ::Cambios( 3,oApl:oCtl:FAMILIAR,::aCtl[14] )
   REDEFINE GET oApl:oCtl:TELEFONO   ID 26 OF oDlgC;
      VALID ::Cambios( 3,oApl:oCtl:TELEFONO,::aCtl[15] )

   REDEFINE BUTTON ID 30 OF oDlgC ACTION HisLiRef( ::nHisto,,3,.t. )
//      oGet[2]:cToolTip := "Imprime Resumen del Examen"
   REDEFINE BUTTON ID 31 OF oDlgC ACTION HisLiRef( ::nHisto,,2 )
   REDEFINE BUTTON ID 32 OF oDlgC ACTION HisLiRef( ::nHisto,,3,.f. )
   REDEFINE BUTTON ID 33 OF oDlgC ACTION ( EVAL( bGraba,3 ), ::MotivosCons() )
   REDEFINE BUTTON ID 34 OF oDlgC ACTION ( EVAL( bGraba,4 ), ::AgudezaVisu() )
   REDEFINE BUTTON ID 35 OF oDlgC ACTION ( EVAL( bGraba,4 ), ::CorreccionU() )
   REDEFINE BUTTON ID 36 OF oDlgC ACTION ( EVAL( bGraba,5 ), ::ExamenExter() )
   REDEFINE BUTTON ID 37 OF oDlgC ACTION ( EVAL( bGraba,6 ), ::Queratometr() )
   REDEFINE BUTTON ID 38 OF oDlgC ACTION ( EVAL( bGraba,7 ), ::Retinoscopi() )
   REDEFINE BUTTON ID 39 OF oDlgC ACTION ( EVAL( bGraba,8 ), ::Oftalmocopi() )

   REDEFINE BUTTON oGet[12] ID 40 OF oDlgC      ;
      ACTION ( ::Diagnostico( @aRX,oRxf,1,.t. ),;
               oGet[12]:SetText( "RX " + LTRIM(STR( LEN(aRX) ))) )
   REDEFINE BUTTON oGet[13] ID 41 OF oDlgC      ;
      ACTION ( ::Diagnostico( @aLC,oLco,2,.t. ),;
               oGet[13]:SetText( "LC " + LTRIM(STR( LEN(aLC) ))) )
   REDEFINE BUTTON oGet[14] ID 42 OF oDlgC      ;
      ACTION ( ::Diagnostico( @aSJ,oSub,3,.t. ),;
               oGet[14]:SetText( "SJ " + LTRIM(STR( LEN(aSJ) ))) )
ACTIVATE DIALOG oDlgC CENTER ON INIT;
  ( oC:DefBar( oDlgC ) ,;
    oGet[12]:SetText( "RX " + LTRIM(STR( LEN(aRX) ))) ,;
    oGet[13]:SetText( "LC " + LTRIM(STR( LEN(aLC) ))) ,;
    oGet[14]:SetText( "SJ " + LTRIM(STR( LEN(aSJ) ))) )
 oApl:oMot:Seek( {"tipo","03"} )
::oLbxC:SetFocus()
RETURN NIL

//-7----------------------------------//
METHOD Diagnostico( aDG,oLbx,nD,lNew ) CLASS THistorias
   LOCAL nA := oLbx:nAt, nOjo, oDlg, oGet := ARRAY(22), oE := Self
   LOCAL aEd := { "I","      ","","","","   ","","    ","    ","      ",;
                  "      ","     ","     ","     ","",SPACE(12),"","",.f.,0 }
If lNew
   nOjo := If( LEN( aDG ) == 1, 1, LEN( aDG ) -1 )
   AEVAL( aEd, { |xV,nP| aEd[20] += If( EMPTY(aDG[nOjo,nP]), 0, 1 ),;
                         aEd[nP] := aDG[nOjo,nP] },2,16 )
   nOjo := If( LEN( aDG ) == 1 .AND. aEd[20] == 0, 0, LEN( aDG ) )
   aEd[1] := ::aOjo[nOjo+1,2]
Else
   AEVAL( aEd, { |xV,nP| aEd[nP] := aDG[nA,nP] },1,16 )
EndIf
   aEd[17] := { "RX Final","Lentes de Contacto","Subjetivo" }[nD]
      nOjo := ArrayValor( ::aOjo,aEd[1],,.t. )
 ::aPrv[1] := If( ::aHis[9], .f., If( lNew .OR. aDG[nA,17] == 0, .t., ::aPrv[2] ) )
::oL:oDb:cWhere := "tipo_lente = '" + { "O","C","" }[nD] + "'"

DEFINE DIALOG oDlg TITLE aEd[17] FROM 0,0 TO 22,50
   @ 02,00 SAY "OJO"        OF oDlg RIGHT PIXEL SIZE 36,10
   @ 02,38 COMBOBOX oGet[1] VAR nOjo ITEMS ArrayCol( ::aOjo,1 );
      SIZE 42,99 OF oDlg PIXEL UPDATE
   @ 14,00 SAY "Código"     OF oDlg RIGHT PIXEL SIZE 36,10
   @ 14,38 BTNGET oGet[2] VAR aEd[2] OF oDlg PICTURE "9999!!!"        ;
      ACTION EVAL({|| If(oE:oL:Mostrar(), (aEd[2] := oE:oL:oDb:CODIGO,;
                         oGet[2]:Refresh() ), ) })                    ;
      VALID If( oE:oL:oDb:Seek( {"codigo",aEd[2]} ),                  ;
              ( aEd[3] := oE:oL:oDb:NOMBRE, oDlg:Update(), .t.), .f. );
      WHEN nD <= 2          SIZE 40,10 PIXEL RESOURCE "BUSCAR"
   @ 08, 80 SAY oGet[3] VAR aEd[3] OF oDlg PIXEL SIZE 120,18 ;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 26, 00 SAY "CB Keratoskon" OF oDlg RIGHT PIXEL SIZE 36,10
   @ 26, 38 GET oGet[4] VAR aEd[16] OF oDlg ;
      WHEN nD == 2   SIZE 40,10 PIXEL
   @ 38, 00 SAY "Curva Base LC" OF oDlg RIGHT PIXEL SIZE 36,10
   @ 38, 38 COMBOBOX oGet[5] VAR aEd[10] ITEMS ::aCba;
      WHEN nD == 2   SIZE 40,99 OF oDlg PIXEL
   @ 38, 80 SAY "Diametro"  OF oDlg RIGHT PIXEL SIZE 36,10
   @ 38,118 GET oGet[6] VAR aEd[11] OF oDlg ;
      WHEN nD == 2   SIZE 40,10 PIXEL
   @ 50, 00 SAY "Esfera"    OF oDlg RIGHT PIXEL SIZE 36,10
   @ 50, 38 COMBOBOX oGet[7] VAR aEd[4] ITEMS ::aEsf;
      SIZE 40,99 OF oDlg PIXEL
   @ 50, 80 SAY "Cilindro"  OF oDlg RIGHT PIXEL SIZE 36,10
   @ 50,118 COMBOBOX oGet[8] VAR aEd[5] ITEMS ::aCil;
      SIZE 40,99 OF oDlg PIXEL
   @ 62, 00 SAY "Eje"       OF oDlg RIGHT PIXEL SIZE 36,10
   @ 62, 38 GET oGet[9] VAR aEd[6] OF oDlg ;
      SIZE 40,10 PIXEL
   @ 62, 80 SAY "Adición"   OF oDlg RIGHT PIXEL SIZE 36,10
   @ 62,118 COMBOBOX oGet[10] VAR aEd[7] ITEMS ::aAdi;
      SIZE 40,99 OF oDlg PIXEL
   @ 74, 80 SAY "Tipo ADD"  OF oDlg RIGHT PIXEL SIZE 36,10
   @ 74,118 COMBOBOX oGet[11] VAR aEd[15] ITEMS {" ","N","D","HI","MED","LOW"};
      SIZE 40,99 OF oDlg PIXEL  WHEN nD == 2
   @ 74, 00 SAY "A.V.Lejos 20/" OF oDlg RIGHT PIXEL SIZE 36,10
   @ 74, 38 GET oGet[12] VAR aEd[08] OF oDlg ;
      SIZE 40,10 PIXEL
   @ 86, 00 SAY "A.V.Cerca 20/" OF oDlg RIGHT PIXEL SIZE 36,10
   @ 86, 38 GET oGet[13] VAR aEd[09] OF oDlg ;
      WHEN nD  # 2   SIZE 40,10 PIXEL
   @ 86, 80 SAY "D.Pupilar" OF oDlg RIGHT PIXEL SIZE 36,10
   @ 86,118 GET oGet[14] VAR aEd[10] OF oDlg ;
      VALID ::VNumeros( aEd[10] )            ;
      WHEN nD == 1   SIZE 40,10 PIXEL
   @ 98, 00 SAY "E.Centro"  OF oDlg RIGHT PIXEL SIZE 36,10
   @ 98, 38 GET oGet[15] VAR aEd[12] OF oDlg ;
      WHEN nD == 2   SIZE 40,10 PIXEL
   @ 98, 80 SAY "E.Borde"   OF oDlg RIGHT PIXEL SIZE 36,10
   @ 98,118 GET oGet[16] VAR aEd[13] OF oDlg ;
      WHEN nD == 2   SIZE 40,10 PIXEL
   @ 110, 00 SAY "Z.Optica"  OF oDlg RIGHT PIXEL SIZE 36,10
   @ 110, 38 GET oGet[17] VAR aEd[14] OF oDlg ;
      WHEN nD == 2   SIZE 40,10 PIXEL
   @ 122, 00 SAY "Fec.Compra"  OF oDlg RIGHT PIXEL SIZE 36,10
   @ 122, 38 GET oGet[18] VAR oApl:oCtl:FECHAFAC OF oDlg ;
      VALID ::Cambios( 3,oApl:oCtl:FECHAFAC,::aCtl[7] )  ;
      WHEN nD == 2   SIZE 40,10 PIXEL
   @ 122, 80 SAY "Fec.Entrega" OF oDlg RIGHT PIXEL SIZE 36,10
   @ 122,118 GET oGet[19] VAR oApl:oCtl:FECHAENT OF oDlg ;
      VALID ::Cambios( 3,oApl:oCtl:FECHAENT,::aCtl[8] )  ;
      WHEN nD == 2   SIZE 40,10 PIXEL
   @ 134, 00 SAY "Notas LC"    OF oDlg RIGHT PIXEL SIZE 36,10
   @ 134, 38 GET oGet[20] VAR oApl:oCtl:NOTAS_LC OF oDlg ;
      VALID ::Cambios( 3,oApl:oCtl:NOTAS_LC,::aCtl[9] )  ;
      WHEN nD == 2   SIZE 140,10 PIXEL

   @ 148, 70 BUTTON oGet[21] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION;
      ( aEd[18] := TRIM(aEd[4]) + TRIM(aEd[5]) + TRIM(aEd[7])          ,;
       If( EMPTY( aEd[18] )                                            ,;
         ( MsgStop( aEd[17],"Imposible GRABAR" ), oGet[1]:SetFocus() ) ,;
         ( aEd[19] := .t., oDlg:End() ) ) ) PIXEL
   @ 148,120 BUTTON oGet[22] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION ( oDlg:End() ) PIXEL
   ACTIVAGET(oGet)
   If !::aPrv[1]
      DesactivaALLGET(oGet,21)
      oGet[22]:SetFocus()
   EndIf
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
If aEd[19]
   aEd[01] := ::aOjo[nOjo,2]
   If lNew .AND. aEd[20] > 0
      If !EMPTY( aEd[18] )
         AADD( aDG,{ aEd[1],aEd[02],aEd[03],aEd[04],aEd[05],aEd[06],aEd[07],aEd[08],;
                     aEd[9],aEd[10],aEd[11],aEd[12],aEd[13],aEd[14],aEd[15],aEd[16],0,.t. } )
         nA := LEN( aDG )
      EndIf
   Else
      AEVAL( aEd, { |xV,nP| If( aDG[nA,nP] #  xV,;
                              ( aDG[nA,nP] := xV, aDG[nA,18] := .t.), ) },1,16 )
   EndIf
   If aDG[nA,18]
      ::Grabando( ,@aDG,{ "R","C","S" }[nD] )
      If ::oBtn[5]:lActive
         ::oBtn[5]:Disable()
      EndIf
      oLbx:Refresh()
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD VNumeros( sDato ) CLASS THistorias
   LOCAL nP, lOK := .t.
FOR nP := 1 TO LEN( sDato )
   If !SUBSTR( sDato,nP,1 ) $ "0123456789./ "
      MsgStop( "Solo Numeros, un Punto y un /",sDato )
      lOK := .f.
      EXIT
   EndIf
NEXT nP
RETURN lOK

//-1----------------------------------//
METHOD MotivosCons() CLASS THistorias
   LOCAL oDlg, oLbx, oGet := ARRAY(3), lOK := .f.
 oApl:oMot:Seek( {"tipo","02"} )
 oApl:oCtl:MOTIVO_CON := ALLTRIM( oApl:oCtl:MOTIVO_CON )
DEFINE DIALOG oDlg TITLE "Motivos de la Consulta - Signos y Síntomas" FROM 0,0 TO 18,80
   @ 06,06 LISTBOX oLbx FIELDS oApl:oMot:DESCRIPCIO  ;
      HEADERS "" COLOR CLR_BLACK, RGB( 255, 255, 235);
      SIZES 400, 450 SIZE 90,110 ;
      OF oDlg PIXEL              ;
      ON CLICK ( ::Observacion( oGet[1],3 ))
    oLbx:GoTop()
    oLbx:cToolTip   := "Haga Click sobre el Criterio"
   MySetBrowse( oLbx,oApl:oMot )

   @ 06,100 GET oGet[1] VAR oApl:oCtl:MOTIVO_CON OF oDlg MEMO ;
      SIZE 200,110 PIXEL UPDATE HSCROLL ;
      VALID ::Cambios( 3,oApl:oCtl:MOTIVO_CON,::aCtl[6] )

   @ 120,180 BUTTON oGet[2] PROMPT "GRABAR"   SIZE 40,12 OF oDlg ;
      ACTION ( lOK := .t., oDlg:End() ) PIXEL
   @ 120,230 BUTTON oGet[3] PROMPT "Cancelar" SIZE 40,12 OF oDlg CANCEL ;
      ACTION ( oDlg:End() ) PIXEL
   If !::aHis[18]      // Solo Consulta
      DesactivaALLGET(oGet,2)
      oGet[3]:SetFocus()
   EndIf
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
If !lOK
   oApl:oCtl:axBuffer[6] := ::aCtl[6]
   ::Cancelar( ::aCtl,oApl:oCtl,5,12,.t. )
EndIf
RETURN NIL

//-2.1--------------------------------//
METHOD AgudezaVisu() CLASS THistorias
   LOCAL aAgv := ACLONE( oApl:oAgv:axBuffer )
   LOCAL oDlg, oGet := ARRAY(19), lOK := .f.
DEFINE DIALOG oDlg TITLE "Agudeza Visual" FROM 0,0 TO 18,70
   @ 02, 26 SAY "Agudeza Visual Sin Corrección" OF oDlg PIXEL SIZE 100,10
   @ 14, 36 SAY "A.V.Lejos"                     OF oDlg PIXEL SIZE  40,10
   @ 14, 80 SAY "Pin Hole      A.V.Cerca"       OF oDlg PIXEL SIZE 100,10
   @ 26, 00 SAY "O.D. 20/"     OF oDlg RIGHT PIXEL SIZE 34,10
   @ 26, 36 COMBOBOX oGet[01] VAR oApl:oAgv:SCAVLOD   ITEMS ::aAvl;
      SIZE 26,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:SCAVLOD,aAgv[5] )
   @ 26, 64 SAY "20/"     OF oDlg RIGHT PIXEL SIZE 14,10
   @ 26, 80 COMBOBOX oGet[02] VAR oApl:oAgv:SCAVLODPH ITEMS ::aAvl;
      SIZE 26,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:SCAVLODPH,aAgv[6] )
   @ 26,108 COMBOBOX oGet[03] VAR oApl:oAgv:SCAVCOD   ITEMS ::aAvc;
      SIZE 26,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:SCAVCOD,aAgv[7] )
   @ 38, 00 SAY "O.I. 20/"     OF oDlg RIGHT PIXEL SIZE 34,10
   @ 38, 36 COMBOBOX oGet[04] VAR oApl:oAgv:SCAVLOI   ITEMS ::aAvl;
      SIZE 26,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:SCAVLOI,aAgv[8] )
   @ 38, 64 SAY "20/"     OF oDlg RIGHT PIXEL SIZE 14,10
   @ 38, 80 COMBOBOX oGet[05] VAR oApl:oAgv:SCAVLOIPH ITEMS ::aAvl;
      SIZE 26,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:SCAVLOIPH,aAgv[9] )
   @ 38,108 COMBOBOX oGet[06] VAR oApl:oAgv:SCAVCOI   ITEMS ::aAvc;
      SIZE 26,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:SCAVCOI,aAgv[10] )
   @ 50, 00 SAY "A.O. 20/"     OF oDlg RIGHT PIXEL SIZE 34,10
   @ 50, 36 COMBOBOX oGet[07] VAR oApl:oAgv:SCAVLAO   ITEMS ::aAvl;
      SIZE 26,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:SCAVLAO,aAgv[11] )
   @ 50, 64 SAY "20/"     OF oDlg RIGHT PIXEL SIZE 14,10
   @ 50, 80 COMBOBOX oGet[08] VAR oApl:oAgv:SCAVLAOPH ITEMS ::aAvl;
      SIZE 26,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:SCAVLAOPH,aAgv[12] )
   @ 50,108 COMBOBOX oGet[09] VAR oApl:oAgv:SCAVCAO   ITEMS ::aAvc;
      SIZE 26,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:SCAVCAO,aAgv[13] )
   @ 02,176 SAY "Agudeza Visual Con Corrección" OF oDlg PIXEL SIZE 100,10
   @ 14,196 SAY "A.V.Lejos     A.V.Cerca"       OF oDlg PIXEL SIZE 100,10
   @ 26,160 SAY "O.D. 20/"     OF oDlg RIGHT PIXEL SIZE 34,10
   @ 26,196 COMBOBOX oGet[10] VAR oApl:oAgv:CCAVLOD   ITEMS ::aAvl;
      SIZE 26,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:CCAVLOD,aAgv[14] )
   @ 26,224 COMBOBOX oGet[11] VAR oApl:oAgv:CCAVCOD   ITEMS ::aAvc;
      SIZE 26,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:CCAVCOD,aAgv[16] )
   @ 38,160 SAY "O.I. 20/"     OF oDlg RIGHT PIXEL SIZE 34,10
   @ 38,196 COMBOBOX oGet[12] VAR oApl:oAgv:CCAVLOI   ITEMS ::aAvl;
      SIZE 26,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:CCAVLOI,aAgv[17] )
   @ 38,224 COMBOBOX oGet[13] VAR oApl:oAgv:CCAVCOI   ITEMS ::aAvc;
      SIZE 26,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:CCAVCOI,aAgv[19] )
   @ 50,160 SAY "O.A. 20/"     OF oDlg RIGHT PIXEL SIZE 34,10
   @ 50,196 COMBOBOX oGet[14] VAR oApl:oAgv:CCAVLAO   ITEMS ::aAvl;
      SIZE 26,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:CCAVLAO,aAgv[20] )
   @ 50,224 COMBOBOX oGet[15] VAR oApl:oAgv:CCAVCAO   ITEMS ::aAvc;
      SIZE 26,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:CCAVCAO,aAgv[22] )
   @ 64, 00 SAY "Notas"        OF oDlg RIGHT PIXEL SIZE 34,10
   @ 64, 36 GET oGet[16] VAR oApl:oAgv:OBSERV_AV OF oDlg MEMO ;
      SIZE 214,40 PIXEL HSCROLL ;
      VALID ::Cambios( 4,oApl:oAgv:OBSERV_AV,aAgv[23] )

   @ 112,130 BUTTON oGet[17] PROMPT "GRABAR"   SIZE 40,12 OF oDlg ;
      ACTION ( lOK := .t., oDlg:End() ) PIXEL
   @ 112,180 BUTTON oGet[18] PROMPT "Cancelar" SIZE 40,12 OF oDlg CANCEL  ;
      ACTION ( oDlg:End() ) PIXEL
   @ 112,230 BUTTON oGet[19] PROMPT "BORRAR"   SIZE 40,12 OF oDlg CANCEL;
      ACTION ( ::BorrarDat( oApl:oAgv,4 ), oDlg:End() );
      WHEN ::aHis[4] PIXEL
   ACTIVAGET(oGet)
   If !::aHis[18]
      DesactivaALLGET(oGet,17)
      oGet[18]:SetFocus()
   EndIf
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
If lOK
   ::Cambios( 4,aAgv,oApl:oAgv:axBuffer )
Else
   ::Cancelar( aAgv,oApl:oAgv,5,13 )
EndIf
RETURN NIL

//-2.2--------------------------------//
METHOD CorreccionU() CLASS THistorias
   LOCAL aAgv := ACLONE( oApl:oAgv:axBuffer )
   LOCAL oDlg, oGet := ARRAY(28), lOK := .f.
DEFINE DIALOG oDlg TITLE "Corrección en Uso" FROM 0,0 TO 19,70
   @ 02, 26 SAY "Lensometría" OF oDlg PIXEL SIZE 100,10 COLOR nRGB( 0,0,255 )
   @ 12, 46 SAY "Esfera          Cilindro          Eje" OF oDlg PIXEL SIZE 100,10
   @ 24, 00 SAY "Visión Lejana OD" OF oDlg RIGHT PIXEL SIZE 44,10
   @ 22, 46 COMBOBOX oGet[01] VAR oApl:oAgv:LOVLODESF ITEMS ::aEsf;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:LOVLODESF,aAgv[24] )
   @ 22, 76 COMBOBOX oGet[02] VAR oApl:oAgv:LOVLODCIL ITEMS ::aCil;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:LOVLODCIL,aAgv[25] )
   @ 22,106 GET oGet[03] VAR oApl:oAgv:LOVLODEJE OF oDlg ;
      SIZE 20,10 PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:LOVLODEJE,aAgv[26] )
   @ 36, 00 SAY "Visión Lejana OI" OF oDlg RIGHT PIXEL SIZE 44,10
   @ 34, 46 COMBOBOX oGet[04] VAR oApl:oAgv:LOVLOIESF ITEMS ::aEsf;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:LOVLOIESF,aAgv[27] )
   @ 34, 76 COMBOBOX oGet[05] VAR oApl:oAgv:LOVLOICIL ITEMS ::aCil;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:LOVLOICIL,aAgv[28] )
   @ 34,106 GET oGet[06] VAR oApl:oAgv:LOVLOIEJE OF oDlg ;
      SIZE 20,10 PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:LOVLOIEJE,aAgv[29] )
   @ 48, 00 SAY "Tipo de Lente"    OF oDlg RIGHT PIXEL SIZE 44,10
   @ 46, 46 GET oGet[07] VAR oApl:oAgv:LOTIPO OF oDlg TEXT;
      SIZE 110,18 PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:LOTIPO,aAgv[38] )
   @ 12,186 SAY "Esfera          Cilindro          Eje" OF oDlg PIXEL SIZE 100,10
   @ 24,140 SAY "Visión Próxima OD" OF oDlg RIGHT PIXEL SIZE 44,10
   @ 22,186 COMBOBOX oGet[08] VAR oApl:oAgv:LOVPODESF ITEMS ::aEsf;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:LOVPODESF,aAgv[30] )
   @ 22,216 COMBOBOX oGet[09] VAR oApl:oAgv:LOVPODCIL ITEMS ::aCil;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:LOVPODCIL,aAgv[31] )
   @ 22,246 GET oGet[10] VAR oApl:oAgv:LOVPODEJE OF oDlg ;
      SIZE 20,10 PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:LOVPODEJE,aAgv[32] )
   @ 36,140 SAY "Visión Próxima OI" OF oDlg RIGHT PIXEL SIZE 44,10
   @ 34,186 COMBOBOX oGet[11] VAR oApl:oAgv:LOVPOIESF ITEMS ::aEsf;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:LOVPOIESF,aAgv[33] )
   @ 34,216 COMBOBOX oGet[12] VAR oApl:oAgv:LOVPOICIL ITEMS ::aCil;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:LOVPOICIL,aAgv[34] )
   @ 34,246 GET oGet[13] VAR oApl:oAgv:LOVPOIEJE OF oDlg ;
      SIZE 20,10 PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:LOVPOIEJE,aAgv[35] )
   @ 48,148 SAY "Adición OD"        OF oDlg RIGHT PIXEL SIZE 36,10
   @ 46,186 COMBOBOX oGet[14] VAR oApl:oAgv:LOODADD   ITEMS ::aAdi;
      SIZE 26,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:LOODADD,aAgv[36] )
   @ 48,214 SAY "Adición OI"        OF oDlg RIGHT PIXEL SIZE 30,10
   @ 46,246 COMBOBOX oGet[15] VAR oApl:oAgv:LOOIADD   ITEMS ::aAdi;
      SIZE 26,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:LOOIADD,aAgv[37] )
   @ 66, 26 SAY "Lentes de Contacto en uso" OF oDlg PIXEL SIZE 100,10 COLOR nRGB( 64,128,128 )
   @ 74, 46 SAY "Curva Base    Poder         Diámetro        Curva Periférica" ;
      OF oDlg PIXEL SIZE 140,10
   @ 86, 00 SAY "Ojo Derecho" OF oDlg RIGHT PIXEL SIZE 44,10
   @ 84, 46 COMBOBOX oGet[16] VAR oApl:oAgv:ODCURVABAS ITEMS ::aCba;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:ODCURVABAS,aAgv[39] )
   @ 84, 76 COMBOBOX oGet[17] VAR oApl:oAgv:ODPODER    ITEMS ::aEsf;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:ODPODER,aAgv[40] )
   @ 84,106 GET oGet[18] VAR oApl:oAgv:ODDIAMETRO OF oDlg ;
      SIZE 30,10 PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:ODDIAMETRO,aAgv[41] )
   @ 84,138 GET oGet[19] VAR oApl:oAgv:ODCURVAP OF oDlg ;
      SIZE 30,10 PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:ODCURVAP,aAgv[42] )
   @ 98, 00 SAY "Ojo Izquierdo" OF oDlg RIGHT PIXEL SIZE 44,10
   @ 96, 46 COMBOBOX oGet[20] VAR oApl:oAgv:OICURVABAS ITEMS ::aCba;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:OICURVABAS,aAgv[43] )
   @ 96, 76 COMBOBOX oGet[21] VAR oApl:oAgv:OIPODER    ITEMS ::aEsf;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:OIPODER,aAgv[44] )
   @ 96,106 GET oGet[22] VAR oApl:oAgv:OIDIAMETRO OF oDlg ;
      SIZE 30,10 PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:OIDIAMETRO,aAgv[45] )
   @ 96,138 GET oGet[23] VAR oApl:oAgv:OICURVAP OF oDlg ;
      SIZE 30,10 PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:OICURVAP,aAgv[46] )
   @ 96,170 SAY "Tipo de Lente"    OF oDlg RIGHT PIXEL SIZE 40,10
   @ 96,212 GET oGet[24] VAR oApl:oAgv:TIPOLC OF oDlg ;
      SIZE 50,10 PIXEL ;
      VALID ::Cambios( 4,oApl:oAgv:TIPOLC,aAgv[47] )
   @ 108, 00 SAY "Observaciones"    OF oDlg RIGHT PIXEL SIZE 44,10
   @ 108, 46 GET oGet[25] VAR oApl:oAgv:OBSERV_RXU OF oDlg MEMO ;
      SIZE 220,20 PIXEL HSCROLL ;
      VALID ::Cambios( 4,oApl:oAgv:OBSERV_RXU,aAgv[48] )

   @ 130,130 BUTTON oGet[26] PROMPT "GRABAR"   SIZE 40,12 OF oDlg ;
      ACTION ( lOK := .t., oDlg:End() ) PIXEL
   @ 130,180 BUTTON oGet[27] PROMPT "Cancelar" SIZE 40,12 OF oDlg CANCEL  ;
      ACTION ( oDlg:End() ) PIXEL
   @ 130,230 BUTTON oGet[28] PROMPT "BORRAR"   SIZE 40,12 OF oDlg CANCEL;
      ACTION ( ::BorrarDat( oApl:oAgv,4 ), oDlg:End() );
      WHEN ::aHis[4] PIXEL
   ACTIVAGET(oGet)
   If !::aHis[18]
      DesactivaALLGET(oGet,26)
      oGet[27]:SetFocus()
   EndIf
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
If lOK
   ::Cambios( 4,aAgv,oApl:oAgv:axBuffer )
Else
   ::Cancelar( aAgv,oApl:oAgv,5,13 )
EndIf
RETURN NIL

//-3----------------------------------//
METHOD ExamenExter() CLASS THistorias
   LOCAL aExa := ACLONE( oApl:oExa:axBuffer )
   LOCAL oDlg, oLbx, oGet := ARRAY(6), lOK := .f.
 oApl:oMot:Seek( {"tipo","03"} )
DEFINE DIALOG oDlg TITLE "Examen Externo" FROM 0,0 TO 19,80
   @ 06,06 LISTBOX oLbx FIELDS oApl:oMot:DESCRIPCIO ;
      HEADERS "" COLOR CLR_BLACK, RGB( 255,255,235 );
      SIZES 400, 450 SIZE 90,120 ;
      OF oDlg PIXEL              ;
      ON CLICK ( ::Observacion( oGet[3],5 ))
    oLbx:GoTop()
    oLbx:cToolTip   := "Haga Click sobre el Criterio"
   MySetBrowse( oLbx,oApl:oMot )

   @ 02,100 SAY "Presión IntraOcular" OF oDlg RIGHT PIXEL SIZE 90,10
   @ 14,110 SAY "O.D."                OF oDlg RIGHT PIXEL SIZE 20,10
   @ 12,132 GET oGet[1] VAR oApl:oExa:ODPINTRAOC OF oDlg ;
      SIZE 30,10 PIXEL ;
      VALID ::Cambios( 5,oApl:oExa:ODPINTRAOC,aExa[5] )
   @ 14,164 SAY "O.I."                OF oDlg RIGHT PIXEL SIZE 20,10
   @ 12,186 GET oGet[2] VAR oApl:oExa:OIPINTRAOC OF oDlg ;
      SIZE 30,10 PIXEL ;
      VALID ::Cambios( 5,oApl:oExa:OIPINTRAOC,aExa[6] )

   @ 24,100 GET oGet[3] VAR oApl:oExa:EXAMEN_EXT OF oDlg MEMO ;
      SIZE 190,102 PIXEL UPDATE HSCROLL ;
      VALID ::Cambios( 5,oApl:oExa:EXAMEN_EXT,aExa[7] )

   @ 130,130 BUTTON oGet[4] PROMPT "GRABAR"   SIZE 40,12 OF oDlg ;
      ACTION ( lOK := .t., oDlg:End() ) PIXEL
   @ 130,180 BUTTON oGet[5] PROMPT "Cancelar" SIZE 40,12 OF oDlg CANCEL  ;
      ACTION ( oDlg:End() ) PIXEL
   @ 130,230 BUTTON oGet[6] PROMPT "BORRAR"   SIZE 40,12 OF oDlg CANCEL;
      ACTION ( ::BorrarDat( oApl:oExa,5 ), oDlg:End() );
      WHEN ::aHis[5] PIXEL
   ACTIVAGET(oGet)
   If !::aHis[18]
      DesactivaALLGET(oGet,4)
      oGet[5]:SetFocus()
   EndIf
ACTIVATE DIALOG oDlg ON INIT ;
  ( oDlg:Move(240,200), oGet[1]:SetFocus() )
If lOK
   ::Cambios( 5,aExa,oApl:oExa:axBuffer )
Else
   ::Cancelar( aExa,oApl:oExa,5,14 )
EndIf
RETURN NIL

//-4----------------------------------//
METHOD Queratometr() CLASS THistorias
   LOCAL aQue := ACLONE( oApl:oQue:axBuffer )
   LOCAL oDlg, oLbx, oGet := ARRAY(13), lOK := .f.
DEFINE DIALOG oDlg TITLE "Queratometría" FROM 0,0 TO 18,70
   @ 02, 46 SAY "Plano        /  Curvo         *   Eje" OF oDlg PIXEL SIZE 100,10
   @ 14, 00 SAY "Ojo Derecho" OF oDlg RIGHT PIXEL SIZE 44,10
   @ 12, 46 COMBOBOX oGet[01] VAR oApl:oQue:ODPLANO ITEMS ::aQue;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 6,oApl:oQue:ODPLANO,aQue[05] )
   @ 12, 76 COMBOBOX oGet[02] VAR oApl:oQue:ODCURVO ITEMS ::aQue;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 6,oApl:oQue:ODCURVO,aQue[06] )
   @ 12,106 GET oGet[03] VAR oApl:oQue:ODEJE OF oDlg ;
      SIZE 20,10 PIXEL ;
      VALID ::Cambios( 6,oApl:oQue:ODEJE,aQue[07] )
   @ 26, 00 SAY "Ojo Izquierdo" OF oDlg RIGHT PIXEL SIZE 44,10
   @ 24, 46 COMBOBOX oGet[04] VAR oApl:oQue:OIPLANO ITEMS ::aQue;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 6,oApl:oQue:OIPLANO,aQue[08] )
   @ 24, 76 COMBOBOX oGet[05] VAR oApl:oQue:OICURVO ITEMS ::aQue;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 6,oApl:oQue:OICURVO,aQue[09] )
   @ 24,106 GET oGet[06] VAR oApl:oQue:OIEJE OF oDlg ;
      SIZE 20,10 PIXEL ;
      VALID ::Cambios( 6,oApl:oQue:OIEJE,aQue[10] )
   @ 20,140 BUTTON oGet[10] PROMPT "OI Igual a OD" SIZE 40,12 OF oDlg    ;
      ACTION ( oApl:oQue:OIPLANO := oApl:oQue:ODPLANO, oGet[4]:Refresh(),;
               oApl:oQue:OICURVO := oApl:oQue:ODCURVO, oGet[5]:Refresh(),;
               oApl:oQue:OIEJE   := oApl:oQue:ODEJE  , oGet[6]:Refresh() ) PIXEL
   @ 38, 00 SAY "Miras"         OF oDlg RIGHT PIXEL SIZE 44,10
   @ 36, 46 GET oGet[07] VAR oApl:oQue:MIRAS OF oDlg ;
      SIZE 160,12 PIXEL ;
      VALID ::Cambios( 6,oApl:oQue:MIRAS,aQue[11] )
   @ 50, 00 SAY "Equipo"        OF oDlg RIGHT PIXEL SIZE 44,10
   @ 48, 46 GET oGet[08] VAR oApl:oQue:EQUIPO OF oDlg ;
      SIZE 160,12 PIXEL ;
      VALID ::Cambios( 6,oApl:oQue:EQUIPO,aQue[12] )
   @ 62, 00 SAY "Observaciones"    OF oDlg RIGHT PIXEL SIZE 44,10
   @ 60, 46 GET oGet[09] VAR oApl:oQue:OBSERV_OT OF oDlg MEMO ;
      SIZE 200,50 PIXEL HSCROLL ;
      VALID ::Cambios( 6,oApl:oQue:OBSERV_OT,aQue[13] )

   @ 120,130 BUTTON oGet[11] PROMPT "GRABAR"   SIZE 40,12 OF oDlg ;
      ACTION ( lOK := .t., oDlg:End() ) PIXEL
   @ 120,180 BUTTON oGet[12] PROMPT "Cancelar" SIZE 40,12 OF oDlg CANCEL  ;
      ACTION ( oDlg:End() ) PIXEL
   @ 120,230 BUTTON oGet[13] PROMPT "BORRAR"   SIZE 40,12 OF oDlg CANCEL;
      ACTION ( ::BorrarDat( oApl:oQue,6 ), oDlg:End() );
      WHEN ::aHis[6] PIXEL
   ACTIVAGET(oGet)
   If !::aHis[18]
      DesactivaALLGET(oGet,11)
      oGet[11]:SetFocus()
   EndIf
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
If lOK
   ::Cambios( 6,aQue,oApl:oQue:axBuffer )
Else
   ::Cancelar( aQue,oApl:oQue,5,15 )
EndIf
RETURN NIL

//-5----------------------------------//
METHOD Retinoscopi() CLASS THistorias
   LOCAL aRet := ACLONE( oApl:oRet:axBuffer )
   LOCAL oDlg, oGet := ARRAY(24), lOK := .f.
DEFINE DIALOG oDlg TITLE "Retinoscopia" FROM 0,0 TO 18,70
   @ 02, 26 SAY "ESTATICA"      OF oDlg PIXEL SIZE 100,10 COLOR nRGB( 0,0,255 )
   @ 12, 46 SAY "Esfera          Cilindro          Eje" OF oDlg PIXEL SIZE 100,10
   @ 24, 00 SAY "Ojo Derecho"   OF oDlg RIGHT PIXEL SIZE 44,10
   @ 22, 46 COMBOBOX oGet[01] VAR oApl:oRet:ESTODESF ITEMS ::aEsf;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 7,oApl:oRet:ESTODESF,aRet[05] )
   @ 22, 76 COMBOBOX oGet[02] VAR oApl:oRet:ESTODCIL ITEMS ::aCil;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 7,oApl:oRet:ESTODCIL,aRet[06] )
   @ 22,106 GET oGet[03] VAR oApl:oRet:ESTODEJE OF oDlg ;
      SIZE 20,10 PIXEL ;
      VALID ::Cambios( 7,oApl:oRet:ESTODEJE,aRet[07] )
   @ 12,146 SAY "Agudeza Visual Lejos    Agudeza Visual Cerca" OF oDlg PIXEL SIZE 120,10
   @ 24,140 SAY "20/" OF oDlg RIGHT PIXEL SIZE 20,10
   @ 22,162 COMBOBOX oGet[04] VAR oApl:oRet:ESTODAVL ITEMS ::aAvl;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 7,oApl:oRet:ESTODAVL,aRet[08] )
   @ 22,222 COMBOBOX oGet[05] VAR oApl:oRet:ESTODAVC ITEMS ::aAvc;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 7,oApl:oRet:ESTODAVC,aRet[09] )
   @ 36, 00 SAY "Ojo Izquierdo" OF oDlg RIGHT PIXEL SIZE 44,10
   @ 34, 46 COMBOBOX oGet[06] VAR oApl:oRet:ESTOIESF ITEMS ::aEsf;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 7,oApl:oRet:ESTOIESF,aRet[10] )
   @ 34, 76 COMBOBOX oGet[07] VAR oApl:oRet:ESTOICIL ITEMS ::aCil;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 7,oApl:oRet:ESTOICIL,aRet[11] )
   @ 34,106 GET oGet[08] VAR oApl:oRet:ESTOIEJE OF oDlg ;
      SIZE 20,10 PIXEL ;
      VALID ::Cambios( 7,oApl:oRet:ESTOIEJE,aRet[12] )
   @ 36,140 SAY "20/" OF oDlg RIGHT PIXEL SIZE 20,10
   @ 34,162 COMBOBOX oGet[09] VAR oApl:oRet:ESTOIAVL ITEMS ::aAvl;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 7,oApl:oRet:ESTOIAVL,aRet[13] )
   @ 34,222 COMBOBOX oGet[10] VAR oApl:oRet:ESTOIAVC ITEMS ::aAvc;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 7,oApl:oRet:ESTOIAVC,aRet[14] )

   @ 48, 26 SAY "DINAMICA" OF oDlg PIXEL SIZE 100,10 COLOR nRGB( 64,128,128 )
   @ 56, 46 SAY "Esfera          Cilindro          Eje" OF oDlg PIXEL SIZE 100,10
   @ 68, 00 SAY "Ojo Derecho"   OF oDlg RIGHT PIXEL SIZE 44,10
   @ 66, 46 COMBOBOX oGet[11] VAR oApl:oRet:DINODESF ITEMS ::aEsf;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 7,oApl:oRet:DINODESF,aRet[15] )
   @ 66, 76 COMBOBOX oGet[12] VAR oApl:oRet:DINODCIL ITEMS ::aCil;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 7,oApl:oRet:DINODCIL,aRet[16] )
   @ 66,106 GET oGet[13] VAR oApl:oRet:DINODEJE OF oDlg ;
      SIZE 20,10 PIXEL ;
      VALID ::Cambios( 7,oApl:oRet:DINODEJE,aRet[17] )
   @ 56,146 SAY "Agudeza Visual Lejos    Agudeza Visual Cerca" OF oDlg PIXEL SIZE 120,10
   @ 68,140 SAY "20/" OF oDlg RIGHT PIXEL SIZE 20,10
   @ 66,162 COMBOBOX oGet[14] VAR oApl:oRet:DINODAVL ITEMS ::aAvl;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 7,oApl:oRet:DINODAVL,aRet[18] )
   @ 66,222 COMBOBOX oGet[15] VAR oApl:oRet:DINODAVC ITEMS ::aAvc;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 7,oApl:oRet:DINODAVC,aRet[19] )
   @ 80, 00 SAY "Ojo Izquierdo" OF oDlg RIGHT PIXEL SIZE 44,10
   @ 78, 46 COMBOBOX oGet[16] VAR oApl:oRet:DINOIESF ITEMS ::aEsf;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 7,oApl:oRet:DINOIESF,aRet[20] )
   @ 78, 76 COMBOBOX oGet[17] VAR oApl:oRet:DINOICIL ITEMS ::aCil;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 7,oApl:oRet:DINOICIL,aRet[21] )
   @ 78,106 GET oGet[18] VAR oApl:oRet:DINOIEJE OF oDlg ;
      SIZE 20,10 PIXEL ;
      VALID ::Cambios( 7,oApl:oRet:DINOIEJE,aRet[22] )
   @ 80,140 SAY "20/" OF oDlg RIGHT PIXEL SIZE 20,10
   @ 78,162 COMBOBOX oGet[19] VAR oApl:oRet:DINOIAVL ITEMS ::aAvl;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 7,oApl:oRet:DINOIAVL,aRet[23] )
   @ 78,222 COMBOBOX oGet[20] VAR oApl:oRet:DINOIAVC ITEMS ::aAvc;
      SIZE 28,99 OF oDlg PIXEL ;
      VALID ::Cambios( 7,oApl:oRet:DINOIAVC,aRet[24] )
   @ 92, 00 SAY "Observaciones"    OF oDlg RIGHT PIXEL SIZE 44,10
   @ 90, 46 GET oGet[21] VAR oApl:oRet:OBSERV_RT OF oDlg MEMO ;
      SIZE 202,30 PIXEL HSCROLL ;
      VALID ::Cambios( 7,oApl:oRet:OBSERV_RT,aRet[25] )

   @ 121,130 BUTTON oGet[22] PROMPT "GRABAR"   SIZE 40,12 OF oDlg ;
      ACTION ( lOK := .t., oDlg:End() ) PIXEL
   @ 121,180 BUTTON oGet[23] PROMPT "Cancelar" SIZE 40,12 OF oDlg CANCEL  ;
      ACTION ( oDlg:End() ) PIXEL
   @ 121,230 BUTTON oGet[24] PROMPT "BORRAR"   SIZE 40,12 OF oDlg CANCEL;
      ACTION ( ::BorrarDat( oApl:oRet,7 ), oDlg:End() );
      WHEN ::aHis[7] PIXEL
   ACTIVAGET(oGet)
   If !::aHis[18]
      DesactivaALLGET(oGet,22)
      oGet[23]:SetFocus()
   EndIf
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
If lOK
   ::Cambios( 7,aRet,oApl:oRet:axBuffer )
Else
   ::Cancelar( aRet,oApl:oRet,5,16 )
EndIf
RETURN NIL

//-6----------------------------------//
METHOD Oftalmocopi() CLASS THistorias
   LOCAL aOft := ACLONE( oApl:oOft:axBuffer )
   LOCAL oDlg, oLbx, oGet := ARRAY(13), lOK := .f.
DEFINE DIALOG oDlg TITLE "Oftalmoscopia" FROM 0,0 TO 18,80
   @ 02, 00 SAY "Tipo" OF oDlg RIGHT PIXEL SIZE 44,10
   @ 02, 46 COMBOBOX oGet[01] VAR oApl:oOft:TIPO  PROMPTS { "Directa","Indirecta" };
      SIZE 130,99 OF oDlg PIXEL ;
      VALID ::Cambios( 8,oApl:oOft:TIPO,aOft[05] )
/*    VALID ( If( !oGet[1]:Find(oGet[1]:GetText() )  ,;
                   oGet[1]:Add( oGet[1]:GetText() ),),;
             ::Cambios( 8,oApl:oOft:TIPO,aOft[05] ) )*/
   @ 14, 00 SAY "Poloposterior O.D." OF oDlg RIGHT PIXEL SIZE 44,10
   @ 14, 46 GET oGet[02] VAR oApl:oOft:ODPOLOPOST OF oDlg ;
      SIZE 100,10 PIXEL ;
      VALID ::Cambios( 8,oApl:oOft:ODPOLOPOST,aOft[06] )
   @ 14,148 SAY "Poloposterior O.I." OF oDlg RIGHT PIXEL SIZE 44,10
   @ 14,194 GET oGet[03] VAR oApl:oOft:OIPOLOPOST OF oDlg ;
      SIZE 100,10 PIXEL ;
      VALID ::Cambios( 8,oApl:oOft:OIPOLOPOST,aOft[10] )
   @ 26, 00 SAY "Excavación O.D."    OF oDlg RIGHT PIXEL SIZE 44,10
   @ 26, 46 GET oGet[04] VAR oApl:oOft:ODEXCAVA   OF oDlg ;
      SIZE 100,10 PIXEL ;
      VALID ::Cambios( 8,oApl:oOft:ODEXCAVA,aOft[07] )
   @ 26,148 SAY "Excavación O.I."    OF oDlg RIGHT PIXEL SIZE 44,10
   @ 26,194 GET oGet[05] VAR oApl:oOft:OIEXCAVA OF oDlg ;
      SIZE 100,10 PIXEL ;
      VALID ::Cambios( 8,oApl:oOft:OIEXCAVA,aOft[11] )
   @ 38, 00 SAY "Mácula O.D."        OF oDlg RIGHT PIXEL SIZE 44,10
   @ 38, 46 GET oGet[06] VAR oApl:oOft:ODMACULA   OF oDlg ;
      SIZE 100,10 PIXEL ;
      VALID ::Cambios( 8,oApl:oOft:ODMACULA,aOft[08] )
   @ 38,148 SAY "Mácula O.I."        OF oDlg RIGHT PIXEL SIZE 44,10
   @ 38,194 GET oGet[07] VAR oApl:oOft:OIMACULA OF oDlg ;
      SIZE 100,10 PIXEL ;
      VALID ::Cambios( 8,oApl:oOft:OIMACULA,aOft[12] )
   @ 50, 00 SAY "Fijación O.D."      OF oDlg RIGHT PIXEL SIZE 44,10
   @ 50, 46 GET oGet[08] VAR oApl:oOft:ODFIJACION   OF oDlg ;
      SIZE 100,10 PIXEL ;
      VALID ::Cambios( 8,oApl:oOft:ODFIJACION,aOft[09] )
   @ 50,148 SAY "Fijación O.I."      OF oDlg RIGHT PIXEL SIZE 44,10
   @ 50,194 GET oGet[09] VAR oApl:oOft:OIFIJACION OF oDlg ;
      SIZE 100,10 PIXEL ;
      VALID ::Cambios( 8,oApl:oOft:OIFIJACION,aOft[13] )
   @ 62, 00 SAY "Observaciones"    OF oDlg RIGHT PIXEL SIZE 44,10
   @ 62, 46 GET oGet[10] VAR oApl:oOft:OBSERV_OF OF oDlg MEMO ;
      SIZE 250,50 PIXEL HSCROLL ;
      VALID ::Cambios( 8,oApl:oOft:OBSERV_OF,aOft[14] )

   @ 117,160 BUTTON oGet[11] PROMPT "GRABAR"   SIZE 40,12 OF oDlg ;
      ACTION ( lOK := .t., oDlg:End() ) PIXEL
   @ 117,210 BUTTON oGet[12] PROMPT "Cancelar" SIZE 40,12 OF oDlg CANCEL;
      ACTION ( oDlg:End() ) PIXEL
   @ 117,260 BUTTON oGet[13] PROMPT "BORRAR"   SIZE 40,12 OF oDlg CANCEL;
      ACTION ( ::BorrarDat( oApl:oOft,8 ), oDlg:End() );
      WHEN ::aHis[8] PIXEL
   ACTIVAGET(oGet)
   If !::aHis[18]
      DesactivaALLGET(oGet,11)
      oGet[12]:SetFocus()
   EndIf
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
If lOK
   ::Cambios( 8,aOft,oApl:oOft:axBuffer )
Else
   ::Cancelar( aOft,oApl:oOft,5,17 )
EndIf
RETURN NIL

//------------------------------------//
METHOD Observacion( oGet,nP ) CLASS THistorias
   LOCAL cLinea, mObser, nL, nFin
   LOCAL cMotiv := TRIM(oApl:oMot:DESCRIPCIO), lNo := .t.
mObser := oGet:VarGet()
nFin   := MLCOUNT( mObser,50 )
FOR nL := 1 TO nFin
   cLinea := MEMOLINE( mObser,50,nL )
   If AT( cMotiv,cLinea ) > 0
      lNo := .f.
      EXIT
   EndIf
NEXT nL
If lNo
   mObser := cLinea := ALLTRIM( mObser )
   mObser += " " + cMotiv + " "
   ::Cambios( nP,mObser,cLinea )
   oGet:VarPut( mObser )
   oGet:Refresh()
// oGet:setText( mObser )
EndIf
RETURN NIL

//------------------------------------//
METHOD BorrarCtl( nCtl ) CLASS THistorias
   LOCAL aKey
If ::aPrv[3] .AND. nCtl > 0
   If Login( "Quiere Borrar este Control"+STR(nCtl) )
    //aKey := { "nro_histor",::nHisto,"control",nCtl }
      aKey := "DELETE FROM hisagvis "                         +;
              "WHERE optica = " + LTRIM(STR(oApl:oCtl:OPTICA))+;
           " AND nro_histor = " + LTRIM(STR(::nHisto))        +;
           " AND control    = " + LTRIM(STR(nCtl))
      Guardar( aKey,"hisagvis" )                                   //4
      Guardar( STRTRAN( aKey,"hisagvis","hisexame" ),"hisexame" )  //5
      Guardar( STRTRAN( aKey,"hisagvis","hisquera" ),"hisquera" )  //6
      Guardar( STRTRAN( aKey,"hisagvis","hisretin" ),"hisretin" )  //7
      Guardar( STRTRAN( aKey,"hisagvis","hisoftal" ),"hisoftal" )  //8
      Guardar( STRTRAN( aKey,"hisagvis","hisdiagn" ),"hisdiagn" )  //9
      If oApl:oCtl:Delete(.t.,1)
         PListbox( ::oLbxC,oApl:oCtl )
      EndIf
      AEVAL( ::aHis, {|cVal,nInd| ::aHis[nInd] := .f. },12 )
   EndIF
EndIf
RETURN NIL

//------------------------------------//
METHOD BorrarDat( oTB,nP,oLbx ) CLASS THistorias
   LOCAL cMsj, nPos, lOK := .t.
If ::aPrv[3] .AND. !::aHis[9]
   cMsj := { "Agudeza Visual","Examen Externo","Queratometría",;
             "Retinoscopia","Oftalmoscopía","Diagnósticos" }[nP-3]
   If Login( "Está seguro de Borrar "+cMsj )
      If oLbx == NIL
         If oTB:Delete(.f.,1)
            nPos := nP + ::nPH
            ::aHis[nP] := ::aHis[nPos] := .f.
         EndIf
      Else
         nPos := oLbx:nAt
         If oApl:oDgn:Seek( {"row_id",oTB[nPos,17]} )
            lOK := oApl:oDgn:Delete(.f.,1)
         EndIf
         If lOK
             ADEL( oTB, nPos )
            ASIZE( oTB, LEN( oTB ) - 1 )
            If LEN( oTB ) == 0
               AADD( oTB,{ "D","      ","","","","   ","","    ","    ","         ",;
                           "      ","     ","     ","     ","",SPACE(12),0, .f. } )
               // oTB := { "D","      ","","","","   ","","    ","    ","         ",;
               //          "      ","     ","     ","     ","",0, .f. }
            EndIf
            nPos     := LEN( oTB )
            oLbx:nAt := MAX( 1, MIN( oLbx:nAt, nPos ) )
            oLbx:Refresh()
         EndIf
      EndIf
   EndIF
EndIf
RETURN NIL

//------------------------------------//
METHOD Cambios( nP,xGet,xVar,lVacio ) CLASS THistorias
   LOCAL nPos := nP + ::nPH
   DEFAULT lVacio := .f.
If VALTYPE( xGet ) == "A"
   ::aHis[nPos] := .f.
   AEVAL( xGet, { |xV,nP| If( xVar[nP] # xV,;
                            ( ::aHis[nPos] := .t. ), ) },5 )
   If ::aHis[nPos] .AND. !lVacio
      ::Grabando()
   EndIf
Else
   do Case
   Case lVacio .AND. EMPTY( xGet )
      MsgInfo( "Este campo no Puede quedar en Blanco",">>> OJO <<<<" )
      lVacio := .f.
   Case xGet # xVar .OR. (!::aHis[nP] .AND. !EMPTY( xGet ))
      nP   := If( nP <= 2, 2, 5 )
      ::aHis[nPos] := lVacio := .t.
      Botones( ::oBtn,nP,.t. )
   OtherWise
      lVacio := .t.
   EndCase
EndIf

RETURN lVacio

//------------------------------------//
METHOD Cancelar( aOld,oTB,nB,nP,lCan ) CLASS THistorias
   LOCAL nSI := 0
   DEFAULT lCan := .f.
   ::aHis[nP] := .f.
If aOld # NIL
   If lCan
      AEVAL( aOld, { |xV,nC| If( oTB:axBuffer[nC] # xV,;
                               ( ::aHis[nP] := .t. ), ) },5 )
   Else
      AEVAL( aOld, { |xV,nC| oTB:axBuffer[nC] := xV },5 )
   EndIf
   AEVAL( ::aHis, { |xV,nP| If( xV, nSI ++, ) },10 )
   If nSI == 0
      Botones( ::oBtn,nB,.f. )
   EndIf
Else
   FOR nSI := 5 TO oTB:nFieldCount
      If !EMPTY( oTB:axBuffer[nSI] )
         lCan := .t.
         EXIT
      EndIF
   NEXT nSI
   If lCan
      Guardar( oTB,!::aHis[nB],.t. )
      ::aHis[nB] := .t.
   ElseIf ::aHis[nB]
       If oTB:Delete(.f.,1)
          oTB:xBlank()
          ::aHis[nB] := .f.
       EndIf
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Grabando( oDlg,aDG,cTD ) CLASS THistorias
   LOCAL nP
If cTD # NIL .AND. cTD == "HN"
   If ::nHisto == 0
      If  !MsgYesNo("Historia #"+STR(::nSigte),"Quiere Hacer esta")
         RETURN NIL
      EndIf
   ElseIf !MsgYesNo( "Desea Guardar los Cambios" )
         RETURN NIL
   EndIf
EndIf

If ::nHisto == 0
 //::nHisto := Buscar( "SELECT sf_secuencia(0, 'HISTORIAS') FROM DUAL","CM" )
   ::nHisto := oApl:oHis:NRO_HISTOR := SgteNumero( "nro_histor",oApl:nEmpresa,.t. )
   ::nSigte := ::nHisto + 1
   Guardar( oApl:oHis,.f.,.f. )
   ::Organiza()
   If oDlg # NIL
      oDlg:Update()
   EndIf
EndIf
  nP := ::nPH    //9
If ::aHis[nP+2] .AND. ::aHis[1]
   //2_historic
   If !::aHis[2]
      oApl:oAna:OPTICA     := oApl:nEmpresa
      oApl:oAna:NRO_HISTOR := ::nHisto
      oApl:oAna:CODIGO_NIT := oApl:oHis:CODIGO_NIT
   EndIf
   Guardar( oApl:oAna,!::aHis[2],.t. )
   ::aHis[2]    := .t.
   ::aHis[nP+2] := .f.
EndIf
If ::aHis[nP+3] .AND. ::aHis[1]
   //3_hiscntrl
   If !::aHis[3]
      oApl:oCtl:OPTICA     := oApl:nEmpresa
      oApl:oCtl:NRO_HISTOR := ::nHisto
//    oApl:oCtl:CONTROL    := Buscar( "SELECT MAX(control) +1 FROM hiscntrl WHERE nro_histor = " +;
//                                    LTRIM(STR(::nHisto)),"CM" )
      Guardar( oApl:oCtl,.t.,.t. )
      PListbox( ::oLbxC,oApl:oCtl )
      ::oLbxC:GoBottom()
//    oApl:oCtl:GoBottom():Read()
//    oApl:oCtl:xLoad()
//    MsgInfo(oApl:oCtl:CONTROL,"Nuevo Control" )
   Else
      Guardar( oApl:oCtl,.f.,.t. )
   EndIf
   ::NEW( .t. )
   ::aCtl := ACLONE( oApl:oCtl:axBuffer )
   ::aHis[3]    := .t.
   ::aHis[nP+3] := .f.
EndIf
If ::aHis[nP+4] .AND. ::aHis[1]
   //4_hisagvis
   If !::aHis[4]
    //oApl:oAgv:CNTRL_ID   := oApl:oCtl:CNTRL_ID
      oApl:oAgv:OPTICA     := oApl:nEmpresa
      oApl:oAgv:NRO_HISTOR := ::nHisto
      oApl:oAgv:CONTROL    := oApl:oCtl:CONTROL
   EndIf
   ::Cancelar( ,oApl:oAgv,4,nP+4,.f. )
EndIf
If ::aHis[nP+5] .AND. ::aHis[1]
   //5_hisexame
   If !::aHis[5]
      oApl:oExa:OPTICA     := oApl:nEmpresa
      oApl:oExa:NRO_HISTOR := ::nHisto
      oApl:oExa:CONTROL    := oApl:oCtl:CONTROL
   EndIf
   ::Cancelar( ,oApl:oExa,5,nP+5,.f. )
EndIf
If ::aHis[nP+6] .AND. ::aHis[1]
   //6_hisquera
   If !::aHis[6]
      oApl:oQue:OPTICA     := oApl:nEmpresa
      oApl:oQue:NRO_HISTOR := ::nHisto
      oApl:oQue:CONTROL    := oApl:oCtl:CONTROL
   EndIf
   ::Cancelar( ,oApl:oQue,6,nP+6,.f. )
EndIf
If ::aHis[nP+7] .AND. ::aHis[1]
   //7_hisretin
   If !::aHis[7]
      oApl:oRet:OPTICA     := oApl:nEmpresa
      oApl:oRet:NRO_HISTOR := ::nHisto
      oApl:oRet:CONTROL    := oApl:oCtl:CONTROL
   EndIf
   ::Cancelar( ,oApl:oRet,7,nP+7,.f. )
EndIf
If ::aHis[nP+8] .AND. ::aHis[1]
   //8_hisoftal
   If !::aHis[8]
      oApl:oOft:OPTICA     := oApl:nEmpresa
      oApl:oOft:NRO_HISTOR := ::nHisto
      oApl:oOft:CONTROL    := oApl:oCtl:CONTROL
   EndIf
   ::Cancelar( ,oApl:oOft,8,nP+8,.f. )
EndIf
   // _hisdiagn
If aDG # NIL .AND. ::aHis[1]
   FOR nP := 1 TO LEN( aDG )
      If aDG[nP,18]
         If !oApl:oDgn:Seek( {"row_id",aDG[nP,17]} )
             oApl:oDgn:OPTICA     := oApl:nEmpresa
             oApl:oDgn:NRO_HISTOR := ::nHisto
             oApl:oDgn:CONTROL    := oApl:oCtl:CONTROL
         EndIf
             oApl:oDgn:TIPODGN    := cTD
             oApl:oDgn:LADOLENTE  := aDG[nP,01]
             oApl:oDgn:CODIGO     := aDG[nP,02]
             oApl:oDgn:ESFERA     := aDG[nP,04]
             oApl:oDgn:CILINDRO   := aDG[nP,05]
             oApl:oDgn:EJE        := aDG[nP,06]
             oApl:oDgn:ADICION    := aDG[nP,07]
             oApl:oDgn:TIPOADD    := aDG[nP,15]
             oApl:oDgn:AVL        := aDG[nP,08]
             oApl:oDgn:AVC        := aDG[nP,09]
             oApl:oDgn:DP_CB      := aDG[nP,10]
             oApl:oDgn:CBASE      := aDG[nP,16]
             oApl:oDgn:DIAMETRO   := aDG[nP,11]
             oApl:oDgn:ECENTRO    := aDG[nP,12]
             oApl:oDgn:EBORDE     := aDG[nP,13]
             oApl:oDgn:ZOPTICA    := aDG[nP,14]
         Guardar( oApl:oDgn,!oApl:oDgn:lOK,.t. )
         aDG[nP,17] := oApl:oDgn:ROW_ID
         aDG[nP,18] := .f.
      EndIf
   NEXT nP
EndIf

If oDlg # NIL
   Botones( ::oBtn,{2},.f. )
Else
   Botones( ::oBtn,{2,5},.f. )
EndIf

RETURN NIL

//------------------------------------//
METHOD Organiza( xOrg ) CLASS THistorias
   LOCAL aFec := {}, nC, nP, nCtl
If xOrg # NIL
   oApl:oCtl:GoTop():Read()
   oApl:oCtl:xLoad()
   While !oApl:oCtl:Eof()
      AADD( aFec, { oApl:oCtl:CONTROL, oApl:oCtl:FCHCTRL } )
      oApl:oCtl:Skip(1):Read()
      oApl:oCtl:xLoad()
      nCtl := oApl:oCtl:CONTROL + 1
   EndDo
   aFec := ASORT(aFec,,, { |x, y| x[2] < y[2] })
   FOR nC := 1 TO LEN( aFec )
      If aFec[nC,1] >  nC
         nP := ASCAN( aFec, {|aVal| aVal[1] == nC},nC )
         ::CambiaCtl( oApl:oAgv,nC,aFec[nC,1],nCtl )
         ::CambiaCtl( oApl:oExa,nC,aFec[nC,1],nCtl )
         ::CambiaCtl( oApl:oQue,nC,aFec[nC,1],nCtl )
         ::CambiaCtl( oApl:oRet,nC,aFec[nC,1],nCtl )
         ::CambiaCtl( oApl:oOft,nC,aFec[nC,1],nCtl )
         ::CambiaCtl( oApl:oDgn,nC,aFec[nC,1],nCtl )
         ::CambiaCtl( oApl:oCtl,nC,aFec[nC,1],nCtl )
         aFec[nP,1] := aFec[nC,1]
      EndIf
   NEXT nC
EndIf

 oApl:oCtl:Seek( {"optica",oApl:nEmpresa,"nro_histor",::nHisto,"control >= ",1} )
If ::oLbxC # NIL
   ::oLbxC:Refresh()
EndIf
RETURN NIL

//------------------------------------//
METHOD CambiaCtl( oBase,nCtl1,nCtl2,nCtlB ) CLASS THistorias
   LOCAL nRg := 0
//      cQry := "UPDATE hiscntrl SET control = " + LTRIM(STR(nCtlB))
//      cWhe := " WHERE optica    = " + LTRIM(STR(oApl:nEmpresa))+;
//         " AND nro_histor = [HIS]"                       +;
//         " AND control    = [CTL]"
If oBase:Seek( {"nro_histor",::nHisto,"control",nCtl1} )
   oBase:CONTROL := nCtlB
   oBase:Update( .t.,1 )
   nRg := oBase:RecNo()
EndIf
If oBase:Seek( {"nro_histor",::nHisto,"control",nCtl2} )
   oBase:CONTROL := nCtl1
   oBase:Update( .t.,1 )
EndIf
If nRg > 0
   oBase:Go(nRg):Read()
   oBase:CONTROL := nCtl2
   oBase:Update( .t.,1 )
EndIf
RETURN NIL

//------------------------------------//
METHOD ListaHis( oDlg,nCtl,nDesde ) CLASS THistorias
If !::aHis[1]
   MsgInfo( "Debes escoger Una Historia","<<<< OJO >>>>" )
   RETURN NIL
ElseIf ::nHisto == 0 .OR. ::oBtn[2]:lActive
   ::Grabando( oDlg )
EndIf
If oApl:oCtl:lOK
   oApl:oCtl:SetBookMark()
   If nCtl == NIL .AND. nDesde == NIL
      oApl:oCtl:GoTop():Read()
      oApl:oCtl:xLoad()
   EndIf
EndIf
HisLiRef( ::nHisto,nCtl )

If oApl:oCtl:nBookRow > 0
   oApl:oCtl:Go( oApl:oCtl:nBookRow ):Read()
   oApl:oCtl:xLoad()
 //oApl:oCtl:GoBookMark()
   oApl:oCtl:FreeBookmark()
EndIf
RETURN NIL

//------------------------------------//
METHOD DefBar( oDlg,oDp,oGet ) CLASS THistorias
   LOCAL oBar
   DEFINE BUTTONBAR oBar OF oDlg 3DLOOK SIZE 28,28
If oGet == NIL
   DEFINE BUTTON ::oBtn[5] RESOURCE "DEDISCO"  OF oBar NOBORDER;
      TOOLTIP "Grabar este Examen" ;
      ACTION ( ::Grabando(), ::oBtn[5]:Disable() )
   DEFINE BUTTON           RESOURCE "PRINT"    OF oBar NOBORDER;
      TOOLTIP "Imprime Resumen del Examen";
      ACTION( ::ListaHis( ,oApl:oCtl:CONTROL ), ::NEW( .f. ) ) GROUP
   DEFINE BUTTON           RESOURCE "DELREC"   OF oBar NOBORDER;
      TOOLTIP "Borrar Control"
   DEFINE BUTTON           RESOURCE "SALIR"    OF oBar NOBORDER;
      TOOLTIP "Regresa al Menu Principal"                 ;
      ACTION( If( ::oBtn[5]:lActive,                      ;
              If( MsgYesNo( "Desea Guardar los Cambios" ),;
                  ::Grabando( oDlg ), ), ), oDlg:End() ) GROUP
   ::oBtn[5]:Disable()
Else
// oBar := TBar():NewAt( 316,300,240,38,34,32,oDlg, .t.,"TOP", )
   DEFINE BUTTON ::oBtn[1] RESOURCE "CLIENTE"  OF oBar NOBORDER;
      TOOLTIP "Información Personal";
      ACTION( oDp:Editar( oDp:oDb:Recno(),.f. ), oGet[7]:SetFocus() ) ADJUST
   DEFINE BUTTON ::oBtn[2] RESOURCE "DEDISCO"  OF oBar NOBORDER;
      TOOLTIP "Graba está Anamnesi";
      ACTION( ::Grabando( oDlg ) )
   DEFINE BUTTON ::oBtn[3] RESOURCE "PRINT"    OF oBar NOBORDER;
      TOOLTIP "Imprime Resumen de la Historia - [F5] Un Control";
      ACTION( ::ListaHis( oDlg ), oGet[1]:SetFocus() ) GROUP
   DEFINE BUTTON ::oBtn[4] RESOURCE "SALIR"    OF oBar NOBORDER;
      TOOLTIP "Regresa al Menu Principal"                 ;
      ACTION( If( ::oBtn[2]:lActive,                      ;
                  ::Grabando( oDlg,,"HN" ), ), oDlg:End() ) GROUP
   ::oBtn[2]:Disable()
EndIf
/*
 oBar:bRClicked := {|| NIL }
 oBar:bLClicked := {|| NIL }
*/
RETURN oBar
/*
//------------------------------------//
FUNCTION ODIgualOI( nPag,oDlg )
   LOCAL nPos := 9
do Case
Case nPag == 51                    // Importar de RetinosCopia Estatica
   oX:oD:SDESFERA   := oX:oR:ESTODESF
   oX:oD:SDCILINDRO := oX:oR:ESTODCIL
   oX:oD:SDEJE      := oX:oR:ESTODEJE
   oX:oD:SVLOD      := oX:oR:ESTODAVL
   oX:oD:SVPOD      := oX:oR:ESTODAVC
   oX:oD:SIESFERA   := oX:oR:ESTOIESF
   oX:oD:SICILINDRO := oX:oR:ESTOICIL
   oX:oD:SIEJE      := oX:oR:ESTOIEJE
   oX:oD:SVLOI      := oX:oR:ESTOIAVL
   oX:oD:SVPOI      := oX:oR:ESTOIAVC
Case nPag == 52                    // Importar de RetinosCopia Dinamica
   oX:oD:SDESFERA   := oX:oR:DINODESF
   oX:oD:SDCILINDRO := oX:oR:DINODCIL
   oX:oD:SDEJE      := oX:oR:DINODEJE
   oX:oD:SVLOD      := oX:oR:DINODAVL
   oX:oD:SVPOD      := oX:oR:DINODAVC
   oX:oD:SIESFERA   := oX:oR:DINOIESF
   oX:oD:SICILINDRO := oX:oR:DINOICIL
   oX:oD:SIEJE      := oX:oR:DINOIEJE
   oX:oD:SVLOI      := oX:oR:DINOIAVL
   oX:oD:SVPOI      := oX:oR:DINOIAVC
Case nPag == 71
   oX:oD:SIESFERA   := oX:oD:SDESFERA
   oX:oD:SICILINDRO := oX:oD:SDCILINDRO
   oX:oD:SIEJE      := oX:oD:SDEJE
   oX:oD:SIADICION  := oX:oD:SDADICION
   oX:oD:SVLOI      := oX:oD:SVLOD
   oX:oD:SVPOI      := oX:oD:SVPOD
Case nPag == 72                    // Copiar a RX Final
   oX:oD:RXDESFERA  := oX:oD:SDESFERA
   oX:oD:RXDCILINDR := oX:oD:SDCILINDRO
   oX:oD:RXDEJE     := oX:oD:SDEJE
   oX:oD:RXDADICION := oX:oD:SDADICION
   oX:oD:RXVLOD     := oX:oD:SVLOD
   oX:oD:RXVPOD     := oX:oD:SVPOD
   oX:oD:RXIESFERA  := oX:oD:SIESFERA
   oX:oD:RXICILINDR := oX:oD:SICILINDRO
   oX:oD:RXIEJE     := oX:oD:SIEJE
   oX:oD:RXIADICION := oX:oD:SIADICION
   oX:oD:RXVLOI     := oX:oD:SVLOI
   oX:oD:RXVPOI     := oX:oD:SVPOI
Case nPag == 721                   // RX Final
   oX:oD:RXIESFERA  := oX:oD:RXDESFERA
   oX:oD:RXICILINDR := oX:oD:RXDCILINDR
   oX:oD:RXIEJE     := oX:oD:RXDEJE
   oX:oD:RXIADICION := oX:oD:RXDADICION
   oX:oD:RXVLOI     := oX:oD:RXVLOD
   oX:oD:RXVPOI     := oX:oD:RXVPOD
Case nPag == 73                    // Lentes de Contacto
   oX:oD:OITIPOLC   := oX:oD:ODTIPOLC
   oX:oD:OICURVABAS := oX:oD:ODCURVABAS
   oX:oD:OIDIAMETRO := oX:oD:ODDIAMETRO
   oX:oD:OIESFERA   := oX:oD:ODESFERA
   oX:oD:OICILINDRO := oX:oD:ODCILINDRO
   oX:oD:OIEJE      := oX:oD:ODEJE
   oX:oD:OIADICION  := oX:oD:ODADICION
   oX:oD:LCVLOI     := oX:oD:LCVLOD
   oX:oD:OIECENTRO  := oX:oD:ODECENTRO
   oX:oD:OIEBORDE   := oX:oD:ODEBORDE
   oX:oD:OIZOPTICA  := oX:oD:ODZOPTICA
EndCase
//Cambios( nPos,"C" )
oDlg:Update()
RETURN .t.
*/
//------------------------------------//
FUNCTION Botones( oBtn,nBtn,lActivar )
   DEFAULT lActivar := .t.
If lActivar
   If VALTYPE( nBtn ) == "A"
      AEVAL( nBtn,{ |nV| If( !oBtn[ nV ]:lActive ,;
                              oBtn[ nV ]:Enable(), ) } )
   ElseIf !oBtn[ nBtn ]:lActive
           oBtn[ nBtn ]:Enable()
   EndIf
Else
   If VALTYPE( nBtn ) == "A"
      AEVAL( nBtn,{ |nV| If( oBtn[ nV ]:lActive  ,;
                             oBtn[ nV ]:Disable(), ) } )
   ElseIf oBtn[ nBtn ]:lActive
          oBtn[ nBtn ]:Disable()
   EndIf
EndIf
RETURN NIL