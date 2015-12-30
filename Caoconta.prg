// Programa.: CAOCONTA.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Contabilizar las Compras.
#include "FiveWin.ch"

MEMVAR oApl

PROCEDURE Contabil()
   LOCAL aOP, oDlg, oFont, oBrw, oGet := ARRAY(10)
   LOCAL oCge := TContabil()
oCge:NEW()
aOP := { { "Compras Repo",{|| oCge:Contable( oGet ) } }  ,;
         { "Ventas"      ,{|| oCge:Ventas( oGet ) } }    ,;
         { "Reposiciones",{|| oCge:Reposicion( oGet ) } },;
         { "Traslados"   ,{|| oCge:Traslado( oGet ) } }  ,;
         { "Ajustes"     ,{|| oCge:Ajustes( oGet ) } }   ,;
         { "Nota Credito",{|| oCge:NCredito(oGet,oBrw) }},;
         { "Reci.Caja"   ,{|| oCge:RCaja( oGet ) } }     ,;
         { "Asentar ICA" ,{|| oCge:BaseICA( oGet,oBrw ) } } }
DEFINE FONT oFont NAME "Ms Sans Serif" SIZE 0, -8

DEFINE DIALOG oDLG TITLE "Contabilizar las Compras" FONT oFont FROM 4,10 TO 24,60
  @ 0.2, 1.0 SAY "Tipo de Ingreso" RIGHT SIZE 40,NIL
  @ 0.2, 6.5 COMBOBOX oGet[1] VAR oCge:aLS[1] PROMPTS ArrayCol( aOP,1 );
      SIZE 50,50 OF oDlg ;
      ON CHANGE( oCge:aLS[3] := { 0,DATE(),DATE(),DATE(),DATE(),;
                                    DATE(),DATE(),DATE() }[oCge:aLS[1]],;
                 oDlg:Update() )
  @ 1.1, 1.0 SAY "Fecha Inicial"   RIGHT SIZE 40 ,NIL
  @ 1.1, 6.5 GET oGet[2] VAR oCge:aLS[2] SIZE 36 ,NIL ;
      WHEN Rango( oCge:aLS[1],{ 2,3,4,5,6,7,8 } )
  @ 2.0, 1.0 SAY "Nro. de Ingreso" RIGHT SIZE 40 ,NIL
  @ 2.0, 6.5 GET oGet[3] VAR oCge:aLS[3] SIZE 36 ,NIL VALID ;
      EVAL( {|| If( oCge:aLS[1] >= 2, (oCge:aMV[1,8] := 1, .t.),;
               (If( oCge:ArmarInf( oGet ), (oBrw:Refresh(), .t. ), .f. )) ) } )
   // EVAL( {|| If( Rango( oCge:aLS[1],{ 2,3,4,5,6,7,8 } ), (oCge:aMV[1,8] := 1, .t.),;
  @ 3.0, 1.5 GET oGet[9] VAR oCge:aLS[11] SIZE 36, 10 ;
      WHEN oCge:aLS[1] == 2
  @ 2.9, 6.9 CHECKBOX oGet[10] VAR oCge:aLS[10] PROMPT "Ventas";
      SIZE 50,12 OF oDlg
  @ 0.2,21.5 SAY "Nro. Consecutivo" RIGHT SIZE 44,NIL
  @ 1.1,15.5 SAY oGet[4] VAR oCge:aLS[4] SIZE  40,NIL COLOR nRGB( 255,0,0 )
  @ 1.1,24.5 SAY oGet[5] VAR oCge:aLS[5] SIZE  40,NIL COLOR nRGB( 128,0,255 )
  @ 2.0,15.5 SAY oGet[6] VAR oCge:aLS[6] SIZE 115,NIL
  @ 4.1,1 LISTBOX oBrw ;
      FIELDS "", "", "", "", "" ;
      HEADERS "Cuenta", "InfA", "InfB", "Debito", "Credito";
      FIELDSIZES 66, 66, 66, 60, 60;
      OF oDlg          SIZE 180, 76;
      ON DBLCLICK MsgInfo( "Array row: " + Str( oBrw:nAt ) + CRLF + ;
                           "Array col: " + Str( oBrw:nAtCol( nCol ) ) )

   // bLine is a codeblock that returns an array
   // if you need a 'traditional column based browse' have a look at TcBrowse
// oBrw:SetArray( oCge:aMV )
   oBrw:nAt       := 1
   oBrw:bLine     := { || { oCge:aMV[oBrw:nAt,1], oCge:aMV[oBrw:nAt,2], oCge:aMV[oBrw:nAt,3],;
                      TRANSFORM( oCge:aMV[oBrw:nAt,7],"999,999,999"),;
                      TRANSFORM( oCge:aMV[oBrw:nAt,8],"999,999,999") } }
   oBrw:bGoTop    := { || oBrw:nAt := 1 }
   oBrw:bGoBottom := { || oBrw:nAt := EVAL( oBrw:bLogicLen ) }
   oBrw:bSkip     := { | nWant, nOld | nOld := oBrw:nAt, oBrw:nAt += nWant,;
                        oBrw:nAt := MAX( 1, MIN( oBrw:nAt, EVAL( oBrw:bLogicLen ) ) ),;
                        oBrw:nAt - nOld }
   oBrw:bLogicLen := { || LEN( oCge:aMV ) }
   oBrw:cAlias    := "Array"
/*
  @ 7.2,1 BUTTON oGet[7] "Grabar Mov" ACTION ;
      ( If( oCge:aMV[1,8] > 0, ;
          ( oGet[7]:Disable(), EVAL( aOP[ oCge:aLS[1] ] ),;
            oGet[7]:Enable() , oGet[3]:SetFocus() )      ,;
            MsgAlert( "NO HAY INFORMACION PARA GRABAR" ) ) )*/
  @ 7.5,1  BUTTON "Grabar Mov" ACTION ;
      ( If( oCge:aMV[1,8] > 0, (EVAL( aOP[ oCge:aLS[1],2 ] ), oGet[3]:SetFocus()),;
            MsgAlert( "NO HAY INFORMACION PARA GRABAR" ) ) )
  @ 7.5,14 BUTTON "&Cancelar"  ACTION oDlg:End()

ACTIVATE DIALOG oDlg CENTERED ON INIT PutFont(oDlg)
   oFont:End()
ConectaOff()
RETURN

//------------------------------------//
CLASS TContabil

 DATA aCC  INIT { "",0,"","",0,"","","","" }
 DATA aDC, oArf
 DATA aLS  INIT { 1,DATE(),0,"BOD",0,"","PR","4",.f.,.t.,0,0 }
 DATA aMV  INIT { { "Cuenta","InfA","InfB","InfC","InfD",0, 0, 0 } }


 METHOD NEW() Constructor
 METHOD ArmarInf( oGet )
 METHOD Reposicion( oGet )
 METHOD Ventas( oGet,nLO )
 METHOD Ordent( oGet )
 METHOD Traslado( oGet )
 METHOD Ajustes( oGet )
 METHOD NCredito( oGet,oBrw )
 METHOD Facturas( nCNit,aGT,aNC )
 METHOD RCaja( oGet )
 METHOD BaseICA( oGet,oBrw )
 METHOD BuscaCC( nCN,nCC,aDC,aGT,oGet,nF )
 METHOD BuscaCta( dFec,nE,cTipo,nO )
 METHOD BuscaNit( aGT,oGet,nC )
 METHOD Contable( oGet,xFec )
 METHOD INF( uVal,cSep )
 METHOD Dsctos( oLbd,nID )
 METHOD Editad( nID,oLbx,lNew )

ENDCLASS

//------OpenOdbc()--------------------//
METHOD NEW() CLASS TContabil
   LOCAL oDlg, oFont, oCombo
 DEFINE FONT oFont NAME "Ms Sans Serif" SIZE 0, -8

 DEFINE DIALOG oDLG TITLE "Apertura Del Dsn de Datos " FONT oFont FROM 4,10 TO 20,50
    @ 0.2,1 SAY "Nombre del Dsn"
    @ 1.8,1 SAY "Usuario"
    @ 3.2,1 SAY "Clave"

    @ 1.0,1 GET oApl:aDsn[1]    //::cDsn
    @ 2.8,1 GET oApl:aDsn[2]    //::cUser
    @ 4.6,1 GET oApl:aDsn[3]    //::cPass
    @ 5.5,1 CheckBox oCombo VAR oApl:aDsn[5];
       PROMPT "Validar Tablas Existentes "
     oCombo:cToolTip:="Inactiva Chequeo de ODBC, Optimiza el Acceso"
     oCombo:=NIL
    @ 6.5,1 CheckBox oCombo VAR oApl:aDsn[6];
       PROMPT ANSITOOEM("Sincroniza Conexción ")
     oCombo:cToolTip:="Sincroniza la conexción ODBC"

    @ 5.8,1   BUTTON "Conectar " ACTION IF( Conectar(), oDlg:End(), NIL )
    @ 5.8,14  BUTTON "Cancelar"  ACTION (oApl:oOdbc := NIL, oDlg:End())
 ACTIVATE DIALOG oDlg CENTERED ON INIT PutFont(oDlg)

 oFont:End()
 STORE NIL TO oFont,oDlg
RETURN NIL

//1-----------------------------------//
METHOD ArmarInf( oGet ) CLASS TContabil
   LOCAL aGT, nC, lOk := .f.
   LOCAL aRes, hRes, nL
aRes := "SELECT u.cliente, u.fechoy, c.optica, u.totaliva, u.totalfac, "+;
           "v.codart, v.precioven, c.row_id, e.principal, e.codigo_nit "+;
        "FROM cadrepoc c, cadempre e, cadfactu u, cadventa v " +;
        "WHERE c.numfac = " + xValToChar( ::aLS[3] )  +;
         " AND c.cgeconse = 0 AND e.optica = c.optica"+;
         " AND u.optica = 0   AND u.numfac = c.numfac"+;
         " AND u.tipo   = 'U' AND u.indicador <> 'A'" +;
         " AND v.optica = 0   AND v.numfac = u.numfac"+;
         " AND v.tipo   = u.tipo"
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   MsgStop( "Ingreso ya Está Contabilizado" )
   RETURN lOk
EndIf
aRes := MyReadRow( hRes )
AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
oApl:oNit:Seek( {"codigo_nit",aRes[10]} )
::aLS[5] := 0
::aLS[7] := "PR" ; ::aLS[8] := "4" ; ::aLS[9] := .f.
aGT  := ::BuscaCta( aRes[2],aRes[9],::aLS[8],aRes[3] )
//1_Fecha,2_Factura,3_Row_id,4_,5_Anomes,6_Descrip,7_Empresa,8_Nit,9_CodigoNit
oGet[4]:SetText( ArrayValor( oApl:aOptic,STR(aRes[3],2) ) )
   aGT[1,2]  := ::INF( ::aLS[3] )              //Numfac
   aGT[1,3]  := LTRIM( STR(aRes[8]) )          //Row_id
   aGT[1,6]  := aRes[1]                        //Descripcion
   aGT[1,8]  := 890110934                      //Nit
   aGT[6,7]  := aRes[4]                        //IVA
   ::aLS[12] := aRes[5] - aRes[4]              //Totalfac - Totaliva
   oApl:aInvme := Retenciones( aRes[2],::aLS[12],aRes[10] )
   aGT[08,5] := oApl:aInvme[6]                 //23654001  Retencion
   aGT[08,8] := oApl:aInvme[1]
   aGT[09,5] := oApl:aInvme[8]                 //23657003  CREE
   aGT[09,8] := oApl:aInvme[3]
   aGT[10,5] := oApl:aInvme[7]                 //23680101  Ret.ICA
   aGT[10,8] := oApl:aInvme[2]
   aGT[07,8] := aRes[5]-aGT[8,8]-aGT[9,8]-aGT[10,8] //PROVEDORES
 ::BuscaNit( @aGT,oGet )
 While nL > 0
    nC := If( LEFT(aRes[6],2) == "03", 4,;
          If( LEFT(aRes[6],2) == "04", 5, 3 ) )
    aGT[nC,7] += aRes[7]
    If (nL --) > 1
       aRes := MyReadRow( hRes )
       AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
    EndIf
 EndDo
 MSFreeResult( hRes )
lOK := ::BuscaNit( aGT )

RETURN lOk

//3-----------------------------------//
METHOD Reposicion( oGet ) CLASS TContabil
   LOCAL aCT, aGT, aRep, aRes, cQry, hRes, nE, nL
cQry := "SELECT c.numrep, c.fecharep, c.optica, "      +;
           "d.codigo, d.cantidad, d.pcosto, c.row_id " +;
        "FROM cadrepoc c, cadempre e, cadrepod d "     +;
        "WHERE c.fecharep >= " + xValToChar( ::aLS[2] )+;
         " AND c.fecharep <= " + xValToChar( ::aLS[3] )+;
         " AND c.optica = e.optica and e.principal = 4"+;
         " AND d.numrep = c.numrep"                    +;
         " AND d.indica <> 'B' ORDER BY c.numrep"
//       " AND (c.Cgeconse = 0 OR c.Cgeconse IS NULL)" +;
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRep := { aRes[1],aRes[7] }
   aCT  := ::BuscaCta( aRes[2],aRes[3],"9" )
   oGet[6]:SetText( "GENERANDO ASIENTOS" )
EndIf
::aLS[7] := "CR" ; ::aLS[8] := "9" ; ::aLS[9] := .t.
While nL > 0
   nE := { 3,0,4,5,1,2 }[VAL( Grupos( aRes[4] ) )]
   If nE > 0
      aRes[5] *= aRes[6]
      aCT[nE+1,7] += aRes[5]
      aCT[nE+6,8] += aRes[5]
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aRep[1] # aRes[1]
      aGT := {}
      FOR nE := 1 TO LEN( aCT )
         cQry:= If( nE <= 6, aCT[1,10], "008" )
         AADD( aGT, { aCT[nE,1],"","","","",;
                      aCT[nE,6],aCT[nE,7],aCT[nE,8],0,cQry } )
      NEXT nE
      aGT[1,2] := ::INF( aRep[1] )                     //Numrep
      aGT[1,3] := LTRIM( STR(aRep[2]) )                //Row_id
      aGT[1,6] := "SUMINISTRO MONTURAS,LIQUIDOS,ACCESORIOS"
      ::BuscaNit( aGT )
      If LEN( ::aMV ) > 2
         oGet[6]:SetText( "REP."+aGT[1,2] )
         ::Contable( oGet )
      EndIf
      aRep := { aRes[1],aRes[7] }
      aCT  := ::BuscaCta( aRes[2],aRes[3],"9" )
   EndIf
EndDo
MSFreeResult( hRes )
RETURN nil

//2-----------------------------------//
METHOD Ventas( oGet,nLO ) CLASS TContabil
   LOCAL aCV, aCT, aGT, aVT, aRes, hRes, nC, nE, nL
aVT  := "SELECT u.numfac, u.fechoy, u.cliente, u.totaldes, u.totaliva, "+;
             "u.totalfac, n.codigo, v.codart, v.cantidad, v.precioven, "+;
            "v.montoiva, v.pcosto, u.autoriza, u.orden, u.codigo_cli "  +;
        "FROM cadventa v, cadclien n, cadfactu u "      +;
        "WHERE u.optica = v.optica"                     +;
         " AND u.numfac = v.numfac"                     +;
         " AND u.tipo   = v.tipo"                       +;
         " AND u.optica = "  + LTRIM(STR(oApl:nEmpresa))+;
         " AND u.fechoy >= " + xValToChar( ::aLS[2] )   +;
         " AND u.fechoy <= " + xValToChar( ::aLS[3] )   +;
         " AND u.tipo   = "  + xValToChar(oApl:Tipo)    +;
         " AND u.numfac > 0 AND u.indicador <> 'A'"     +;
         " AND n.codigo_nit = u.codigo_nit ORDER BY u.numfac"
If ::aLS[11] > 0
   aVT := STRTRAN( aVT,"> 0","= "+LTRIM( STR(::aLS[11]) ) )
EndIf
hRes := If( MSQuery( oApl:oMySql:hConnect,aVT ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   aRes := { 0,::aLS[2] }
Else
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aVT := { .035,aRes[1],aRes[2],aRes[3],aRes[5],aRes[6],INT(aRes[7]),;
            aRes[13],aRes[14],aRes[15],.f. }
EndIf
   nE  := If( oApl:nEmpresa == 21 .AND. ::aLS[2] <= CTOD("31.08.2015"), 18, oApl:nEmpresa )
   aGT := ::BuscaCta( aRes[2],nE,"3" )
/*
If ::aLS[2] >= CTOD("01.08.2014")
   aGT[2,1] := "13050515"
   aGT[7,1] := "41359530"
   aGT[8,1] := "41359531"
EndIf
*/
   aCT := ACLONE( aGT )
::aLS[8] := "3"
::aLS[9] := .t.
// 1_01 Monturas  , 2_05 Varios      , 3_03 Liquidos,
// 4_04 Accesorios, 5_02 L.Oftalmicos, 6_60 L.Contacto
While nL > 0
      nE := VAL( Grupos( aRes[8] ) )
   If nE == 2 .AND. oApl:nEmpresa == 0
      If LEFT(aRes[8],4) == "0598"
         aGT[09,8] += aRes[10]  //42054001 DE PROPAGANDA
       //aVT[1] := 0
      Else
         aGT[10,8] += aRes[10]  //42352001 ADMINISTRATIVOS
         aVT[1] := .04
      EndIf
   ElseIf aRes[11] > 0
      aGT[7,8] += aRes[10]      //413595xx    GRAVADA
   Else
      aGT[8,8] += aRes[10]      //413595xx NO GRAVADA
   EndIf
   If nE # 2
      nE := { 3,0,4,5,1,2 }[nE]
      nC := aRes[12] * If(oApl:nEmpresa == 0, 1, aRes[9] )
      aGT[nE+12,7] += nC       //613595xx
      aGT[nE+17,8] += nC       //1435xx
      If nE == 3  //Consignacion
         ::BuscaNit( @aGT,aRes[8],nC )
      EndIf
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aVT[2] # aRes[1]
      aVT[4]   := If( EMPTY( aVT[4] ), "VARIOS", ALLTRIM(aVT[4]) )
      aGT[1,1] := aVT[3]                              //Fecha
      aGT[1,2] := LTRIM( STR( aVT[2] ) )              //Numfac
      aGT[1,6] := STRTRAN( aVT[4],"'"," " )           //Descripcion
      aGT[1,8] := If( oApl:nEmpresa == 1, 1, aVT[7] ) //Nit
      If aVT[7] == 0
         ::BuscaCC( 123,aVT[10],{aVT[4],""},@aGT,oGet )
      Else
         ::BuscaNit( @aGT,oGet )
      EndIf
      If aVT[3] >= CTOD("01.09.2013") .AND. aVT[3] <= CTOD("28.02.2014")
         //Ret.CREE
         aCV := PIva( aVT[3] )
         aGT[11,7] := aGT[12,8] := ROUND( (aVT[6] - aVT[5]) * aCV[9],0 )
       //aGT[11,7] := aGT[12,8] := ROUND( (aVT[6] - aVT[5]) * .003,0 )
      EndIf
      aCV := ACLONE( aGT )
      AEVAL( aCV,{|x| AFILL( x,0,7,2 ) },2,11 )
//AEVAL( <aMatriz> , <bBloque> , <nInicio>, <nPosiciones> )
//AFILL( <aDestino>, <expValor>, <nInicio>, <nPosiciones> )
      If oApl:nEmpresa == 18 .AND. TRIM(aVT[8]) == "FOCA"
         aCV[1,10] := "003"
           aVT[11] := .t.
      EndIf
      oGet[6]:SetText( "FAC."+aGT[1,2] )
      If ::aLS[10]
         If oApl:nEmpresa == 0
            oApl:oNit:Seek( {"codigo",aVT[7]} )
            ::aLS[12]:= aVT[6] - aVT[5]                //Totalfac - Totaliva
            oApl:aInvme := Retenciones( aVT[3],::aLS[12],oApl:oNit:CODIGO_NIT )
            aGT[3,5] := oApl:aInvme[6]                 //135515xx  FTE
            aGT[3,7] := oApl:aInvme[1]
            aGT[4,5] := oApl:aInvme[7]                 //13551801  ICA
            aGT[4,7] := oApl:aInvme[2]
            aGT[5,5] := oApl:aInvme[8]                 //13559502  CREE
            aGT[5,7] := oApl:aInvme[3]
         EndIf
         aGT[2,7] := aVT[6]-aGT[3,7]-aGT[4,7]-aGT[5,7] //130505xx
         aGT[6,8] := aVT[5]                            //24080101
         AEVAL( aGT,{|x| AFILL( x,0,7,2 ) },13 )
         ::aLS[7] := "VT" ; ::aLS[8] := "3"
         ::BuscaNit( aGT )
         If LEN( ::aMV ) > 2
            If aVT[11]
               FOR nE := 2 TO LEN( ::aMV ) -1
                  If !Rango( LEFT(::aMV[nE,1],2),{"13","24"} )
                     ::aMV[nE,9] := "003"
                  EndIf
               NEXT nE
            EndIf
            ::Contable( oGet )
         EndIf
      EndIf
         ::aLS[7] := "CV" ; ::aLS[8] := "9"
      If nLO == NIL .OR.;
        (nLO  # NIL .AND. aCV[18,8] > 0)
         aGT := ACLONE( aCV )
         ::BuscaNit( aGT )
         If LEN( ::aMV ) > 2
            ::Contable( oGet )
         EndIf
      EndIf
      //Ordenes de Talla
      If aVT[3] >= CTOD("01.10.2009") .AND.;
         aVT[9] > 0 .AND. aCV[18,8] > 0
         aGT := ACLONE( aCV )
         AEVAL( aGT,{|x| AFILL( x,0,7,2 ) },12 )
         aGT[01,2] := LTRIM(STR( aVT[9] ))
         aGT[18,7] := aGT[19,8] := aCV[18,8]
         aGT[19,1] := "26059501"
         aGT[18,2] := aGT[19,2] := "890112740"
         aGT[18,6] := aGT[19,6] := 1
         ::aLS[7] := "CO"
         ::BuscaNit( aGT )
         ::aMV[2,4] := "F." + aCV[1,2]
         ::Contable( oGet,1 )
      EndIf
      aVT := { .035,aRes[1],aRes[2],aRes[3],aRes[5],aRes[6],INT(aRes[7]),;
               aRes[13],aRes[14],aRes[15],.f. }
      aGT := ACLONE( aCT )
   EndIf
EndDo
MSFreeResult( hRes )

If ::aLS[2] < CTOD("01.10.2009") .OR. oApl:nEmpresa <= 1
   RETURN NIL
EndIf
aVT  := "SELECT c.numero, c.fecha, c.orden, c.cliente,"+;
         " d.cantidad, d.pcosto, d.codart, c.totalfac "+;
        "FROM cadantid d, cadantic c "                 +;
        "WHERE d.codart IN('0201', '0202', '0503', '0505')"+;
         " AND c.optica = d.optica"                    +;
         " AND c.numero = d.numero"                    +;
         " AND c.optica = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fecha >= " + xValToChar( ::aLS[2] )   +;
         " AND c.fecha <= " + xValToChar( ::aLS[3] )   + If( ::aLS[11] > 0,;
         " AND c.numero = " + LTRIM(STR(::aLS[11])), "" )+;
         " AND c.orden  > 0"                           +;
         " AND c.indicador <> 'A' ORDER BY c.numero"
hRes := If( MSQuery( oApl:oMySql:hConnect,aVT ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   RETURN NIL
EndIf
  aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aVT := { aRes[1],aRes[2],aRes[3],aRes[4] }
  aCT[01,08] := 890112740
  aCT[01,09] := aCT[17,6] := aCT[18,6] := 1
  aCT[01,10] := If( oApl:nEmpresa == 21, "003", aCT[01,10] )
  aCT[14,01] := aGT[18,1]
  aCT[14,02] := aCT[18,2] := aGT[19,2] := "890112740"
  aCT[19,01] := "26059501"
::aLS[7] := "CO" ; ::aLS[8] := "9"
  aGT := ACLONE( aCT )
While nL > 0
      aRes[6] *= aRes[5]
   If aRes[8] == 0
      aGT[13,7] += aRes[6]
      aGT[14,8] += aRes[6]
   EndIf
   aGT[18,7] += aRes[6]
   aGT[19,8] += aRes[6]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aVT[1] # aRes[1]
      aVT[4]   := If( EMPTY( aVT[4] ), "VARIOS", ALLTRIM(aVT[4]) )
      aGT[1,1] := aVT[2]
      aGT[1,2] := LTRIM( STR( aVT[3] ) )              //Orden
      aGT[1,6] := STRTRAN( aVT[4],"'"," " ) + " - ANT."
      oGet[6]:SetText( "ORD."+aGT[1,2] )
      ::BuscaNit( aGT )
      If LEN( ::aMV ) > 2
         ::aMV[2,4] := "A." + LTRIM( STR( aVT[1] ) )
         ::Contable( oGet )
      EndIf
      aVT := { aRes[1],aRes[2],aRes[3],aRes[4] }
      aGT := ACLONE( aCT )
   EndIf
EndDo
MSFreeResult( hRes )
RETURN NIL

//------------------------------------//
METHOD Ordent( oGet ) CLASS TContabil
   LOCAL aCV, cQry, hRes, nA, nL, oCursor
cQry := "SELECT numero_orden, factura "+;
        "FROM pedido_c "               +;
        "WHERE codigo_cliente = '" + oApl:oEmp:CODIGOLOC    +;
        "' AND fecha_control >= '" + NtChr( ::aLS[2]  ,"2" )+;
        "' AND fecha_control <= '" + NtChr( ::aLS[3]+3,"2" )+;
        "' AND factura        > 0"
ConectaOn()
::aLS[4] := "Ejecutando Pedidos" ; oGet:Update()
nA := SECONDS()
oCursor := tTable():New( cQry,oApl:oODbc )
oApl:oWnd:SetMsg("Pedidos en "+STR(SECONDS() - nA)+" Segundos en Registros "+;
                 STR(oCursor:RecCount()) )
aCV := "UPDATE cadfactu SET orden = [ORD] "         +;
       "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
        " AND numfac = [FAC] AND orden = 0"         +;
        " AND fechoy >= " + xValToChar( ::aLS[2] )
nA  := Buscar( "SELECT MAX(numero) FROM cadantic WHERE optica = " +;
               LTRIM(STR(oApl:nEmpresa)),"CM" )
WHILE !oCursor:Eof()
   cQry := STRTRAN( aCV ,"[ORD]",LTRIM(STR(oCursor:FieldGet(1))) )
   cQry := STRTRAN( cQry,"[FAC]",LTRIM(STR(oCursor:FieldGet(2))) )
   If !MSQuery( oApl:oMySql:hConnect,cQry )
      oApl:oMySql:oError:Display( .f. )
   Else
      hRes := MSStoreResult( oApl:oMySql:hConnect )
      nL   := MSAffectedRows( oApl:oMySql:hConnect )
      MSFreeResult( hRes )
      If nL == 0 .AND. oCursor:FieldGet(2) <= nA
         cQry := STRTRAN( cQry,"factu" ,"antic" )
         cQry := STRTRAN( cQry,"numfac","numero" )
         cQry := STRTRAN( cQry,"fechoy","fecha" )
         MSQuery( oApl:oMySql:hConnect,cQry )
      EndIf
   EndIf
   oCursor:Skip(1)
EndDo
oCursor:End()
RETURN NIL

//4-----------------------------------//
METHOD Traslado( oGet ) CLASS TContabil
   LOCAL aDV, aRes, hRes, lDev, nE, nL, nOpt
   LOCAL aGT := {}, aCta, aCte
aDV  := "SELECT c.documen, c.fechad, d.destino, d.codigo, "+;
            "d.causadev, d.cantidad, d.pcosto, i.compra_d,"+;
             " i.moneda, i.codigo_nit, c.codigo_nit  "  +;
        "FROM cadinven i, caddevod d, caddevoc c "      +;
        "WHERE i.codigo  = d.codigo"                    +;
         " AND c.optica  = d.optica"                    +;
         " AND c.documen = d.documen"                   +;
         " AND d.codigo <> '0599000004'"                +;
         " AND d.indica <> 'B'"                         +;
         " AND c.optica  = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fechad >= " + xValToChar( ::aLS[2] )   +;
         " AND c.fechad <= " + xValToChar( ::aLS[3] )   +;
         " ORDER BY c.documen"
hRes := If( MSQuery( oApl:oMySql:hConnect,aDV )  ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   RETURN .f.
EndIf
 oGet[6]:SetText( "GENERANDO ASIENTOS" )
 aRes := MyReadRow( hRes )
 AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
aDV  := { aRes[1],"","","",0,.f. }
lDev := If( oApl:nEmpresa == 0 .OR. oApl:oEmp:PRINCIPAL # 4, .t., .f. )
nOpt := If( oApl:nEmpresa == 1,  4, oApl:nEmpresa )
::aLS[7] := "CT" ; ::aLS[8] := "9" ; ::aLS[9] := .t.
While nL > 0
   aRes[7]:= Dolar_Peso( oApl:nUS,aRes[7],aRes[9] )
   aDV[2] := { "03","","04","05","01","02" }[VAL( Grupos( aRes[4] ) )]
   aDV[3] := "1435"   + aDV[2]
   aDV[4] := "613595" + aDV[2]
   aDV[5] := aRes[6] * aRes[7]   //Cantidad * Pcosto
   aDV[6] := .f.
   aCta := ::BuscaCta( aDV[3],nOpt )
   If oApl:nEmpresa == 1
      aCta[1,10] := "015"        //TEO
   EndIf
   If LEN( aGT ) == 0
      AADD( aGT, { aRes[2],"","","","",0,aCta[1,7],999,0,aCta[1,10] } )
   EndIf
   If Rango( aRes[5],{ 2,3,8 } )
      // Devolucion, Daño, Dev.Proveedor
      If aRes[8] .OR. aRes[9] == "C" .OR. aRes[5] == 8 .OR.;
        (aRes[5] == 2 .AND. oApl:nEmpresa == 0 .AND. aDV[2] == "03")
         ::BuscaCC( If( aRes[11] == 123, aRes[10], aRes[11] ),0,{"",""},@aGT,oGet )
         If aRes[9] == "C"
            aDV[4]    := "911520" + RIGHT( aCta[2,1],2 )
            aCta[2,1] := "941520" + RIGHT( aCta[2,1],2 )
         Else
            aDV[4]    := "14650102"
         EndIf
         aCta[2,2] := LTRIM( STR(aGT[1,8]) )
         aCta[2,6] := aGT[1,9]
         aDV[6]    := .t.
      ElseIf aRes[5] == 2 .AND. oApl:nEmpresa # 0 .AND. lDev
         aCta[2,2] := 890110934
         aCta[2,6] := 171
          aDV[4]   := "14650102"
          aDV[6]   := .t.
      EndIf
   EndIf
   If Rango( aRes[5],{ 1,3,5,8 } ) .OR.;
           ( aRes[5] == 2 .AND. lDev )
      // Cambio, Daño, Sin Costo, Devolucion de BOD u Opticas que no son COC
      If aRes[9] == "C"
         If (nE := AscanX( aGT,aCta[2,1],aCta[2,6] )) == 0
            AADD( aGT, {    aDV[4],aCta[2,2],"","","",aCta[2,6],0,0,aCta[2,6] } )
            AADD( aGT, { aCta[2,1],aCta[2,2],"","","",aCta[2,6],0,0,aCta[2,6] } )
            nE := LEN( aGT )
         EndIf
         aGT[nE-1,7] += aDV[5]
      ElseIf aDV[6]
         If (nE := AscanX( aGT,aDV[4],aCta[2,6] )) == 0
            AADD( aGT, {    aDV[4],aCta[2,2],"","","",aCta[2,6],0,0,aCta[2,6] } )
            nE := LEN( aGT )
         EndIf
         aGT[nE  ,7] += aDV[5]
         If (nE := AscanX( aGT,aCta[2,1],1 )) == 0
            AADD( aGT, { aCta[2,1],"","","","",aCta[2,6],0,0,1 } )
            nE := LEN( aGT )
         EndIf
       //MsgInfo( aGT[nE,1],"1.0-"+aRes[4]+STR(nE,5) )
      Else
       //MsgInfo( aCta[2,1],"Antes 1.1-"+aRes[4] )
         If aRes[5] == 3 .AND. !lDev .AND. aDV[2] $ "04 05"
            aCte := ::BuscaCta( aDV[3],aRes[3] )
            If (nE := AscanX( aGT,aCte[2,1],2 )) == 0
               AADD( aGT, { aCte[2,1],"","","","",aCte[2,6],0,0,2,aCte[1,10] } )
               nE := LEN( aGT )
            EndIf
            aGT[nE  ,7] += aDV[5]
            If (nE := AscanX( aGT,aCta[2,1],3 )) == 0
               AADD( aGT, { aCta[2,1],"","","","",aCta[2,6],0,0,3 } )
               nE := LEN( aGT )
            EndIf
         Else
            If (nE := AscanX( aGT,aCta[2,1],5 )) == 0
               AADD( aGT, { aDV[4]   ,"","","","",        0,0,0,5 } )
               AADD( aGT, { aCta[2,1],"","","","",aCta[2,6],0,0,5 } )
               nE := LEN( aGT )
            EndIf
            aGT[nE-1,7] += aDV[5]
         EndIf
       //MsgInfo( aGT[nE-1,1],"1.2-"+aRes[4]+STR(nE,5) )
      EndIf
         aGT[nE  ,8] += aDV[5]
       //MsgInfo( aGT[nE,1]+" = "+aDV[4],"2-"+aRes[4] )
   ElseIf aRes[5] == 2                 // Devolucion
      If aDV[6] .OR. aDV[2] == "02"
         If aRes[9] == "C"
            If (nE := AscanX( aGT,aCta[2,1],aCta[2,6] )) == 0
               AADD( aGT, {    aDV[4],aCta[2,2],"","","",aCta[2,6],0,0,aCta[2,6] } )
               AADD( aGT, { aCta[2,1],aCta[2,2],"","","",aCta[2,6],0,0,aCta[2,6] } )
               nE := LEN( aGT )
            EndIf
            aGT[nE-1,7] += aDV[5]
         ElseIf aDV[2] == "02"
            If (nE := AscanX( aGT,aCta[2,1],1 )) == 0
               AADD( aGT, {"14650102","","","","",        0,0,0,1 } )
               AADD( aGT, { aCta[2,1],"","","","",aCta[2,6],0,0,1 } )
               nE := LEN( aGT )
            EndIf
            aGT[nE-1,7] += aDV[5]
         Else
            If (nE := AscanX( aGT,aDV[4],aCta[2,6] )) == 0
               AADD( aGT, {    aDV[4],aCta[2,2],"","","",aCta[2,6],0,0,aCta[2,6] } )
               nE := LEN( aGT )
            EndIf
            aGT[nE  ,7] += aDV[5]
            If (nE := AscanX( aGT,aCta[2,1],1 )) == 0
               AADD( aGT, { aCta[2,1],"","","","",aCta[2,6],0,0,1 } )
               nE := LEN( aGT )
            EndIf
         EndIf
            aGT[nE  ,8] += aDV[5]
      Else
         aCte := ::BuscaCta( aDV[3],aRes[3] )
         If (nE := AscanX( aGT,aCte[2,1],2 )) == 0
            AADD( aGT, { aCte[2,1],"","","","",aCte[2,6],0,0,2,aCte[1,10] } )
            nE := LEN( aGT )
         EndIf
         aGT[nE  ,7] += aDV[5]
         If (nE := AscanX( aGT,aCta[2,1],3 )) == 0
            AADD( aGT, { aCta[2,1],"","","","",aCta[2,6],0,0,3 } )
            nE := LEN( aGT )
         EndIf
         aGT[nE  ,8] += aDV[5]
      EndIf
   ElseIf aRes[5] == 4                 // Traslado
      If aRes[3] == 1
         aCte := ACLONE( aCta )
         aCte[1,10] := "015"           //TEO
      Else
         aCte := ::BuscaCta( aDV[3],aRes[3] )
      EndIf
      If aRes[9] == "C"
         If (nE := AscanX( aGT,aCta[2,1],aCta[2,6] )) == 0
            AADD( aGT, {    aDV[4],aCta[2,2],"","","",aCta[2,6],0,0,aCta[2,6] } )
            AADD( aGT, { aCta[2,1],aCta[2,2],"","","",aCta[2,6],0,0,aCta[2,6] } )
            nE := LEN( aGT )
         EndIf
         aGT[nE-1,7] += aDV[5]
         aGT[nE  ,8] += aDV[5]
         aDV[4]    := "941520" + RIGHT( aCte[2,1],2 )
         aCta[2,1] := "911520" + RIGHT( aCte[2,1],2 )
         If (nE := AscanX( aGT,aCta[2,1],aCta[2,6] )) == 0
            AADD( aGT, {    aDV[4],aCta[2,2],"","","",aCta[2,6],0,0,aCta[2,6] } )
            AADD( aGT, { aCta[2,1],aCta[2,2],"","","",aCta[2,6],0,0,aCta[2,6] } )
            nE := LEN( aGT )
         EndIf
         aGT[nE-1,7] += aDV[5]
         aGT[nE  ,8] += aDV[5]
      Else
         If (nE := AscanX( aGT,aCte[2,1],aRes[3] )) == 0
            AADD( aGT, { aCte[2,1],"","","","",aCte[2,6],0,0,aRes[3],aCte[1,10] } )
            nE := LEN( aGT )
         EndIf
         aGT[nE  ,7] += aDV[5]
         If (nE := AscanX( aGT,aCta[2,1],3 )) == 0
            AADD( aGT, { aCta[2,1],"","","","",aCta[2,6],0,0,3 } )
            nE := LEN( aGT )
         EndIf
         aGT[nE  ,8] += aDV[5]
      EndIf
   Else
      //6_Dev.Cliente, 7_Dev.X.Cambio
      If (nE := AscanX( aGT,aDV[4],6 )) == 0
         If aRes[5] == 6 .AND. oApl:nEmpresa == 18 .AND. aRes[3] == 21
            aCta[1,10] := "003"
         EndIf
         AADD( aGT, { aCta[2,1],"","","","",aCta[2,6],0,0,6,aCta[1,10] } )
         AADD( aGT, { aDV[4]   ,"","","","",        0,0,0,6,aCta[1,10] } )
         nE := LEN( aGT )
      EndIf
      aGT[nE-1,7] += aDV[5]
      aGT[nE  ,8] += aDV[5]
    //MsgInfo( aGT[nE,1],"3-"+aRes[4]+STR(nE,5) )
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aDV[1] # aRes[1]
      aGT[1,2] := ::INF( aDV[1] )                      //Documen
      aGT[1,6] := "CAMBIOS, DEVOLUCIONES Y TRASLADOS -" + TRIM(oApl:oEmp:LOCALIZ)
      ::BuscaNit( aGT )
      If LEN( ::aMV ) > 2
         oGet[6]:SetText( "DEV."+aGT[1,2] )
         ::Contable( oGet )
      EndIf
      aDV[1] := aRes[1]
      aGT := {}
   EndIf
EndDo
MSFreeResult( hRes )
RETURN .f.

//5-----------------------------------//
METHOD Ajustes( oGet,oBrw ) CLASS TContabil
   LOCAL aGT, aCta, aDV, aRes, hRes, nE, nL
aDV := "SELECT a.codigo, a.tipo, a.cantidad, a.pcosto"+;
            ", i.moneda, n.codigo, a.numero, a.fecha "+;
       "FROM cadclien n, cadinven i, cadajust a "     +;
       "WHERE n.codigo_nit = i.codigo_nit"            +;
        " AND a.codigo = i.codigo"                    +;
        " AND a.optica = " + LTRIM(STR(oApl:nEmpresa))+;
        " AND a.fecha >= " + xValToChar( ::aLS[2] )   +;
        " AND a.fecha <= " + xValToChar( ::aLS[3] )   + If( ::aLS[11] > 0,;
        " AND a.numero = " + LTRIM(STR(::aLS[11])), "" )+;
        " AND a.indica <> 'B' ORDER BY a.numero"
hRes := If( MSQuery( oApl:oMySql:hConnect,aDV )  ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   MsgStop( "No hay AJUSTES que Contabilizar" )
   RETURN .f.
EndIf
If oGet # NIL
   oGet[6]:SetText( "GENERANDO ASIENTOS" )
EndIf
::aLS[7] := "CA" ; ::aLS[8] := "9" ; ::aLS[9] := .t.
 aRes := MyReadRow( hRes )
 AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
 aDV := { 0,0,"","",0,aRes[7] }
 aGT := {}
While nL > 0
   aDV[3] := "1435" + { "03","","04","05","01","02" }[VAL( Grupos( aRes[1] ) )]
   aDV[4] := "613595" + RIGHT( aDV[3],2 )
   aDV[5] := aRes[3] * aRes[4]   //Cantidad * Pcosto
   aCta := ::BuscaCta( aDV[3],oApl:nEmpresa )
   If LEN( aGT ) == 0
      aGT := { { aRes[8],"","","","","AJUSTES POR SOBRANTES Y FALTANTES",;
                 aCta[1,07],0,0,aCta[1,10] } }
      If aRes[8] >= CTOD("01.05.2011")
         aGT[1,2] := LTRIM(STR(aRes[7]))
         aGT[1,6] += " -" + TRIM(oApl:oEmp:LOCALIZ)
      Else
         aGT[1,2] := PADL( LTRIM(STR(oApl:nEmpresa)),6,"9" )
      EndIf
   EndIf
   If aRes[5] == "C"
      aGT[1,8] := INT(aRes[6])
      ::BuscaNit( @aGT,oGet )
      aDV[2]    := LTRIM( STR(aGT[1,8]) )
      aDV[4]    := "911520" + RIGHT( aCta[2,1],2 )
      aCta[2,1] := "941520" + RIGHT( aCta[2,1],2 )
   EndIf
   If aRes[2] == 1
      If aRes[5] == "C"
         If (nE := AscanX( aGT,aDV[4],aGT[1,9] )) == 0
            AADD( aGT, { aCta[2,1],aDV[2],"","","",aGT[1,9],0,0,aGT[1,9] } )
            AADD( aGT, {    aDV[4],aDV[2],"","","",aGT[1,9],0,0,aGT[1,9] } )
            nE := LEN( aGT )
         EndIf
      Else
         If (nE := AscanX( aGT,aDV[4],1 )) == 0
            AADD( aGT, { aCta[2,1],"","","","",0,0,0,1 } )
            AADD( aGT, { aDV[4]   ,"","","","",0,0,0,1 } )
            nE := LEN( aGT )
         EndIf
      EndIf
   Else
      If aRes[5] == "C"
         If (nE := AscanX( aGT,aCta[2,1],aGT[1,9] )) == 0
            AADD( aGT, {    aDV[4],aDV[2],"","","",aGT[1,9],0,0,aGT[1,9] } )
            AADD( aGT, { aCta[2,1],aDV[2],"","","",aGT[1,9],0,0,aGT[1,9] } )
            nE := LEN( aGT )
         EndIf
      Else
         If (nE := AscanX( aGT,aCta[2,1],2 )) == 0
            AADD( aGT, { aDV[4]   ,"","","","",0,0,0,2 } )
            AADD( aGT, { aCta[2,1],"","","","",0,0,0,2 } )
            nE := LEN( aGT )
         EndIf
      EndIf
   EndIf
   aGT[nE-1,7] += aDV[5]
   aGT[nE  ,8] += aDV[5]
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aDV[6] # aRes[7]
      ::BuscaNit( aGT )
      If LEN( ::aMV ) > 2
         ::Contable( oGet )
         MsgInfo( "AJUSTE CONTABILIZADO","LISTO" )
      EndIf
      aGT := {}
      aDV[6] := aRes[7]
   EndIf
EndDo
MSFreeResult( hRes )
RETURN .f.

//6-----------------------------------//
METHOD NCredito( oGet,oBrw ) CLASS TContabil
   LOCAL aGT, aNC, aCom, aRes, hRes, nC, nE, nL
aCom := "SELECT c.numero, c.fecha, c.concepto, c.totaliva, c.totalfac, d.codigo, "+;
           "d.cantidad, d.pcosto, d.precioven, c.numfac, c.pagado, c.codigo_nit, "+;
           "c.anulap, c.nroiden, c.clase, c.bonos, c.devol, c.tipo "              +;
        "FROM cadnotac c LEFT JOIN cadnotad d"         +;
        " USING( optica, numero ) "                    +;
        "WHERE c.optica = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fecha >= " + xValToChar( ::aLS[2] )   +;
         " AND c.fecha <= " + xValToChar( ::aLS[3] )   +;
        " ORDER BY c.numero"
hRes := If( MSQuery( oApl:oMySql:hConnect,aCom ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   RETURN nil
EndIf
 aRes := MyReadRow( hRes )
 AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
 aCom := { aRes[01],aRes[02],aRes[03],aRes[04],aRes[05],       0,aRes[10],;
           aRes[11],aRes[12],aRes[13],aRes[14],aRes[15],aRes[16],aRes[17],aRes[18] }
 aGT  := ::BuscaCta( aRes[2],oApl:nEmpresa,"11" )
 ::BuscaNit( @aGT,"NIT" )
 ::aLS[7] := "NC" ; ::aLS[8] := "11" ; ::aLS[9] := .t.
/*
If ::aLS[2] >= CTOD("01.08.2014")
   aGT[2,1] := "41750115"
   aGT[4,1] := "13050515"
EndIf
*/
While nL > 0
   If !EMPTY( aRes[6] ) .AND. aRes[15] # 5
      nE := VAL( Grupos( aRes[6] ) )
      If nE # 2
         nE := { 7,0,8,9,5,6 }[nE]
         nC := aRes[8] * If(oApl:nEmpresa == 0, 1, aRes[7] )
         aGT[nE+4,7] += nC       //1435xx
         aGT[nE+9,8] += nC       //613595xx
      EndIf
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aCom[1] # aRes[1]
      aCom[6]  := Buscar( "SELECT codigo FROM cadclien WHERE codigo_nit = "+;
                       LTRIM(STR(aCom[9])),"CM",,8,,4 )
      aCom[3]  := If( EMPTY( aCom[3] ), "VARIOS", ALLTRIM(aCom[3]) )
      aCom[5]  := ROUND( aCom[5],0 )
      aGT[1,1] := aCom[2]                        //Fecha
      aGT[1,2] := ::INF( aCom[1] )               //Numero
      aGT[1,6] := STRTRAN( aCom[3],"'"," " )     //Descripcion
      aGT[1,8] := aCom[6] := INT(aCom[6])        //Nit
      aGT[2,7] := aCom[5]-aCom[4]                //417501xx
      aGT[3,7] := aCom[4]                        //24080101 TOTALIVA
      If oApl:nEmpresa == 0
         nE := Buscar( "SELECT optica FROM cadempre WHERE codigo_nit = "+;
                       LTRIM(STR(aCom[9])),"CM" )
         aNC := ::BuscaCta( aCom[2],nE,"11" )
         aGT[4,8] := aCom[5]                     //13050501 TOTALFAC
         aNC[1,1] := aCom[2]    ; aNC[1,2] := aGT[1,2]
         aNC[1,6] := aGT[1,6]   ; aNC[1,8] := 890110934
         aNC[1,9] := 171
         aNC[2,1] := "22050101" ; aNC[2,7] := ROUND( aCom[5],0 )
         aNC[2,5] := NtChr( aCom[2] + 30,"2" )
         aNC[3,1] := "24080102" ; aNC[3,8] := aCom[4]
         aNC[9,1] := "14650102" ; aNC[9,6] := 0
         FOR nE := 9 TO 13
            aNC[9,8] += aGT[nE,7]
         NEXT nE
            aNC[9,8] := ROUND( aNC[9,8],0 )
           ::Facturas( aCom[9],@aGT,@aNC )
      Else
          //CLASE     # Devolucion
         If aCom[12]  # 2
            aGT[4,8] := aCom[08]                 //13050502 PAGADO
         EndIf
         If aCom[12] <= 2
            aGT[5,8] := aCom[13]                 //28050501 BONOS
            If aCom[2] >= CTOD("01.10.2008")
               If aCom[10] <= 2
                  aGT[6,8] := aCom[14]           //28050502 DEVOL
               Else
                  aGT[7,8] := aCom[14]           //42950501 DEVOL
               EndIf
            Else
               aGT[7,8] += aCom[14]
            EndIf
         ElseIf aCom[12] == 5
               aGT[2,7] := aGT[3,7] := 0
               aGT[5,7] := aCom[13] + aCom[14]
             //ANULAP   == Ninguna de las Anteriores
            If aCom[10] == 3
             //aGT[7,8] := aGT[5,7]
               aGT[7,8] := aCom[14]
               aGT[8,8] := aCom[13]
            Else
               aGT[6,8] := aCom[14]
               aGT[7,1] := "28050501"
               aGT[7,8] := aCom[13]
            EndIf
         EndIf
         If aGT[5,7] # 0 .OR. aGT[5,8] # 0
            If EMPTY( aCom[11] )
               aGT[5,2] := "28050501" ; aGT[5,6] := 7046
            Else
               ::BuscaCC( 123,aCom[11],{aGT[1,6],oApl:oEmp:DIRECCION},@aGT,oGet,5 )
               aGT[1,8] := aCom[6]
            EndIf
            If aGT[7,1] == "28050501"
               aGT[7,2] := aGT[5,2]
               aGT[7,6] := aGT[5,6]
            EndIf
         EndIf
         If aGT[6,8] # 0
            ::BuscaCC( 123,aCom[11],{aGT[1,6],oApl:oEmp:DIRECCION},@aGT,oGet,6 )
            aGT[1,8] := aCom[6]
         EndIf
         If aCom[12] == 4                    //Cruce de Cuentas
            aGT[2,7] := aGT[3,7] := nE := 0
            aNC := Buscar( {"optica",oApl:nEmpresa,"numero",aCom[1],;
                            "tipo"  ,oApl:Tipo},"cadnotap","numfac, pagado",9 )
            AEVAL( aNC, {|x| AADD( aGT, { "22050101","",LTRIM(STR(x[1])),"","",0,x[2],0 } ),;
                             nE += x[2] } )
            aGT[4,3] := LTRIM(STR(aCom[7]))
            aGT[8,1] := "13551501"
            aGT[8,7] := aCom[08] - nE
         Else
            nE := 0
            AEVAL( aGT, { | e | nE += (e[7] - e[8]) },2,7 )
            If nE > 0
               aGT[8,8] :=     nE                   //53053501
            Else
               aGT[8,7] := ABS(nE)
            EndIf
            aGT[8,2] := ::aCC[1]
            aGT[8,6] := ::aCC[2]
         EndIf
      EndIf
      ::BuscaNit( @aGT,oGet )
      ::BuscaNit( aGT )
      If LEN( ::aMV ) > 2
         If aCom[15] == "F"
            FOR nE := 2 TO LEN( ::aMV ) - 1
               If LEFT(::aMV[nE,1],6) # "130505" .AND.;
                  LEFT(::aMV[nE,1],6) # "240801"
                  ::aMV[nE,9] := "003"
               EndIf
            NEXT nE
         EndIf
         oGet[6]:SetText( "N.C."+aGT[1,2] )
         ::aLS[7] := If( oApl:nEmpresa == 0, "CN", "NC" )
         ::Contable( oGet )
         // oBrw:Refresh()
         // MsgInfo( "NC CONTABILIZADA","LISTO" )
         If oApl:nEmpresa == 0
            aGT := ACLONE( aNC )
            ::BuscaNit( aGT )
            ::aLS[7] := "NC"
            ::Contable( oGet )
         EndIf
      EndIf
      aCom := { aRes[01],aRes[02],aRes[03],aRes[04],aRes[05],       0,aRes[10],;
                aRes[11],aRes[12],aRes[13],aRes[14],aRes[15],aRes[16],aRes[17],aRes[18] }
      aGT  := ::BuscaCta( aRes[2],oApl:nEmpresa,"11" )
   EndIf
EndDo
MSFreeResult( hRes )
RETURN nil

//------------------------------------//
METHOD Facturas( nCNit,aGT,aNC ) CLASS TContabil
   LOCAL aCN, nB, oDlg, oGet := ARRAY(5)
   LOCAL aNF := {}, aFT := { 0,aNC[2,7],aNC[2,7] }
DEFINE DIALOG oDLG TITLE "Facturas para Aplicar la N.C."+aGT[1,2] FROM 0, 0 TO 10,46
   @ 02, 00 SAY "No. Factura" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 02, 52 GET oGet[1] VAR aFT[1] OF oDlg PICTURE "9999999999"  ;
      VALID {|| If( !oApl:oFac:Seek( {"optica",0,"numfac",aFT[1],;
                                      "tipo","U"} )             ,;
                  ( MsgStop("Factura NO EXISTE"), .f.)          ,;
                  ( If( nCNit == 578 .OR. nCNit == 992          ,;
                        (aCN  := { 578,992 } )                  ,;
                        (aCN  := { oApl:oFac:CODIGO_NIT } ) )   ,;
                    If( !Rango( nCNit,aCN )                     ,;
                     (MsgStop( "No es de esta Optica","Factura"),;
                      .f. ), .t.) )) }                           ;
      SIZE 40,10 PIXEL
   @ 14, 00 SAY "Valor Pago"  OF oDlg RIGHT PIXEL SIZE 50,10
   @ 14, 52 GET oGet[2] VAR aFT[2] OF oDlg PICTURE "999,999,999.99";
      VALID {|| If( aFT[2] <= 0                                ,;
                (MsgStop("Valor tiene que ser Positivo",">> OJO <<"),.f.),;
                If( aFT[2]  > aFT[3]                           ,;
                  (MsgStop( "Pago Mayor que el Total",">> OJO <<" ),.f.) ,;
                    .t. )) } ;
      SIZE 40,10 PIXEL
   @ 14,100 SAY oGet[3] VAR aFT[3] OF oDlg PICTURE "9,999,999,999";
      SIZE 50,10 PIXEL UPDATE COLOR nRGB( 255,0,0 )
   @ 28, 50 BUTTON oGet[4] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( oGet[4]:Disable(), If( aFT[1] > 0, (aFT[3] -= aFT[2],;
                  AADD( aNF, { LTRIM(STR(aFT[1])),aFT[2] } ),;
                           aFT[1] := 0, aFT[2] := aFT[3]), ),;
        nB := If( aFT[3] > 0, 1, 5 ),       oGet[4]:Enable(),;
        oGet[4]:oJump := oGet[nB], oGet[nB]:SetFocus() ) PIXEL
   @ 28,100 BUTTON oGet[5] PROMPT "OK"       SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
 ACTIVATE DIALOG oDlg CENTERED
If LEN( aNF ) > 0
   oApl:cPer := NtChr( aGT[1,1],"1" )
   aCN := {}
   AEVAL( aGT,{ |x| AADD( aCN, { x[1],x[2],x[3],x[4],x[5],x[6],x[7],x[8],x[9],x[10] } ) },1,1 )
   AEVAL( aGT,{ |x| AADD( aCN, { x[1],x[2],x[3],x[4],x[5],x[6],x[7],x[8] } ) },2,2 )
   aFT := {}
   AEVAL( aNC,{ |x| AADD( aFT, { x[1],x[2],x[3],x[4],x[5],x[6],x[7],x[8],x[9],x[10] } ) },1,1 )
   FOR nB := 1 TO LEN( aNF )
      AADD( aCN, { aGT[4,1] ,aGT[4,2],aNF[nB,1],;
                   aGT[4,4] ,aGT[4,5],aGT[4,6] ,;
                         0 ,aNF[nB,2] } )
      AADD( aFT, { aNC[2,1] ,aNC[2,2],aNF[nB,1],;
                   aNC[2,4] ,aNC[2,5],aNC[2,6] ,;
                   aNF[nB,2],      0  } )
      aNF[nB,1] := INT( VAL(aNF[nB,1]) )
      aNC[2,7]  := aNF[nB,2]
      If oApl:oPag:Seek( {"optica",0,"numfac",aNF[nB,1],"tipo","U",;
                          "formapago",7,"pordonde","N","numcheque",aGT[1,2]} )
         aNC[2,7] -= oApl:oPag:PAGADO
      Else
         oApl:oPag:OPTICA    := 0         ; oApl:oPag:NUMFAC   := aNF[nB,1]
         oApl:oPag:TIPO      := oApl:Tipo ; oApl:oPag:FECPAG   := aGT[1,1]
         oApl:oPag:FORMAPAGO := 7         ; oApl:oPag:PORDONDE := "N"
         oApl:oPag:NUMCHEQUE := aGT[1,2]
      EndIf
         oApl:oPag:PAGADO    := aNF[nB,2]
      Guardar( oApl:oPag,!oApl:oPag:lOK,.f. )
      NotaCre( aNF[nB,1],aGT[1,1],1,aNC[2,7],3 )
   NEXT nB
   nB  := LEN( aGT )
   AEVAL( aGT,{ |x| AADD( aCN, { x[1],x[2],x[3],x[4],x[5],x[6],x[7],x[8] } ) },5,nB-4 )
   aGT := ACLONE( aCN )
   nB  := LEN( aNC )
   AEVAL( aNC,{ |x| AADD( aFT, { x[1],x[2],x[3],x[4],x[5],x[6],x[7],x[8] } ) },3,nB-3 )
   aNC := ACLONE( aFT )
Else
   aNF := SPACE(10)
   MsgGet( "N.C."+aGT[1,2],"Factura",@aNF )
   aGT[4,1] := "23359501"
   aGT[4,5] := aNC[2,5]
   aGT[4,3] := aNC[2,3] := If( EMPTY( aNF ), aGT[1,2], ALLTRIM( aNF ) )
   aNC[2,1] := "13102001"
   aNC[2,5] := ""
EndIf
RETURN NIL

//7-----------------------------------//
METHOD RCaja( oGet ) CLASS TContabil
   LOCAL aCT, aGT, aLC, aPG, aRC, sCC, cNC, hRes, nE, nC, nL
   LOCAL aTJ := {}
::aLS[7] := "IO" ; ::aLS[8] := "14" ; ::aLS[9] := .f.
nE   := If( oApl:nEmpresa == 1, 3, oApl:oEmp:PRINCIPAL )
aGT  := { { 1,2,3,4,5,6,7,oApl:oEmp:CC_CAJERA,0,"" } }
aCT  := { {  ::aLS[2],"","","","",0,nE,0,0,oApl:oEmp:SUCURSAL,0 },;
          {"11050501","","","","",0,0,0 }  ,{"13551501","","","","",0,0,0,0 },;
          {"13802011","800219876","","","",3542,0,0,0 },;
          {"53051501","","","","",0,0,0 }  ,{"53053501","","","","",0,0,0 }  ,;
          {"28050501", "28050501","","","",7046,0,0,0 },;
          {"28050501","","","","",0,0,0,0 },{"13050502","","","","",0,0,0 }  ,;
          {"42950501","","","","",0,0,0 } }
If ::aLS[2] >= CTOD("11.02.2008") .AND. Rango( oApl:nEmpresa,{44,51,52} )
    aCT[2,1] := "13102001"    //CFM, SAO
    aGT[1,8] := If( oApl:nEmpresa == 44, 890101994, 890107487 )
EndIf
/*
If ::aLS[2] >= CTOD("01.08.2014")
   aGT[9,1] := "13050515"
EndIf
*/
::BuscaNit( @aGT,1 )
aCT[2,2] := LTRIM( STR(aGT[1,8]) ) ; aCT[2,6] := aGT[1,9]
::BuscaNit( @aGT,"NIT" )
aCT[5,2] := aCT[6,2] := aCT[10,2] := ::aCC[1]
aCT[5,6] := aCT[6,6] := aCT[10,6] := ::aCC[2]
nE   := If( oApl:nEmpresa == 21, 18, oApl:nEmpresa )
aLC  := { "SELECT p.codbanco, p.abono, p.retencion, p.retiva, p.retica"+;
               ", p.deduccion, p.descuento, p.pordonde, p.formapago, " +;
                 "p.indred, p.numcheque, c.codigo_nit, c.cliente, "    +;
                 "c.direcc, c.codigo_cli, p.retcre, p.p_de_mas "       +;
          "FROM cadantip p, cadantic c "                 +;
          "WHERE p.optica = " + LTRIM(STR(oApl:nEmpresa))+;
           " AND p.rcaja  = [RCAJA]"                     +;
           " AND c.optica = p.optica AND c.numero = p.numero","", 0,;
          "SELECT nit, codigo_nit, cuenta, ctacte FROM bancos "    +;
          "WHERE optica = " + LTRIM(STR(nE))+;
          " AND (codigo = '[BAN]' OR codigo = 'XX') ORDER BY codigo" }
aLC[2]:= STRTRAN( aLC[1],"antip","pagos" ) + " AND c.tipo = p.tipo"
aLC[2]:= STRTRAN( aLC[2],"antic","factu" )
aLC[2]:= STRTRAN( aLC[2],"numero","numfac" )
aPG  := "SELECT c.rcaja, c.fecha, c.tipo, c.nroiden, n.codigo, c.control "+;
        "FROM cadrcaja c LEFT JOIN cadclien n USING( codigo_nit ) "       +;
        "WHERE c.optica = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fecha >= " + xValToChar( ::aLS[2] )   +;
         " AND c.fecha <= " + xValToChar( ::aLS[3] )
//      " AND (c.Control = 0 OR c.Control IS NULL)"
hRes := If( MSQuery( oApl:oMySql:hConnect,aPG )  ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRC := MyReadRow( hRes )
   AEVAL( aRC, { | xV,nP | aRC[nP] := MyClReadCol( hRes,nP ) } )
   nE  := If( aRC[3] == "A", 1, 2 )
   aGT := ACLONE( aCT )
   aPG := Buscar( STRTRAN( aLC[nE],"[RCAJA]",LTRIM(STR(aRC[1])) ),"CM",,9 )
   FOR nC := 1 TO LEN( aPG )
      aGT[1,1] := If( aRC[3] == "T" .AND. aPG[nC,8] == "A", .f., .t. )
      aGT[1,11]:= aPG[nC,3] + aPG[nC,4] + aPG[nC,5] + aPG[nC,16]          //Retenciones
      aGT[1,6] := aPG[nC,2] + aPG[nC,6] + aPG[nC,7] + aGT[1,11]
      If (aPG[nC,9] == 2 .OR.  aPG[nC,9] == 3     .OR.;
         (aPG[nC,9] == 1 .AND. aPG[nC,12] # 123)) .AND. aGT[1,1]
         If aGT[1,11] > 0
            If oApl:nEmpresa == 1
               aGT[1,1] := .f.
               aGT[6,7] += aGT[1,11]
            Else
               If aPG[nC,9] == 1
                  //p.formapago = CHEQUE
                  ::BuscaCC( aPG[nC,12],0,{"",""},@aGT,oGet )
                  aLC[3] := { aGT[1,8],aGT[1,9] }
               Else
                //aPG[nC,1] := If( ISALPHA( aPG[nC,1] ), aPG[nC,1], "M " )
                  aLC[3] := Buscar( STRTRAN( aLC[4],"[BAN]",TRIM(aPG[nC,1]) ),"CM",,8 )
                  If TRIM(aLC[3,4]) == "99070" .AND. aRC[2] >= CTOD("10.09.2009")
                     aLC[3,4] := "99776"
                  EndIf
                  If aRC[2] >= CTOD("23.09.2008")
                     aPG[nC,1] += "-" + NtChr( aPG[nC,11],"N" )
                     aPG[nC,2] := aGT[ 1,6] - aPG[nC,7]
                     sCC := NtChr( aRC[2],"2" )
                     AADD( aGT, {aLC[3,3],aLC[3,4],aPG[nC,1],""   ,sCC,0,aPG[nC,2],0,aPG[nC,1] } )
                     AADD( aGT, {aLC[3,3],aLC[3,4],aPG[nC,1],"COM",sCC,0,0,aPG[nC,6],aPG[nC,1] } )  //Deduccion
                     AADD( aGT, {aLC[3,3],aLC[3,4],aPG[nC,1],"RET",sCC,0,0,aPG[nC,3],aPG[nC,1] } )  //Retencion
                     AADD( aGT, {aLC[3,3],aLC[3,4],aPG[nC,1],"IVA",sCC,0,0,aPG[nC,4],aPG[nC,1] } )  //RetIVA
                     AADD( aGT, {aLC[3,3],aLC[3,4],aPG[nC,1],"ICA",sCC,0,0,aPG[nC,5],aPG[nC,1] } )  //RetICA
                     aPG[nC,2] := 0
                  EndIf
               EndIf
               If (nE := AscanX( aTJ,"13559502",aLC[3,2] )) == 0
                  aLC[3,1] := LTRIM(STR(aLC[3,1],11,0))
                  AADD( aTJ, {"53051501",aLC[3,1],"","","",aLC[3,2],0,0,aLC[3,2] } )
                  AADD( aTJ, {"13551501",aLC[3,1],"","","",aLC[3,2],0,0,aLC[3,2] } )
                  AADD( aTJ, {"13551701",aLC[3,1],"","","",aLC[3,2],0,0,aLC[3,2] } )
                  AADD( aTJ, {"13551801",aLC[3,1],"","","",aLC[3,2],0,0,aLC[3,2] } )
                  AADD( aTJ, {"13559502",aLC[3,1],"","","",aLC[3,2],0,0,aLC[3,2] } )
                  nE := LEN( aTJ )
               EndIf
               aTJ[nE-4,7] += aPG[nC,6]
               aTJ[nE-3,7] += aPG[nC,3]
               aTJ[nE-2,7] += aPG[nC,4]
               aTJ[nE-1,7] += aPG[nC,5]
               aTJ[nE  ,7] += aPG[nC,16]
               aGT[1,11]   := aPG[nC,3] := aPG[nC,4] := aPG[nC,5] := aPG[nC,6] := aPG[nC,16] := 0
            EndIf
         EndIf
         If aPG[nC,9] # 1 .AND. oApl:nEmpresa # 1
            aGT[5,7] += aPG[nC,6]
            aPG[nC,6]:= 0
         EndIf
      EndIf
      If aPG[nC,9] == 4 .AND. aPG[nC,10]
         If aRC[3] # "A"
            aGT[ 1,2] := (LEFT( aPG[nC,11],2 ) == "NC")
            aPG[nC,6] += aPG[nC,7]
            aPG[nC,7] := aGT[1,6] - aPG[nC,6]
            If aRC[3] == "T" .AND. !aGT[01,2]
               aGT[8,7] += aPG[nC,7]
            Else
               If aGT[1,2]
                  ::BuscaCC( 123,aPG[nC,15],{aPG[nC,13],aPG[nC,14],aPG[nC,11]},@aGT,oGet )
               Else
                  ::BuscaCC( 123,aPG[nC,15],{aPG[nC,13],aPG[nC,14]},@aGT,oGet )
               EndIf
               If (nE := AscanX( aGT,"28050501",aGT[1,9] )) == 0
                  AADD( aGT, {"28050501",LTRIM(STR(aGT[1,8],11,0)),;
                              "","","",aGT[1,9],0,0,aGT[1,9] } )
                  nE := LEN( aGT )
               EndIf
               aGT[nE,7] += aPG[nC,7]  //Bonos por N.C
            EndIf
               aGT[6 ,7] += aPG[nC,6]  //Descuentos
               aGT[9 ,8] += (aGT[1,6] - aPG[nC,17])  //13050502
         EndIf
      Else
         If aPG[nC,8] # "A"
            If aPG[nC,9] # 4
               aGT[2,7] += aPG[nC,2]
            Else
               If LEFT( aPG[nC,11],4 ) == "SODE"
                  aGT[04,7] += aPG[nC,2]
               Else
                  If (nE := AscanX( aGT,"13802011",5002 )) == 0
                     AADD( aGT, {"13802011","800112214","","","",5002,0,0,5002 } )
                     nE := LEN( aGT )         //BIG PASS
                  EndIf
                  aGT[nE,7] += aPG[nC,2]
               EndIf
            EndIf
         EndIf
         If aGT[1,1]
            If aGT[1,11] > 0 .AND. aPG[nC,12] # 123
               If (nE := AscanX( aGT,"13559502",aPG[nC,12] )) == 0
                  ::BuscaCC( aPG[nC,12],0,{"",""},@aGT,oGet )
                  sCC := LTRIM(STR(aGT[1,8],11,0))
                  AADD( aGT, {"13551501",sCC,"","","",aGT[1,9],0,0,aPG[nC,12] } )
                  AADD( aGT, {"13551701",sCC,"","","",aGT[1,9],0,0,aPG[nC,12] } )
                  AADD( aGT, {"13551801",sCC,"","","",aGT[1,9],0,0,aPG[nC,12] } )
                  AADD( aGT, {"13559502",sCC,"","","",aGT[1,9],0,0,aPG[nC,12] } )
                  nE := LEN( aGT )
               EndIf
               aGT[nE-3,7] += aPG[nC,3]
               aGT[nE-2,7] += aPG[nC,4]
               aGT[nE-1,7] += aPG[nC,5]
               aGT[nE  ,7] += aPG[nC,16]
            Else
               aGT[ 3,7] += aPG[nC,3]
            EndIf
            aGT[6,7] += (aPG[nC,6] + aPG[nC,7])
         ElseIf oApl:nEmpresa == 1
            aGT[6,7] += (aPG[nC,6] + aPG[nC,7])
         EndIf
         If aRC[3]  # "A"
            aGT[8,7] += If( aPG[nC,8] == "A", aGT[1,6], 0 )
            aGT[9,8] += (aGT[1,6] - aPG[nC,17])
         Else
            aGT[8,8] += (aGT[1,6] - aPG[nC,17])
         EndIf
      EndIf
      If aPG[nC,17] > 0
         aGT[10,8] += aPG[nC,17] //Aprovechamiento
      EndIf
      nE := 9
   NEXT nC
   If nE == 9
      If aGT[8,7] # 0 .OR. aGT[8,8] # 0
         ::BuscaCC( 123,aRC[4],{aPG[1,13],aPG[1,14]},@aGT,oGet,8 )
      EndIf
      ::aLS[5] := aRC[6]                               //CONTROL
      aGT[1,1] := aRC[2]                               //FECHA
      aGT[1,2] := aGT[1,3] := LTRIM( STR(aRC[1]) )     //RCAJA
      aGT[1,6] := If( aRC[3] == "A", "ANTICIPOS", "ABONO Y CANC.FACT." ) + " - " +;
                      oApl:oEmp:LOCALIZ
      aGT[1,8] := If( oApl:nEmpresa == 1, 890110934, aRC[5] ) //NIT
      AEVAL( aTJ, { |x| AADD( aGT,{ x[1],x[2],x[3],x[4],x[5],x[6],x[7],x[8],x[9] } ) } )
      aTJ := {}
      ::BuscaNit( @aGT,oGet )
      ::BuscaNit( aGT )
      If LEN( ::aMV ) > 2
         oGet[6]:SetText( "R.C."+aGT[1,2] )
         ::Contable( oGet )
      EndIf
   EndIf
   nL --
EndDo
MSFreeResult( hRes )
RETURN .f.

//------------------------------------//
METHOD BaseICA( oGet,oBrw ) CLASS TContabil
   LOCAL aGT, aRes, cQry, hRes, nG, nK, nL, oSal
   LOCAL aOG, aOP, aV
 ::aLS[2] := NtChr( LEFT( DTOS( ::aLS[2] ),6 ),"F" )
 ::aLS[3] := CTOD( NtChr( ::aLS[2],"4" ) )
cQry := "SELECT codigo_nit FROM opticasg WHERE codigo <> " +;
        STRTRAN( LEFT( oApl:oEmp:NIT,AT("-",oApl:oEmp:NIT)-1 ),".","" )
 aOG := Buscar( cQry,"CM",,9 )
cQry := "SELECT optica, pica, pavi, pbom, sucursal FROM cadempre WHERE pica > 0" +;
        " AND principal = " + LTRIM(STR(oApl:oEmp:PRINCIPAL))+;
         " ORDER BY optica"
 aOP := Buscar( cQry,"CM",,9 )
aV := { 0,0,0,0,0,0,0,0,;
        "SELECT v.numfac, v.codart, v.precioven, c.codigo_nit, i.tipomontu "+;
        "FROM cadfactu c, cadventa v LEFT JOIN cadinven i"+;
          " ON v.codart  = i.codigo "                     +;
        "WHERE v.optica  = c.optica"                      +;
         " AND v.numfac  = c.numfac"                      +;
         " AND v.tipo    = c.tipo"                        +;
         " AND v.optica  = [X]"                           +;
         " AND v.fecfac >= " + xValToChar( ::aLS[2] )     +;
         " AND v.fecfac <= " + xValToChar( ::aLS[3] )     +;
         " AND v.tipo    = " + xValToChar(oApl:Tipo )     +;
         " ORDER BY v.numfac",;
        "SELECT c.numero, d.codigo, d.precioven, c.codigo_nit, i.tipomontu "+;
        "FROM cadnotac c, cadnotad d LEFT JOIN cadinven i"+;
        " USING( codigo ) "                               +;
        "WHERE c.optica = d.optica"                       +;
         " AND c.numero = d.numero"                       +;
         " AND c.optica = [X]"                            +;
         " AND c.fecha >= " + xValToChar( ::aLS[2] )      +;
         " AND c.fecha <= " + xValToChar( ::aLS[3] )      +;
         " AND c.clase <= 2"                              +;
         " ORDER BY c.numero"                             ,;
        "SELECT SUM(valor_deb), SUM(valor_cre) FROM acumulados "+;
        "WHERE codigo_emp = " + LTRIM(STR(oApl:oEmp:PRINCIPAL)) +;
         " AND ano_mes    = " + LEFT( DTOS(::aLS[3]),6 )        +;
         " AND SUBSTR(cuenta,1,2) = '42'"                       +;
         " AND sucursal   = [X]" }
 aGT := ::BuscaCta( ::aLS[3],oApl:nEmpresa,"13" )
If oApl:nEmpresa == 19
   aGT[1,8] := 890480184
   aGT[2,6] := 4614
Else
   aGT[1,8] := 890102018
   If oApl:oEmp:PRINCIPAL == 4
      AADD( aOP,{ 0,oApl:oEmp:PICA,oApl:oEmp:PAVI,oApl:oEmp:PBOM,"008" } )
   EndIf
EndIf
   aGT[1,2] := "2"
 //aGT[1,2] := PADL( LTRIM(STR(oApl:nEmpresa)),6,"9" )
   aGT[1,6] := "PROV IMP.IND.CCIO " + RIGHT( NtChr( ::aLS[3],"2" ),8 )
   aGT[1,7] := oApl:oEmp:PRINCIPAL
   aGT[2,2] := LTRIM( STR(aGT[1,8]) )
 ::aLS[7] := "CD" ; ::aLS[8] := "13" ; ::aLS[9] := .t.
 ::aMV := { { NtChr( aGT[1,1],"2" ) ,aGT[1,2],aGT[1,3],aGT[1,4],;
            LEFT( DTOS(aGT[1,1]),6 ),aGT[1,6],aGT[1,7],aGT[1,8],aGT[1,9] } }
FOR nK := 1 TO LEN( aOP )
   oApl:oWnd:SetMsg( "Sucursal " + aOP[nK,5] )
   cQry := STRTRAN( aV[9],"[X]",LTRIM(STR(aOP[nK,1])) )
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   If (nL := MSNumRows( hRes )) > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      aV[1] := aRes[1]
      aV[2] := If( Rango( aRes[4],aOG ), 1, 0 )
   EndIf
   While nL > 0
      If oApl:oEmp:PRINCIPAL == 16 .OR.;
         oApl:oEmp:PRINCIPAL == 18
         aV[3] += aRes[3]
      Else
         nG := GrupoIca( aRes[2],aRes[5],aV[2] )
         If Rango( nG,{3,5,6,7,10 } )
            aV[3] += aRes[3]
         EndIf
      EndIf
      If (nL --) > 1
         aRes := MyReadRow( hRes )
         AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      EndIf
      If nL == 0 .OR. aV[1] # aRes[1]
         aV[1] := aRes[1]
         aV[2] := If( Rango( aRes[4],aOG ), 1, 0 )
      EndIf
   EndDo
   MSFreeResult( hRes )
   //Notas Creditos Devoluciones
   cQry := STRTRAN( aV[10],"[X]",LTRIM(STR(aOP[nK,1])) )
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   If (nL := MSNumRows( hRes )) > 0
      aRes := MyReadRow( hRes )
      AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      aV[1] := aRes[1]
      aV[2] := If( Rango( aRes[4],aOG ), 1, 0 )
   EndIf
   While nL > 0
      If oApl:oEmp:PRINCIPAL == 16 .OR.;
         oApl:oEmp:PRINCIPAL == 18
         aV[3] -= aRes[3]
      Else
         nG := GrupoIca( aRes[2],aRes[5],aV[2] )
         If Rango( nG,{3,5,6,7,10 } )
            aV[3] -= aRes[3]
         EndIf
      EndIf
      If (nL --) > 1
         aRes := MyReadRow( hRes )
         AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
      EndIf
      If nL == 0 .OR. aV[1] # aRes[1]
         aV[1] := aRes[1]
         aV[2] := If( Rango( aRes[4],aOG ), 1, 0 )
      EndIf
   EndDo
   MSFreeResult( hRes )
   If aV[3] > 0
      If aOP[nK,1] == 18
         cQry := STRTRAN( aV[11],"= [X]","IN('001','003')" )
      Else
         cQry := STRTRAN( aV[11],"[X]",aOP[nK,5] )
      EndIf
      oSal := tTable():New( cQry,oApl:oODbc )
   // oApl:oWnd:SetMsg( STR(oSal:RecCount()) + " Registros" )
      If !oSal:Eof()
         aV[3] := aV[3] - oSal:FieldGet(1) + oSal:FieldGet(2)
      EndIf
      oSal:End()
      If aOP[nK,1] == 48
         cQry := { "891780009",26100 }
      Else
         cQry := { aGT[2,2],aGT[2,6] }
      EndIf
     // MsgInfo( TRANSFORM(aV[3],"999,999,999.99"),"Valor" )
      aV[4] := ROUND( aV[3] * aOP[nK,2] / 100,0 )
      aV[5] := ROUND( aV[4] * aOP[nK,3] / 100,0 )
      aV[6] := ROUND( aV[4] * aOP[nK,4] / 100,0 )
      aV[7] := aV[4] + aV[5] + aV[6]
      aV[8] += aV[7]
      AADD( ::aMV, { aGT[2,1],cQry[1],aGT[1,2],aGT[2,4],;
                     aGT[2,5],cQry[2], aV[4]  ,       0,aOP[nK,5] } )
      AADD( ::aMV, { aGT[2,1],cQry[1],aGT[1,2],aGT[2,4],;
                     aGT[2,5],cQry[2], aV[5]  ,       0,aOP[nK,5] } )
      AADD( ::aMV, { aGT[3,1],cQry[1],aGT[1,2],aGT[2,4],;
                     aGT[2,5],cQry[2], aV[6]  ,       0,aOP[nK,5] } )
      AADD( ::aMV, { aGT[4,1],cQry[1],aGT[1,2],aGT[2,4],;
                     aGT[2,5],cQry[2],       0, aV[7]  ,aOP[nK,5] } )
   EndIf
   aV[3] := 0
NEXT nK
   If aV[8] > 0
      AADD( ::aMV, { "","","TOTALES =>","","",0,aV[8],aV[8] } )
      ::Contable( oGet )
    //oBrw:Refresh()
   EndIf
RETURN .f.

//------------------------------------//
METHOD BuscaCC( nCN,nCC,aDC,aGT,oGet,nF ) CLASS TContabil
   LOCAL sCC := ""
If LEN( aDC ) == 3
   ::aCC[1] := Buscar( "SELECT nroiden FROM historia WHERE codigo_nit = "+;
                       LTRIM(STR(nCC)),"CM",,8 )
     nCC := LEN( aDC[3] )
   //Bono por NC p.numcheque
   FOR nCN := 1 TO LEN( aDC[3] )
      If SUBSTR( aDC[3],nCN,1 ) $ "1234567890"
         sCC += SUBSTR( aDC[3],nCN,1 )
         nCC := nCN
      EndIf
   NEXT nCN
   aDC[3] := ALLTRIM( SUBSTR( aDC[3],nCC+1 ) )
   If EMPTY( aDC[3] )
      sCC := "SELECT nroiden FROM cadnotac "                +;
             "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))  +;
              " AND numero = " + sCC
   Else
      sCC := "SELECT c.nroiden FROM cadempre e, cadnotac c "+;
             "WHERE e.localiz = '" + aDC[3]                 +;
             "' AND c.optica  = e.optica"                   +;
              " AND c.numero  = " + sCC
   EndIf
     aDC[3] := Buscar( sCC,"CM",,8 )
     sCC    := NtChr( aDC[3],"N" )      //Solo Numeros
   ::aCC[1] := NtChr( ::aCC[1],"N" )
   ::aCC[3] := aDC[1]
   ::aCC[4] := aDC[2]
   If !EMPTY( sCC ) .AND. sCC # ::aCC[1]
      ::aCC[1] := sCC
   EndIf
   sCC := "CC"
//ElseIf nCN # 123 .AND. nCC == 0
ElseIf nCN # 123
   oApl:oNit:Seek( {"codigo_nit",nCN} )
   ::aCC[1] := LTRIM(STR(oApl:oNit:CODIGO,12,0))
   ::aCC[3] := oApl:oNit:NOMBRE
   ::aCC[4] := oApl:oNit:DIRECCION
   ::aCC[5] := oApl:oNit:DIGITO
Else
   sCC := If( VALTYPE( nCC ) == "C", "nroiden", "codigo_nit" )
   oApl:oHis:Seek( {sCC,nCC} )
   ::aCC[1] := NtChr( oApl:oHis:NROIDEN,"N" )
   ::aCC[3] := XTrim( oApl:oHis:APELLIDOS ) + oApl:oHis:NOMBRES
   ::aCC[4] := oApl:oHis:DIRECCION
   ::aCC[6] := SUBSTR( oApl:oHis:APELLIDOS,1,oApl:oHis:PAPEL )
   ::aCC[7] := SUBSTR( oApl:oHis:APELLIDOS,2+oApl:oHis:PAPEL )
   ::aCC[8] := SUBSTR( oApl:oHis:NOMBRES  ,1,oApl:oHis:PNOMB )
   ::aCC[9] := SUBSTR( oApl:oHis:NOMBRES  ,2+oApl:oHis:PNOMB )
   sCC := "CC"
EndIf
   aGT[1,8] := If( EMPTY( ::aCC[1] ), oApl:oEmp:CC_CAJERA, INT(VAL(::aCC[1])) )
If sCC == "CC"
   ::aCC[5] := DigitoVerifica( aGT[1,8] )
EndIf
   ::BuscaNit( @aGT,oGet )
   If nF # NIL
      aGT[nF,2] := LTRIM( STR(aGT[1,8]) )
      aGT[nF,6] := aGT[1,9]
   EndIf
RETURN NIL

//------------------------------------//
METHOD BuscaCta( dFec,nE,cTipo,nO ) CLASS TContabil
   LOCAL aCta, aE
If VALTYPE( dFec ) == "D"
   aCta := "SELECT cuenta, codigo_nit, empresa, sucursal FROM cuentas "+;
           "WHERE (optica = " + xValToChar( nE )+;
              " OR optica = 99) AND tipo = '"   + cTipo + "' ORDER BY db_cr, cuenta"
Else
   aCta := "SELECT cuenta, codigo_nit, empresa, sucursal FROM cuentas "+;
           "WHERE optica = " + xValToChar( If( nE == 0, 99, nE ) )+;
            " AND LEFT(cuenta,6) = " + xValToChar( dFec )    +;
            " AND tipo = '9'"
EndIf
aE   := Buscar( aCta,"CM",,9 )
If nO # NIL .AND. nO # nE
   aE[1,4] := Buscar( {"optica",nO},"cadempre","sucursal" )
EndIf
aCta := { { dFec,"","0","","",0,aE[1,3],0,0,aE[1,4] } }
AEVAL( aE, {| x | AADD( aCta, { TRIM(x[1]),"","","","",x[2],0,0 } ) } )
RETURN aCta

//------------------------------------//
METHOD BuscaNit( aGT,oGet,nC,aD ) CLASS TContabil
   LOCAL aE, cSql, nE, oNit, lOK := .f.
 ConectaOn()
If nC # NIL
   aE := "SELECT n.codigo FROM cadinven i, cadclien n "+;
         "WHERE i.codigo = " + xValToChar( oGet )      +;
          " AND i.moneda = 'C' AND n.codigo_nit = i.codigo_nit"
   aE := Buscar( aE,"CM","*",8 )
   If !EMPTY( aE )
      aE   := LTRIM(STR( aE,10,0 ))
      oNit := TDbOdbc()
      oNit:New( "SELECT codigo_nit FROM NITS WHERE nit = " +;
                aE + " ORDER BY codigo_nit",oApl:oODbc )
      oNit:End()
      If !oNit:lEof
         ::aCC[1] := LTRIM(STR( oNit:FieldGet(1) ))
         cSql     := SUBSTR( aGT[18,1],7,2 )
         AADD( aGT, { "911520"+cSql,aE,"","","",::aCC[1],nC,0  } )
         AADD( aGT, { "941520"+cSql,aE,"","","",::aCC[1],0 ,nC } )
      EndIf
   EndIf
ElseIf oGet # NIL
   If VALTYPE( oGet ) == "C"
      ::aCC[1] := STRTRAN( LEFT( oApl:oEmp:NIT,AT("-",oApl:oEmp:NIT)-1 ),".","" )
       aGT[1,8] := INT(VAL(::aCC[1]))
   EndIf
   If aGT[1,8] == 0 .AND. Rango( ::aLS[1],{2,6,7} )
      aGT[1,8] := 11111101
   EndIf
   cSql := "SELECT codigo_nit, nombre FROM NITS WHERE nit = " + LTRIM(STR(aGT[1,8]))+;
           " ORDER BY codigo_nit"
   oNit := TDbOdbc()
   oNit:New( cSql,oApl:oODbc )
   oNit:End()
   If oNit:lEof .OR. aGT[1,8] == 0
      If ::aLS[8] # "4"
         cSql := "SELECT consecutivo FROM control_gen WHERE fuente = 1"
         oNit := TDbOdbc()
         oNit:New( cSql,oApl:oODbc )
         oNit:End()
         aGT[1,9] := oNit:FieldGet(1) + 1
         cSql := "UPDATE control_gen SET consecutivo = " + LTRIM(STR(aGT[1,9])) +;
                 " WHERE fuente = 1"
         oApl:oOdbc:Execute( cSql )
         If EMPTY(::aCC[3])
            oApl:oNit:Seek( {"codigo",aGT[1,8]} )
            ::aCC[3] := oApl:oNit:NOMBRE
            ::aCC[4] := oApl:oNit:DIRECCION
            ::aCC[5] := oApl:oNit:DIGITO
         EndIf
         cSql := "INSERT INTO nits (CODIGO_NIT, NIT, NOMBRE, CLASE_DOCU, "  +;
                     "DIRECCION, CODIGO_CIU, SISTEMA, DIGITO, PRIMER_AP, "  +;
                 "SEGUNDO_AP, PRIMER_NO, SEGUNDO_NO, CODIGO_PAIS) VALUES ( "+;
                 ::INF( aGT[1,9],", " ) + ::INF( aGT[1,8],", " ) +;
                 ::INF( ::aCC[3],", " ) +;
                 If( aGT[1,8] > 800000000 .AND. aGT[1,8] < 999999999,;
                     "'N', ", "'C', " ) +;
                 ::INF( ::aCC[4],", '" +LEFT(oApl:oEmp:CODIGOLOC,2)+ "', 'CON', " )+;
                 ::INF( ::aCC[5],", " ) + ::INF( ::aCC[6],", " ) +;
                 ::INF( ::aCC[7],", " ) + ::INF( ::aCC[8],", " ) +;
                 ::INF( ::aCC[9],", '169' )" )
         oApl:oOdbc:Execute( cSql )
         AEVAL( ::aCC, {|xV,nI| ::aCC[nI] := {"",0}[AT(VALTYPE(xV),"CN")] },3 )
      Else
         MsgAlert( aGT[1,8],"Este Nit no Existe" )
         lOk := .t.
      EndIf
   Else
      aGT[1,9] := oNit:FieldGet(1)
      If VALTYPE( oGet ) == "O"
         oGet[6]:SetText( oNit:FieldGet(2) )
      ElseIf VALTYPE( oGet ) == "C"
         ::aCC[2] := aGT[1,9]
      EndIf
   EndIf
ElseIf LEN( aGT ) > 0
   aE := { 0,0,NtChr( aGT[1,1] + 30,"2" ),aGT[1,10],"",0 }
   ::aMV := { { NtChr( aGT[1,1],"2" ),aGT[1,2],aGT[1,3],aGT[1,4],;
            LEFT( DTOS(aGT[1,1]),6 ) ,aGT[1,6],aGT[1,7],aGT[1,8],aGT[1,9] } }
   FOR nE := 2 TO LEN( aGT )
      If aGT[nE,7] > 0 .OR. aGT[nE,8] > 0
         cSql := STUFF( aGT[nE,1],5,2,"" )
         aE[5]:= If( LEN(aGT[nE]) == 10, aGT[nE,10],;
                 If( cSql == "143508", "008", aE[4] ))
         aE[6]:= 0
         cSql := "SELECT SUCURSAL, INFA, INFB, INFC, INFD FROM PLAN WHERE CODIGO_EMP = "+;
                 LTRIM(STR(aGT[1,7])) + " AND CUENTA = '" + aGT[nE,1] + "'"
      // MsgInfo( cSql,aGT[1,2] )
         oNit := TDbOdbc()
         oNit:New( cSql,oApl:oODbc )
         oNit:End()
         FOR nC := 2 TO 5
            cSql:= ALLTRIM( oNit:FieldGet(nC) )
            do case
            Case cSql == "$BASE" .AND. ::aLS[12] > 0 .AND. VALTYPE( aGT[nE,5] ) == "N"
               aE[6]      := aGT[nE,5]
               aGT[nE,05] := ""
               aGT[nE,nC] := LTRIM( STR(::aLS[12],10,0) )
            Case cSql == "COD-VAR"
               aGT[nE,nC] := aGT[nE,1]
               If aGT[nE,1] == "11050501"
                  aGT[nE,6] := 0
               EndIf
            Case cSql == "DOCUMENTO" .AND. EMPTY( aGT[nE,nC] )
               aGT[nE,nC] := aGT[01,2]
            Case cSql == "FECHA"     .AND. EMPTY( aGT[nE,nC] )
               aGT[nE,nC] := aE[3]
            Case cSql == "NIT"       .AND. EMPTY( aGT[nE,nC] )
               If Rango( ::aLS[1],{ 3,4,5 } )
                  aGT[nE,nC] := { "999","99911","99912" }[::aLS[1]-2]
                  aGT[nE,06] := { 3931,8386,8387 }[::aLS[1]-2]
               ElseIf ::aLS[8] # "4" .AND. LEFT(aGT[nE,1],4) == "1435"
                  aGT[nE,nC] := aGT[nE,1]
               Else
                  aGT[nE,nC] := LTRIM( STR(aGT[1,8]) )
                  aGT[nE,06] := aGT[1,9]
               EndIf
            EndCase
         NEXT nC
         aE[1] += aGT[nE,7]
         aE[2] += aGT[nE,8]
         AADD( ::aMV, { aGT[nE,1],aGT[nE,2],aGT[nE,3],aGT[nE,4],;
                        aGT[nE,5],aGT[nE,6],aGT[nE,7],aGT[nE,8],;
                        If( oNit:FieldGet(1) == 1, aE[5], "001" ),aE[6],0 } )
      EndIf
   NEXT nE
   If (nE := ASCAN( ::aMV,{ |aX| aX[1] == "13102001" },2 )) > 0
      ::aMV[nE,9] := "001"
   EndIf
   //Aqui Duplico los registros para las NIIF
   //If oApl:oEmp:NIIF .AND. ::aMV[1,5] >= "201501"
   If !EMPTY(oApl:oEmp:NIIF) .AND. ::aMV[1,1] >= oApl:oEmp:NIIF
      If ::aDC == NIL .OR. LEN( ::aDC ) == 0
         aD := { 0,0 }
      Else
         aD := { ::aDC[1,3],0 }
      EndIf
      aGT := ACLONE( ::aMV )
      FOR nE := 2 TO LEN( aGT )
         If LEFT( aGT[nE,1],4 ) == "1435"
            aGT[nE,7] -= aD[1]
                aD[2] += aD[1]
                aD[1] := 0
         ElseIf LEFT( aGT[nE,1],4 ) == "2205"
            aGT[nE,8] -= aD[2]
         EndIf
         AADD( ::aMV, { aGT[nE,1],aGT[nE,2],aGT[nE,3],aGT[nE,4],;
                        aGT[nE,5],aGT[nE,6],aGT[nE,7],aGT[nE,8],;
                        aGT[nE,9],aGT[nE,10], 1 } )
      NEXT nE
   EndIf
   AADD( ::aMV, { "","","TOTALES =>","","",0,aE[1],aE[2] } )
   lOk := .t.
EndIf
//ConectaOff()
RETURN lOk

//------------------------------------//
METHOD Contable( oGet,xFec ) CLASS TContabil
   LOCAL aCG, cSql, nCtl, nE, oMes
aCG := { .t.,0,""," WHERE CODIGO_EMP = " + LTRIM(STR(::aMV[1,7])) +;
                    " AND ANO_MES = " + ::aMV[1,5] }
If ::aLS[9]
   cSql := "SELECT CONSECUTIVO FROM movto_c" + aCG[4] + " AND COMPROBANTE = " +;
           ::aMV[1,2] + " AND TIPO = '" + ::aLS[8]   + "' AND DESCRIPCION = '"+;
           ::aMV[1,6] + If( xFec == NIL, "'", "' AND FECHA = " + ::INF(::aMV[1,1]) )
   ConectaOn()
   oMes := TDbOdbc()
   oMes:New( cSql,oApl:oODbc )
   oMes:End()
   If !oMes:lEof
      aCG[1] := .f.
      nCtl := oMes:FieldGet(1)
      cSql := "DELETE FROM movto_d" + aCG[4] + ;
              " AND CONSECUTIVO = " + LTRIM(STR(nCtl))
      oApl:oOdbc:Execute( cSql )
   EndIf
ElseIf Rango( ::aLS[1],{0,7} ) .AND. ::aLS[5] > 0
   aCG[1] := .f.
   nCtl := ::aLS[5]
   cSql := "DELETE FROM movto_d" + aCG[4] + ;
           " AND CONSECUTIVO = " + LTRIM(STR(nCtl))
   ConectaOn()
   oApl:oOdbc:Execute( cSql )
EndIf
WHILE aCG[1]
   cSql := "SELECT CONSECUTIVO FROM control_mes" + aCG[4] + " AND FUENTE = 8"
       //  "FOR UPDATE OF CONSECUTIVO"
   ConectaOn()
   oMes := TDbOdbc()
   oMes:New( cSql,oApl:oODbc )
   oMes:End()
   oApl:oWnd:SetMsg( "Por FAVOR espere Buscando CONTROL_MES" )
//   MsgInfo( If( oMes:lEof, "SI", "NO" ),"control_mes" ) EMPTY(oMes:RecCount())
   If oMes:lEof
      nCtl := 1
      cSql := "INSERT INTO control_mes VALUES ( 8, " + ::aMV[1,5] +;
              ", 'CONTABILIDAD', 1, " + LTRIM(STR(::aMV[1,7])) + ", 0 )"
   Else
      nCtl := oMes:FieldGet(1) + 1
      cSql := "UPDATE control_mes SET CONSECUTIVO = " + LTRIM(STR(nCtl)) +;
              aCG[4] + " AND FUENTE = 8"
   EndIf
   If oApl:oOdbc:Execute( cSql,cSql )
      cSql := "SELECT COMPROBANTE FROM movto_c" +aCG[4]+ " AND CONSECUTIVO = "
      ConectaOn()
      oMes := TDbOdbc()
      oMes:New( cSql + LTRIM(STR(nCtl)),oApl:oODbc )
      oMes:End()
      If oMes:lEof
         EXIT      //NO EXISTE
      EndIf
   EndIf
EndDo
If ::aLS[1] == 0
   ::aLS[5] := nCtl
   aCG[3] := "UPDATE comprasc SET cgeconse = nCtl"
ElseIf ::aLS[1] == 1 .OR. ::aLS[1] == 3
   aCG[3] := "UPDATE cadrepoc SET cgeconse = nCtl"
ElseIf ::aLS[1] == 7
   aCG[3] := "UPDATE cadrcaja SET control = nCtl WHERE optica = "+;
             LTRIM(STR(oApl:nEmpresa)) + " AND rcaja = "
EndIf
If oGet # NIL
   oGet[5]:SetText( nCtl )
EndIf
xFec   := aCG[4]     // CODIGO_EMP         ,       ANO_MES,
aCG[4] := "VALUES ( " + ::INF( ::aMV[1,7],", " ) + ::aMV[1,5] + ", "
If aCG[1]
   cSql := "INSERT INTO movto_c (CODIGO_EMP, ANO_MES, COMPROBANTE, CONSECUTIVO, "+;
           "CLASE, DESCRIPCION, FECHA, TIPO, ESTADO) " + aCG[4]                  +;
           If( ::aLS[8] == "4", ::INF( nCtl ),  ::aMV[1,2] ) + ", "              +;
           ::INF( nCtl,", " ) + ::INF(::aLS[7],", ") + ::INF( ::aMV[1,6],", " )  +;
           ::INF(::aMV[1,1],", ") + ::INF(::aLS[8],", '0' )" )
   oApl:oOdbc:Execute( cSql,"movto_c" )
EndIf
//aCG[4] := "INSERT INTO movto_d " + aCG[4] + ::INF( nCtl,", " )
aCG[4] := "INSERT INTO movto_d (CODIGO_EMP, ANO_MES, CONSECUTIVO, "+;
          "SECUENCIA, CUENTA, INFA, INFB, INFC, INFD, CODIGO_NIT, "+;
          "VALOR_DEB, VALOR_CRE, SUCURSAL, CEN_COS, VERSION, "     +;
          "RETE, LIBRO) " + aCG[4] + ::INF( nCtl,", " )
 FOR nE := 2 TO LEN( ::aMV ) - 1
    If ::aMV[nE,7] > 0 .OR. ::aMV[nE,8] > 0
       cSql := aCG[4] + ::INF( ++aCG[2],", " ) +;
               ::INF( ::aMV[nE,1] ,", " ) + ::INF( ::aMV[nE,2],", " ) +;
               ::INF( ::aMV[nE,3] ,", " ) + ::INF( ::aMV[nE,4],", " ) +;
               ::INF( ::aMV[nE,5] ,", " ) + ::INF( ::aMV[nE,6],", " ) +;
               ::INF( ::aMV[nE,7] ,", " ) + ::INF( ::aMV[nE,8],", " ) +;
               ::INF( ::aMV[nE,9] ,", 1, 0, " )                       +;
               ::INF( ::aMV[nE,10],", " ) + STR( ::aMV[nE,11],1 ) + " )"
       //      ::INF( ::aMV[nE,9] ,", 1, 0, NULL, NULL, " )           +;
       //MsgInfo( cSql,"movto_d"+STR(::aMV[nE,10]) )
       oApl:oOdbc:Execute( cSql,"movto_d" )
    EndIf
 NEXT nE
   //Aqui van los Descuentos Condicionados
If oApl:oEmp:NIIF .AND. ::aDC # NIL .AND. LEN( ::aDC ) > 0
   cSql := "SELECT CONSECUTIVO FROM compras_des" + xFec +;
           " AND CONSECUTIVO = " + LTRIM(STR(nCtl))
   oMes := TDbOdbc()
   oMes:New( cSql,oApl:oODbc )
   oMes:End()
   If !oMes:lEof
      aCG[4] := STRTRAN( aCG[4],"movto_d","compras_des" )
      FOR nE := 1 TO LEN( ::aDC )
         cSql := ::INF( ::aDC[nE,1],", " ) + ::INF( ::aDC[nE,2],", " ) +;
                 ::INF( ::aDC[nE,3],", " ) + ::INF( ::aDC[nE,4],")" )
         oApl:oOdbc:Execute( aCG[4] + cSql,"compras_des" )
      NEXT nE
   EndIf
EndIf
 ConectaOff()
 ::aMV[1,8] := 0
If !EMPTY( aCG[3] )
   cSql := STRTRAN( aCG[3],"nCtl",::INF( nCtl ) ) +;
           If( ::aLS[1] == 7, "", " WHERE row_id = " ) + ::aMV[1,3]
   MSQuery( oApl:oMySql:hConnect,cSql )
EndIf
RETURN NIL

//------------------------------------//
METHOD INF( uVal,cSep ) CLASS TContabil
   LOCAL cType := ValType( uVal ), cValor := ""
   DEFAULT cSep := ""
do Case
Case EMPTY( uVal )
   cValor := "''"
Case cType == "C"
   uVal := STRTRAN( uVal,"'"," " )
   cValor := "'" + ALLTRIM( uVal ) + "'"
case cType == "D"
   cValor := "'" + NtChr( uVal,"2" ) + "'"
Case cType == "N"
   cValor := LTRIM( STR( uVal ) )
EndCase
RETURN cValor + cSep

//------------------------------------//
METHOD Dsctos( oLbd,nID ) CLASS TContabil
   LOCAL oDlg, oLbx
If nID == 0
   RETURN NIL
EndIf
 ::oArf:Seek( {"comprasc_id",nID} )

DEFINE DIALOG oDlg TITLE "Descuentos Condicionados" FROM 0, 0 TO 15,36

   @ 16,06 LISTBOX oLbx FIELDS DTOC( ::oArf:FECHA )                ,;
                          TRANSFORM( ::oArf:DSCTO,"99,999,999.99" ),;
                          TRANSFORM( ::oArf:PTAJE,       "999.99" ) ;
      HEADERS "Fecha" +CRLF+ "Descuento", "Descuento", "Porcentaje" ;
      SIZES 400, 450 SIZE 130,86 ;
      OF oDlg UPDATE PIXEL       ;
      ON DBLCLICK ::Editad( nID,oLbx,.f. )
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:nHeaderHeight := 28
    oLbx:GoTop()
    oLbx:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:aColSizes   := {84,86,86}
    oLbx:aHjustify   := {2,2,2}
    oLbx:aJustify    := {0,1,1}
    oLbx:ladjbrowse  := oLbx:lCellStyle  := .f.
    oLbx:ladjlastcol := .t.
    oLbx:bKeyDown := {|nKey| If(nKey == VK_ESCAPE, ( oDlg:End() ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, ::Editad( nID,oLbx,.t. ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, ::Editad( nID,oLbx,.f. ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE             , DelRecord( ::oArf,oLbx ), )))) }
   MySetBrowse( oLbx, ::oArf )
ACTIVATE DIALOG oDlg CENTERED
 oLbd:SetFocus()
RETURN NIL

//------------------------------------//
METHOD Editad( nID,oLbx,lNew ) CLASS TContabil
   LOCAL oDlg, cTit := "Modificando Descuento"
   LOCAL bGrabar, oGet := ARRAY(6)
If lNew
   cTit    := "Nuevo Descuento"
   bGrabar := {|| ::oArf:COMPRASC_ID := nID     ,;
                  ::oArf:Append( .t. )          ,;
                  ::oArf:xBlanK()               ,;
                  oDlg:Update(), oDlg:SetFocus() }
   oLbx:GoBottom() ; ::oArf:xBlank()
Else
   bGrabar := {|| ::oArf:Update( .f.,1 ), oDlg:End() }
EndIf

DEFINE DIALOG oDlg TITLE cTit FROM 0, 0 TO 10,30
   @ 02,00 SAY "Fecha"      OF oDlg RIGHT PIXEL SIZE 46,10
   @ 02,50 GET oGet[1] VAR ::oArf:FECHA OF oDlg ;
      SIZE 40,10 PIXEL
   @ 14,00 SAY "Descuento"  OF oDlg RIGHT PIXEL SIZE 46,10
   @ 14,50 GET oGet[2] VAR ::oArf:DSCTO OF oDlg PICTURE "99,999,999";
      VALID {|| If( ::oArf:DSCTO <  ::oArc:TOTALFAC, .t.           ,;
          (MsgStop( "Dscto debe ser Menor de "+STR(::oArc:TOTALFAC),"<< OJO >>"), .f.)) };
      SIZE 40,10 PIXEL UPDATE
   @ 26,00 SAY "Dscto US"   OF oDlg RIGHT PIXEL SIZE 46,10
   @ 26,50 GET oGet[3] VAR ::oArf:DSCTO_US OF oDlg PICTURE "99,999,999";
      VALID {|| If( ::oArf:DSCTO_US <  ::oArc:TOTALFAC, .t.           ,;
          (MsgStop( "Dscto debe ser Menor de "+STR(::oArc:TOTALFAC),"<< OJO >>"), .f.)) };
      SIZE 40,10 PIXEL UPDATE
   @ 38,00 SAY "Porcentaje" OF oDlg RIGHT PIXEL SIZE 46,10
   @ 38,50 GET oGet[4] VAR ::oArf:PTAJE OF oDlg PICTURE "999.99";
      SIZE 40,10 PIXEL UPDATE

   @ 52,30 BUTTON oGet[5] PROMPT "&Grabar"   SIZE 34,12 OF oDlg ACTION ;
      (If( EMPTY(::oArf:FECHA) .OR. ::oArf:DSCTO <= 0                 ,;
         ( MsgStop("Imposible grabar este Dscto"), oGet[1]:SetFocus()),;
         ( oGet[5]:Disable(), EVAL( bGrabar ), oGet[5]:Enable() ))) PIXEL
   @ 52,70 BUTTON oGet[6] PROMPT "&Cancelar" SIZE 34,12 OF oDlg CANCEL;
      ACTION ( oDlg:End() ) PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(240,200)
 oLbx:Refresh()
 oLbx:SetFocus()
RETURN NIL

//----------Conectar el Dsn-----------//
// oApl:aDsn[4] := .f.   lConected
// oApl:aDsn[5] := .f.   lValTable    Indica validar tablas existentes
// oApl:aDsn[6] := .t.   lSincroniza  Sincroniza el ODBC, solo conecta cuando lo necesitamos
FUNCTION Conectar()

 oApl:oWnd:SetMsg( "Conectando con ODBC" )

 oApl:oODbc := TODBC():New( oApl:aDsn[1],oApl:aDsn[2],oApl:aDsn[3] )

 oApl:oWnd:SetMsg( "Conectado con ODBC" )

 oApl:aDsn[4] := .t.
 If oApl:aDsn[7] == NIL
    oApl:aDsn[7] := .t.
    MsgWait( "ODBC, Conectado","Dsn",1 )
 EndIf
RETURN .t.

//-Si la conexción esta cerrada la Reactiva
FUNCTION ConectaOn()

 IF !oApl:aDsn[6]
    RETURN .F.
 ENDIF
 IF oApl:aDsn[4]
    RETURN .T.         // Esta Conectado
 ENDIF

 Conectar()            // Reestablece la Conexión
RETURN .f.

//-Si la conexción esta cerrada la Reactiva
FUNCTION ConectaOff()
   LOCAL I, aWindows
 If oApl:aDsn[4] .AND. oApl:aDsn[6]
    // Verifica que las Ventanas Hijas no tengan un Cursor TDBODBC Abierto
    aWindows := GetAllWin()

    FOR I := 1 TO LEN(aWindows)
       IF ValType(aWindows[I])="O" .AND. ValType(aWindows[i]:Cargo)="A" .AND. ValType(aWindows[I]:Cargo[1])="L" // Tiene un TDBODBC Abierto
          aWindows:=NIL
          RETURN .F.
       ENDIF
    NEXT

    aWindows := nil

    oApl:oOdbc:End()
    oApl:oOdbc   := oApl:aDsn[7] := NIL
    oApl:aDsn[4] := oApl:aDsn[5] := .f.
    oApl:aDsn[6] := .t.
 ELSE
    RETURN .F.           //Ya estaba apagada
 ENDIF
RETURN .T.

// Envia el Valor del oOdbc hacia otro programa o Clase
FUNCTION GetOdbc()
   ConectaOn()           // Rectifica la Conexción
RETURN oApl:oOdbc

//------------------------------------//
FUNCTION AscanX( aX,cCta,nX )
   LOCAL nIni, nFin := LEN( aX ), nPos := 0
FOR nIni := 2 TO nFin
   If aX[nIni,1] == cCta .AND.;
      aX[nIni,9] == nX
      nPos := nIni
      EXIT
   EndIf
NEXT nIni
RETURN nPos

//------------------------------------//
FUNCTION GrupoIca( sCod,cTM,nG )
   sCod := TRIM( sCod )
   do Case
      Case sCod == "0599000001" .OR. LEFT(sCod,2) == "01"
         nG := If( cTM == "S", 1, nG + 2 )       // Montura
      Case LEFT(sCod,2) >= "60" .OR.;
           sCod == "0599000003" .OR.;
           sCod == "0504"
         nG += 4                                 // L.Contacto
      Case LEFT(sCod,2) == "03" .OR.;
           LEFT(sCod,2) == "04"
         nG += 6                                 // Liquidos y Accesorios
      Case sCod == "0599000002" .OR. LEFT(sCod,2) == "02"
         nG := 8                                 // Oftalmicos
      Case LEFT(sCod,4) == "0501"
         nG := 9                                 // Consultas
      Case LEFT(sCod,4) >= "0502" .AND.;
           LEFT(sCod,4) <= "0599"
         nG := 10                                // Otros
   EndCase
RETURN nG

//--Coloca Font a Todos los Controls--//
FUNCTION PutFont( oDlg,oFont )
   DEFAULT oFont := oDlg:oFont
 AEVAL( oDlg:aControls, {|a| a:SetFont(oFont) } )
RETURN NIL