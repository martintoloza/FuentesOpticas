// Programa.: CAOPRECI.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Modificar los Precios de Lentes Oftalmicos
#include "Fivewin.ch"
#include "TSBrowse.ch"

MEMVAR oApl

#define CLR_NBLUE nRGB( 128,128,192 )

PROCEDURE LentesOft()
   LOCAL oDlg, oMat, oEsf, oGet := ARRAY(7), aL, aTer
   LOCAL aMat, aTip, nTer, nMat, nTip
   LOCAL aTM := { { 0, 0, 0, 0, 0, 0 } }, aTE := { { 0, 0, 0, 0, 0 } }
If TRIM( oApl:cUser ) # "root"
   MsgStop( "Usted no está Autorizado para Cambiar Precios",oApl:cUser )
   RETURN
EndIf
aL   := { "M    ","  ","  ",;
          {|| aL[1] := aTip[nTip,3] ,;
              aL[2] := aL[3] := "  ", oDlg:Update() },;
          {|cTB,nRow,nVal| cTB := "UPDATE " + cTB + LTRIM(STR(nVal))+;
                               " WHERE row_id = " + LTRIM(STR(nRow)),;
            MSQuery( oApl:oMySql:hConnect,cTB ) } }
aTer := { {"Tallado"," "},{"Terminado","T"},{"Coquilla","C"} }
aMat := Material()
aTip := Material( "0" )
nTer := nMat := nTip := 1

DEFINE DIALOG oDlg FROM 0, 0 TO 320, 650 PIXEL;
   TITLE "Precios LENTES OFTALMICOS"
   @ 02,00 SAY "Clase de Lente"    OF oDlg RIGHT PIXEL SIZE 66,10
   @ 02,70 COMBOBOX oGet[1] VAR nTer ITEMS ArrayCol( aTer,1) SIZE  60,99 OF oDlg PIXEL
   @ 16,00 SAY "Clase de Material" OF oDlg RIGHT PIXEL SIZE 66,10
   @ 16,70 COMBOBOX oGet[2] VAR nMat ITEMS ArrayCol( aMat,1) SIZE 110,99 OF oDlg PIXEL;
      ON CHANGE( aTip := Material( aMat[nMat,2],aTip,oGet[3] ),;
                 nTip := 1, EVAL( aL[4] ) )
   @ 30,00 SAY "Tipo  de Material" OF oDlg RIGHT PIXEL SIZE 66,10
   @ 30,70 COMBOBOX oGet[3] VAR nTip ITEMS ArrayCol( aTip,1) ;
     SIZE 140,99 OF oDlg PIXEL UPDATE
    oGet[3]:bLostFocus := { || EVAL( aL[4] ) }
   @ 30,220 SAY aTip[nTip,2]       OF oDlg PIXEL SIZE 66,10 UPDATE
   @ 44,00 SAY "Caracteristica"    OF oDlg RIGHT PIXEL SIZE 66,10
   @ 44,70 GET oGet[4] VAR aL[1]   OF oDlg PICTURE "@!"        ;
      WHEN aTer[nTer,2] == " " .AND. aMat[nMat,2] == "0" .AND. ;
           aTip[nTip,2] == "11" ;
      VALID (If( aL[1] == "M    " .OR. aL[1] == "LEN  ", .t.  ,;
            (MsgStop( "Caracteristica NO EXISTE" ),.f. )))     ;
      SIZE 30,12 PIXEL UPDATE
    oGet[4]:cToolTip := "[LEN] PARA MONOFOCAL LENTICULAR NEGATIVO CON DISEÑO ESPECIAL"
   @ 44,110 SAY "Color del Vidrio"  OF oDlg RIGHT PIXEL SIZE 66,10
   @ 44,180 GET oGet[5] VAR aL[2]   OF oDlg PICTURE "@!";
      WHEN aMat[nMat,2] == "V"                          ;
      VALID ( If( aL[2] $ "BL CL FG HB",           .t. ,;
                ( MsgStop( "Color NO EXISTE" ),.f. )))  ;
      SIZE 24,12 PIXEL UPDATE
    oGet[5]:cToolTip := "BL, CL, FG, HB"
   @ 58, 00 SAY "Tipo  de Esfera"   OF oDlg RIGHT PIXEL SIZE 66,10
   @ 58, 70 GET oGet[6] VAR aL[3]   OF oDlg PICTURE "@!";
      WHEN aTer[nTer,2] == "T"                          ;
      SIZE 22,12 PIXEL UPDATE
   @ 58,130 BUTTON oGet[7] PROMPT "&OK"   SIZE 44,12 OF oDlg ACTION        ;
      ( If( Precios( aTer[nTer,2],aMat[nMat,2],aTip[nTip,2],aL,@aTM,@aTE ),;
          ( oMat:aArray := aTM, oMat:Refresh(), oEsf:aArray := aTE        ,;
            oEsf:Refresh(), oGet[7]:oJump := oMat, oMat:SetFocus() )      ,;
          ( oGet[7]:oJump := oGet[2], oGet[2]:SetFocus() ) ) ) PIXEL
   @ 72,00 SAY "CADTMATE"  OF oDlg CENTER PIXEL SIZE 150,10
   @ 84,06 BROWSE oMat                 ;
           COLORS CLR_BLACK,CLR_NBLUE  ;
           SIZE 156, 70 PIXEL OF oDlg CELLED
    oMat:SetArray( aTM )
    oMat:nHeightCell += 4
    oMat:nHeightHead += 4
    oMat:lAutoEdit   := !oApl:lEnLinea
      ADD COLUMN TO BROWSE oMat DATA ARRAY ELEMENT 1;
          TITLE "CONSEC"           PICTURE "999999" ;
          SIZE  54 ;
          3DLOOK TRUE, TRUE, TRUE;
          MOVE DT_MOVE_NEXT;
          ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT
      ADD COLUMN TO BROWSE oMat DATA ARRAY ELEMENT 6;
          TITLE "Esfera" + CRLF + "+" PICTURE "999" ;
          SIZE  48 ;
          3DLOOK TRUE, TRUE, TRUE;
          MOVE DT_MOVE_NEXT;
          ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT
      ADD COLUMN TO BROWSE oMat DATA ARRAY ELEMENT 2;
          TITLE "Diametro"         PICTURE     "99" ;
          SIZE  55 ;
          3DLOOK TRUE, TRUE, TRUE;
          MOVE DT_MOVE_NEXT;
          ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT
      ADD COLUMN TO BROWSE oMat DATA ARRAY ELEMENT 3;
          TITLE "Precio" + CRLF + "Público"         ;
          PICTURE "9,999,999";
          SIZE  80 EDITABLE  ;
          3DLOOK TRUE, TRUE, TRUE;
          MOVE DT_MOVE_NEXT;
          ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT ;
          POSTEDIT { |uVar| If( oMat:lChanged,;
               EVAL( aL[5],"cadtmate SET valventa = ",aTM[oMat:nAt,5],uVar ), ) }
      ADD COLUMN TO BROWSE oMat DATA ARRAY ELEMENT 4;
          TITLE "Precio" + CRLF + "Costo"           ;
          PICTURE "9,999,999";
          SIZE  80 EDITABLE  ;
          3DLOOK TRUE, TRUE, TRUE;
          MOVE DT_MOVE_NEXT;
          ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT ;
          POSTEDIT { |uVar| If( oMat:lChanged,;
               EVAL( aL[5],"cadtmate SET pcosto = "  ,aTM[oMat:nAt,5],uVar ), ) }
    oMat:SetColor( { 3,4,5,6 }, ;
                   { CLR_BLACK, oApl:nClrBackHead, oApl:nClrNFore, oApl:nClrNBack} )

   @ 84,168 BROWSE oEsf                ;
           COLORS CLR_BLACK,CLR_NBLUE  ;
           SIZE 150, 70 PIXEL OF oDlg CELLED
    oEsf:SetArray( aTE )
    oEsf:nHeightCell += 4
    oEsf:nHeightHead += 4
      ADD COLUMN TO BROWSE oEsf DATA ARRAY ELEMENT 1;
          TITLE "Esfera_De"        PICTURE "999.99" ;
          SIZE  72 ;
          3DLOOK TRUE, TRUE, TRUE;
          MOVE DT_MOVE_NEXT;
          ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT
      ADD COLUMN TO BROWSE oEsf DATA ARRAY ELEMENT 2;
          TITLE "Esfera_A"         PICTURE "999.99" ;
          SIZE  72 ;
          3DLOOK TRUE, TRUE, TRUE;
          MOVE DT_MOVE_NEXT;
          ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT
      ADD COLUMN TO BROWSE oEsf DATA ARRAY ELEMENT 3;
          TITLE "Precio" + CRLF + "Público"         ;
          PICTURE "9,999,999";
          SIZE  86 EDITABLE;
          3DLOOK TRUE, TRUE, TRUE;
          MOVE DT_MOVE_NEXT;
          ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT ;
          POSTEDIT { |uVar| If( oEsf:lChanged,;
               EVAL( aL[5],"cadtesfe SET valventa = ",aTE[oEsf:nAt,5],uVar ), ) }
      ADD COLUMN TO BROWSE oEsf DATA ARRAY ELEMENT 4;
          TITLE "Precio" + CRLF + "Costo"           ;
          PICTURE "9,999,999";
          SIZE  86 EDITABLE;
          3DLOOK TRUE, TRUE, TRUE;
          MOVE DT_MOVE_NEXT;
          ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT ;
          POSTEDIT { |uVar| If( oEsf:lChanged,;
               EVAL( aL[5],"cadtesfe SET pcosto = "  ,aTE[oEsf:nAt,5],uVar ), ) }
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT ( oDlg:Move(80,1) )

RETURN

//------------------------------------//
STATIC FUNCTION Material( cClase,aTipo,oGet )
   LOCAL aTip := {}, cQry, hRes, nL
If cClase == NIL
   aTipo := " "
// cQry := "SELECT DISTINCTROW clase_mate, nombre_cla FROM cadtlist " +;
   cQry := "SELECT clase_mate, nombre_cla FROM cadtlist "+;
            "WHERE clase_mate <> 'S' AND activo = '0' "  +;
            "ORDER BY clase_mate, tipo_mater, tipol"
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   While nL > 0
      cQry := MyReadRow( hRes )
      AEVAL( cQry, { | xV,nP | cQry[nP] := MyClReadCol( hRes,nP ) } )
      If cQry[1] # aTipo
         AADD( aTip, { cQry[1] + " " + cQry[2],cQry[1] } )
         aTipo := cQry[1]
      EndIf
      nL --
   EndDo
Else
   cQry := "SELECT nombre, tipo_mater, tipo_lista FROM cadtlist "+;
           "WHERE clase_mate = " + xValToChar( cClase )          +;
            " AND activo = '0' ORDER BY clase_mate, tipo_mater, tipol"
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   nL   := MSNumRows( hRes )
   If nL > 0 .AND. cClase == "0"
      cQry := MyReadRow( hRes )
      nL --
   EndIf
   While nL > 0
      cQry := MyReadRow( hRes )
      AEVAL( cQry, { | xV,nP | cQry[nP] := MyClReadCol( hRes,nP ) } )
      AADD( aTip, { cQry[1],cQry[2],cQry[3] } )
      nL --
   EndDo
   If oGet # NIL
      AEVAL( aTipo, { |x| oGet:Del(1) } )
      AEVAL( aTip , { |x| oGet:Add( x[1] ) } )
   EndIf
EndIf
   MSFreeResult( hRes )
RETURN aTip

//------------------------------------//
STATIC FUNCTION Precios( cTer,cCla,cTip,aL,aTM,aTE )
   LOCAL aPC
aPC := Buscar( { "terminado",cTer,"clasemat" ,cCla ,;
                 "tipomat"  ,cTip,"tipolista",aL[1],;
                 "colorv"   ,aL[2],"tipoesfe",aL[3] },"cadtmate",;
                 "consec, diametro, valventa, pcosto, row_id, esferap",2 )
If LEN( aPC ) == 0
   RETURN .f.
EndIf
aTM := ACLONE( aPC )
aPC := Buscar( { "consec",aTM[1,1],"terminado",cTer },"cadtesfe",;
                 "esfera_de, esfera_a, valventa, pcosto, row_id",2 )
If LEN( aPC ) == 0
   RETURN .f.
EndIf
aTE := ACLONE( aPC )
RETURN .t.

//------------------------------------//
PROCEDURE PreciosOft( cTB,nPP,nPC )
   LOCAL aLO, cQry, hRes, nF
If !AbreDbf( "Tmp",cTB,,,.f. )
   RETURN
EndIf
aLO := { "SELECT 1 FROM " + cTB + " WHERE row_id = " ,;
         "UPDATE " + cTB + " SET " + FieldName( nPP ),;
         "INSERT INTO " + cTB + " VALUES ( ",FCOUNT() }
While !Tmp->(EOF())
   hRes := If( MSQuery( oApl:oMySql:hConnect,aLO[1]+LTRIM(STR(Tmp->ROW_ID)) ),;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   If MSNumRows( hRes ) > 0
      cQry := aLO[2] + " = " + LTRIM(STR(FieldGet( nPP ))) +;
               ", pcosto = " + LTRIM(STR(FieldGet( nPC ))) +;
          " WHERE row_id = " + LTRIM(STR(Tmp->ROW_ID))
   Else
      cQry := aLO[3]
      FOR nF := 1 TO aLO[4]
         cQry += xValToChar( FieldGet( nF ),1 ) + ", "
      NEXT nF
      cQry := LEFT( cQry,LEN(cQry)-2 ) + " )"
   EndIf
   MSFreeResult( hRes )
   MSQuery( oApl:oMySql:hConnect,cQry )
   Tmp->(dbSkip())
Enddo
dbCloseArea()
RETURN

//------------------------------------//
PROCEDURE Constantes()
   LOCAL oDlg, oGet := ARRAY(10), cNombre, lOk := .f.
   LOCAL aPrv := Privileg( "CONSTANTES" )
If !aPrv[2]
   MsgStop( "Usted no esta Autorizado para hacer CAMBIOS" )
   RETURN
EndIf
cNombre := oApl:oEmp:NOMBRE
DEFINE DIALOG oDlg TITLE "CONSTANTES OPTICA" FROM 0, 0 TO 18,70
   @  02, 00 SAY "NOMBRE DE LA EMPRESA" OF oDlg RIGHT PIXEL SIZE 100,10
   @  02,102 GET oGet[1] VAR cNombre OF oDlg PICTURE "@!" SIZE 140,12 PIXEL;
      WHEN aPrv[1]
   @  16, 00 SAY    "NIT DE LA EMPRESA" OF oDlg RIGHT PIXEL SIZE 100,10
   @  16,102 GET oGet[2] VAR oApl:oEmp:NIT OF oDlg PICTURE "@!" SIZE 68,12 PIXEL;
      WHEN aPrv[1]
   @  30, 00 SAY "DIRECCION"     OF oDlg RIGHT PIXEL SIZE 100,10
   @  30,102 GET oGet[3] VAR oApl:oEmp:DIRECCION  OF oDlg PICTURE "@!" SIZE 124,12 PIXEL
   @  44, 00 SAY "OBSERVACIONES" OF oDlg RIGHT PIXEL SIZE 100,10
   @  44,102 GET oGet[4] VAR oApl:oEmp:OBSERVA    OF oDlg PICTURE "@!" SIZE 124,12 PIXEL
   @  58, 00 SAY "# FACTURA"     OF oDlg RIGHT PIXEL SIZE 100,10
   @  58,102 GET oGet[5] VAR oApl:oEmp:NUMFACU    OF oDlg SIZE 50,12 PIXEL
   @  72, 00 SAY "# COTIZACION"  OF oDlg RIGHT PIXEL SIZE 100,10
   @  72,102 GET oGet[6] VAR oApl:oEmp:NUMFACZ    OF oDlg SIZE 50,12 PIXEL
   @  86, 00 SAY "# HISTORIA"    OF oDlg RIGHT PIXEL SIZE 100,10
   @  86,102 GET oGet[7] VAR oApl:oEmp:NRO_HISTOR OF oDlg SIZE 50,12 PIXEL
   @ 100, 00 SAY "# DEVOLUCION"  OF oDlg RIGHT PIXEL SIZE 100,10
   @ 100,102 GET oGet[8] VAR oApl:oEmp:NUMDEVOL   OF oDlg SIZE 50,12 PIXEL
   @ 116,100 BUTTON oGet[09] PROMPT "&Aceptar"  SIZE 44,12 OF oDlg ACTION;
      ( lOk := MsgYesNo( "Graba estos Datos" ), oDlg:End() ) PIXEL
   @ 116,150 BUTTON oGet[10] PROMPT "&Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
If lOk
   oApl:oEmp:NOMBRE := oApl:cEmpresa := ALLTRIM( cNombre )
   oApl:oEmp:Update( .t.,1 )
EndIf
RETURN