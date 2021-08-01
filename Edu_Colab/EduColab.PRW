#include'totvs.ch'
#include "RWMAKE.CH"
#include "TBICONN.CH"
#include 'Protheus.ch'
#include 'FWMVCDef.ch'
#INCLUDE "APWIZARD.CH"
#Include "SIGAWIN.ch"

#DEFINE Enter CHR(10)+CHR(13)
/*--------------------------------------------------
Assistente Para realizar um TESTE BASICO DE TOTVS COLAB 
SELECT * FROM SDS990 --CABEC
SELECT * FROM SDT990 --GRID
SELECT CKO_STATUS, * FROM CKOCOL --ARQUIVO

/{Protheus.doc}------------------------------------------------------------
    @type Function
    @author Eduardo Paro de Simoni
    @version 12
 --------------------------------------------------------------------------------
----------------------------------------------------*/
Function U_zMainColab()
    Local chTitle  := "Assistente TOTVS COLAB."	//	Titulo do cabeçalho
    Local chMsg	   := "Atenção!"                            //	Mensagem do cabeçalho
    Local cTitle   := cText:=cMsg:= ""                            //	Título do painel de apresentação//	Texto do painel de apresentação
    Local bNext    := bFinish := {||.T.}

    Private oWizard
   
    RpcSetEnv("99","01","Administrador","")
    //cModulo:=COM
    Private cPag   := Space(TamSX3('E4_CODIGO')[1])
    Private cProd  := Space(TamSX3('B1_COD')[1])
    Private cForn  := Space(TamSX3('A2_COD')[1])
    Private cLoja  := Space(TamSX3('A2_LOJA')[1])
    Private aRet	:= {cPag, cProd, cForn,cLoja,1}

    cText+="Este assistente tem como finalidade popular o ambiente para realizar um teste do TOTVS Colaboração SIGACOM."+Enter
    cText+="- Somente rodar essa aplicação em modo exclusivo!"+Enter
    cText+="- Realizar *backup* do banco de dados antes da atualização."+Enter
    cText+="- Rodar a atualização somente em base de homologação."+Enter
    cText+="- Leia com atenção as informações na próxima tela!"

    //ApWizard():New( < chTitle >  ,<chMsg>,<cTitle>,<cText>,<bNext>,<bFinish>, < lPanel > , < cResHead > , < bExecute > , < lNoFirst > , < aCoord > ) --> NIL
    oWizard := APWizard():New( chTitle, chMsg, cTitle, cText, bNext,bFinish ,,,,) 

    //PROXIMO PAINEL
    cTitle:="Informe os dados abaixo."
    cMsg:= "Informe os valores para realizar a população dos dados nas rotinas."+Enter+"Caso não possua registros no campo consulta pode informar qualquer valor que será incluso em seu ambiente"
    bBack := {||.T.}
    bNext := {|| .T.}
    bFinish:= {||.T.}
    lPanel :=.T. 
    bExecute:= {||xPanel1(@oWizard,1)}

   // NewPanel ( < cTitle > , < cMsg > , < bBack > , < bNext > , < bFinish > , < lPanel > , < bExecute > ) --> NIL
    oWizard:NewPanel(cTitle, cMsg ,bBack, bNext, bFinish,lPanel, bExecute)

    //oObj:Activate ( < lCEnter > , < bValid > , < bInit > , < bWhen > )
    oWizard:Activate(.T.,Nil,Nil,{||.T.})
Return

/*{Protheus.doc} Funcao xPanel1-------------------------------------------------------------
    @type Function
    @author Eduardo Paro de Simoni
    @version 12
 --------------------------------------------------------------------------------*/
Static Function xPanel1(oWizard,nPanel)
    Local aOpcoes	:= {}
    Local aPergs := {}

    aadd(aOpcoes, "1=XML-NFE")
    aadd(aOpcoes, "2=XML-CTE")

    aAdd(aPergs, {1, "Condicao de pagamento", cPag,  "@!", ".T.", "SE4", ".T.", 80,  .T.})
    aAdd(aPergs, {1, "Informe o Produto",  cProd    ,  "@!", ".T.", "SB1", ".T.", 80,.T.})
    aAdd(aPergs, {1, "Informe o Fornecedor", cForn,  "@!", ".T.", "SA2", ".T.", 80,  .T.})
     aAdd(aPergs, {1, "Informe a Loja", cLoja,  "@!", ".T.", "", ".T.", 40,  .T.})
    
    aAdd(aPergs, {2,"Informe o tipo do XML: ","1",aOpcoes,80,"",.T.})

    ParamBox(aPergs ,"Executar" , @aRet,,,.F.,120,3,oWizard:oMPanel[oWizard:nPanel],,.F. )

    oTButton1 := TButton():New( 100, 010, "EXECUTAR DADOS",oWizard:oMPanel[oWizard:nPanel],{|| ExecEdu(@aRet)}, 80,20,,,.F.,.T.,.F.,,.F.,,,.F. )   
    oTButton2 := TButton():New( 100, 090, "COLAUTOREAD()",oWizard:oMPanel[oWizard:nPanel],{|| COLAUTOREAD()}, 80,20,,,.F.,.T.,.F.,,.F.,,,.F. )   
    oTButton3 := TButton():New( 100, 170, "SCHEDCOMCOL()",oWizard:oMPanel[oWizard:nPanel],{|| SCHEDCOMCOL()}, 80,20,,,.F.,.T.,.F.,,.F.,,,.F. )  
Return 

/*/{Protheus.doc} Funcao ExecEdu-------------------------------------------------------------
    @type  Static Function
    @author Eduardo Paro de Simoni
    @version 12
 --------------------------------------------------------------------------------*/
Static Function ExecEdu(aRet)
    Local oColab
    Local cPag :=  PadR(aRet[1],TamSx3("E4_CODIGO")[1])
    Local cProd := PadR(aRet[2],TamSx3("B1_COD")[1])
    Local cForn := PadR(aRet[3],TamSx3("A2_COD")[1])
    Local cLoja := PadR(aRet[4],TamSx3("A2_LOJA")[1])
    Local nTPXML:= aRet[5]
    Local cCNPXML:=cIe:=cIeFor:=cCodPXml:=""
    
    if cValToChar(nTPXML) == "1"
        cCNPXML:="12884632000144"
        cIe:=""
        
        oColab := TColab():New(cCNPXML,cIe,cProd,cPag)
        oColab:incXmlNFE()
        
        cCodPXml:="43672104000155"
        cIeFor:="528016068117      " 
        
        oColab:incForn(cForn,cLoja,cCodPXml,cIeFor)
        
        cCodPXml:="2000000000964"      
        oColab:incRelF(cProd,cForn,cLoja,cCodPXml)

    else
        cCNPXML:="13455068000107"
        cIe:="22988533"
        cIeFor:="27346477"
        cCodPXml:="58890252000709" 

        oColab := TColab():New(cCNPXML,cIe,cProd,cPag)
        oColab:incXmlCTE()

        oColab:incForn(cForn,cLoja,cCodPXml,cIeFor)
        oColab:incRelF(cProd,cForn,cLoja,cCodPXml)
    ENDIF

    oColab:incProd(cProd)
   
    cFile := NomeAutoLog()
    MostraErro()

Return

/*/{Protheus.doc} Classe TColab-------------------------------------------------------------
    @type  Classe
    @author Eduardo Paro de Simoni
    @version 12
 --------------------------------------------------------------------------------*/
Class TColab
    // Declaracao das propriedades da Classe
    Data cCNPXML//:="13455068000107"
    Data cIe
    Data cIeFor
    Data cPag
    Data cProd//:="cProd"
    Data cForn//:="COLABC"
    Data cLoja
    Data cCodPXml//:="58890252000709"    

    // Declaração dos Métodos da Classe
    Method New(cCNPXML,cIe,cProd,cPag) constructor
    
    //Metodos Privados
    Private Method xEduLog(cMet,cDesc,cRet)
    Private Method incDir()
    Private Method altParam(cProd,cPag)
    Private Method altSigaMat()
    Private Method altSX2()
    
    //Metodos
    Public Method incProd(cProd)
    Public Method incForn(cForn,cLoja,cCodPXml,cIeFor)
    Public Method incRelF(cProd,cForn,cLoja,cCodPXml)
    Public Method incXmlCTE()
    Public Method incXmlNFE()

EndClass

/*--------------------------------------------------------------------------------
 Methodo New
 --------------------------------------------------------------------------------*/
Method New(cCNPXML,cIe,cProd,cPag,) Class TColab
    ::cPag:=cPag 
    
    ::incDir()
    ::altParam(cProd,cPag)
    ::altSigaMat(cCNPXML,cIe)
    ::altSX2()

Return self

/*--------------------------------------------------------------------------------
 Methodo Para montagem de Logs
 --------------------------------------------------------------------------------*/
 Method xEduLog(cMet,cDesc,cRet) Class TColab
    AutoGrLog("Metodo : "     +cMet)
    AutoGrLog("Descricao : "  +cDesc)
    AutoGrLog("Retorno : "    +cRet)
    AutoGRLog(Repl("-",80))
 Return
/*--------------------------------------------------------------------------------
 Methodo Inc Diretorios
 --------------------------------------------------------------------------------*/
 Method incDir() Class TColab as undefined
    Local cMet      :="incDir"
    Local cDesc      :="Caminho dos diretorio \importadorxml "
    Local cRet      :="Sucesso!!!"

     //Criação dos Diretórios
	If !ExistDir("\importadorxml")
        lRet:= MakeDir( "\importadorxml" )
        lRet:= MakeDir( "\importadorxml\lidos" )
        lRet:= MakeDir( "\importadorxml\inn" )
        lRet:= MakeDir( "\importadorxml\out" )
	else
        if FILE("\importadorxml\lidos\testeColab.XML")
            FErase("\importadorxml\lidos\testeColab.XML")
        ENDIF
        if FILE("\importadorxml\lidos\testeColabCTE.XML")
            FErase("\importadorxml\lidos\testeColabCTE.XML")
        ENDIF
        cRet:="Falha na inclusao dos diretorios, verifique se eles ja existem no caminho : \importadorxml"
        ::xEduLog(cMet,cDesc,cRet) 
        Return 
	endIf
    ::xEduLog(cMet,cDesc,cRet) 
Return 
/*--------------------------------------------------------------------------------
 Methodo ALTERAR SIGAMAT
 --------------------------------------------------------------------------------*/
 Method altSigaMat(cCNPXML,cIe) Class TColab
    Local cMet      :="altSigaMat"
    Local cDesc      :="Alteracao dos campos M0_CGC e M0_INSC com o valor do XML "
    Local cRet      :="Sucesso!!!"

    Local lRet      :=.T.
    //Alterar o SigaMat
    dbSelectArea( "SM0" ) 
    SM0->(dbGoTop() )
    SM0->(dbSetOrder(1)) //M0_CODIGO, M0_CODFIL, R_E_C_N_O_, D_E_L_E_T_
    lRet:=SM0->(dbSeek(FWSM0Util():GetSM0Data()[1][2] + FWFilial() ))
	
    if lRet
        RECLOCK("SM0",.F.)
            SM0->M0_CGC :=  cCNPXML
            SM0->M0_INSC := cIe  
        MSUNLOCK()
	elseIf lRet
        cRet:="Não foi possivel alterar o SIGAMAT ! "
        ::xEduLog(cMet,cDesc,cRet)
        Return
	else
        ::xEduLog(cMet,cDesc,cRet)
	endIf

 Return
/*--------------------------------------------------------------------------------
 Methodo ALTERAR SX2
 --------------------------------------------------------------------------------*/
 Method altSX2() Class TColab
    Local cMet       :="altSX2"
    Local cDesc      :="Alteracao da tabela CKO para CKOCOL "
    Local cRet       :="Sucesso!!!"

    dbSelectArea( "SX2" ) 
    SX2->(dbGoTop() )
    SX2->(dbSetOrder(1)) //X2_CHAVE, R_E_C_N_O_, D_E_L_E_T_

    IF SX2->(dbSeek("CKO"+alltrim(FWFilial()) ))
        RECLOCK("SX2",.F.)
            SX2->X2_ARQUIVO :=PadR("CKOCOL",len(SX2->X2_ARQUIVO))
        MSUNLOCK()
    elseif lRet     
        cRet:="Não foi possivel alterar a CKO990, verifique se tabela já está alterada"
         ::xEduLog(cMet,cDesc,cRet)
         Return
    endIf  
    
    ::xEduLog(cMet,cDesc,cRet)
    
Return
/*--------------------------------------------------------------------------------
 METODO ALTERAR PARAMETROS
 --------------------------------------------------------------------------------*/
Method altParam(cProd,cPag) Class TColab
    Local cMet      :="altParam"
    Local cDesc      :="Alteracao dos parametros : MV_IMPXML,MV_XMLCPCT,MV_XMLPFCT,MV_INTGFE,MV_NGINN MV_NGOUT,MV_NGLIDOS"
    Local cRet      :="Sucesso!!!"
    Local lRet      :=.T.

    lRet:=PUTMV("MV_IMPXML",.T.)
    lRet:=PUTMV("MV_XMLCPCT",cPag)//PAG
    lRet:=PUTMV("MV_XMLPFCT",cProd)//PRODUTO
    lRet:=PUTMV("MV_INTGFE",.F.)

    lRet:=PUTMV("MV_NGINN ","\importadorxml\inn")
    lRet:=PUTMV("MV_NGOUT ","\importadorxml\out")
    lRet:=PUTMV("MV_NGLIDOS ","\importadorxml\lidos")

    //Verificar se foi possivel Inc os dirtetorios
    if lRet <> .T.
         cRet :="Falha ao alterar os parametros"
         ::xEduLog(cMet,cDesc,cDesc,cRet)   
         Return lRet   
    endIf
     ::xEduLog(cMet,cDesc,cRet)    
Return lRet
/*--------------------------------------------------------------------------------
 METODO INCLUIR PRODUTO 
 --------------------------------------------------------------------------------*/
Method incProd(cProd) Class TColab
    Local cMet      :="incProd"
    Local cDesc     :="Incluir Produto - MATA010"
    Local cRet      :="Sucesso!!!"

    Local aGetArea:=GetArea()
    Local oModel := nil

    Private lMsErroAuto     := .F.
    //Private lAutoErrNoFile  := .T.

    dbSelectArea( "SB1" ) 
    SB1->(dbGoTop() )
    SB1->(dbSetOrder(1)) //B1_FILIAL, B1_COD, R_E_C_N_O_, D_E_L_E_T_
    if SB1->(dbSeek( xFilial("SB1") + PadR(cProd,TamSx3("B1_COD")[1]) ))
         cRet:="Falha na inclusao - MATA010 - Produto ja cadastrado "
         ::xEduLog(cMet,cDesc,cRet)  
        Return .F.
    endIf 

    oModel:= FwLoadModel("MATA010")
    oModel:SetOperation(3)
    oModel:Activate()
    oModel:LoadValue("SB1MASTER","B1_COD"        ,cProd)
    oModel:LoadValue("SB1MASTER","B1_DESC"       ,"TOTVS COLAB1                  ")
    oModel:LoadValue("SB1MASTER","B1_TIPO"       ,"PA")
    oModel:LoadValue("SB1MASTER","B1_UM"         ,"UN")
    oModel:LoadValue("SB1MASTER","B1_LOCPAD"     ,"01")
    oModel:LoadValue("SB1MASTER","B1_MSBLQL"     , "2" ) // bloqueado
    
    If oModel:VldData()
        oModel:CommitData()
        ::xEduLog(cMet,cDesc,cRet)  
    Else
        aLog := oModel:GetErrorMessage()               
        aEval(aLog,{|x|ConOut(x)})    

        oModel:DeActivate()
        oModel:Destroy()
        oModel:=nil
        restArea(aGetArea)
        cRet:="Falha ao incluir o produto - verifique o console"
        ::xEduLog(cMet,cDesc,cRet)  
        Return .F.                         
              
    EndIf       

    oModel:DeActivate()
    oModel:Destroy()
    oModel:=nil
    restArea(aGetArea)
Return .T.

/*----------------------------------------------------------------
Incluir o Forncedor Do XML
-------------------------------------------------------------------*/
Method incForn(cForn,cLoja,cCodPXml,cIeFor) Class TColab
    Local cMet      :="incForn"
    Local cDesc     :="Incluir ou alteracao Fornecedor - MATA020 "
    Local cRet      :="Sucesso!!!"

    Local aGetArea:=GetArea()
    Local oModel := nil
    Private lMsErroAuto     := .F.
   // Private lAutoErrNoFile  := .T.

    dbSelectArea( "SA2" ) 
    SA2->(dbGoTop() )
    SA2->(dbSetOrder(1)) //A2_FILIAL, A2_COD, A2_LOJA, R_E_C_N_O_, D_E_L_E_T_
    if SA2->(dbSeek(xFilial("SA2")+PadR(cForn,TamSx3("A2_COD")[1]) + cLoja ))
        oModel := FWLoadModel('MATA020')
        oModel:SetOperation(4)
        oModel:Activate()

        //CabeÃ§alho
        oModel:LoadValue('SA2MASTER','A2_COD'     ,SA2->A2_COD)
        oModel:LoadValue('SA2MASTER','A2_LOJA'    ,SA2->A2_LOJA)
        oModel:LoadValue('SA2MASTER','A2_NOME'    ,SA2->A2_NOME)
        oModel:LoadValue('SA2MASTER','A2_NREDUZ'  ,SA2->A2_NREDUZ)
        oModel:LoadValue('SA2MASTER','A2_END'     ,SA2->A2_END)
        oModel:LoadValue('SA2MASTER','A2_EST'     ,SA2->A2_EST)
        oModel:LoadValue('SA2MASTER','A2_MUN'     ,SA2->A2_MUN)
        oModel:LoadValue('SA2MASTER','A2_TIPO'    ,"J")
        oModel:LoadValue('SA2MASTER','A2_CGC'     ,cCodPXml)
        oModel:LoadValue('SA2MASTER','A2_INSCR'   ,cIeFor)

         If oModel:VldData()
            oModel:CommitData()
            oModel:DeActivate()
            oModel:Destroy()
            restArea(aGetArea)
             ::xEduLog(cMet,cDesc,cRet)  
            Return .T. 
        Else
            aLog := oModel:GetErrorMessage()               
            aEval(aLog,{|x|ConOut(x)})
     
            oModel:DeActivate()
            oModel:Destroy()
            restArea(aGetArea)

            cRet:="Falha na alteracao - MATA020 - Verificar - console " 
            ::xEduLog(cMet,cDesc,cRet) 
            Return .F.                         

        EndIf       
    endIf 

    oModel := FWLoadModel('MATA020')

    oModel:SetOperation(3)
    oModel:Activate()

    //CabeÃ§alho
    oModel:LoadValue('SA2MASTER','A2_COD'  ,cForn)
    oModel:LoadValue('SA2MASTER','A2_LOJA' ,cLoja)
    oModel:LoadValue('SA2MASTER','A2_NOME' ,"COLAB                                   ")
    oModel:LoadValue('SA2MASTER','A2_NREDUZ' ,"COLAB               ")
    oModel:LoadValue('SA2MASTER','A2_END' ,"COLBA                                   ")
    oModel:LoadValue('SA2MASTER','A2_EST' ,"BA")
    oModel:LoadValue('SA2MASTER','A2_MUN' ,"COLAB                                                       ")
    oModel:LoadValue('SA2MASTER','A2_TIPO' ,"J")
    oModel:LoadValue('SA2MASTER','A2_CGC' ,cCodPXml)
    oModel:LoadValue('SA2MASTER','A2_INSCR' ,cIeFor)

     If oModel:VldData()
        oModel:CommitData()
        ::xEduLog(cMet,cDesc,cRet)  
    Else
        aLog := oModel:GetErrorMessage()               
        aEval(aLog,{|x|ConOut(x)})    

        oModel:DeActivate()
        oModel:Destroy()
        restArea(aGetArea)
        cRet:="Falha na inclusao - MATA020 - Verificar - console " 
        ::xEduLog(cMet,cDesc,cRet)  
        Return .F.                         
               
    EndIf       
   
    oModel:DeActivate()
    oModel:Destroy()
    restArea(aGetArea)
    
Return .T.

/*--------------------------------------------------------------------------------
 METODO INCLUIR PRODUTO 
 --------------------------------------------------------------------------------*/
Method incRelF(cProd,cForn,cLoja,cCodPXml) Class TColab
    Local cMet      :="incRelF"
    Local cDesc     :="Incluir ou alterar relacionamento fornecedor e produto - MATA061 "
    Local cRet      :="Sucesso!!!"
    Local oModel := nil
    Private lMsErroAuto     := .F.
    //Private lAutoErrNoFile  := .T.

    dbSelectArea( "SA5" ) 
    SA5->(dbGoTop() )
    SA5->(dbSetOrder(1)) //A5_FILIAL, A5_FORNECE, A5_LOJA, A5_PRODUTO, A5_FABR, A5_FALOJA, R_E_C_N_O_, D_E_L_E_T_
    if SA5->(dbSeek(xFilial("SA5")+PadR(cForn,TamSx3("A5_FORNECE")[1]) + cLoja + PadR(cProd,TamSx3("A5_PRODUTO")[1]) ))
        oModel := FWLoadModel('MATA061') //CARREGA O MODELO DE DADOS 
    
        oModel:SetOperation(4) // SETA A OPERAÃ‡ÃƒO
        oModel:Activate() // ATIVA O MODELO DADOS

        //CabeÃ§alho
        oModel:LoadValue('MdFieldSA5','A5_PRODUTO',SA5->A5_PRODUTO )// ADICIONA NO CAMPO A5_PRODUTO O VALOR DEFINIDO EM cProd061
        oModel:LoadValue('MdFieldSA5','A5_NOMPROD',SA5->A5_NOMPROD)// ADICIONA NO CAMPO A5_NOMPROD O VALOR PRODUTO 061 CT001

        //Grid
        oModel:LoadValue('MdGridSA5','A5_FORNECE', SA5->A5_FORNECE)
        oModel:LoadValue('MdGridSA5','A5_LOJA'   , SA5->A5_LOJA)
        oModel:LoadValue('MdGridSA5','A5_CODPRF' , PadR(cCodPXml, TamSx3("A5_CODPRF")[1]))

        If oModel:VldData()
            oModel:CommitData()
            ::xEduLog(cMet,cDesc,cRet)  
            Return
        Else
            aLog := oModel:GetErrorMessage()               
            aEval(aLog,{|x|ConOut(x)})    

            oModel:DeActivate()
            oModel:Destroy()

            cRet:="Falha na alteracao - MATA061 - Verificar - console "    
            ::xEduLog(cMet,cDesc,cRet)  
            Return                     

        EndIf       

        oModel:DeActivate()
        oModel:Destroy()
    endIf 

    oModel := FWLoadModel('MATA061') //CARREGA O MODELO DE DADOS 
    
    oModel:SetOperation(3) // SETA A OPERAÃ‡ÃƒO
    oModel:Activate() // ATIVA O MODELO DADOS
    
    //CabeÃ§alho
    oModel:LoadValue('MdFieldSA5','A5_PRODUTO',PadR(cProd,TamSx3("A5_PRODUTO")[1]) )// ADICIONA NO CAMPO A5_PRODUTO O VALOR DEFINIDO EM cProd061
    oModel:LoadValue('MdFieldSA5','A5_NOMPROD',PadR('TOTVS COLAB1                  ',TamSx3("A5_NOMPROD")[1]))// ADICIONA NO CAMPO A5_NOMPROD O VALOR PRODUTO 061 CT001
    
    //Grid
    oModel:LoadValue('MdGridSA5','A5_FORNECE', PadR(cForn,TamSx3("A5_FORNECE")[1]))
    oModel:LoadValue('MdGridSA5','A5_LOJA'   , PadR(cLoja, TamSx3("A5_LOJA")[1]))
    oModel:LoadValue('MdGridSA5','A5_CODPRF' , PadR(cCodPXml, TamSx3("A5_CODPRF")[1]))
    
    If oModel:VldData()
        oModel:CommitData()
        ::xEduLog(cMet,cDesc,cRet)  
        
    Else
        aLog := oModel:GetErrorMessage()               
        aEval(aLog,{|x|ConOut(x)})    
        oModel:DeActivate()
        oModel:Destroy()
        cRet:="Falha na inclusao - MATA061 - Verificar - console "    
        ::xEduLog(cMet,cDesc,cRet)  
        Return .F.                       
               
    EndIf       

    oModel:DeActivate()
    oModel:Destroy()
    
Return .T.

/*--------------------------------------------------------------------------------
 Methodo Inc ARQUIVO
 --------------------------------------------------------------------------------*/
 Method incXmlCTE() Class TColab
    Local cMet      :="incXml"
    Local cDesc      :="Gerar arquivo \importadorxml\inn\TesteColabCTE.XML "
    Local cRet      :="Sucesso!!!"

    Local cXml:=''
    Local nHandle 
    
    cXml:='<?xml version="1.0" encoding="UTF-8"?><cteProc versao="3.00" xmlns="http://www.portalfiscal.inf.br/cte"><CTe xmlns="http://www.portalfiscal.inf.br/cte"><infCte versao="3.00"'
    cXml+=' Id="CTe29200958890252000709570100056339021682302730"><ide><cUF>29</cUF><cCT>68230273</cCT><CFOP>6353</CFOP><natOp>Prestacao de servico de transporte a estabelecimento '
    cXml+='comerc</natOp><mod>57</mod><serie>10</serie><nCT>5633902</nCT><dhEmi>2020-09-29T19:16:25-03:00</dhEmi><tpImp>1</tpImp><tpEmis>1</tpEmis><cDV>0</cDV><tpAmb>'
    cXml+='1</tpAmb><tpCTe>0</tpCTe><procEmi>0</procEmi><verProc>NDDigital CTe 4.8.5</verProc><cMunEnv>2919207</cMunEnv><xMunEnv>LAURO DE FREITAS</xMunEnv><UFEnv>BA</UFEnv><modal>01'
    cXml+='</modal><tpServ>0</tpServ><cMunIni>2930709</cMunIni><xMunIni>SIMOES FILHO</xMunIni><UFIni>BA</UFIni><cMunFim>3156700</cMunFim><xMunFim>SABARA</xMunFim><UFFim>MG</UFFim><retira>1</retira><indIEToma>1'
    cXml+='</indIEToma><toma3><toma>0</toma></toma3></ide><compl><ObsCont xCampo="TEXTO_ADICIONAL_DHL2"><xTexto>Transporte referente ao WB 6823027326. Lei n12741/2012- O valor aproximado de tributos incidentes '
    cXml+='sobre o preco deste servico e de R$ 13.67</xTexto></ObsCont><ObsCont xCampo="DATA_WB"><xTexto>2020-09-2900:00:00</xTexto></ObsCont><ObsCont xCampo="FILIAL_ORIGEM"><xTexto>SSA</xTexto></ObsCont><ObsCont '
    cXml+='xCampo="FILIAL_DESTINO"><xTexto>BHZ</xTexto></ObsCont><ObsCont xCampo="PIDS"><xTexto>1209568811</xTexto></ObsCont><ObsCont xCampo="CONTA"><xTexto>655958314</xTexto></ObsCont><ObsCont xCampo="WB">'
    cXml+='<xTexto>6823027326</xTexto></ObsCont></compl><emit><CNPJ>58890252000709</CNPJ><IE>27346477</IE><xNome>DHL EXPRESS (BRASIL) LTDA</xNome><xFant>DHL EXPRESS (BRASIL)</xFant><enderEmit><xLgr>Doutor Barreto'
    cXml+='</xLgr><nro>483</nro><xCpl>Lauro de Freitas</xCpl><xBairro>Lauro de Freitas</xBairro><cMun>2919207</cMun><xMun>LAURO DE FREITAS</xMun><CEP>42700000</CEP><UF>BA</UF></enderEmit></emit><rem><CNPJ>13455068000107'
    cXml+='</CNPJ><IE>22988533</IE><xNome>DURIT BRASIL LTDA</xNome><xFant>DURIT</xFant><fone>7121069544</fone><enderReme><xLgr>VIA DE PENETRACAO III</xLgr><nro>519</nro><xBairro>SIMOES FILHO</xBairro><cMun>2930709</cMun>'
    cXml+='<xMun>SIMOES FILHO</xMun><CEP>43700000</CEP><UF>BA</UF><cPais>1058</cPais><xPais>BRASIL</xPais></enderReme><email>COMERCIAL@DURIT.COM.BR</email></rem><dest><CNPJ>17469701003273</CNPJ><IE>5670940070729</IE>'
    cXml+='<xNome>ARCELOR MITTAL BRASIL SA</xNome><fone>3136791286</fone><enderDest><xLgr>RUA DA PONTE NUMERO 12 F</xLgr><nro>12</nro><xCpl>LOTE F</xCpl><xBairro>SABARA</xBairro><cMun>3156700</cMun><xMun>SABARA</xMun>'
    cXml+='<CEP>34515190</CEP><UF>MG</UF><cPais>1058</cPais><xPais>BRASIL</xPais></enderDest></dest><vPrest><vTPrest>113.93</vTPrest><vRec>113.93</vRec></vPrest><imp><ICMS><ICMS00><CST>00</CST><vBC>113.93</vBC><pICMS>'
    cXml+='12.00</pICMS><vICMS>13.67</vICMS></ICMS00></ICMS><vTotTrib>13.67</vTotTrib></imp><infCTeNorm><infCarga><vCarga>798.38</vCarga><proPred>PECAS EM METAL DURO</proPred><infQ><cUnid>03</cUnid><tpMed>ITENS</tpMed>'
    cXml+='<qCarga>1.0000</qCarga></infQ><infQ><cUnid>01</cUnid><tpMed>PESO BRUTO</tpMed><qCarga>2.9600</qCarga></infQ></infCarga><infDoc><infNFe><chave>29200913455068000107550010000471661100061148</chave></infNFe>'
    cXml+='</infDoc><infModal versaoModal="3.00"><rodo><RNTRC>03947773</RNTRC><occ><nOcc>27326</nOcc><dEmi>2020-09-29</dEmi><emiOcc><CNPJ>58890252000709</CNPJ><cInt>6823027326</cInt><IE>27346477</IE><UF>BA</UF>'
    cXml+='</emiOcc></occ></rodo></infModal></infCTeNorm></infCte><infCTeSupl><qrCodCTe>https://dfe-portal.svrs.rs.gov.br/cte/qrCode?chCTe=29200958890252000709570100056339021682302730&amp;tpAmb=1</qrCodCTe>'
    cXml+='</infCTeSupl><Signature xmlns="http://www.w3.org/2000/09/xmldsig#"><SignedInfo><CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" />'
    cXml+='<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1" /><Reference URI="#CTe29200958890252000709570100056339021682302730"><Transforms>'
    cXml+='<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature" /><Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" />'
    cXml+='</Transforms><DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1" /><DigestValue>HzpvsG2/xRQ9/QFTYpe4UUumuhk=</DigestValue></Reference></SignedInfo>'
    cXml+='<SignatureValue>CN2Scuad92q+nopA6vLkLatRk3FKWpH6l2v68jVT/2d1hevW+IPjZm3Og+uB36v6FQzl84BKDHd7IPBeDPtovSNWOlS4aKGFcpBDLmNean33WKOz/tMQLjhaRZyyU7iSyGxQMztPOrkf708/Bpjpuhu5Q+Al/d2Ev3CWQ3IHTwNcq7uinFClmK08YIYa2AWi/'
    cXml+='xNwRW76V6o+lgGBJeKEog7EPGBj+K5FU/Y13Cu8v5+8qr8mjJZlj5LoMqKPVNr1tM2MJJbyVep9Cu7eREbGWm7bEgtjFtIlRiQTwfQrTWa0PcYCk6RfFyR2SOM/43bpVgTtIRANquPZY0qUvUaM5g==</SignatureValue><KeyInfo><X509Data>'
    cXml+='<X509Certificate>MIIHpTCCBY2gAwIBAgIIMC2yAYf6nh0wDQYJKoZIhvcNAQELBQAwTDELMAkGA1UEBhMCQlIxEzARBgNVBAoMCklDUC1CcmFzaWwxKDAmBgNVBAMMH1NFUkFTQSBDZXJ0aWZpY2Fkb3JhIERpZ2l0YWwgdjUwHhcNMjAwMjEyMTQwOTAwWhcNM'
    cXml+='jEwMjExMTQwOTAwWjCB+zELMAkGA1UEBhMCQlIxEzARBgNVBAoMCklDUC1CcmFzaWwxFDASBgNVBAsMCyhFTSBCUkFOQ08pMRgwFgYDVQQLDA8wMDAwMDEwMDk0NTY0ODYxFDASBgNVBAsMCyhFTSBCUkFOQ08pMRQwEgYDVQQLDAsoRU0gQlJBTkNPKTEoMCYGA1'
    cXml+='UECwwfU0VSQVNBIENlcnRpZmljYWRvcmEgRGlnaXRhbCB2NTEXMBUGA1UECwwONjIxNzM2MjAwMDAxODAxFDASBgNVBAsMCyhFTSBCUkFOQ08pMSIwIAYDVQQDDBlESEwgRVhQUkVTUyAoQlJBWklMKSBMVERBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgK'
    cXml+='CAQEA1ytSxS7m2IiXepQqgvBtHnnsDdoxN3J2vZTBZwbFUgsCYjsRmeS8DMeGyYxp+9bUURMbHN4syMR94rjpZlkVgvNdGt+tLxuiDlmu/U///BXNgPTYUu2qU8gA01iwmSaDKhOCg9xFmXvsS10vSu/tc+k4hMHcznJlM6vpfrjyia6bR//rNLYQTc9qVMLIkvgN'
    cXml+='tR84vE1szt+IrwOvCkPIPQkwKWcTXgPJv6Yp06IPR8e30CPwlgiEVpeoQGxN8kc7elyjeKePhnIThhXcMHls9rcep2MLBNWW2qD3CQzAvYo0o1lrqUnUvqLYgpLyCnWmhMWX4PuPDS/Cr+VOnREYRQIDAQABo4IC2TCCAtUwHwYDVR0jBBgwFoAUVnWvSnOy2AjEf'
    cXml+='ftsKBwR1ffBqMwwgZcGCCsGAQUFBwEBBIGKMIGHMEcGCCsGAQUFBzAChjtodHRwOi8vd3d3LmNlcnRpZmljYWRvZGlnaXRhbC5jb20uYnIvY2FkZWlhcy9zZXJhc2FjZHY1LnA3YjA8BggrBgEFBQcwAYYwaHR0cDovL29jc3AuY2VydGlmaWNhZG9kaWdpdGFsLm'
    cXml+='NvbS5ici9zZXJhc2FjZHY1MIG4BgNVHREEgbAwga2BEUZJU0NBTC5CUkBESEwuQ09NoD4GBWBMAQMEoDUTMzE3MDUxOTc0MjYwODA3MjU4NTEwMDAwMDAwMDAwMDAwMDAwMDAyNDc1ODg0NFNTUCBTUKAkBgVgTAEDAqAbExlNSVJFTEUgR1JJRVNJVVMgTUFVVFND'
    cXml+='SEtFoBkGBWBMAQMDoBATDjU4ODkwMjUyMDAwMTEzoBcGBWBMAQMHoA4TDDAwMDAwMDAwMDAwMDBxBgNVHSAEajBoMGYGBmBMAQIBBjBcMFoGCCsGAQUFBwIBFk5odHRwOi8vcHVibGljYWNhby5jZXJ0aWZpY2Fkb2RpZ2l0YWwuY29tLmJyL3JlcG9zaXRvcmlvL2'
    cXml+='RwYy9kZWNsYXJhY2FvLXNjZC5wZGYwHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMEMIGbBgNVHR8EgZMwgZAwSaBHoEWGQ2h0dHA6Ly93d3cuY2VydGlmaWNhZG9kaWdpdGFsLmNvbS5ici9yZXBvc2l0b3Jpby9sY3Ivc2VyYXNhY2R2NS5jcmwwQ6BBoD'
    cXml+='+GPWh0dHA6Ly9sY3IuY2VydGlmaWNhZG9zLmNvbS5ici9yZXBvc2l0b3Jpby9sY3Ivc2VyYXNhY2R2NS5jcmwwHQYDVR0OBBYEFIbP81CKrxeyrNQbqyWrdAX5sqgvMA4GA1UdDwEB/wQEAwIF4DANBgkqhkiG9w0BAQsFAAOCAgEAF82euL5DIWHFy61ByF6bjJ'
    cXml+='PAXy9TIUIHKtVE0nWd1lE6EGLl01H4yBRypE1hDcasuSp0B7bv1vlX9aq95Op9+vbDLmRPWidIwnJ/S69Nqx7tq2AAoT0vGTO5TzKVfwvtGEeOnVQeu6ha1akh358+4LHdd2gHgEXEQVFtoGdBzAhI/lO24fzTP1QnDacwk4ZyThijlCtXaPd1kN30riNLqX7Vqf'
    cXml+='ZliBwRsVAHFf1LGok6bRy9aAo1Xei1+dtIxUByc+Z8VJPxS0Sicyj0Yzy0tqL9MidLI2Yp0OF2P+r6rediwcT+abkMljiyUtj0LiYenE5vrUfkL6uALokK7j4YZ6VM/LHVyLvKspBX0DtVM+ZTay17t6xX029fLXSh5G2jLKJ0pbx5Bskn6fIp9WAs6b+iD5Fdpn'
    cXml+='Twqm9TyOMduwTGXysRejjRFv+cQVC44uKjqWF9bt5xnb6NsfdcM6v/LYhRfXybfwJ1YufSRro/Ko1sl9fYI1WSUrTfurDf5T2Bps0tGDWao6WtI6wQPDA69OmslOIffYjOPevfn0wD3IChzUD75in6v5RzAr5hcli/qLnk3l24oJQ8ExnN/vqfh0qONYGjrISzoD'
    cXml+='eNHB/Frx9vLenfNxMJYIX4est7QIGssNAQo0gXIL/sYZpZjT/oqUtCigMQM2kBlB0ELNJSd0I=</X509Certificate></X509Data></KeyInfo></Signature></CTe><protCTe versao="3.00"><infProt Id="CTe329200032243249">  <tpAmb>'
    cXml+='1</tpAmb>  <verAplic>RS20200915181434</verAplic>  <chCTe>29200958890252000709570100056339021682302730</chCTe>  <dhRecbto>2020-09-29T19:16:28-03:00</dhRecbto>  <nProt>329200032243249</nProt>  '
    cXml+='<digVal>HzpvsG2/xRQ9/QFTYpe4UUumuhk=</digVal>  <cStat>100</cStat>  <xMotivo>Autorizado o uso do CT-e</xMotivo></infProt></protCTe></cteProc>'

    //Criação do Arquivo
    nHandle := FCREATE("\importadorxml\inn\TesteColabCTE.XML")
  
    if nHandle = -1
        cRet:="Erro ao Inc arquivo - ferror " + Str(Ferror())
        ::xEduLog(cMet,cDesc,cRet)  
        Return .F.
    else
        FWrite(nHandle,cXml )
        FClose(nHandle)
        ::xEduLog(cMet,cDesc,cRet)  
    endif

Return
/*--------------------------------------------------------------------------------
 Methodo Inc ARQUIVO
 --------------------------------------------------------------------------------*/
 Method incXmlNFE() Class TColab
    Local cMet      :="incXmlNFE"
    Local cDesc      :="Gerar arquivo \importadorxml\inn\TesteColabCTE.XML "
    Local cRet      :="Sucesso!!!"
    Local cXml:=''
    Local nHandle 

    cXml+='<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="4.00">'
    cXml+='<NFe xmlns="http://www.portalfiscal.inf.br/nfe">'
    cXml+='<infNFe Id="NFe35200343672104000155550030000005831285637105" versao="4.00">'
    cXml+='<ide>'
    cXml+='<cUF>35</cUF>'
    cXml+='<cNF>28563710</cNF>'
    cXml+='<natOp>Venda Dentro do Estado</natOp>'
    cXml+='<mod>55</mod>'
    cXml+='<serie>3</serie>'
    cXml+='<nNF>583</nNF>'
    cXml+='<dhEmi>2020-03-30T16:00:54-03:00</dhEmi>'
    cXml+='<tpNF>1</tpNF>'
    cXml+='<idDest>1</idDest>'
    cXml+='<cMunFG>3538006</cMunFG>'
    cXml+='<tpImp>1</tpImp>'
    cXml+='<tpEmis>1</tpEmis>'
    cXml+='<cDV>5</cDV>'
    cXml+='<tpAmb>1</tpAmb>'
    cXml+='<finNFe>1</finNFe>'
    cXml+='<indFinal>0</indFinal>'
    cXml+='<indPres>0</indPres>'
    cXml+='<procEmi>0</procEmi>'
    cXml+='<verProc>1.00</verProc>'
    cXml+='</ide>'
    cXml+='<emit>'
    cXml+='<CNPJ>43672104000155</CNPJ>'
    cXml+='<xNome>R E FONSECA LTDA ME</xNome>'
    cXml+='<enderEmit>'
    cXml+='<xLgr>R JOSE TEBERGA</xLgr>'
    cXml+='<nro>678</nro>'
    cXml+='<xBairro>MOREIRA CESAR</xBairro>'
    cXml+='<cMun>3538006</cMun>'
    cXml+='<xMun>PINDAMONHANGABA</xMun>'
    cXml+='<UF>SP</UF>'
    cXml+='<CEP>12440060</CEP>'
    cXml+='<cPais>1058</cPais>'
    cXml+='<fone>1236412181</fone>'
    cXml+='</enderEmit>'
    cXml+='<IE>528016068117</IE>'
    cXml+='<CRT>1</CRT>'
    cXml+='</emit>'
    cXml+='<dest>'
    cXml+='<CNPJ>12884632000144</CNPJ>'
    cXml+='<xNome>GV DO BRASIL IND E COMERCIO DE ACO LTDA</xNome>'
    cXml+='<enderDest>'
    cXml+='<xLgr>Rodovia Vereador Abel Fabricio Dias</xLgr>'
    cXml+='<nro>SN</nro>'
    cXml+='<xBairro>Vila Sao Benedito</xBairro>'
    cXml+='<cMun>3538006</cMun>'
    cXml+='<xMun>Pindamonhangaba</xMun>'
    cXml+='<UF>SP</UF>'
    cXml+='<CEP>12445010</CEP>'
    cXml+='<cPais>1058</cPais>'
    cXml+='<fone>1236441910</fone>'
    cXml+='</enderDest>'
    cXml+='<indIEDest>1</indIEDest>'
    cXml+='<IE>528066809113</IE>'
    cXml+='<email>nfe@gruposimec.com.br</email>'
    cXml+='</dest>'
    cXml+='<autXML>'
    cXml+='<CNPJ>13998916000124</CNPJ>'
    cXml+='</autXML>'
    cXml+='<det nItem="1">'
    cXml+='<prod>'
    cXml+='<cProd>2000000000964</cProd>'
    cXml+='<cEAN>SEM GTIN</cEAN>'
    cXml+='<xProd>PEDRISCO BRITA 0 - METRO</xProd>'
    cXml+='<NCM>25171000</NCM>'
    cXml+='<CFOP>5405</CFOP>'
    cXml+='<uCom>UN</uCom>'
    cXml+='<qCom>5.0000</qCom>'
    cXml+='<vUnCom>156.0000</vUnCom>'
    cXml+='<vProd>780.00</vProd>'
    cXml+='<cEANTrib>SEM GTIN</cEANTrib>'
    cXml+='<uTrib>UN</uTrib>'
    cXml+='<qTrib>5.0000</qTrib>'
    cXml+='<vUnTrib>156.0000</vUnTrib>'
    cXml+='<indTot>1</indTot>'
    cXml+='</prod>'
    cXml+='<imposto>'
    cXml+='<vTotTrib>32.76</vTotTrib>'
    cXml+='<ICMS>'
    cXml+='<ICMSSN102>'
    cXml+='<orig>0</orig>'
    cXml+='<CSOSN>102</CSOSN>'
    cXml+='</ICMSSN102>'
    cXml+='</ICMS>'
    cXml+='<PIS>'
    cXml+='<PISOutr>'
    cXml+='<CST>49</CST>'
    cXml+='<vBC>0.00</vBC>'
    cXml+='<pPIS>0.00</pPIS>'
    cXml+='<vPIS>0.00</vPIS>'
    cXml+='</PISOutr>'
    cXml+='</PIS>'
    cXml+='<COFINS>'
    cXml+='<COFINSOutr>'
    cXml+='<CST>49</CST>'
    cXml+='<vBC>0.00</vBC>'
    cXml+='<pCOFINS>0.00</pCOFINS>'
    cXml+='<vCOFINS>0.00</vCOFINS>'
    cXml+='</COFINSOutr>'
    cXml+='</COFINS>'
    cXml+='</imposto>'
    cXml+='</det>'
    cXml+='<total>'
    cXml+='<ICMSTot>'
    cXml+='<vBC>0.00</vBC>'
    cXml+='<vICMS>0.00</vICMS>'
    cXml+='<vICMSDeson>0.00</vICMSDeson>'
    cXml+='<vFCPUFDest>0.00</vFCPUFDest>'
    cXml+='<vICMSUFDest>0.00</vICMSUFDest>'
    cXml+='<vICMSUFRemet>0.00</vICMSUFRemet>'
    cXml+='<vFCP>0.00</vFCP>'
    cXml+='<vBCST>0.00</vBCST>'
    cXml+='<vST>0.00</vST>'
    cXml+='<vFCPST>0.00</vFCPST>'
    cXml+='<vFCPSTRet>0.00</vFCPSTRet>'
    cXml+='<vProd>780.00</vProd>'
    cXml+='<vFrete>0.00</vFrete>'
    cXml+='<vSeg>0.00</vSeg>'
    cXml+='<vDesc>0.00</vDesc>'
    cXml+='<vII>0.00</vII>'
    cXml+='<vIPI>0.00</vIPI>'
    cXml+='<vIPIDevol>0.00</vIPIDevol>'
    cXml+='<vPIS>0.00</vPIS>'
    cXml+='<vCOFINS>0.00</vCOFINS>'
    cXml+='<vOutro>0.00</vOutro>'
    cXml+='<vNF>780.00</vNF>'
    cXml+='<vTotTrib>32.76</vTotTrib>'
    cXml+='</ICMSTot>'
    cXml+='</total>'
    cXml+='<transp>'
    cXml+='<modFrete>1</modFrete>'
    cXml+='</transp>'
    cXml+='<cobr>'
    cXml+='<fat>'
    cXml+='<nFat>598</nFat>'
    cXml+='<vOrig>780.00</vOrig>'
    cXml+='<vDesc>0.00</vDesc>'
    cXml+='<vLiq>780.00</vLiq>'
    cXml+='</fat>'
    cXml+='<dup>'
    cXml+='<nDup>001</nDup>'
    cXml+='<dVenc>2020-04-28</dVenc>'
    cXml+='<vDup>780.00</vDup>'
    cXml+='</dup>'
    cXml+='</cobr>'
    cXml+='<pag>'
    cXml+='<detPag>'
    cXml+='<indPag>1</indPag>'
    cXml+='<tPag>99</tPag>'
    cXml+='<vPag>780.00</vPag>'
    cXml+='</detPag>'
    cXml+='</pag>'
    cXml+='<infAdic>'
    cXml+='<infCpl>*** PEDIDO GV 031438 (PARCIAL) *** DOCUMENTO EMITIDO POR ME OU EPP OPTANTE PELO SIMPLES NACIONALNAO GERA DIREITO A CREDITO FISCAL DE ICMS, ISS E IPI. (Emitido atraves do MarketUp.)</infCpl>''
    cXml+='</infAdic>'
    cXml+='<infRespTec>'
    cXml+='<CNPJ>13998916000124</CNPJ>'
    cXml+='<xContato>Alexandre Klemar Parpinelli</xContato>'
    cXml+='<email>ti@marketup.com</email>'
    cXml+='<fone>1147807420</fone>'
    cXml+='</infRespTec>'
    cXml+='</infNFe>'
    cXml+='<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">'
    cXml+='<SignedInfo>'
    cXml+='<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>'
    cXml+='<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>'
    cXml+='<Reference URI="#NFe35200343672104000155550030000005831285637105">'
    cXml+='<Transforms>'
    cXml+='<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>'
    cXml+='<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>'
    cXml+='</Transforms>'
    cXml+='<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>'
    cXml+='<DigestValue>1wQKH47NMuO5awjZgeeFEMorClk=</DigestValue>'
    cXml+='</Reference>'
    cXml+='</SignedInfo>'
    cXml+='<SignatureValue>BZOQlpSJCOFuqnAXDN7TF9Q+kFiLJgZnN/aIJVyJu+pojXRifuYi75KRbGl5Xh2ywrMqN4wjBhJNBX1upBGAg4dQyD+BDzzxmikqxgjbevl8r+K8tLdxeiCOg0DduaPURm/qaglF9+aEMfkSJR8jV0LzM5I7SrpqOeLI0ipdam9S9Il/xQPCEy/PLrbkzyhf7nUFpM1bY9NqTNbptKJlEOmWXYMVvkZvIYY1ZUJIJc/+3wNHSbDt0Iqv/9ybJvvf7c5wEbZ/b4uNWsfDnfgnTg9GrAbGPbOsFLzjatdrlL4NrscZegujc45NCprmH011FUENIDwir+g4mTZ7ksX40w==</SignatureValue>'
    cXml+='<KeyInfo>'
    cXml+='<X509Data>'
    cXml+='<X509Certificate>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</X509Certificate>'
    cXml+='</X509Data>'
    cXml+='</KeyInfo>'
    cXml+='</Signature>'
    cXml+='</NFe>'
    cXml+='<protNFe versao="4.00">'
    cXml+='<infProt Id="Id135200256599594">'
    cXml+='<tpAmb>1</tpAmb>'
    cXml+='<verAplic>SP_NFE_PL009_V4</verAplic>'
    cXml+='<chNFe>35200343672104000155550030000005831285637105</chNFe>'
    cXml+='<dhRecbto>2020-03-30T16:00:56-03:00</dhRecbto>'
    cXml+='<nProt>135200256599594</nProt>'
    cXml+='<digVal>1wQKH47NMuO5awjZgeeFEMorClk=</digVal>'
    cXml+='<cStat>100</cStat>'
    cXml+='<xMotivo>Autorizado o uso da NF-e</xMotivo>'
    cXml+='</infProt>'
    cXml+='</protNFe>'
    cXml+='</nfeProc>'

    //Criação do Arquivo
    nHandle := FCREATE("\importadorxml\inn\TesteColab.XML")
  
    if nHandle = -1
        cRet:="Erro ao criar arquivo - ferror " + Str(Ferror())
        ::xEduLog(cMet,cDesc,cRet)  
        
    else
        FWrite(nHandle,cXml )
        FClose(nHandle)
        ::xEduLog(cMet,cDesc,cRet)  
        
    endif

Return 
