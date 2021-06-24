/*
    // Global.js
    // Contiene tutte le funzioni e gli oggetti globali del programma

    // DATA E ULTIMA VERSIONE RILASCIATA
    // Ver 1.010 (0.6.000) Del 17/02/2021

    // DATA ULTIMA MODIFICA ALL'INTERA SOLUZIONE
    // 04/11/2020
*/

var DEBUG = false;

var Versione = "1.11 (W15)";

/* Enumeratore delle pagine di Moovi */
var enumPagine = {
    "pgHome": 1
    , "pgRL": 2
    , "pgTR": 3
    , "pgDocAperti": 4
    , 'pgTRRig_P': 5
    , 'pgTRRig_A': 6
    , 'pgDOPrelievi': 7                     // Pagina dei doc prelevabili di una DOTes già definita (prg DO)
    , 'pgRLRig': 8
    , 'pgSscc': 9
    , 'pgRLPiede': 10
    , 'pgStampaDocumento': 11
    , 'pgAvviaConsumo': 12
    , 'pgSottoMenu': 13
    , 'pgxListaCarico': 14                  // Pers: Lista di carico
    , 'pgLog': 15                           // Pagina di log
    , 'pgDocRistampa': 16                   // Pagina fittizia che avvia pgListener quando clicco su 'Stampa Doc' del menu laterale
    , 'pgPrelievi': 17                      // Pagina del prg PR contenente tutti i doc prelevabili
    , 'pgTRPiede': 18
    , 'pgIN': 19                            // Pagina di testa dell'inventario
    , 'pgINRig': 20                         // Righe dell'inventario con l'elenco degli articoli da inventariare
    , 'pgINPiede': 21
    , 'pgINAperti': 22                      // Elenco degli inventari aperti
    , 'pgSP': 23                            // Spedizione
    , 'pgRLPK': 24                          // Pack List
    , 'pgAA': 25                            // Acquisizione alias
    , 'pgMGDisp': 26                        // Interrogazione magazzino
    , 'pgSM': 27
    , 'pgSMRig': 28                         // Elenco articoli da stoccare
    , 'pgSMRig_T': 29                       // Lettura dell'articolo stoccato
    , 'pgSMPiede': 30
    , 'pgSMLoad': 31                        // Pagina per selezionare le opzioni da cui caricare gli articoli da stoccare 
    , 'pgPRTRAttivita': 32                  // Pagina trasferimento materiali attività
    , 'pgPRTRMateriale': 33                 // Pagina trasferimento materiali 
    , 'pgPRMPMateriale': 34                 // Pagina rientro materiali 
};

//Enumeratore browser
var enumBrowser = {
    "Unknow": 0
    , "Chrome": 1
    , "Explorer": 2
    , "Mozilla": 3
}

/**
 * Oggetto oApp:
 * Contiene tutte le variaibli e gli oggetti necessari per la gestione dell'applicaizone
 * viene ripulita in fase di Login
 */
var oApp = {
    "Logon": false,             // = true se il login è andato a buon fine.
    "Cd_Operatore": null,       // Codice dell'operatore loggato
    "Terminale": null,          // Indirizzo ip del terminale loggato
    "Browser": null,            // Tipo di browser
    "BrowserType": null,        // 0 = Unknow, 1 = Chrome, 2 = Explorer, 3 = Mozilla
    //### DA CAMBIARE CON LA GESTIONE DEL Id_xMOListener e non ListenerIP!
    "ListenerIP": null,         // Indirizzo ip del listener
    "SetFocus": null,           //Tipologia di set focus del terminale (0 = disattivo; 1 = tipologia 1(?) standard)
    "LicF_Id": null,            // Cod lic
    "MRP_Advanced": false,      // Produzione avanzata
    "PressTimer": 0,            // Timer usato per intercettare il long press (detail packing list) per replicare l'evento taphold
    "SottoMenuAttivo": null,    // Elementi da visualizzare nel sotto menu, indica anche che in GoHome devo gestire il sotto menu se != null
    "xMOImpostazioni": {        // Oggetto impostazioni globali di Moovi
        "MovTraAbilita": false,
        "MovTraUbicazione": false,
        "MovTraLotto": false,
        "MovTraDescrizione": "",
        "MovTraCommessa": false,
        "MovInvAbilita": false,
        "MovInvUbicazione": false,
        "MovInvLotto": false,
        "MovInvDescrizione": "",
        "MovInvCommessa": false,
        "SpeAbilita": false,
    },
    "xMOImpostazioniWeb": {
        "PackingList": false,
    },
    "dtPrograms": null,         // Array dei pgrogrammi utilizzati per la navigazione tra le pagine di moovi
    "dtDO": null,               // Array dei documenti gestiti da Moovi (sotto menu)
    "dtxMOLinea": null,         // Array delle liene di produzione
    "dtxMOListener": null,      // Array dei listener disponibili
    "ActiveListenerIdx": null,     // Idx dell'Array dei listener 
    "dtxMOMenu": null,          // Array dei menù utente disponibili 
    "Messages": null,           // Messaggi della sessione corrente
    "TipoAA": 'ALI'             // Indica la modalità di visualizzazione della pagina pgAA per inserimento alias (ALI) o alternativo (ALT), parametro inserito in oApp in modo che rimanga impostato per tutta la sessione
}

// Si occupa del reset delle variabili dell'oggetto
var oApp_Reset = function () {
    oApp.Logon = false;
    oApp.Cd_Operatore = null;
    oApp.Terminale = null;
    oApp.Browser = null;
    oApp.BrowserType = 0;
    oApp.SetFocus = null;
    oApp.LicF_Id = null;
    oApp.MRP_Advanced = false;
    oApp.PressTimer = 0;
    oApp.dtPrograms = null;
    oApp.dtDO = null;
    oApp.dtxMOLinea = null;
    oApp.dtxMOListener = null;
    oApp.ActiveListenerIdx = null;
    oApp.dtxMOMenu = null;
    oApp.dixMOARMisura = null;
    // xMOImpostazioni
    oApp.xMOImpostazioni.MovTraAbilita = false;
    oApp.xMOImpostazioni.MovTraUbicazione = false;
    oApp.xMOImpostazioni.MovTraLotto = false;
    oApp.xMOImpostazioni.MovTraDescrizione = "";
    oApp.xMOImpostazioni.MovTraCommessa = false;
    oApp.xMOImpostazioni.MovInvAbilita = false;
    oApp.xMOImpostazioni.MovInvUbicazione = false;
    oApp.xMOImpostazioni.MovInvLotto = false;
    oApp.xMOImpostazioni.MovInvDescrizione = "";
    oApp.xMOImpostazioni.MovInvCommessa = false;
    oApp.xMOImpostazioni.SpeAbilita = false;
    // NON SVUOTO MAI LA CODA DEI MESSAGGI oApp.Messages = [];
    oApp.TipoAA = 'ALI';
}

// Oggetto contenente il programma precedente se necessario tornare indietro
// viene clonato dall'oggetto oPrg
var oPrg_Back;

// Si occupa di aggiungere un programma al dtPrograms
var oApp_AddProg = function (prog) {
    if (fU.IsNull(oApp.dtPrograms)) oApp.dtPrograms = {};
    var prg = { "Key": prog, "Pages": [], "ActivePageIdx": -1, "ActivePageId": "", "ActivePageValue": null };
    oApp.dtPrograms[prog] = prg;
}

// Si occupa di aggiungere le pagine ad un elemento del dtPrograms
var oApp_AddPage2Prog = function (prog, page, enabled) {
    var page = { "Key": fPage.GetPageKey(parseInt(page)), "Value": parseInt(page), "Enabled": enabled, "Next": false, "Back": true, "GoHome": false };
    //Verifica se è la prima pagina
    if (oApp.dtPrograms[prog].Pages && oApp.dtPrograms[prog].Pages.length == 0) {
        // Assegno l'indice
        oApp.dtPrograms[prog].ActivePageIdx = 0;
        // Assegno il nome
        oApp.dtPrograms[prog].ActivePageId = page.Key;
        // Assegno il value
        oApp.dtPrograms[prog].ActivePageValue = page.Value;
        //Ultima pagina: GoHome = true
        oApp.dtPrograms[prog].GoHome = true;
    } else {
        //Le pagina corrente (maggiore di zero) abilita il next alla pagina precedente
        var lastpage = oApp.dtPrograms[prog].Pages.length - 1;
        oApp.dtPrograms[prog].Pages[lastpage].Next = true;
    }
    // Aggiungo la pagina al programma
    oApp.dtPrograms[prog].Pages.push(page);
}

/**
 * Oggetto oPrg:
 * Contiene il programma attivo in questo momento, viene interamente gestito dall'oggetto Nav
 * viene ripulita nella home
 */
var oPrg = {

    // TUTTE LE VARIABILI DEVONO ESSERE GESTITE NEL RESET!

    "Key": null,                                // Key del programma corrente
    "Pages": null,                              // Array contenente le pagine 
    "ActivePageIdx": null,                      // Indice della pagina correntemente attiva
    "ActivePageId": null,                       // Nome della pagina correntemente attiva
    "ActivePageValue": null,                    // Valore equivalente a enumPagine per la pagina corrente (es. ActivePageId = "pgRL"; ActivePageValue = 3)
    "Id_xMORL_Edit": null,                      // Identificativo univoco della testa del documento di Moovi che sto editando  
    "Id_xMOTR_Edit": null,                      // Identificativo univoco della testa del trasferimento di Moovi che sto editando  
    "Id_xMOIN_Edit": null,                      // Identificativo univoco della testa dell'inventariooPrg.Load
    "Id_DOTes": null,                           // Identificativo univoco della testa del documento di ARCA che sto editando in questo momento (es.: utile alla ristampa, ecc)
    "drDO": null,                               // Riga dell'array oApp.dtDO selezionato
    "drRL": null,                               // Riga della testa della rilevazione
    "drTR": null,                               // Riga della testa del Trasferimento
    "BC": null,                                 // Barcode abilitati per il programma 
    "ActiveSearchId": null,                     // Indice della pagina correntemente attiva
    "ActiveSearchOutField": null,               // Contiene il nome del campo utile per l'aggiornamento dei dati selezionati nella pagina corrente
    "ActiveSearchValue": null,                  // Contiene il valore selezionato esternamente alla ricerca
    "RL": {
        "ARIncompleti": 0,                      // Articoli del prelievo non completamente evasi
        "ARCompleti": 0,                        // Articoli del prelievo completamente evasi
        "Letture": 0,                           // Numero di letture effettuate nel prelievo corrente
        "ResetAll": function () {
            this.ARIncompleti = 0;
            this.ARCompleti = 0;
            this.Letture = 0;
        }
    },
    "PK": {
        "dtxMORLPK": null,                      // Array contenente l'elenco dei PackListRef del documento sulla quale si sta facendo pack list   
        "idx": null,                            // Indice del dtxMORLPK corrente
        "PackListRef": "",                      // Numero del pacco di cui visualizzare il detail dei pesi e volumi (se vuoto voglio tutti i packlistref del documento)
        "RLPKDetail": false,                    // Variabile per aperire la pgRLPK come detail (true visualizza i dati solo del packlistref selezionato sul select di pgRLRig)
        "ResetAll": function () {
            this.dtxMORLPK = null;
            this.idx = null;
        }
    },
    "IN": {                                     // Gestione INVENTARIO
        "Tipo": "",                             // M --> Inventario Massivo, P --> Inventario Puntuale
        "drIN": null,                           //Dati di testa di IN 
        "dtxMOINRig": null,                     // Array contenente l'elenco degli articoli da inventariare
        "idx": null,                            // Id riferito alla posizione nel dt degli AR della riga visualizzata nel dettaglio
        //Utili per l'inserimento di una nuova riga di inventario
        "AddNew": false,                        // Modalità con cui è aperto il dettaglio dell'inventario (false = modalita dettaglio riga esistente, true = modalità add new ar)
        "Id_xMOINRig": null,                    // Id della riga inserita in xMOINRig
        "ResetAll": function (head) {
            if (head == true) {
                this.drIN = null;
            }
            this.dtxMOINRig = null;
            this.idx = null;
            this.AddNew = false;
            this.Id_xMOINRig = null;
        }
    },
    "SM": {
        "key": null,                               // Indice della riga nel dt
        "dtxMOTRRig_T": null,                      // Array contenente le righe dello stoccaggio merce
        "Id_xMOTRRig_T": null,                     // Id della riga temporanea a cui sono arrivato
        "NewAr": false,                            // Se nella pagina SMRig avvio la modalità di aggiunta nuovo articolo imposta la variabile a true in modo da strutturare pgSMRig_T correttamente
        "ResetAll": function () {
            this.dtxMOTRRig_T = null;
            this.key = null;
            this.Id_xMOTRRig_T = null;
        }
    },
    "PRAV": {
        "keyBLA": null,                           // Indice della riga nel dt delle attività
        "dtBLA": null,                             // Array contenente le righe delle attività delle Bolle
        "keyBLM": null,                           // Indice della riga nel dt dei materiali
        "dtBLM": null,                             // Array contenente le righe dei materiali dell'attività della Bolla
        "ResetAll": function () {
            this.keyBLA = null;
            this.dtBLA = null;
            this.keyBLM = null;
            this.dtBLM = null;
        },
    },
    "PRMP": {
        "dt": null,
        "dtLinea": null,
        "dt4BL": null,
        "key": null,
        "keyLinea": null,
        "keyBolla": null,
        "ActiveRecord": function () {
            return this.dt[this.key];
        },
        "ActiveBolla": function () {
            return this.dt4BL[this.keyBolla];
        },
        "ResetAll": function () {
            this.dt = null;
            this.dtLinea = null;
            this.dt4BL = null;
            this.key = null;
            this.keyLinea = null;
            this.keyBolla = null;
        }
    },
    // Reset: si occupa di ripulire le variabili dell'oggetto
    "Reset": function () {
        this.Key = null;
        this.Pages = null;
        this.ActivePageIdx = null;
        this.ActivePageId = null;
        this.ActivePageValue = null;
        this.Id_xMORL_Edit = 0;
        this.Id_xMOTR_Edit = 0;
        this.Id_xMOIN_Edit = 0;
        this.Id_DOTes = 0;
        //this.Cd_DO = null;
        this.drDO = null;
        this.drRL = null;
        this.drTR = null;
        this.BC = null;
        this.ActiveSearchId = null;
        this.ActiveSearchOutField = null;
        this.ActiveSearchValue = null;
        // RL variabile
        this.RL.ResetAll();
        // Packing List
        this.PK.ResetAll();
        //Inventario
        this.IN.ResetAll(true);
        // Stoccaggio Merce
        this.SM.ResetAll();
        // Produzione Avanzata
        this.PRAV.ResetAll();
        this.PRMP.ResetAll();
    },

    "Load": function (keyprg, Cd_DO, Id_toEdit, Edit_Area) {
        // reset
        this.Reset();
        try {
            // Verifico la presenza del keyprg
            if (fU.IsEmpty(keyprg))
                throw { message: "Attenzione non è stato definito un programma valido per il documento " + Cd_DO };
            // load
            this.Key = oApp.dtPrograms[keyprg].Key;
            this.Pages = oApp.dtPrograms[keyprg].Pages;
            this.ActivePageIdx = oApp.dtPrograms[keyprg].ActivePageIdx;
            this.ActivePageId = oApp.dtPrograms[keyprg].ActivePageId;
            this.ActivePageValue = oApp.dtPrograms[keyprg].ActivePageValue;

            //Memorizza l'id edit se passato alla funzione
            switch (fU.ToString(Edit_Area)) {
                case 'RL': this.Id_xMORL_Edit = fU.ToInt32(Id_toEdit); break;
                case 'TR': this.Id_xMOTR_Edit = fU.ToInt32(Id_toEdit); break;
                case 'IN': this.Id_xMOIN_Edit = fU.ToInt32(Id_toEdit); break;
            }

            // carico le impostazioni del documento corrente
            if (!fU.IsEmpty(Cd_DO))
                this.LoadDO(Cd_DO);
            // Gestione dei dati per la pagina da aprire 
            fPage.LoadData();
            // Gestione dell'interfaccia
            fPage.LoadUI();
            // Mostro il nav se necessario
            Nav.Show();
            // Show della pagina
            fPage.Show(oPrg.ActivePageId);
        }
        catch (e) {
            PopupMsg_Show("oPrg.Load()", "1", fU.ToString(e.message));
        }
    },
    "LoadDO": function (Cd_DO) {
        this.drDO = null;
        // carico le impostazioni del documento corrente
        if (!fU.IsNull(Cd_DO)) {
            //this.Cd_DO = oApp.dtDO[Cd_DO].Cd_DO;
            this.drDO = oApp.dtDO[Cd_DO];
        }
    },
    "PageIdx": function (PageValue) {
        var i = null;
        $.each(this.Pages, function (idx, page) {
            if (page.Value == PageValue) {
                i = idx;
                return false;
            }
        });
        return i;
    },
    "ResetPages": function () {
        $(".mo-page input").val("");
        $(".mo-page input[type='check']").attr("checked", false);
        $(".mo-page textarea").val("");
        $(".mo-page label.descrizione").text("");
        $(".mo-page label.oprg").text("");
        $("#pgPrelievi").find("select[name='Cd_DO'] option").remove();
    },
    "LoadTemporaryPrg": function (GoToPrg) {
        // Salvo su un oggetto il programma precedente
        // In modo di riuscire a tornare indietro nella navigazione
        oPrg_Back = $.extend(true, {}, oPrg);
        // Imposto nell'oggetto prg il nuovo programma 
        oPrg.Load(GoToPrg);
    },
    "DA": null
}

/**
 * Classe Nav:
 * Gestisce la navigazione tra le pagine di un programma e si occupa della visualizzazione delle frecce di navigazione
 */
var Nav = {
    "OnNav": false,     // Indica se sto eseguento Next o Back
    "GoToPage": function (PageIdx) {

        //Imposta la pagina corrente
        oPrg.ActivePageIdx = PageIdx;
        oPrg.ActivePageId = oPrg.Pages[PageIdx].Key;
        oPrg.ActivePageValue = oPrg.Pages[PageIdx].Value;

        //Abilita comunque la pagina
        oPrg.Pages[oPrg.ActivePageIdx].Enabled = true;
        // Svuoto la parte di header destinata alle info di navigazione riferite alla pagina 
        $("#header .info-space").html("");
        // Gestione dei dati per la pagina da aprire        
        fPage.LoadData();
        // Gestione dell'interfaccia
        fPage.LoadUI();
        // Show della pagina
        fPage.Show(oPrg.ActivePageId);

        // Mostro il nav se necessario
        this.Show();
    },
    // Si occupa della navigazione in avanti tra le pagine del programma
    "Next": function () {
        if (!this.OnNav) {
            this.OnNav = true;
            // Se ho selezionato un programma che ha delle pagine
            if (oPrg.Key != null && (oPrg.Pages && oPrg.Pages.length > 0)) {

                // Validazione della pagina corrente
                if (fPage.Validate()) {
                    //Se richiesto va alla Home (o è l'ultima pagina o il programma esce prima dal flusso standard)
                    if (!oPrg.Pages[oPrg.ActivePageIdx].GoHome) {
                        ///Se esite una pagina successiva abilitata la carica
                        if (oPrg.Pages[oPrg.ActivePageIdx].Next) {
                            var ifind = null;
                            // Recupero della prima pagina abilitata successiva alla corrente
                            for (var i = (oPrg.ActivePageIdx + 1); i < oPrg.Pages.length; i++) {
                                // Ciclo finche non trovo una pagina abilitata
                                if (oPrg.Pages[i].Enabled) {
                                    // idx trovato: esco dal for
                                    ifind = i;
                                    break;
                                }
                            }
                            if (fU.ToInt32(ifind) >= 0) {
                                this.GoToPage(ifind);
                            } else {
                                PopupMsg_Show("ERRORE", "1", "Pagina corrente con NEXT ma nessuna pagina successiva!!<BR />Contattare il fornitore di Software!");
                            }
                        } else { GoHome(true); }
                    } else { GoHome(true); }
                }
            }
            else {
                PopupMsg_Show("ERRORE", "1", "Errore nella navigazione!");
                GoHome(true);
            }
            this.OnNav = false;

        }
    },

    // Si occupa della navigazione all'indietro tra le pagine del programma
    "Back": function () {
        if (!this.OnNav) {
            this.OnNav = true;
            // Esiste un programma di ritorno forzato?
            if (oPrg_Back != null) {
                oPrg = $.extend(true, {}, oPrg_Back);
                oPrg_Back = null;
                // Adesso non devo tornare indietro: carico il programma del back
                this.GoToPage(oPrg.ActivePageIdx);
                // Se ho selezionato un programma che ha delle pagine
            }
            // Se ho selezionato un programma che ha delle pagine
            else if (oPrg.Key != null && (oPrg.Pages && oPrg.Pages.length > 0)) {
                // Salvo i dati della pagina corrente
                if (fPage.SaveData()) {
                    // Se sono già alla prima pagina del programma, vado alla home page
                    if (oPrg.ActivePageIdx == 0) {
                        GoHome(true);
                    }
                    else {
                        var find = false;
                        // Recupero della prima pagina abilitata precedente alla corrente
                        for (var i = (oPrg.ActivePageIdx - 1); i >= 0; i--) {
                            // Ciclo finche non trovo una pagina abilitata
                            if (oPrg.Pages[i].Enabled) {
                                oPrg.ActivePageIdx = i;
                                oPrg.ActivePageId = oPrg.Pages[i].Key;
                                oPrg.ActivePageValue = oPrg.Pages[i].Value;
                                find = true;
                                break; // esco dal for
                            }
                        }
                        //  Se ho trovato una pagina abilitata precedente alla corrente faccio lo show senno torno alla home
                        if (find) {
                            fPage.Show(oPrg.ActivePageId);
                            // Mostro il nav se necessario
                            this.Show();
                        }
                        else { GoHome(); }
                    }
                }
            }
            else {
                PopupMsg_Show("ERRORE", "1", "Errore nella navigazione!");
                GoHome();
            }
            this.OnNav = false;
        }
    },

    // Si occupa della visualizzazione della navbar
    "Show": function () {
        // Pagina corrente
        var pg = oPrg.Pages[oPrg.ActivePageIdx];
        // Hide della navigazione
        $(".nav-next").hide();
        $(".nav-back").hide();
        // Show del nav 
        if (pg.Next) $(".nav-next").show();
        if (pg.Back) $(".nav-back").show();
    },

    // Mostra o nasconde in base ai parametri i button back e next
    "NavbarShowIf": function (showBack, showNext) {
        fU.ShowIf($(".nav-back"), showBack);
        fU.ShowIf($(".nav-next"), showNext);
    },

    "Keybhide": function () {
        $(document.activeElement).blur();
    }
}

/**
 * Classe fPage: Gestisce le funzioni generali per le pagine
 */
var fPage = {
    //Recupera il nome della pagina da aprire
    "GetPageKey": function (page) {
        return fU.GetEnumKey(enumPagine, page);
    },

    // Valida la pagina corrente, torna un boolean
    "Validate": function () {
        var m = "";
        var r = false;

        /* =================================
        Attenzione! Tutte le chiamate Ajax utili per la validazione devono essere SINCRONE!
         ================================= */

        // In base alla pagina...
        switch (oPrg.ActivePageValue) {
            // pagine non validate
            case enumPagine.pgHome:
            case enumPagine.pgSottoMenu:
            case enumPagine.pgDocAperti:
            case enumPagine.pgLog:
            case enumPagine.pgINAperti:
            case enumPagine.pgINRig:
            case enumPagine.pgINPiede:
            case enumPagine.pgMGDisp:
            case enumPagine.pgSMRig_T:
            case enumPagine.pgPRTRAttivita:
                // Posso andare avanti solo se ho scelto una bolla
                if (oPrg.PRAV.keyBLA == null)
                    m += "\nNessuna Bolla selezionata.";
                r = (m == "" ? true : false);
                break;
            // pagina Testa della rilevazione
            case enumPagine.pgRL:
                //Verifico che il CF sia stato selezionato
                if (fU.IsEmpty($("#pgRL [name='Cd_CF']").val()))
                    m += "\nCliente/Fornitore non selezionato.";
                if (!fU.IsDate($("#pgRL input[name='DataDoc']").val()))
                    m += '\nLa data del documento inserita non è nel formato richiesto (GG/MM/AAAA).';
                if (!fU.IsDate($("#pgRL input[name='DataDocRif']").val()))
                    m += '\nLa data di riferimento inserita non è nel formato richiesto (GG/MM/AAAA).';
                //Salvataggio dei dati della testa RL
                if (m == "") { r = Ajax_xmosp_xMORL_Save(); }
                break;

            case enumPagine.pgDocRistampa:
                // carico le impostazioni del documento corrente
                oPrg.LoadDO($("#pgDocRistampa label[name='Cd_DO']").text());
                oPrg.Id_DOTes = $("#pgDocRistampa label[name='Id_DOTes']").text();
                oPrg.Id_xMORL_Edit = $("#pgDocRistampa label[name='Id_xMORL_Edit']").text();
                r = true;
                break;

            case enumPagine.pgAvviaConsumo:
                if (fU.IsEmpty($("#pgAvviaConsumo select[name='Cd_xMOLinea']").val())) {
                    m += "\nLinea non selezionata.";
                }
                if (!fU.IsDate($("#pgAvvioConsumo input[name='DataOra']").val())) {
                    m += '\nLa data inserita non è nel formato richiesto (GG/MM/AAAA).'
                }

                if (m == "") { r = Ajax_xmosp_xMOConsumo_Save(); }
                break;

            case enumPagine.pgDOPrelievi:
                var Id_DOTess = "";
                //Genera una stringa di id dei prelievi selezionati
                $("#pgDOPrelievi .tr-prel").find(":checkbox:not(disabled)").each(function () {
                    if ($(this).prop("checked") == true) {
                        // Salva in una stringa l'id dei doc selezionati
                        Id_DOTess += $(this).attr("Id_DOTes") + ',';
                    }
                });
                //Verifica dell'obbligatorietà del prelievo
                switch (oPrg.drDO.xMOPrelievo) {
                    case 0:
                    case 3:
                        break;
                    case 1:
                        if (fU.IsEmpty(Id_DOTess) && oPrg.drDO.xMOPrelievoObb) {
                            m += "<br />- Prelievo obbligatorio! Nessun documento selezionato.";
                        }
                        break;
                    case 2:
                        if (fU.IsEmpty(Id_DOTess) && oPrg.drDO.xMOPrelievoObb) {
                            m += "<br />- Copia Righe obbligatoria! Nessun documento selezionato.";
                        }
                        break;
                }
                if (m == "") {
                    //Se sono stati prelevati dei documenti li controlla
                    if (fU.IsEmpty(Id_DOTess) || Ajax_xmosp_xMORLPrelievo_Validate(Id_DOTess, oPrg.drRL.Cd_DO)) {
                        //Salva i documenti di prelievo selezionati
                        r = Ajax_xmosp_xMORLPrelievo_Save(Id_DOTess);
                    }
                }
                break;

            case enumPagine.pgPrelievi:
                var Id_DOTess = "";
                var Cd_DO = "";
                //Genera una stringa di id dei prelievi selezionati
                $("#pgPrelievi .li-prel").find(":checkbox:not(disabled)").each(function () {
                    if ($(this).prop("checked") == true) {
                        // Salva in una stringa l'id dei doc selezionati
                        Id_DOTess += $(this).attr("Id_DOTes") + ',';
                    }
                });
                Cd_DO = fU.ToString($("#" + oPrg.ActivePageId + " select[name='Cd_DO']").val());
                //Verifica la selezione del prelievo
                if (fU.IsEmpty(Id_DOTess)) m += "<br />- Nessun documento selezionato da prelevare.";
                if (fU.IsEmpty(Cd_DO)) m += '<br /> -Selezionare il tipo di documento da creare';
                if (m == "") {
                    if (Ajax_xmosp_xMORLPrelievo_Validate(Id_DOTess, Cd_DO)) {
                        //Salva i documenti di prelievo selezionati
                        r = Ajax_xmosp_xMORLPrelievo_SaveRL(Id_DOTess, Cd_DO);
                    }
                }
                break;

            case enumPagine.pgRLRig:
                var DoIt = false;
                //Verifica che sia stata inserita almeno una riga
                // var nRows = fU.ToInt32($("#pgRLRig .letture").text())
                // Se pk è attiva e pgRLPK viene aperta in modalità detail non vanno effettuati i controlli
                if (oPrg.drDO.PkLstEnabled && oPrg.PK.RLPKDetail) {
                    r = true;
                }
                else {
                    if (oPrg.RL.Letture == 0) m += "<br />- Nessuna lettura effettuata.";
                    if (oPrg.drDO.xMOPrelievo == 1 && oPrg.RL.ARIncompleti > 0) {
                        var msg = "Presenza di Articoli non completamente prelevati.";
                        if (fU.ToBool(oPrg.drDO.xMOResiduoInPrelievo)) {
                            msg += String.fromCharCode(13) + "ATTENZIONE: se si sceglie di continuare i residui del prelievo verranno azzerati!"
                        }
                        DoIt = confirm(msg + String.fromCharCode(13) + "Proseguire nella creazione del documento?", "ATTENZIONE!");
                    }
                    else { DoIt = true; }
                    if (m == "" && DoIt) {
                        //Tutto ok
                        r = true;
                    }
                }
                break;

            case enumPagine.pgRLPiede:
                var DoIt = false;
                var msg = "";
                // Se Targa e Caricatore sono gestiti dal DOC ma i campi sono vuoti chiedo a l'operatore se continuare comuqnue il salvataggio
                if (oPrg.drDO.xMOTarga && fU.IsEmpty($("#" + oPrg.ActivePageId + " input[name='Targa']").val())) {
                    msg += String.fromCharCode(13) + "- Targa mancante";
                }
                if (oPrg.drDO.xMOTarga && fU.IsEmpty($("#" + oPrg.ActivePageId + " input[name='Cd_DOCaricatore']").val())) {
                    msg += String.fromCharCode(13) + "- Caricatore mancante";
                }

                if (msg == "") { DoIt = true; }
                else {
                    DoIt = confirm(msg + String.fromCharCode(13) + "Salvare comunque il documento?", "ATTENZIONE!");
                    // Imposto il check di stampa a false in modo da non stampare il documento 
                    $("#pgRLPiede").find(".ck-print").prop("checked", false);
                }
                if (DoIt) {
                    // Salva il piede e stampa se richiesto dall'operatore
                    r = Ajax_xmosp_xMORLPiede_Save();
                }
                break;

            case enumPagine.pgStampaDocumento:
                var cmd = "";
                //Per la generazione dei comandi di stampa vanno verificati gli id correnti
                //Verifica la Ristampa (Id_DOTes e Id_xMORL_Edit completi)
                if (fU.ToInt32(oPrg.Id_DOTes) > 0 && fU.ToInt32(oPrg.Id_xMORL_Edit) > 0) {
                    //Stampa un doc di Arca
                    cmd = Listener_RLRePrint(oPrg.Id_DOTes, $("#pgStampaDocumento ul"));
                    // Id_xMORL_Edit è null perchè il documento è già esistente in Arca quindi lo stato deve rimanere Storicizzato
                    // e l'Id_DOTes è compreso nel cmd
                    r = Ajax_ListenerCoda_Add(cmd, null);

                } else {
                    //Verifica la Stampa di un RL
                    if (fU.ToInt32(oPrg.Id_xMORL_Edit) > 0) {
                        //Salva e Stampa una rilevazione
                        cmd = Listener_RLSaveAndPrint(oPrg.Id_xMORL_Edit, $("#pgStampaDocumento li.li-modulo"));
                        r = Ajax_ListenerCoda_Add(cmd, oPrg.Id_xMORL_Edit);
                    }
                }
                break;

            case enumPagine.pgTR:
                if (!fU.IsDate($("#pgTR input[name='DataMov']").val())) {
                    m += '\nLa data del movimento non è nel formato richiesto (GG/MM/AAAA).'
                }
                if (m == "") {
                    r = Ajax_xmosp_xMOTR_Save();
                }
                break;

            case enumPagine.pgTRRig_P:
                //Verifica che sia stata inserita almeno una riga
                var nRows = fU.ToInt32($("#pgTRRig_P .letture").text())
                if (nRows == 0) m += "<br />- Nessuna lettura effettuata.";
                if (m == "") {
                    //Tutto ok
                    r = true;
                }
                break;

            case enumPagine.pgTRRig_A:
                //Verifica che sia stata inserita almeno una riga
                var nRows = fU.ToInt32($("#pgTRRig_A .letture").text())
                if (nRows == 0) m += "<br />- Nessuna lettura effettuata.";
                if (m == "") {
                    //Tutto ok
                    r = true;
                }
                break;

            case enumPagine.pgTRPiede:
                // Salva il piede del trasferimento e crea il documento in arca
                r = Ajax_xmosp_xMOTRPiede_Save();
                break;

            case enumPagine.pgIN:
                // Se inventario massivo salvo la testa sul server
                switch (oPrg.IN.Tipo) {
                    case 'M':
                        // Massiva: salva la testa dell'inventario in xMOIN
                        r = Ajax_xmosp_xMOIN_Save();
                        break;
                    case 'P':
                        // Se il magazzino è vuoto non valido la pagina
                        if (!fU.IsEmpty($("#pgIN input[name='Cd_MG']").val())) {
                            // Puntuale: salvo la testa su variabili client
                            r = xMOIN_SaveTo_drIN();
                        }
                        else { PopupMsg_Show("ERRORE", "", "Selezionare un magazzino"); r = false; }
                        break;
                }
                break;

            case enumPagine.pgRLPK:
                // Salvo le modifiche effettuate al pklistref modificato per ultimo 
                // NB lo faccio nel validate perchè gli altri vengono salvati al click delle frecce, l'ultimo rimarrebbe non salvato
                var r = Ajax_xmosp_xMORLPackListRef_Save();
                break;

            case enumPagine.pgSP:
                //var Id_DOTes = fU.ToInt32($("#pgSP table .ck-sp:checked").attr("Id_DOTes"));
                var NumDocCheck = 0;
                var Id_DOTess = "";
                //Genera una stringa di id dei prelievi selezionati
                $("#pgSP .tr-sp").find(":checkbox:not(disabled)").each(function () {
                    if ($(this).prop("checked") == true) {
                        // Salva in una stringa l'id dei doc selezionati
                        Id_DOTess += $(this).attr("Id_DOTes") + ',';
                        NumDocCheck += 1;
                        // #### Per il momento in Id_DOTess salvo un numero che indica i check selezionati
                        //Id_DOTess += 1;
                    }
                });
                //### da completare lo sviluppo per la selezione di più valori nel server in xmosp_xMOSpedizione_SaveRL
                var Cd_DO = $("#pgSP select[name='Cd_DO']").val();
                //Verifica i dati
                if (fU.ToInt32(NumDocCheck) == 0) m += "<br />- Nessun documento da prelevare selezionato.";
                //if (Id_DOTess > 1) m += "<br />- Selezionare solo un documento.";
                if (fU.IsEmpty(Cd_DO)) m += "<br />- Documento da generare non selezionato.";
                //Carica la testa del doc e i prelievi da lista di carico 
                if (m == "") {
                    r = Ajax_xmosp_xMOSpedizione_SaveRL(Id_DOTess, Cd_DO);
                }
                // Se il salvataggio == true allora disabilito la pagina corrente
                if (r) {
                    oPrg.Pages[oPrg.PageIdx(enumPagine.pgSP)].Enabled = false;
                }
                break;

            case enumPagine.pgAA:
                if (oApp.TipoAA.toUpperCase() == 'ALI') {
                    Ajax_xmosp_ARAlias_Save();
                } else {
                    Ajax_xmosp_ARCodCF_Save();
                }
                break

            // Pers
            case enumPagine.pgxListaCarico:
                var Id_DOTes = $("#pgxListaCarico [name='Id_DOTes']").val();
                var Cd_DO = $("#pgxListaCarico [name='Cd_DO']").val();
                //Verifica i dati
                if (fU.ToInt32(Id_DOTes) == 0) m += "<br />- Documento da prelevare non selezionato.";
                if (fU.IsEmpty(Cd_DO)) m += "<br />- Documento da generare non selezionato.";
                //Carica la testa del doc e i prelievi da lista di carico 
                if (m == "") {
                    r = Ajax_xmosp_xListaCarico_SaveRL(Id_DOTes, Cd_DO);
                    //r = Ajax_xmosp_xListaCarico_SaveRL(Id_DOTes, Cd_DO);
                }
                // Se il salvataggio == true allora disabilito la pagina corrente
                if (r) {
                    oPrg.Pages[oPrg.PageIdx(enumPagine.pgxListaCarico)].Enabled = false;
                }
                break;

            case enumPagine.pgSM:
                if (fU.IsEmpty($("#pgSM input[name='Cd_MG_P']").val())) m += "<br /> - Inserire il magazzino di partenza";
                if (fU.IsEmpty($("#pgSM input[name='Cd_MG_A']").val())) m += "<br /> - Inserire il magazzino di arrivo";
                if (m == "") {
                    // Se la testa del trasferimento di stoccaggio era già creata (documenti aperti) disabilito la pagina che mi permette di caricare le righe
                    if (oPrg.Id_xMOTR_Edit > 0) {
                        oPrg.Pages[oPrg.PageIdx(enumPagine.pgSMLoad)].Enabled = false;
                    } else {
                        oPrg.Pages[oPrg.PageIdx(enumPagine.pgSMLoad)].Enabled = true;
                    }
                    localStorage.Cd_MG_P = $("#pgSM input[name='Cd_MG_P']").val();
                    localStorage.Cd_MG_A = $("#pgSM input[name='Cd_MG_A']").val();
                    r = Ajax_xmosp_xMOSM_Save();
                }
                break;

            case enumPagine.pgSMRig:
                oPrg.SM.dtxMOTRRig_T.length <= 0 ? m = "lista vuota. Nessun articolo da stoccare!" : r = true;
                break;

            case enumPagine.pgSMLoad:
                var notck = true;
                if (fU.IsChecked($("#pgSMLoad .ck-smdocs"))) {
                    r = Ajax_xmosp_xMOTRRig_P_FromDocs();
                    notck = false;
                }
                if (fU.IsChecked($("#pgSMLoad .ck-smmgubi"))) {
                    r = Ajax_xmosp_xMOTRRig_P_FromMGUBI();
                    notck = false;
                }
                // ### Da gestire il check del reintegro ubicazioni
                if (fU.IsChecked($("#pgSMLoad .ck-smmgubi"))) {
                    notck = false;
                }
                if (r) {
                    // Procedura che inserisce le righe in T e assegna le ubicazioni
                    r = Ajax_xmosp_xMOTRRig_T_Save();
                }
                // Se tutte le procedure di salvataggio sono andate a buon fine diasbilito la pagina corrente
                if (r) {
                    oPrg.Pages[oPrg.PageIdx(enumPagine.pgSMLoad)].Enabled = false;
                }
                if (notck) { r = true; }
                break;

            case enumPagine.pgSMPiede:
                // ### Salva il piede dello stoccaggio e crea il Trasferimento in arca
                r = Ajax_xmosp_xMOTRPiede_Save();
                break;
            case enumPagine.pgPRTRMateriale:
                // @@@ r = Ajax_xmosp_xMOPRTRMateriale_Save();
                break;
            case enumPagine.pgPRMPMateriale:
                // @@@ r = Ajax_xmosp_xMOPRTRMateriale_Save();
                break;

            default:
                m = "ERRORE", "Errore di gestione del Validate() della pagina " + oPrg.ActivePageId;
                break;
        }
        if (m != "") {
            //Se presente mostra l'errore
            PopupMsg_Show("ERRORE", "1", 'Impossibile continuare a causa di: ' + m);
        }

        // ATTENZIONE se la funzione non restituisce TRUE non va avanti 

        return r;
    },

    // Carica i dati della pagina, possono essere anche caricati in modo asincrono
    "LoadData": function () {

        /* =================================
        Attenzione! Tutte le funzioni ASINCRONE si devono preoccupare di gestire l'UI per i propri dati (clear e load)
         ================================= */

        // In base alla pagina
        switch (oPrg.ActivePageValue) {
            case enumPagine.pgSottoMenu:
            case enumPagine.pgAvviaConsumo:
            case enumPagine.pgStampaDocumento:
            case enumPagine.pgINPiede:
            case enumPagine.pgLog:
            case enumPagine.pgMGDisp:
            case enumPagine.pgSMLoad:
            case enumPagine.pgSMRig_T:
                break;
            case enumPagine.pgRL:
                //Attiva la pagina del prelievo se è parametrizzata nel prg 'DO'
                if (oPrg.Key == 'DO') {
                    oPrg.Pages[oPrg.PageIdx(enumPagine.pgDOPrelievi)].Enabled = (fU.IsPrelievoUI(oPrg.drDO.xMOPrelievo));
                }
                //Se Id_xMORL_Edit > 0 carica i dati nei campi
                if (fU.ToInt32(oPrg.Id_xMORL_Edit) > 0) {
                    //Carico la RL
                    Ajax_xmovs_xMORL();
                }
                break;

            case enumPagine.pgDOPrelievi:
                //Carica il dt dei documenti prelevabili
                Ajax_xmofn_DOTes_Prel();
                break;

            case enumPagine.pgPrelievi:
                if (!fU.IsEmpty(oPrg.drDO)) {
                    $("#pgPrelievi input[name='Cd_DO']").val(oPrg.drDO.Cd_DO);
                }
                Ajax_xmofn_DOTes_Prel_4PR();
                break;

            case enumPagine.pgDocAperti:
                //Carica l'elenco dei documenti aperti
                Ajax_xmofn_DOAperti();
                break;

            case enumPagine.pgDocRistampa:
                Ajax_xmofn_DORistampa();
                break;

            case enumPagine.pgRLRig:
                //Carica i dati di testa (se necessario: potremmo saltare la pagina di caricamento dati di testa)
                if (oPrg.drRL == null) {
                    Ajax_xmovs_xMORL()
                }
                // Carica i tipi di Barcode utilizzabili 
                Ajax_xmofn_DOBarcode();
                // Carica le letture e il numero di quelle effettuate
                Ajax_xmofn_xMORLRig_AR();
                // Se PkList == true carica i Ref e abilita la pagina di packing
                if (oPrg.drDO.PkLstEnabled) {
                    oPrg.Pages[oPrg.PageIdx(enumPagine.pgRLPK)].Enabled = true;
                    // Caricare i codici PackListref se esistenti altrimenti propone quello nuovo
                    Ajax_xmofn_xMORLRigPackingList();
                }
                // Disabilita la pagina di PKList
                else {
                    oPrg.Pages[oPrg.PageIdx(enumPagine.pgRLPK)].Enabled = false;
                }
                break;

            case enumPagine.pgRLPK:
                // Carica l'elenco dei pcaklistref e li salva su un array globale
                Ajax_xmofn_xMORLPackListRef();
                break;

            case enumPagine.pgTR:
            case enumPagine.pgSM:
                // Se Id_xMOTR_Edit > 0 allora carica il TR passato alla funzione senno carica il TR top 1 con Stato = 0
                //Ajax_xmofn_xMOTR_To_Edit();
                if (fU.ToInt32(oPrg.Id_xMOTR_Edit) > 0) {
                    Ajax_xmovs_xMOSM();
                }
                break;

            case enumPagine.pgTRRig_P:
                // Se sono in Edit carico le letture effettuate
                if (!fU.IsEmpty(oPrg.Id_xMOTR_Edit)) Ajax_xmofn_xMOTRRig_P_AR();
                break;

            case enumPagine.pgTRRig_A:
                // Carica letture effettuate in partenza se sono in Edit
                if (!fU.IsEmpty(oPrg.Id_xMOTR_Edit)) Ajax_xmofn_xMOTRRig_A_AR();
                break;

            case enumPagine.pgRLPiede:
                if (oPrg.drRL.CountPrelievi > 0) {
                    // Carica riepilogo del prelievo 
                    Ajax_xmofn_xMORLRig_Totali();
                }
                break;

            case enumPagine.pgTRPiede:
            case enumPagine.pgSMPiede:
                // Carica riepilogo del trasferimento
                Ajax_xmofn_xMOTRRig_Totali();
                break;

            case enumPagine.pgPRTRAttivita:
                // Di default mostro le attività interne
                ActivePageDOM().querySelector("input[data-bind='Interne']").checked = true;
                ActivePageDOM().querySelector("input[data-bind='DaTrasferire']").checked = true;
                // Carica l'elenco delle attività
                Ajax_xmofn_xMOPRBLAttivita();
                break;

            case enumPagine.pgPRTRMateriale:
                // Carica l'elenco dei materiali dell'attività
                Ajax_xmofn_xMOPRBLMateriali();
                break;

            case enumPagine.pgPRMPMateriale:
                // Carica l'elenco delle linee
                Ajax_xmofn_xMOLinea(PRMPMateriale_Load);
                break;

            case enumPagine.pgINAperti:
                // Assegno il tipo di inventario 
                // ATTENZIONE se passo in pgINAperti il prg è INM e quindi il tipo è MASSIVO
                oPrg.IN.Tipo = 'M';
                Ajax_xmofn_xMOIN_Aperti();
                break;

            case enumPagine.pgIN:
                // In base  al programma Mass o Punt imposto la variabile tipo di inventario
                // ATTENZIONE Nel caso in cui ho fatto nuovo dalla pagin INAperti era stato già assegnato e qui lo riassegna 
                oApp.dtPrograms[oPrg.Key].Key == 'INM' ? oPrg.IN.Tipo = 'M' : oPrg.IN.Tipo = 'P';
                Ajax_xmofn_xMOMGEsercizio();
                break;

            case enumPagine.pgINRig:
                if (oPrg.IN.Tipo == 'M') {
                    // Inserisce gli articoli da inventariare nella tab xMOINRig poi chiama la funzione che ne carica l'elenco
                    Ajax_xmosp_xMOINRig_AR();
                }
                break;

            case enumPagine.pgSP:
                pgSP_OrderTable(fU.IfEmpty(localStorage.getItem("SPFiltro"), 0));
                //Carica la lista dei documenti di Spedizione dell'operatore 
                Ajax_xmofn_xMOCodSpe();
                break;

            case enumPagine.pgAA:
                // Carica i tipi di Barcode utilizzabili 
                Ajax_xmofn_xMOBarcode();
                break;
            // Pers
            case enumPagine.pgxListaCarico:
                //Carica la lista dei documenti LdC dell'operatore 
                Ajax_xmofn_xListaCarico();
                break;

            case enumPagine.pgSMRig:
                Ajax_xmofn_xMOTRRig_TA();
                break;

            default:
                PopupMsg_Show("ERRORE", "1", "Errore di gestione del LoadData() della pagina " + oPrg.ActivePageId);
                break;
        }
    },

    // Carica l'interfaccia utente, della pagina
    "LoadUI": function () {

        /* =================================
        Attenzione! i dati potrebbero non essere tutti disponibili perché LoadData può lavorare anche in modo ASINCRONO
         ================================= */

        // In base alla pagina...
        switch (oPrg.ActivePageValue) {
            case enumPagine.pgSottoMenu:
            case enumPagine.pgDocRistampa:
            case enumPagine.pgDocAperti:
            case enumPagine.pgDOPrelievi:
            case enumPagine.pgINAperti:
                break;
            case enumPagine.pgAvviaConsumo:
                pgAvviaConsumo_UI();
                break;
            case enumPagine.pgRL:
                pgRL_UI();
                break;
            case enumPagine.pgRLRig:
                pgRLRig_UI();
                break;
            case enumPagine.pgRLPK:
                pgRLPK_UI();
            case enumPagine.pgRLPiede:
                pgRLPiede_UI();
                break;
            case enumPagine.pgTRPiede:
                pgTRPiede_UI();
                break;
            case enumPagine.pgPrelievi:
                // Chiudo il div dei filtri
                DivToggle_Execute($("#pgPrelievi .div-filtri"), false);
                pgPrelievi_UI_Edit();
                break;
            case enumPagine.pgStampaDocumento:
                pgStampaDocumento_UI();
                break;
            case enumPagine.pgTRRig_P:
                pgTRRig_P_UI();
                break;
            case enumPagine.pgTRRig_A:
                pgTRRig_A_UI();
                break;
            case enumPagine.pgTR:
                pgTR_UI();
                break;
            case enumPagine.pgIN:
                pgIN_UI();
                break;
            case enumPagine.pgINRig:
                pgINRig_UI();
                break;
            case enumPagine.pgINPiede:
                pgINPiede_UI();
                break;
            case enumPagine.pgSP:
                pgSP_UI();
                break;
            // Pers
            case enumPagine.pgxListaCarico:
                pgxListaCarico_UI();
                break;
            case enumPagine.pgLog:
                pgLog_UI();
                break;
            case enumPagine.pgAA:
                pgAA_UI();
                break;
            case enumPagine.pgMGDisp:
                pgMGDisp_UI();
                break;
            case enumPagine.pgSM:
                pgSM_UI();
                break;
            case enumPagine.pgSMLoad:
                pgSMLoad_UI();
                break;
            case enumPagine.pgSMRig:
                // Svuoto la variabile che indicato l'indice del dt in cui sono arrivato
                oPrg.SM.key = null;
                $("#pgSMRig .Id_xMOTR").text(oPrg.Id_xMOTR_Edit);
                $("#pgSMRig input[name='Cd_MGUbicazione_P']").val($("#pgSM input[name='Cd_MGUbicazione_P']").val());
                break;
            case enumPagine.pgSMRig_T:
                pgSMRig_T_UI();
                break;
            case enumPagine.pgSMPiede:
                pgSMPiede_UI();
                break;
            // @@@
            case enumPagine.pgPRTRAttivita:
                break;
            case enumPagine.pgPRTRMateriale:
                break;
            case enumPagine.pgPRMPMateriale:
                break;

            default:
                PopupMsg_Show("ERRORE", "1", "Errore di gestione del LoadUI() della pagina " + oPrg.ActivePageId);
                break;
        }

    },

    // Salva i dati della pagina al back
    "SaveData": function () {
        var m = "";
        var r = false;

        // ATTENZIONE nelle prime pagine dei programmi non possono essere salvate le modifiche al back
        // In base alla pagina...
        switch (oPrg.ActivePageValue) {
            case enumPagine.pgPRTRMateriale:
                //Ricarica in modo temporizzato la lista delle attività
                setTimeout(function () {
                    Ajax_xmofn_xMOPRBLAttivita();
                }, 350);
                r = true;
                break;
            case enumPagine.pgRLPK:
                // Salvo le modifiche effettuate al pklistref modificato per ultimo 
                // NB lo faccio nel back perchè gli altri vengono salvati al click delle frecce, l'ultimo rimarrebbe non salvato
                var r = Ajax_xmosp_xMORLPackListRef_Save();
                break;

            case enumPagine.pgRLPiede:
                // Salva il piede e stampa se richiesto dall'operatore
                r = Ajax_xmosp_xMORLPiede_Save();
                break;

            case enumPagine.pgTR:
                r = Ajax_xmosp_xMOTR_Save();
                break;

            default:
                //NESSUN SALVATAGGIO RICHIESTO m = "ERRORE", "Errore di gestione del SaveData() della pagina " + oPrg.ActivePageId;
                r = true;
                break;
        }
        if (m != "") {
            //Se presente mostra l'errore
            PopupMsg_Show("ERRORE", "1", 'Impossibile continuare a causa di: ' + m);
        }

        // ATTENZIONE se la funzione non restituisce TRUE non va avanti 
        return r;
    },

    "Show": function (pgKey, left) {
        // Hide di tutte le pagine
        $("div.mo-page").hide();
        // Show della pagina corrente
        $("#" + pgKey).show();
        // //Attiva il focus al primo campo con la classe "first-focus" 
        // if (oApp.SetFocus != 0) {
        //     $("#" + pgKey + " .first-focus:visible").first().focus().select();
        // }
        SetFocus();
    },

    // Pulisce la pagina corrente 
    "Clear": function () {
        $("#" + this.ActivePageId + " input").val("");
        $("#" + this.ActivePageId + " input[type='check']").attr("checked", false);
        $("#" + this.ActivePageId + " textarea").val("");
    },
}

// Classe fCF: Gestisce le funzioni generali per i clienti / fornitori
var fCF = {

    "Etichetta": function (breve) {
        switch ((Stato.DO[Stato.idxDO].CF).toUpperCase()) {
            case "C":
                return (breve == true ? "C" : "Cliente");
            case "F":
                return (breve == true ? "F" : "Fornitore");
            default:
                return (breve == true ? "C/F" : "Cliente/Fornitore");
        }
    },

    "AutoComplete": function (cf) {
        //Autocompleta il codice CF formattandolo a 7 cifre
        var t = $(cf).val();
        if (t.length > 0) {
            if (t.length != 7) {
                //Completo la stringa del CF perché non è nel numero di caratteri validi: 7
                t = '000000' + t;
                $(cf).val(Stato.DO[Stato.idxDO].CF + t.substring(t.length - 6));
            }
        }
    }

}

/**
 * Classe fDO: Gestisce le funzioni generali per i documenti
 */
var fDO = {

    "FindIdxByCd_Do": function (Cd_DO) {
        //Restituisce l'idx di DO
        for (i = 0; i < Stato.DO.length; i++) {
            if (Stato.DO[i].Cd_DO == Cd_DO) {
                return i;
            }
        }
        //nessun doc trovato!!
        return -1;
    }
}

/**
 * Classe fMG: Gestisce le funzioni generali per i magazzini
 */
var fMG = {

    "Mg4Find": function (Cd_MG_P, Cd_MG_A) {
        //normalizza i valori
        // Cd_MG_P = fU.IsEmpty(Cd_MG_P);
        // Cd_MG_A = fU.IsEmpty(Cd_MG_A);

        //verifica i magazzini passati alla funzione
        if (Cd_MG_P == "" && Cd_MG_A == "") {
            return "";
        } else if (Cd_MG_P != "" && Cd_MG_A == "") {
            return Cd_MG_P;
        } else if (Cd_MG_P == "" && Cd_MG_A != "") {
            return Cd_MG_A;
        } else {
            //Se sono presenti entrambi in magazzini restituisco quello di partenza
            return Cd_MG_P;
        }
    },
    "Mg4PA": function (Codice) {
        var v = "";
        //Testa l'ultimo carattere per interpretare il _P o _A o nessuno dei due
        switch (Codice.substring(Codice.length - 2, Codice.length).toLowerCase()) {
            case "_p": v = "_P"; break;
            case "_a": v = "_A"; break;
        }
        return v;
    }

}

/**
 * Classe fU: Utility globali
 */
var fU = {
    // Restituisce il nome dell'oggetto passato come parametro
    "NameOf": function (obj) {
        for (var key in window) { if (window[key] == obj) return key; }
    },

    // Salva l'oggetto passato come parametro in una variabile di sessione
    "SetSession": function (obj) {
        sessionStorage.setItem(this.NameOf(obj), JSON.stringify(obj));
    },

    // Recupera la variabile di stato con il nome specificato
    "GetSession": function (name) {
        var app = sessionStorage.getItem(name);
        if (app == null || app == undefined) { return null; }
        else { return $.parseJSON(app); }
    },

    "GetEnumKey": function (e, enumval) {
        var rkey = "";

        $.each(e, function (key, val) {
            if (val == enumval) {
                rkey = key;
                return; // esco dal foreach
            }
        });

        return rkey;
    },

    // Verifica se il valore passato alla funzione è 0
    "IsZeroVal": function (val) {
        return (val == undefined || val == '0' || val == '' ? true : false);
    },

    // Verifica se il valore passato alla funzione è 0 restituisce il valore di epval
    "IfZeroVal": function (val, epval) {
        return (val == undefined || val == '0' || val == '' ? epval : val);
    },

    // Formatta la data
    "ToDate": function (sDate) {
        // Se è stato 
        r = "";
        //Testa il browser
        switch (oApp.BrowserType) {
            case enumBrowser.Chrome:
            case enumBrowser.Mozilla:
                r = this.DateJsonToDateRev(sDate);
                break;
            default:
                r = this.DateJsonToDate(sDate);
                break;
        }
        return r;
    },

    // Formatta la data e ora
    "ToDateTime": function (sDateTime) {
        // Se è stato 
        r = "";
        //Testa il browser
        switch (oApp.BrowserType) {
            case enumBrowser.Chrome:
                r = this.DateJsonToTimeRev(sDateTime);
                break;
            default:
                r = this.DateJsonToTime(sDateTime);
                break;
        }
        return r;
    },

    // Formattazione della data  (GG/MM/YYYY)
    "DateJsonToDate": function (sDate) {
        if (!fU.IsEmpty(sDate)) {
            sDate = sDate.toString();
            var num = parseInt(sDate.replace(/[^0-9]/g, ""));
            var date = new Date(num);
            var gg = "0" + date.getDate();
            var me = "0" + (parseInt(date.getMonth() + 1));
            var an = date.getFullYear();
            var d = gg.substring(gg.length - 2) + "/" + me.substring(me.length - 2) + "/" + an;
            return (d == "01/01/1970" ? "" : d);
        } else {
            return "";
        }
    },

    // Formattazione della data per Chrome (YYY-MM-GG)
    "DateJsonToDateRev": function (sDate) {
        if (!fU.IsEmpty(sDate)) {
            sDate = sDate.toString();
            var num = parseInt(sDate.replace(/[^0-9]/g, ""));
            var date = new Date(num);
            var gg = "0" + date.getDate();
            var me = "0" + (parseInt(date.getMonth() + 1));
            var an = date.getFullYear();
            var d = an + "-" + me.substring(me.length - 2) + "-" + gg.substring(gg.length - 2);
            return (d == "01-01-1970" ? "" : d);
        } else {
            return "";
        }
    },

    // Formattazione di data ora  (GG/MM/YYYY HH:MM:SS)
    "DateJsonToTime": function (sDate) {
        if (!fU.IsEmpty(sDate)) {
            sDate = sDate.toString();
            var num = parseInt(sDate.replace(/[^0-9]/g, ""));
            var date = new Date(num);
            var gg = "0" + date.getDate();
            var me = "0" + (parseInt(date.getMonth() + 1));
            var an = date.getFullYear();
            var or = "0" + date.getHours();
            var mi = "0" + date.getMinutes();
            var se = "0" + date.getSeconds();
            var d = gg.substring(gg.length - 2) + "/" + me.substring(me.length - 2) + "/" + an + " "
                + or.substring(or.length - 2) + ":" + mi.substring(mi.length - 2) + ":" + se.substring(se.length - 2);
            return (d == "01/01/1970 01:00:00" ? "" : d);
        } else {
            return "";
        }
    },

    // Formattazione di data ora  Per Chrome (YYYY-MM-GG HH:MM:SS)
    "DateJsonToTimeRev": function (sDate) {
        if (!fU.IsEmpty(sDate)) {
            sDate = sDate.toString();
            var num = parseInt(sDate.replace(/[^0-9]/g, ""));
            var date = new Date(num);
            var gg = "0" + date.getDate();
            var me = "0" + (parseInt(date.getMonth() + 1));
            var an = date.getFullYear();
            var or = "0" + date.getHours();
            var mi = "0" + date.getMinutes();
            var se = "0" + date.getSeconds();
            var d = an + "-" + me.substring(me.length - 2) + "-" + gg.substring(gg.length - 2) + " "
                + or.substring(or.length - 2) + ":" + mi.substring(mi.length - 2) + ":" + se.substring(se.length - 2);
            return (d == "1970/01/01 01:00:00" ? "" : d);
        } else {
            return "";
        }
    },

    "DateToSql": function (sDate) {
        var g = '';
        var m = '';
        var a = '';
        var r;

        r = sDate.replace("-", "").replace("-", "");
        r = r.replace("/", "").replace("/", "");

        //Testa il browser
        switch (oApp.BrowserType) {
            case enumBrowser.Explorer:
                //Explorer in italiano è l'unico che ha bisogno della data "girata"
                switch (navigator.language.substr(0, 2).toLowerCase()) {
                    case "it":
                        g = r.substr(0, 2);
                        m = r.substr(2, 2);
                        a = r.substr(4, 8);
                        break;
                    default:
                        m = r.substr(0, 2);
                        g = r.substr(2, 2);
                        a = r.substr(4, 8);
                        break;
                }
                r = a + m + g;
                break;
            default:
                break;
        }
        return r;
    },

    // Restituisce true se il valore passato alla funzione è null
    "IsNull": function (val) {
        if (val == null || val == undefined)
            return true;

        return false;
    },

    // Restituisce true se il check passato alla funzione è checked = true
    "IsChecked": function (check) {
        if ($(check).prop("checked") == true)
            return true;
        else
            return false;
    },

    "IsVisible": function (ele) {
        if ($(ele).is(":visible") == true)
            return true;
        else
            return false;
    },

    // Restituisce nullval se il valore passato alla funzione è null; se anche nullvall = null allora la funzione restituirà ""
    "IfNull": function (val, nullval) {
        // Verifico nullval
        nullval = (this.IsNull(nullval) ? "" : nullval);
        // Return
        return (this.IsNull(val) ? nullval : val);
    },

    // Verifica se il valore passato alla funzione è una data valida
    "IsDate": function (val) {

        // Se il valore passato alla funzione è vuoto torna true
        if (!fU.IsEmpty(val)) {

            var date = Date.parse(val);

            if (isNaN(date)) {
                return false;
            }

            val = val.replace(/-/g, '/');
            var comp = val.split('/');

            if (comp.length !== 3) {
                return false;
            }

            var s0 = comp[0].length;
            var s1 = comp[1].length;
            var s2 = comp[2].length;

            //testa la lunghezza del dato (2xGG, 2xMM, 4xAAAA magari non in questo ordine)
            if (s0 + s1 + s2 == 8) {
                return true;
            } else {
                return false;
            }
        } else { return true }
    },

    // Formatta la data prima di inserirla nel campo in base al browser e alla lingua
    "DateFormatToBrowserLang": function (date) {

        var r;
        //Testa il browser
        switch (oApp.BrowserType) {
            case enumBrowser.Explorer:
                //Explorer in italiano è l'unico che ha bisogno della data "girata"
                switch (navigator.language.substr(0, 2).toLowerCase()) {
                    case "en":
                        r = date.replace("-", "").replace("-", "");
                        r = r.replace("/", "").replace("/", "");
                        g = r.substr(0, 2);
                        m = r.substr(2, 2);
                        a = r.substr(4, 8);
                        r = m + "/" + g + "/" + a;
                        break;
                    default:
                        r = date;
                }
                break;
            default:
                r = date;
        }

        return r;
    },

    // Restituisce nullval se il valore passato alla funzione è null o ugale a epval (per default IsNull(nullval) == true ->  = "")
    "IsEmpty": function (val) {
        val = this.ToString(val);
        return (val == "" ? true : false);
    },
    // Restituisce epval se il valore passato alla funzione è ""
    "IfEmpty": function (val, epval) {
        // Verifico epval
        epval = (this.IsEmpty(epval) ? "" : epval);
        // Return
        return (this.IsEmpty(val) ? epval : val);
    },

    // Converte il valore String passato alla funzione in boolean
    "ToBool": function (val) {
        var v = false;
        if (val == undefined) val = "undefined";
        if (val === true) val = "true";
        if (val === false) val = "false";
        // Convrte il numero in stringa perchè la prop toLowerCase supporta solo stringhe
        if (val == 1 || val == 0) val = fU.ToString(val);
        switch (val.toLowerCase()) {
            case "true":
            case "vero":
            case "1":
                v = true;
        }
        return v;
    },

    //Restituisce sempre una stringa
    "ToString": function (val) {
        if (val == undefined) val = "";
        if (val == null || val == "null") val = "";
        if (val == "NaN") val = "";
        if (val === true) val = "true";
        if (val === false) val = "false";
        val = val.toString();

        return val;
    },
    //Restituisce la stringa o null (mai vuoto)
    "ToStringNull": function (val) {
        if (val == undefined) val = null;
        if (val == null || val == "null") val = null;
        if (val === true) val = "true";
        if (val === false) val = "false";
        if (val == "") val = null;
        val = val;

        return val;
    },

    //Restituisce sempre un valore int32
    "ToInt32": function (val) {
        var r = 0;
        if (!this.IsEmpty(val)) {
            r = parseInt(val);
        }
        return r;
    },

    "ToDecimal": function (val) {
        var r = 0;
        if (!this.IsEmpty(val)) {
            //cambia la virgola in punto
            val = val.replace(",", ".");
            r = parseFloat(val);
        }
        if (!this.IsEmpty(val)) {
        }
        return r;
    },
    // Restituisce la lunghezza del valore passato come parametro
    "LenghtOf": function (val) {
        var r = 0;
        if (val != null) {
            r = val.length;
        }
        return r;
    },

    // Copia val1 in val2
    "Copy": function (val1, val2) {
        val2 = val1;
    },

    // Copia l'elemento specificato dell'array in un oggetto
    "Array2Obj": function (array, idx, obj) {
        var val1 = array[idx];
        this.Copy(val1, obj);
    },

    //Checked in base al valore della variabile attivo (valore boolean) 
    "CheckIf": function (check, attivo) {
        check.prop('checked', attivo);
    },

    //Visualizza o nasconde l'elemento in base alla variabile mostra (val boolean) 
    "ShowIf": function (ele, mostra) {
        if (mostra == false) ele.hide();
        else ele.show();
    },

    "DisableIf": function (ele, disable) {
        if (disable == true) $(ele).attr("disabled", "disabled");
        else ele.removeAttr("disabled");
    },

    // Restituisce true se un valore numerico è undefined, "" o 0
    "IsZeroVal": function (val) {
        return (val == undefined || val == '0' || val == '' ? true : false);
    },

    "IsPrelievoUI": function (preltype) {
        var uion = false;
        switch (preltype) {
            case 0:     //Nessun Prelievo
            case 3:     //Preleva dal più vecchio
                break;
            case 1:     //Prelievo
            case 2:     //Copia righe
                uion = true;
                break;
        }
        return uion;
    },
    "ToLocaleDate": function (date) {
        // Rimuovo dalla data i caratteri non numerici
        var date = parseInt(date.replace(/[^0-9]/g, ''));

        // Converto il valore in Date
        date = new Date(date);

        var options = {
            day: "2-digit",
            month: "2-digit",
            year: "numeric",
        };

        return date.toLocaleDateString("it-IT", options);
    }
}
/****************************************************************************************/

//UTILITY

//Gestione errori chiamate ajax / server
function Ajax_ErrOut(XMLHttpRequest, textStatus, errorThrown) {
    // Variabili di ritorno  
    var response = $.parseJSON(XMLHttpRequest.responseText).Message;
    var status = XMLHttpRequest.status;
    var statusTxt = XMLHttpRequest.statusText;
    // Messaggio restituito
    var text = "ERRORE \n" + response + "\n" + status + " - " + statusTxt;
    PopupMsg_Show(statusTxt, "Ajax", text);
    // ### Sviluppare la pagina della pila dei messaggi 
}

//Gestione errori client
function ErrOut(err) {
    PopupMsg_Show("ERRORE", "ErrOut", err);
    // ### Sviluppare la pagina della pila dei messaggi 
}

// Variabile per la memorizzazione del campo con il focus prima di aprire il popupmsg
var PopupMgs_From;
// Show del popup dei messaggi
// ### Enumerare le tipologie di messagio in modo da arricchire il popup
function PopupMsg_Show(title, result, msg, focusto) {

    //Memorizza l'oggetto con il focus
    if (fU.IsEmpty(focusto)) {
        PopupMgs_From = $(':focus');
    } else {
        PopupMgs_From = focusto;
    }

    //Accoda alla gestione della messaggistica di sessione
    Messages_Add(title, msg);

    //Apre ol popup con ritardo (per far scatenare tutti gli eventi della pagina)
    setTimeout(function () {
        $("#PopupMsg .msg").html(result + ": " + msg);
        $("#PopupMsg .title").html(title);
        $("#PopupMsg .div-btn").show();

        $("#PopupMsg").show();
        $("#PopupMsg button").focus();
    }, 250);
}

function PopupMsg_Hide() {
    //Nasconde il popup
    $("#PopupMsg").hide();
    //Reimposta il focus
    $(PopupMgs_From).focus();
}

function Messages_Add(title, msg) {

    if (oApp.Messages == null) oApp.Messages = [];

    var msg = {
        "DateTime": fU.DateJsonToTime($.now())
        , "Title": title
        , "Message": msg
    };
    //Inserisce il nuovo messaggio per primo nella pila
    oApp.Messages.unshift(msg);
    //oApp.Messages.unshift("[" + fU.DateJsonToTime($.now()) + "] " + fU.ToString(oPrg.ActivePageId) + "<br />" + title + ": " + msg);
}

// -------------------------------------------------
// REGION: FOCUS
// -------------------------------------------------

//evento per impostare il focus sul primo input vuoto (se afterclass != "" è il primo input dopo questa classe)
//function SetFocus(aftername) {
//    //Imposto il focus solo se il terminale ha la tipologia di focus <> da disattivo
//    if (oApp.SetFocus != 0) {

//        //Cerca un testo vuoto diverso dal nome passato alla funzione
//        var e_text = $("#" + oPrg.ActivePageId + " input:visible").filter(function () {
//            //Nome diverso dal quello passato alla funzione e testo vuoto
//            var ret = ($(this).attr("name") != aftername && $(this).val() === "");
//            return ret;
//        });

//        //Se esiste setta il focus
//        if (e_text.length > 0) {
//            $(e_text).filter(":first").focus().select();
//        } else {
//            //Assegna il focus al primo pulsante 
//            $("#" + oPrg.ActivePageId + " button:visible").focus();
//        }

//        //..........................................................................
//        //var find = !fU.IsEmpty(aftername);          //Eseguo la ricerca ?
//        //var findFirst = fU.IsEmpty(aftername);      //Cerco il primo ?
//        //var findIt = false;
//        //$("#" + oPrg.ActivePageId + " input:visible").each(function () {
//        //    //Se ho trovato quello che cercavo O devo trovare il primo
//        //    if ((find && findIt) || findFirst) {
//        //        //Verifico che il campo sia vuoto
//        //        if (this.value === '') {
//        //            this.focus();
//        //            findIt = true;
//        //            return false;
//        //        }
//        //    }
//        //    //Verifica che la classe corrente corrisponda a quella passata alla funzione come after
//        //    if (find && !findIt) { findIt = ($(this).attr("name") == aftername ? false : true); }
//        //});

//    }
//}

// Setta il focus nel primo campo della pg con classe first-focus visibile
function SetFocus() {
    $("#" + oPrg.ActivePageId + " .first-focus:visible:enabled").first().focus().select();
}

// Nasconde l'oggetto corrispondente all'id passato alla funzione e imposta il focus nel campo
function HideAndFocus(id) {
    $("#" + id).hide();
    Find_Next_Tabindex();
}

// Aggiungere al progetto la funzione i tabindex a tutti i campi e una variabile globale 
// per attivare e disattivare la funzionalità (per attivarla verificare sia che SetFocus == 1 && la nuova variabile == true)
function Find_Next_Tabindex() {
    var newindex = -1;
    // La variabile index contiene il tabindex dell'oggetto attualmente con il focus nella pagina corrente
    var index = fU.ToInt32($(ActivePage()).find(":focus").attr("tabindex"));
    // Se non ho trovato nessun campo con il focus lo setto sul primo della pg che ha il tabindex
    if (fU.IsEmpty(index) || index <= 0) {
        SetFocus();
        return;
    }

    // Se index == all'ultimo visibile e abilitato della pagina richiamo il setfocus
    if (index == $(ActivePage()).find("[tabindex]:visible:enabled").last().attr("tabindex")) {
        SetFocus();
    }
    else {
        // Prendo tutti gli oggetti (input, select, textarea.. visibili e abilitati nella pagina corrente (i visibility:hidden sono considerati visibili))
        $(ActivePage()).find("[tabindex]:visible:enabled").each(function (i, obj) {
            if (fU.ToInt32($(obj).attr("tabindex")) > index) {
                // Verifico che il campo successivo sia vuoto altrimenti continuo a cercare il prossimo vuoto
                //if (fU.IsEmpty($(obj).val()) || $(obj).attr("name") == "Quantita") {}

                // Prendo il nuovo tabindex                         
                newindex = fU.ToInt32($(obj).attr("tabindex"));
                //Esce dal for each
                return false;
            }
        });

        // Se new tab è ancora -1 non ho trovato nulla e riporto il focus sul primo oggetto della pagina
        if (newindex == -1) {
            // Newindex sarà uguale al tab del primo oggetto visibile e abilitato della pagina
            newindex = fU.ToInt32($(ActivePage()).find("[tabindex]:visible:enabled").first().attr("tabindex"));
        }
        //Focus sul campo
        $(ActivePage()).find("[tabindex='" + newindex + "']").focus().select(); // Inutile? .addClass("mo-br-orange");
    }
}
// -------------------------------------------------
// ENDREGION: FOCUS
// -------------------------------------------------

function ActivePage() {
    return $('#' + oPrg.ActivePageId);
}

function ActivePageDOM() {
    return document.getElementById(oPrg.ActivePageId);
}

function GetBindedValues(querySelector) {
    // Recupero gli elementi bindati
    var bindedElements = querySelector ? $(ActivePage()).find(querySelector).find('[data-bind]').toArray() : $(ActivePage()).find('[data-bind]').toArray();

    // Direzione del Binding
    // Set:         data-bind-direction="OneWay"
    // Set & Get:   data-bind-direction="TwoWay"

    // Funzione per recuperare il valore dall'elemento del DOM
    var getElementValue = function (element) {
        var value = null;

        switch ($(element).prop('tagName').toLowerCase()) {
            case 'input':
                switch ($(element).attr('type').toLowerCase()) {
                    case 'checkbox':
                        value = $(element).prop('checked');
                        break;
                    case 'number':
                        value = fU.ToDecimal($(element).val());
                        break;
                    default:
                        value = $(element).val();
                        break;
                }
                break;
            case 'textarea':
                value = $(element).val();
                break;
            case 'select':
                value = $(element).val();
                break;
            default:
                value = $(element).text();
                break;
        }

        return value;
    }

    // Oggetto con i valori
    var bindedValues = {};

    // Creo un oggetto data-bind: value
    bindedElements.forEach(function (element) {
        bindedValues[$(element).attr('data-bind')] = getElementValue(element);
    });

    return bindedValues;
}

// Rolling
$(document).ready(function () {
    // Tabelle con rolling attivo
    var tables = $('[data-rolling="true"]').toArray();

    tables.forEach(function (table) {
        // Colonne della tabella
        var columns = $(table).find('th').toArray();

        // Indici delle colonne con il rolling
        var keys = [];
        // Rollings
        var rollings = [];

        columns.forEach(function (column, index) {
            if ($(column).attr('data-rolling-key')) {
                // Stile del rolling
                $(column).addClass('mo-underline').addClass('mo-pointer');

                // Key del rolling
                var key = $(column).attr('data-rolling-key');

                // Array con distinct delle chiavi
                if (!keys.includes(key))
                    keys.push(key);

                // Oggetto del rolling
                var rollItem = {
                    index: index,
                    key: key
                };

                // Memorizzo la colonna
                rollings.push(rollItem);

                // Click sulla colonna
                $(column).click(function () {
                    var rollingGroup = rollings.filter(function (item) { return item.key == key });
                    var activeIndex = rollingGroup.indexOf(rollItem);
                    var nextIndex = activeIndex < rollingGroup.length - 1 ? rollingGroup[activeIndex + 1].index : rollingGroup[0].index;
                    setActiveColumn(nextIndex, key);
                });
            }
        });

        // Funzione per settare la colonna attiva (nascondendo le altre)
        var setActiveColumn = function (index, key) {
            // Recupero gli indici del rolling (chiave della colonna)
            var indexes = [];
            rollings.filter(function (item) { return item.key == key }).forEach(function (item) {
                indexes.push(item.index);
            });

            // Per ogni indice
            indexes.forEach(function (item) {
                // Mostro/nascondo le colonne d'intestazione
                if (item == index) {
                    $(columns[item]).attr('data-rolling-active', 'true');
                    $(columns[item]).show();
                } else {
                    $(columns[item]).attr('data-rolling-active', 'false');
                    $(columns[item]).hide();
                }

                // Mostro/nasconod le colonne del corpo
                $(table).find('tr').toArray().forEach(function (row) {
                    $(row).find('td').toArray().forEach(function (td, tdIndex) {
                        if (indexes.includes(tdIndex)) {
                            if (index == tdIndex)
                                $(td).show();
                            else
                                $(td).hide();
                        }
                    })
                });
            })
        }

        // Per cambiare programmaticamente la colonna attiva utilizzare:
        // $(tableSelector).attr("data-rolling-active", newIndex).trigger('datachange', "data-rolling-active");
        // Oppure la funzione custom:
        // $(tableSelector).setData('data-rolling-active', newIndex);
        //$(table).on('datachange', function (e, key) {
        //    if (key == 'data-rolling-active') {
        //        var index = $(table).attr('data-rolling-active');
        //        setActiveColumn(index);
        //    }
        //});

        // Attivo la prima colonna
        keys.forEach(function (key) {
            var index = rollings.find(function (item) { return item.key == key; }).index;
            setActiveColumn(index, key);
        });
    });
});

$.fn.setData = function (key, variable) {
    $(this).attr(key, variable).trigger('datachange', key);
}