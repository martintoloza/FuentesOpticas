// Programa.: CAODBASE.PRG    >>> Martin A. Toloza Lozano <<<
// Notas....: Modulo para la creacion de el diccionario de datos

MEMVAR oApl

FUNCTION Diccionario( cTabla,xDbf )
   LOCAL aStruct, aIndice := {}, nI, oTb
   LOCAL cLogica := " unsigned zerofill NOT NULL default '0'"
do Case
Case cTabla == "cadantic"
   aStruct := { { "optica"    , "N", 02, 00, },;
                { "numero"    , "N", 10, 00, " auto_increment" },;
                { "fecha"     , "D", 08, 00, },;
                { "vendedor"  , "C", 05, 00, },;
                { "orden"     , "N", 10, 00, },;
                { "gaveta"    , "N", 03, 00, },;
                { "cliente"   , "C", 30, 00, },;
                { "direcc"    , "C", 30, 00, },;
                { "telefono"  , "C", 08, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "codigo_cli", "N", 06, 00, },;
                { "fechaent"  , "D", 08, 00, },;
                { "fechacan"  , "D", 08, 00, },;
                { "totaldes"  , "N", 10, 02, },;
                { "totaliva"  , "N", 10, 02, },;
                { "totalfac"  , "N", 11, 02, },;
                { "saldofac"  , "N", 10, 00, },;
                { "indicador" , "C", 01, 00, " default 'C'"},;
                { "valoreps"  , "N", 06, 00, },;
                { "tipofac"   , "C", 01, 00, },;
                { "numfac"    , "N", 10, 00, },;
                { "valorot"   , "N", 10, 00, },;
                { "PRIMARY KEY (optica, numero)", "P",,,} }
   aIndice := { { "Fecha"     , { "optica", "fecha", "numero" } },;
                { "Cliente"   , { "cliente" } } }
Case cTabla == "cadantid"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "optica"    , "N", 02, 00, },;
                { "numero"    , "N", 10, 00, },;
                { "fecha"     , "D", 08, 00, },;
                { "codart"    , "C", 12, 00, },;
                { "descri"    , "C", 40, 00, },;
                { "cantidad"  , "N", 03, 00, },;
                { "precioven" , "N", 11, 02, },;
                { "despor"    , "N", 06, 02, },;
                { "desmon"    , "N", 11, 02, },;
                { "montoiva"  , "N", 11, 02, },;
                { "ppubli"    , "N", 11, 02, },;
                { "indicador" , "C", 01, 00, },;
                { "fecdev"    , "D", 08, 00, },;
                { "pcosto"    , "N", 11, 02, } }
   aIndice := { { "Factura"  , { "optica", "numero" } },;
                { "FechaDev" , { "optica", "fecdev", "numero" } } }
//                { "Constraint",{ "ALTER TABLE cadantid ADD CONSTRAINT kt_Venta "+;
//                             "FOREIGN KEY (Optica, Numero) REFERENCES cadantic "+;
//                             "(Optica, Numero) ON DELETE CASCADE ON UPDATE CASCADE" } } }
Case cTabla == "cadantip"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "optica"    , "N", 02, 00, },;
                { "numero"    , "N", 10, 00, },;
                { "fecha"     , "D", 08, 00, },;
                { "abono"     , "N", 11, 02, },;
                { "pagado"    , "N", 11, 02, },;
                { "retencion" , "N", 10, 02, },;
                { "deduccion" , "N", 10, 02, },;
                { "descuento" , "N", 10, 02, },;
                { "numcheque" , "C", 16, 00, },;
                { "codbanco"  , "C", 02, 00, },;
                { "formapago" , "N", 01, 00, },;
                { "indred"    , "L", 01, 00, },;
                { "pordonde"  , "C", 01, 00, " default 'F'"},;
                { "rcaja"     , "N", 08, 00, } }
   aIndice := { { "Factura"  , { "optica", "numero" } }  ,;
                { "FechaPag" , { "optica", "fecha", "numero" } } }
Case cTabla == "comprasc"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "optica"    , "N", 02, 00, },;
                { "ingreso"   , "N", 05, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "fecingre"  , "D", 08, 00, },;
                { "factura"   , "C", 08, 00, },;
                { "moneda"    , "C", 01, 00, },;
                { "control"   , "N", 06, 00, },;
                { "totaliva"  , "N", 11, 02, },;
                { "totalfac"  , "N", 11, 02, },;
                { "cgeconse"  , "N", 06, 00, } }
   aIndice := { { "Ingreso", { "ingreso" } } ,;
                { "Fecha"  , { "fecingre", "ingreso" } } }
Case cTabla == "comprasf"
   aStruct := { { "row_id"     , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "comprasc_id", "N", 11, 00, },;
                { "fecha"      , "D", 08, 00, },;
                { "dscto"      , "N", 11, 02, },;
                { "dscto_us"   , "N", 11, 02, },;
                { "ptaje"      , "N", 06, 02, } }
   aIndice := { { "comprasf_FKIndex1", { "comprasc_id" } } }
Case cTabla == "cadartid"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "ingreso"   , "N", 05, 00, },;
                { "codigo"    , "C", 12, 00, },;
                { "cantidad"  , "N", 04, 00, },;
                { "pcosto"    , "N", 10, 02, },;
                { "pventa"    , "N", 10, 02, },;
                { "ppubli"    , "N", 10, 02, },;
                { "indiva"    , "N", 01, 00, },;
                { "secuencia" , "N", 06, 00, },;
                { "indica"    , "C", 01, 00, } }
   aIndice := { { "Ingreso", { "ingreso" } } }
Case cTabla == "cadarque"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "optica"    , "N", 02, 00, },;
                { "codigo"    , "C", 12, 00, },;
                { "anomes"    , "C", 06, 00, },;
                { "cantidad"  , "N", 04, 00, },;
                { "vitrina"   , "C", 03, 00, } }
   aIndice := { { "Codigo" , { "optica", "codigo", "anomes" } },;
                { "Periodo", { "optica", "anomes", "vitrina" } } }
Case cTabla == "cadbanco"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 02, 00, },;
                { "nombre"    , "C", 30, 00, },;
                { "debito"    , "N", 05, 02, },;
                { "credito"   , "N", 05, 02, },;
                { "en_espera" , "L", 01, 00, } }
   aIndice := { { "Codigo" , { "codigo" } },;
                { "Nombre" , { "nombre" } } }
Case cTabla == "cadcodig"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codbarra"  , "C", 12, 00, },;
                { "codigo"    , "C", 12, 00, } }
   aIndice := { { "Codigob", { "codbarra" } } }
Case cTabla == "cadclien"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "N", 12, 00, },;
                { "digito"    , "N", 01, 00, },;
                { "tipocod"   , "N", 01, 00, },;
                { "nombre"    , "C", 35, 00, },;
                { "telefono"  , "C", 16, 00, },;
                { "fax"       , "C", 08, 00, },;
                { "direccion" , "C", 40, 00, },;
                { "email"     , "C", 30, 00, },;
                { "codigo_ciu", "C", 05, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "por_dscto" , "N", 05, 02, },;
                { "consulta"  , "N", 08, 00, },;
                { "eps"       , "L", 01, 00, cLogica },;
                { "grupo"     , "L", 01, 00, cLogica },;
                { "codigoprv" , "N", 03, 00, },;
                { "autoreten" , "L", 01, 00, cLogica },;
                { "exportar"  , "C", 01, 00, },;
                { "tipofac"   , "C", 10, 00, } }
   aIndice := { { "Codigo", { "codigo" } } ,;
                { "Nombre", { "nombre" } } ,;
                { "Codigo_nit", { "codigo_nit" } } }
Case cTabla == "cadcombo"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "tipo"      , "C", 10, 00, },;
                { "desplegar" , "C", 30, 00, },;
                { "retornar"  , "C", 02, 00, } }
   aIndice := { { "TipoComb", { "tipo" } } }
Case cTabla == "caddevoc"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "optica"    , "N", 02, 00, },;
                { "documen"   , "N", 10, 00, },;
                { "fechad"    , "D", 08, 00, },;
                { "consedev"  , "N", 08, 00, },;
                { "nombre"    , "C", 30, 00, },;
                { "despub"    , "N", 06, 02, } }
   aIndice := { { "Devolucion", { "optica","documen" } },;
                { "Fecha"     , { "optica","fechad" } } }
Case cTabla == "caddevod"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "optica"    , "N", 02, 00, },;
                { "documen"   , "N", 10, 00, },;
                { "fechad"    , "D", 08, 00, },;
                { "codigo"    , "C", 12, 00, },;
                { "cantidad"  , "N", 04, 00, " default 1"},;
                { "pcosto"    , "N", 10, 02, },;
                { "causadev"  , "N", 01, 00, " default 1"},;
                { "destino"   , "N", 02, 00, },;
                { "fecharep"  , "D", 08, 00, },;
                { "numrep"    , "N", 07, 00, },;
                { "facturado" , "L", 01, 00, cLogica },;
                { "secuencia" , "N", 06, 00, },;
                { "indica"    , "C", 01, 00, } }
   aIndice := { { "Devolucion", { "optica","documen" } },;
                { "Destino"   , { "destino","fechad" } } }
Case cTabla == "cadempre"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "fec_hoy"   , "D", 08, 00, },;
                { "optica"    , "N", 02, 00, },;
                { "localiz"   , "C", 03, 00, },;
                { "titular"   , "C", 03, 00, },;
                { "nit"       , "C", 14, 00, },;
                { "nombre"    , "C", 43, 00, },;
                { "enlinea"   , "L", 01, 00, cLogica },;
                { "numfacu"   , "N", 10, 00, },;
                { "numfacd"   , "N", 10, 00, },;
                { "numfacz"   , "N", 10, 00, },;
                { "nro_histor", "N", 08, 00, },;
                { "piva"      , "N", 06, 02, },;
                { "val_admon" , "N", 10, 00, },;
                { "orden_dato", "N", 02, 00, },;
                { "rsv"       , "N", 02, 00, },;
                { "cartera"   , "D", 08, 00, },;
                { "codmontura", "N", 06, 00, },;
                { "numdevol"  , "N", 10, 00, },;
                { "consedev"  , "N", 10, 00, },;
                { "numrep"    , "N", 06, 00, },;
                { "numingreso", "N", 06, 00, },;
                { "numproveed", "N", 03, 00, },;
                { "direccion" , "C", 30, 00, },;
                { "telefonos" , "C", 30, 00, },;
                { "reshabit"  , "C", 05, 00, },;
                { "facturo"   , "C", 03, 00, },;
                { "precio"    , "C", 01, 00, },;
                { "dias"      , "N", 02, 00, },;
                { "principal" , "N", 02, 00, },;
                { "dividenomb", "N", 02, 00, },;
                { "lente"     , "C", 01, 00, },;
                { "sgsss"     , "C", 10, 00, },;
                { "observa"   , "C", 90, 00, } }
   aIndice := { { "Optica", { "Optica" } } }
Case cTabla == "cadfactu"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "optica"    , "N", 02, 00, },;
                { "numfac"    , "N", 10, 00, },;
                { "tipo"      , "C", 01, 00, },;
                { "fechoy"    , "D", 08, 00, },;
                { "vendedor"  , "C", 05, 00, },;
                { "orden"     , "N", 10, 00, },;
                { "gaveta"    , "N", 03, 00, },;
                { "cliente"   , "C", 30, 00, },;
                { "direcc"    , "C", 30, 00, },;
                { "telefono"  , "C", 08, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "codigo_cli", "N", 06, 00, },;
                { "autoriza"  , "C", 10, 00, },;
                { "fechaent"  , "D", 08, 00, },;
                { "fechacan"  , "D", 08, 00, },;
                { "totaldes"  , "N", 10, 02, },;
                { "totaliva"  , "N", 10, 02, },;
                { "totalfac"  , "N", 11, 02, },;
                { "indicador" , "C", 01, 00, " default 'C'"},;
                { "valoreps"  , "N", 06, 00, },;
                { "tipofac"   , "C", 01, 00, },;
                { "remplaza"  , "N", 10, 00, },;
                { "llego"     , "L", 01, 00, } }
   aIndice := { { "Factura"  , { "optica", "numfac", "tipo" } }  ,;
                { "Fecha"    , { "optica", "fechoy", "numfac" } },;
                { "CodigoNit", { "optica", "codigo_nit", "fechoy" } },;
                { "Cliente"  , { "cliente" } },;
                { "Anuladas" , { "optica", "fechaent", "numfac" } } }
Case cTabla == "cadfactm"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "optica"    , "N", 02, 00, },;
                { "numfac"    , "N", 10, 00, },;
                { "tipo"      , "C", 01, 00, },;
                { "anomes"    , "C", 06, 00, },;
                { "saldo"     , "N", 13, 02, },;
                { "abonos"    , "N", 13, 02, },;
                { "debito"    , "N", 13, 02, } }
   aIndice := { { "Factura"  , { "optica", "numfac", "tipo", "anomes" } } }
Case cTabla == "cadinven"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "optica"    , "N", 02, 00, },;
                { "codigo"    , "C", 12, 00, },;
                { "grupo"     , "C", 01, 00, },;
                { "descrip"   , "C", 35, 00, },;
                { "codigo_nit", "N", 05, 00, },;
                { "marca"     , "N", 02, 00, },;
                { "tamano"    , "C", 06, 00, },;
                { "material"  , "C", 01, 00, },;
                { "sexo"      , "C", 01, 00, },;
                { "tipomontu" , "C", 01, 00, },;
                { "fecrecep"  , "D", 08, 00, },;
                { "fecrepos"  , "D", 08, 00, },;
                { "numrepos"  , "N", 06, 00, },;
                { "ingreso"   , "N", 05, 00, },;
                { "pcosto"    , "N", 10, 02, },;
                { "pventa"    , "N", 10, 02, },;
                { "ppubli"    , "N", 10, 02, },;
                { "pvendida"  , "N", 10, 02, },;
                { "factupro"  , "C", 06, 00, },;
                { "factuven"  , "N", 10, 00, },;
                { "fecventa"  , "D", 08, 00, },;
                { "situacion" , "C", 01, 00, },;
                { "identif"   , "C", 01, 00, },;
                { "loc_antes" , "N", 02, 00, },;
                { "indiva"    , "N", 01, 00, },;
                { "despor"    , "N", 06, 02, },;
                { "moneda"    , "C", 01, 00, },;
                { "compra_d"  , "L", 01, 00, },;
                { "paquete"   , "N", 02, 00, " default 1"} }
   aIndice := { { "Codigo", { "codigo" }, .t. },;
                { "Nombre", { "descrip" } } }
// DEFINE INDEX CODIGOPRV, DESCRIP, MATERIAL, SEXO, TAMANO TAG CodigoPrv
// DEFINE INDEX PADR(DTOS(FECRECEP)+RIGHT(CODIGO,8),16)    TAG FechaIng
Case cTabla == "cadinvme"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "optica"    , "N", 02, 00, },;
                { "anomes"    , "C", 06, 00, },;
                { "existencia", "N", 04, 00, },;
                { "codigo"    , "C", 12, 00, },;
                { "entradas"  , "N", 04, 00, },;
                { "salidas"   , "N", 04, 00, },;
                { "ajustes_e" , "N", 04, 00, },;
                { "ajustes_s" , "N", 04, 00, },;
                { "fec_ulte"  , "D", 08, 00, },;
                { "fec_ults"  , "D", 08, 00, },;
                { "devol_e"   , "N", 04, 00, },;
                { "devol_s"   , "N", 04, 00, },;
                { "devolcli"  , "N", 04, 00, },;
                { "pcosto"    , "N", 10, 02, } }
   aIndice := { { "Codigo", { "optica","codigo","anomes" } } }
Case cTabla == "cadmontd"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "ingreso"   , "N", 05, 00, },;
                { "marca"     , "C", 15, 00, },;
                { "cantidad"  , "N", 04, 00, },;
                { "refer"     , "C", 20, 00, },;
                { "material"  , "C", 01, 00, },;
                { "sexo"      , "C", 01, 00, },;
                { "tipomontu" , "C", 01, 00, },;
                { "tamano"    , "C", 06, 00, },;
                { "identif"   , "C", 01, 00, },;
                { "pcosto"    , "N", 10, 02, },;
                { "pventa"    , "N", 10, 02, },;
                { "ppubli"    , "N", 10, 02, },;
                { "consec"    , "C", 06, 00, },;
                { "secuencia" , "N", 06, 00, },;
                { "indica"    , "C", 01, 00, } }
   aIndice := { { "Ingreso", { "ingreso" } } }
Case cTabla == "cadpagos"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "optica"    , "N", 02, 00, },;
                { "numfac"    , "N", 10, 00, },;
                { "tipo"      , "C", 01, 00, },;
                { "fecpag"    , "D", 08, 00, },;
                { "abono"     , "N", 11, 02, },;
                { "pagado"    , "N", 11, 02, },;
                { "retencion" , "N", 10, 02, },;
                { "deduccion" , "N", 10, 02, },;
                { "descuento" , "N", 10, 02, },;
                { "numcheque" , "C", 16, 00, },;
                { "codbanco"  , "C", 02, 00, },;
                { "formapago" , "N", 01, 00, },;
                { "indicador" , "C", 01, 00, },;
                { "indred"    , "L", 01, 00, },;
                { "pordonde"  , "C", 01, 00, " default 'P'"} }
   aIndice := { { "Factura"  , { "optica", "numfac", "tipo" } }  ,;
                { "FechaPag" , { "optica", "fecpag", "numfac" } },;
                { "NotasDCA" , { "optica", "fecpag", "formapago" } } }
Case cTabla == "cadpreci"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "optica"    , "N", 02, 00, },;
                { "fecha"     , "D", 08, 00, },;
                { "codigo"    , "C", 12, 00, },;
                { "pcosto"    , "N", 10, 02, },;
                { "pventa"    , "N", 10, 02, },;
                { "ppubli"    , "N", 10, 02, } }
   aIndice := { { "Codigos", { "fecha","codigo" } } }
Case cTabla == "cadventa"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "optica"    , "N", 02, 00, },;
                { "numfac"    , "N", 10, 00, },;
                { "tipo"      , "C", 01, 00, },;
                { "fecfac"    , "D", 08, 00, },;
                { "codart"    , "C", 12, 00, },;
                { "descri"    , "C", 40, 00, },;
                { "cantidad"  , "N", 03, 00, },;
                { "precioven" , "N", 11, 02, },;
                { "despor"    , "N", 06, 02, },;
                { "desmon"    , "N", 10, 02, },;
                { "montoiva"  , "N", 10, 02, },;
                { "ppubli"    , "N", 10, 02, },;
                { "indicador" , "C", 01, 00, },;
                { "fecdev"    , "D", 08, 00, },;
                { "pcosto"    , "N", 10, 02, } }
   aIndice := { { "Factura"  , { "optica", "numfac", "tipo" } }  ,;
                { "FechaDev" , { "optica", "fecdev", "numfac" } } }
Case cTabla == "cadrepoc"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "optica"    , "N", 02, 00, },;
                { "numrep"    , "N", 06, 00, },;
                { "fecharep"  , "D", 08, 00, },;
                { "control"   , "N", 05, 00, },;
                { "items"     , "N", 05, 00, },;
                { "numfac"    , "N", 10, 00, },;
                { "cgeconse"  , "N", 06, 00, },;
                { "despor"    , "N", 06, 02, },;
                { "despub"    , "N", 06, 02, } }
   aIndice := { { "Nrorepos" , { "numrep" } }  ,;
                { "OpticaFe" , { "optica", "fecharep", "numrep" } },;
                { "FechaRep" , { "fecharep", "numrep" } } }
Case cTabla == "cadrepod"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "numrep"    , "N", 06, 00, },;
                { "grupo"     , "C", 01, 00, },;
                { "codigo"    , "C", 12, 00, },;
                { "cantidad"  , "N", 04, 00, " default 1"},;
                { "pcosto"    , "N", 12, 02, },;
                { "ppubli"    , "N", 12, 02, },;
                { "secuencia" , "N", 05, 00, },;
                { "indica"    , "C", 01, 00, } }
   aIndice := { { "Nrorepos" , { "numrep" } } }
Case cTabla == "menudbf"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "grupo"     , "N", 02, 00, },;
                { "Nivel"     , "N", 02, 00, },;
                { "pos"       , "N", 02, 00, },;
                { "submenu"   , "L", 01, 00, cLogica },;
                { "item"      , "C", 40, 00, },;
                { "accion"    , "C", 40, 00, },;
                { "mensaje"   , "C", 60, 00, },;
                { "prompt"    , "C", 20, 00, },;
                { "acelerador", "C", 03, 00, },;
                { "tecla"     , "C", 03, 00, } }
   aIndice := { { "Posicion", { "grupo","pos" } } }
Case cTabla == "cadlente"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 12, 00, },;
                { "tip"       , "N", 02, 00, },;
                { "esf"       , "C", 06, 00, },;
                { "cil"       , "C", 06, 00, },;
                { "adi"       , "C", 06, 00, },;
                { "cantidad"  , "N", 04, 00, },;
                { "valor"     , "N", 10, 00, } }
   aIndice := { { "Codigo", "codigo" } }
Case cTabla == "cadrcaja"
   aStruct := { { "optica"    , "N", 02, 00, },;
                { "rcaja"     , "N", 08, 00, " auto_increment" },;
                { "fecha"     , "D", 08, 00, " default NULL"},;
                { "codigo_nit", "N", 05, 00, " default NULL"},;
                { "tipo"      , "C", 01, 00, " default 'A'"},;
                { "anticipo"  , "N", 10, 02, " default NULL"},;
                { "control"   , "N", 06, 00, " default NULL"},;
                { "PRIMARY KEY (optica, rcaja)", "P",,,} }
   aIndice := { { "Fecha"     , { "optica", "fecha", "rcaja" } } }
Case cTabla == "cadsaldo"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 12, 00, },;
                { "anomes_an" , "C", 06, 00, },;
                { "existe_an" , "N", 06, 00, },;
                { "pcosto_an" , "N", 12, 02, },;
                { "anomes_ac" , "C", 06, 00, },;
                { "existe_ac" , "N", 06, 00, },;
                { "pcosto_ac" , "N", 12, 02, },;
                { "descrip"   , "C", 30, 00, },;
                { "cantidad"  , "N", 04, 00, },;
                { "entradas"  , "N", 04, 00, },;
                { "salidas"   , "N", 04, 00, },;
                { "ajustes_e" , "N", 04, 00, },;
                { "ajustes_s" , "N", 04, 00, },;
                { "devol_e"   , "N", 04, 00, },;
                { "devol_s"   , "N", 04, 00, },;
                { "devolcli"  , "N", 10, 00, } }
   aIndice := { { "Codigo", "codigo" } }
Case cTabla == "cadtalla"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "numfac"    , "N", 10, 00, },;
                { "orden"     , "N", 10, 00, },;
                { "fecfac"    , "D", 08, 00, },;
                { "consec"    , "N", 06, 00, },;
                { "fecdoc"    , "C", 11, 00, },;
                { "cantidad"  , "N", 03, 00, },;
                { "precioven" , "N", 11, 02, },;
                { "desmon"    , "N", 10, 02, },;
                { "ppubli"    , "N", 10, 02, },;
                { "servic"    , "N", 10, 02, },;
                { "cantloc"   , "N", 03, 00, },;
                { "valor"     , "N", 10, 02, },;
                { "servloc"   , "N", 10, 02, },;
                { "clase"     , "C", 02, 00, },;
                { "excedente" , "N", 10, 00, } }
   aIndice := { { "Factura", { "numfac","orden" } } }
Case cTabla == "ciudades"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "codigo"    , "C", 05, 00, },;
                { "nombre"    , "C", 30, 00, } }
   aIndice := { { "Codigo",  { "codigo" } },;
                { "Nombre",  { "nombre" } } }
Case cTabla == "contacto"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "grupo"     , "C", 01, 00, },;
                { "codigo"    , "C", 04, 00, },;
                { "nombre"    , "C", 35, 00, },;
                { "cantidad"  , "N", 05, 00, },;
                { "valor"     , "N", 13, 02, },;
                { "listo"     , "L", 01, 00, cLogica },;
                { "nombre_cla", "C", 15, 00, } }
   aIndice := { { "Codigo", { "grupo","codigo" } } }
Case cTabla == "extracto"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "numfac"    , "N", 10, 00, },;
                { "tipo"      , "C", 01, 00, },;
                { "fechoy"    , "D", 08, 00, },;
                { "cliente"   , "C", 30, 00, },;
                { "valor"     , "N", 13, 02, },;
                { "debitos"   , "N", 13, 02, },;
                { "creditos"  , "N", 13, 02, } }
   aIndice := { { "Fecha", "fechoy" } }
Case cTabla == "fisicoc"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "optica"    , "N", 02, 00, },;
                { "anomes"    , "C", 06, 00, },;
                { "vitrina"   , "C", 03, 00, },;
                { "grupo"     , "C", 01, 00, },;
                { "tvitrina"  , "N", 08, 00, } }
   aIndice := { { "Vitrina", "optica, anomes, grupo, vitrina" } }
Case cTabla == "fisicod"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "fisicoc_id", "N", 11, 00, },;
                { "codigo"    , "C", 12, 00, },;
                { "cantidad"  , "N", 05, 00, } }
   aIndice := { { "Vitrina", "fisicoc_id" } }
Case cTabla == "INVTEM"        //DBF
   aStruct := { { "OPTICA"    , "N", 02, 00 },;
                { "CODIGO"    , "C", 12, 00 },;
                { "GRUPO"     , "C", 01, 00 },;
                { "CODIGO_NIT", "N", 05, 00, },;
                { "DESCRIP"   , "C", 35, 00 },;
                { "MARCA"     , "C", 15, 00 },;
                { "TAMANO"    , "C", 06, 00 },;
                { "MATERIAL"  , "C", 01, 00 },;
                { "SEXO"      , "C", 01, 00 },;
                { "TIPOMONTU" , "C", 01, 00 },;
                { "FECRECEP"  , "D", 08, 00 },;
                { "FECREPOS"  , "D", 08, 00 },;
                { "NUMREPOS"  , "N", 06, 00 },;
                { "INGRESO"   , "N", 05, 00 },;
                { "PCOSTO"    , "N", 14, 02 },;
                { "PVENTA"    , "N", 14, 02 },;
                { "PPUBLI"    , "N", 14, 02 },;
                { "IDENTIF"   , "C", 01, 00 },;
                { "FACTUPRO"  , "C", 08, 00 },;
                { "LOC_ANTES" , "N", 02, 00 },;
                { "INDIVA"    , "N", 01, 00 },;
                { "IMPUESTO"  , "N", 06, 02 },;
                { "MONEDA"    , "C", 01, 00 },;
                { "COMPRA_D"  , "L", 01, 00 },;
                { "PAQUETE"   , "N", 02, 00 },;
                { "CANTIDAD"  , "N", 04, 00 },;
                { "SECUENCIA" , "N", 05, 00 },;
                { "INDICA"    , "C", 01, 00 },;
                { "NUMFAC"    , "N", 10, 00 },;
                { "MOV"       , "N", 01, 00 },;
                { "CONSEDEV"  , "N", 08, 00 },;
                { "CAUSADEV"  , "N", 01, 00 },;
                { "DESPOR"    , "N", 06, 02 },;
                { "DESPUB"    , "N", 06, 02 } }
Case cTabla == "CODIGOS"       //DBF
   aStruct := { { "VITRINA"   , "C", 03, 00 },;
                { "CODIGO"    , "C", 12, 00 },;
                { "VALOR"     , "C", 11, 00 } }
EndCase
/*
Case cTabla == "Usuarios"      //02
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "password"  , "C", 05, 00, },;
                { "nombre"    , "C", 30, 00, },;
                { "nivel"     , "N", 01, 00, },;
                { "cedula"    , "C", 08, 00, },;
                { "direccion" , "C", 30, 00, },;
                { "telefono"  , "C", 08, 00, } }
   aIndice := { { "Devolucion", { "password" } } }
//12
   DEFINE TABLE CADTABLA ALIAS Tab   NORECYCLE CONVERT DOS
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
      { "COSTODESDE , "N",  11,2
      { "COSTOHASTA , "N",  11,2
      { "PORCENTAJE , "N",   5,1
      { "INCREMENTO , "N",  11,2
      { "TIPO       , "C",   1
//13
   DEFINE TABLE CADTLIST ALIAS Tli   NORECYCLE CONVERT DOS
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
      { "CLASE_MATE , "C",   1
      { "TIPO_MATER , "C",   2
      { "TIPOL      , "C",   1
      { "NOMBRE     , "C",  35
      { "POR_DSCTO  , "N",   5,2
      { "TIPO_LISTA , "C",   5
      { "BIFOCAL    , "L",   1
      { "NOMCORTO   , "C",   5
      { "TIPO_TRAB  , "C",   7
      { "DIAMETRO   , "N",   4,1
      { "NOMBRE_CLA , "C",  15
      { "DESCRIP    , "C",  20
      { "VALUNIDAD  , "N",   6
      { "MAXIDIAM   , "N",   3
   DEFINE INDEX CLASE_MATE,TIPO_MATER, TIPOL TAG ClaseMate
   DEFINE INDEX TIPO_TRAB                    TAG Servicios
//14
   DEFINE TABLE CADTESFE ALIAS Esf   NORECYCLE CONVERT DOS
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
      { "RANGO      , "N",   1
      { "CONSEC     , "N",   8
      { "TERMINADO  , "C",   1
      { "ESFERA_DE  , "N",   6,2
      { "ESFERA_A   , "N",   6,2
      { "VALVENTA   , "N",   6
      { "CODIGO_DIA , "C",   4
   DEFINE INDEX CONSEC TAG Consecut
//15
   DEFINE TABLE CADTMATE ALIAS Mat   NORECYCLE CONVERT DOS
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
      { "CONSEC     , "N",   8
      { "TERMINADO  , "C",   1
      { "CLASEMAT   , "C",   1
      { "TIPOMAT    , "C",   2
      { "TIPOLISTA  , "C",   5
      { "COLORV     , "C",   2
      { "VALVENTA   , "N",   6
      { "TIPOESFE   , "C",   2
      { "DIAMETRO   , "N",   4
      { "ESFERACIL  , "N",   3
      { "ESFERAP    , "N",   3
      { "ADICION_DE , "N",   5,2
      { "ADICION_A  , "N",   5,2
   DEFINE INDEX TERMINADO, CLASEMAT, TIPOMAT, TIPOLISTA, COLORV, ;
      TIPOESFE TAG ClaseMate
//16
   DEFINE TABLE CADTCILI ALIAS Cil   NORECYCLE CONVERT DOS
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
      { "RANGO      , "N",   1
      { "CILIN_DE   , "N",   5,2
      { "CILIN_A    , "N",   5,2
      { "VALVENTA   , "N",   6
//17
   DEFINE TABLE CADTCOLO ALIAS Tco   NORECYCLE CONVERT DOS
      { "COLORV     , "C",   2
      { "NOMBRE     , "C",  10
      { "COD_COLOR  , "C",   2
   DEFINE INDEX COD_COLOR TAG CodColor
//21
Case cTabla == "cadajust"
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "optica"    , "N", 02, 00, },;
                { "numero"    , "N", 10, 00, },;
                { "fecha"     , "D", 08, 00, },;
                { "codigo"    , "C", 12, 00, },;
                { "cantidad"  , "N", 05, 00, },;
                { "tipo"      , "N", 01, 00, " default 1"},;
                { "pcosto"    , "N", 12, 02, },;
                { "pventa"    , "N", 12, 02, },;
                { "secuencia" , "N", 06, 00, },;
                { "indica"    , "C", 01, 00, } }
   aIndice := { { "Periodo", { "optica","fecha","numero" } } }
//29
Case cTabla == "historia"
   aStruct := { { "codigo_nit", "N", 11, 00, " auto_increment PRIMARY KEY" },;
                { "tipoiden"  , "C", 02, 00, " default 'CC'"},;
                { "nroiden"   , "C", 15, 00, },;
                { "apellidos" , "C", 35, 00, },;
                { "nombres"   , "C", 30, 00, },;
                { "sexo"      , "C", 01, 00, " default 'M'"},;
                { "fec_nacimi", "D", 08, 00, },;
                { "uniedad"   , "C", 01, 00, " default '1'"},;
                { "edad"      , "N", 03, 00, },;
                { "reshabit"  , "C", 05, 00, },; //{||Emp->RESHABIT}
                { "zonaresi"  , "C", 01, 00, " default 'U'"},;
                { "direccion" , "C", 40, 00, },;
                { "tel_reside", "C", 15, 00, },;
                { "tel_oficin", "C", 15, 00, },;
                { "email"     , "C", 40, 00, },;
                { "ocupacion" , "C", 03, 00, " default '999'"},;
                { "tipousua"  , "C", 01, 00, " default '5'"},;
                { "tipoafili" , "C", 01, 00, " default 'C'"},;
                { "papel"     , "N", 02, 00, },;
                { "pnomb"     , "N", 02, 00, },;
                { "optica"    , "N", 02, 00, },;
                { "exportar"  , "C", 01, 00, } }
   aIndice := { { "NroIden"  , { "nroiden" } }  ,;
                { "Apellido" , { "apellidos", "nombres" } },;
                { "Nombres"  , { "nombres", "apellidos" } } }
//31
   DEFINE TABLE RIDOCUPA ALIAS OCUPA  NORECYCLE CONVERT OEM2ANSI
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
      { "CODIGO     , "C",   3
      { "NOMBRE     , "C",  73
   DEFINE INDEX CODIGO TAG Codigo PRIMARY
   DEFINE INDEX NOMBRE TAG Nombre
//32
//02 NO PERMANECEN ABIERTOS
   DEFINE TABLE CADDEVOL ALIAS TDev  NORECYCLE CONVERT DOS
   aStruct := { { "row_id"    , "N", 11, 00, " auto_increment PRIMARY KEY" },;
      { "GRUPO      , "C",   1
      { "TIPO       , "N",   2
      { "NOMBRE     , "C",  30
      { "CANTIDAD   , "N",   6
      { "PCOSTO     , "N",  12,2
   DEFINE INDEX GRUPO, TIPO   TAG Codigo  */
If xDbf == nil
   oTb := TMSTable():Create( oApl:oMySql, cTabla, aStruct )
   FOR nI := 1 TO LEN( aIndice )
      If aIndice[nI,1] == "PrimaryKey"
         oTb:CreatePrimaryKey( aIndice[nI,2] )
      ElseIf aIndice[nI,1] == "Constraint"
         MSQuery( oApl:oMySql:hConnect,aIndice[nI,2] )
      Else
         oTb:CreateIndex( aIndice[nI,1],aIndice[nI,2], .f. )
      EndIf
   NEXT nI
   oTb:Destroy()
Else
   BorraFile( cTabla,{"DBF"} )
   dbCREATE( oApl:cRuta2+cTabla,aStruct )
EndIf
RETURN NIL