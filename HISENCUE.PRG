// Programa.: HISENCUE.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Encuestas.
#include "FiveWin.ch"

MEMVAR oApl

PROCEDURE Encuesta()
   LOCAL oDlg, oLbx, oGet := ARRAY(4), lSalir := .f.
   LOCAL aBarra, bEmp, oD
oD := TEncues() ; oD:New()
aBarra := { {|| oD:Editar( oLbx,.t. ) }, {|| oD:Editar( oLbx,.f. ) },;
            {|| oD:Archivo() }         , {|| oD:Borrar( oLbx ) }    ,;
            {|| oD:Listado(), oGet[1]:SetFocus() }                  ,;
            {|| lSalir := .t., oDlg:End() } }
bEmp := {|| If( oApl:oEmp:Seek( {"localiz",oD:aCab[1]} ),;
              ( nEmpresa( .t. ), oD:oDvc:xBlank()       ,;
                oDlg:Update(), .t. )                    ,;
              (MsgStop("Esta Optica NO EXISTE"), .f.) ) }
DEFINE DIALOG oDlg FROM 0, 0 TO 320, 600 PIXEL;
   TITLE "Encuesta"
   @ 16, 06 SAY "Optica"       OF oDlg RIGHT PIXEL SIZE 50,10
   @ 16, 58 GET oGet[1] VAR oD:aCab[1] OF oDlg PICTURE "@!";
      VALID EVAL( bEmp ) ;
      SIZE 21,10 PIXEL
   @ 28, 06 SAY "Año Encuesta" OF oDlg RIGHT PIXEL SIZE 50,10
   @ 28, 58 GET oGet[2] VAR oD:aCab[2] OF oDlg PICTURE "9999";
      SIZE 21,10 PIXEL UPDATE
   @ 40, 06 SAY "Semestre"     OF oDlg RIGHT PIXEL SIZE 50,10
   @ 40, 58 GET oGet[3] VAR oD:aCab[3] OF oDlg ;
      VALID oD:NEW( .t.,oLbx,oGet )            ;
      SIZE 21,10 PIXEL UPDATE
   @ 40,110 SAY "Control" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 40,173 SAY oGet[4] VAR oD:oDvc:CONTROL OF oDlg PIXEL SIZE  44,10 ;
      UPDATE COLOR nRGB( 128,0,255 )

   @ 60, 06 LISTBOX oLbx FIELDS                            ;
                     TRANSFORM( oD:oDvd:ENCUESTA,"9,999" ),;
                       oD:aEnc[ oD:oDvd:ATENCION_R+1 ]    ,;
                       oD:aEnc[ oD:oDvd:ATENCION_T+1 ]    ,;
                       oD:aEnc[ oD:oDvd:ATENCION_A+1 ]    ,;
                       oD:aEnd[ oD:oDvd:SERVICIOS +1 ]     ;
      HEADERS "Numero"  +CRLF+"Encuesta"  , "Atención"+CRLF+"recibida",;
              "Atención"+CRLF+"telefónica", "Atención"+CRLF+"asesora" ,;
              "Nuestros"+CRLF+"Serivicios"                             ;
      SIZES 400, 450 SIZE 290,90 ;
      OF oDlg UPDATE PIXEL       ;
      ON DBLCLICK EVAL( aBarra[2] )
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:GoTop()
    oLbx:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:nHeaderHeight := 28
    oLbx:aColSizes   := {90,90,90,90,90}
    oLbx:aHjustify   := {2,2,2,2,2}
    oLbx:aJustify    := {1,0,0,0,0}
    oLbx:ladjbrowse  := oLbx:lCellStyle  := .f.
    oLbx:ladjlastcol := .t.
    oLbx:bKeyDown := {|nKey| If(nKey == VK_ESCAPE, ( oGet[1]:SetFocus() ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(aBarra[1]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, EVAL(aBarra[2]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE, EVAL(aBarra[4]),) ))) }
   MySetBrowse( oLbx,oD:oDvd )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT ;
  (oDlg:Move(80,1), DefineBar( oDlg,oLbx,aBarra ),;
   oD:aCab[5] := oDlg)       ;
   VALID lSalir
oD:oDvc:Destroy()
oD:oDvd:Destroy()
RETURN

//------------------------------------//
CLASS TEncues

 DATA aEnc AS ARRAY INIT { "Sin Respuesta","Regular","Bueno","Muy Bueno","Excelente" }
 DATA aEnd AS ARRAY INIT { "Sin Respuesta","Regulares","Buenos","Excelentes" }
 DATA aCab, oDvc, oDvd

 METHOD NEW( lOK,oLbx,oGet ) Constructor
 METHOD Borrar( oLbx )
 METHOD Editar( oLbx,lNew )
 METHOD Grabar( oLbx,lNew )
 METHOD Archivo()
 METHOD Listado()

ENDCLASS

//------------------------------------//
METHOD NEW( lOK,oLbx,oGet ) CLASS TEncues
If lOK == NIL
   oApl:oEmp:Seek( {"optica",0} )
   ::aCab := { oApl:cLocal,YEAR(DATE()),1,0,"" }
   ::oDvc := oApl:Abrir( "encuestc","optica, control",.t.,,10 )
   ::oDvd := oApl:Abrir( "encuestd","optica, control",.t.,,100 )
   ::oDvd:Seek( {"optica",0,"control",0} )
Else
   If EMPTY( ::aCab[2] )
      MsgStop( "No puede ir en Blanco","AÑO" )
      lOK := .f.
   ElseIf Rango( ::aCab[3],1,2 )
      If ::oDvc:Seek( {"optica",oApl:nEmpresa,"periodo",::aCab[2],"semestre",::aCab[3]} )
         oGet[3]:oJump := oLbx
      EndIf
      ::oDvd:Seek( {"optica",oApl:nEmpresa,"control",::oDvc:CONTROL},"encuesta",.t. )
      ::aCab[5]:Update()
      oLbx:Refresh()
   Else
      MsgStop( "1_Primer,  2_Segundo","SEMESTRE" )
      lOK := .f.
   EndIf
EndIf

RETURN lOK

//------------------------------------//
METHOD Borrar( oLbx ) CLASS TEncues
If MsgNoYes( "Esta Encuesta "+STR(::oDvd:ENCUESTA),"Elimina" )
   If ::oDvd:Delete( .t.,1 )
      PListbox( oLbx,::oDvd )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Editar( oLbx,lNew ) CLASS TEncues
   LOCAL bGrabar, oDlg, oGet := ARRAY(16)
   LOCAL aEd := { "Modificando Encuesta",1,1,1,1,1,1,1,1,1,1,1,1 }
If EMPTY( ::aCab[2] )
   MsgStop( "Encuesta sin AÑO",">>> OJO <<<" )
   RETURN NIL
EndIf
lNew := If( ::oDvd:nRowCount == 0, .t., lNew )
If lNew
   aEd[1]  := "Nueva Encuesta"
   bGrabar := {|| ::Grabar( oLbx,lNew )     ,;
                  ::oDvd:xBlanK()           ,;
                  AFILL( aEd,1,2 )          ,;
                  oDlg:Update(), oDlg:SetFocus() }
   oLbx:GoBottom() ; ::oDvd:xBlank()
Else
   bGrabar := {|| ::Grabar( oLbx,lNew ), oLbx:Refresh(), oDlg:End() }
EndIf
   AEVAL( ::oDvd:axBuffer, { |x,p| aEd[p-3] := x+1 },14,3 )
DEFINE DIALOG oDlg TITLE aEd[1] FROM 0, 0 TO 25,54
   @  02, 00 SAY          "Encuesta No." OF oDlg RIGHT PIXEL SIZE 138,10
   @  02,140 GET oGet[1] VAR ::oDvd:ENCUESTA OF oDlg SIZE 40,10 PIXEL
   @  14, 00 SAY "Prontitud en la atención recibida" OF oDlg RIGHT PIXEL SIZE 138,10
   @  14,140 GET oGet[02] VAR ::oDvd:ATENCION_R OF oDlg PICTURE "9";
      VALID Rango( ::oDvd:ATENCION_R,0,4 )   SIZE 10,10 PIXEL UPDATE
   @  26, 00 SAY "Calidad en la atención telefónica" OF oDlg RIGHT PIXEL SIZE 138,10
   @  26,140 GET oGet[03] VAR ::oDvd:ATENCION_T OF oDlg PICTURE "9";
      VALID Rango( ::oDvd:ATENCION_T,0,4 )   SIZE 10,10 PIXEL UPDATE
// @  26,140 COMBOBOX oGet[03] VAR aEd[03] ITEMS ::aEnc;
//    SIZE 50,99 OF oDlg PIXEL UPDATE
   @  38, 00 SAY "Atención de la asesora" OF oDlg RIGHT PIXEL SIZE 138,10
   @  38,140 GET oGet[04] VAR ::oDvd:ATENCION_A OF oDlg PICTURE "9";
      VALID Rango( ::oDvd:ATENCION_A,0,4 )   SIZE 10,10 PIXEL UPDATE
   @  50, 00 SAY "Atención del profesional" OF oDlg RIGHT PIXEL SIZE 138,10
   @  50,140 GET oGet[05] VAR ::oDvd:ATENCION_P OF oDlg PICTURE "9";
      VALID Rango( ::oDvd:ATENCION_P,0,4 )   SIZE 10,10 PIXEL UPDATE
   @  62, 00 SAY "Calidad de información suministrada" OF oDlg RIGHT PIXEL SIZE 138,10
   @  62,140 GET oGet[06] VAR ::oDvd:CALIDAD_IS OF oDlg PICTURE "9";
      VALID Rango( ::oDvd:CALIDAD_IS,0,4 )   SIZE 10,10 PIXEL UPDATE
   @  74, 00 SAY "Prontitud en la entrega de su trabajo" OF oDlg RIGHT PIXEL SIZE 138,10
   @  74,140 GET oGet[07] VAR ::oDvd:PRONTITUD  OF oDlg PICTURE "9";
      VALID Rango( ::oDvd:PRONTITUD,0,4 )    SIZE 10,10 PIXEL UPDATE
   @  86, 00 SAY "Calidad del producto recibido" OF oDlg RIGHT PIXEL SIZE 138,10
   @  86,140 GET oGet[08] VAR ::oDvd:CALIDAD_PR OF oDlg PICTURE "9";
      VALID Rango( ::oDvd:CALIDAD_PR,0,4 )   SIZE 10,10 PIXEL UPDATE
   @  98, 00 SAY "Comodidad, orden y limpieza de nuestras instalaciones" OF oDlg RIGHT PIXEL SIZE 138,10
   @  98,140 GET oGet[09] VAR ::oDvd:INSTALACIO OF oDlg PICTURE "9";
      VALID Rango( ::oDvd:INSTALACIO,0,4 )   SIZE 10,10 PIXEL UPDATE
   @ 110, 00 SAY "Atención de portería" OF oDlg RIGHT PIXEL SIZE 138,10
   @ 110,140 GET oGet[10] VAR ::oDvd:ATENCION_P OF oDlg PICTURE "9";
      VALID Rango( ::oDvd:ATENCION_P,0,4 )   SIZE 10,10 PIXEL UPDATE
   @ 122,00 SAY "En terminos generales cómo califica nuestros servicios" OF oDlg RIGHT PIXEL SIZE 138,10
   @ 122,140 COMBOBOX oGet[11] VAR aEd[11] ITEMS ::aEnd;
      SIZE 50,99 OF oDlg PIXEL UPDATE
   @ 134,00 SAY "Recomendaria a otra persona nuestro establecimiento" OF oDlg RIGHT PIXEL SIZE 138,10
   @ 134,140 COMBOBOX oGet[12] VAR aEd[12] ITEMS {"Sin Respuesta","SI","NO"};
      SIZE 50,99 OF oDlg PIXEL UPDATE
   @ 146,00 SAY "Queja o Reclamo" OF oDlg RIGHT PIXEL SIZE 138,10
   @ 146,140 COMBOBOX oGet[13] VAR aEd[13] ITEMS {"Sin Respuesta","Queja","Reclamo"};
      SIZE 50,99 OF oDlg PIXEL UPDATE
   @ 158,00 SAY "Se Resolvio el Caso adverso" OF oDlg RIGHT PIXEL SIZE 138,10
   @ 158,140 CHECKBOX oGet[14] VAR ::oDvd:RESUELTO   PROMPT "" OF oDlg;
      SIZE 60,12 PIXEL WHEN aEd[13] > 1

   @ 172, 70 BUTTON oGet[15] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION   ;
      (If( EMPTY( ::oDvd:ENCUESTA )                                       ,;
         ( MsgStop("Imposible grabar esta Encuesta"), oGet[1]:SetFocus() ),;
         ( AEVAL( aEd, { |x,p| ::oDvd:axBuffer[p+3] := x-1 },11 ), EVAL(bGrabar) ) )) PIXEL
   @ 172,120 BUTTON oGet[16] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL  ;
      ACTION ( oDlg:End() ) PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
RETURN NIL

//------------------------------------//
METHOD Grabar( oLbx,lNew ) CLASS TEncues
   LOCAL lSi
If !::oDvc:lOK
   ::oDvc:OPTICA   := oApl:nEmpresa
   ::oDvc:PERIODO  := ::aCab[2]
   ::oDvc:SEMESTRE := ::aCab[3]
   ::oDvc:Append( .t. )
   ::aCab[5]:Update()
EndIf
If lNew
   ::oDvd:OPTICA  := oApl:nEmpresa
   ::oDvd:CONTROL := ::oDvc:CONTROL
   ::oDvd:Append( .t. )
   PListbox( oLbx,::oDvd )
Else
   ::oDvd:Update( .t.,1 )
EndIf
RETURN NIL

//-----------------------------------//
METHOD Archivo() CLASS TEncues
   LOCAL aLC, aRes, cQry, cReg, hRes, nL, nX
cQry := "SELECT atencion_r, atencion_t, atencion_a, atencion_o, "+;
               "calidad_is, prontitud , calidad_pr, instalacio, "+;
               "atencion_p, servicios , adversos  , resuelto "   +;
        "FROM encuestd "                               +;
        "WHERE optica  = " + LTRIM(STR(oApl:nEmpresa)) +;
         " AND control = " + LTRIM(STR(::oDvc:CONTROL))
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes ) ; RETURN NIL
EndIf
aLC := { 0,nL,0,0,ALLTRIM( STRTRAN(oApl:oEmp:NIT,".","") ),;
         If( ::aCab[3] == 1, "41", "43" ) }
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   FOR nX := 2 TO 10
      aRes[01] += aRes[nX]
   NEXT nX
   If aRes[01] > 19.5
       aLC[1] ++
   EndIf
   If aRes[11] > 0
       aLC[3] += If( aRes[12], 1, 0 )
       aLC[4] ++
   EndIf
   nL --
EndDo
   MSFreeResult( hRes )
/*
   cRut := AbrirFile( 1,,"ct.txt" )
   If (nK := RAT( "\", cRut )) > 0
      cRut := LEFT( cRut,nK )
   Else
      cRut := "A:"
   EndIf
*/
 aRes := STRTRAN( aLC[5],"-",""  ) + aLC[6] + STR(::aCab[2],4) + "062.TXT"
 cQry := STRTRAN( aLC[5],"-","," ) + "," +  + aLC[6] + "," + STR(::aCab[2],4) +;
         ",062," + oApl:oEmp:RESHABIT + ALLTRIM(oApl:oEmp:SSALUD)
 cReg := ",I.3.3.0," + LTRIM(STR(aLC[3])) + "," + LTRIM(STR(aLC[4])) + CRLF
 hRes := FCREATE( aRes, 0 )
 FWRITE( hRes, cQry + cReg )
 cReg := ",I.4.1.0," + LTRIM(STR(aLC[1])) + "," + LTRIM(STR(aLC[2])) + CRLF
 FWRITE( hRes, cQry + cReg )
 FCLOSE( hRes )
 MsgStop( "Está en la Carpeta "+CURDIR(),"El Archivo "+aRes )
RETURN NIL

//------------------------------------//
METHOD Listado() CLASS TEncues
   LOCAL aRes, aGT, cQry, hRes, nGT, nL, nX, oRpt
cQry := "SELECT atencion_r, atencion_t, atencion_a, atencion_o, "+;
               "calidad_is, prontitud , calidad_pr, instalacio, "+;
               "atencion_p, servicios , recomendar, adversos "   +;
        "FROM encuestd "                               +;
        "WHERE optica  = " + LTRIM(STR(oApl:nEmpresa)) +;
         " AND control = " + LTRIM(STR(::oDvc:CONTROL))
//         " ORDER BY encuesta"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MsgInfo( "NO HAY INFORMACION PARA LISTAR" )
   MSFreeResult( hRes ) ; RETURN NIL
EndIf
  aGT := ARRAY(13,2)
  nGT := nL
AEVAL( aGT, { |x| AFILL( x,0 ) } )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   FOR nX := 1 TO 11
      If aRes[nX] == 0
          aGT[nX,1] ++
      Else
          aGT[nX,2] += aRes[nX]
      EndIf
          aGT[13,2] += aRes[nX]
   NEXT nX
   If aGT[13,2] - aRes[11] > 19.5
      aGT[13,1] ++
   EndIf
      aGT[13,2] := 0
   nL --
EndDo
 MSFreeResult( hRes )
aRes := { "PRONTITUD EN LA ATENCION RECIBIDA",;
          "CALIDAD EN LA ATENCION TELEFONICA",;
          "ATENCION DE LA ASESORA"  ,;
          "ATENCION DEL PROFESIONAL",;
          "CALIDAD DE INFORMACION SUMINISTRADA"  ,;
          "PRONTITUD EN LA ENTREGA DE SU TRABAJO",;
          "CALIDAD DEL PRODUCTO RECIBIDO",;
          "COMODIDAD, ORDEN Y LIMPIEZA DE NUESTRAS INSTALACIONES",;
          "ATENCION DE PORTERIA",;
          "EN TERMINOS GENERALES COMO CALIFICA NUESTROS SERVICIOS",;
          "RECOMENDARIA A OTRA PERSONA NUESTRO ESTABLECIMIENTO" }
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"ENCUESTAS"             ,;
         STR(::aCab[3]) + " SEMESTRE DE " + STR(::aCab[2],4) },.t.,,2 )
   oRpt:Titulo( 100 )
   oRpt:Say( 08,52,"TOTAL SIN       TOTAL    PORCENTAJE" )
   oRpt:Say( 09,52,"RESPONDER     PUNTAJE      PROMEDIO" )
   oRpt:nL := 10
FOR nL := 1 TO 11
   aGT[12,1] += aGT[nL,1]
   aGT[12,2] += aGT[nL,2]
   nX  := ROUND( aGT[nL,2] / (nGT - aGT[nL,1]),3 )
   oRpt:Say( oRpt:nL,00,aRes[nL] )
   oRpt:Say( oRpt:nL,54,TRANSFORM(aGT[nL,1],"@Z 999,999") )
   oRpt:Say( oRpt:nL,66,TRANSFORM(aGT[nL,2],"@Z 999,999") )
   oRpt:Say( oRpt:nL,80,TRANSFORM(       nX,"@Z 999.999") )
   oRpt:nL += 2
NEXT nL
   oRpt:Say(  oRpt:nL,00,REPLICATE("=",100) )
   oRpt:Say(++oRpt:nL,01,"TOTAL DE ENCUESTAS ======>" +;
                         TRANSFORM( nGT,"999,999" ) )
   oRpt:Say(  oRpt:nL,52,TRANSFORM(aGT[12,1],"9,999,999") )
   oRpt:Say(  oRpt:nL,64,TRANSFORM(aGT[12,2],"9,999,999") )
   oRpt:Say(++oRpt:nL,01,"CLIENTES SATISFECHOS ====>" +;
                         TRANSFORM(aGT[13,1],"999,999" ) )
   oRpt:NewPage()
   oRpt:End()
RETURN NIL
