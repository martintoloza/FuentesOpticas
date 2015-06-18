//------------------------------------//
FUNCTION ExportEXC( cQry,xModo )
   LOCAL oXls, oFile, cCelda, cTxt
   LOCAL f, i, j, lAlfa
   LOCAL cExcel := ""
// LOCAL cTxt := cFilePath( GetModuleFileName( GetInstance() ))
If xModo # NIL
   If (j := RAT( "\",cQry )) > 0
      cTxt   :=  LEFT( cQry,j )
      cExcel := SUBSTR(cQry,j+1 )
   EndIf
EndIf
    cTxt := STRTRAN( oApl:cRuta1,"Bitmap","Excel" )
  cExcel := AbrirFile( 5,cTxt,"*.XLS" )
  If EMPTY( cExcel )
     RETURN Nil
  EndIf
  cExcel += If( !"." $ cExcel, ".xls","" )
MsgInfo( cExcel )
  f := 1
  FERASE(cExcel)
  oApl:oWnd:SetMsg( "Exportando hacia "+cExcel )

  OPEN XLS oXls ;
    FILENAME cExcel
If xModo == NIL
   oFile := TMsQuery():Query( oApl:oDb,cQry )
   If oFile:Open()
         @ f,1 SAY oApl:cEmpresa OF oXls
      f += 2
      FOR j := 1 TO oFile:nFieldCount
         @ f, j SAY oFile:FieldName(j) OF oXls
      NEXT j

      oFile:GoTop()
      FOR j := 1 TO oFile:nRowCount
         cTxt := oFile:Read()
         f++
         FOR i := 1 TO oFile:nFieldCount
            @ f, i SAY cTxt[i] OF oXls
         NEXT i
         oFile:Skip(1)
      NEXT j
   EndIf
   oFile:Close()
Else
   oFile  := TTxtFile():New(cQry)

   WHILE !oFile:lEoF()
      cTxt := oFile:cLine
      If !EMPTY(cTxt)
         i := 1
         WHILE !EMPTY(cTxt)
            cCelda := Saca(@cTxt,'",')
            cCelda := STRTRAN(cCelda,'"')

            lAlfa := .f.
            FOR j=1 TO LEN(cCelda)
               If ISALPHA( SUBSTR(cCelda,j,1) )
                  lAlfa := .t.
                  Exit
               EndIf
            NEXT j
            If !lAlfa
               cCelda := ALLTRIM(cCelda)
            EndIf
            @ f, i SAY cCelda OF oXls
            i++
         ENDDO
      EndIf
      oFile:Skip( 1 )
      f++
   ENDDO
EndIf
  CLOSE XLS oXls
If f > 1
   If MSGYESNO("Se ha generado el archivo Excel "+CRLF+CRLF+;
               cExcel+CRLF+CRLF+;
              "¿Desea poner en marcha Excel y visualizar el archivo?","Informe terminado")
      ShellExecute( ,,cExcel,'','',5)  //Ejecutamos Excel
   EndIf
Else
   FERASE(cExcel)
EndIf
RETURN NIL
