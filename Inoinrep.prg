// Programa.: INOINREP.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Mantenimiento a Reposiciones.
#include "FiveWin.ch"
#include "btnget.ch"

MEMVAR oApl

FUNCTION InoinRep()
   LOCAL oDlg, oLbx, oGet := ARRAY(7), lSalir := .f.
   LOCAL aBarra, oR := TRepos()
oR:New()
aBarra := { {|| oR:Editar( oLbx,.t. ) }, {|| oR:Editar( oLbx,.f. ) },;
            {|| oR:Facturar() }        , {|| oR:Borrar( oLbx ) }    ,;
            {|| ListoRep( {oR:aCab[2],"publi",oR:oRpc:FECHAREP,oR:oRpc:FECHAREP,;
                   oR:aCab[1],.f.,"N"} ), oR:aCab[1] := 0, oGet[1]:SetFocus() },;
            {|| lSalir := .t., oDlg:End() } }

DEFINE DIALOG oDlg FROM 0, 0 TO 330, 580 PIXEL;
   TITLE "Reposiciones a Opticas"
   @ 02, 00 SAY "Nro. de Reposición" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 02, 72 GET oGet[1] VAR oR:aCab[1] OF oDlg PICTURE "999999";
      VALID oR:Buscar( oLbx,oGet )                             ;
      SIZE 30,10 PIXEL UPDATE
   @ 02,110 SAY "Sgte.Reposición" + STR( oR:aCab[3],6 ) OF oDlg PIXEL SIZE 80,10;
      UPDATE COLOR nRGB( 255,0,0 )
   @ 16, 00 SAY "Optica" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 16, 72 GET oGet[2] VAR oR:aCab[2] OF oDlg PICTURE "@!"        ;
      VALID EVAL( {|| If( oApl:oEmp:Seek( {"localiz",oR:aCab[2]} ),;
                        ( oApl:nEmpresa := oApl:oEmp:OPTICA       ,;
                          oR:CambiaOptica() , .t. )               ,;
                      (MsgStop("Esta Optica NO EXISTE"), .f.) ) } );
      WHEN (oR:oRpc:ITEMS == 0 .OR. oR:aPrv[2]) SIZE 26,10 PIXEL UPDATE
   @ 16,110 SAY "% Dscto. Costo"   OF oDlg RIGHT PIXEL SIZE 40,10
   @ 16,152 GET oGet[3] VAR oR:oRpc:DESPOR   OF oDlg PICTURE "999.99";
      VALID (If( Rango( oR:oRpc:DESPOR,0,100 ), .t., ;
               (MsgStop( "El Porcentaje debe ser entre 0 y 100",">>OJO<<" ), .f.)) );
      WHEN  oR:oRpc:ITEMS == 0 SIZE 26,10 PIXEL UPDATE
   @ 30, 00 SAY "Fecha [DD.MM.AA]" OF oDlg RIGHT PIXEL SIZE 70,10
   @ 30, 72 GET oGet[4] VAR oR:oRpc:FECHAREP OF oDlg ;
      VALID oR:New( .f. )                            ;
      WHEN  oR:oRpc:ITEMS == 0 SIZE 36,10 PIXEL UPDATE
   @ 30,110 SAY "% Dscto. Publico" OF oDlg RIGHT PIXEL SIZE 40,10
   @ 30,152 GET oGet[5] VAR oR:oRpc:DESPUB   OF oDlg PICTURE "999.99";
      VALID (If( Rango( oR:oRpc:DESPUB,0,100 ), .t., ;
               (MsgStop( "El Porcentaje debe ser entre 0 y 100",">>OJO<<" ), .f.)) );
      WHEN  oR:oRpc:ITEMS == 0 SIZE 26,10 PIXEL UPDATE
   @ 16,182 SAY "Nro. Factura"     OF oDlg RIGHT PIXEL SIZE 60,10
   @ 16,246 SAY oGet[6] VAR oR:oRpc:NUMFAC   OF oDlg SIZE 40,12 PIXEL UPDATE
   @ 30,182 SAY "Nro. Items"       OF oDlg RIGHT PIXEL SIZE 60,10
   @ 30,246 SAY oGet[7] VAR oR:oRpc:ITEMS    OF oDlg SIZE 40,12 PIXEL UPDATE
   @ 62,06 LISTBOX oLbx FIELDS oR:oRpd:CODIGO             ,;
                    LeerCodig( oR:oRpd:CODIGO )           ,;
                    TRANSFORM( oR:oRpd:CANTIDAD,"99,999" ),;
                    TRANSFORM( oR:oRpd:PCOSTO  ,"99,999,999" ),;
                               oR:oRpd:INDICA              ;
      HEADERS "Código"+CRLF+"Artículo", "Descripción", "Cantidad",;
              "Precio"+CRLF+"Costo", "Ind";
      SIZES 400, 450 SIZE 280,100 ;
      OF oDlg UPDATE PIXEL        ;
      ON DBLCLICK EVAL( aBarra[2] )
    oLbx:nClrBackHead  := oApl:nClrBackHead
    oLbx:nClrForeHead  := oApl:nClrForeHead
    oLbx:SetColor(oApl:nClrFore,oApl:nClrBack)
    oLbx:nClrBackFocus := oApl:nClrBackFocus
    oLbx:nClrForeFocus := oApl:nClrForeFocus
    oLbx:nHeaderHeight := 28
    oLbx:GoTop()
    oLbx:oFont  := Tfont():New("Ms Sans Serif",0,-10,,.f.)
    oLbx:aColSizes   := {90,220,80,80,10}
    oLbx:aHjustify   := {2,2,2,2,2}
    oLbx:aJustify    := {0,0,1,1,2}
    oLbx:ladjbrowse  := oLbx:lCellStyle  := .f.
    oLbx:ladjlastcol := .t.
    oLbx:bKeyDown := {|nKey| If(nKey == VK_ESCAPE,  ( oR:aCab[1] := 0, oGet[1]:SetFocus() )   ,;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=65, oR:Actual()            ,;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=82, CambiaIndica( oR:oRpd ),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=78 .OR. nKey=VK_INSERT, EVAL(aBarra[1]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=69 .OR. nKey=VK_RETURN, EVAL(aBarra[2]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=VK_DELETE,          EVAL(aBarra[4]),;
                             If(GetKeyState(VK_CONTROL) .AND. nKey=80 .OR. nKey=VK_F3, EVAL(aBarra[5]),) )))))) }
   MySetBrowse( oLbx,oR:oRpd )
   ACTIVAGET(oGet)
ACTIVATE DIALOG oDlg ON INIT         ;
  (oDlg:Move(80,1), DefineBar( oDlg,oLbx,aBarra,90,18 ),;
   oR:aCab[6] := oDlg);
   VALID lSalir
oR:oRpc:Destroy()
oR:oRpd:Destroy()
oApl:oEmp:Seek( {"optica",oR:aCab[4]} )
nEmpresa( .f. )

RETURN NIL

//------------------------------------//
CLASS TRepos

 DATA aCab, aPrv, oRpc, oRpd

 METHOD NEW( lOK ) Constructor
 METHOD Buscar( oLbx,oGet,lNew )
 METHOD Borrar( oLbx )
 METHOD Editar( oLbx,lNew )
 METHOD Grabar( oLbx,lNew )
 METHOD Marcar( cCodigo,nCanti,lCambio,nBod )
 METHOD CambiaOptica()
 METHOD Actual()
 METHOD Facturar()

ENDCLASS

//------------------------------------//
METHOD New( lOK ) CLASS TRepos
If lOK == NIL
   oApl:oEmp:Seek( {"optica",0} )
   ::aCab := { 0,"COC",oApl:oEmp:NUMREP + 1,oApl:nEmpresa,TInv(),"",.f.,0,0 }
   ::aPrv := Privileg( "REPOSICIONES" )
   ::oRpc := oApl:Abrir( "cadrepoc","numrep",.t.,,10 )
   ::oRpd := oApl:Abrir( "cadrepod","numrep",.t.,,100 )
   ::oRpd:Seek( { "numrep",0 } )
   ::aCab[5]:New( ,.f. )
Else
   If EMPTY( ::oRpc:FECHAREP )
      MsgStop( "No puede ir en Blanco","FECHA" )
   ElseIf ::oRpc:FECHAREP < DATE()-1
      MsgStop( "Menor para hacer Reposiciones","FECHA" )
   Else
      oApl:cPer := NtChr( ::oRpc:FECHAREP,"1" )
      lOK := .t.
   EndIf
EndIf
RETURN lOK

//------------------------------------//
METHOD Buscar( oLbx,oGet,lNew ) CLASS TRepos
   LOCAL xBus, lSi := .f.
If oLbx == NIL
   If (lSi := oApl:oInv:Seek( {"codigo",::oRpd:CODIGO} ))
      If oApl:oInv:GRUPO == "1"
         If lNew .OR. ::aCab[8] # ::oRpd:CODIGO
            If Buscar( {"numrep",::aCab[1],"codigo",::oRpd:CODIGO},"cadrepod","1",8,,4 ) == 1
               MsgStop( "Está Reposición ya tiene este Código",::oRpd:CODIGO )
               If oApl:oInv:OPTICA == 0
                  ::Actual()
               EndIf
               RETURN .f.
            EndIf
            xBus          := oApl:nEmpresa
            oApl:nEmpresa := 0
            SaldoInv( ::oRpd:CODIGO,oApl:cPer )
            oApl:nEmpresa := xBus
         Else
            oApl:aInvme[1] := 1
         EndIf
         If oApl:aInvme[1] <= 0
            MsgStop( "hacer Reposición sin Existencia",">> NO PUEDO <<" )
            lSi := .f.
         ElseIf oApl:oInv:OPTICA # 0 .OR. oApl:oInv:SITUACION == "D"
            xBus := {"Activa","Vendida","Devuelta"}[AT(oApl:oInv:SITUACION,;
                     "EVD")] + " en " + ;
                    ArrayValor( oApl:aOptic,STR(oApl:oInv:OPTICA,2) )
            MsgStop( xBus,"Montura esta" )
            lSi := .f.
         EndIf
      EndIf
      If lSi
         oGet:Update()
      EndIf
   Else
      MsgStop( "Este Código NO EXISTE !!!",::oRpd:CODIGO )
   EndIf
ElseIf Rango( ::aCab[1],0,::aCab[3] )
   If !::oRpc:Seek( { "numrep",::aCab[1] } ) .AND. ::aCab[1] > 0
      MsgStop( "Está Reposición NO EXISTE !!" )
   Else
      If ::oRpc:lOK
         oApl:oEmp:Seek( {"optica",::oRpc:OPTICA} )
         ::aCab[2] := oApl:oEmp:LOCALIZ
         ::aCab[7] := If( oApl:oEmp:PRINCIPAL == 4, .f., .t. )
         oApl:nEmpresa := ::oRpc:OPTICA
         oGet[1]:oJump := oLbx
      Else
         ::aCab[2] := "COC"
         ::oRpc:FECHAREP := DATE()
      EndIf
      oApl:cPer := NtChr( ::oRpc:FECHAREP,"1" )
      ::oRpd:Seek( { "numrep",::aCab[1] } )
      ::aCab[6]:Update()
      oLbx:Refresh()
      lSi := .t.
   EndIf
EndIf
RETURN lSi

//------------------------------------//
METHOD Borrar( oLbx ) CLASS TRepos
   LOCAL lDesmar := .f.
If ::aPrv[3]          .AND. ::oRpc:ITEMS   > 0  .AND.;
   ::oRpc:NUMFAC == 0 .AND. ::oRpd:INDICA # "B" .AND.;
   !CierreInv( ::oRpc:FECHAREP,"REPOSICIONES" )
   If MsgNoYes( "Este Código "+::oRpd:CODIGO,"Elimina" )
//      If Login( "Desea Eliminar este Código" ) .AND. LEFT(::oRpd:CODIGO,2) == "01"
//         lDesmar := MsgNoYes("Desmarcar esta Montura","Quieres" )
//      EndIf
      ::Marcar( ::oRpd:CODIGO,-::oRpd:CANTIDAD,lDesmar )
      ::oRpc:ITEMS -- ; ::oRpc:Update( .f.,1 )
      If ::oRpd:INDICA == "E" .AND. oApl:lEnLinea
         ::oRpd:INDICA := "B"; ::oRpd:Update( .f.,1 )
      ElseIf ::oRpd:Delete( .t.,1 )
         oLbx:GoBottom()
      EndIf
      oLbx:SetFocus() ; oLbx:Refresh()
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD Editar( oLbx,lNew ) CLASS TRepos
   LOCAL oDlg, cMsg, cTit := "Modificando Reposición"
   LOCAL oAr, oGet := ARRAY(5), oE := Self
   LOCAL bGrabar := {|| ::Grabar( oLbx,lNew ), oLbx:Refresh(), oDlg:End() }
lNew := If( ::oRpc:CONTROL == 0, .t., lNew )
If CierreInv( ::oRpc:FECHAREP,"REPOSICIONES" )
   RETURN NIL
ElseIf lNew
   cTit    := "Nueva Reposición"
   bGrabar := {|| ::Grabar( oLbx,lNew )         ,;
                  ::oRpd:xBlank()               ,;
                  ::oRpd:CANTIDAD := 1          ,;
                  oDlg:Update(), oDlg:SetFocus() }
   oLbx:GoBottom() ; ::oRpd:xBlank()
   ::oRpd:CANTIDAD := 1
ElseIf ::oRpc:NUMFAC > 0 .OR. ::oRpd:INDICA == "B"
   MsgStop( "Esta Reposición ya fue Facturada !!!" )
   RETURN NIL
EndIf
 ::aCab[8] := ::oRpd:CODIGO
 ::aCab[9] := ::oRpd:CANTIDAD
oAr := ::aCab[5]
oApl:oInv:Seek( {"codigo",oE:oRpd:CODIGO} )

DEFINE DIALOG oDlg TITLE cTit FROM 0, 0 TO 08,40
   @ 02,00 SAY "Código"   OF oDlg RIGHT PIXEL SIZE 60,10
   @ 02,62 BTNGET oGet[1] VAR oE:oRpd:CODIGO OF oDlg PICTURE "999999999!!!";
      VALID oE:Buscar( ,oDlg,lNew )                                        ;
      SIZE 56,12 PIXEL  RESOURCE "BUSCAR"                                  ;
      ACTION EVAL({|| If(oAr:Mostrar(), ( oE:oRpd:CODIGO := oAr:oDb:CODIGO,;
                         oGet[1]:Refresh() ),)})
   @ 16,30 SAY oGet[2] VAR oApl:oInv:DESCRIP OF oDlg PIXEL SIZE 100,12;
      UPDATE COLOR nRGB( 128,0,255 )
   @ 30,00 SAY "Cantidad" OF oDlg RIGHT PIXEL SIZE 60,10
   @ 30,62 GET oGet[3] VAR ::oRpd:CANTIDAD OF oDlg PICTURE "9,999";
      VALID {|| If( ::oRpd:CANTIDAD >  0, .t.                    ,;
        (MsgStop( "La Cantidad debe ser Mayor de 0","<< OJO >>" ), .f.)) };
      WHEN LEFT( ::oRpd:CODIGO,2 ) # "01" SIZE 40,12 PIXEL UPDATE
   @ 46, 50 BUTTON oGet[4] PROMPT "Grabar"   SIZE 44,12 OF oDlg ACTION ;
      (If( EMPTY( ::oRpd:CODIGO ) .OR. ::oRpd:CANTIDAD <= 0           ,;
         (MsgStop("Imposible grabar este Código"), oGet[1]:SetFocus()),;
         ( oGet[4]:Disable(), EVAL( bGrabar ), oGet[4]:Enable() ))) PIXEL
   @ 46,100 BUTTON oGet[5] PROMPT "Cancelar" SIZE 44,12 OF oDlg CANCEL;
      ACTION oDlg:End() PIXEL
   ACTIVAGET(oGet)
   If !::aPrv[1]
      oGet[4]:Disable()
   EndIf
ACTIVATE DIALOG oDlg ON INIT oDlg:Move(260,230)
RETURN NIL

//------------------------------------//
METHOD Grabar( oLbx,lNew ) CLASS TRepos

If ::aCab[1] == 0
   ::aCab[1] := SgteNumero( "numrep",0,.t. )
   ::oRpc:OPTICA := oApl:nEmpresa
   ::oRpc:NUMREP := ::aCab[1]
   ::oRpc:Append( .t. )
   ::aCab[3] := ::aCab[1] + 1
   ::aCab[6]:Update()
EndIf
::oRpd:GRUPO  := oApl:oInv:GRUPO
If ::oRpc:DESPOR > 0
   ::oRpd:PCOSTO := oApl:oInv:PCOSTO - ;
                    ROUND( oApl:oInv:PCOSTO * ::oRpc:DESPOR / 100,0 )
Else
   ::oRpd:PCOSTO := ROUND( oApl:oInv:PCOSTO * ;
                    Ptaje( oApl:oInv:IDENTIF,::aCab[7],oApl:oInv:CODIGO_NIT ),0 )
EndIf
::oRpd:PPUBLI := oApl:oInv:PPUBLI
If lNew
   ::oRpc:CONTROL   ++
   ::oRpc:ITEMS     ++
   ::oRpd:NUMREP    := ::aCab[1]
   ::oRpd:SECUENCIA := ::oRpc:CONTROL
   ::oRpd:Append( .t. )
   ::oRpc:Update( .f.,1 )
   ::Marcar( ::oRpd:CODIGO,::oRpd:CANTIDAD,.t. )
   PListbox( oLbx,::oRpd )
Else
   If ::oRpd:INDICA == "E" .AND. ;
     (::oRpd:CODIGO # ::aCab[8] .OR. ::oRpd:CANTIDAD # ::aCab[9])
      ::oRpd:INDICA := "C"
   EndIf
   If ::oRpd:CODIGO # ::aCab[8]
      ::Marcar( ::aCab[8],-::aCab[9],.f. )
      ::aCab[9] := 0
   EndIf
   ::oRpd:Update( .t.,1 )
   ::Marcar( ::oRpd:CODIGO,::oRpd:CANTIDAD-::aCab[9],.t. )
EndIf
RETURN NIL

//------------------------------------//
METHOD Marcar( cCodigo,nCanti,lCambio,nBod ) CLASS TRepos
   LOCAL aD, cQry
If nCanti # 0
   If LEFT( cCodigo,2 )  == "01"
      If lCambio
         aD := { ::oRpc:OPTICA,::oRpc:FECHAREP,::oRpc:NUMREP,0,::oRpc:DESPUB }
      Else
         aD := { 0,CTOD(""),0,0,0 }
      EndIf
      cQry := "UPDATE cadinven SET optica = " + LTRIM( STR(aD[1]) )+;
              ", fecrepos = " + xValToChar(aD[2] )  +;
              ", numrepos = " + LTRIM( STR(aD[3]) ) +;
              ", loc_antes = "+ LTRIM( STR(aD[4]) ) +;
              ", despor    = "+ LTRIM( STR(aD[5]) ) +;
            " WHERE codigo = "+ xValToChar(cCodigo)
//           " AND (Numrepos = 0 OR Numrepos = "      + LTRIM(STR(::oRpc:NUMREP)) + ")"
      If MSQuery( oApl:oMySql:hConnect,cQry )
         oApl:oWnd:SetMsg( "Actualizado el Codigo "+cCodigo )
      Else
         oApl:oMySql:oError:Display( .f. )
      EndIf
   EndIf
   If nBod == NIL
      oApl:nEmpresa := 0               // Actualiza inventario de Bodega
      Actualiz( cCodigo,nCanti,::oRpc:FECHAREP,2 )
   EndIf
   oApl:nEmpresa := ::oRpc:OPTICA      // Actualiza entrada inventario de Opticas
   If oApl:nEmpresa > 2
      Actualiz( cCodigo,nCanti,::oRpc:FECHAREP,1,::oRpd:PCOSTO )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
METHOD CambiaOptica() CLASS TRepos
   LOCAL aO := { ::oRpc:OPTICA,0,"" }
If ::oRpc:ITEMS   > 0 .AND. aO[1] # oApl:nEmpresa
   ::oRpc:OPTICA := oApl:nEmpresa
   ::oRpc:Update( .f.,1 )
   aO[2] := ::oRpd:Recno()
   aO[3] := "UPDATE cadinvme SET optica = " + LTRIM(STR(oApl:nEmpresa))+;
           " WHERE optica = "  + LTRIM( STR(aO[1]) )       +;
             " AND anomes = '" + NtChr(::oRpc:FECHAREP,"1")+;
            "' AND codigo = '[COD]'"                       +;
             " AND existencia = 0 AND entradas  = 0"       +;
             " AND salidas    = 0 AND ajustes_e = 0"       +;
             " AND ajustes_s  = 0 AND devol_e   = 0"       +;
             " AND devol_s    = 0 AND devolcli  = 0"
   ::oRpd:GoTop():Read()
   ::oRpd:xLoad()
   While !::oRpd:Eof()
      oApl:nEmpresa := aO[1]
      Actualiz( ::oRpd:CODIGO,-::oRpd:CANTIDAD,::oRpc:FECHAREP,1,::oRpd:PCOSTO )
      If LEFT( ::oRpd:CODIGO,2 ) == "01"
         Guardar( STRTRAN( aO[3],"[COD]",ALLTRIM(::oRpd:CODIGO) ),"cadinvme" )
      EndIf
      ::Marcar( ::oRpd:CODIGO, ::oRpd:CANTIDAD,.t.,0 )
      ::oRpd:Skip(1):Read()
      ::oRpd:xLoad()
   EndDo
   ::oRpd:Go( aO[2] ):Read()
   MsgInfo( "El cambio de Optica","HECHO" )
EndIf
 ::aCab[7] := If( oApl:oEmp:PRINCIPAL == 4, .f., .t. )
RETURN NIL

//------------------------------------//
METHOD Actual() CLASS TRepos
   LOCAL cQry
cQry := "UPDATE cadinven i, cadrepoc c, cadrepod d "        +;
        "SET i.optica = c.optica, i.fecrepos = c.fecharep, "+;
            "i.numrepos = c.numrep, i.despor = c.despub "   +;
        "WHERE c.numrep = " + LTRIM( STR(::aCab[1]) )       +;
         " AND d.numrep = c.Numrep"     +;
         " AND LEFT(d.codigo,2) = '01'" +;
         " AND i.codigo = d.codigo"     +;
         " AND i.optica = 0"
RunSql1( cQry )
RETURN NIL

//------------------------------------//
METHOD Facturar() CLASS TRepos
   LOCAL aDet, aFac, aRes, cQry, hRes, nL, nV
If oApl:lEnLinea
   If ::oRpc:NUMFAC > 0
      If MsgNoYes( "Está Reposición","DESMARCAR" )
         cQry := "DELETE FROM cadfactu WHERE optica = 0"     +;
                 " AND numfac = " + LTRIM(STR(::oRpc:NUMFAC))+;
                 " AND tipo = 'U'"
         MSQuery( oApl:oMySql:hConnect,cQry )
         ::oRpc:NUMFAC := 0 ; ::oRpc:Update( .f.,1 )
         MsgInfo( "Ya está Desmarcada","HECHO" )
      EndIf
   EndIf
   RETURN NIL
EndIf
aFac := { 0,0,0,0,0,oApl:oEmp:PIVA/100 }
aDet := { {"0101","MONTURAS"  ,0,0,0,0,0,0,0},;
          {"0301","LIQUIDOS"  ,0,0,0,0,0,0,0},;
          {"0302","LIQUIDOS"  ,0,0,0,0,0,0,0},;
          {"0401","ACCESORIOS",0,0,0,0,0,0,0},;
          {"0402","ACCESORIOS",0,0,0,0,0,0,0} }
cQry := "SELECT d.cantidad, d.pcosto, d.codigo, i.indiva, i.moneda, i.identif, i.codigo_nit "+;
        "FROM cadrepod d, cadinven i "             +;
        "WHERE d.numrep = " + LTRIM(STR(::aCab[1]))+;
         " AND d.indica <> 'B' AND i.codigo = d.codigo"
hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
            MSStoreResult( oApl:oMySql:hConnect ), 0 )
nL   := MSNumRows( hRes )
While nL > 0
   aRes := MyReadRow( hRes )
   AEVAL( aRes, { | xV,nP | aRes[nP] := MyClReadCol( hRes,nP ) } )
   aRes[3] := Grupos( aRes[3] )
   nV := { 1,1,2,4 }[VAL( aRes[3] )] + If( aRes[4] == 1, 0, 1 )
   aFac[3] := aRes[1] * Dolar_Peso( oApl:nUS,aRes[2],aRes[5] )
   aFac[4] += aFac[3]
   aFac[5] += If( aRes[4] == 1, aFac[3], 0 )
   aDet[nV,3] += aRes[1]
   aDet[nV,4] += aFac[3]
   If aRes[3] == "1"
      aFac[3] := ROUND( aFac[3] / Ptaje( aRes[6],.t.,aRes[7] ),0 )
   EndIf
   aDet[nV,9] += aFac[3]
   nL --
EndDo
MSFreeResult( hRes )
If aFac[4] > 0
   nV := SgteNumero( "numfacu",0,.f. )
   If MsgGet( "Numero","Factura",@nV )
      aFac[5]   := ROUND( aFac[5]   * aFac[6],0 )
      aDet[1,7] := ROUND( aDet[1,4] * aFac[6],0 )
      aDet[2,7] := ROUND( aDet[2,4] * aFac[6],0 )
      aDet[4,7] := ROUND( aDet[4,4] * aFac[6],0 )
      oApl:cPer := NtChr( ::oRpc:FECHAREP,"1" )
      oApl:lFam := .f.
      oApl:oFac:xBlank()
  /*  If aFac[4] >= oApl:oEmp:TOPERET
         oApl:oFac:RETFTE := ROUND( aFac[4] * oApl:oEmp:PRET,0 )
      EndIf*/
      oApl:nSaldo := aFac[4] + aFac[5] // - oApl:oFac:RETFTE
      oApl:oFac:OPTICA   := oApl:nEmpresa := 0
      oApl:oFac:NUMFAC   := ::oRpc:NUMFAC := nV
      oApl:oFac:CODIGO_NIT:= oApl:oEmp:CODIGO_NIT
      oApl:oFac:TIPO     := "U"
      oApl:oFac:FECHOY   := oApl:oFac:FECHAENT := ::oRpc:FECHAREP
      oApl:oFac:GAVETA   := INT( ::oRpc:ITEMS/14 ) + If( ::oRpc:ITEMS % 14 > 0, 1, 0 )
      oApl:oFac:CLIENTE  := "Reposicion No." + STR( ::aCab[1] )
      oApl:oFac:TOTALIVA := aFac[5]
      oApl:oFac:TOTALFAC := oApl:nSaldo
      oApl:oFac:INDICADOR:= "P" ; oApl:oFac:TIPOFAC := "L"
      nV += (oApl:oFac:GAVETA -1)
      oApl:oFac:Insert( .f. )
      GrabaSal( oApl:oFac:NUMFAC,1,0 )
      GrabaVen( aDet,1 )
      MSQuery( oApl:oMySql:hConnect,"UPDATE cadempre SET numfacu = "+;
               LTRIM( STR(nV) ) + " WHERE optica = 0" )
      oApl:nEmpresa := ::oRpc:OPTICA
      ::oRpc:Update( .f.,1 )
      MsgInfo( "TOT"+TRANSFORM( oApl:nSaldo,"99,999,999" ),;
               "IVA"+TRANSFORM( aFac[5],"99,999,999") )
   EndIf
EndIf
RETURN NIL

//------------------------------------//
FUNCTION Ptaje( cIdentif,lFac,nCNit )
   LOCAL cQry, hRes, nPor := 1
If cIdentif == "I" .AND. lFac
   cQry := "SELECT ptaje FROM cadimport " +;
           "WHERE codigo_nit = " + LTRIM(STR(nCNit))
   hRes := If( MSQuery( oApl:oMySql:hConnect,cQry ) ,;
               MSStoreResult( oApl:oMySql:hConnect ), 0 )
   If MSNumRows( hRes ) > 0
      cQry := MyReadRow( hRes )
      nPor := MyClReadCol( hRes,1 )
   Else
      nPor := 1.40
   EndIf
   MSFreeResult( hRes )
EndIf
RETURN nPor