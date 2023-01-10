<%--
    # PAGINE DI MOOVI DA 1.0000 A 2.9999
        #1.0000 HEADER 
        #1.0010 pgHome        
        #1.0020 pgSottoMenu   
        #1.0030 pgDocAperti   
        #1.0040 pgDocRistampa (RISTAMPA DOC ESISTENTE)
        #1.0050 pgAvviaConsumo
        #1.0060 pgRL (TESTA DOC)
        #1.0070 pgDOPrelievi (PRELIEVI DI UNA DOTes)
        #1.0080 pgPrelievi (TUTTI I DOC PRELEVABILI)
        #1.0090 pgRLRig (RIGHE DOC)
        #1.0095 pgRLPK (PACK LIST)
        #1.0096 pgRLPrelievo (Prelievo del documento)
        #1.0100 pgRLPiede (PIEDE DEL DOCUMENTO)
        #1.0110 pgStampaDocumento (STAMPA DOC CREATO)
        #1.0110 pgTRAperti (TRASFERIMENTI APERTI)   --> Da aggiungere
        #1.0120 pgTR (TESTA DEI TRASFERIMENTI)
        #1.0130 pgTRRig_P (PARTENZA)
        #1.0140 pgTRRig_A (ARRIVO)
        #1.0150 pgTRPiede (PIEDE DEI TRASFERIMENTI)
        #1.0160 pgINAperti      
        #1.0170 pgIN (TESTA INVENTARIO)
        #1.0180 pgINRig (RIGHE INVENTARIO)
        #1.0190 pgINPiede (PIEDE INVENTARIO)
        #1.0195 pgINPuntuale
        #1.0200 pgSP (SPEDIZIONE)
        #1.0210 pgLog
        #1.0220 pgAA (ACQUISIZIONE ALIAS)
        #1.0230 pgMGDisp (Interrogazione magazzini)
        #1.0240 pgSM
        #1.0250 pgSMLoad
        #1.0260 pgSMRig
        #1.0270 pgSMRig_T
        #1.0280 pgSMPiede (PIEDE DELLO STOCCAGGIO)
        #1.0300 pgPRTRAttivita Produzione Avanzata - pagina select delle attività a cui trasferire le bolle
        #1.0310 pgPRTRMateriale Produzione Avanzata - pagina trasferimento materiale
        #1.0320 pgPRMPMateriale Produzione Avanzata - pagina rientro materiale
        **PERS**
        #2.999 pgxListaCarico

    # RICERCHE MOOVI DA 3 A 3.99
        #3.00 SearchAR
        #3.01 SearchARLotto
        #3.02 SearchCF
        #3.03 SearchCFDest
        #3.04 SearchMG
        #3.05 SearchMGUbicazione
        #3.06 SearchDOSottoCommessa
        #3.07 SearchDOCaricatore
        #3.08 SearchxMOCodSpe
        #3.09 SearchARARMisura
        **PERS**
        #3.99 SearchxListaCarico
    
    # DETAIL MOOVI DA 4 A 4.99
        #4.00 DetailCF
        #4.01 DetailCFDest
        #4.02 DetailARGiacenza
        #4.03 DetailBarcode
        #4.04 DetailDO
        #4.05 Detail_Letture
        #4.06 Detail_PackingList
        #4.07 Detail_MultiBarcode
        #4.08 Detail_SMDocs
        #4.09 DetailUBIGiacenza
        #4.10 Detail_NotePiede

    # POPUP DA 5 A 5.99
        #5.00 PopupMsg
        #5.01 Popup_DocAperti_Del (CONFERMA ELIMINAZIONE DOCUMENTO APERTO)
        #5.02 Popup_Del_Lettura (CONFERMA ELIMINAZIONE LETTURA)
        #5.03 Popup_Delete_Last_Read (CONFERMA ELIMINAZIONE DELL'ULTIMA LETTURA)       
        #5.04 Popup_Button_OpConfirm (RICHIESTA CONFERMA DELL'OPERATORE PER I CONTROLLI DAL BOTTONE CONFERMA DELLA PG)
        #5.05 Popup_Sscc_OpConfirm (RICHIESTA CONFERMA DELL'OPERATORE PER I CONTROLLI)
        #5.06 Popup_PackList_New (AGGIUNGE UNA NUOVA UNITA' LOGICA ALLA PACKING LIST) 
        #5.07 Popup_PKListAR_DelShift (ELIMINA O SPOSTA UN ARTICOLO DELLA PACKING)
        #5.08 Popup_INAperti_Del (CONFERMA ELIMINAZIONE INVENTARIO APERTO) 
        #5.09 Popup_ARAlias_Insert (RICHIESTA DI APERTURA PAGINA PER INSERIMENTO ALIAS)
        #5.10 Popup_TRAperti_Del (CONFERMA ELIMINAZIONE DEL TRASFERIMENTO APERTO)
        #5.11 Popup_SMRig_Del (CONFERMA ELIMINAZIONE DELLE RIGHE STOCCATE)
        #5.12 Popup_UserPref (elenco preferenze utente)
        #5.70 Popup_BC_Select 
--%>

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Moovi.aspx.cs" Inherits="MooviWeb.Moovi" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="icon" href="image/moovi.ico" type="image/ico" sizes="16x16" />
    <!-- Script statici -->
    <script src="js/jquery-3.2.0.min.js"></script>
    <script src="js/injector.js"></script>
    <link href="style/w3.css" rel="stylesheet" />
    <link href="font-awesome/css/all.min.css" rel="stylesheet" />
    <link href="style/Style.css" rel="stylesheet" />
    <link href="style/MediaQuery.css" rel="stylesheet" />
    <link href="style/icon-library.css" rel="stylesheet" />
    <!-- Cache Busting -->
    <script>
        // CSS
        var styles = [/*"style/w3.css", "style/Style.css", "style/MediaQuery.css", "style/icon-library.css",*/ "style/pgMGDisp.css", "style/Detail_PackingList.css"];
        styles.forEach(function (item) { injectStyle(item); });
        // Scripts
        var scripts = ["js/ajax.js", "js/settings.js", "js/Global.js", "js/Barcode.js", "js/BarcodeHelper.js", "js/MooviBarcode.js", "js/Moovi.js", "js/MediaQuery.js", "js/IN.js"];
        scripts.forEach(function (item) { injectScript(item); });
    </script>

    <title>MOOVI</title>
    <script>

        window.addEventListener("load", function () {

            Init();

            //Rivisualizzo il BODY
            $("body").removeClass("w3-hide");

        });

    </script>
</head>
<body class="w3-hide">

    <%-- #1.0000 HEADER --%>
    <div id="header" class="mo-header mo-darkblue">
        <div class="w3-row">
            <%-- bottone per home page --%>
            <div class="c1 mo-display-inlineblock w3-left" style="width: 33.33%;">
                <label class="mo-btn-home mo-title mo-pointer w3-center w3-text-white w3-margin-left">MOOVI</label>
            </div>
            <%--    <%-- Spazio per le info di navigazione 
            <div class="info c2 mo-display-inlineblock w3-center mo-pt-8" style="width: 23.33%;">
            </div>--%>
            <%-- frecce per spostamento tra le pagine --%>
            <div class="c3 mo-display-inlineblock w3-right mo-pt-8" style="width: 63.33%;">
                <i class="nav-next mi darkblue s38 s32small mo-pointer mo-display-inlineblock w3-right w3-margin-right w3-circle w3-white" onclick="Nav.Next();">keyboard_arrow_right</i>
                <i class="nav-back mi darkblue s38 s32small mo-pointer mo-display-inlineblock w3-right w3-margin-right w3-circle w3-white" onclick="Nav.Back();">keyboard_arrow_left</i>
                <i class="nav-keybhide mi white s38 s32small mo-pointer mo-display-inlineblock w3-right w3-margin-right " onclick="Nav.Keybhide();">keyboard_hide</i>
                <i data-key="settings" class="settings-modal-btn mi s38 s32small white mo-pointer mo-display-inlineblock w3-right w3-margin-right" onclick="UserPref_Load();">settings</i>
            </div>
        </div>
    </div>

    <%-- #1.0010 pgHome --%>
    <div id="pgHome" class="mo-page">
        <ul id="ulMenu" class="w3-ul w3-card-4 mo-menu">
            <li id="menu-ca" class="menu menu-principale w3-hover-light-gray w3-padding-8">
                <i class="mi s35 mo-padding-10 w3-left w3-round-small w3-margin-right w3-green">description</i>
                <span class="w3-left mo-pt-8 w3-text-black w3-large">Ciclo Attivo</span>
            </li>

            <li id="menu-cp" class="menu menu-principale w3-hover-light-gray w3-padding-8" style="vertical-align: middle;">
                <i class="mi s35 mo-padding-10 w3-left w3-round-small w3-margin-right w3-red">description</i>
                <span class="w3-left mo-pt-8 w3-text-black w3-large">Ciclo Passivo</span>
            </li>

            <li id="menu-ad" class="menu menu-principale w3-hover-light-gray w3-padding-8">
                <i class="mi s35 mo-padding-10 w3-left w3-round-small w3-margin-right w3-text-white w3-purple">format_indent_increase</i>
                <span class="w3-left mo-pt-8 w3-text-black w3-large">Altri Documenti</span>
            </li>

            <li id="menu-us-template" class="menu menu-principale w3-hover-light-gray w3-padding-8" style="visibility: hidden;">
                <i class="mi s35 mo-padding-10 w3-left w3-round-small w3-margin-right w3-text-white">extension</i>
                <span class="w3-left mo-pt-8 w3-text-black w3-large">USER PROGRAM</span>
            </li>

            <li id="menu-sp" class="menu menu-principale w3-hover-light-gray w3-padding-8">
                <i class="mi s35 mo-padding-10 w3-left w3-round-small w3-margin-right w3-text-white mo-greenlemon">add_shopping_cart</i>
                <span class="w3-left mo-pt-8 w3-text-black w3-large">Spedizioni</span>
            </li>

            <li id="menu-pr" class="menu menu-principale w3-hover-light-gray w3-padding-8">
                <i class="mi s35 mo-padding-10 w3-left w3-round-small w3-margin-right w3-text-white mo-purple">import_export</i>
                <span class="w3-left mo-pt-8 w3-text-black w3-large">Prelievo</span>
            </li>
            <li id="menu-da" class="menu menu-principale w3-hover-light-gray w3-padding-8">
                <i class="mi s35 mo-padding-10 w3-left w3-round-small w3-margin-right w3-blue">content_paste</i>
                <span class="w3-left mo-pt-8 w3-text-black w3-large">Documenti Aperti</span>
                <span class="mo-tag w3-tag w3-margin-left mo-mt-8"></span>
            </li>
            <li id="menu-tr" class="menu menu-principale w3-hover-light-gray w3-padding-8">
                <i class="mi s35 mo-padding-10 w3-left w3-round-small w3-margin-right w3-text-white mo-ariforceblue">call_split</i>
                <span class="w3-left mo-pt-8 w3-text-black w3-large">Trasferimenti</span>
            </li>

            <li id="menu-sm" class="menu menu-principale w3-hover-light-gray w3-padding-8">
                <i class="mi s35 white mo-padding-10 w3-left w3-round-small w3-margin-right w3-text-white" style="background-color: #5199ff">transfer_within_a_station</i>
                <span class="w3-left mo-pt-8 w3-large w3-text-black w3-large">Stoccaggio Merce</span>
            </li>

            <li id="menu-prav" class="menu menu-principale w3-hover-light-gray w3-padding-8">
                <i class="mi s35 mo-padding-10 w3-left w3-round-small w3-margin-right w3-text-white mo-green">build</i>
                <span class="w3-left mo-pt-8 w3-text-black w3-large">Prod. Avanzata</span>
            </li>

            <li id="menu-in" class="menu menu-principale w3-hover-light-gray w3-padding-8">
                <i class="mi s35 mo-padding-10 w3-left w3-round-small w3-margin-right w3-text-white mo-darkairforceblue">playlist_add_check</i>
                <span class="w3-left mo-pt-8 w3-text-black w3-large">Inventario</span>
            </li>
            <li id="menu-ac" class="menu menu-principale w3-hover-light-gray w3-padding-8">
                <i class="mi s35 white mo-padding-10 w3-left w3-round-small w3-margin-right mo-orange">cached</i>
                <span class="w3-left mo-pt-8 w3-text-black w3-large">Avvia Consumo</span>
            </li>

            <li id="menu-aa" class="menu menu-principale w3-hover-light-gray w3-padding-8">
                <i class="mi s35 white mo-padding-10 w3-left w3-round-small w3-margin-right w3-text-white mo-tiffany">text_format</i>
                <span class="w3-left mo-pt-8 w3-large w3-text-black w3-large">Alias - Alternativi</span>
            </li>

            <li id="menu-im" class="menu menu-principale w3-hover-light-gray w3-padding-8">
                <i class="mi s35 white mo-padding-10 w3-left w3-round-small w3-margin-right w3-text-white" style="background-color: #FFE808">youtube_searched_for</i>
                <span class="w3-left mo-pt-8 w3-large w3-text-black w3-large cut-text">Interrogazione Magazzino</span>
            </li>

            <li id="menu-rs" class="menu menu-principale w3-hover-light-gray w3-padding-8">
                <i class="mi s35 white mo-padding-10 w3-left w3-round-small w3-margin-right w3-text-white w3-amber">print</i>
                <span class="w3-left mo-pt-8 w3-large w3-text-black w3-large">Stampa Documento</span>
            </li>

            <li id="menu-log" class="menu menu-principale w3-hover-light-gray w3-padding-8">
                <i class="mi s35 white mo-padding-10 w3-left w3-round-small w3-margin-right mo-light-green">list</i>
                <span class="w3-left mo-pt-8 w3-text-black w3-large">Messaggi</span>
            </li>

            <li id="menu-lo" class="menu menu-principale w3-hover-light-gray w3-padding-8">
                <i class="mi s35 white mo-padding-10 w3-left w3-round-small w3-margin-right mo-nightblue">exit_to_app</i>
                <span class="w3-left mo-pt-8 w3-text-black w3-large">Esci</span>
            </li>
        </ul>
    </div>

    <%-- #1.0020 pgSottoMenu --%>
    <div id="pgSottoMenu" class="mo-page">
        <ul id="ulSottoMenu" class="w3-ul w3-card-4 mo-menu">
            <%-- template menu dei documenti --%>
            <li id="SottomenuTemplate" class="menu w3-hover-light-gray w3-padding-8" style="display: none;">
                <i class="mi s35 mo-padding-10 w3-left w3-round-small w3-margin-right w3-blue">content_paste</i>
                <span class="doc-nome mo-bold"></span>
                <br />
                <span class="doc-desc"></span>
            </li>
            <li id="Back" class="menu w3-hover-light-gray w3-padding-8" onclick="oApp.SottoMenuAttivo = null; GoHome();">
                <i class="mi s35 mo-padding-10 w3-left w3-round-small w3-margin-right w3-orange w3-text-white">reply</i>
                <h5 class="doc-nome w3-text-black">Menu Principale</h5>
            </li>
        </ul>
    </div>

    <%-- #1.0030 pgDocAperti --%>
    <div id="pgDocAperti" class="mo-page w3-container mo-mb-5">
        <input filterkey="DocAperti_DO" type="text" class="filtro first-focus mo-search w3-input w3-border mo-mb-5 " placeholder="Cerca Documento..." />
        <div class="mo-intestazione">
            <label class="">DOCUMENTI APERTI</label>
            <i class="mi s28 s22small white mo-pointer w3-right" onclick="Ajax_xmofn_DOAperti();">cached</i>
        </div>
        <ul class="w3-ul">
            <li prgexe="" cd_do="" prgid="" class="template w3-bar w3-hover-light-gray mo-pointer w3-padding-8" style="display: none;">
                <div class="w3-bar-item">
                    <span class="cd-do w3-tag mo-bold mo-darkblue w3-round-small"></span>
                    <span class="id mo-font-darkblue mo-bold w3-large"></span>
                    <span class="do-info"></span>
                    <br />
                    <span class="cf-info"></span>
                    <br />
                    <span class="do-rows-info"></span>
                    <br />
                </div>
                <i delete="false" class="mi s40 red mo-pointer w3-bar-item w3-right mo-pt-16" onclick="$(this).attr('delete', 'true');">delete_forever</i>
            </li>
        </ul>
        <span class="msg w3-text-red"></span>
    </div>

    <%-- #1.0040 pgDocRistampa (RISTAMPA DOC ESISTENTE) --%>
    <div id="pgDocRistampa" class="mo-page w3-container mo-mb-5">
        <input filterkey="DocRistampa_DO" type="text" class="filtro first-focus mo-search w3-input w3-border mo-mb-5 " placeholder="Cerca Documento..." />
        <div class="mo-intestazione">
            <label class="">DOCUMENTI STAMPABILI</label>
            <i class="mi s30 s22small white mo-pointer w3-right" onclick="Ajax_xmofn_DORistampa();">cached</i>
        </div>
        <ul class="w3-ul w3-card-4">
            <li class="template w3-bar w3-hover-light-gray mo-pointer w3-padding-8" style="display: none;">
                <div class="w3-bar-item">
                    <span class="cd-do w3-tag mo-bold mo-darkblue w3-round-small"></span>
                    <span class="id-dotes mo-font-darkblue mo-bold w3-large"></span>
                    <span class="do-info"></span>
                    <br />
                    <span class="cf-info"></span>
                    <br />
                    <span class="datadoc mo-font-darkgray"></span>
                </div>
            </li>
        </ul>
        <span class="msg w3-text-red"></span>
        <%-- Label che contengono le info per la pagina di stampa del li cliccato (sono nascoste) --%>
        <label name="Cd_DO" class="oprg w3-hide"></label>
        <label name="Id_DOTes" class="oprg w3-hide"></label>
        <label name="Id_xMORL_Edit" class="oprg w3-hide"></label>
    </div>

    <%-- #1.0050 pgAvviaConsumo --%>
    <div id="pgAvviaConsumo" class="mo-page w3-container">
        <div class="mo-intestazione">
            <label class="">LINEA DI PRODUZIONE</label>
        </div>
        <%-- linea produzione --%>
        <div class="w3-row mo-mt-4">
            <select name='Cd_xMOLinea' class="first-focus mo-select w3-border" style="width: 100%;">
                <option value="null" selected="selected">Seleziona linea di produzione</option>
            </select>
        </div>
        <%-- articolo --%>
        <div class=" w3-row mo-mt-4">
            <label class="mo-bold mo-font-darkgray w3-large">ARTICOLO</label><br />
            <input name="Cd_AR" type="text" class="w3-large w3-margin-right w3-input w3-border" style="width: 250px;" />
            <i searchkey="Cd_AR" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i><br />
        </div>
        <%-- lotto --%>
        <div class="w3-row mo-mt-4">
            <label class="mo-font-darkgray mo-bold w3-large">LOTTO</label>
            <br />
            <input name="Cd_ARLotto" type="text" class="w3-large w3-margin-right w3-input w3-border" style="width: 100px;" />
            <i searchkey="Cd_ARLotto" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i><br />
        </div>
        <%-- data --%>
        <div class="w3-row mo-mt-4">
            <label class="mo-font-darkgray mo-bold w3-large">DATA</label><br />
            <input name='DataOra' type="date" class="w3-large w3-margin-right w3-input w3-border" style="width: 200px" />
        </div>
        <div class="w3-container w3-center mo-mt-20">
            <button class="validate w3-button w3-round-medium w3-large w3-green">CONFERMA</button>
        </div>
    </div>

    <%-- #1.0060 pgRL (TESTA DOC) --%>
    <div id="pgRL" class="mo-page w3-container mo-mb-5">
        <div class="mo-intestazione mo-pt-5">
            <label class="lb-doc-name w3-large">DOC</label><label>&nbsp;-&nbsp;</label>
            <label class="lb-doc-desc w3-small truncate-text inline-block-label">Descrizione del documento</label>
            <div class="w3-dropdown-click w3-right">
                <i onclick="$('.info-content').toggle();" class="mi s20 white mo-pointer">info</i>
                <div class="info-content w3-dropdown-content w3-bar-block w3-border w3-padding" onclick="$(this).hide();">
                    <span class="prelievo mo-pl-4 mo-mr-6">
                        <input class="ck-prelievo w3-check" type="checkbox" disabled="disabled" />
                        <label class="etichetta">Prelievo</label>
                    </span>
                    <br />
                    <span class="fuorilista mo-pl-4 mo-mr-6">
                        <input class="ck-fuorilista w3-check" type="checkbox" disabled="disabled" />
                        <label class="etichetta">Fuori lista</label>
                    </span>
                    <br />
                    <span class="ubicazione mo-pl-4 mo-mr-6">
                        <input class="ck-ubicazione w3-check" type="checkbox" disabled="disabled" />
                        <label class="etichetta">Gestione Ubicazione</label>
                    </span>
                    <br />
                    <span class="lotto mo-pl-4 mo-mr-6">
                        <input class="ck-lotto w3-check" type="checkbox" disabled="disabled" />
                        <label class="etichetta">Gestione Lotto</label>
                    </span>
                </div>
            </div>
            <label class="lb-doc-id mo-bold w3-large w3-right w3-margin-right"></label>
            <label>&nbsp;&nbsp;</label>
        </div>
        <div>
            <label class="title mo-lbl">CLIENTE/FORNITORE</label>
            <br />
            <input name="Cd_CF" type="text" class="first-focus mo-mr-6 w3-input w3-border" style="width: 100px;" />
            <label class="descrizione mo-font-darkblue" name="CF_Descrizione"></label>
            <i searchkey="Cd_CF" class="search mi s35 mo-pointer w3-margin-right w3-right">search</i>
            <i class="detail mi s35 darkblue mo-pointer w3-margin-right w3-right">account_box</i>
        </div>
        <div class="div-dest">
            <label class="mo-lbl">SEDE OPERATIVA</label>
            <br />
            <input name="Cd_CFDest" type="text" class="w3-margin-right w3-input w3-border" style="width: 90px;" />
            <label class="descrizione mo-font-darkblue" name="CFDest_Descrizione"></label>
            <i searchkey="Cd_CFDest" class="search mi s35 mo-pointer w3-margin-right w3-right">search</i><br />
        </div>
        <div>
            <label class="mo-lbl">DATA</label>
            <br />
            <input name="DataDoc" type="date" class="w3-margin-right w3-large w3-input w3-border" style="width: 200px" />
        </div>
        <div class="div-com">
            <label class="mo-lbl">SOTTOCOMMESSA</label>
            <br />
            <input name="Cd_DOSottoCommessa" type="text" class="w3-margin-right w3-input w3-border" style="width: 200px;" />
            <i searchkey="Cd_DOSottoCommessa" class="search mi s35 mo-pointer w3-margin-right w3-right">search</i><br />
        </div>
        <div>
            <div class="mo-intestazione w3-large w3-margin-top">RIFERIMENTI</div>
            <label class="mo-lbl">NR. DOCUMENTO</label><br />
            <input name="NumeroDocRif" type="text" class="w3-margin-right w3-large w3-input w3-border" style="width: 40%" />
            <br />
            <label class="mo-lbl">DATA</label><br />
            <input name="DataDocRif" type="date" class="w3-margin-right w3-large w3-input w3-border" style="width: 200px" />
        </div>
        <div class="div-magazzini">
            <div class="mo-intestazione w3-large w3-margin-top">MAGAZZINI</div>
            <%-- MG Partenza --%>
            <div class="div-mgp">
                <label class="mo-lbl">MAGAZZINO PARTENZA</label>
                <br />
                <input name="Cd_MG_P" type="text" class="w3-large w3-margin-right w3-input w3-border" style="width: 90px" />
                <i searchkey="Cd_MG_P" searchtitle="MAGAZZINO PARTENZA" class="search mi s35 mo-pointer w3-margin-right w3-right">search</i>
            </div>
            <%-- MG Arrivo --%>
            <div class="div-mga">
                <label class="mo-lbl">MAGAZZINO ARRIVO</label>
                <br />
                <input name="Cd_MG_A" type="text" class="w3-large w3-margin-right w3-input w3-border" style="width: 90px" />
                <i searchkey="Cd_MG_A" searchtitle="MAGAZZINO ARRIVO" class=" search mi s35 mo-pointer w3-margin-right w3-right">search</i>
            </div>
        </div>
        <%-- Linea --%>
        <div class="div-linea">
            <div class="mo-intestazione w3-large w3-margin-top">LINEE</div>
            <label class="mo-lbl">LINEA PRODUZIONE</label>
            <br />
            <select name="Cd_xMOLinea" class="mo-select w3-input w3-border" style="width: 60%">
                <option selected="selected"></option>
            </select>
        </div>
    </div>

    <%-- #1.0070 pgDOPrelievi (PRELIEVI DI UNA DOTes)  --%>
    <div id="pgDOPrelievi" class="mo-page w3-container">
        <div>
            <%-- <input id="prFiltroId" type="text" class="filtro mo-search w3-input w3-border" placeholder="Cerca ID..." />--%>
            <input filterkey="Prelievi_DO" type="text" class="first-focus filtro mo-search w3-input w3-border mo-mt-4 " placeholder="Cerca Documento..." />
            <input filterkey="Prelievi_AR" type="text" class="filtro mo-search w3-input w3-border mo-mt-4 " placeholder="Cerca Articolo..." />
        </div>
        <div class="mo-intestazione w3-margin-top">
            <label class="">DOCUMENTI PRELEVABILI</label>
            <i class="toggle-disabled w3-right mi s30 white mo-pointer" onclick="$('#pgDOPrelievi table .non-prelevabile').toggle();">visibility</i>
        </div>
        <div class="mo-ofy-auto">
            <%-- Tabella dei documenti prelevabili --%>
            <table class="mo-table mo-mt-4 w3-table w3-bordered">
                <tr>
                    <th class="w3-small">
                        <input class="ck-documenti mo-pointer w3-left" type="checkbox" />
                    </th>
                    <th class="mo-lbl w3-center w3-small">DOC.</th>
                    <th class="mo-lbl w3-center w3-small">N Righe</th>
                    <th class="mo-lbl w3-center w3-small">NR.</th>
                    <th class="mo-lbl w3-center w3-small">DATA</th>
                    <th class="mo-lbl w3-center w3-small">ESE.</th>
                    <%--<th class="w3-small">SC.</th>--%>
                </tr>
                <tr class="template" style="display: none;">
                    <td class="w3-small cell-content">
                        <input class="ck-documento mo-pointer" type="checkbox" onclick="$(this).prop('checked', this.checked);if(!this.checked) { ActivePage().find('.ck-documenti').prop('checked', false)}" />
                    </td>
                    <td class="w3-small cell-content Cd_DO mo-pointer mo-font-darkblue mo-underline"></td>
                    <td class="w3-small cell-content N_DORig"></td>
                    <td class="w3-small cell-content NumeroDoc"></td>
                    <td class="w3-small cell-content DataDoc"></td>
                    <td class="w3-small cell-content Cd_MGEsercizio"></td>
                    <%--<td class="w3-small Cd_DoSottoCommessa"></td>--%>
                </tr>
            </table>
        </div>
    </div>

    <%-- #1.0080 pgPrelievi (TUTTI I DOC PRELEVABILI) --%>
    <div id="pgPrelievi" class="mo-page w3-container">
        <div class="div-filtri div-accordion">
            <div class="header mo-intestazione mo-mt-4">
                <label class="">FILTRI</label>
                <i class="icon mi s30 mo-pointer w3-right">keyboard_arrow_up</i>
            </div>
            <div class="w3-row">
                <input name="Id_DOTes" type="text" class="first-focus w3-input w3-border mo-mt-4" placeholder="ID Documento" />
                <div class="content w3-container mo-mt-8 mo-mb-5">
                    <div class="mo-display-inlineblock w3-left  mo-mb-5" style="width: 100%;">
                        <div class="mo-display-inlineblock w3-left" style="width: 49%;">
                            <label class="mo-lbl">TIPO DOCUMENTO</label><br />
                            <input name="Cd_DO" type="text" class="w3-input w3-border mo-mt-4" style="width: 100px;" />
                        </div>
                        <div class="mo-display-inlineblock w3-right" style="width: 49%;">
                            <label class="mo-lbl">DATA CONSEGNA</label><br />
                            <input name="DataConsegna" type="date" class="w3-input w3-border mo-mt-4" style="width: 200px;" />
                        </div>
                    </div>
                    <div class="mo-display-inlineblock w3-left  mo-mb-5" style="width: 100%;">
                        <div class="mo-display-inlineblock w3-left" style="width: 49%;">
                            <label class="mo-lbl">CLIENTE/FORNITORE</label><br />
                            <input name="Cd_CF" type="text" class="w3-input w3-border mo-mt-4" style="width: 100px;" />
                            <i searchkey="Cd_CF" class="search mi s35 mo-pointer w3-margin-right w3-right">search</i>
                        </div>
                        <div class="mo-display-inlineblock w3-right" style="width: 49%;">
                            <label class="mo-lbl">SO</label><br />
                            <input name="Cd_CFDest" type="text" class="w3-input w3-border mo-mt-4" style="width: 100px;" />
                            <i searchkey="Cd_CFDest" class="search mi s35 mo-pointer w3-margin-right w3-right">search</i>
                        </div>
                    </div>
                    <div class="mo-display-inlineblock w3-left  mo-mb-5" style="width: 100%;">
                        <label class="mo-lbl">SOTTOCOMMESSA</label><br />
                        <input name="Cd_DOSottoCommessa" type="text" class="w3-input w3-border mo-mt-4" style="width: 80%;" />
                        <i searchkey="Cd_DOSottoCommessa" class="search mi s35 mo-pointer w3-margin-right w3-right">search</i>
                    </div>

                </div>

                <div class="w3-center mo-mt-4">
                    <%--<label class="title mo-lbl w3-margin-right">DOC</label>--%>
                    <select name="Cd_DO" class="mo-select w3-border mo-display-inlineblock w3-left" style="width: 40%"></select>
                    <button class="w3-button w3-blue mo-display-inlineblock w3-right" style="width: 50%" onclick="Ajax_xmofn_DOTes_Prel_4PR();">CERCA</button>
                </div>
            </div>
        </div>
        <div class="mo-intestazione mo-mt-8">
            <label class="">DOCUMENTI PRELEVABILI</label>
        </div>
        <div class="mo-ofy-auto" style="font-size: 0.8em !important;">
            <%-- UL dei documenti prelevabili --%>
            <ul class="w3-ul w3-card-4">
                <li class="template w3-bar mo-padding-0" style="display: none;">
                    <div class="w3-bar-item w3-centered mo-font-darkgray">
                        <span class="id-dotes w3-large mo-font-darkblue mo-bold mo-mr-6"></span>
                        <span class="cd-do w3-large mo-pointer mo-font-darkblue mo-underline"></span>
                        <span>-</span>
                        <span class="do-desc"></span>
                        <br />
                        <span class="cd-cf"></span>
                        <br />
                        <span class="numerodoc"></span>
                        <span class="datadoc"></span>
                        <br />
                        <span class="do_sottocommessa_descrizione"></span>
                        <br />
                        <span class="dataconsegna mo-bold"></span>
                    </div>
                    <input class="ck-documento w3-bar-item w3-right w3-large mo-pointer w3-check" type="checkbox" onclick="Select_Cd_DO_Template($(this));" style="width: 40px; margin-bottom: 20px;" />
                </li>
            </ul>
            <span class="msg w3-text-red"></span>
        </div>
    </div>

    <%-- #1.0090 pgRLRig (RIGHE DOC) --%>
    <div id="pgRLRig" class="mo-page w3-container">
        <div class="mo-ofy-auto">
            <%-- TABELLA LETTURE --%>
            <div class="div-letture div-accordion mo-mb-4">
                <div class="header mo-intestazione">
                    <label class="">LETTURE:&nbsp;&nbsp;</label>
                    <label class="letture"></label>
                    <i class="icon mi s30 mo-pointer w3-right mo-mt--3">keyboard_arrow_up</i>
                    <i class="mi s25 mo-pointer w3-right mo-mr-6" onclick="pgRLRig_Clear();" title="Reset dei campi">autorenew</i>
                    <i class="delete mi s25 white mo-pointer  w3-margin-right w3-right" onclick="$('#Popup_Delete_Last_Read').show();">delete_forever</i>
                    <i class="detail-letture mi s30 white mo-pointer w3-margin-right w3-right mo-mt--3">dehaze</i>
                    <i class="detail-notepiede mi s22 white mo-pointer w3-right w3-ml-2" onclick="Ajax_xmofn_xMORLPrelievo_NotePiede();">notes</i>
                </div>
                <div class="mo-ofy-auto" style="max-height: 150px;">
                    <table class="content mo-table w3-table w3-striped mo-mt-4 ">
                        <tr>
                            <th class="mo-lbl w3-small">AR</th>
                            <th class="mo-lbl w3-small Descrizione cl-ardesc">Descrizione</th>
                            <th class="mo-lbl w3-small Cd_MGUbicazione  cl-ardesc display-none">Ubicazione</th>
                            <%--<th class="w3-small Cd_ARLotto">LOTTO</th>--%>
                            <th class="mo-lbl w3-small w3-center">UM</th>
                            <th class="mo-lbl w3-small w3-center">QTA</th>
                            <th class="mo-lbl w3-small w3-center QtaEvadibile">EVAD.</th>
                        </tr>
                        <tr class="template" style="display: none;">
                            <td class="w3-small Cd_AR"></td>
                            <td class="w3-small Descrizione cl-ardesc"></td>
                            <td class="w3-small Cd_MGUbicazione  cl-ardesc display-none" style="background-color: yellow; color: black"></td>
                            <%--<td class="w3-small Cd_ARLotto"></td>--%>
                            <td class="w3-small w3-center Cd_ARMisura mo-pointer mo-btnum w3-btn"></td>
                            <td class="w3-small w3-right-align Quantita"></td>
                            <td class="w3-small w3-right-align QtaEvadibile"></td>
                        </tr>
                        <%-- template non nascosto perchè ci pensano le media query --%>
                        <tr class="template_ARDesc tr-ardesc" style="display: none;">
                            <td class="w3-small Descrizione" colspan="3"></td>
                            <td class="w3-small Cd_MGUbicazione display-none" style="background-color: yellow; color: black"></td>
                        </tr>
                    </table>
                </div>
            </div>

            <%--<button class="w3-button w3-round-medium w3-large w3-green mo-btn-bottom position1 mo-pointer" onclick="alert('conferma');">CONFERMA</button>--%>
            <%-- PACKING (mo-intestazione) --%>
            <div class="div-packinglist mo-mb-4 w3-round-small w3-amber" style="height: 45px; padding: 10px 5px;">
                <label class="mo-bold">PACKING</label>
                <select name="PackListRef" class="w3-border w3-round-small mo-ml-5" style="width: 100px; padding: 2px 3px 2px 1px;"></select>
                <i class="detail-pklist mi s30 black mo-pointer w3-right" title="Dettaglio della Packing List">dehaze</i>
                <i class="mi s30 black mo-pointer w3-right" onclick="Popup_PackList_New_Load();" title="Nuovo pacco">add_box</i>
                <i class="detail-pklistref mi s30 black mo-pointer w3-right" title="Dettaglio pesi e misure del pacco">receipt</i>
            </div>
            <%-- BARCODE --%>
            <div class="div-barcode div-accordion lg-mt-5">
                <div class="header mo-intestazione">
                    <label>BARCODE</label>
                    <i class="icon mi s30 mo-pointer w3-right mo-mt--3">keyboard_arrow_up</i>
                    <label class="container w3-right w3-margin-right">
                        <label class="lg-lblautoconfirm">Conf. automatica</label>
                        <input class="ck-autoconfirm" type="checkbox" onclick="SetFocus();" style="position: absolute;" />
                        <span class="checkmark"></span>
                    </label>
                </div>
                <div class="content lg-mt-5">
                    <div class="barcode">
                        <select class="lg-input lg-select lg-mb-5" style="width: 80px;" onchange="Barcode_SelType();"></select>
                        <input name="xMOBarcode" class="first-focus lg-input lg-mr-6" type="text" placeholder="Barcode..." style="width: 70%;" onfocus="$(this).off( 'blur' );" />
                        <label class="detail-bc lg-lbllink mo-pointer lg-mt-5 w3-right w3-margin-right">Vedi lista completa &gt;</label><br />
                    </div>
                </div>
            </div>
            <%-- ARTICOLO --%>
            <div class="mo-mb-4">
                <label class="mo-lbl">ARTICOLO</label><label class="ar-aa mo-font-darkgray w3-small mo-ml-5"></label><br />
                <input name="Cd_AR" type="text" class="first-focus w3-large w3-margin-right w3-input w3-border" style="width: 60%" tabindex="5" />
                <i searchkey="Cd_AR" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
                <i class="detail-giacar mi s35 mo-pointer w3-right w3-margin-right" data-inputubi="Cd_MGUbicazione_P" title="Giacenza">inbox</i>
            </div>
            <%-- QTA E UM --%>
            <div class="div-qtaum mo-mb-4">
                <label class="mo-lbl">QUANTITA</label><br />
                <input name="Quantita" type="number" class="w3-large w3-margin-right w3-input w3-border w3-right-align" style="width: 35%" tabindex="10" />
                <select name="Cd_ARMisura" class="mo-select w3-border w3-large" style="width: 60px;" tabindex="13">
                </select>
            </div>
            <%-- Fattore --%>
            <div class="div-umfatt mo-mb-4">
                <label class="mo-lbl">Fattore</label><br />
                <input name="UMFatt" type="number" class="w3-large w3-margin-right w3-input w3-border w3-right-align" style="width: 35%" tabindex="15" />
            </div>
            <%-- COMMESSA --%>
            <div class="div-com mo-mb-4">
                <label class="mo-lbl">SOTTOCOMMESSA</label><br />
                <input name="Cd_DOSottoCommessa" type="text" class="w3-large w3-margin-right w3-input w3-border" style="width: 200px;" tabindex="20" />
                <i searchkey="Cd_DOSottoCommessa" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
            </div>
            <%-- MG PARTENZA (accordion) --%>
            <div class="div-mgp div-accordion mo-mb-4">
                <div class="header mo-intestazione">
                    <label class="">MAGAZZINO PARTENZA&nbsp;</label>
                    <i class="icon mi s30 mo-pointer w3-right mo-mt--3">keyboard_arrow_up</i>
                    <label class="cd_mg_p w3-large w3-right w3-margin-right"></label>
                </div>
                <div class="content">
                    <label class="mo-lbl">MAGAZZINO PARTENZA</label><br />
                    <input name="Cd_MG_P" type="text" class="input-label w3-margin-right w3-input w3-border" style="width: 90px" tabindex="25" />
                    <i searchkey="Cd_MG_P" searchtitle="MAGAZZINO DI PARTENZA" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
                    <br />
                    <div class="div-mgubip">
                        <label class="mo-lbl mo-pointer mo-font-blue" onclick="Ajax_xmofn_xMORLRig_GetUbicazione('P');">UBICAZIONE MAGAZZINO</label><br />
                        <input name="Cd_MGUbicazione_P" type="text" class="w3-margin-right w3-input w3-border" style="width: 150px" tabindex="30" />
                        <i searchkey="Cd_MGUbicazione_P" searchtitle="UBICAZIONE DI PARTENZA" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i><br />
                    </div>
                </div>
            </div>
            <%-- MG ARRIVO --%>
            <div class="div-mga div-accordion mo-mb-4">
                <div class="header mo-intestazione">
                    <label class="">MAGAZZINO ARRIVO&nbsp;</label>
                    <i class="icon mi s30 mo-pointer w3-right mo-mt--3">keyboard_arrow_up</i>
                    <label class="cd_mg_a w3-large w3-right w3-margin-right"></label>
                </div>
                <div class="content">
                    <label class="mo-lbl">MAGAZZINO ARRIVO</label><br />
                    <input name="Cd_MG_A" type="text" class="input-label w3-large w3-margin-right w3-input w3-border" style="width: 80px" tabindex="35" />
                    <i searchkey="Cd_MG_A" searchtitle="MAGAZZINO DI ARRIVO" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
                    <br />
                    <div class="div-mgubia">
                        <label class="mo-lbl mo-pointer mo-font-blue" onclick="Ajax_xmofn_xMORLRig_GetUbicazione('A');">UBICAZIONE MAGAZZINO</label><br />
                        <input name="Cd_MGUbicazione_A" type="text" class="w3-large w3-margin-right w3-input w3-border" style="width: 150px" tabindex="40" />
                        <i searchkey="Cd_MGUbicazione_A" searchtitle="UBICAZIONE DI ARRIVO" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
                    </div>
                </div>
            </div>
            <%-- LOTTO --%>
            <div class="div-lotto mo-mb-4">
                <label class="mo-lbl">LOTTO</label><label class="lotto-scad mo-lbl">/SCAD.</label><br />
                <input name="Cd_ARLotto" type="text" class="w3-large w3-input w3-border" style="width: 100px" tabindex="45" />
                <label class="lotto-scad mo-font-darkgray mo-bold">/</label>
                <input name="DataScadenza" type="date" class="lotto-scad w3-large w3-margin-right w3-input w3-border" style="width: 140px" tabindex="46" />
                <i searchkey="Cd_ARLotto" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i><br />
            </div>
            <%-- MATRICOLA --%>
            <div class="div-matricola mo-mb-4">
                <label class="mo-lbl">MATRICOLA</label><br />
                <input name="Matricola" type="text" class="w3-large w3-margin-right w3-input w3-border" style="width: 60%" tabindex="50" />
            </div>
            <%-- EXTFLD--%>
            <div class="div-extfld mo-mb-4">
                <div class="template_extfld" style="display: none;">
                    <label class="mo-lbl"></label>
                    <br />
                    <input name="" type="" class="w3-large w3-margin-right w3-input w3-border" style="width: 60%" />
                </div>
            </div>
            <%-- BTN CONFERMA --%>
            <div class="w3-row w3-center w3-margin-bottom">
                <button class="btn-confirm mo-rlrigconfirm mo-mt-20" onclick="Confirm_Read(oPrg.drDO.EseguiControlli);onRowCountChange();" tabindex="55">CONFERMA</button>
                <%--<button class="btn-confirm mo-rlrigconfirm mo-mt-20" onclick="Confirm_Read(oPrg.drDO.EseguiControlli);onRowCountChange();" tabindex="55">CONFERMA</button>--%>
            </div>
        </div>
    </div>

    <%-- #1.0095 pgRLPK (PACK LIST)--%>
    <div id="pgRLPK" class="mo-page w3-container">
        <div class="mo-intestazione">
            <label class="">PACK LIST:&nbsp;</label><label class="PackListRef mo-bold"></label>
            <label class="NRow lbl w3-right"></label>
        </div>
        <label class="mo-font-darkgray mo-bold w3-large">TIPOLOGIA UL:&nbsp;</label>
        <label class="Cd_xMOUniLog mo-font-darkgray mo-bold w3-large"></label>
        <%--<label class="detail-pklist mo-pointer w3-right w3-margin-right" title="Dettaglio della Packing List" style="text-decoration: underline;">Visualizza dettaglio</label>--%>
        <i class="detail-pklist mi s30 black mo-pointer w3-right w3-margin-right hamburger" title="Dettaglio della Packing List">dehaze</i>
        <div class="mo-intestazione">
            <label class="">PESI:</label>
            <label class="w3-right">[Kg]</label>
        </div>
        <div class="mo-display-inlineblock" style="width: 32.33%;">
            <label class="mo-font-darkgray mo-bold w3-large">TARA:</label>
            <br />
            <input name="PesoTaraMks" type="number" class="w3-margin-right w3-input w3-border w3-right-align" style="width: 70px;" onchange="PKPesi_Calcola($(this));" />
        </div>
        <div class="mo-display-inlineblock" style="width: 32.33%;">
            <label class="mo-font-darkgray mo-bold w3-large">P.NETTO:</label><br />
            <input name="PesoNettoMks" type="number" class="w3-margin-right w3-input w3-border w3-right-align" style="width: 70px" onchange="PKPesi_Calcola($(this));" />
        </div>
        <div class="mo-display-inlineblock" style="width: 32.33%;">
            <label class="mo-font-darkgray mo-bold w3-large">P.LORDO:</label><br />
            <input name="PesoLordoMks" type="number" class="w3-margin-right w3-input w3-border w3-right-align" style="width: 70px" onchange="PKPesi_Calcola($(this));" />
        </div>
        <div class="mo-intestazione mo-mt-4">
            <label class="">DIMENSIONI:</label>
            <label class="w3-right">[m]</label>
        </div>
        <%-- Altezza --%>
        <div class="mo-display-inlineblock" style="width: 32.33%;">
            <label class="mo-font-darkgray mo-bold w3-large">H:</label>
            <br />
            <input name="AltezzaMks" type="number" class="w3-margin-right w3-input w3-border w3-right-align" style="width: 70px" />
        </div>
        <%-- Larghezza --%>
        <div class="mo-display-inlineblock" style="width: 32.33%;">
            <label class="mo-font-darkgray mo-bold w3-large">L:</label>
            <br />
            <input name="LarghezzaMks" type="number" class="w3-margin-right w3-input w3-border w3-right-align" style="width: 70px" />
        </div>
        <%-- Profondità --%>
        <div class="mo-display-inlineblock" style="width: 32.33%;">
            <label class="mo-font-darkgray mo-bold w3-large">P:</label>
            <br />
            <input name="LunghezzaMks" type="number" class="w3-margin-right w3-input w3-border w3-right-align" style="width: 70px" />
        </div>
        <%-- BTN --%>
        <div class="div-arrow w3-row w3-center">
            <i class="btn-slideshow-under mi s45 w3-blue mo-mt-20 mo-va-middle w3-hover-blue-gray w3-margin-right mo-pointer" onclick="Slideshow_PKRef(-1);">keyboard_arrow_left</i>
            <i class="btn-slideshow-plus mi s45 w3-blue mo-mt-20 mo-va-middle w3-hover-blue-gray w3-margin-left mo-pointer" onclick="Slideshow_PKRef(1);">keyboard_arrow_right</i>
        </div>
        <div class="w3-center">
            <button class="btn-pkref-save w3-button w3-round-medium w3-large w3-green mo-mt-20" onclick="PackListRef_Save();">CHIUDI</button>
        </div>
    </div>

    <%-- #1.0096 pgRLPrelievo (Prelievo del documento) --%>
    <div id="pgRLPrelievo" class="mo-page w3-container">
        <div class="mo-intestazione">
            <label class="">PRELIEVI</label>
            <i class="mi selall s25 white mo-pointer w3-right w3-hover-amber" onclick="pgRLPrelievo_CheckAll();" style="width: 25px;">checked</i>
        </div>
        <div class="mo-mt-4">
            <div class="mo-mb-5">
                <label class="title">SELEZIONE RIGHE DA EVADERE&nbsp;</label>
            </div>
            <div class="articoli">
                <div class="w3-card-4 articolo template" style="display: none;">
                    <div class="w3-card-header w3-container w3-light-gray">
                        Articolo
                    </div>
                    <div class="w3-card-ele w3-container">Documenti</div>
                    <div class="w3-card-footer w3-container w3-light-gray w3-right-align">
                        Totali
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- #1.0100 pgRLPiede (PIEDE DEL DOCUMENTO) --%>
    <div id="pgRLPiede" class="mo-page w3-container">
        <div class="mo-intestazione">
            <label class="">SALVATAGGIO DEL DOCUMENTO</label>
        </div>
        <div class="mo-mt-4">
            <div class="mo-mb-5">
                <span class="id-doc w3-tag w3-xlarge w3-text-white mo-darkblue"></span>
                <label>Del:&nbsp;</label>
                <span class="data-doc"></span>
                <br />
                <label class="desc-doc"></label>
                <br />
                <label class="cliente w3-margin-right w3-large"></label>
            </div>
            <div class="mo-card w3-row w3-centered mo-m-4">
                <div style="width: 48%;" class="div-card mo-display-inlineblock w3-center mo-darkblue w3-text-white mo-padding-2">
                    <span class="mo-bold" title="Articoli totali letti">TOT.</span><br />
                    <span class="ar-totali"></span>
                </div>
                <div style="width: 48%;" class="div-card mo-display-inlineblock w3-center mo-darkblue w3-text-white mo-padding-2">
                    <span class="mo-bold" title="Articoli di prelievo">PRE.</span><br />
                    <span class="ar-prelievo"></span>
                </div>
                <div style="width: 48%;" class="div-card div-noncongrui mo-display-inlineblock w3-center mo-darkblue w3-text-white mo-mt-4 mo-padding-2">
                    <span class="mo-bold" title="Articoli non congrui (qta < evadibile)">INC.</span><br />
                    <span class="ar-noncongrui"></span>
                </div>
                <div style="width: 48%;" class="div-card mo-display-inlineblock w3-center mo-darkblue w3-text-white mo-mt-4 mo-padding-2">
                    <span class="mo-bold" title="Fuorilista inseriti nel prelievo">F.L.</span><br />
                    <span class="ar-fuorilista"></span>
                </div>
            </div>
            <div class="mo-mt-4 spedizione w3-margin-top">
                <input type="checkbox" name="ChiudiSpedizione" class="w3-margin-left w3-margin-right" />
                <label class="mo-lbl">CHIUDI SPEDIZONE</label>
            </div>
            <div class="mo-mt-4">
                <%-- Targa e Caricatore --%>
                <div class="div-trcr">
                    <label class="mo-lbl">TARGA</label><br />
                    <input name="Targa" type="text" class="first-focus w3-large w3-margin-right w3-input w3-border" style="width: 150px; text-transform: uppercase;" />
                    <br />
                    <label class="mo-lbl">CARICATORE</label><br />
                    <input name="Cd_DOCaricatore" type="text" class="first-focus w3-large w3-margin-right w3-input w3-border" style="width: 150px;" />
                    <label class="descrizione mo-font-darkblue" name="CRDescrizione"></label>
                    <i searchkey="Cd_DOCaricatore" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i><br />
                </div>
                <%-- Peso e Volume di UL aggiuntive alla PK --%>
                <div class="div-pkpv mo-mt-4">
                    <label class="mo-lbl">UL AGGIUNTIVI: PESO/VOLUME</label><br />
                    <input name="PesoExtraMks" type="text" class="first-focus w3-large w3-input w3-border" placeholder="Peso" style="width: 80px;" />
                    <label class="mo-lbl w3-margin-right">[Kg]</label>
                    <input name="VolumeExtraMks" type="text" class="w3-large w3-input w3-border" placeholder="Volume" style="width: 80px;" />
                    <label class="mo-lbl">[M3]</label>
                </div>
                <div class="div-notepiede mo-mt-4">
                    <label class="mo-lbl">NOTE</label><br />
                    <textarea name="NotePiede" rows="4" class="first-focus w3-large w3-margin-right w3-input w3-border"></textarea>
                </div>
                <div class="div-listener mo-mt-4">
                    <label class="mo-lbl">LISTENER</label><br />
                    <select name="Listener" class="w3-select w3-border mo-select" onchange="Listener_Sel_Idx(this, false);">
                    </select>
                </div>
                <%-- Shortcut Avvio Consumo --%>
                <div class="div-avvioconsumo mo-mt-8">
                    <button class="w3-button w3-green" title="Effettua Avvio Consumo per tutti gli Articoli" onclick="Ajax_xmosp_xMOConsumoFromRL_Save();">Avvio Consumo</button>
                </div>
                <input type="checkbox" class="ck-print" style="display: none;" checked="checked" />
            </div>
            <div class="mo-mt-20">
                <button class="btn-salva w3-button w3-large w3-green w3-left" style="width: 49%" onclick="$('#pgRLPiede .ck-print').prop('checked', false); Nav.Next();">SALVA</button>
                <button class="btn-stampa w3-button w3-large w3-blue w3-right" style="width: 49%" onclick="$('#pgRLPiede .ck-print').prop('checked', true); Nav.Next();">STAMPA</button>
            </div>
        </div>
    </div>

    <%-- #1.0110 pgStampaDocumento (STAMPA DOC CREATO) --%>
    <div id="pgStampaDocumento" class="mo-page w3-container">
        <div class="mo-intestazione">
            <label class="">MODULI</label>
        </div>
        <div>
            <div class="mo-mt-4 mo-mb-4">
                <label class="w3-large mo-bold ">LISTENER</label><br />
                <select name="Listener" class="first-focus w3-select w3-border mo-select" onchange="Listener_Sel_Idx(this, true);">
                </select>
            </div>
            <ul class="w3-ul w3-card-4 mo-border-b-lightblue">
                <li class="template" style="display: none;">
                    <div class="w3-row">
                        <div class="mo-display-inlineblock w3-center" style="width: 10%">
                            <i class="mi s35 darkblue w3-left w3-margin-right mo-mt-20">insert_drive_file</i>
                        </div>
                        <div class="mo-display-inlineblock w3-center" style="width: 50%">
                            <label class="descrizione mo-font-darkgray"></label>
                            <br />
                            <select name="ListenerDevice" class="w3-border mo-m-4 mo-select" style="width: 90% !important;">
                            </select>
                        </div>
                        <div class="mo-display-inlineblock w3-center" style="width: 15%">
                            <label class="mo-font-darkgray">Copie</label><br />
                            <input name="NumeroCopie" class="w3-input w3-border w3-large w3-center" />
                        </div>
                        <div class="mo-display-inlineblock w3-center" style="width: 15%">
                            <label class="mo-font-darkgray">Sel.</label><br />
                            <input type="checkbox" class="ck-stampa w3-check w3-round-small" />
                        </div>
                    </div>
                </li>
            </ul>
            <div class="mo-mt-20 w3-center">
                <button class="w3-button w3-round-medium w3-large w3-blue" onclick="Nav.Next();">STAMPA</button>
            </div>
        </div>
    </div>

    <%-- #1.0120 pgTR (TESTA DEI TRASFERIMENTI) --%>
    <div id="pgTR" class="mo-page w3-container">
        <div class="mo-intestazione mo-pt-5">
            <label class="">TRAFERIMENTI INTERNI</label>
            <div class="w3-dropdown-click w3-right">
                <i onclick="$('.info-content').toggle();" class="mi white mo-pointer">info</i>
                <div class="info-content w3-dropdown-content w3-bar-block w3-border w3-padding" onclick="$(this).hide();">
                    <span class="ubicazione mo-pl-4 mo-mr-6">
                        <input class="ck-ubicazione w3-check" type="checkbox" disabled="disabled" />
                        <label class="etichetta">Gestione Ubicazione</label>
                    </span>
                    <br />
                    <span class="lotto mo-pl-4 mo-mr-6">
                        <input class="ck-lotto w3-check" type="checkbox" disabled="disabled" />
                        <label class="etichetta">Gestione Lotto</label>
                    </span>
                </div>
            </div>
            <label class="lb-doc-id mo-bold w3-large w3-right w3-margin-right"></label>
            <label>&nbsp;&nbsp;</label>
        </div>
        <div>
            <label class="title mo-font-darkgray mo-bold w3-large">DESCRIZIONE</label>
            <br />
            <input name="Descrizione" type="text" class="mo-mr-6 w3-input w3-border" style="width: 70%;" />
        </div>
        <div>
            <label class="mo-font-darkgray mo-bold w3-large">DATA</label>
            <br />
            <input name="DataMov" type="date" class="first-focus w3-margin-right w3-large w3-input w3-border" style="width: 200px" />
        </div>
        <%-- COMMESSA --%>
        <div class="div-com">
            <label class="mo-font-darkgray mo-bold w3-large">SOTTOCOMMESSA</label><br />
            <input name="Cd_DOSottoCommessa" type="text" class="w3-input w3-border" style="width: 200px;" />
            <i searchkey="Cd_DOSottoCommessa" searchtitle="SOTTOCOMMESSE" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
        </div>
        <div class="div-mgp div-accordion mo-mt-4">
            <div class="header mo-intestazione">
                <label class="">MAGAZZINO PARTENZA&nbsp;</label>
                <i class="icon mi s30 mo-pointer w3-right">keyboard_arrow_up</i>
                <label class="cd_mg_p w3-large w3-right w3-margin-right"></label>
            </div>
            <div class="content">
                <label class="mo-font-darkgray mo-bold w3-large">MAGAZZINO PARTENZA</label><br />
                <input name="Cd_MG_P" type="text" class="input-label w3-margin-right w3-input w3-border" style="width: 150px" />
                <i searchkey="Cd_MG_P" searchtitle="MAGAZZINO DI PARTENZA" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
                <br />
                <div class="div-mgubip">
                    <label class="mo-font-darkgray mo-bold w3-large">UBICAZIONE MAGAZZINO</label><br />
                    <input name="Cd_MGUbicazione_P" type="text" class="w3-margin-right w3-input w3-border" style="width: 150px" />
                    <i searchkey="Cd_MGUbicazione_P" searchtitle="UBICAZIONE DI PARTENZA" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i><br />
                </div>
            </div>
        </div>
        <%-- MG ARRIVO --%>
        <div class="div-mga div-accordion mo-mt-4">
            <div class="header mo-intestazione">
                <label class="">MAGAZZINO ARRIVO&nbsp;</label>
                <i class="icon mi s30 mo-pointer w3-right">keyboard_arrow_up</i>
                <label class="cd_mg_a mo-bold w3-large w3-right w3-margin-right"></label>
            </div>
            <div class="content">
                <label class="mo-font-darkgray mo-bold w3-large">MAGAZZINO ARRIVO</label><br />
                <input name="Cd_MG_A" type="text" class="input-label w3-large w3-margin-right w3-input w3-border" style="width: 150px" />
                <i searchkey="Cd_MG_A" searchtitle="MAGAZZINO DI ARRIVO" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
                <br />
                <div class="div-mgubia">
                    <label class="mo-font-darkgray mo-bold w3-large">UBICAZIONE MAGAZZINO</label><br />
                    <input name="Cd_MGUbicazione_A" type="text" class="w3-large w3-margin-right w3-input w3-border" style="width: 150px" />
                    <i searchkey="Cd_MGUbicazione_A" searchtitle="UBICAZIONE DI ARRIVO" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
                </div>
            </div>
        </div>
    </div>

    <%-- #1.0130 pgTRRig_P (PARTENZA) --%>
    <div id="pgTRRig_P" class="mo-page w3-container">
        <%-- TABELLA LETTURE --%>
        <div class="div-letture div-accordion">
            <div class="header mo-intestazione">
                <label class="">LETTURE:</label>
                <label class="letture mo-bold"></label>
                <label class="">&nbsp;PARTENZA</label>
                <i class="icon mi s30 mo-pointer w3-right">keyboard_arrow_up</i>
                <i class="delete mi s25 white mo-pointer w3-margin-right w3-right" onclick="$('#Popup_Delete_Last_Read').show();">delete_forever</i>
                <i class="detail-letture mi s30 white mo-pointer w3-margin-right w3-right">dehaze</i>
            </div>
            <div class="content mo-ofy-auto" style="max-height: 250px;">
                <table class="mo-table mo-mt-4 w3-table w3-bordered">
                    <tr>
                        <th class="w3-small w3-center">AR</th>
                        <th class="w3-small w3-center Cd_ARLotto">LOTTO</th>
                        <th class="w3-small w3-center">UM</th>
                        <th class="w3-small w3-center">QTA</th>
                        <th class="w3-small w3-center">MG</th>
                    </tr>
                    <tr class="template" style="display: none;">
                        <td class="w3-small w3-center Cd_AR"></td>
                        <td class="w3-small w3-center Cd_ARLotto"></td>
                        <td class="w3-small w3-center Cd_ARMisura mo-pointer mo-btnum w3-btn w3-round-medium w3-center"></td>
                        <td class="w3-small w3-right-align Quantita"></td>
                        <td class="w3-small w3-right-align Cd_MG_P"></td>
                    </tr>
                </table>
            </div>
        </div>
        <%-- ARTICOLO --%>
        <div>
            <label class="mo-font-darkgray mo-bold w3-large">ARTICOLO</label><br />
            <input name="Cd_AR" type="text" class="first-focus w3-large w3-margin-right w3-input w3-border" style="width: 60%" />
            <i searchkey="Cd_AR" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
            <i class="detail-giacar mi s35 mo-pointer w3-right w3-margin-right" title="Giacenza">inbox</i>
        </div>
        <%-- QTA E UM --%>
        <div class="div-qtaum">
            <label class="mo-font-darkgray mo-bold w3-large">QUANTITA</label><br />
            <input name="Quantita" type="number" class="w3-large w3-margin-right w3-input w3-border w3-right-align" style="width: 35%" />
            <select name="Cd_ARMisura" class="mo-select w3-border w3-large" style="width: 60px;">
            </select>
        </div>
        <%-- MG PARTENZA (accordion) --%>
        <div class="div-mgp div-accordion mo-mt-4">
            <div class="header mo-intestazione">
                <label class="">MAGAZZINO PARTENZA&nbsp;</label>
                <i class="icon mi s30 mo-pointer w3-right">keyboard_arrow_up</i>
                <label class="cd_mg_p w3-large mo-bold w3-right w3-margin-right"></label>
            </div>
            <div class="content">
                <label class="mo-font-darkgray mo-bold w3-large">MAGAZZINO PARTENZA</label><br />
                <input name="Cd_MG_P" type="text" class="input-label w3-margin-right w3-input w3-border" style="width: 150px" />
                <i searchkey="Cd_MG_P" searchtitle="MAGAZZINO DI PARTENZA" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
                <br />
                <div class="div-mgubip">
                    <label class="mo-font-darkgray mo-bold w3-large">UBICAZIONE MAGAZZINO</label><br />
                    <input name="Cd_MGUbicazione_P" type="text" class="w3-margin-right w3-input w3-border" style="width: 150px" />
                    <i searchkey="Cd_MGUbicazione_P" searchtitle="UBICAZIONE DI PARTENZA" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i><br />
                </div>
            </div>
        </div>
        <%-- LOTTO --%>
        <div class="div-lotto">
            <label class="mo-font-darkgray mo-bold w3-large">LOTTO</label><br />
            <input name="Cd_ARLotto" type="text" class="w3-large w3-margin-right w3-input w3-border" style="width: 100px" />
            <i searchkey="Cd_ARLotto" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i><br />
        </div>
        <%-- BTN CONFERMA --%>
        <div class="w3-row w3-center w3-margin-bottom">
            <button class="btn-confirm w3-button w3-round-medium w3-large w3-green mo-mt-20" onclick="Confirm_Read();">CONFERMA</button>
        </div>
    </div>

    <%-- #1.0140  pgTRRig_A (ARRIVO) --%>
    <div id="pgTRRig_A" class="mo-page w3-container">
        <%-- TABELLA LETTURE --%>
        <div class="div-letture div-accordion">
            <div class="header mo-intestazione">
                <label class="">LETTURE:</label>
                <label class="letture"></label>
                <label class="">&nbsp;ARRIVO</label>
                <i class="icon mi s30 mo-pointer w3-right">keyboard_arrow_up</i>
                <i class="delete mi s25 white mo-pointer w3-margin-right w3-right" onclick="$('#Popup_Delete_Last_Read').show();">delete_forever</i>
                <i class="detail-letture mi s30 white mo-pointer w3-margin-right w3-right">dehaze</i>
            </div>
            <div class="content mo-ofy-auto" style="max-height: 250px;">
                <table class="mo-table mo-mt-4 w3-table w3-bordered">
                    <tr>
                        <th class="w3-small w3-center">AR</th>
                        <th class="w3-small w3-center Cd_ARLotto">LOTTO</th>
                        <th class="w3-small w3-center">UM</th>
                        <th class="w3-small w3-center">QTA</th>
                        <th class="w3-small w3-center">RES</th>
                    </tr>
                    <tr class="template" style="display: none;">
                        <td class="w3-small w3-center Cd_AR"></td>
                        <td class="w3-small w3-center Cd_ARLotto"></td>
                        <td class="w3-small w3-center Cd_ARMisura mo-pointer mo-btnum w3-btn w3-round-medium w3-center"></td>
                        <td class="w3-small w3-right-align Quantita"></td>
                        <td class="w3-small w3-right-align Residua"></td>
                        <%--<td class="w3-small w3-right-align Cd_MG_P"></td>--%>
                    </tr>
                </table>
            </div>
        </div>
        <%-- ARTICOLO --%>
        <div>
            <label class="mo-font-darkgray mo-bold w3-large">ARTICOLO</label><br />
            <input name="Cd_AR" type="text" class="first-focus w3-large w3-margin-right w3-input w3-border" style="width: 60%" disabled="disabled" />
            <i class="detail-giacar mi s35 mo-pointer w3-right w3-margin-right" title="Giacenza">inbox</i>
        </div>
        <%-- QTA E UM --%>
        <div class="div-qtaum">
            <label class="mo-font-darkgray mo-bold w3-large">QUANTITA</label><br />
            <input name="Quantita" type="number" class="w3-large w3-margin-right w3-input w3-border mo-text-right" style="width: 35%" />
            <select name="Cd_ARMisura" class="mo-select w3-border w3-large" style="width: 60px;">
            </select>
        </div>
        <%-- MG ARRIVO (accordion) --%>
        <div class="div-mga div-accordion mo-mt-4">
            <div class="header mo-intestazione">
                <label class="">MAGAZZINO ARRIVO&nbsp;</label>
                <i class="icon mi s30 mo-pointer w3-right">keyboard_arrow_up</i>
                <label class="cd_mg_a w3-large w3-right w3-margin-right"></label>
            </div>
            <div class="content">
                <label class="mo-font-darkgray mo-bold w3-large">MAGAZZINO ARRIVO</label><br />
                <input name="Cd_MG_A" type="text" class="input-label w3-margin-right w3-input w3-border" style="width: 150px" />
                <i searchkey="Cd_MG_A" searchtitle="MAGAZZINO DI ARRIVO" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
                <br />
                <div class="div-mgubia">
                    <label class="mo-font-darkgray mo-bold w3-large">UBICAZIONE MAGAZZINO</label><br />
                    <input name="Cd_MGUbicazione_A" type="text" class="w3-margin-right w3-input w3-border" style="width: 150px" />
                    <i searchkey="Cd_MGUbicazione_A" searchtitle="UBICAZIONE DI ARRIVO" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i><br />
                </div>
            </div>
        </div>
        <%-- BTN CONFERMA --%>
        <div class="w3-row w3-center w3-margin-bottom">
            <button class="btn-confirm w3-button w3-round-medium w3-large w3-green mo-mt-20" onclick="Confirm_Read();">CONFERMA</button>
        </div>
    </div>

    <%-- #1.0150 pgTRPiede (PIEDE DEI TRASFERIMENTI) --%>
    <div id="pgTRPiede" class="mo-page w3-container">
        <div class="mo-intestazione">
            <label class="">SALVATAGGIO DEL TRASFERIMENTO</label>
        </div>
        <div class="mo-mt-4">
            <div class="w3-card-4 mo-padding-8">
                <span class="id-doc w3-tag w3-large w3-text-white mo-darkblue mo-bold"></span>
                <label>Del:&nbsp;</label>
                <span class="data-doc"></span>
                <br />
                <label class="desc-doc mo-bold"></label>
            </div>
            <div class="w3-row w3-centered mo-m-4">
                <div style="width: 49%;" class="mo-display-inlineblock w3-center w3-round-medium mo-darkblue w3-text-white mo-padding-8">
                    <span class="mo-bold">TOTALI</span>
                    <span class="ar-totali w3-right"></span>
                </div>
                <div style="width: 49%;" class="mo-display-inlineblock w3-center w3-round-medium mo-darkblue w3-text-white mo-padding-8">
                    <span class="mo-bold">INCOMPLETI</span>
                    <span class="ar-incompleti w3-right"></span>
                </div>
            </div>
            <div class="mo-mt-4">
                <div class="div-notepiede">
                    <label class="mo-lbl">NOTE</label><br />
                    <textarea name="NotePiede" rows="4" class="first-focus w3-large w3-margin-right w3-input w3-border"></textarea>
                </div>
                <div class="div-listener">
                    <label class="mo-lbl">LISTENER</label><br />
                    <select name="Listener" class="w3-select w3-border mo-select" onchange="Listener_Sel_Idx(this, false);">
                    </select>
                </div>
                <input type="checkbox" class="ck-print" style="display: none;" checked="checked" />
            </div>
            <div class="w3-margin-bottom mo-mt-4 w3-center">
                <button class="btn-salva w3-button w3-round-medium w3-large w3-green" onclick="$('#pgTRPiede .ck-print').prop('checked', false); Nav.Next();">SALVA</button>
            </div>
        </div>
    </div>

    <%-- #1.0160 pgINAperti --%>
    <div id="pgINAperti" class="mo-page w3-container mo-mb-5">
        <div class="mo-intestazione">
            <label class="">INVENTARI APERTI</label>
            <i class="mi s30 s22small white mo-pointer w3-right" onclick="Ajax_xmofn_xMOIN_Aperti();">cached</i>
        </div>
        <i class="mi s50 white mo-btn-bottom position1 w3-circle w3-blue mo-pointer" onclick="oPrg.Pages[oPrg.PageIdx(enumPagine.pgIN)].Enabled = true; Nav.Next();">add</i>
        <ul class="w3-ul w3-card-4">
            <li id_xmoin="" class="template w3-bar w3-hover-light-gray mo-pointer w3-padding-8" style="display: none;">
                <div class="w3-bar-item">
                    <span class="w3-tag mo-bold mo-darkblue w3-round-small">INV</span>
                    <span class="id mo-font-darkblue mo-bold w3-large"></span><span>&nbsp;</span>
                    <span class="cd_mgesercizio"></span><span>&nbsp;</span><span class="mges_descrizione"></span>
                    <br />
                    <span class="cd_mg"></span>
                    <br />
                    <span class="cd_mgubicazione"></span>
                    <br />
                    <span class="dataora"></span>
                </div>
                <i delete="false" class="mi s40 red mo-pointer w3-bar-item w3-right mo-pt-16" onclick="$(this).attr('delete', 'true');">delete_forever</i>
            </li>
        </ul>
        <span class="msg w3-text-red"></span>
    </div>

    <%-- #1.0170 pgIN (TESTA INVENTARIO) --%>
    <div id="pgIN" class="mo-page w3-container">
        <div class="mo-intestazione">
            <label class="">INVENTARIO:</label>
            <label class="lb-doc-id w3-large mo-ml-5"></label>
            <div class="w3-dropdown-click w3-right">
                <i onclick="$('.info-content').toggle();" class="mi white mo-pointer">info</i>
                <div class="info-content w3-dropdown-content w3-bar-block w3-border w3-padding" onclick="$(this).hide();">
                    <span class="ubicazione mo-pl-4 mo-mr-6">
                        <input class="ck-ubicazione w3-check" type="checkbox" disabled="disabled" />
                        <label class="etichetta">Gestione Ubicazione</label>
                    </span>
                    <br />
                    <span class="lotto mo-pl-4 mo-mr-6">
                        <input class="ck-lotto w3-check" type="checkbox" disabled="disabled" />
                        <label class="etichetta">Gestione Lotto</label>
                    </span>
                    <br />
                    <span class="lotto mo-pl-4 mo-mr-6">
                        <input class="ck-commessa w3-check" type="checkbox" disabled="disabled" />
                        <label class="etichetta">Gestione Commessa</label>
                    </span>
                </div>
            </div>
        </div>
        <div>
            <div>
                <label class="title mo-font-darkgray mo-bold w3-large">DESCRIZIONE</label>
                <br />
                <input name="Descrizione" type="text" class="mo-mr-6 w3-input w3-border" style="width: 70%;" />
            </div>
            <label class="mo-font-darkgray mo-bold w3-large">ESERCIZIO</label><br />
            <select name="Cd_MGEsercizio" class="w3-select w3-border mo-select">
            </select><br />
            <%-- Data --%>
            <div class="w3-row lg-mt-5">
                <label class="mo-font-darkgray mo-bold w3-large">DATA</label><br />
                <input name='DataOra' type="date" class="first-focus w3-margin-right w3-input w3-border" style="width: 150px" />
            </div>
            <label class="mo-font-darkgray mo-bold w3-large">MAGAZZINO</label><br />
            <input name="Cd_MG" type="text" class="input-label w3-margin-right w3-input w3-border" style="width: 150px" />
            <i searchkey="Cd_MG" searchtitle="MAGAZZINO" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
            <div class="div-mgubi">
                <label class="mo-font-darkgray mo-bold w3-large">UBICAZIONE MAGAZZINO</label><br />
                <input name="Cd_MGUbicazione" type="text" class="w3-margin-right w3-input w3-border" style="width: 150px" />
                <i searchkey="Cd_MGUbicazione" searchtitle="UBICAZIONE" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
            </div>
            <div class="div-rig">
                <label class="mo-font-darkgray mo-bold w3-large">RIGHE</label><br />
                <input name='Top' class="w3-input w3-border w3-right-align" type="number" style="width: 150px; border-radius: 2px 3px;" />
            </div>
        </div>
    </div>

    <%-- #1.0180 pgINRig (RIGHE INVENTARIO) --%>
    <div id="pgINRig" class="mo-page w3-container">
        <div class="div-grid">
            <div class="div-filtri div-accordion mo-mb-4">
                <div class="header mo-intestazione">
                    <label class="">MAGAZZINO: </label>
                    <label class="cd_mg"></label>
                    <i class="icon mi s30 mo-pointer w3-right">keyboard_arrow_up</i>
                </div>
                <div class="content">
                    <%-- ARTICOLO --%>
                    <label class="mo-font-darkgray mo-bold w3-large">ARTICOLO</label><br />
                    <input type="text" class="first-focus Cd_AR w3-margin-right w3-input w3-border" onkeyup="INRig_Client_Filter();" style="width: 60%" />
                    <div class="div-mgubi">
                        <label class="mo-font-darkgray mo-bold w3-large">UBICAZIONE MAGAZZINO</label><br />
                        <input name='Cd_MGUbicazione' type="text" class="Cd_MGUbicazione w3-margin-right w3-input w3-border" onkeyup="INRig_Client_Filter();" style="width: 150px" />
                    </div>
                </div>
            </div>
            <div>
                <i class="mi s50 white mo-btn-bottom position1 w3-circle w3-blue mo-pointer" onclick="Detail_pgINRig_Load();">add</i>
                <i class="mi s50 btn-top mo-btn-bottom position2 w3-circle mo-pointer w3-amber w3-text-white" onclick="GoTo_TopPage();" style="display: none;">keyboard_arrow_up</i>
                <%-- LISTA ARTICOLI PER IN MASSIVO --%>
                <table class="tbl-arlist mo-table mo-mt-4 w3-table w3-bordered">
                    <tr class="w3-amber">
                        <th>AR/LT</th>
                        <th class="Cd_MGUbicazione">UBI</th>
                        <th class="Cd_DOSottoCommessa">COM.</th>
                        <th class="w3-center">Contabile</th>
                        <th class="w3-center col-qtarilevata">
                            <button class="w3-button w3-blue" onclick="$('#pgINRig .tbl-arlist .col-qtarilevata').hide(); $('#pgINRig .tbl-arlist .col-qtarettifica').show();">Rilevata</button></th>
                        <th class="w3-center col-qtarettifica">
                            <button class="w3-button w3-blue" onclick="$('#pgINRig .tbl-arlist .col-qtarettifica').hide(); $('#pgINRig .tbl-arlist .col-qtarilevata').show();">Rettifica</button></th>
                        <%--<th class="w3-center">UM</th>--%>
                    </tr>
                    <tr class="template mo-pointer w3-hover-light-gray" style="display: none;">
                        <td>
                            <label class="Cd_AR"></label>
                            <br />
                            <label class="mo-font-darkblue Cd_ARLotto"></label>
                        </td>
                        <td class="Cd_MGUbicazione"></td>
                        <td class="Cd_DOSottoCommessa"></td>
                        <td class="col-qta w3-right-align">
                            <label class="Quantita"></label>
                            <br />
                            <label class="mo-font-darkblue Cd_ARMisura"></label>
                        </td>
                        <td class="col-qtarilevata w3-right-align">
                            <label class="QtaRilevata"></label>
                            <br />
                            <label class="mo-font-darkblue Cd_ARMisura"></label>
                        </td>
                        <td class="col-qtarettifica w3-right-align">
                            <label class="QtaRettifica"></label>
                            <br />
                            <label class="mo-font-darkblue Cd_ARMisura"></label>
                        </td>
                        <%--<td class="w3-center Cd_ARMisura"></td>--%>
                    </tr>
                    <%-- template non nascosto perchè ci pensano le media query --%>
                    <tr class="template_ARDesc w3-border-bottom tr-ardesc" style="display: none;">
                        <td class="w3-small Descrizione" colspan="5"></td>
                    </tr>
                    <tfoot>
                    </tfoot>
                </table>
                <label class="mo-msg w3-large mo-font-darkblue w3-padding">Nessun articolo da inventariare</label>
            </div>
        </div>

        <div class="div-detail">
            <div class="mo-intestazione">
                <label class="mo-mr-6">ARTICOLO: </label>
                <label class="NRow lbl"></label>
                <span onclick="$('#pgINRig .div-detail').hide(); $('#pgINRig .div-grid').show();" class="w3-large w3-text-white mo-pointer w3-margin-right w3-right">&times;</span>
            </div>
            <%-- <div class="w3-container">--%>
            <%-- ARTICOLO NEW --%>
            <div class="div-in-ar-new">
                <div>
                    <label class="mo-lbl">ARTICOLO</label><label class="ar-aa lbl mo-font-darkgray w3-small mo-ml-5"></label><br />
                    <input name="Cd_AR" type="text" class="first-focus w3-large w3-margin-right w3-input w3-border" style="width: 170px;" />
                    <i searchkey="Cd_AR" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
                </div>
                <%-- COMMESSA --%>
                <div class="div-com">
                    <label class="mo-lbl">SOTTOCOMMESSA</label>
                    <br />
                    <input name="Cd_DOSottoCommessa" type="text" class="w3-margin-right w3-input w3-border" style="width: 200px;" />
                    <i searchkey="Cd_DOSottoCommessa" class="search mi s35 mo-pointer w3-margin-right w3-right">search</i><br />
                </div>
                <%-- LOTTO --%>
                <div class="div-lotto">
                    <label class="mo-lbl">LOTTO</label><br />
                    <input name="Cd_ARLotto" type="text" class="w3-large w3-margin-right w3-input w3-border" style="width: 130px" />
                    <i searchkey="Cd_ARLotto" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i><br />
                </div>
                <div>
                    <label class="mo-lbl">MAGAZZINO</label><br />
                    <input name="Cd_MG" type="text" class="w3-margin-right w3-input w3-border" style="width: 90px" disabled="disabled" />
                    <br />
                    <%-- UBICAZIONE --%>
                    <div class="div-mgubi mo-mt-4">
                        <label class="mo-lbl">UBICAZIONE</label><br />
                        <input name="Cd_MGUbicazione" type="text" class="w3-margin-right w3-input w3-border" style="width: 150px" />
                        <i searchkey="Cd_MGUbicazione" searchtitle="UBICAZIONE" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i><br />
                    </div>
                </div>
                <div class="w3-row w3-center mo-mb-5">
                    <button class="in-btn-new w3-button w3-large w3-green mo-mt-20" onclick="Detail_pgINRig_AR_New();">Aggiungi</button>
                </div>
                <div class="mo-intestazione">
                    <label>GIACENZE ARTICOLO</label>
                </div>
                <%-- Lista delle giacenze per l'articolo selezionato --%>
                <table class="tbl-argiac mo-table w3-table mo-mt-4" style="font-size: 0.8em;">
                    <tr>
                        <th class="mo-lbl w3-center">SOTTOCOMMESSA</th>
                        <th class="mo-lbl w3-center">LOTTO</th>
                        <th class="mo-lbl w3-center">UBICAZIONE</th>
                        <th class="mo-lbl w3-center">QUANTITA'</th>
                    </tr>
                    <tr class="template mo-pointer w3-hover-light-gray" style="display: none;">
                        <td class="w3-right-align argiac-dosottocommessa"></td>
                        <td class="w3-right-align argiac-arlotto"></td>
                        <td class="w3-right-align argiac-mgubicazione"></td>
                        <td class="w3-right-align">
                            <label class="argiac-quantita"></label>
                            <br />
                            <label class="argiac-armisura w3-text-gray"></label>
                        </td>
                    </tr>
                </table>
                <label class="mo-msg-argiac">Nessuna giacenza presente per l'articolo</label>
            </div>
            <%-- ARTICOLO --%>
            <div class="div-in-ar">
                <%-- QTA E UM --%>
                <div class="div-qtaum">
                    <div>
                        <label class="mo-h4 mo-font-darkblue mo-bold lbl Cd_AR"></label>
                        <label class="mo-font-darkblue mo-bold lbl Cd_ARLotto"></label>
                        <label class="mo-font-darkblue mo-bold lbl Cd_MGUbicazione"></label>
                        <label class="mo-font-darkblue mo-bold lbl Cd_DOSottoCommessa"></label>
                    </div>
                    <label class="mo-font-darkgray mo-bold w3-large">QUANTITA</label><br />
                    <label class="lbl Quantita"></label>
                    <br />
                    <i class="mod-somma mi s45 gray mo-va-middle mo-pointer w3-margin-right" onclick="$(this).toggleClass('w3-text-green'); $('.focus').focus();">add_box</i>
                    <input name="QtaRilevata" type="number" class="focus w3-large w3-margin-right w3-input w3-border w3-right-align" style="width: 35%" />
                    <select name="Cd_ARMisura" class="mo-select w3-border w3-large" style="width: 60px;">
                    </select><br />
                    <%-- Icona che indica la modalità somma se attiva --%>
                    <label>Lettura:&nbsp;<label class="lbl QtaRilevata"></label></label>
                    <br />
                    <label class="msg" style="font-size: 12px; color: gray;"></label>
                </div>
                <%-- BTN PER IN MASSIVO --%>
                <div class="btn-inm w3-row w3-center">
                    <i class="btn-slideshow in-back mi s45 w3-blue mo-mt-20 mo-va-middle w3-hover-blue-gray w3-margin-right mo-pointer" onclick="IN_SlideShow(-1);">keyboard_arrow_left</i>
                    <button class="in-ok w3-button w3-round-medium w3-large w3-green mo-mt-20" onclick="Detail_pgINRig_AR_Confirm();">OK</button>
                    <i class="btn-slideshow in-next mi s45 w3-blue mo-mt-20 mo-va-middle w3-hover-blue-gray w3-margin-left mo-pointer" onclick="IN_SlideShow(1);">keyboard_arrow_right</i>
                </div>
                <%-- BTN PER IN PUNTUALE --%>
                <div class="btn-inp w3-center mo-mt-4">
                    <div class="mo-div-btn w3-button w3-round-medium w3-large w3-green mo-mt-20" onclick="Ajax_xmosp_xMOIN_MakeOne_MGMov('CON');">
                        <div class="w3-col" style="width: 60px;"><i class="mi s30 white">save</i></div>
                        <div class="w3-col" style="width: 120px;">
                            <label>CONTINUA</label>
                        </div>
                    </div>
                    <br />
                    <div class="mo-div-btn w3-button w3-round-medium w3-large w3-green mo-mt-4" onclick="Ajax_xmosp_xMOIN_MakeOne_MGMov('NEW');">
                        <div class="w3-col" style="width: 60px;"><i class="mi s30 white">save</i></div>
                        <div class="w3-col" style="width: 120px;">
                            <label>RICOMINCIA</label>
                        </div>
                    </div>
                    <br />
                    <div key="chiudi" class="mo-div-btn w3-button w3-round-medium w3-large w3-green mo-mt-4" onclick="Ajax_xmosp_xMOIN_MakeOne_MGMov('END');">
                        <div class="w3-col" style="width: 60px;"><i class="mi s30 white">save</i></div>
                        <div class="w3-col" style="width: 120px;">
                            <label>CHIUDI</label>
                        </div>
                    </div>
                </div>
            </div>

            <%-- LETTURA SEQUENZIALE --%>
            <div class="mo-mb-4 div-sequenziale">
                <input class="ck-sequenziale w3-check mo-mr-6" type="checkbox" onclick="SlideShow_Attiva($(this));" /><label>Lettura sequenziale</label>
            </div>
            <%--  </div>--%>
        </div>
    </div>

    <%-- #1.0190 pgINPiede (PIEDE INVENTARIO) --%>
    <div id="pgINPiede" class="mo-page w3-container">
        <div class="mo-intestazione">
            <label class="">CONFERMA INVENTARIO</label>
        </div>
        <div class="w3-center mo-mt-4">
            <h4>Rettifiche effettuate:
                <label class="lbl-inm-let"></label>
            </h4>
            <div class="btn-inm-con mo-div-btn w3-button w3-round-medium w3-large w3-green mo-mt-4" onclick="Ajax_xmosp_xMOIN_Make_MGMov(this, 'CON');">
                <div class="w3-col" style="width: 60px;"><i class="mi s30 white">save</i></div>
                <div class="w3-col" style="width: 120px;">
                    <label>CONTINUA</label>
                </div>
            </div>
            <br />
            <div class="mo-div-btn w3-button w3-round-medium w3-large w3-green mo-mt-4" onclick="Ajax_xmosp_xMOIN_Make_MGMov(this, 'NEW');">
                <div class="w3-col" style="width: 60px;"><i class="mi s30 white">save</i></div>
                <div class="w3-col" style="width: 120px;">
                    <label>RICOMINCIA</label>
                </div>
            </div>
            <br />
            <div key="chiudi" class="mo-div-btn w3-button w3-round-medium w3-large w3-green mo-mt-4" onclick="Ajax_xmosp_xMOIN_Make_MGMov(this, 'END');">
                <div class="w3-col" style="width: 60px;"><i class="mi s30 white">save</i></div>
                <div class="w3-col" style="width: 120px;">
                    <label>CHIUDI</label>
                </div>
            </div>
        </div>
    </div>

    <%-- #1.0195 pgINPuntuale --%>
    <div id="pgINPuntuale" class="mo-page w3-container">
        <div class="mo-intestazione">
            <label class="mo-mr-6">ARTICOLO: </label>
            <label class="NRow lbl"></label>
        </div>
        <div class="w3-container">
            <%-- ARTICOLO --%>
            <div>
                <label class="mo-font-darkgray mo-bold w3-large">ARTICOLO</label><label class="ar-aa lbl mo-font-darkgray w3-small mo-ml-5"></label><br />
                <input name="Cd_AR" type="text" class="first-focus w3-large w3-margin-right w3-input w3-border" style="width: 170px;" />
                <i searchkey="Cd_AR" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
            </div>
            <%-- COMMESSA --%>
            <div class="div-com">
                <label class="mo-font-darkgray mo-bold w3-large">SOTTOCOMMESSA</label>
                <br />
                <input name="Cd_DOSottoCommessa" type="text" class="w3-margin-right w3-input w3-border" style="width: 200px;" />
                <i searchkey="Cd_DOSottoCommessa" class="search mi s35 mo-pointer w3-margin-right w3-right">search</i><br />
            </div>
            <%-- LOTTO --%>
            <div class="div-lotto">
                <label class="mo-font-darkgray mo-bold w3-large">LOTTO</label><br />
                <input name="Cd_ARLotto" type="text" class="w3-large w3-margin-right w3-input w3-border" style="width: 130px" />
                <i searchkey="Cd_ARLotto" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i><br />
            </div>
            <%-- UBICAZIONE --%>
            <div class="div-mgubi">
                <label class="mo-font-darkgray mo-bold w3-large">UBICAZIONE</label><br />
                <input name="Cd_MGUbicazione" type="text" class="w3-margin-right w3-input w3-border" style="width: 150px" />
                <i searchkey="Cd_MGUbicazione" searchtitle="UBICAZIONE" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i><br />
            </div>
            <%-- QTA E UM --%>
            <div class="div-qtaum">
                <label class="mo-font-darkgray mo-bold w3-large">QUANTITA</label><br />
                <label class="lbl Quantita"></label>
                <br />
                <i class="mod-somma mi s45 gray mo-va-middle mo-pointer w3-margin-right" onclick="$(this).toggleClass('w3-text-green'); $('.focus').focus().select();">add_box</i>
                <input name="QtaRilevata" type="number" class="focus w3-large w3-margin-right w3-input w3-border w3-right-align" style="width: 35%" />
                <select name="Cd_ARMisura" class="mo-select w3-border w3-large" style="width: 60px;">
                </select><br />
                <%-- Icona che indica la modalità somma se attiva --%>
                <label>Lettura:&nbsp;<label class="lbl QtaRilevata"></label></label>
            </div>
            <%-- BTN --%>
            <div class="w3-row w3-center">
                <i class="btn-slideshow in-back mi s45 w3-blue mo-mt-20 mo-va-middle w3-hover-blue-gray w3-margin-right mo-pointer" onclick="IN_SlideShow(-1);">keyboard_arrow_left</i>
                <button class="w3-button w3-round-medium w3-large w3-green mo-mt-20" onclick="Detail_pgINRig_Save(true);">OK</button>
                <i class="btn-slideshow in-next mi s45 w3-blue mo-mt-20 mo-va-middle w3-hover-blue-gray w3-margin-left mo-pointer" onclick="IN_SlideShow(1);">keyboard_arrow_right</i>
            </div>
            <%-- LETTURA SEQUENZIALE --%>
            <div class="mo-mb-4 div-sequenziale">
                <input class="ck-sequenziale w3-check mo-mr-6" type="checkbox" onclick="SlideShow_Attiva($(this));" /><label>Lettura sequenziale</label>
            </div>
        </div>
    </div>

    <%-- #1.0200 pgSP (SPEDIZIONE) --%>
    <div id="pgSP" class="mo-page w3-container">
        <div>
            <label class="title mo-lbl">SPEDIZIONE</label>
            <br />
            <input name="Cd_xMOCodSpe" type="text" class="keypressexec w3-input w3-border w3-margin-right" style="width: 200px;" />
            <i searchkey="Cd_xMOCodSpe" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i><br />
        </div>
        <div>
            <label class="title mo-lbl">SELEZIONA ID DOCUMENTO</label>
            <br />
            <input name="Id_DOTes" type="text" class="keypressexec first-focus w3-input w3-border w3-margin-right" style="width: 200px;" />
        </div>
        <div class="mo-mt-4">
            <label class="title mo-lbl w3-margin-right">DOC</label><br />
            <select name="Cd_DO" class="mo-select w3-border" style="width: 30%"></select>
            <i class="i sp-no mi red mo-padding-2 mo-pointer w3-right">close</i>
            <i class="i sp-ok mi green mo-padding-2 mo-pointer w3-right" onclick="Nav.Next();">check</i>
        </div>
        <div class="mo-intestazione mo-mt-4">
            <label class="">SPEDIZIONE</label>
            <i class="mi s25 mo-pointer w3-right mo-mt--3" onclick="Ajax_xmofn_xMOCodSpe();">cached</i>
        </div>
        <div class="mo-ofy-auto">
            <%-- Tabella dei documenti prelevabili --%>
            <table class="mo-table mo-mt-4 w3-table w3-bordered">
                <tr style="font-size: 11px !important;">
                    <th class="mo-lbl mo-pointer order-0" onclick="pgSP_OrderTable(0);">SPEDIZIONE</th>
                    <th class="mo-lbl">DOC.</th>
                    <th class="mo-lbl CF">C/F</th>
                    <th class="mo-lbl">NR.</th>
                    <th class="mo-lbl mo-pointer order-1" onclick="pgSP_OrderTable(1);">DATA SPEDIZIONE</th>
                    <th class="mo-lbl"></th>
                </tr>
                <tr class="template" style="display: none;">
                    <td class="w3-small Cd_xMOCodSpe"></td>
                    <td class="w3-small Cd_DO mo-pointer mo-font-darkblue mo-underline"></td>
                    <td class="w3-small Cd_CF CF"></td>
                    <td class="w3-small NumeroDoc"></td>
                    <%--<td class="w3-small DataDoc"></td>--%>
                    <td class="w3-small DataSpedizione"></td>
                    <td class="w3-small">
                        <input class="ck-sp w3-check" type="checkbox" onclick="Spedizione_Check_SP($(this));" />
                        <i class="mi s35 mo-pointer red">highlight_off</i>
                    </td>
                </tr>
            </table>
        </div>
    </div>

    <%-- #1.0210 pgLog --%>
    <div id="pgLog" class="mo-page w3-container">
        <div class="mo-intestazione">
            <label class="">ELENCO MESSAGGI</label>
        </div>
        <div>
            <ul class="w3-ul w3-card-4">
                <li class="template w3-bar" style="display: none;">
                    <div class="w3-row">
                        <div class="w3-col">
                            <i class="mi s30 green">message</i>
                        </div>
                        <div class="w3-col">
                            <span class="datetime mo-font-darkblue"></span>
                            <br />
                            <span class="title mo-font-darkblue"></span>
                            <br />
                            <span class="message mo-font-darkblue"></span>
                        </div>
                    </div>
                </li>
            </ul>
        </div>
    </div>

    <%--#1.0220 pgAA (ACQUISIZIONE ALIAS)--%>
    <div id="pgAA" class="mo-page w3-container">
        <div class="mo-intestazione">
            <label class="alias">ACQUISIZIONE ALIAS</label>
            <label class="codalt">ACQUISIZIONE ALTERNATIVI</label>
            <label class="switch w3-right">
                <input class="ck-alt" type="checkbox" onclick="pgAA_Change_TipoAA($(this).prop('checked'));" />
                <span class="slider round"></span>
            </label>
        </div>
        <%-- cliente/fornitore --%>
        <div class="codalt w3-row">
            <label class="title mo-font-darkgray mo-bold w3-large">CLIENTE/FORNITORE</label>
            <br />
            <input name="Cd_CF" type="text" class="first-focus mo-mr-6 w3-input w3-border" style="width: 100px;" />
            <label class="descrizione mo-font-darkblue" name="CF_Descrizione"></label>
            <i searchkey="Cd_CF" class="search mi s35 mo-pointer w3-margin-right w3-right">search</i>
        </div>
        <%-- articolo --%>
        <div class=" w3-row mo-mt-4">
            <label class="mo-bold mo-font-darkgray w3-large">ARTICOLO</label><br />
            <input name="Cd_AR" type="text" class="w3-large w3-margin-right w3-input w3-border" style="width: 100px;" />
            <i searchkey="Cd_AR" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i><br />
        </div>
        <%-- um --%>
        <div class="alias w3-row mo-mt-4">
            <label class="mo-font-darkgray mo-bold w3-large">UM</label>
            <br />
            <input name="Cd_ARMisura" type="text" class="w3-large w3-margin-right w3-input w3-border" style="width: 80px;" />
            <i searchkey="Cd_ARMisura" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i><br />
        </div>
        <%-- barcode --%>
        <div class="barcode">
            <select class="mo-select mo-mb-5 w3-input w3-border" style="width: 100px;" onchange="Barcode_SelType();"></select>
            <input name="xMOBarcode" class="first-focus w3-large mo-ml-5 w3-input w3-border" type="text" placeholder="Barcode..." style="width: 50%;" />
        </div>
        <%-- alias --%>
        <div class="alias w3-row mo-mt-4">
            <label class="mo-font-darkgray mo-bold w3-large">ALIAS</label><br />
            <input name='ALI' type="text" class="w3-large w3-margin-right w3-input w3-border" style="width: 200px" />
        </div>
        <%-- codice alternativo --%>
        <div class="codalt w3-row mo-mt-4">
            <label class="mo-font-darkgray mo-bold w3-large">CODICE ALTERNATIVO</label><br />
            <input name='ALT' type="text" class="w3-large w3-margin-right w3-input w3-border" style="width: 200px" />
        </div>
        <%-- descrizione codalt --%>
        <div class="codalt w3-row mo-mt-4">
            <label class="mo-font-darkgray mo-bold w3-large">DESCRIZIONE</label><br />
            <input name='Descrizione' type="text" class="w3-large w3-margin-right w3-input w3-border" style="width: 80%" />
            <br />
            <label class="lg-lbl-da">Se non specificata viene inserita quella dell'articolo</label>
        </div>
        <div class="w3-container w3-center mo-mt-20">
            <button class="validate w3-button w3-round-medium w3-large w3-green">INSERISCI</button>
        </div>
        <label class="mo-font-darkgray mo-bold w3-large msg"></label>
    </div>

    <%-- #1.0230 pgMGDisp (Interrogazione magazzini) --%>
    <div id="pgMGDisp" class="mo-page w3-container">
        <div class="div-filtri div-accordion">
            <div class="header mo-intestazione pgMGDisp-header">
                <label class="">FILTRI&nbsp;</label>
                <i class="icon mi s30 mo-pointer w3-right">keyboard_arrow_up</i>
            </div>
            <div class="content">
                <%-- ARTICOLO --%>
                <div class="div-cdar">
                    <label class="mo-font-darkgray w3-large">ARTICOLO</label><label class="ar-aa mo-font-darkgray w3-small mo-ml-5"></label><br />
                    <input name="Cd_AR" type="text" class="first-focus w3-large w3-margin-right w3-input w3-border" style="width: 60%" />
                    <i searchkey="Cd_AR" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
                </div>

                <%-- MG --%>
                <div class="div-mg">
                    <label class="mo-font-darkgray w3-large">MAGAZZINO</label><br />
                    <input name="Cd_MG" type="text" class="first-focus input-label w3-margin-right w3-input w3-border" style="width: 60%" />
                    <i searchkey="Cd_MG" searchtitle="MAGAZZINO" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
                </div>

                <%-- UBICAZIONE --%>
                <div class="div-mgubi">
                    <label class="mo-font-darkgray w3-large">UBICAZIONE MAGAZZINO</label><br />
                    <input name="Cd_MGUbicazione" type="text" class="w3-margin-right w3-input w3-border" style="width: 60%" />
                    <i searchkey="Cd_MGUbicazione" searchtitle="UBICAZIONE" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
                </div>

                <%-- SOTTOCOMMESSA --%>
                <div class="div-mgubi">
                    <label class="mo-font-darkgray w3-large">SOTTOCOMMESSA</label><br />
                    <input name="Cd_DOSottoCommessa" type="text" class="w3-margin-right w3-input w3-border" style="width: 60%" />
                    <i searchkey="Cd_DOSottoCommessa" searchtitle="SOTTOCOMMESSA" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
                </div>

                <%-- LOTTO --%>
                <div class="div-mgubi">
                    <label class="mo-font-darkgray w3-large">LOTTO</label><br />
                    <input name="Cd_ARLotto" type="text" class="w3-margin-right w3-input w3-border" style="width: 60%" />
                    <i searchkey="Cd_ARLotto" searchtitle="LOTTO" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
                </div>

                <%-- QTA POS. --%>
                <div class="div-mgubi">
                    <div class="qta">
                        <label>QTA POS.</label>
                        <div class="switch-container">
                            <label class="switch">
                                <input class="pgMGDisp-Cruscotto chk-qtapos" type="checkbox" />
                                <div></div>
                            </label>
                        </div>
                    </div>

                    <%-- BTN CONFERMA --%>
                    <div class="w3-row w3-center w3-margin-bottom">
                        <button class="btn-confirm w3-button w3-round-medium w3-large w3-red mo-mt-20" onclick="Clear_MGDisp();$('input[name=\'Cd_AR\']').focus();">REIMPOSTA</button>
                        <button class="btn-confirm w3-button w3-round-medium w3-large w3-green mo-mt-20" onclick="Confirm_MGDisp();">CERCA</button>
                    </div>
                </div>
            </div>
            <%--<label class="filtri mo-bold w3-large w3-text-blue"></label>--%>

            <%-- TABELLA GIACENZE  --%>
            <div class="div-giac">
                <label data-key="ARDescrizione" class="filtri mo-bold w3-large w3-text-blue"></label>
                <div data-key="pgMGDisp-Cruscotto" class="pgMGDisp-Cruscotto">
                    <div class="contenitore-totali">
                        <div class="totali">
                            <div class="totale">Totale:</div>
                            <div class="dettaglio">
                                <div class="tot-qta w3-text-green">
                                    <span class="label">Qta.</span>
                                    <span class="valoreTot">99999.99</span>
                                    <span class="um">pz</span>
                                </div>
                                <div class="tot-dis w3-text-orange">
                                    <span class="label">Disp.</span>
                                    <span class="valoreTot">99999.99</span>
                                    <span class="um">pz</span>
                                </div>
                                <div class="tot-dimm w3-text-blue">
                                    <span class="label">D.imm</span>
                                    <span class="valoreTot">99999.99</span>
                                    <span class="um">pz</span>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>
                <table data-key="giacenze" class="mo-table mo-mt-4 w3-table">
                    <tr>
                        <%--<th class="w3-small"></th>--%>
                        <th class="w3-small AR">AR</th>
                        <%--<th class="w3-small Descrizione cl-ardesc">Descrizione</th>--%>
                        <th class="w3-small w3-center w3-text-underline th-lotto-commessa">
                            <div class="lotto-commessa">
                                <label name="Cd_ARLotto" class="">LOTTO</label>
                                <label name="Cd_DOSottoCommessa" class="">COMMESSA</label>
                            </div>
                        </th>
                        <th class="w3-small w3-center all-QTA">
                            <div class="all-qta-roller">
                                <div name="label_qta" class="w3-text-underline w3-text-green w3-text-underline-green">QTA</div>
                                <div name="label_dis" class="w3-text-underline w3-text-orange w3-text-underline-orange">DIS.</div>
                                <div name="label_d_imm" class="w3-text-underline w3-text-blue w3-text-underline-blue">D.IMM</div>
                            </div>
                        </th>
                        <th class="w3-small w3-center">UM</th>
                        <%--<th class="w3-small w3-center">D.IMM</th>--%>
                    </tr>
                    <tr class="template_mgubi w3-border-top" style="display: none;">
                        <td class="w3-small MGUbi" colspan="4" style="font-weight: bold;"></td>
                    </tr>
                    <tr class="template_ar w3-border-top" style="display: none;">
                        <%--<td class="w3-small"></td>--%>
                        <td class="w3-small Cd_AR AR"></td>
                        <%--<td class="w3-small Descrizione cl-ardesc"></td>--%>
                        <td class="w3-small w3-right-align td-lotto-commessa"></td>
                        <td class="w3-small w3-right-align td-quantita"></td>
                        <td class="w3-small w3-center Cd_ARMisura" style="float: right;"></td>
                        <%--<td class="w3-small w3-right-align QuantitaDisp"></td>
                        <td class="w3-small w3-right-align QuantitaDimm"></td>--%>
                    </tr>
                    <%-- template non nascosto perchè ci pensano le media query --%>
                    <%--<tr class="template_ardesc w3-border-bottom tr-ardesc" style="display: none;">
                        <td class="w3-small MGUbi"></td>
                        <td class="w3-small Descrizione" colspan="5"></td>
                    </tr>--%>
                    <tr class="template_ardesc w3-border-bottom w3-light-grey tr-ardesc" style="display: none;">
                        <td class="w3-small Descrizione" colspan="4"></td>
                    </tr>
                    <tr class="w3-border-bottom tr-ardesc tr-MGUbi" style="display: none;">
                        <td class="w3-small" colspan="1">Ubi.</td>
                        <td class="w3-small MGUbi" colspan="3"></td>
                    </tr>
                    <%--<tr class="template_ardesc w3-border-bottom tr-ardesc tr-LottoCommessa">
                        <td class="w3-small LottoCommessa" colspan="5"></td>
                    </tr>--%>
                </table>
                <label class="msg"></label>
            </div>
        </div>
    </div>

    <%-- #1.0240 pgSM  --%>
    <div id="pgSM" class="mo-page w3-container">
        <div class="mo-intestazione mo-pt-5">
            <label class="">STOCCAGGIO:&nbsp;</label>
            <label class="lb-doc-id w3-large"></label>
        </div>
        <div>
            <label class="title mo-lbl">DESCRIZIONE</label>
            <br />
            <input name="Descrizione" type="text" class="mo-mr-6 w3-input w3-border" style="width: 70%;" />
        </div>
        <div class="div-mgp div-accordion mo-mt-4">
            <div class="header mo-intestazione">
                <label class="">MAGAZZINO PARTENZA&nbsp;</label>
                <i class="icon mi s30 mo-pointer w3-right">keyboard_arrow_up</i>
                <label class="cd_mg_p w3-large w3-right w3-margin-right"></label>
            </div>
            <div class="content">
                <label class="mo-lbl">MAGAZZINO PARTENZA</label><br />
                <input name="Cd_MG_P" type="text" class="input-label w3-margin-right w3-input w3-border" style="width: 150px" />
                <i searchkey="Cd_MG_P" searchtitle="MAGAZZINO DI PARTENZA" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
                <br />
                <div class="div-mgubip">
                    <label class="mo-lbl">UBICAZIONE MAGAZZINO</label><br />
                    <input name="Cd_MGUbicazione_P" type="text" class="w3-margin-right w3-input w3-border" style="width: 150px" />
                    <i searchkey="Cd_MGUbicazione_P" searchtitle="UBICAZIONE DI PARTENZA" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i><br />
                </div>
            </div>
        </div>
        <%-- MG ARRIVO --%>
        <div class="div-mga div-accordion mo-mt-4">
            <div class="header mo-intestazione">
                <label class="">MAGAZZINO ARRIVO&nbsp;</label>
                <i class="icon mi s30 mo-pointer w3-right">keyboard_arrow_up</i>
                <label class="cd_mg_a w3-large w3-right w3-margin-right"></label>
            </div>
            <div class="content">
                <label class="mo-lbl">MAGAZZINO ARRIVO</label><br />
                <input name="Cd_MG_A" type="text" class="input-label w3-large w3-margin-right w3-input w3-border" style="width: 150px" />
                <i searchkey="Cd_MG_A" searchtitle="MAGAZZINO DI ARRIVO" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
            </div>
        </div>
        <div class="mo-mt-8">
            <label class="mo-smload mo-lbllink mo-pointer w3-right w3-margin-right" onclick="oPrg.Pages[oPrg.PageIdx(enumPagine.pgSMLoad)].Enabled = true; Nav.GoToPage(PageIdx_For_GoToPage(enumPagine.pgSMLoad));">Aggiungi articoli da stoccare ></label>
        </div>
    </div>

    <%-- #1.0250 pgSMLoad --%>
    <div id="pgSMLoad" class="mo-page w3-container">
        <div>
            <div class="header mo-intestazione">
                <label class="w3-text-white lbl">CARICA ARTICOLI DA STOCCARE</label>
            </div>
            <div class="w3-container">
                <ul class="mo-smload-ul w3-ul w3-card-4" style="box-shadow: none;">
                    <li class="w3-bar">
                        <span class="smdocs w3-bar-item mo-pl-4 mo-mr-6" style="padding: 4px 4px;">
                            <input class="ck-smdocs w3-check" type="checkbox" />
                        </span>
                        <div class="w3-bar-item" style="padding: 8px 4px;">
                            <label class="etichetta">DOCUMENTI</label><br />
                            <label class="detail-smdocs mo-lbllink mo-pointer" title="Elenco documenti">Vedi elenco documenti ></label>
                            <br />
                            <label class="docs"></label>
                        </div>
                    </li>

                    <li class="w3-bar">
                        <span class="smmgubi w3-bar-item mo-pl-4 mo-mr-6" style="padding: 4px 4px;">
                            <input class="ck-smmgubi w3-check" type="checkbox" />
                        </span>
                        <div class="w3-bar-item" style="padding: 8px 4px;">
                            <label class="etichetta">ARTICOLI NON UBICATI PRESENTI NEL MAGAZZINO</label>
                        </div>
                    </li>

                    <li class="w3-bar">
                        <span class="smscorta w3-bar-item mo-pl-4 mo-mr-6" style="padding: 4px 4px;">
                            <input class="ck-smscorta w3-check" type="checkbox" />
                        </span>
                        <div class="w3-bar-item" style="padding: 8px 4px;">
                            <label class="etichetta">INTEGRA UBICAZIONI SOTTO SCORTA MINIMA</label>
                        </div>
                    </li>
                </ul>
            </div>
        </div>
    </div>

    <%-- #1.0260 pgSMRig --%>
    <div id="pgSMRig" class="mo-page w3-container">
        <div>
            <div class="header mo-intestazione">
                <label class="mo-mt-4">STOCCAGGIO:&nbsp;</label><label class="Id_xMOTR mo-mt-4"></label>
                <i class="section div-table mi s28 white mo-pointer w3-right" onclick="Ajax_xmofn_xMOTRRig_TA();">cached</i>
            </div>
            <div class="section div-table">
                <div class="w3-row">
                    <label class="mo-smload mo-lbllink mo-pointer mo-mt-4 mo-ml-5" style="text-decoration: underline;" onclick="SMRig_NewAR();">Nuovo</label>
                    <label class="switch w3-right">
                        <input class="ck-smart" type="checkbox" onclick="SMRig_TA_Load();" />
                        <span class="slider"></span>
                    </label>
                    <label class="etichetta mo-font-darkblue mo-lbllink w3-right w3-margin-right">Ordina per articolo&nbsp;</label>
                </div>
                <table class="w3-table mo-table mo-mt-4">
                    <tr>
                        <th class="mo-lbl Cd_AR">AR</th>
                        <%--<th class="w3-small Descrizione cl-ardesc">Descrizione</th>--%>
                        <%--<th class="w3-small Cd_ARLotto">LOTTO</th>--%>
                        <th class="mo-lbl w3-center">QTA</th>
                        <th class="mo-lbl w3-center">UM</th>
                        <th class="mo-lbl w3-center Cd_MGUbicazione">UBI</th>
                        <th class="mo-lbl w3-center tblOrdine">ORDINE</th>
                        <th class="mo-lbl w3-center"></th>

                    </tr>
                    <%-- Template per il OrderBy o UBI o ART --%>
                    <tr class="template_OrderBy mo-heavenly w3-border-top" style="display: none;">
                        <td class="w3-small Ordine" colspan="6"></td>
                    </tr>
                    <tr class="template w3-border-top w3-hover-light-gray mo-pointer" style="display: none;">
                        <td class="mo-lbl Cd_AR"></td>
                        <%--<td class="w3-small Descrizione cl-ardesc"></td>--%>
                        <%--<td class="w3-small Cd_ARLotto"></td>--%>
                        <td class="mo-lbl w3-right-align Quantita"></td>
                        <td class="mo-lbl w3-center Cd_ARMisura"></td>
                        <td class="mo-lbl w3-center Cd_MGUbicazione"></td>
                        <td class="mo-lbl w3-right-align tblOrdine"></td>
                        <td class="mo-lbl w3-right-align Stato"><i class='w3-hide delete mi s35 white mo-pointer w3-hover-gray' style="padding: 4px 7px; background-color: red; box-shadow: inset 0px -2px 9px 2px rgba(209,92,92,1); border-radius: 2px;" data-delete="false" onclick='$(this).attr("data-delete", true);'>delete_forever</i></td>

                    </tr>
                    <%-- template non nascosto perchè ci pensano le media query --%>
                    <tr class="template_ARDesc tr-ardesc w3-hover-light-gray mo-pointer" style="display: none;">
                        <td class="mo-lbl Descrizione" colspan="6"></td>
                    </tr>
                </table>
            </div>
            <div class="section div-input">
                <%-- MG UBI Arrivo --%>
                <div class="div-mgubia w3-row">
                    <label class="mo-lbl">UBICAZIONE</label><br />
                    <input name="Cd_MGUbicazione_P" type="text" class="w3-large w3-input w3-border" style="width: 60%; font-size: 1.3em;" />
                    <i class="detail-giacubi mi s35 mo-pointer w3-right w3-margin-right" data-inputubi="Cd_MGUbicazione_P" title="Articoli in giacenza">inbox</i>
                    <i searchkey="Cd_MGUbicazione_P" searchtitle="UBICAZIONE DI ARRIVO" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
                </div>
                <%-- MG Arrivo --%>
                <div class="div-mga w3-row w3-hide">
                    <input name="Cd_MG_A" type="text" class="w3-input" style="width: 70%; font-size: 1.3em;" />
                </div>
                <%-- Articolo --%>
                <div class=" w3-row mo-mt-4">
                    <label class="mo-lbl">ARTICOLO</label><br />
                    <input name="Cd_AR" type="text" class="w3-large w3-input w3-border" style="width: 60%; font-size: 1.3em;" />
                    <i class="detail-giacar mi s35 mo-pointer w3-right w3-margin-right" data-inputubi="Cd_MGUbicazione_A" title="Giacenza">inbox</i>
                    <i searchkey="Cd_AR" searchtitle="RICERCA ARTICOLO" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
                    <br />
                    <label class="mo-font-darkblue lbl AR_Descrizione"></label>
                </div>
                <%-- lotto --%>
                <%--<div class="w3-row mo-mt-4">
                    <label class="mo-font-darkgray mo-bold w3-large">LOTTO</label>
                    <br />
                    <input name="Cd_ARLotto" type="text" class="w3-large w3-margin-right w3-input w3-border" style="width: 100px;" />
                    <i searchkey="Cd_ARLotto" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i><br />
                </div>--%>
                <div class="div-qtaum">
                    <label class="mo-lbl">QUANTITA</label><br />
                    <input name="Quantita" type="number" class="w3-large w3-margin-right w3-input w3-border w3-right-align" style="width: 35%; font-size: 1.3em;" />
                    <select name="Cd_ARMisura" class="mo-select w3-border w3-large" style="width: 60px; font-size: 1.3em;">
                    </select>
                </div>
                <div class="w3-row w3-center mo-mt-20">
                    <button class="btn-slideshow arrow-left w3-col mo-display-inlineblock w3-center w3-blue w3-hover-blue-gray mo-pointer w3-border-0 mo-padding-10" style="width: 50%; border-right: 2px solid white !important;" onclick="$('#pgSMRig .section').hide(); $('#pgSMRig .div-table').show();">
                        <span class="w3-text-white mo-mr-6">ANNULLA</span>
                    </button>
                    <button class="btn-slideshow arrow-right w3-col mo-display-inlineblock w3-center w3-blue w3-hover-blue-gray mo-pointer w3-border-0 mo-padding-10" style="width: 50%; border-left: 2px solid white !important;" onclick="Ajax_xmosp_xMOTRRig_P_AddAR();">
                        <span class="w3-text-white mo-mr-6">AGGIUNGI</span>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <%-- #1.0270 pgSMRig_T --%>
    <div id="pgSMRig_T" class="mo-page w3-container">
        <div class="div-accordion">
            <div class="header mo-intestazione mo-pt-5">
                <label class="w3-text-white lbl">RIGA TEMP:&nbsp;</label>
                <label class="w3-text-white lbl Id_xMOTRRig_T"></label>
                <label class="w3-text-white lbl nrar w3-right"></label>
            </div>
            <div class="w3-row mo-mt-8 mo-mb-5">
                <label class="mo-smload mo-lbllink mo-pointer w3-right w3-margin-right" style="text-decoration: underline;" onclick="SM_SlideShow(false);">Salta stoccaggio dell'articolo ></label>
                <label class="smrigt-edit w3-hide mo-smload mo-lbllink mo-pointer w3-right w3-margin-right" style="text-decoration: underline;" modifica="0" onclick="SMRig_T_Edit();">Modifica</label>
                <label class="smrigt-delete w3-hide mo-smload mo-lbllink mo-pointer w3-right w3-margin-right" style="text-decoration: underline;" onclick="$('#Popup_SMRig_A_Del').attr('Id_xMOTRRig_A', $(this).attr('Id_xMOTRRig_A')).show();">Elimina</label>
            </div>
            <div class="div-input">
                <%-- MG UBI Arrivo --%>
                <div class="div-mgubia w3-row">
                    <label class="mo-font-darkgray mo-bold w3-large">UBICAZIONE</label><br />
                    <input name="Cd_MGUbicazione_A" type="text" class="w3-large w3-input w3-border" style="width: 60%; font-size: 1.3em;" />
                    <i class="detail-giacubi mi s35 mo-pointer w3-right w3-margin-right" data-inputubi="Cd_MGUbicazione_A" title="Articoli in giacenza">inbox</i>
                    <i searchkey="Cd_MGUbicazione_A" searchtitle="UBICAZIONE DI ARRIVO" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i>
                    <br />
                    <label class="mo-smload mo-lbllink mo-pointer mo-mt-4" style="text-decoration: underline;" onclick="Ajax_xmosp_xMOTRRig_T_RicercaUbicazione_Escludi();">Proponi altra ubicazione</label>
                </div>
                <%-- MG Arrivo --%>
                <div class="div-mga w3-row w3-hide">
                    <input name="Cd_MG_A" type="text" class="w3-input" style="width: 70%; font-size: 1.3em;" />
                </div>
                <%-- Articolo --%>
                <div class=" w3-row mo-mt-4">
                    <label class="mo-bold mo-font-darkgray w3-large">ARTICOLO</label><br />
                    <input name="Cd_AR" type="text" class="w3-hide w3-input" />
                    <label class="Cd_AR" style="font-size: 1.4em;"></label>
                    <i class="detail-giacar mi s35 mo-pointer w3-right w3-margin-right" data-inputubi="Cd_MGUbicazione_A" title="Giacenza">inbox</i>
                    <br />
                    <label class="mo-font-darkblue lbl AR_Descrizione"></label>
                </div>
                <%-- lotto --%>
                <%--<div class="w3-row mo-mt-4">
                    <label class="mo-font-darkgray mo-bold w3-large">LOTTO</label>
                    <br />
                    <input name="Cd_ARLotto" type="text" class="w3-large w3-margin-right w3-input w3-border" style="width: 100px;" />
                    <i searchkey="Cd_ARLotto" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i><br />
                </div>--%>
                <div class="div-qtaum">
                    <label class="mo-font-darkgray mo-bold w3-large">QUANTITA</label><br />
                    <input name="Quantita" type="number" class="w3-large w3-margin-right w3-input w3-border w3-right-align" style="width: 35%; font-size: 1.3em;" />
                    <select name="Cd_ARMisura" class="mo-select w3-border w3-large" style="width: 60px; font-size: 1.3em;">
                    </select>
                    <br />
                    <label class="lbl-qta mo-font-darkgray w3-large"></label>
                </div>
            </div>
            <div class="div-label">
                <%-- MG UBI Arrivo --%>
                <div class="div-mgubia">
                    <label class="mo-font-darkgray mo-bold w3-large">UBICAZIONE DI STOCCAGGIO</label>
                    <i class="detail-giacubi mi s35 mo-pointer w3-right w3-margin-right" data-inputubi="Cd_MGUbicazione_A" title="Articoli in giacenza">inbox</i>
                    <br />
                    <h4 class="Cd_MGUbicazione_A" style="text-align: center; font-size: 25px !important;"></h4>
                </div>
                <%-- Articolo --%>
                <div class=" w3-row mo-mt-4">
                    <label class="mo-bold mo-font-darkgray w3-large">ARTICOLO</label>
                    <i class="detail-giacar mi s35 mo-pointer w3-right w3-margin-right" title="Giacenza">inbox</i>
                    <br />
                    <label class="Cd_AR" style="font-size: 20px;"></label>
                    <label class="Cd_ARMisura w3-right w3-margin-right" style="font-size: 20px;"></label>
                    <label>&nbsp;</label>
                    <label class="Quantita w3-right" style="font-size: 20px;"></label>
                    <br />
                    <label class="AR_Descrizione mo-font-darkblue lbl" style="font-size: 15px;"></label>
                </div>
                <%-- lotto --%>
                <%--<div class="w3-row mo-mt-4">
                    <label class="mo-font-darkgray mo-bold w3-large">LOTTO</label>
                    <br />
                    <input name="Cd_ARLotto" type="text" class="w3-large w3-margin-right w3-input w3-border" style="width: 100px;" />
                    <i searchkey="Cd_ARLotto" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i><br />
                </div>--%>
            </div>
            <%-- BTN --%>
            <div class="w3-row mo-mt-8">
                <button class="btn-slideshow arrow-left w3-col mo-display-inlineblock w3-center w3-blue w3-hover-blue-gray mo-pointer w3-border-0" style="width: 50%; border-right: 2px solid white !important;" onclick="SM_SlideShow(true)">
                    <i class="mi s40 mo-va-middle">keyboard_arrow_left</i>
                </button>
                <button class="btn-slideshow arrow-right w3-col mo-display-inlineblock w3-center w3-blue w3-hover-blue-gray mo-pointer w3-border-0" style="width: 50%; border-left: 2px solid white !important;" onclick="Ajax_xmosp_xMOTRRig_TA_Save();">
                    <span class="w3-text-white mo-mr-6">SALVA</span>
                    <i class="mi s40 mo-va-middle">keyboard_arrow_right</i>
                </button>
            </div>
        </div>
    </div>

    <%-- #1.0280 pgSMPiede (PIEDE DELLO STOCCAGGIO) --%>
    <div id="pgSMPiede" class="mo-page w3-container">
        <div class="mo-intestazione">
            <label class="">SALVATAGGIO DEL TRASFERIMENTO</label>
        </div>
        <div class="mo-mt-4">
            <div class="w3-card-4 mo-padding-8">
                <span class="id-doc w3-tag w3-large w3-text-white mo-darkblue mo-bold"></span>
                <label>Del:&nbsp;</label>
                <span class="data-doc"></span>
                <br />
                <label class="desc-doc mo-bold"></label>
            </div>
            <div class="w3-row w3-centered mo-m-4">
                <div style="width: 49%;" class="mo-display-inlineblock w3-center w3-round-medium mo-darkblue w3-text-white mo-padding-8">
                    <span class="mo-bold">TOTALI</span>
                    <span class="ar-totali w3-right"></span>
                </div>
                <div style="width: 49%;" class="mo-display-inlineblock w3-center w3-round-medium mo-darkblue w3-text-white mo-padding-8">
                    <span class="mo-bold">INCOMPLETI</span>
                    <span class="ar-incompleti w3-right"></span>
                </div>
            </div>
            <div class="mo-mt-4">
                <div class="div-notepiede">
                    <label class="mo-font-darkgray mo-bold w3-large">NOTE</label><br />
                    <textarea name="NotePiede" rows="4" class="first-focus w3-large w3-margin-right w3-input w3-border"></textarea>
                </div>
                <div class="div-listener">
                    <label class="w3-large mo-bold ">LISTENER</label><br />
                    <select name="Listener" class="w3-select w3-border mo-select" onchange="Listener_Sel_Idx(this, false);">
                    </select>
                </div>
                <input type="checkbox" class="ck-print" style="display: none;" checked="checked" />
            </div>
            <div class="w3-margin-bottom mo-mt-4 w3-center">
                <button class="btn-salva w3-button w3-round-medium w3-large w3-green" onclick="$('#pgSMPiede .ck-print').prop('checked', false); Nav.Next();">SALVA</button>
            </div>
        </div>
    </div>

    <%-- #1.0300 pgPRTRAttivita Produzione Avanzata - pagina select delle attività a cui trasferire le bolle --%>
    <div id="pgPRTRAttivita" class="mo-page w3-container">
        <div class="mo-intestazione">
            <label class="">BOLLE DI LAVORAZIONE</label>
            <i class="mi s25 white mo-pointer w3-right" onclick="Ajax_xmofn_xMOPRBLAttivita();">cached</i>
        </div>
        <!-- Ricerca -->
        <div class="w3-row mo-mt-4">
            <input data-bind="SearchQuery" type="text" class="first-focus w3-margin-right w3-input w3-border" style="width: 100%" placeholder="Cerca..." onchange="PRTRAttivita_Load_Items()" />
        </div>
        <!-- Linea di produzione -->
        <div data-key="Filtri" class="w3-row mo-mt-4">
            <select data-bind="Cd_xMOLinea" class="mo-select w3-border" style="width: 100%;" onchange="PRTRAttivita_Load_Items()">
                <option value="" selected="selected">Seleziona linea di produzione</option>
            </select>
        </div>
        <!-- Filtri -->
        <div data-key="Filtri" class="w3-row mo-mt-4">
            <!-- Interne -->
            <div class="w3-col s6 d-flex items-center">
                <label class="switch">
                    <input data-bind="Interne" class="ck-alt" type="checkbox" onclick="PRTRAttivita_Load_Items()" />
                    <span class="slider round"></span>
                </label>
                <span class="mo-ml-5">Interne</span>
            </div>
            <!-- Da trasferire -->
            <div class="w3-col s6 d-flex items-center">
                <label class="switch">
                    <input data-bind="DaTrasferire" class="ck-alt" type="checkbox" onclick="PRTRAttivita_Load_Items()" />
                    <span class="slider round"></span>
                </label>
                <span class="mo-ml-5">Da trasferire</span>
            </div>
        </div>
        <div class="mo-mt-4">
            <ul class="w3-ul w3-card-4">
                <li class="template w3-bar w3-hover-light-gray mo-pointer" style="display: none;">
                    <div class="w3-row">
                        <div class="w3-col s4">
                            <span data-bind="Id_PrBL" class="mo-tag"></span>
                            <span data-bind="Bolla" class="mo-font-darkblue"></span>
                        </div>
                        <div class="w3-col s8">
                            <span data-bind="Articolo"></span>
                        </div>
                    </div>
                    <div class="w3-row">
                        <div class="w3-col s12">
                            <span data-bind="Descrizione"></span>
                            <span data-bind="Id_PrBLAttivita" class="mo-tag-green"></span>
                            <span data-bind="Mancante" class="mo-tag w3-red">!</span>
                        </div>
                    </div>
                    <div class="w3-row">
                        <div class="w3-col s8">
                            <span data-bind="Cd_xMOLinea"></span>
                        </div>
                        <div class="w3-col s4 w3-right-align">
                            <span data-bind="DataObiettivo" class="mo-font-darkgray"></span>
                        </div>
                    </div>
                </li>
            </ul>
        </div>
    </div>

    <%-- #1.0310 pgPRTRMateriale Produzione Avanzata - pagina trasferimento materiale --%>
    <div id="pgPRTRMateriale" class="mo-page w3-container">
        <!-- Riepilogo attivita -->
        <div data-key="Riepilogo" class="w3-row mo-mt-4">
            <div class="w3-col s12">
                <span data-bind="Id_PrBL" class="mo-tag"></span>
                <label data-bind="Bolla" class="mo-font-darkblue"></label>
                <span data-bind="Id_PrBLAttivita" class="mo-tag-green"></span>
                <label data-bind="Fase"></label>
            </div>
        </div>
        <!-- Materiali: Lista -->
        <div data-key="Lista">
            <div data-key="QtaUsr" class="w3-row mo-mt-4">
                <div class="w3-col s12 w3-right-align w3-margin-right">
                    <label data-bind="QtaUsrP" class="mo-font-darkgray w3-large">QUANTITA DA TRA</label>
                    <input data-bind="QtaUsrP" name="QtaUsr" type="number" class="w3-large w3-input w3-border w3-right-align" style="width: 125px; margin-right: 5px;" />
                    <select data-bind="Cd_ARMisura" name="Cd_ARMisura" class="mo-select w3-border w3-large" style="width: 60px;"></select>
                    <input data-bind="FattoreToUM1" type="hidden" />
                    <label data-bind="PercTrasferitaP" class="mo-font-darkgray w3-large w3-margin-left mo-pointer mo-underline">%</label><br />
                </div>
            </div>
            <div class="mo-intestazione">
                <label class="">MAT. DA TRA. - FASE <span data-bind="Id_PrBLAttivita"></span></label>
                <i class="mi s25 white mo-pointer w3-right" onclick="PRBLMaterialiUsr();">cached</i>
            </div>
            <div class="mo-ofy-auto">
                <table data-key="Materiali" class="mo-table mo-mt-4 w3-table w3-bordered">
                    <thead>
                        <tr>
                            <th class="w3-small">AR</th>
                            <th class="w3-small">LOTTO</th>
                            <th class="w3-small">QTA</th>
                            <th class="w3-small">UM</th>
                            <th class="w3-small"></th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr class="template mo-pointer" style="display: none;">
                            <td data-bind="Cd_AR" class="w3-small"></td>
                            <td data-bind="Cd_ARLotto" class="w3-small"></td>
                            <td data-bind="Qta" class="w3-small w3-right-align"></td>
                            <td data-bind="Cd_ARMisura" class="w3-small"></td>
                            <td data-bind="Del" class="w3-small" style="width: 55px;"></td>
                        </tr>
                    </tbody>
                </table>
                <div data-bind="Trasferisci" class="w3-col s12">
                    <div class="w3-row w3-center w3-margin-top">
                        <label class="mo-font-darkgray w3-large">% Trasf.</label>
                        <input data-bind="PercTrasferita" name="PercTrasferita" type="number" class="w3-large w3-input w3-border w3-right-align" style="width: 85px; margin-right: 5px;" />
                    </div>
                    <div class="w3-row w3-center w3-margin-bottom">
                        <button class="btn-confirm w3-button w3-round-medium w3-large w3-green mo-mt-20" onclick="Ajax_xmosp_xMOPRTR_Close()">TRASFERISCI</button>
                    </div>
                </div>
            </div>
        </div>
        <!-- Materiali: Trasferimento -->
        <div data-key="Trasferimento" style="display: none;">
            <div class="mo-intestazione mo-pointer">
                <label class="">TRASFERIMENTO</label>
                <i class="mi mo-pointer w3-right" onclick="PRTRMateriali_Load()">menu</i>
            </div>
            <div class="w3-row">
                <div class="w3-col s8">
                    <label data-bind="Cd_AR" class="mo-h4 mo-font-darkblue mo-bold lbl"></label>
                    <input type="hidden" name="Cd_AR" />
                    <label data-bind="Descrizione" class="mo-font-darkblue mo-bold lbl"></label>
                </div>
                <div class="w3-col s4">
                    <label class="switch">
                        <input data-bind="Mancante" class="ck-alt" type="checkbox" />
                        <span class="slider round danger"></span>
                    </label>
                    <span class="mo-ml-5">Mancante</span>
                </div>
                <div class="w3-col s8">
                    <label class="mo-font-darkblue lbl">LOTTO:</label>
                    <label data-bind="Cd_ARLotto" class="mo-font-darkblue mo-bold lbl"></label>
                </div>
                <div class="w3-col s12 div-qtaum mo-mt-8">
                    <label class="mo-font-darkgray w3-large">QUANTITA</label><br />
                    <input data-bind="Quantita" name="QtaRilevata" type="number" class="w3-large w3-input w3-border w3-right-align" style="width: 125px; margin-right: 5px;" />
                    <select data-bind="Cd_ARMisura" name="Cd_ARMisura" class="mo-select w3-border w3-large" style="width: 60px;"></select>
                    <input data-bind="FattoreToUM1" type="hidden" />
                    <i class="detail-giacar mi s35 mo-pointer w3-right w3-margin-right" data-mg="P" title="Giacenza">inbox</i>
                </div>
                <div class="w3-col s12 mo-mt-8">
                    <label class="lbl">PARTENZA</label><br />
                </div>
                <div class="w3-col s6">
                    <label class="mo-font-darkblue lbl">MG:</label>
                    <label data-bind="Cd_MG_P" class="mo-font-darkblue mo-bold lbl"></label>
                </div>
                <div class="w3-col s6">
                    <label class="mo-font-darkblue lbl">UBI:</label>
                    <label data-bind="Cd_MGUbicazione_P" class="mo-font-darkblue mo-bold lbl"></label>
                </div>
                <div class="w3-col s12 mo-mt-3">
                    <label class="lbl">ARRIVO</label><br />
                </div>
                <div class="w3-col s6">
                    <label class="mo-font-darkblue lbl">MG:</label>
                    <label data-bind="Cd_MG_A" class="mo-font-darkblue mo-bold lbl"></label>
                </div>
                <div class="w3-col s6">
                    <label class="mo-font-darkblue lbl">UBI:</label>
                    <label data-bind="Cd_MGUbicazione_A" class="mo-font-darkblue mo-bold lbl"></label>
                </div>
                <div class="w3-col s12 mo-mt-8">
                    <label class="lbl">LINEA PRODUZIONE</label>
                    <label data-bind="Cd_xMOLinea" class="mo-font-darkblue mo-bold lbl w3-right"></label>
                    <input data-bind="Cd_xMOLinea" type="text" class="first-focus w3-margin-right w3-input w3-border" style="width: 100%" />
                </div>
                <div class="w3-col s12 mo-mt-8">
                    <label class="lbl">NOTE</label>
                    <textarea data-bind="Note" class="w3-margin-right w3-input w3-border" style="width: 100%"></textarea>
                </div>
                <div class="w3-col s12">
                    <div class="w3-row w3-center w3-margin-bottom">
                        <button class="btn-confirm w3-button w3-round-medium w3-large w3-green mo-mt-20" onclick="Ajax_xmosp_xMOPRTRRig_Save()">CONFERMA</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- #1.0320 pgPRMPMateriale Produzione Avanzata - pagina rientro materiale --%>
    <div id="pgPRMPMateriale" class="mo-page w3-container">
        <div data-key="Lista">
            <div class="mo-intestazione">
                <label>RIENTRO MATERIALI DA PRODUZIONE</label>
                <i class="mi s25 mo-pointer w3-right mo-mt--3" onclick="Ajax_xmofn_xMOLinea(Ajax_xmofn_xMOPRMPLinea);">cached</i>
            </div>
            <div class="w3-row mo-mt-4">
                <select data-bind="Cd_xMOLinea" class="first-focus mo-select w3-border" style="width: 100%;" onchange="Ajax_xmofn_xMOPRMPLinea()">
                    <option value="" selected="selected">Seleziona linea di produzione</option>
                </select>
            </div>
            <div class="mo-ofy-auto">
                <table data-key="Materiali" data-rolling="true" class="mo-table mo-mt-4 w3-table w3-bordered">
                    <thead>
                        <tr>
                            <th class="w3-small"></th>
                            <th class="w3-small">AR</th>
                            <th class="w3-small" data-rolling-key="LOCO">LOTTO</th>
                            <th class="w3-small" data-rolling-key="LOCO">COMMESSA</th>
                            <th class="w3-small">QTA</th>
                            <th class="w3-small">BL</th>
                            <th class="w3-small"></th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr class="template mo-pointer" style="display: none;">
                            <td data-key="Rientro" class="w3-small" style="color: #3bdf00;">
                                <i class="mi mo-pointer">arrow_back</i>
                            </td>
                            <td data-bind="Cd_AR" class="w3-small"></td>
                            <td data-bind="Cd_ARLotto" class="w3-small"></td>
                            <td data-bind="Cd_DoSottoCommessa" class="w3-small"></td>
                            <td data-bind="Quantita" class="w3-small w3-right-align"></td>
                            <td data-key="Trasferimento" class="w3-small" style="color: #005fff;">
                                <i class="mi mo-pointer">arrow_forward</i>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
        <div data-key="Input" data-mode="" style="display: none;">
            <div class="mo-intestazione mo-pointer">
                <label></label>
                <i class="mi mo-pointer w3-right" onclick="PRMPMateriale_Load()">menu</i>
            </div>
            <div class="w3-row">
                <div class="w3-col s12">
                    <label data-bind="Cd_AR" class="mo-h4 mo-font-darkblue mo-bold lbl"></label>
                    <input data-bind="Cd_AR" type="hidden" name="Cd_AR" />
                    <label data-bind="Descrizione" class="mo-font-darkblue mo-bold lbl"></label>
                </div>
                <div class="w3-col s12">
                    <label class="mo-font-darkblue lbl">LOTTO:</label>
                    <label data-bind="Cd_ARLotto" class="mo-font-darkblue mo-bold lbl"></label>
                </div>
                <div class="w3-col s8 div-qtaum mo-mt-8">
                    <label class="mo-font-darkgray w3-large">QUANTITA REALE</label><br />
                    <input data-bind="Quantita_A" name="Quantita" type="number" class="first-focus w3-large w3-input w3-border w3-right-align" style="width: 75px; margin-right: 5px;" />
                    <select data-bind="Cd_ARMisura" name="Cd_ARMisura" class="mo-select w3-border w3-large" style="width: 60px;"></select>
                    <input data-bind="FattoreToUM1" type="hidden" />
                </div>
                <div data-key="MG_P" class="w3-col s12 mo-mt-8">
                    <label class="lbl">PARTENZA</label><br />
                    <div class="w3-row">
                        <div class="w3-col s6">
                            <label class="mo-font-darkblue lbl">MG: </label>
                            <label data-bind="Cd_MG_P" class="mo-font-darkblue mo-bold lbl"></label>
                        </div>
                        <div class="w3-col s6">
                            <label class="mo-font-darkblue lbl">UBI: </label>
                            <label data-bind="Cd_MGUbicazione_P" class="mo-font-darkblue mo-bold lbl"></label>
                        </div>
                    </div>
                </div>
                <div data-key="MG_A" class="w3-col s12 mo-mt-3">
                    <label class="lbl">ARRIVO</label><br />
                    <div class="w3-row">
                        <div class="w3-col s6">
                            <label class="mo-font-darkblue lbl">MG: </label>
                            <label data-bind="Cd_MG_A" class="mo-font-darkblue mo-bold lbl"></label>
                        </div>
                    </div>
                </div>
                <div data-key="MGUbicazione_A" class="w3-col s12 mo-mt-8">
                    <label class="mo-font-darkblue lbl">UBICAZIONE</label>
                    <label data-bind="Cd_MGUbicazione_A" class="mo-font-darkblue mo-bold lbl w3-right"></label>
                    <input data-bind="Cd_MGUbicazione_A" type="text" class="w3-margin-right w3-input w3-border" style="width: 100%" />
                </div>
                <div data-key="xMOLinea" class="w3-col s12 mo-mt-8">
                    <label class="mo-font-darkblue lbl">LINEA PRODUZIONE</label>
                    <label data-bind="Cd_xMOLinea" class="mo-font-darkblue mo-bold lbl w3-right"></label>
                    <input data-bind="Cd_xMOLinea" type="text" class="w3-margin-right w3-input w3-border" style="width: 100%" />
                </div>
                <div class="w3-col s12 ckCompleta mo-mt-8 d-flex items-center">
                    <label class="switch">
                        <input data-bind="xMOCompleta" class="ck-alt" type="checkbox" />
                        <span class="slider round"></span>
                    </label>
                    <span class="mo-ml-5">Completa</span>
                </div>
                <div class="w3-col s12 mo-mt-8">
                    <label class="mo-font-darkblue lbl">NOTE</label>
                    <textarea data-bind="Note" class="w3-margin-right w3-input w3-border" style="width: 100%"></textarea>
                </div>
                <div class="w3-col s12">
                    <div class="w3-row w3-center w3-margin-bottom">
                        <button class="btn-confirm w3-button w3-round-medium w3-large w3-green mo-mt-20">CONFERMA</button>
                    </div>
                </div>
            </div>
        </div>
        <div data-key="Bolle" style="display: none;">
            <div class="mo-intestazione mo-pointer">
                <label></label>
                <i class="mi mo-pointer w3-right" onclick="PRMPMateriale_Load()">menu</i>
            </div>
            <!-- Ricerca -->
            <div class="w3-row mo-mt-4">
                <input data-bind="SearchQuery" type="text" class="first-focus w3-margin-right w3-input w3-border" style="width: 100%" placeholder="Cerca..." onchange="PRMPMateriali_Bolle_Load()" />
            </div>
            <div class="w3-row">
                <div class="w3-col s12">
                    <ul class="w3-ul w3-card-4">
                        <li class="template w3-bar w3-hover-light-gray mo-pointer" style="display: none;">
                            <div class="w3-row">
                                <div class="w3-col s12">
                                    <span data-bind="Id_PrBL" class="mo-tag"></span>
                                    <span data-bind="Bolla" class="mo-font-darkblue"></span>
                                    <span data-bind="Quantita" class="w3-right"></span>
                                </div>
                            </div>
                            <div class="w3-row">
                                <div class="w3-col s12">
                                    <span data-bind="Descrizione"></span>
                                </div>
                            </div>
                            <div class="w3-row">
                                <div class="w3-col s8">
                                    <span data-bind="Cd_xMOLinea"></span>
                                </div>
                                <div class="w3-col s4 w3-right-align">
                                    <span data-bind="DataObiettivo" class="mo-font-darkgray"></span>
                                </div>
                            </div>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>

    <%-- #2.9999 pgxListaCarico --%>
    <div id="pgxListaCarico" class="mo-page w3-container">
        <div>
            <label class="title mo-font-darkgray mo-bold w3-large">LISTA CARICO</label>
            <br />
            <input name="xListaCarico" type="text" class="keypressexec w3-input w3-border w3-margin-right" style="width: 200px;" />
            <i searchkey="xListaCarico" class="search mi s35 mo-pointer w3-right w3-margin-right">search</i><br />
        </div>
        <div>
            <label class="title mo-font-darkgray mo-bold w3-large">SELEZIONA ID DOCUMENTO</label>
            <br />
            <input name="Id_DOTes" type="text" class="keypressexec first-focus w3-input w3-border w3-margin-right" style="width: 200px;" />
        </div>
        <div>
            <label class="title mo-font-darkgray mo-bold w3-large w3-margin-right">DOC</label><br />
            <select name="Cd_DO" class="mo-select w3-border" style="width: 30%"></select>
        </div>
        <div class="mo-intestazione mo-mt-4">
            <label class="">LISTE DI CARICO</label>
            <i class="mi s30 mo-pointer w3-right" onclick="Ajax_xmofn_xListaCarico();">cached</i>
        </div>
        <div class="mo-ofy-auto">
            <%-- Tabella dei documenti prelevabili --%>
            <table class="mo-table mo-mt-4 w3-table w3-bordered">
                <tr>
                    <th class="w3-small">LDC</th>
                    <th class="w3-small">DOC.</th>
                    <th class="w3-small CF">C/F</th>
                    <th class="w3-small">NR.</th>
                    <th class="w3-small">DATA</th>
                    <th class="w3-small"></th>
                </tr>
                <tr class="template" style="display: none;">
                    <td class="w3-small xListaCarico"></td>
                    <td class="w3-small Cd_DO mo-pointer mo-font-darkblue mo-underline"></td>
                    <td class="w3-small Cd_CF CF"></td>
                    <td class="w3-small NumeroDoc"></td>
                    <td class="w3-small DataDoc"></td>
                    <td class="w3-small">
                        <input class="ck-ldc w3-check" type="checkbox" onclick="xListaCarico_Check_LdC($(this));" />
                        <i class="mi s35 mo-pointer red">highlight_off</i>
                    </td>
                </tr>
            </table>
        </div>
    </div>


    <%-- #3.00 SearchAR --%>
    <div id="SearchAR" class="w3-modal mo-zindex-2001">
        <div class="w3-modal-content w3-round-medium">
            <header class="w3-container w3-amber mo-shadow">
                <h4 class="mo-font-darkblue">ARTICOLI</h4>
                <span class="w3-btn w3-large eraser-icon mo-font-darkblue" style="right: 180px" onclick="$(this).parent().parent().find('input.filtro').val('').focus().select().trigger($.Event('keyup', {which: 13}))">
                    <i class="fa fa-solid fa-eraser"></i>
                </span>

                <div class="w3-display-topright" style="margin-right: 35px">
                    <label class="container w3-right w3-margin-right w3-margin-top">
                        <label class="">Articoli Fittizi</label>
                        <input class="ck-fittizi" type="checkbox" checked="checked" />
                        <span class="checkmark blue"></span>
                    </label>
                </div>

                <span class="w3-btn w3-large font25bold  mo-font-darkblue w3-display-middleright" onclick="Search_Close();">&times;</span>
            </header>
            <div class="w3-container">
                <input filterkey="Search_AR" type="text" class="filtro mo-search mo-mt-4 w3-input" placeholder="Cerca..." style="border: 1px solid #5199ff;" />
                <br />
                <ul class="w3-ul mo-pt-8">
                    <li class="template mo-pointer mo-padding-8" style="display: none;" onclick="Search_Close($(this));">
                        <label class="mo-font-darkblue w3-large"></label>
                    </li>
                </ul>
                <label class="mo-msg w3-large mo-font-darkblue w3-padding">Ricerca...</label>
            </div>
        </div>
    </div>

    <%-- #3.01 SearchARLotto --%>
    <div id="SearchARLotto" class="w3-modal mo-zindex-2001">
        <div class="w3-modal-content w3-round-medium">
            <header class="w3-container w3-amber mo-shadow">
                <h4 class="mo-font-darkblue">LOTTO</h4>

                <span class="w3-btn w3-large eraser-icon mo-font-darkblue" style="right: 215px;" onclick="$(this).parent().parent().find('input.filtro').val('').focus().select().trigger($.Event('keyup', {which: 13}))">
                    <i class="fa fa-solid fa-eraser"></i>
                </span>

                <div class="w3-display-topright" style="margin-right: 33px">
                    <label class="container w3-right w3-margin-right w3-margin-top">
                        <label class="">Lotti con giacenza</label>
                        <input class="ck-giacpositiva" type="checkbox" checked="checked" />
                        <span class="checkmark blue"></span>
                    </label>
                </div>

                <span class="w3-btn w3-large font25bold  mo-font-darkblue w3-display-middleright" onclick="Search_Close();">&times;</span>
            </header>
            <div class="w3-container">
                <input filterkey="Search_ARLotto" type="text" class="filtro mo-search mo-mt-4 w3-input" placeholder="Cerca..." style="border: 1px solid #5199ff !important;" />
                <ul class="w3-ul mo-pt-8">
                    <li class="template mo-pointer mo-padding-8" style="display: none;" onclick="Search_Close($(this));">
                        <div class="w3-row">
                            <div class="w3-twothird">
                                <span class="cd-lotto w3-large mo-font-darkblue"></span><span>&nbsp;-&nbsp;</span><span class="desc-lotto mo-font-darkblue">&nbsp;-</span><br />
                            </div>
                            <div class="w3-third">
                                <span class="scadenza-lotto mo-font-darkgray"></span>
                            </div>
                        </div>
                        <div class="w3-row">
                            <span class="w3-small mo-font-darkblue">ARTICOLO:&nbsp;</span><span class="ar-lotto w3-small mo-font-darkblue"></span>
                            <span class="cdubi-lotto w3-small mo-font-darkblue w3-margin-left"></span>
                            <br />
                            <span class="qta-lotto mo-font-darkblue w3-small"></span>
                        </div>
                    </li>
                </ul>
                <label class="mo-msg w3-large mo-font-darkblue w3-padding">Ricerca...</label>
            </div>
        </div>
    </div>

    <%-- #3.02 SearchCF --%>
    <div id="SearchCF" class="w3-modal mo-zindex-2001">
        <div class="w3-modal-content w3-round-medium">
            <header class="w3-container w3-amber mo-shadow">
                <h4 class="title mo-font-darkblue truncate-text"></h4>

                <span class="w3-btn w3-large eraser-icon mo-font-darkblue" onclick="$(this).parent().parent().find('input.filtro').val('').focus().select().trigger($.Event('keyup', {which: 13}))">
                    <i class="fa fa-solid fa-eraser"></i>
                </span>
                <span class="w3-btn w3-large font25bold  mo-font-darkblue w3-display-middleright" onclick="Search_Close();">&times;</span>
            </header>
            <div class="w3-container">
                <div class="w3-row">
                    <img src="image/darkblue.png" class="mo-mr-6" width="20" height="14" /><label class="w3-small mo-font-darkblue w3-margin-right">senza prelievo</label>
                    <img src="image/black.png" class="mo-mr-6" width="20" height="14" /><label class="w3-small w3-text-black">con prelievo</label>
                </div>
                <input filterkey="Search_CF" type="text" class="filtro mo-search mo-mt-4 w3-input" placeholder="Cerca..." style="border: 1px solid #5199ff;" />
                <ul class="w3-ul">
                    <li class="template mo-pointer mo-padding-8 mo-font-darkblue " style="display: none;">
                        <div class="mo-display-inlineblock" style="width: 90%;">
                            <label class="cd-cf w3-large"></label>
                            <label class="desc-cf"></label>
                        </div>
                        <div class="mo-display-inlineblock w3-right" style="width: 10%; text-align: center;">
                            <i class="detail mi darkblue">account_box</i>
                        </div>
                    </li>
                </ul>
                <label class="mo-msg w3-large mo-font-darkblue w3-padding">Ricerca...</label>
            </div>
        </div>
    </div>

    <%-- #3.03 SearchCFDest --%>
    <div id="SearchCFDest" class="w3-modal mo-zindex-2001">
        <div class="w3-modal-content w3-round-medium">
            <header class="w3-container w3-amber mo-shadow">
                <h4 class="mo-font-darkblue">DESTINAZIONI</h4>

                <span class="w3-btn w3-large eraser-icon mo-font-darkblue" onclick="$(this).parent().parent().find('input.filtro').val('').focus().select().trigger($.Event('keyup', {which: 13}))">
                    <i class="fa fa-solid fa-eraser"></i>
                </span>
                <span class="w3-btn w3-large font25bold  mo-font-darkblue w3-display-middleright" onclick="Search_Close();">&times;</span>
            </header>
            <div class="w3-container">
                <input filterkey="Search_CFDest" type="text" class="filtro mo-search mo-mt-4 w3-input" placeholder="Cerca..." style="border: 1px solid #5199ff;" />
                <ul class="w3-ul">
                    <li class="template mo-pointer mo-padding-8" style="display: none;">
                        <div class="mo-display-inlineblock" style="width: 90%;">
                            <label class="cd-cfdest mo-font-darkblue w3-large"></label>
                            <label class="desc-cfdest mo-font-darkblue"></label>
                            <br />
                            <label class="cd-cf mo-font-darkblue"></label>
                        </div>
                        <div class="mo-display-inlineblock w3-right" style="width: 10%;">
                            <i class="detail mi s35 darkblue">account_box</i>
                        </div>
                    </li>
                </ul>
                <label class="mo-msg w3-large mo-font-darkblue w3-padding">Ricerca...</label>
            </div>
        </div>
    </div>

    <%-- #3.04 SearchMG --%>
    <div id="SearchMG" class="w3-modal mo-zindex-2001">
        <div class="w3-modal-content">
            <header class="w3-container w3-amber mo-shadow">
                <h4 class="title mo-font-darkblue truncate-text"></h4>

                <span class="w3-btn w3-large eraser-icon mo-font-darkblue" onclick="$(this).parent().parent().find('input.filtro').val('').focus().select().trigger($.Event('keyup', {which: 13}))">
                    <i class="fa fa-solid fa-eraser"></i>
                </span>
                <span class="w3-btn w3-large font25bold  mo-font-darkblue w3-display-middleright" onclick="Search_Close();">&times;</span>
            </header>
            <div class="w3-container">
                <input filterkey="Search_MG" type="text" class="filtro mo-search mo-mt-4 w3-input" style="border: 1px solid #5199ff;" />
                <ul class="w3-ul mo-pt-8">
                    <li class="template mo-pointer mo-pt-8" style="display: none;" onclick="Search_Close($(this));">
                        <label class="w3-large mo-font-darkblue"></label>
                    </li>
                </ul>
                <label class="mo-msg w3-large mo-font-darkblue w3-padding">Ricerca...</label>
            </div>
        </div>
    </div>

    <%-- #3.05 SearchMGUbicazione --%>
    <div id="SearchMGUbicazione" class="w3-modal mo-mo-zindex-2001" style="">
        <div class="w3-modal-content">
            <header class="w3-container w3-amber mo-shadow">
                <h4 class="title mo-font-darkblue truncate-text"></h4>
                <span class="w3-btn w3-large eraser-icon mo-font-darkblue" onclick="$(this).parent().parent().find('input.filtro').val('').focus().select().trigger($.Event('keyup', {which: 13}))">
                    <i class="fa fa-solid fa-eraser"></i>
                </span>
                <span class="w3-btn w3-large font25bold  mo-font-darkblue w3-display-middleright" onclick="Search_Close();">&times;</span>
            </header>
            <div class="w3-container">
                <select class="mo-select mo-mt-4" style="width: 100%; padding: 6px 4px;" onchange="MGUbicazione_Giac_Filter();">
                    <option style="font-size: 1.4em;" value="" selected="selected">Tutte</option>
                    <option style="font-size: 1.4em;" value="0">Vuote</option>
                    <option style="font-size: 1.4em;" value="1">Con Giac.</option>
                </select>
                <input filterkey="Search_MGUbi" type="text" class="filtro mo-search mo-mt-4 w3-input" placeholder="Cerca..." style="border: 1px solid #5199ff;" />
                <ul class="w3-ul mo-pt-8">
                    <li class="template w3-bar mo-pointer mo-padding-8" style="display: none;" onclick="Search_Close($(this));">
                        <div class="statogiac w3-bar-item w3-left" style="padding: 14px 2px !important;"></div>
                        <label class="cd_mgubicazione w3-bar-item w3-large mo-font-darkblue" style="padding: 4px 8px !important;"></label>
                        <i class="detail-giacubi w3-bar-item mi s20 black w3-right">inbox</i>
                    </li>
                </ul>
                <label class="mo-msg w3-large mo-font-darkblue w3-padding">Ricerca...</label>
            </div>
        </div>
    </div>

    <%-- #3.06 SearchDOSottoCommessa --%>
    <div id="SearchDOSottoCommessa" class="w3-modal mo-zindex-2001">
        <div class="w3-modal-content">
            <header class="w3-container w3-amber mo-shadow">
                <h4 class="title mo-font-darkblue  truncate-text">SOTTOCOMMESSE</h4>
                <span class="w3-btn w3-large eraser-icon mo-font-darkblue" onclick="$(this).parent().parent().find('input.filtro').val('').focus().select().trigger($.Event('keyup', {which: 13}))">
                    <i class="fa fa-solid fa-eraser"></i>
                </span>
                <span class="w3-btn w3-large font25bold  mo-font-darkblue w3-display-middleright" onclick="Search_Close();">&times;</span>
            </header>
            <div class="w3-container">
                <input filterkey="Search_DOSC" type="text" class="filtro mo-search mo-mt-4 w3-input" placeholder="Cerca..." style="border: 1px solid #5199ff;" />
                <ul class="w3-ul mo-pt-8">
                    <li class="template mo-pointer mo-padding-8" style="display: none;" onclick="Search_Close($(this));">
                        <label class="w3-large mo-font-darkblue"></label>
                    </li>
                </ul>
                <label class="mo-msg w3-large mo-font-darkblue w3-padding">Ricerca...</label>
            </div>
        </div>
    </div>

    <%-- #3.07 SearchDOCaricatore --%>
    <div id="SearchDOCaricatore" class="w3-modal mo-zindex-2001">
        <div class="w3-modal-content w3-round-medium">
            <header class="w3-container w3-amber mo-shadow">
                <h4 class="mo-font-darkblue">CARICATORI</h4>
                <span class="w3-btn w3-large eraser-icon mo-font-darkblue" onclick="$(this).parent().parent().find('input.filtro').val('').focus().select().trigger($.Event('keyup', {which: 13}))">
                    <i class="fa fa-solid fa-eraser"></i>
                </span>
                <span class="w3-btn w3-large font25bold  mo-font-darkblue w3-display-middleright" onclick="Search_Close();">&times;</span>
            </header>
            <div class="w3-container">
                <input filterkey="Search_DOCaricatore" type="text" class="filtro mo-search mo-mt-4 w3-input" placeholder="Cerca..." style="border: 1px solid #5199ff !important;" />
                <ul class="w3-ul mo-pt-8">
                    <li class="template mo-pointer mo-padding-8" style="display: none;" onclick="Search_Close($(this));">
                        <label class="w3-large mo-font-darkblue"></label>
                    </li>
                </ul>
                <label class="mo-msg w3-large mo-font-darkblue w3-padding">Ricerca...</label>
            </div>
        </div>
    </div>

    <%-- #3.08 SearchxMOCodSpe --%>
    <div id="SearchxMOCodSpe" class="w3-modal mo-zindex-2001">
        <div class="w3-modal-content w3-round-medium">
            <header class="w3-container w3-amber mo-shadow">
                <h4 class="mo-font-darkblue">SPEDIZIONI</h4>
                <span class="w3-btn w3-large eraser-icon mo-font-darkblue" onclick="$(this).parent().parent().find('input.filtro').val('').focus().select().trigger($.Event('keyup', {which: 13}))">
                    <i class="fa fa-solid fa-eraser"></i>
                </span>
                <span class="w3-btn w3-large font25bold  mo-font-darkblue w3-display-middleright" onclick="Search_Close();">&times;</span>
            </header>
            <div class="w3-container">
                <input filterkey="Search_xMOCodSpe" type="text" class="filtro mo-search mo-mt-4 w3-input" placeholder="Cerca..." style="border: 1px solid #5199ff !important;" />
                <ul class="w3-ul mo-pt-8">
                    <li class="template mo-pointer mo-padding-8" style="display: none;" onclick="Search_Close($(this));">
                        <div class="w3-row">
                            <div class="w3-twothird">
                                <span class="sp w3-large mo-font-darkblue"></span>
                            </div>
                            <div class="w3-third">
                                <span class="sp-ndocs mo-font-darkgray"></span>
                            </div>
                        </div>
                    </li>
                </ul>
                <label class="mo-msg w3-large mo-font-darkblue w3-padding">Ricerca...</label>
            </div>
        </div>
    </div>

    <%-- #3.09 SearchARARMisura --%>
    <div id="SearchARARMisura" class="w3-modal mo-zindex-2001">
        <div class="w3-modal-content w3-round-medium">
            <header class="w3-container w3-amber mo-shadow">
                <h4 class="mo-font-darkblue">UM</h4>
                <span class="w3-btn w3-large eraser-icon mo-font-darkblue" onclick="$(this).parent().parent().find('input.filtro').val('').focus().select().trigger($.Event('keyup', {which: 13}))">
                    <i class="fa fa-solid fa-eraser"></i>
                </span>
                <span class="w3-btn w3-large font25bold  mo-font-darkblue w3-display-middleright" onclick="Search_Close();">&times;</span>
            </header>
            <div class="w3-container">
                <input filterkey="Search_ARARMisura" type="text" class="filtro mo-search mo-mt-4 w3-input" placeholder="Cerca..." style="border: 1px solid #5199ff !important;" />
                <ul class="w3-ul mo-pt-8">
                    <li class="template mo-pointer mo-padding-8" style="display: none;" onclick="Search_Close($(this));">
                        <label class="w3-large mo-font-darkblue"></label>
                    </li>
                </ul>
                <label class="mo-msg w3-large mo-font-darkblue w3-padding">Ricerca...</label>
            </div>
        </div>
    </div>

    <%-- #3.99 SearchxListaCarico --%>
    <div id="SearchxListaCarico" class="w3-modal mo-zindex-2001">
        <div class="w3-modal-content w3-round-medium">
            <header class="w3-container w3-amber mo-shadow">
                <h4 class="mo-font-darkblue truncate-text">LISTE DI CARICO</h4>
                <span class="w3-btn w3-large eraser-icon mo-font-darkblue" onclick="$(this).parent().parent().find('input.filtro').val('').focus().select().trigger($.Event('keyup', {which: 13}))">
                    <i class="fa fa-solid fa-eraser"></i>
                </span>
                <span class="w3-btn w3-large font25bold  mo-font-darkblue w3-display-middleright" onclick="Search_Close();">&times;</span>
            </header>
            <div class="w3-container">
                <input filterkey="Search_xListaCarico" type="text" class="filtro mo-search mo-mt-4 w3-input" placeholder="Cerca..." style="border: 1px solid #5199ff !important;" />
                <ul class="w3-ul mo-pt-8">
                    <li class="template mo-pointer mo-padding-8" style="display: none;" onclick="Search_Close($(this));">
                        <div class="w3-row">
                            <div class="w3-twothird">
                                <span class="ldc w3-large mo-font-darkblue"></span>
                            </div>
                            <div class="w3-third">
                                <span class="ldc-ndocs mo-font-darkgray"></span>
                            </div>
                        </div>
                    </li>
                </ul>
                <label class="mo-msg w3-large mo-font-darkblue w3-padding">Ricerca...</label>
            </div>
        </div>
    </div>

    <%-- #4.00 DetailCF --%>
    <div id="DetailCF" class="w3-modal">
        <div class="w3-modal-content w3-round-medium" style="width: 70%;">
            <header class="w3-container mo-light-blue mo-shadow">
                <h4 class="cd-cf mo-bold w3-large w3-text-white"></h4>
                <span onclick="$('#DetailCF').hide();" class="w3-button w3-large w3-text-white font25bold w3-display-middleright">&times;</span>
            </header>
            <div class="w3-container">
                <div class="w3-row w3-section">
                    <div class="w3-col" style="width: 50px"><i class="mi s35 darkblue w3-margin-right">location_on</i></div>
                    <div class="w3-rest">
                        <label class="w3-large mo-font-darkblue indirizzo"></label>
                        <br />
                        <label class="w3-large mo-font-darkblue localita"></label>
                        <label class="w3-large mo-font-darkblue cap"></label>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- #4.01 DetailCFDest --%>
    <div id="DetailCFDest" class="w3-modal">
        <div class="w3-modal-content w3-round-medium" style="width: 70%;">
            <header class="w3-container mo-light-blue mo-shadow">
                <h4 class="cd-cfdest w3-large w3-text-white"></h4>
                <span onclick="$('#DetailCFDest').hide();" class="w3-button w3-large w3-text-white font25bold w3-display-middleright">&times;</span>
            </header>
            <div class="w3-container">
                <div class="div-indirizzo w3-row w3-section">
                    <div class="w3-col" style="width: 50px"><i class="mi s35 darkblue w3-margin-right">location_on</i></div>
                    <div class="w3-rest">
                        <label class="w3-large mo-font-darkblue indirizzo"></label>
                        <br />
                        <label class="w3-large mo-font-darkblue localita"></label>
                        <label class="w3-large mo-font-darkblue cap"></label>
                    </div>
                </div>
                <div class="div-agente w3-row w3-section">
                    <div class="w3-col" style="width: 50px;"><i class="mi s35 darkblue w3-margin-right">person</i></div>
                    <div class="w3-rest">
                        <label class="w3-large mo-font-darkblue agente"></label>
                    </div>
                </div>
                <div class="div-telefono w3-row w3-section">
                    <div class="w3-col" style="width: 50px;"><i class="mi s35 darkblue w3-margin-right">phone</i></div>
                    <div class="w3-rest">
                        <label class="w3-large mo-font-darkblue telefono"></label>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- #4.02 DetailARGiacenza --%>
    <div id="DetailARGiacenza" class="w3-modal">
        <div class="w3-modal-content w3-round-medium">
            <header class="w3-container w3-amber mo-shadow">
                <h6 class="mo-font-darkblue">GIACENZA</h6>
                <span class="w3-button w3-large font25bold mo-font-darkblue w3-display-topright" onclick="HideAndFocus('DetailARGiacenza');">&times;</span>
            </header>
            <div class="w3-container">
                <select class="mo-select mo-mt-4" style="width: 100%; padding: 6px 4px;" onchange="Articolo_Giac_Filter();">
                    <option style="font-size: 1.4em;" value="">Tutte</option>
                    <option style="font-size: 1.4em;" value="0">Vuote</option>
                    <option style="font-size: 1.4em;" value="1" selected="selected">Con Giac.</option>
                </select>
                <table class="mo-table w3-table w3-bordered mo-mt-4" data-rolling="true">
                    <tr class="">
                        <th class="mo-lbl w3-small">MG/UB</th>
                        <th class="mo-lbl w3-small" data-rolling-key="LOCO">LOTTO</th>
                        <th class="mo-lbl w3-small" data-rolling-key="LOCO">COMMESSA</th>
                        <th class="mo-lbl w3-small Quantita" data-rolling-key="QTA">QTA</th>
                        <th class="mo-lbl w3-small" data-rolling-key="QTA">DISP.</th>
                        <th class="mo-lbl w3-small" data-rolling-key="QTA">IMME.</th>
                    </tr>
                    <tr class="template" style="display: none;">
                        <td class="w3-small">
                            <label class="Cd_MG"></label>
                            <br />
                            <label class="Cd_MGUbicazione mo-pointer mo-underline mo-font-blue"></label>
                        </td>
                        <td class="w3-small Cd_ARLotto"></td>
                        <td class="w3-small Cd_DOSottoCommessa"></td>
                        <td class="w3-small w3-right-align Quantita"></td>
                        <td class="w3-small w3-right-align QuantitaDisp"></td>
                        <td class="w3-small w3-right-align QuantitaDImm"></td>
                    </tr>
                </table>
            </div>
        </div>
    </div>

    <%-- #4.03 DetailBarcode --%>
    <div id="DetailBarcode" class="w3-modal">
        <div class="w3-modal-content w3-round-medium">
            <header class="w3-container w3-amber mo-shadow">
                <h4 class="mo-font-darkblue">BARCODE</h4>
                <span class="w3-button w3-large font25bold  mo-font-darkblue w3-display-middleright" onclick="oPrg.BC.Detail_Close()">&times;</span>
            </header>
            <div class="w3-container">
                <div>
                    <div class="w3-left w3-padding w3-border-right mo-display-inlineblock" style="width: 50%;">
                        <span>TOTALI</span>
                        <label class="tot mo-font-darkblue mo-bold w3-right">0</label>
                    </div>
                    <div class="w3-right w3-padding mo-display-inlineblock" style="width: 50%;">
                        <span>ERRATE</span>
                        <label class="err mo-font-darkblue mo-bold w3-right">0</label>
                    </div>
                </div>
                <div class="barcode mo-mt-4">
                    <label class="mo-font-darkblue mo-bold w3-left w3-margin-right">Tipo di barcode</label>
                    <input type="text" class="first-focus w3-input w3-border" placeholder="Barcode..." />
                </div>
                <div class="mo-mt-4">
                    <div class="mo-intestazione">
                        <label class="">ELENCO LETTURE</label>
                    </div>
                    <%-- letture barcode --%>
                    <ul class="w3-ul mo-mt-4">
                        <li class="template mo-padding-8" style="display: none;">
                            <i class="icona mi s35 icon-find mo-display-inlineblock w3-right">launch</i>
                            <span class="numero w3-large mo-display-inlineblock mo-bold mo-font-darkblue"></span>
                            <span class="barcode mo-font-darkblue mo-display-inlineblock w3-left w3-margin-right"></span>
                            <span class="codice mo-font-darkblue"></span>
                            <br />
                            <span class="messaggio w3-small w3-margin-left"></span>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>

    <%-- #4.04 DetailDO --%>
    <div id="DetailDO" class="w3-modal">
        <div class="w3-modal-content w3-round-medium">
            <header class="w3-container w3-amber mo-shadow">
                <h4 class="doc-numero mo-font-darkblue"></h4>
                <span class="w3-button w3-large font25bold  mo-font-darkblue w3-display-middleright" onclick="HideAndFocus('DetailDO');">&times;</span>
            </header>
            <div class="w3-container" style="font-size: 0.8em;">
                <div class="mo-font-darkblue">
                    <label class="cf-descrizione"></label>
                    <br />
                    <label class="indirizzo"></label>
                    <hr class="mo-m-2" />
                    <label>ESERCIZIO:&nbsp;</label>
                    <label class="cd-mgesercizio w3-right"></label>
                    <hr class="mo-m-2" />
                    <div class="div-dataconsegna">
                        <label>CONSEGNA:&nbsp;</label>
                        <label class="dataconsegna w3-right"></label>
                        <hr class="mo-m-2" />
                    </div>
                    <div class="div-sottocommessa">
                        <label>SOTTOCOMMESSA:&nbsp;</label>
                        <label class="cd-dosottocommessa w3-right"></label>
                        <hr class="mo-m-2" />
                    </div>
                    <div class="div-riferimento">
                        <label>RIFERIMENTO:&nbsp;</label>
                        <label class="numerodocrif mo-mr-6"></label>
                        <label class="datadocrif w3-right"></label>
                        <hr class="mo-m-2" />
                    </div>
                    <div class="div-cdpg">
                        <label>PAGAMENTO:&nbsp;</label><br />
                        <label class="cd-pg"></label>
                    </div>
                    <div class="div-prelevatoda">
                        <label>PRELEVATO DA:&nbsp;</label><br />
                        <label class="prelevatoda"></label>
                        <hr class="mo-m-2" />
                    </div>
                </div>
                <div class="div-notepiede div-accordion mo-mt-4 mo-mb-4">
                    <div class="header mo-intestazione">
                        <label>NOTE PIEDE</label>
                        <i class="icon mi s30 mo-pointer w3-right">keyboard_arrow_up</i>
                    </div>
                    <div class="content">
                        <label class="notepiede lbl"></label>
                    </div>
                </div>
                <div class="w3-container mo-mt-5 mo-mb-5">
                    <table class="w3-table w3-striped">
                        <tr class="mo-mt-4  w3-text-white mo-light-blue">
                            <th class="w3-center">AR</th>
                            <th class="w3-center Cd_ARLotto">Lotto</th>
                            <th class="w3-center">UM</th>
                            <th class="w3-center">Qta</th>
                        </tr>
                        <tr class="template" style="display: none;">
                            <td class="w3-small w3-left  Cd_AR"></td>
                            <td class="w3-small w3-center Cd_ARLotto"></td>
                            <td class="w3-small w3-center Cd_ARMisura"></td>
                            <td class="w3-small w3-right  QtaEvadibile"></td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <%-- #4.05 Detail_Letture --%>
    <div id="Detail_Letture" class="w3-modal">
        <div class="w3-modal-content w3-round-medium">
            <header class="w3-container w3-amber mo-shadow">
                <h4 class="mo-font-darkblue">LETTURE</h4>
                <span class="w3-button w3-large font25bold  mo-font-darkblue w3-display-middleright" onclick="HideAndFocus('Detail_Letture');">&times;</span>
            </header>
            <div class="w3-container">
                <ul class="w3-ul">
                    <li class="template" style="display: none;">
                        <div class="mo-font-darkblue">
                            <div class="w3-row mo-pt-2 mo-pb-2">
                                <span class="id-rig w3-tag mo-darkblue w3-margin-right"></span>
                                <span class="ar-cddesc"></span>
                                <i class="delete mi s35 w3-right w3-text-red mo-pointer">delete_forever</i>
                                <hr class="mo-m-2" />
                            </div>
                            <div class="div-operatore">
                                <label>OPERATORE:&nbsp;</label>
                                <span class="cd-operatore w3-margin-right"></span>
                                <hr class="mo-m-2" />
                            </div>
                            <div>
                                <label>DEL:&nbsp;</label>
                                <span class="dataora"></span>
                                <hr class="mo-m-2" />
                            </div>
                            <div class="div-mgp">
                                <label>MG PARTENZA:&nbsp;</label>
                                <span class="cd-mg-p w3-margin-right">0001</span>
                                <span class="ubip cd-mgubicazione-p w3-right">A002</span>
                                <label class="ubip w3-right">UBI:&nbsp;</label>
                                <hr class="mo-m-2" />
                            </div>
                            <div class="div-mga">
                                <label>MG ARRIVO:&nbsp;</label>
                                <span class="cd-mg-a w3-margin-right">0009</span>
                                <span class="ubia cd-mgubicazione-a w3-right">F005</span>
                                <label class="ubia w3-right">UBI:&nbsp;</label>
                                <hr class="mo-m-2" />
                            </div>
                            <div class="div-lotto">
                                <label>LOTTO:&nbsp;</label>
                                <span class="cd-arlotto w3-margin-right">LT-001</span><br />
                                <hr class="mo-m-2" />
                            </div>
                            <div class="div-quantita">
                                <label>QUANTITA':&nbsp;</label>
                                <span class="quantita">45pl</span><br />
                                <hr class="mo-m-2" />
                            </div>
                            <div class="div-matricola">
                                <label>MATRICOLA:&nbsp;</label>
                                <span class="matricola w3-margin-right">ASSD09876WRE</span><br />
                                <hr class="mo-m-2" />
                            </div>
                            <div class="div-barcode">
                                <label>BARCODE:&nbsp;</label>
                                <span class="barcode">1234567890</span>
                            </div>
                        </div>
                    </li>
                </ul>
                <label class="mo-msg w3-large mo-font-darkblue w3-padding">Nessuna Lettura</label>
            </div>
        </div>
    </div>

    <%-- #4.06 Detail_PackingList --%>
    <div id="Detail_PackingList" class="w3-modal">
        <div class="w3-modal-content w3-round-medium">
            <header class="w3-container w3-amber mo-shadow">
                <h4 class="mo-font-darkblue">PACKING LIST</h4>
                <span class="w3-button w3-large font25bold  mo-font-darkblue w3-display-middleright" onclick="HideAndFocus('Detail_PackingList');">&times;</span>
            </header>
            <div class="w3-container">
                <div class="w3-row mo-pt-8">
                    <div class="w3-col" style="width: 100%;">
                        <table class="mo-table mo-table-br">
                            <tr class="mo-font-darkblue">
                                <th class="w3-center">NETTO</th>
                                <th class="w3-center">LORDO</th>
                                <th class="w3-center">VOLUME</th>
                            </tr>
                            <tr class="tr-pktotali">
                                <td class="w3-right-align netto"></td>
                                <td class="w3-right-align lordo"></td>
                                <td class="w3-right-align volume"></td>
                            </tr>
                        </table>
                    </div>
                    <div style="margin-top: 56px; text-align: right; padding-right: 3px;">
                        <div style="display: inline-block">
                            <label class="switch">
                                <input class="ck-pkpesi" type="checkbox" onclick="DetailPackinList_OnOffPesi($(this));" />
                                <span class="slider"></span>
                            </label>
                            <label class="mo-font-darkblue w3-large w3-left w3-margin-right">Pesi:</label>

                        </div>
                        <div style="display: inline-block">
                            <label class="switch">
                                <input class="ck-visualsing" type="checkbox" onclick="DetailPackinList_Visualizzazione($(this));" />
                                <span class="slider"></span>
                            </label>
                            <label class="mo-font-darkblue w3-large w3-left w3-margin-right">Modifica:</label>
                        </div>
                    </div>
                    <%-- <div class="w3-col mo-pt-8" style="width: 40%;">
                        <div class="w3-row w3-right">
                            <label class="switch">
                                <input class="ck-pkpesi" type="checkbox" onclick="DetailPackinList_OnOffPesi($(this));" />
                                <span class="slider"></span>
                            </label>
                            <label class="mo-font-darkblue w3-large w3-left w3-margin-right">Pesi:</label>
                        </div>
                    </div>--%>
                </div>
                <%--<div class="w3-row w3-right">
                    <label class="switch">
                        <input class="ck-visualsing" type="checkbox" onclick="DetailPackinList_Visualizzazione($(this));" />
                        <span class="slider"></span>
                    </label>
                    <label class="mo-font-darkblue w3-large w3-left w3-margin-right">Visualizzazione singola:</label>
                </div>--%>
                <div class="mo-mb-4">
                    <table class="pk-all" border="0" style="border-collapse: collapse; width: 100%;">
                        <tr class="w3-amber">
                            <th>Unità logica</th>
                            <th>QTA.</th>
                            <th>NETTO</th>
                            <th>LORDO</th>
                            <th>V</th>
                        </tr>
                        <tr class="w3-amber">
                            <th></th>
                            <th>TOT.</th>
                            <th>[kg]</th>
                            <th>[kg]</th>
                            <th>[m3]</th>
                        </tr>
                        <tr class="template-ul-header w3-padding w3-large mo-height-35" style="display: none;">
                            <td class="mo-bold w3-center mo-font-darkblue PackListRef" style="width: 160px;"></td>
                            <td class="mo-bold mo-font-darkblue w3-right-align qtaul">0</td>
                            <td class="mo-bold mo-font-darkblue w3-right-align pnul">0</td>
                            <td class="mo-bold mo-font-darkblue w3-right-align plul">0</td>
                            <td class="mo-bold mo-font-darkblue w3-right-align vul">0</td>
                        </tr>
                        <tr class="template-ul-rows" style="display: none;">
                            <td colspan="5" style="padding: 0;">
                                <table class="dati-ar mo-table-br" style="width: 100%; border: 1px solid gray;">
                                    <tr class="mo-darkblue w3-text-white">
                                        <th class="w3-center" style="width: 40px;"></th>
                                        <th class="w3-center" style="width: 120px;">AR</th>
                                        <th class="dati1 w3-center">QTA</th>
                                        <th class="dati1 w3-center">UM</th>
                                        <th class="dati2 w3-center">NETTO</th>
                                        <th class="dati2 w3-center">LORDO</th>
                                        <th class="dati2 w3-center">VOLUME</th>
                                    </tr>
                                    <tr class="template-ar" style="display: none;">
                                        <td class="w3-center"><i class="mi s30 gray mo-pointer">settings</i></td>
                                        <td class="w3-center Cd_AR"></td>
                                        <td class="dati1 w3-center Qta"></td>
                                        <td class="dati1 w3-center Cd_ARMisura"></td>
                                        <td class="dati2 w3-right-align PesoNettoKg"></td>
                                        <td class="dati2 w3-right-align PesoLordoKg"></td>
                                        <td class="dati2 w3-right-align VolumeM3"></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </div>
                <label class="mo-msg w3-large mo-font-darkblue w3-padding">Nessuna Unità Logica</label>
            </div>
        </div>
    </div>

    <%-- #4.07 Detail_MultiBarcode --%>
    <div id="Detail_MultiBarcode" class="w3-modal">
        <div class="w3-modal-content w3-round-medium">
            <header class="w3-container w3-amber mo-shadow">
                <h4 class="mo-font-darkblue">BARCODE</h4>
                <span class="w3-button w3-large font25bold  mo-font-darkblue w3-display-middleright" onclick="$('#Detail_MultiBarcode').hide();">&times;</span>
            </header>
            <div class="w3-container">
                <div class="mo-mt-4">
                    <%-- Codice letto --%>
                    <div class="mo-intestazione">
                        <label class="codBC"></label>
                    </div>
                    <%-- Elenco Interpretazioni --%>
                    <ul class="w3-ul mo-mt-4">
                        <li class="template mo-padding-8 mo-pointer" style="display: none;">
                            <%--<span class="campo w3-large mo-display-inlineblock mo-bold mo-font-darkblue"></span>--%>
                            <span class="codice mo-font-darkblue"></span>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>

    <%-- #4.08 Detail_SMDocs --%>
    <div id="Detail_SMDocs" class="w3-modal">
        <div class="w3-modal-content w3-round-medium">
            <header class="w3-container w3-amber mo-shadow">
                <h4 class="mo-font-darkblue">DOCUMENTI</h4>
                <button class="w3-button w3-blue" onclick="SMRig_P_FromDocs_Load();">CARICA</button>
                <span class="w3-button w3-large font25bold  mo-font-darkblue w3-display-middleright" onclick="HideAndFocus('Detail_SMDocs');">&times;</span>
            </header>
            <div class="w3-container">
                <%-- UL dei documenti --%>
                <ul class="w3-ul w3-card-4">
                    <li class="template w3-bar mo-padding-0" style="display: none;">
                        <div class="w3-bar-item w3-centered mo-font-darkgray">
                            <span class="id-dotes w3-large mo-font-darkblue mo-bold mo-mr-6"></span>
                            <span class="cd-do w3-large mo-pointer mo-font-darkblue mo-underline"></span>
                            <span>-</span>
                            <span class="do-desc w3-small"></span>
                            <br />
                            <span class="cd-cf"></span>
                            <br />
                            <span class="numerodoc"></span>
                            <span class="datadoc"></span>
                            <span class="ndorig"></span>
                        </div>
                        <input class="ck-documento w3-bar-item w3-right w3-large mo-pointer w3-check" type="checkbox" style="width: 40px; margin-bottom: 20px;" />
                    </li>
                </ul>
            </div>
        </div>
    </div>


    <%-- #4.09 DetailUBIGiacenza --%>
    <div id="DetailUBIGiacenza" class="w3-modal">
        <div class="w3-modal-content w3-round-medium">
            <header class="w3-container w3-amber mo-shadow">
                <h4 class="mo-font-darkblue">GIACENZA</h4>
                <span class="w3-button w3-large font25bold  mo-font-darkblue w3-display-middleright" onclick="HideAndFocus('DetailUBIGiacenza');">&times;</span>
            </header>
            <div class="w3-container">
                <table class="mo-table w3-table mo-mt-4">
                    <tr class="w3-border-bottom">
                        <th class="mo-lbl">ARTICOLO</th>
                        <th class="mo-lbl">UM</th>
                        <th class="mo-lbl Quantita">QTA</th>
                        <th class="mo-lbl">DISP.</th>
                        <th class="mo-lbl">IMME.</th>
                    </tr>
                    <tr class="template" style="display: none;">
                        <td class="w3-small Cd_AR"></td>
                        <td class="w3-small Cd_ARMisura"></td>
                        <td class="w3-small w3-right-align Quantita"></td>
                        <td class="w3-small w3-right-align QuantitaDisp"></td>
                        <td class="w3-small w3-right-align QuantitaDImm"></td>
                    </tr>
                    <%-- template non nascosto perchè ci pensano le media query --%>
                    <tr class="template_ARDesc w3-border-bottom tr-ardesc" style="display: none;">
                        <td class="w3-small Descrizione w3-text-blue" colspan="5"></td>
                    </tr>
                </table>
            </div>
        </div>
    </div>

    <%-- #4.10 Detail_NotePiede --%>
    <div id="Detail_NotePiede" class="w3-modal mo-zindex-200">
        <div class="w3-modal-content w3-round-medium">
            <header class="w3-container w3-amber mo-shadow">
                <span class="w3-right w3-xlarge w3-text-white mo-pointer" onclick="HideAndFocus('Detail_NotePiede');">&times;</span>
                <label class="title w3-xlarge w3-text-white mo-font-darkblue">Note Principali</label>
            </header>
            <ul class="w3-ul w3-card-4">
                <li class="template mo-pointer w3-white" style="display: none;">
                    <div class="mo-display-inlineblock">
                        <label class="do-info"></label>
                        <br />
                        <label class="notepiede"></label>
                    </div>
                </li>
            </ul>
            <label class="mo-msg mo-mt-20"></label>
        </div>
    </div>

    <%-- #5.00 PopupMsg --%>
    <div id="PopupMsg" class="w3-modal mo-zindex-2010">
        <div class="w3-modal-content w3-animate-zoom w3-card-4">
            <header class="w3-container mo-light-blue mo-shadow" style="height: 40px;">
                <span class="w3-right w3-xlarge w3-text-white mo-pointer" onclick="HideAndFocus('PopupMsg');">&times;</span>
                <label class="title w3-text-white w3-xlarge mo-bold">MESSAGGIO</label>
            </header>
            <div class="w3-container w3-margin w3-padding-16 mo-ofy-auto">
                <label class="msg mo-font-darkgray w3-large"></label>
                <div class="div-btn w3-row w3-margin-bottom w3-center">
                    <%-- "PopupMsg_Hide();" --%>
                    <button class="w3-button w3-round-medium w3-green" onclick="HideAndFocus('PopupMsg');" style="padding: 8px 16px !important;">Ok</button>
                </div>
            </div>
        </div>
    </div>

    <%-- #5.01 Popup_DocAperti_Del (CONFERMA ELIMINAZIONE DOCUMENTO APERTO) --%>
    <div id="Popup_DocAperti_Del" class="w3-modal mo-zindex-2002">
        <div class="w3-modal-content w3-animate-zoom w3-card-4">
            <header class="w3-container mo-light-blue mo-shadow" style="height: 40px;">
                <span class="mo-pointer w3-xlarge w3-right w3-text-white" onclick="HideAndFocus('Popup_DocAperti_Del');">&times;</span>
                <label class="w3-text-white w3-xlarge mo-bold">ELIMINA</label>
            </header>
            <div class="w3-container w3-margin w3-padding-16 mo-ofy-auto">
                <label class="mo-font-darkgray mo-bold w3-large">Confermare l'eliminazione del documento?</label>
                <div class="w3-row w3-margin w3-center">
                    <button class="w3-button w3-round-medium w3-large w3-green" onclick="DocAperti_DeleteIt($('#Popup_DocAperti_Del').attr('iddoc'));">CONFERMA</button>
                    <button class="w3-button w3-round-medium w3-large w3-blue" onclick="HideAndFocus('Popup_DocAperti_Del');">ANNULLA</button>
                </div>
            </div>
        </div>
    </div>

    <%-- #5.02 Popup_Del_Lettura (CONFERMA ELIMINAZIONE LETTURA) --%>
    <div id="Popup_Del_Lettura" class="w3-modal mo-zindex-2010">
        <div class="w3-modal-content w3-animate-zoom w3-card-4">
            <header class="w3-container mo-light-blue mo-shadow" style="height: 40px;">
                <span class="mo-pointer w3-xlarge w3-right w3-text-white" onclick="$('#Popup_Del_Lettura').hide();">&times;</span>
                <label class="w3-text-white w3-xlarge mo-bold">ELIMINA</label>
            </header>
            <div class="w3-container w3-margin w3-padding-16 mo-ofy-auto">
                <label class="mo-font-darkgray w3-large">Confermare l'eliminazione?</label>
                <div class="w3-row w3-margin w3-center">
                    <button class="w3-button w3-round-medium w3-green" onclick="Delete_Lettura($('#Popup_Del_Lettura').attr('Id_Del'));">CONFERMA</button>
                    <button class="w3-button w3-round-medium w3-blue" onclick="$('#Popup_Del_Lettura').hide();">ANNULLA</button>
                </div>
            </div>
        </div>
    </div>

    <%-- #5.03 Popup_Delete_Last_Read (CONFERMA ELIMINAZIONE DELL'ULTIMA LETTURA) --%>
    <div id="Popup_Delete_Last_Read" class="w3-modal mo-zindex-2010">
        <div class="w3-modal-content w3-animate-zoom w3-card-4">
            <header class="w3-container mo-light-blue mo-shadow" style="height: 40px;">
                <span class="mo-pointer w3-xlarge w3-right w3-text-white" onclick="HideAndFocus('Popup_Delete_Last_Read');">&times;</span>
                <label class="w3-text-white w3-xlarge mo-bold">ELIMINA</label>
            </header>
            <div class="w3-container w3-margin w3-padding-16 mo-ofy-auto">
                <label class="mo-font-darkgray w3-large">Confermare l'eliminazione dell'ultima lettura?</label>
                <div class="w3-row w3-margin w3-center">
                    <button class="w3-button w3-round-medium w3-green" onclick="Delete_Last_Read();">CONFERMA</button>
                    <button class="w3-button w3-round-medium w3-blue" onclick="HideAndFocus('Popup_Delete_Last_Read');">ANNULLA</button>
                </div>
            </div>
        </div>
    </div>

    <%-- #5.04 Popup_Button_OpConfirm (RICHIESTA CONFERMA DELL'OPERATORE PER I CONTROLLI DAL BOTTONE CONFERMA DELLA PG) --%>
    <div id="Popup_Button_OpConfirm" class="w3-modal mo-zindex-2002">
        <div class="w3-modal-content w3-animate-zoom w3-card-4">
            <header class="w3-container w3-red mo-shadow" style="height: 40px;">
                <span class="w3-right w3-xlarge w3-text-white mo-pointer" onclick="HideAndFocus('Popup_Button_OpConfirm');">&times;</span>
                <label class="title w3-text-white w3-xlarge mo-bold">RICHIESTA CONFERMA</label>
            </header>
            <div class="w3-container w3-margin w3-padding-16 mo-ofy-auto">
                <label class="msg mo-font-darkgray w3-large"></label>
                <br />
                <label class="mo-font-darkgray w3-large mo-mt-4">Vuoi continuare?</label>
                <div class="div-btn w3-row w3-margin w3-center">
                    <button class="w3-button w3-round-medium w3-green" onclick="Confirm_Read(false); $('#Popup_Button_OpConfirm').hide();">SI</button>
                    <button class="w3-button w3-round-medium w3-blue" onclick="HideAndFocus('Popup_Button_OpConfirm');">NO</button>
                </div>
            </div>
        </div>
    </div>

    <%-- #5.05 Popup_Sscc_OpConfirm (RICHIESTA CONFERMA DELL'OPERATORE PER I CONTROLLI) --%>
    <div id="Popup_Sscc_OpConfirm" class="w3-modal mo-zindex-2002">
        <div class="w3-modal-content w3-animate-zoom w3-card-4">
            <header class="w3-container w3-red mo-shadow" style="height: 40px;">
                <span class="w3-right w3-xlarge w3-text-white mo-pointer" onclick="HideAndFocus('Popup_Sscc_OpConfirm');">&times;</span>
                <label class="title w3-text-white w3-xlarge mo-bold">RICHIESTA CONFERMA</label>
            </header>
            <div class="w3-container w3-margin w3-padding-16 mo-ofy-auto">
                <label class="msg mo-font-darkgray w3-large"></label>
                <br />
                <label class="mo-font-darkgray w3-large mo-mt-4">Vuoi continuare?</label>
                <div class="div-btn w3-row w3-margin w3-center">
                    <button class="sscc-ok w3-button w3-round-medium w3-green" onclick="Ajax_Sscc_Validate($(this).attr('bc_val'), $(this).attr('id_lettura'), false); HideAndFocus('Popup_Sscc_OpConfirm');">SI</button>
                    <button class="w3-button w3-round-medium w3-blue" onclick="HideAndFocus('Popup_Sscc_OpConfirm');">NO</button>
                </div>
            </div>
        </div>
    </div>

    <%-- #5.06 Popup_PackList_New (AGGIUNGE UNA NUOVA UNITA' LOGICA ALLA PACKING LIST) --%>
    <div id="Popup_PackList_New" class="w3-modal mo-zindex-2002">
        <div class="w3-modal-content w3-animate-zoom w3-card-4">
            <header class="w3-container w3-amber mo-shadow" style="height: 40px;">
                <span class="w3-right w3-xlarge w3-text-white mo-pointer" onclick="HideAndFocus('Popup_PackList_New');">&times;</span>
                <label class="title w3-text-white w3-xlarge mo-bold">NUOVA UNITA' LOGICA</label>
            </header>
            <div class="w3-container w3-center w3-margin w3-padding-16 mo-ofy-auto">
                <label class="packlist mo-font-darkgray mo-bold w3-large"></label>
                <br />
                <label class="mo-font-darkgray mo-bold w3-large">CODICE:&nbsp;&nbsp;&nbsp;</label>
                <input name="PackListRef" type="text" class="w3-large w3-margin-right w3-input w3-right-align w3-border" style="width: 60%" />
                <div class="mo-mt-4">
                    <label class="mo-font-darkgray mo-bold w3-large w3-margin-top">TIPO UL:&nbsp;</label>
                    <select name='Cd_xMOUniLog' class="mo-select w3-border" style="width: 60%;">
                        <option value="" selected="selected">Seleziona tipo di UL</option>
                    </select>
                </div>
                <div class="div-btn w3-row w3-margin w3-center">
                    <button class="w3-button w3-round-medium w3-green" onclick="Ajax_xmosp_xMORLPackListRef_Add();">OK</button>
                    <button class="w3-button w3-round-medium w3-blue" onclick="HideAndFocus('Popup_PackList_New');">ANNULLA</button>
                </div>
            </div>
        </div>
    </div>

    <%-- #5.07 Popup_PKListAR_DelShift (ELIMINA O SPOSTA UN ARTICOLO DELLA PACKING) --%>
    <div id="Popup_PKListAR_DelShift" class="w3-modal mo-zindex-2002">
        <div class="w3-modal-content w3-animate-zoom w3-card-4">
            <header class="w3-container w3-amber mo-shadow" style="height: 40px;">
                <span class="w3-right w3-xlarge w3-text-white mo-pointer" onclick="$('#Popup_PKListAR_DelShift').hide();">&times;</span>
                <label class="title w3-text-white w3-xlarge mo-bold">DETTAGLIO</label>
            </header>
            <div class="div-container w3-container w3-margin-top w3-padding-16">
                <h5 class="Cd_AR mo-font-darkblue mo-bold w3-center"></h5>
                <label class="mo-font-darkgray mo-bold w3-large mo-mr-6">QUANTITA:</label>
                <input name="Qta" type="number" class="w3-large w3-margin-right w3-input w3-border w3-right-align" style="width: 35%" />
                <label class="Cd_ARMisura mo-font-darkgray mo-bold w3-large mo-ml-5"></label>
                <br />
                <br />
                <label class="mo-font-darkgray mo-bold w3-large mo-mr-6">SPOSTA IN:</label>
            </div>
            <div class="w3-container w3-center" style="padding: 15px !important;">
                <i action="shift" class="mi s40 orange mo-pointer" title="Sposta tutta o una parte della qta in un'altra unità logistica">wrap_text</i>
                <i action="delete" class="mi s40 red mo-pointer w3-margin-right w3-margin-left" title="Cancella tutta o una parte della qta">delete</i>
                <i class="mi s40 blue mo-pointer" onclick="$('#Popup_PKListAR_DelShift').hide();" title="Annulla">cancel</i>
            </div>
        </div>
    </div>

    <%-- #5.08 Popup_INAperti_Del (CONFERMA ELIMINAZIONE INVENTARIO APERTO) --%>
    <div id="Popup_INAperti_Del" class="w3-modal mo-zindex-2002">
        <div class="w3-modal-content w3-animate-zoom w3-card-4">
            <header class="w3-container mo-light-blue mo-shadow" style="height: 40px;">
                <span class="mo-pointer w3-xlarge w3-right w3-text-white" onclick="$('#Popup_INAperti_Del').hide();">&times;</span>
                <label class="w3-text-white w3-xlarge mo-bold">ELIMINA</label>
            </header>
            <div class="w3-container w3-margin w3-padding-16 mo-ofy-auto">
                <label class="mo-font-darkgray w3-large">Confermare l'eliminazione dell'inventario?</label>
                <div class="w3-row w3-margin w3-center">
                    <button class="w3-button w3-round-medium w3-green" onclick="INAperti_DeleteIt($('#Popup_INAperti_Del').attr('id_xmoin'));">CONFERMA</button>
                    <button class="w3-button w3-round-medium w3-blue" onclick="$('#Popup_INAperti_Del').hide();">ANNULLA</button>
                </div>
            </div>
        </div>
    </div>

    <%-- #5.09 Popup_ARAlias_Insert (RICHIESTA DI APERTURA PAGINA PER INSERIMENTO ALIAS) --%>
    <div id="Popup_ARAlias_Insert" class="w3-modal mo-zindex-2002">
        <div class="w3-modal-content w3-animate-zoom w3-card-4">
            <header class="w3-container w3-red mo-shadow" style="height: 40px;">
                <span class="w3-right w3-xlarge w3-text-white mo-pointer" onclick="HideAndFocus('Popup_ARAlias_Insert');">&times;</span>
                <label class="title w3-text-white w3-large mo-bold">Acquisizione Alias/Alternativi</label>
            </header>
            <div class="w3-container w3-margin w3-padding-16 mo-ofy-auto">
                <label class="msg mo-font-darkgray w3-large"></label>
                <br />
                <label class="mo-font-darkgray w3-small mo-mt-4">Vuoi andare all'inserimento?</label>
                <div class="div-btn w3-row w3-margin w3-center">
                    <button class="w3-button w3-round-medium w3-green" style="width: 100%; padding: 4px 0px; margin-bottom: 4px;" onclick="GoTo_Prg_AA('ALI');">Alias</button><br />
                    <button class="w3-button w3-round-medium w3-green" style="width: 100%; padding: 4px 0px; margin-bottom: 4px;" onclick="GoTo_Prg_AA('ALT');">Alternativi</button><br />
                    <button class="w3-button w3-round-medium w3-blue" style="width: 100%; padding: 4px 0px;" onclick="HideAndFocus('Popup_ARAlias_Insert');">Annulla</button>
                </div>
            </div>
        </div>
    </div>

    <%-- #5.10 Popup_TRAperti_Del (CONFERMA ELIMINAZIONE DEL TRASFERIMENTO APERTO) --%>
    <div id="Popup_TRAperti_Del" class="w3-modal mo-zindex-2002">
        <div class="w3-modal-content w3-animate-zoom w3-card-4">
            <header class="w3-container mo-light-blue mo-shadow" style="height: 40px;">
                <span class="mo-pointer w3-xlarge w3-right w3-text-white" onclick="HideAndFocus('Popup_TRAperti_Del');">&times;</span>
                <label class="w3-text-white w3-xlarge mo-bold">ELIMINA</label>
            </header>
            <div class="w3-container w3-margin w3-padding-16 mo-ofy-auto">
                <label class="mo-font-darkgray mo-bold w3-large">Confermare l'eliminazione del trasferimento?</label>
                <div class="w3-row w3-margin w3-center">
                    <button class="w3-button w3-round-medium w3-large w3-green" onclick="TRAperti_DeleteIt($('#Popup_TRAperti_Del').attr('idtr'));">CONFERMA</button>
                    <button class="w3-button w3-round-medium w3-large w3-blue" onclick="HideAndFocus('Popup_TRAperti_Del');">ANNULLA</button>
                </div>
            </div>
        </div>
    </div>

    <%--#5.11 Popup_SMRig_A_Del--%>
    <div id="Popup_SMRig_A_Del" class="w3-modal mo-zindex-2002">
        <div class="w3-modal-content w3-animate-zoom w3-card-4">
            <header class="w3-container mo-light-blue mo-shadow" style="height: 40px;">
                <span class="mo-pointer w3-xlarge w3-right w3-text-white" onclick="HideAndFocus('Popup_SMRig_A_Del');">&times;</span>
                <label class="w3-text-white w3-xlarge mo-bold">ELIMINA</label>
            </header>
            <div class="w3-container w3-margin w3-padding-16 mo-ofy-auto">
                <label class="mo-font-darkgray mo-bold w3-large">Confermare l'eliminazione della riga stoccata?</label>
                <div class="w3-row w3-margin w3-center">
                    <button class="w3-button w3-round-medium w3-large w3-green" onclick="SMRig_A_DeleteIt($('#Popup_SMRig_A_Del').attr('Id_xMOTRRig_A'));">CONFERMA</button>
                    <button class="w3-button w3-round-medium w3-large w3-blue" onclick="HideAndFocus('Popup_SMRig_A_Del');">ANNULLA</button>
                </div>
            </div>
        </div>
    </div>

    <%--#5.12 Popup_UserPref (elenco preferenze utente)--%>
    <div id="Popup_UserPref" class="w3-modal mo-zindex-2002">
        <div class="w3-modal-content w3-animate-zoom w3-card-4">
            <header class="w3-container mo-light-blue mo-shadow" style="height: 40px;">
                <span class="mo-pointer w3-xlarge w3-right w3-text-white" onclick="HideAndFocus('Popup_UserPref');">&times;</span>
                <label class="w3-text-white w3-xlarge mo-bold">PREFERENZE</label>
            </header>
            <div class="w3-container " style="padding: 10px !important;">
                <label>Altezza elenco articoli in letture</label>
                <input data-up="altezzaLetture" class="w3-large w3-margin-right w3-input w3-border" style="width: 100px; text-align: right;" type="number" min="100" max="600" value="150" /><span> px</span>
            </div>
            <div class="w3-container w3-margin w3-padding-16 mo-ofy-auto">
                <div class="w3-row w3-margin w3-center">
                    <button class="w3-button w3-round-medium w3-large w3-green" onclick="UserPref_Save();">CONFERMA</button>
                    <button class="w3-button w3-round-medium w3-large w3-blue" onclick="HideAndFocus('Popup_UserPref');">ANNULLA</button>
                </div>
            </div>
        </div>
    </div>

    <%-- #5.70 Popup_BC_Select --%>
    <div id="Popup_BC_Select" class="w3-modal lg-zindex-202">
        <div class="w3-modal-content lg-mw-500">
            <div class="w3-yellow" style="height: 4px;">
            </div>
            <div class="w3-container w3-margin-top">
                <div class="w3-row w3-centered">
                    <div class="we-col s12">
                        <label class="lg-popuptitle lg-mt-5 w3-margin-right">Seleziona Barcode</label>
                        <ol data-key="BarcodeList"></ol>
                    </div>
                </div>
                <div class="w3-row w3-margin-top w3-margin-bottom">
                    <div class="w3-col w3-center ">
                        <button class="lg-btn-white">Chiudi</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

</body>
</html>
