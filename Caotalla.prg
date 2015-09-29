// Programa.: CAOTALLA.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Comparacion precios Ordenes Talla.
#include "FiveWin.ch"

MEMVAR oApl

PROCEDURE CaoTalla()
   LOCAL aOpc, oDlg, oTL, oGet := ARRAY(8)
oTL  := TCompara() ; oTL:NEW()
aOpc := { { {|| oTL:ArmarInf( oDlg ) },"Precio Público" },;
          { {|| oTL:NCredito( oGet ) },"Precio Costo" }  ,;
          { {|| oTL:Traslado( oGet ) },"Contabilizar" }  ,;
          { {|| oTL:RCaja( oDlg ) }   ,"Nomina Excel" } }
DEFINE DIALOG oDlg TITLE "Comparacion precios O.Talla" FROM 0, 0 TO 09,50
   @ 02, 00 SAY "FECHA INICIAL [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 02, 82 GET oGet[1] VAR oTL:aLS[2] OF oDlg  SIZE 40,10 PIXEL
   @ 14, 00 SAY "FECHA  FINAL  [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 80,10
   @ 14, 82 GET oGet[2] VAR oTL:aLS[3] OF oDlg ;
      VALID oTL:aLS[3] >= oTL:aLS[2] SIZE 40,10 PIXEL
   @ 26, 00 SAY "Comparar Orden Talla A"   OF oDlg RIGHT PIXEL SIZE 80,10
   @ 26, 82 COMBOBOX oGet[3] VAR oTL:aLS[6] ITEMS ArrayCol( aOpc,2 );
      SIZE 48,94 OF oDlg PIXEL
   @ 14,140 CHECKBOX oGet[8] VAR oTL:aLS[10] PROMPT "Ajustar C.Orden" OF oDlg;
      SIZE 60,12 PIXEL
   @ 26,140 CHECKBOX oGet[4] VAR oTL:aLS[9] PROMPT "Vista Previa" OF oDlg;
      SIZE 60,12 PIXEL
   @ 40, 40 BUTTON oGet[5] PROMPT "Aceptar"  SIZE 44,12 OF oDlg ACTION ;
      ( oGet[5]:Disable(), EVAL( aOpc[ oTL:aLS[6],1 ] ), oDlg:End() ) PIXEL
   @ 40, 90 BUTTON oGet[6] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   @ 46, 02 SAY "[CAOTALLA]" OF oDlg PIXEL SIZE 32,10
   @ 54, 10 SAY oGet[7] VAR oTL:aLS[4] OF oDlg PIXEL SIZE 160,10 ;
      UPDATE COLOR nRGB( 128,0,255 )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg CENTERED
ConectaOff()
RETURN

//------------------------------------//
CLASS TCompara FROM TContabil

 METHOD NEW( cQry ) Constructor
 METHOD ArmarInf( oDlg )
 METHOD Traslado( oGet )
 METHOD Reposicion( oGet )
 METHOD NCredito( oGet )
 METHOD Ajustes( aCT,nVal )
 METHOD Facturas( aCT,cOpt )
 METHOD RCaja( oDlg )
ENDCLASS

//------------------------------------//
METHOD NEW( cQry ) CLASS TCompara
If cQry == NIL
   Super:New()
   Empresa()
   ::aLS := { 2,DATE(),DATE(),oApl:oEmp:CODIGOLOC,0,2,"CV","9",.t.,.f.,0 }
ElseIf VALTYPE( cQry ) == "A"
   cQry[1]:DropIndex( "Factura" )
   cQry[1]:Destroy()
   MSQuery( oApl:oMySql:hConnect,"DROP TABLE cadtalla" )
   oApl:oDb:GetTables()
ElseIf ::aLS[2] >= CTOD("01.10.2009")
   cQry := STRTRAN( cQry,"ordenes_r","pedido_c" )
EndIf
RETURN NIL

//------------------------------------//
METHOD RCaja( oDlg ) CLASS TCompara
   LOCAL aCT := ARRAY(11), aEpl := ARRAY(19)
   LOCAL oRpt, oCursor,  hRes, nK, nP
   LOCAL cCel, cFile
cCel := "SELECT e.codigo, n.nit, n.nombre, v.clase_pd,"        +;
              " v.concepto, SUM(v.horas), SUM(v.valor_noved) " +;
        "FROM   nits n, nomemple e, nomnoved v "               +;
        "WHERE e.codigo_nit  = n.codigo_nit"                   +;
         " AND v.codigo_emp  = e.codigo_emp"                   +;
         " AND v.codigo      = e.codigo"                       +;
         " AND v.codigo_emp  = " + LTRIM(STR(oApl:oEmp:PRINCIPAL))+;
         " AND v.fecha_has  >= '" + NtChr( ::aLS[2],"2" )      +;
        "' AND v.fecha_has  <= '" + NtChr( ::aLS[3],"2" )      +;
       "' GROUP BY e.codigo, n.nit, n.nombre, v.clase_pd, v.concepto"+;
        " ORDER BY n.nit, v.clase_pd, v.concepto"
ConectaOn()
oCursor := tTable():New( cCel,oApl:oODbc )
AFILL( aEpl,0 )
  cFile := cFilePath( GetModuleFileName( GetInstance() )) + "Nomina.xls"
  nP    := 6
   oRpt := TExcelScript():New()
   oRpt:Create( cFile )
   oRpt:Font("Verdana")
   oRpt:Size(10)
// Say( nRow, nCol, xValue, cFont, nSize, lBold, lItalic, ;
//     lUnderLine, nAlign, nColor, nFondo , nOrien , nStyle , cFormat )  CLASS TExcelScript
// nAlign -> 1  // Derecha
// nAlign -> 4  // Izquierda
// nAlign -> 7  // Centrado
   oRpt:Visualizar(.F.)
   oRpt:Say(  1 , 2 , oApl:cEmpresa, , 14 ,,,,,,,, 0  )
   oRpt:Say(  2 , 2 , "NIT: " + oApl:oEmp:Nit, ,12 ,,,, 7,,,, 0 )
   oRpt:Say(  3 , 2 , "NOMINA Desde " + NtChr(::aLS[2],"2") +;
                            " Hasta " + NtChr(::aLS[3],"2"), ,12 ,,,,,,,, 0 )
   oRpt:Say(  4 , 1 , "Cedula",,,,,, 7,,,, 0 )
   oRpt:Say(  4 , 2 , "Nombre",,,,,, 7,,,, 0 )
   oRpt:Say(  4 , 3 , "D.Incap",,,,,, 4,,,, 0 )
   oRpt:Say(  4 , 4 , "Dias",,,,,, 4,,,, 0 )
   oRpt:Say(  4 , 5 , "Sueldo",,,,,, 4,,,, 0 )
   oRpt:Say(  5 , 5 , "Basico",,,,,, 4,,,, 0 )
   oRpt:Say(  5 , 6 , "Comisiones",,,,,, 4,,,, 0 )
   oRpt:Say(  5 , 7 , "Horas Extras",,,,,, 4,,,, 0 )
   oRpt:Say(  5 , 8 , "Incapacidad",,,,,, 4,,,, 0 )
   oRpt:Say(  4 , 9 , "Auxilio",,,,,, 4,,,, 0 )
   oRpt:Say(  5 , 9 , "Transporte",,,,,, 4,,,, 0 )
   oRpt:Say(  4 ,10 , "Otros",,,,,, 4,,,, 0 )
   oRpt:Say(  5 ,10 , "Pagos",,,,,, 4,,,, 0 )
   oRpt:Say(  4 ,11 , "Total",,,,,, 4,,,, 0 )
   oRpt:Say(  5 ,11 , "Devengado",,,,,, 4,,,, 0 )
   oRpt:Say(  4 ,12 , "Salud",,,,,, 4,,,, 0 )
   oRpt:Say(  4 ,13 , "Pension",,,,,, 4,,,, 0 )
   oRpt:Say(  4 ,14 , "F.S.P.",,,,,, 4,,,, 0 )
   oRpt:Say(  4 ,15 , "Prestamo",,,,,, 4,,,, 0 )
   oRpt:Say(  4 ,16 , "Otros",,,,,, 4,,,, 0 )
   oRpt:Say(  5 ,16 , "Descuentos",,,,,, 4,,,, 0 )
   oRpt:Say(  4 ,17 , "Total",,,,,, 4,,,, 0 )
   oRpt:Say(  5 ,17 , "Deduccion",,,,,, 4,,,, 0 )
   oRpt:Say(  4 ,18 , "Neto a",,,,,, 4,,,, 0 )
   oRpt:Say(  5 ,18 , "Pagar",,,,,, 4,,,, 0 )
WHILE !oCursor:Eof()
   aCT[1] := oCursor:FieldGet(1)
   aCT[2] := oCursor:FieldGet(2)
   aCT[3] := oCursor:FieldGet(3)
 //aCT[4] := oCursor:FieldGet(4)
   aCT[5] := oCursor:FieldGet(4)
   aCT[6] := oCursor:FieldGet(5)
   aCT[7] := oCursor:FieldGet(6)
   aCT[8] := oCursor:FieldGet(7)
   If aEpl[01] == 0
      aEpl[01] := aCT[2]
      aEpl[02] := aCT[3]
      aEpl[19] := aCT[1]
   EndIf
    //clase_pd
   If aCT[5] == 1
       //concepto
      If Rango( aCT[6],{ 1,2,10,13 } )
         If aCT[6] <= 2
            aEpl[4] += (aCT[7] / 8)
         //Else
         //   aEpl[4] +=  aCT[7]
         EndIf
            aEpl[05] +=  aCT[8]
      ElseIf aCT[6] ==  9 .OR. aCT[6] == 69
            aEpl[03] +=  aCT[7]
            aEpl[08] +=  aCT[8]
      ElseIf aCT[6] == 12
            aEpl[09] +=  aCT[8]
      ElseIf aCT[6] == 34
            aEpl[06] +=  aCT[8]
      ElseIf Rango( aCT[6],{ 3,4,5,6,7,8,11,37,40,56 } )
            aEpl[07] +=  aCT[8]
      Else
            aEpl[10] +=  aCT[8]
      EndIf
   Else
      If Rango( aCT[6],{ 32,47,50 } )
            aEpl[12] +=  aCT[8]
      ElseIf aCT[6] == 48 .OR. aCT[6] == 51
            aEpl[13] +=  aCT[8]
      ElseIf aCT[6] == 49 .OR. aCT[6] == 52
            aEpl[14] +=  aCT[8]
      ElseIf aCT[6] == 26
            aEpl[15] +=  aCT[8]
      Else
            aEpl[16] +=  aCT[8]
      EndIf
   EndIf
   oCursor:Skip(1)
   If oCursor:Eof() .OR. aEpl[19]  # oCursor:FieldGet(1)
      aEpl[11] := aEpl[05] + aEpl[06] + aEpl[07] + aEpl[08] + aEpl[09] + aEpl[10]
      aEpl[17] := aEpl[12] + aEpl[13] + aEpl[14] + aEpl[15] + aEpl[16]
      aEpl[18] := aEpl[11] - aEpl[17]
      FOR nK := 1 TO 18
         oRpt:Say( nP , nK , aEpl[nK],,,,,,,,,, 0 )
      NEXT nK
      AFILL( aEpl,0 )
      nP ++
   EndIf
EndDo
oCursor:End()
ConectaOff()
 cCel := LTRIM( STR(nP-1) ) + ")"
 oRpt:Say( nP+1, 2 , "Totales  ====>",,,,,,,,,, 0 )
 oRpt:Say( nP+1, 5 , "=SUMA(E5:E" + cCel,,,,,,,,,, 0 )
 oRpt:Say( nP+1, 6 , "=SUMA(F5:F" + cCel,,,,,,,,,, 0 )
 oRpt:Say( nP+1, 7 , "=SUMA(G5:G" + cCel,,,,,,,,,, 0 )
 oRpt:Say( nP+1, 8 , "=SUMA(H5:H" + cCel,,,,,,,,,, 0 )
 oRpt:Say( nP+1, 9 , "=SUMA(I5:I" + cCel,,,,,,,,,, 0 )
 oRpt:Say( nP+1,10 , "=SUMA(J5:J" + cCel,,,,,,,,,, 0 )
 oRpt:Say( nP+1,11 , "=SUMA(K5:K" + cCel,,,,,,,,,, 0 )
 oRpt:Say( nP+1,12 , "=SUMA(L5:L" + cCel,,,,,,,,,, 0 )
 oRpt:Say( nP+1,13 , "=SUMA(M5:M" + cCel,,,,,,,,,, 0 )
 oRpt:Say( nP+1,14 , "=SUMA(N5:N" + cCel,,,,,,,,,, 0 )
 oRpt:Say( nP+1,15 , "=SUMA(O5:O" + cCel,,,,,,,,,, 0 )
 oRpt:Say( nP+1,16 , "=SUMA(P5:P" + cCel,,,,,,,,,, 0 )
 oRpt:Say( nP+1,17 , "=SUMA(Q5:Q" + cCel,,,,,,,,,, 0 )
 oRpt:Say( nP+1,18 , "=SUMA(R5:R" + cCel,,,,,,,,,, 0 )
 oRpt:Borders("A1:R" + LTRIM(STR(nP+1)) ,,, 3 )
 oRpt:ColumnWidth( 2 , 40 )
 oRpt:Visualizar(.T.)
 oRpt:End(.F.) ; oRpt := NIL
RETURN NIL

//------------------------------------//
METHOD ArmarInf( oDlg ) CLASS TCompara
   LOCAL oRpt, aCT := ARRAY(11), hRes, nK, nP
   LOCAL aSRV, oCursor, cDiam := ::aLS[4]
   LOCAL cCel, cTipo, cTipoE, cTer, cCara, cColor, nEsf, nCil, nAdd, nDiam
aCT[1] := oApl:Abrir( "cadtalla","numfac, orden",,.t. )
aSRV := Buscar( "SELECT nomcorto, tipo_trab, valunidad FROM cadtlist WHERE "+;
                "clase_mate IN('S','U') ORDER BY clase_mate, tipo_mater","CM",,9 )
cCel := "SELECT ordenes_c.NUMERO_ORDEN, FECHA_DOCUMENTO, ordenes_r.FACTURA, "+;
        "TIPO_SERVICIO, TIPO_TRABAJO, ordenes_c.CONSECUTIVO, CANTIDAD, ANTICIPO "+;
        "FROM ordenes_c, ordenes_r, ordenes_o "                  +;
        "WHERE FECHA_DOCUMENTO >= '" + NtChr( ::aLS[2],"2" )     +;
        "' AND FECHA_DOCUMENTO <= '" + NtChr( ::aLS[3],"2" )     +;
        "' AND ordenes_c.CODIGO_CLIENTE = '" + cDiam             +;
        "' AND ordenes_c.NUMERO_ORDEN   = ordenes_r.NUMERO_ORDEN"+;
         " AND ordenes_o.ANO_MES        = ordenes_r.ANO_MES"     +;
         " AND ordenes_o.CONSECUTIVO    = ordenes_r.CONSECUTIVO" +;
         " AND ordenes_o.VALOR_UNIDAD   > 0"                     +;
         " AND TIPO_TRABAJO NOT IN ('FE','OT')"
::NEW( @cCel )
ConectaOn()
::aLS[4] := "Ejecutando Servicios" ; oDlg:Update()
 aCT[11] := 0
nK := SECONDS()
oCursor := tTable():New( cCel,oApl:oODbc )
//oCursor := TDbOdbc():New( cCel,oApl:oODbc )
oApl:oWnd:SetMsg("Servicios en "+STR(SECONDS() - nK)+" Segundos en Registros "+;
                 STR(oCursor:RecCount()) )
WHILE !oCursor:Eof()
   aCT[2] := oCursor:FieldGet(1)
   aCT[3] := NtChr( oCursor:FieldGet(2),"2" )
   aCT[4] := If( oCursor:FieldGet(3) == 0, oCursor:FieldGet(8),;
                 oCursor:FieldGet(3) )
   aCT[5] := oCursor:FieldGet(4) + oCursor:FieldGet(5)
   aCT[6] := oCursor:FieldGet(6)
   aCT[7] := oCursor:FieldGet(7)
   aCT[8] := aCT[9] := 0
   If LEFT( aCT[5],2 ) $ "BMCORCRPTR"
      If LEFT( aCT[5],2 ) == "CO"
         aCT[5] := STRTRAN( aCT[5],"G","E" )
         aCT[5] := STRTRAN( aCT[5],"D","M" )
      ElseIf LEFT( aCT[5],4 ) == "RCTC"
         aCT[5] := "RCTB   "
      ElseIf LEFT( aCT[5],4 ) == "TRAR"
         aCT[5] := "TRAR1  "
      ElseIf LEFT( aCT[5],4 ) == "TRMR"
         aCT[5] := "TRMR   "
      ElseIf LEFT( aCT[5],4 ) == "TRPR"
         aCT[5] := "TRPR   "
      EndIf
      If (nK := ASCAN( aSRV, {|aVal| aVal[2] == aCT[5]} )) > 0
         ::aLS[4] := aCT[5] ; oDlg:Update()
         aCT[9] := aCT[7] * aSRV[nK,3]
      EndIf
      aCT[7] := 0
      If aCT[5] == "TRPR   "
         If aCT[1]:Seek( {"numfac",aCT[4],"orden",aCT[2]} )
            aCT[9] := If( "6" $ aCT[1]:CLASE, 0, aCT[9] )
         EndIf
      ElseIf aCT[5] == "BMP   "
         oApl:oVen:dbEval( {|| aCT[9] := 0 },{"optica",oApl:nEmpresa,"numfac",aCT[4],;
                           "tipo",oApl:Tipo,"indicador <> ","A",;
                           "LEFT(codart,2)","01" } )
      EndIf
      aCT[5] := 0
      ::Facturas( aCT,"Tem" )
   EndIf
   oCursor:Skip(1)
EndDo
oCursor:End()
cCel := "SELECT ordenes_c.NUMERO_ORDEN, FECHA_DOCUMENTO, ordenes_r.FACTURA, "+;
        "nvl(ordenes_d.CLASE_MAT_FAC,ordenes_c.CLASE_MATERIAL), "            +;
        "nvl(ordenes_d.TIPO_MAT_FAC, ordenes_c.TIPO_MATERIAL), "             +;
        "to_char(ESFERA,'999D99'), to_char(CILINDRO,'999D99'), "             +;
        "TERMINADO, nvl(DIAMETRO,DIAM_PEDIDO), ordenes_c.CONSECUTIVO, "      +;
        "CANTIDAD, nvl(ordenes_d.TIPO_LISTA,ordenes_c.TIPO_LISTA), ANTICIPO "+;
        "FROM ordenes_c, ordenes_d, ordenes_r "                  +;
        "WHERE FECHA_DOCUMENTO >= '" + NtChr( ::aLS[2],"2" )     +;
        "' AND FECHA_DOCUMENTO <= '" + NtChr( ::aLS[3],"2" )     +;
        "' AND ordenes_c.CODIGO_CLIENTE = '" + cDiam             +;
        "' AND ordenes_c.CLASE_MATERIAL != 'C'"                  +;
         " AND ordenes_d.ANO_MES        = ordenes_c.ANO_MES"     +;
         " AND ordenes_d.CONSECUTIVO    = ordenes_c.CONSECUTIVO" +;
         " AND ordenes_r.NUMERO_ORDEN   = ordenes_c.NUMERO_ORDEN"+;
         " ORDER BY ordenes_c.CONSECUTIVO"
::NEW( @cCel )
ConectaOn()
::aLS[4] := "Ejecutando Lentes" ; oDlg:Update()
nK := SECONDS()
oCursor := tTable():New( cCel,oApl:oODbc )
oApl:oWnd:SetMsg("Lentes en "+STR(SECONDS() - nK)+" Segundos en Registros "+;
                 STR(oCursor:RecCount()) )
WHILE !oCursor:Eof()
   aCT[2] := oCursor:FieldGet(1)
   aCT[3] := NtChr( oCursor:FieldGet(2),"2" )
   aCT[4] := If( oCursor:FieldGet(3) == 0, oCursor:FieldGet(13),;
                 oCursor:FieldGet(3) )
   aCT[5] :=      oCursor:FieldGet(4)  //Clase Material
   cTipo  := TRIM(oCursor:FieldGet(5)) //Tipo  Material
   nEsf   := VAL( oCursor:FieldGet(6) )
   nCil   := VAL( oCursor:FieldGet(7) )
   cTer   := oCursor:FieldGet(8)
   nDiam  := oCursor:FieldGet(9)
   aCT[6] := oCursor:FieldGet(10)    //Consecutivo
   aCT[7] := oCursor:FieldGet(11)    //Cantidad
   cCara  := cCel := TRIM(oCursor:FieldGet(12))
   If cTer  # "T"
      If cCara == "TR" .OR. cCara == "AR" .OR.;
        (cCara == "N" .AND. aCT[5] == "4")
         cCara := "M"
      EndIf
   EndIf
   If cTer $ "K T" .AND. LEFT( cTipo,1 ) == "6" .AND. cCara # "BUI"
      cTer  := If( cTer == "K" .AND. cTipo == "6", "C",;
               If( cTer == " ", " ", "T" ) )
      cTipo := "11"
   EndIf
   If cTer == "C" .AND. aCT[5] == "1" .OR.;
     (cTer == "F" .AND. cTipo $ "21 24")
      cTer := "T" ; nDiam := 70
   EndIf
   If aCT[5] == "F"
      aCT[5] := "6"
      cCara  := "AR"
   EndIf
   ::aLS[4] := aCT[2] ; oDlg:Update()
   cColor := "SELECT nombre, tipo_lista, diametro, maxidiam FROM cadtlist "+;
             "WHERE clase_mate = "+ xValToChar( aCT[5] )+;
              " AND tipo_mater = "+ xValToChar( cTipo ) + If( cTipo == "11",;
              " AND tipo_lista = "+ xValToChar( cCara ), "" )
/*
   If Rango( aCT[2],{10073337,10075439} )
      MsgInfo( cColor,"cCel="+cCel+" cCara="+cCara+" cTer="+cTer+STR(aCT[2]) )
   EndIf
*/
   aCT[10]:= Buscar( cColor,"CM",,8 )
   If LEN( aCT[10] ) == 0
      aCT[10] := { "NO EXISTE",cCara,nDiam,nDiam }
   EndIf
   ::aLS[4] := aCT[10,1] ; oDlg:Update()
   If aCT[5] == "0" .AND. cTipo == "24" .AND. nDiam == 71
      nDiam := 68
   Else
      nDiam := If( nDiam < aCT[10,3], aCT[10,3], ;
               If( nDiam > aCT[10,4], aCT[10,4], nDiam ) )
   EndIf
   cCara := aCT[10,2]
   nEsf  := ABS( nEsf )
   If aCT[5] $ "012" .AND. cTipo == "11"     .AND. ;
      nEsf   <= 4.00 .AND. ABS(nCil) <= 2.00 .AND. ;
      cTer $ "KW"
      cTer := "T"
   EndIf
   If cTer $ "FSKW" .OR.;
     (cTer == "T" .AND. !(cTipo $ "11 21"))
      cTer := " "
   EndIf
   If cTer == "T"
      cColor := "SELECT tipolista, diametro FROM cadtmate "+;
                "WHERE clasemat  = "+ xValToChar( aCT[5] ) +;
                 " AND tipomat   = "+ xValToChar( cTipo )  +;
                 " AND terminado = 'T'" + If( cCara # "M"  ,;
                 " AND tipolista = "+ xValToChar( cCara ), "" )
      aCT[10]:= Buscar( cColor,"CM",,8 )
      If LEN( aCT[10] ) > 0
         cCara := aCT[10,1]
         nDiam := aCT[10,2]
      EndIf
   EndIf
   cColor := cTipoE := "  "
   cDiam  := If( nDiam < 70, "1", If( nDiam >= 75, "3", "2" ) )
 //If cTipo  == "11" .AND. nEsf = 0 .AND. nCil # 0 .AND. cTer = "T"
 //   cTipoE := "PC"
 //EndIf
 //         " AND m.tipoesfe  = " + xValToChar( cTipoE)+;
   cTer := "SELECT m.valventa, e.valventa "            +;
           "FROM cadtmate m, cadtesfe e "              +;
           "WHERE m.terminado = " + xValToChar( cTer ) +;
            " AND m.clasemat  = " + xValToChar( aCT[5])+;
            " AND m.tipomat   = " + xValToChar( cTipo )+;
            " AND m.tipolista = " + xValToChar( cCara )+;
            " AND m.colorv    = " + xValToChar( cColor)+;
            " AND m.diametro  = " + xValToChar( nDiam )+;
            " AND e.consec = m.consec AND e.terminado = m.terminado" +;
            " AND e.esfera_de<=" + xValtoChar( nEsf )  +;
            " AND e.esfera_a >=" + xValtoChar( nEsf )  +;
            " AND e.codigo_dia LIKE '%" + cDiam + "%'"
   aCT[5] := aCT[8] := aCT[9] := 0
   aCT[10]:= Buscar( cTer,"CM",,8 )
   If !EMPTY( aCT[10] )
      aCT[8] := (aCT[10,1] + aCT[10,2]) * aCT[7]
   //ElseIf aCT[2] == 1907940
      //MsgInfo( cTer,"NO EXISTE" )
   EndIf
   ::Facturas( aCT,"Tem" )
   oCursor:Skip(1)
EndDo
oCursor:End()
ConectaOff()
cTer := "SELECT c.orden, c.fechoy, c.numfac, d.codart, d.descri, "    +;
         "d.cantidad, d.precioven, d.desmon, d.ppubli, c.factexce, 0 "+;
        "FROM cadventa d, cadfactu c "                 +;
        "WHERE d.codart IN('0201', '0202', '0203', '0503', '0505', '0599000002')"+;
         " AND c.optica = d.optica"                    +;
         " AND c.numfac = d.numfac"                    +;
         " AND c.tipo   = d.tipo"                      +;
         " AND c.optica = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fechoy >= " + xValToChar( ::aLS[2] )  +;
         " AND c.fechoy <= " + xValToChar( ::aLS[3] )  +;
         " AND c.indicador <> 'A'"                     +;
         " AND c.remplaza = 0"                         +;
        " UNION ALL " +;
        "SELECT c.orden, c.fecha, c.numero, d.codart, d.descri, "     +;
         "d.cantidad, d.precioven, d.desmon, d.ppubli, c.factexce, 1 "+;
        "FROM cadantid d, cadantic c "                 +;
        "WHERE d.codart IN('0201', '0202', '0203', '0503', '0505', '0599000002')"+;
         " AND c.optica = d.optica"                    +;
         " AND c.numero = d.numero"                    +;
         " AND c.optica = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fecha >= " + xValToChar( ::aLS[2] )   +;
         " AND c.fecha <= " + xValToChar( ::aLS[3] )   +;
         " AND c.indicador <> 'A'"
hRes := If( MSQuery( oApl:oMySql:hConnect,cTer ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nAdd := MSNumRows( hRes )
While nAdd > 0
   cDiam := MyReadRow( hRes )
   AEVAL( cDiam, { | xV,nP | cDiam[nP] := MyClReadCol( hRes,nP ) } )
   cCara  := ALLTRIM( cDiam[4] )
   If cCara == "0599000002" .AND. cDiam[10] == 0
      nAdd --
      LOOP
   EndIf
   aCT[2] := cDiam[1]              //Orden
   aCT[3] := cDiam[2]              //Fechoy
   aCT[4] := cDiam[3]              //Numfac
   aCT[5] := cDiam[7]              //Precioven
   aCT[6] := cDiam[8]              //Desmon
   aCT[7] := aCT[8] := aCT[9] := aCT[11]:= 0
   If cCara == "0203"
      cCel := ALLTRIM( cDiam[5] )  //Descri
      ::aLS[4] := cCel + STR(cDiam[3]) ; oDlg:Update()
      While !EMPTY( cCel )
         cTer := Saca( @cCel,"," )
         nP   := 1
         If ISDIGIT( cTer )
            nK   := If( ISDIGIT( SUBSTR(cTer,2,1) ), 2, 1 )
            nP   := VAL( LEFT(cTer,nK) )
            cTer := STUFF( cTer,nK,nK,"" )
         EndIf
         cTer := PADR( cTer,5," " )
         If (nK := ASCAN( aSRV, {|aVal| aVal[1] == cTer} )) > 0
            aCT[9] += (aSRV[nK,3] * nP)
         EndIf
      EndDo
   //ElseIf cCara == "0503" .OR. cCara == "0505"
   // aCT[9] := cDiam[9] / cDiam[6]
   Else
      aCT[7] := cDiam[6]
      aCT[8] := cDiam[9] * aCT[7]  //Ppubli
   EndIf
  /*f aCT[4] == 24149 .OR. aCT[4] == 24229
      MsgInfo( aCT[4],"PASE" )
   EndIf*/
   If cDiam[10] > 0
      cCel := "UPDATE cadtalla SET precioven = precioven + " + LTRIM(STR(aCT[5]))+;
                                ", excedente = " + LTRIM(STR(aCT[4]))            +;
                   If( aCT[2] > 0, ", numfac = " + LTRIM(STR(cDiam[10])), "" )   +;
             " WHERE numfac = " + LTRIM(STR(cDiam[10])) +;
                " OR numfac = " + LTRIM(STR(aCT[4]))    + If( aCT[2] > 0,;
               " AND orden  = " + LTRIM(STR(aCT[2])), "" )
      If MSQuery( oApl:oMySql:hConnect,cCel )
         oRpt := MSStoreResult( oApl:oMySql:hConnect )
         If MSAffectedRows( oApl:oMySql:hConnect ) == 0
            aCT[7] := aCT[8] := 0
            aCT[11]:= aCT[4]
            aCT[04]:= cDiam[10]
            ::Facturas( aCT,"Ven" )
         EndIf
         MSFreeResult( oRpt )
      EndIf
   Else
      ::Facturas( aCT,"Ven" )
   EndIf
   nAdd --
EndDo
MSFreeResult( hRes )
/*
SELECT DISTINCTROW cadtalla.* FROM cadtalla
WHERE cadtalla.orden IN (SELECT orden FROM cadtalla AS Tmp
                         GROUP BY orden HAVING Count(*)>1)
ORDER BY orden, numfac
*/
cCel := "SELECT valor, servloc FROM cadtalla "+;
        "WHERE orden  = [ORD]"                +;
         " AND consec > 0"
oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"COMPARACION PRECIOS ORDENES DE TALLA",;
          "DESDE " + NtChr(::aLS[2],"2") + " HASTA " + NtChr(::aLS[3],"2" ),;
          "FACTURA NRO.ORDEN CONSE FEC.OPTICA FEC.LABORA.  VAL. VENTA  VAL"+;
          ". LISTA  VAL. TALLA"},::aLS[9] )
::aLS[9] := .t. //Rango( oApl:nEmpresa,{4,18,44} )
aCT[1]:Seek( { "numfac >=",0 },"numfac, orden" )
While !aCT[1]:EOF()
   aCT[8] := aCT[1]:PRECIOVEN + aCT[1]:DESMON
   aCT[7] := aCT[1]:VALOR     + aCT[1]:SERVLOC
   aCT[5] := aCT[1]:SERVIC    * aCT[1]:CANTIDAD
   aCT[6] := aCT[1]:SERVLOC
   If aCT[1]:ORDEN > 0 .AND. aCT[1]:CONSEC == 0
      aCT[10]:= Buscar( STRTRAN( cCel,"[ORD]",LTRIM(STR(aCT[1]:ORDEN)) ),"CM",,8 )
      If LEN( aCT[10] ) > 0
         aCT[7] := aCT[10,1] + aCT[10,2]
         aCT[6] := aCT[10,2]
      EndIf
   EndIf
   If ::aLS[9]
      aCT[9] := aCT[1]:SERVIC * aCT[1]:CANTIDAD + aCT[1]:PPUBLI
   Else
      aCT[9] := aCT[8]
   EndIf
   oRpt:Titulo( 83 )
   If aCT[8] # aCT[9] .OR. aCT[7] # aCT[9]
      oRpt:Say( oRpt:nL,00,STR(aCT[1]:NUMFAC,7) + STR(aCT[1]:ORDEN,10) +;
                           STR(aCT[1]:CONSEC,6) )
      oRpt:Say( oRpt:nL,24,aCT[1]:FECFAC )
      oRpt:Say( oRpt:nL,35,aCT[1]:FECDOC )
      oRpt:Say( oRpt:nL,48,TRANSFORM(aCT[8],"99,999,999") )
      oRpt:Say( oRpt:nL,60,TRANSFORM(aCT[9],"99,999,999") )
      oRpt:Say( oRpt:nL,70,If( aCT[8] == aCT[9], "", If( aCT[8] < aCT[9], "-", "+" ) ))
      oRpt:Say( oRpt:nL,72,TRANSFORM(aCT[7],"99,999,999") )
      oRpt:Say( oRpt:nL,82,If( aCT[7] == aCT[9], "", If( aCT[7] < aCT[9], "-", "+" ) ))
      oRpt:nL++
      If aCT[5] # aCT[6] .AND. aCT[7] > 0  .AND. aCT[9] > 0
         If aCT[1]:EXCEDENTE > 0
            oRpt:Say( oRpt:nL,12,"Excedente" + STR(aCT[1]:EXCEDENTE) )
         Else
            nEsf := Buscar( "SELECT numfac FROM cadtalla WHERE consec = 0"+;
                            " AND orden = " + LTRIM(STR(aCT[1]:ORDEN)),"CM",,8,,4 )
            If nEsf > 0
               oRpt:Say( oRpt:nL,12,"NC. Nueva F." + LTRIM(STR(nEsf)) )
            EndIf
         EndIf
         oRpt:Say( oRpt:nL,35,"SERVICIOS(" + STR(aCT[1]:CANTIDAD,5) + ")" )
         oRpt:Say( oRpt:nL,60,TRANSFORM(aCT[5],"99,999,999") )
         oRpt:Say( oRpt:nL,72,TRANSFORM(aCT[6],"99,999,999") )
         oRpt:Say( oRpt:nL,82,If( aCT[6] < aCT[5], "-", "+" ) )
         oRpt:nL++
      EndIf
   EndIf
   aCT[1]:Skip(1):Read()
   aCT[1]:xLoad()
EndDo
oRpt:NewPage()
oRpt:End()
//::NEW( aCT )
RETURN NIL

//------------------------------------//
METHOD Traslado( oGet ) CLASS TCompara
   LOCAL aCT := ARRAY(10), aFac, cLOC := ::aLS[4]
   LOCAL oPC, cCel, cFac, cQry, hRes, nP
//aCT[1] := oApl:Abrir( "cadtalla","orden",,.t. )
aCT[6] := ::aLS[2]
aCT[7] := ::aLS[3]
 ::aLS[10] := .f.
cCel := "SELECT CONSECUTIVO FROM movto_c "           +;
        "WHERE CODIGO_EMP  = " + LTRIM(STR(oApl:oEmp:PRINCIPAL))+;
         " AND ANO_MES     = " + NtChr( aCT[7],"1" ) +;
         " AND COMPROBANTE = [ORD]"                  +;
         " AND TIPO        = '9'"                    +;
         " AND FECHA       = [FEC]"
cQry := "SELECT numfac, orden, fechoy, 'F' FROM cadfactu "+;
        "WHERE optica  = " +LTRIM(STR(oApl:nEmpresa))+;
         " AND fechoy >= " + xValToChar( aCT[6] )    +;
         " AND fechoy <= " + xValToChar( aCT[7] )    +;
         " AND indicador <> 'A'"                     +;
         " AND orden > 0"                            +;
        " UNION ALL "                                +;
        "SELECT numero, orden, fecha, 'A' FROM cadantic " +;
        "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND fecha >= " + xValToChar( aCT[6] )     +;
         " AND fecha <= " + xValToChar( aCT[7] )     +;
         " AND indicador <> 'A'"                     +;
         " AND orden > 0"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nP   := MSNumRows( hRes )
While nP > 0
   aFac := MyReadRow( hRes )
   AEVAL( aFac, { | xV,nP | aFac[nP] := MyClReadCol( hRes,nP ) } )
   cQry := STRTRAN( cCel,"[ORD]",LTRIM(STR(aFac[2])) )
   cQry := STRTRAN( cQry,"[FEC]",::INF(aFac[3]) )
   ConectaOn()
   oPC := TDbOdbc()
   oPC:New( cQry,oApl:oODbc )
   oPC:End()
   If oPC:lEof
      //MsgInfo( "ORDEN="+STR(aFac[2]),"FACTURA="+aFac[4]+STR(aFac[1]) )
      oGet[7]:SetText( aCT[3] )
      ::aLS[02] := ::aLS[03] := aFac[3]
      ::aLS[11] := aFac[1]
      ::Ventas( oGet,5 )     //Actualizar en Contabilidad Costos de L.Oftalmicos
   EndIf
   nP --
EndDo
MSFreeResult( hRes )
 ConectaOff()
/*
While nP > 0
   aFac := MyReadRow( hRes )
   AEVAL( aFac, { | xV,nP | aFac[nP] := MyClReadCol( hRes,nP ) } )
   aCT[1]:xBlank()
   aCT[1]:NUMFAC := aFac[1] ; aCT[1]:ORDEN := aFac[2]
   aCT[1]:FECFAC := aFac[3] ; aCT[1]:CLASE := aFac[4]
   aCT[1]:Append(.f.)
   nP --
EndDo
MSFreeResult( hRes )
cCel := "SELECT r.FACTURA, c.NUMERO_ORDEN, c.VALOR_TOTAL "  +;
        "FROM ordenes_c c, ordenes_r r "                    +;
        "WHERE c.FECHA_DOCUMENTO >= '" + NtChr( aCT[6],"2" )+;
        "' AND c.FECHA_DOCUMENTO <= '" + NtChr( aCT[7],"2" )+;
        "' AND c.CODIGO_CLIENTE   = '" + cLOC               +;
        "' AND c.CLASE_MATERIAL  != 'C'"                    +;
         " AND c.ESTADO          != 'R'"                    +;
         " AND r.NUMERO_ORDEN     = c.NUMERO_ORDEN"
cFac := "SELECT numfac, fecfac, clase FROM cadtalla "+;
        "WHERE (numfac = [FAC] OR orden = [ORD])"
::NEW( @cCel )
ConectaOn()
oGet[7]:SetText( "Ejecutando Lentes" )
  aCT[9] := 0
nP  := SECONDS()
oPC := tTable():New( cCel,oApl:oODbc )
oApl:oWnd:SetMsg("Lentes en "+STR(SECONDS() - nP)+" Segundos en Registros "+;
                 STR(oPC:RecCount()) )
WHILE !oPC:Eof()
   aCT[2] := oPC:FieldGet(1)     //Factura
   aCT[3] := oPC:FieldGet(2)     //Orden
   aCT[4] := oPC:FieldGet(3)     //Total
   aCT[9] += aCT[4]
   oGet[7]:SetText( aCT[3] )
   cQry := STRTRAN( cFac,"[FAC]",LTRIM(STR(aCT[2])) )
   cQry := STRTRAN( cQry,"[ORD]",LTRIM(STR(aCT[3])) )
   aFac := Buscar( cQry,"CM",,8 )
   If LEN( aFac ) > 0
      ::aLS[9] := .f.
      ::Ajustes( aFac,aCT[4] )
      If ::aLS[09]
         ::aLS[02] := ::aLS[03] := aFac[2]
         ::aLS[11] := aCT[2]
         ::Ventas( oGet,5 )     //Actualizar en Contabilidad Costos de L.Oftalmicos
      EndIf
   EndIf
   oPC:Skip(1)
EndDo
oPC:End()
 cQry := "UPDATE cadnotad d, cadnotac c, cadventa v "   +;
         "SET d.pcosto = v.pcosto "                     +;
         "WHERE c.optica = " + LTRIM(STR(oApl:nEmpresa))+;
          " AND c.fecha >= " + xValToChar( aCT[6] )+;
          " AND c.fecha <= " + xValToChar( aCT[7] )+;
          " AND d.optica = c.optica"               +;
          " AND d.numero = c.numero"               +;
          " AND v.optica = c.optica"               +;
          " AND v.numfac = c.numfac"               +;
          " AND v.codart = d.codigo"
 MSQuery( oApl:oMySql:hConnect,cQry )
ConectaOff()
cFac := "SELECT numero_factura, cant_ordenes_o, valor_oftalmica "+;
        "FROM facturas "                                  +;
        "WHERE FECHA_DOCUMENTO >= '" + NtChr( aCT[6],"2" )+;
        "' AND FECHA_DOCUMENTO <= '" + NtChr( aCT[7],"2" )+;
        "' AND CODIGO_CLIENTE = '"   + cLOC               +;
        "' AND TIPO_DOCUMENTO = 'F'"                      +;
         " AND ESTADO_FACTURA = 0"
 ConectaOn()
 oPC := TDbOdbc()
 oPC:New( cFac,oApl:oODbc )
 oPC:End()
 If !oPC:lEof
    cFac := LTRIM(STR(oPC:FieldGet(1)))
    nP   := Buscar( "SELECT ingreso FROM comprasc "               +;
                    "WHERE optica  = " + LTRIM(STR(oApl:nEmpresa))+;
                     " AND factura = '"+ cFac + "'","CM",,8 )
    If EMPTY( nP )
       cCel := LTRIM(STR(SgteNumero( "numingreso",0,.t. )))
       cQry := "INSERT INTO comprasc (optica, ingreso, codigo_nit, "+;
                      "fecingre, factura, moneda, control) VALUES( "+;
                LTRIM(STR(oApl:nEmpresa)) + ", " + cCel + ", 490, " +;
                  xValToChar( aCT[7] )   + ", '" + cFac + "', 'X', 1)"
       MSQuery( oApl:oMySql:hConnect,cQry )
       cQry := "INSERT INTO cadartid VALUES ( NULL, " + cCel +;
               ", '0201', 1, " +  LTRIM(STR(oPC:FieldGet(3)))+;
               ", NULL, NULL, 0, 1, 'E', NULL, NULL )"
       MSQuery( oApl:oMySql:hConnect,cQry )
       MsgInfo( "INGRESO No."+cCel,oApl:oEmp:LOCALIZ )
    EndIf
 EndIf
 ConectaOff()
::NEW( aCT )
*/
RETURN NIL

//5-----------------------------------//
METHOD Reposicion( oGet ) CLASS TCompara
   LOCAL aGT, aRes, sCli, sQry, hRes, nL
sQry := "SELECT numfac, servic, fecfac, orden, precioven - valor "+;
        "FROM cadtalla "       +;
        "WHERE orden      > 0" +;
         " AND fecfac    <> ''"+;
         " AND precioven  > 0" +;
         " AND valor      > 0" +;
         " AND precioven <> valor OR clase = 'SP' ORDER BY numfac"
hRes := If( MSQuery( oApl:oMySql:hConnect,sQry )  ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) == 0
   MSFreeResult( hRes )
   MsgStop( "No hay AJUSTES que Contabilizar" )
   RETURN .f.
EndIf
sCli := "SELECT cliente FROM cadantic "+;
        "WHERE numero = XX"            +;
         " AND optica = " + LTRIM(STR(oApl:nEmpresa))
 aGT := ::BuscaCta( ::aLS[2],If( oApl:nEmpresa == 21, 18, oApl:nEmpresa ),"18" )
 aGT[1,07] := oApl:oEmp:PRINCIPAL
 aGT[1,10] := oApl:oEmp:SUCURSAL
 aGT[2,02] := aGT[3,2] := "890112740"
::aLS[7] := "AO" ; ::aLS[8] := "18" ; ::aLS[9] := .t.
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   If aRes[2] > 0
      aRes[2] := "A." + LTRIM( STR( aRes[1] ) )
      sQry  := sCli
   Else
      aRes[2] := "F." + LTRIM( STR( aRes[1] ) )
      sQry  := STRTRAN( sCli,"antic" ,"factu" )
      sQry  := STRTRAN( sQry,"numero","numfac" )
   EndIf
   oGet[7]:SetText( aRes[2] )
      sQry  := Buscar( STRTRAN( sQry,"XX",LTRIM(STR(aRes[1])) ),"CM",,8,,1 )
   aGT[1,1] := aRes[3]                           //Fecha
   aGT[1,2] := LTRIM( STR( aRes[4] ) )           //Orden
   aGT[1,6] := If( EMPTY( sQry ), "VARIOS",;
                   ALLTRIM(STRTRAN( sQry,"'"," " )) )
   aGT[2,3] := aGT[3,3] := aGT[4,3] := aGT[5,3] := aRes[2]
   If aRes[5] > 0
      aGT[2,7] := aGT[5,7] := aRes[5]
      aGT[3,8] := aGT[4,8] := aRes[5]
      aGT[2,8] := aGT[5,8] := aGT[3,7] := aGT[4,7] := 0
   Else
      aRes[5]  *= -1
      aGT[2,8] := aGT[5,8] := aRes[5]
      aGT[3,7] := aGT[4,7] := aRes[5]
      aGT[2,7] := aGT[5,7] := aGT[3,8] := aGT[4,8] := 0
   EndIf
   ::BuscaNit( aGT )
   ::aMV[2,4] := aRes[2]
   //MsgInfo( TRANSFORM( ::aMV[2,7],"99,999,999" ) + CRLF +;
   //         TRANSFORM( ::aMV[2,8],"99,999,999" ),aRes[2] )
   ::Contable( oGet )
   nL --
EndDo
MSFreeResult( hRes )
RETURN .f.

//------------------------------------//
METHOD NCredito( oGet ) CLASS TCompara
   LOCAL aCT := ARRAY(18)
   LOCAL aFac, aRes, hRes, nF, nL, oPC, oRpt
aCT[1] := oApl:Abrir( "cadtalla","numfac, orden",,.t. )
aRes := "SELECT c.NUMERO_ORDEN, c.FECHA_DOCUMENTO, r.FACTURA, "+;
               "r.ANTICIPO, c.VALOR_DESCTOS, c.VALOR_TOTAL "   +;
        "FROM ordenes_r r, ordenes_c c "                       +;
        "WHERE c.NUMERO_ORDEN     = r.NUMERO_ORDEN"            +;
         " AND c.FECHA_DOCUMENTO >= '" + NtChr( ::aLS[2],"2" ) +;
        "' AND c.FECHA_DOCUMENTO <= '" + NtChr( ::aLS[3],"2" ) +;
        "' AND c.CODIGO_CLIENTE   = '" +::aLS[4]               +;
        "' AND c.CLASE_MATERIAL  != 'C'"                       +;
         " AND c.ESTADO          != 'R'"
::NEW( @aRes )
ConectaOn()
AFILL( aCT,0,5 )
nL  := SECONDS()
oPC := tTable():New( aRes,oApl:oODbc )
oApl:oWnd:SetMsg("Ordenes en "+STR(SECONDS() - nL)+" Segundos en Registros "+;
                 STR(oPC:RecCount()) )
WHILE !oPC:Eof()
   aCT[2] := oPC:FieldGet(1)
   aCT[3] := NtChr( oPC:FieldGet(2),"2" )
   aCT[4] := oPC:FieldGet(3)
   aCT[5] := oPC:FieldGet(5)
   aCT[8] := oPC:FieldGet(6)
   If aCT[4] == 0
      aCT[4] := oPC:FieldGet(4)
   EndIf
   ::Facturas( aCT,"Tem" )
   oPC:Skip(1)
EndDo
oPC:End()
/*
SELECT c.orden, c.fechoy, c.numfac FAC,
   SUM(d.cantidad * d.pcosto), c.remplaza, 'A', c.factexce
FROM cadventa d, cadfactu c
WHERE LEFT(d.codart,2) IN('02', '05')
  AND d.indicador <> 'A'
  AND c.optica = d.optica
  AND c.numfac = d.numfac
  AND c.tipo   = d.tipo
  AND c.optica = 19
  AND c.fechoy >= '2012-01-01'
  AND c.fechoy <= '2012-01-31'
GROUP BY FAC UNION ALL
SELECT c.orden, c.fecha, c.numero FAC,
   SUM(d.cantidad * d.pcosto), c.numfac, '', c.factexce
FROM cadantid d, cadantic c
WHERE LEFT(d.codart,2) IN('02', '05')
  AND c.optica = d.optica
  AND c.numero = d.numero
  AND c.optica = 19
  AND c.fecha >= '2012-01-01'
  AND c.fecha <= '2012-01-31'
  AND c.indicador <> 'A'
GROUP BY FAC

SELECT numfac, orden, clase, fecfac, fecdoc, precioven, valor, servic, cantloc
FROM cadtalla
WHERE clase = 'A' AND orden = 0
ORDER BY numfac, orden

SELECT t.consec, SUM(t.precioven) FROM cadtalla t
WHERE t.clase  = ''
  AND t.consec IN (SELECT a.numfac FROM cadtalla a
                   WHERE  a.clase = 'A' AND a.orden = 0)
GROUP BY t.consec
ORDER BY t.consec
*/
aRes := "SELECT c.orden, c.fechoy, c.numfac FAC, SUM(d.cantidad * d.pcosto), "+;
               "c.remplaza, 'A', c.factexce, SUM(d.precioven), c.codigo_nit " +;
        "FROM cadventa d, cadfactu c "                 +;
        "WHERE LEFT(d.codart,2) IN('02', '05')"        +;
         " AND d.indicador <> 'A'"                     +;
         " AND c.optica = d.optica"                    +;
         " AND c.numfac = d.numfac"                    +;
         " AND c.tipo   = d.tipo"                      +;
         " AND c.optica = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fechoy >= " + xValToChar( ::aLS[2] )  +;
         " AND c.fechoy <= " + xValToChar( ::aLS[3] )  +;
        " GROUP BY FAC UNION ALL "                     +;
        "SELECT c.orden, c.fecha, c.numero FAC, SUM(d.cantidad * d.pcosto), " +;
               "c.numfac, '', c.factexce, SUM(d.precioven), 0 "               +;
        "FROM cadantid d, cadantic c "                 +;
        "WHERE LEFT(d.codart,2) IN('02', '05')"        +;
         " AND c.optica = d.optica"                    +;
         " AND c.numero = d.numero"                    +;
         " AND c.optica = " + LTRIM(STR(oApl:nEmpresa))+;
         " AND c.fecha >= " + xValToChar( ::aLS[2] )   +;
         " AND c.fecha <= " + xValToChar( ::aLS[3] )   +;
         " AND c.indicador <> 'A'"                     +;
        " GROUP BY FAC"
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
AFILL( aCT,0,5 )
aRes := "SELECT MIN(numfac), MAX(numfac) FROM cadfactu "+;
        "WHERE optica  = "  +LTRIM(STR(oApl:nEmpresa))  +;
         " AND fechoy >= " + xValToChar( ::aLS[2] )     +;
         " AND fechoy <= " + xValToChar( ::aLS[3] )     +;
         " AND tipo <> 'Z'"
aFac := Buscar( aRes,"CM",,8 )
If LEN( aFac ) > 0
   aCT[10] := aFac[1]
   aCT[12] := aFac[2]
EndIf
While nL > 0
   aFac := MyReadRow( hRes )
   AEVAL( aFac, { | xV,nP | aFac[nP] := MyClReadCol( hRes,nP ) } )
   aCT[2] := aFac[1]              //Orden
   aCT[3] := aFac[2]              //Fechoy
   aCT[4] := aFac[3]              //Numfac
   aCT[5] := aFac[4]              //Costo
   aCT[8] := aFac[8]              //Precioven
   If aFac[6] <> "A"
      aCT[9] := If( aCT[8] == 0 .AND. aFac[5] == 0, 1,;
                If( Rango( aFac[5],aCT[10],aCT[12] ), 2, 3 ) )
   EndIf
   If aFac[7] > 0
      aRes := "UPDATE cadtalla SET precioven = precioven + " + LTRIM(STR(aCT[5]))+;
                                ", excedente = " + LTRIM(STR(aCT[4]))            +;
                   If( aCT[2] > 0, ", numfac = " + LTRIM(STR(aFac[7])), "" )     +;
             " WHERE numfac = " + LTRIM(STR(aCT[4]))    +;
                " OR numfac = " + LTRIM(STR(aFac[7]))   + If( aCT[2] > 0,;
               " AND orden  = " + LTRIM(STR(aCT[2])), "" )
      If MSQuery( oApl:oMySql:hConnect,aRes )
         oRpt := MSStoreResult( oApl:oMySql:hConnect )
         nF   := MSAffectedRows( oApl:oMySql:hConnect )
         MSFreeResult( oRpt )
         If nF == 0
            aCT[7] := aCT[8] := 0
            aCT[11]:= aCT[4]
            aCT[04]:= aFac[7]
            ::Facturas( aCT,"Ven" )
         EndIf
      EndIf
   Else
      ::Facturas( aCT,"Ven" )
   EndIf
   If aFac[1] == 0
      If EMPTY( aFac[6] ) .OR.;
        (aFac[6] == "A" .AND. aFac[5] == 0 .AND. aFac[9] # 48)
         aFac[6] := "S"
      EndIf
   EndIf
   If aFac[6] == "S" .OR. aFac[5] > 0 .OR. aFac[9] == 48
      aRes := "UPDATE cadtalla SET consec = " + LTRIM(STR(aFac[5]))+;
                  ", clase = '" + aFac[6]           +;
            "' WHERE numfac = " + LTRIM(STR(aCT[4]))+;
               " AND orden  = " + LTRIM(STR(aCT[2]))
      MSQuery( oApl:oMySql:hConnect,aRes )
   EndIf
   nL --
EndDo
MSFreeResult( hRes )

aRes := "SELECT DISTINCTROW t.orden, t.row_id, t.precioven, t.valor FROM cadtalla t "+;
        "WHERE t.orden IN (SELECT orden FROM cadtalla As Tmp "+;
        "WHERE orden > 0 GROUP BY orden HAVING COUNT(*)>1) ORDER BY t.orden"
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL  := MSNumRows( hRes )) > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aFac := { aRes[1],0,0,0 }
EndIf
While nL > 0
   If aRes[3] > 0
      aFac[2] := aRes[2]
   Else
      aFac[3] := aRes[2]
      aFac[4] := aRes[4]
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aFac[1] # aRes[1]
      Guardar( "UPDATE cadtalla SET valor = valor + " + LTRIM(STR(aFac[4]))+;
              " WHERE row_id = " + LTRIM(STR(aFac[2])),"cadtalla" )
      Guardar( "DELETE FROM cadtalla WHERE row_id = " + LTRIM(STR(aFac[3])),"cadtalla" )
      aFac := { aRes[1],0,0,0 }
   EndIf
EndDo
MSFreeResult( hRes )

aRes := "SELECT orden, row_id FROM cadtalla "+;
        "WHERE fecdoc = '' AND orden > 0 ORDER BY numfac"
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[1] := "SELECT FECHA_DOCUMENTO, VALOR_TOTAL, VALOR_DESCTOS "+;
              "FROM ordenes_c  "         +;
              "WHERE ESTADO      != 'R'" +;
               " AND NUMERO_ORDEN = " + LTRIM(STR(aRes[1]))
   ConectaOn()
   oPC := TDbOdbc()
   oPC:New( aRes[1],oApl:oODbc )
   oPC:End()
   If !oPC:lEof
      aCT[3]  := oPC:FieldGet(1)
      aRes[1] := "UPDATE cadtalla SET fecdoc = '" + NtChr( aCT[3],"2" )    +;
                                "', valor = " + LTRIM(STR(oPC:FieldGet(2)))+;
                                ", desmon = " + LTRIM(STR(oPC:FieldGet(3)))
      If !(aCT[3] >= ::aLS[2] .AND. aCT[3] <= ::aLS[3])
         aRes[1] += ", cantloc = 1"
      EndIf
      Guardar( aRes[1]+" WHERE row_id = " + LTRIM(STR(aRes[2])),"cadtalla" )
   EndIf
   nL --
EndDo
MSFreeResult( hRes )

oRpt := TDosPrint()
oRpt:New( oApl:cPuerto,oApl:cImpres,{"COMPARACION COSTOS ORDENES DE TALLA" ,;
          "DESDE " + NtChr(::aLS[2],"2") + " HASTA " + NtChr(::aLS[3],"2" ),;
          "FACTURA  NRO.ORDEN  FEC.OPTICA  FEC.LABORA.     COSTO LOC.  COSTO OPT."},::aLS[9] )
aRes := "SELECT numfac, orden, clase, fecfac, fecdoc, valor, "+;
               "precioven, ppubli, desmon, servic, cantloc "  +;
        "FROM cadtalla WHERE numfac >= 0 ORDER BY numfac, orden"
oPC  := "SELECT SUM(precioven) FROM cadtalla WHERE consec = [FAC] AND clase = ''"
hRes := If( MSQuery( oApl:oMySql:hConnect,aRes ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL  := MSNumRows( hRes )) > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aFac := {}
   aCT[2] := aRes[1]
EndIf
AFILL( aCT,0,3 )
While nL > 0
   ::aLS[9] := .t.
   If aRes[3] == "A " .AND. aRes[2] == 0
      nF := Buscar( STRTRAN( oPC,"[FAC]",LTRIM(STR(aRes[1])) ),"CM",,8,,4 )
      If aRes[7] == nF
         ::aLS[9]:= .f.
         aCT[09] += aRes[7]
      ElseIf nF # 0 .AND. aRes[7] # nF
         aRes[3] := "*"
         aRes[6] := nF
      EndIf
   EndIf
   If ::aLS[9] .AND. aRes[6] + aRes[7] # 0
      If aRes[3] == "S "
         aRes[5] := " SIN ORDEN"
         aCT[03] += 2
         aCT[11] += aRes[7]
      Else
         aCT[03] += (aRes[7] - aRes[6])
      EndIf
      AADD( aFac,aRes )
      nF := If( aRes[3] == "A " .OR. aRes[3] == "*", 9, 8 )
      aCT[nF] += aRes[7]
      aCT[07] += If( aRes[3] == "*", 0, aRes[6] )
      aCT[10] += aRes[9]
      If aRes[10] >= 1
         nF := INT(aRes[10]) + 11
         aCT[nF] += aRes[7]
      EndIf
      If aRes[11] >= 1
         aCT[15] += aRes[6]
         aCT[17] += aRes[7]
      EndIf
   EndIf
   If (nL --) > 1
      aRes := MyReadRow( hRes )
      AEVAL( aRes, {| xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   EndIf
   If nL == 0 .OR. aCT[2] == 0 .OR. aCT[2] # aRes[1]
      oRpt:Titulo( 83 )
      If aCT[3] # 0
         aCT[6] ++
         FOR nF := 1 TO LEN( aFac )
            aCT[4] := aFac[nF,6] - aFac[nF,7]
            aFac[nF,8] := If( !EMPTY(aFac[nF,4]) .AND. aFac[nF,8] == 0, "SP", "" )
            If aFac[nF,2] > 0
               If aFac[nF,6] > 0 .AND. aFac[nF,7] > 0 .OR. aFac[nF,8] == "SP"
                  If aCT[4] < 0
                     aCT[16] += (aCT[4] * -1)
                  Else
                     aCT[18] +=  aCT[4]
                  EndIf
               EndIf
               If aFac[nF,8] == "SP"
                  Guardar( "UPDATE cadtalla SET clase = 'SP' WHERE numfac = "+;
                           LTRIM(STR(aFac[nF,1])),"cadtalla" )
               EndIf
            EndIf
            oRpt:Say( oRpt:nL,00,STR(aFac[nF,1],7) + STR(aFac[nF,2],10) )
            oRpt:Say( oRpt:nL,18,aFac[nF,3] )
            oRpt:Say( oRpt:nL,20,aFac[nF,4] )
            oRpt:Say( oRpt:nL,32,aFac[nF,5] )
            oRpt:Say( oRpt:nL,45,aFac[nF,8] )
            oRpt:Say( oRpt:nL,48,TRANSFORM(aFac[nF,6],"99,999,999") )
            oRpt:Say( oRpt:nL,60,TRANSFORM(aFac[nF,7],"99,999,999") )
            oRpt:Say( oRpt:nL,71,If( aFac[nF,9] > 0, "D", "" ) )
            oRpt:Say( oRpt:nL,72,TRANSFORM(    aCT[4],"99,999,999") )
            oRpt:nL++
         NEXT nF
      EndIf
      aFac := {}
      aCT[2] := aRes[1]
      aCT[3] := 0
      aCT[5] ++
   EndIf
EndDo
MSFreeResult( hRes )
 aRes := { "ANTICIPOS FACTURADOS","DESCUENTOS LOC"      ,"SIN ORDEN EN OPTICA",;
           "GARANTIAS O REGALOS" ,"FACTURADOS EN EL MES","SIN FACTURAR"       ,;
           "MES DIFERENTE EN LOC","VALOR PARA AJUSTAR" }
 aCT[7] -= aCT[15]
 aCT[8] -= aCT[11]
 aCT[2] := aCT[07] - aCT[8]
 aCT[3] := aCT[15] - aCT[17]
 aCT[4] := aCT[16] - aCT[18] - aCT[2]
 oRpt:Say(  oRpt:nL,00,REPLICATE( "-",83 ),,,1 )
 oRpt:Separator( 1,8 )
 oRpt:Say(  oRpt:nL,20,TRANSFORM(aCT[05],"999,999") )
 oRpt:Say(  oRpt:nL,32,TRANSFORM(aCT[06],"999,999") )
 oRpt:Say(  oRpt:nL,47,TRANSFORM(aCT[07],"999,999,999") )
 oRpt:Say(  oRpt:nL,59,TRANSFORM(aCT[08],"999,999,999") )
 oRpt:Say(  oRpt:nL,71,TRANSFORM(aCT[02],"999,999,999") )
FOR nF := 1 TO 8
   oRpt:Say(++oRpt:nL,23,aRes[nF] )
   oRpt:Say(  oRpt:nL,47,TRANSFORM(aCT[nF+8],"999,999,999") )
NEXT nF
 nF := oRpt:nL -1
 oRpt:Say(  nF     ,59,TRANSFORM(aCT[17],"999,999,999") )
 oRpt:Say(  nF     ,71,TRANSFORM(aCT[03],"999,999,999") )
 oRpt:Say(  oRpt:nL,59,TRANSFORM(aCT[18],"999,999,999") )
 oRpt:Say(  oRpt:nL,71,TRANSFORM(aCT[04],"999,999,999") )
 oRpt:NewPage()
 oRpt:End()
If ::aLS[10] .AND. ::aLS[2] >= CTOD("01.07.2015")
   ::Reposicion( oGet )
EndIf
RETURN NIL

//------------------------------------//
METHOD Ajustes( aMT,nVal ) CLASS TCompara
   LOCAL aRes, cQry, hRes, nE, nL
cQry := "SELECT row_id, cantidad, pcosto FROM cadventa "+;
        "WHERE optica = " + LTRIM(STR(oApl:nEmpresa))   +;
         " AND numfac = " + LTRIM(STR( aMT[1] ))        +;
         " AND codart IN('0201','0202') ORDER BY codart"
//         " AND codart IN('0201','0202','0502','0503',"  +;
//             "'0504','0505','0599000002') ORDER BY codart"
If aMT[3] == "F "
   aMT[3] := "cadventa"
Else
   aMT[3] := "cadantid"
   cQry := STRTRAN( cQry,"cadventa",aMT[3] )
   cQry := STRTRAN( cQry,"numfac","numero" )
EndIf
aRes := Buscar( STRTRAN( cQry,"row_id, cantidad, pcosto",;
                "CAST(SUM(cantidad) AS UNSIGNED INTEGER), SUM(cantidad * pcosto)" ),"CM",,8 )
If LEN( aRes ) == 0 .OR.;
  (aRes[1] > 2 .OR. aRes[2] == nVal)
   RETURN NIL
EndIf
   aMT[3] := "UPDATE " + aMT[3] + " SET pcosto = "
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
If (nL := MSNumRows( hRes )) >= 2
   nVal:= nVal / 2
EndIf
oApl:oWnd:SetMsg( STR(nL,3)+" Registros en Fac."+STR(aMT[1]) )
nE := 0
While nL > 0 .AND. nE <= 2
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
//   If aRes[3] <= 0
      cQry := aMT[3] + LTRIM(STR( nVal/aRes[2] )) +;
              " WHERE row_id = " + LTRIM(STR(aRes[1]))
      MSQuery( oApl:oMySql:hConnect,cQry )
      ::aLS[9] := .t.
//   EndIf
   nE ++
   nL --
EndDo
MSFreeResult( hRes )
/*
If aMT[3] == "cadantid"
   cQry := "UPDATE cadventa v, cadantic c, cadantid d "   +;
             "SET v.pcosto = d.pcosto"                    +;
           "WHERE c.optica = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND c.numero = " + LTRIM(STR( aMT[1] ))     +;
            " AND d.optica = c.optica" +;
            " AND d.numero = c.numero" +;
            " AND d.codart IN('0201', '0202', '0503')"    +;
            " AND v.optica = " +   If( oApl:nEmpresa # 21 ,;
                            "c.optica", "18" )            +;
            " AND v.numfac = c.numfac" +;
            " AND v.codart = d.codart" +;
            " AND v.descri = d.descri"
   MSQuery( oApl:oMySql:hConnect,cQry )

   cQry := "UPDATE cadnotad v, cadantic c, cadantid d "   +;
             "SET v.pcosto = d.pcosto"                    +;
           "WHERE c.optica = " + LTRIM(STR(oApl:nEmpresa))+;
            " AND c.numero = " + LTRIM(STR( aMT[1] ))     +;
            " AND d.optica = c.optica"                +;
            " AND d.numero = c.numero"                +;
            " AND v.optica = c.optica"                +;
            " AND v.numfac = c.numero"                +;
            " AND v.codigo = d.codart"
EndIf
*/
RETURN NIL

//------------------------------------//
METHOD Facturas( aCT,cOpt ) CLASS TCompara
   //LOCAL cCla := If( LEN( aCT[5] ) == 1, aCT[5], "" )
If cOpt == "Ven"
   If aCT[1]:Seek( {"orden",aCT[2]} )
      If aCT[1]:NUMFAC == 0
         aCT[1]:NUMFAC := aCT[4] ; aCT[1]:Update(.f.,1)
      //Else
      //   aCT[4] := aCT[1]:NUMFAC
      EndIf
   EndIf
EndIf
If !aCT[1]:Seek( {"numfac",aCT[4],"orden",aCT[2]} )
   aCT[1]:NUMFAC    := aCT[4] ; aCT[1]:ORDEN := aCT[2]
   aCT[1]:EXCEDENTE := aCT[11]; aCT[1]:Append(.t.)
EndIf
If cOpt == "Ven"
   aCT[1]:FECFAC    := aCT[3] ; aCT[1]:CANTIDAD += aCT[7]
   aCT[1]:PRECIOVEN += aCT[5] ; aCT[1]:DESMON   += aCT[6]
   aCT[1]:PPUBLI    += aCT[8] ; aCT[1]:SERVIC   += aCT[9]
Else
   aCT[1]:CONSEC    := aCT[6] ; aCT[1]:FECDOC   := aCT[3]
   aCT[1]:DESMON    += aCT[5] ; aCT[1]:CANTLOC  += aCT[7]
   aCT[1]:VALOR     += aCT[8] ; aCT[1]:SERVLOC  += aCT[9]
EndIf
   aCT[1]:Update(.f.,1)
RETURN NIL

//----Convierte en Vacio un Valor-----//
FUNCTION CTOEMPTY( uValue,cType,nLen )
   DEFAULT cType:=ValType(uValue)

   DO CASE
      CASE ValType(uValue)="U".AND.cType$"CM"
            uValue:=SPACE(nLen)
      CASE ValType(uValue)="U".AND.cType="N"
            uValue:=0.00
      CASE ValType(uValue)="U".AND.cType="D"
            uValue:=CTOD("")
      CASE ValType(uValue)="U".AND.cType="L"
            uValue:=.F.
      CASE ValType(uValue)="C"
         uValue:=SPACE(LEN(uValue))
      CASE ValType(uValue)="N"
         uValue:=0
      CASE ValType(uValue)="D"
         uValue:=CTOD("")
      CASE ValType(uValue)="L"
         uValue:=.F.
   ENDCASE
RETURN uValue