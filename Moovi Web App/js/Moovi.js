/*
      Moovi.js
      Contiene tutte le funzioni e gli oggetti della pagina moovi.aspx

        #1.00 REGION: FUNZIONI BASE
        #1.10 REGION: CHIAMATE AJAX
            #1.11 AJAX SEARCH
            #1.12 AJAX DETAILS
        #1.20 REGION: BARCODE
        #1.30 REGION: FUNZIONI UI
        #1.40 REGION: FUNZIONI LOAD
        #1.50 REGION: TEMPLATE
        #1.60 REGION: CLEAR PAGE
        #1.70 REGION: xListaCarico
        #1.80 REGION: EVENTI KEYPRESS
        #1.90 REGION: EXECUTE
        #2.00 REGION: COMANDI LISTENER
        #2.10 REGION: FUNZIONALITA' GENERICHE
        #2.20 REGION: SPEDIZIONE
        #2.30 REGION: ACQUISIZIONE ALIAS
        #2.40 REGION: INTERROGAZIONE MAGAZZINO
        #2.50 REGION: STOCCAGGIO MERCE
*/



// -------------------------------------------------
// #1.00 REGION: FUNZIONI BASE
// -------------------------------------------------




//$(document).ready(function () {
//    registerBrowserDataSession(); // in Global.js
//});

// Init di Moovi.aspx
function Init() {

    // Fondamentale per ajaxCall ed ajaxCallSync in ajax.js per capire da dove provengo!
    window.baseUrl = "Moovi.aspx"

    // Carica gli oggetti del local e session storage
    DataSession_Load();

    Init_SettingsTAG();

    Media_Query();

    // Nascondo tutto
    $(".mo-page").hide();

    // Carico la variabile oApp
    // ATTENZIONE la variabile oAPP va subito testata se nulla (non è possibile testarne i valori delle var interne)
    // oApp = fU.GetSession("oApp");
    oApp = oSessionStorage.get("oApp");

    if (fU.IsNull(oApp)) {
        //oApp non valida: esco al log-in
        location.assign("default.htm");
        return false;
    }

    // Verifico se l'utente è loggato (va sempre testato dopo la verifica che oApp != null)
    if (fU.ToBool(oApp.Logon) == false) {
        location.assign("default.htm");
        return false;
    }


    // ASSEGNAZIONE EVENTI Begin

    // ### swipe!

    // Al resize della finestra browser chiama la funzione di media query
    $(window).resize(function () {
        Media_Query();
        // nascondo la prima riga della tabella delle rilevazioni
        $('tbody tr.template_ARDesc').first().hide();

    });

    // Allo scroll della pagina visulizza il bottone per tornare al top page se esistente nella pagina attiva
    window.onscroll = function () { When_PageScroll() };

    $(window).on("orientationchange", function () {
        Media_Query();
    });

    // Click sulla label moovi
    $("label.mo-btn-home").on("click", function () {
        //Reset del sottomenù selezionato
        oApp.SottoMenuAttivo = null;
        //Va alla home page
        GoHome();
    });

    // Click menu principale
    $("li.menu-principale").on("click", function () {
        switch ($(this).attr("id")) {
            case 'menu-ca':
            case 'menu-cp':
            case 'menu-ad':
            case 'menu-prav':
                // Gestisco il sotto menu
                GoToSottoMenu($(this).attr("id"));
                break;
            case 'menu-in':
                // Gestisco il sotto menu
                GoToSottoMenu($(this).attr("id"));
                break;
            case 'menu-da':
                // Carico il programma dei documenti aperti
                oPrg.Load("DA");
                break;
            case 'menu-tr':
                oPrg.Load("TI");
                break;
            case 'menu-mi':
                break;
            case 'menu-ac':
                // Carico il programma dei documenti aperti
                oPrg.Load("AC");
                break;
            case 'menu-rs':
                oPrg.Load('RS');
                break;
            case 'menu-pr':
                oPrg.Load('PR');
                break;
            //case 'menu-in':
            //    oPrg.Load('IN');
            //    break;
            case 'menu-sp':
                oPrg.Load('SP');
                break;
            case 'menu-aa':
                oPrg.Load('AA');
                break;
            case 'menu-im':
                oPrg.Load('IM');
                break;
            case 'menu-sm':
                oPrg.Load('SM');
                break;
            case "menu-log":
                oPrg.Load("LOG");
                break;
            case 'menu-lo':
                LogOff();
                break;
            default:
                //Errore di programmazione
                PopupMsg_Show("Messaggio", "1", "Identificativo del menù non gestito!! " + $(this).attr("id"));
                break;
        }


    });

    //// Binda l'evento invio a tutti i campi (non funziona)
    //$(document).keydown(function (event) {
    //    var keycode = (event.keyCode ? event.keyCode : event.which);
    //    if (keycode === 13) {
    //        //$(document.activeElement).css({ "color": "red", "border": "2px solid red" });
    //        //var ne = $(document.activeElement).nextAll('input:first');
    //        //if (ne != undefined) { var ne = $(document.activeElement).nextAll('select:first'); }
    //        //if (ne != undefined) { var ne = $(document.activeElement).nextAll('textarea:first'); }
    //        //if (ne != undefined) { var ne = $(document.activeElement).nextAll('button:first'); }
    //        //if (ne != undefined) {
    //        //    event.preventDefault();
    //        //    ne.focus();
    //        //    $(ne).css({ "color": "blue", "border": "2px solid blue" });
    //        //} else {
    //        //    $('input,select,textarea,button').first().focus();
    //        //}
    //    }
    //});

    //Click delle icone per le ricerche
    $(".search").on("click", function () {
        Search_Open($(this));
    });

    //Click dei bottoni di conferma per avviare la validazione e il salvataggio della pagina
    $(".validate").on("click", function () {
        fPage.Validate();
    });

    //Click del check che seleziona di tutti i documenti prelevabili
    $("#pgDOPrelievi .ck-documenti").on("click", function () {
        // Seleziona tutti i check delle righe di tamplate non disabilitati
        $("#pgDOPrelievi .template").find(":checkbox:not(:disabled)").prop('checked', this.checked);
    });

    //Click sui campi di partenza della ricerca
    $.each($("i.search"), function (key, i) {
        var input = $(i).parent().find("input");

        //Eventi keydown
        $(input).keydown(function (e) {
            if (e.which == 114) {   //F3
                setTimeout(Search_Open, 250, $(i));
                return false;
            }
        });

    });

    // Click sui campi Search .filtro
    $(".filtro").keydown(function (e) {
        if (e.which == 114) {   //F3
            return false;
        }
    });

    // Click sui campi Search .filtro
    $(".filtro").keyup(function (e) {
        var do_search = true;
        var select_first = false;
        switch (e.which) {
            case 13:    //Invio
                //Se il campo non è vuoto seleziona la prima ricerca della lista
                select_first = true;
                break;
            case 114:   //F3
                do_search = false;
                $("#" + oPrg.ActiveSearchId).hide();
                break;
            default:
                break;
        }
        //Esegue la ricerca
        if (do_search) setTimeout(Filtro_Execute, 500, $(this), $(this).val(), select_first);
    });

    // Click dell'icon dettaglio cliente visibile in pgRL solo se in modalità edit 
    $("#pgRL .detail").on("click", function () {
        Detail_Ajax_xmovs_CF($("#pgRL input[name='Cd_CF']").val());
    });

    // Click dei bottoni nel popup delle azioni del dettaglio della packing list
    $("#Popup_PKListAR_DelShift i").on("click", function () {

        switch ($(this).attr('action')) {
            case 'shift':
                Ajax_xmosp_xMORLRigPackList_Shift();
                break;
            case 'delete':
                Ajax_xmosp_xMORLRigPackList_Del();
                break;
        }

        $('#Popup_PKListAR_DelShift').hide();
    });

    //focus degli input
    $("input[type='text']").on('focus', function () {
        $(this).select();
        if (DEBUG) { $(".debug").text($(this).val()); }
    });

    // Focusout dell'input con classe input-label.
    // Viene aggiornata la label correlata al campo con il val dell'input
    $(".input-label").on('focusout', function () {
        var name = $(this).attr("name");
        $("#" + oPrg.ActivePageId + " label." + name.toLowerCase() + "").text($(this).val());
    });

    //Gestione del keypress execute 
    $("input.keypressexec").on("keypress", function (e) {
        KeyPress_Execute(e.keyCode, $(this));
    });

    // Click dettaglio BC in pgRLRig
    $("#pgRLRig .detail-bc").on("click", function () {
        Detail_Barcode();
    });

    // Click dettaglio Articolo - Ubicazioni 
    $(".detail-giacar").on("click", function () {
        var inputubi = $(this).attr("data-inputubi");
        var mg = $(this).attr('data-mg');
        $("#" + oPrg.ActivePageId + " input[name='Cd_AR']").val() != '' ? Detail_Ajax_xmofn_ARMGUbicazione_Giac(inputubi, mg) : PopupMsg_Show("ATTENZIONE", "1", "Nessun articolo specificato");
    });

    // Click dettaglio Ubicazione - Articoli 
    $(".detail-giacubi").on("click", function () {
        // Recupero dall'icona stessa l'attributo name del campo da cui prendere l'ubicazione da passare alla funzione che carica il detail
        var Cd_MGUbi = $("#" + oPrg.ActivePageId + " input[name='" + $(this).attr("data-inputUbi") + "']").val();
        !fU.IsEmpty(Cd_MGUbi) ? Detail_Ajax_xmofn_MGUbicazioneAR_Giac(Cd_MGUbi) : PopupMsg_Show("ATTENZIONE", "1", "Nessuna ubicazione specificata");
    });

    // Click dettaglio letture in pgRLRig
    $(".detail-letture").on("click", function () {

        switch (oPrg.ActivePageValue) {
            case enumPagine.pgRLRig:
                Detail_Ajax_xmovs_xMORLRig();
                break;
            case enumPagine.pgTRRig_P:
                Detail_Ajax_xmovs_xMOTRRig_P();
                break;
            case enumPagine.pgTRRig_A:
                Detail_Ajax_xmovs_xMOTRRig_A();
                break;
        }

        $("#Detail_Letture").show();
    });

    // Visualizza pgRLPK in modalità detail 
    $(".detail-pklistref").on("click", function () {
        oPrg.PK.RLPKDetail = true;
        // Prendo il packlistref selezionato
        oPrg.PK.PackListRef = $("#" + oPrg.ActivePageId + " select[name='PackListRef']").val();
        // Simulo il next page
        Nav.Next();
        // Nascondo i bottoni back e next
        Nav.NavbarShowIf(false, false);
    });

    $("#pgRLPK :input[name='PesoNettoMks'], #pgRLPK :input[name='PesoLordoMks']").on("change", function (e) {
        oLocalStorage.set("pgRLPK_lastPesoInput", e.target.name);
    });

    $(".detail-pklist").on("click", function () {
        // Carico il detail in base al tipo di visualiuzzazione attivo
        if (fU.IsChecked($("#Detail_PackingList .ck-visualsing")))
            Detail_Ajax_xmofn_xMORLRigPackingList_AR();
        else
            Detail_Ajax_xmofn_xMORLRigPackingList_AR_GRP();
        $("#Detail_PackingList").show();
        if ($("#Detail_PackingList .ck-visualsing").attr("checked") === 'checked') {
            $(".pk-dati table.dati-ar tbody tr ").find("th:nth-child(1), td:nth-child(1)").show()
        } else {
            $(".pk-dati table.dati-ar tbody tr ").find("th:nth-child(1), td:nth-child(1)").hide()
        }

    });

    //Gestione del toggle delle sezioni div
    $("div.div-accordion").find(".header").on("click", function (event) {
        //Verifico che l'elemento che ha scatenato il click sia l'header del div toggle
        //serve per inibire il click del toggle se ho eseguito click su icone di azioni 
        if ($(event.target).hasClass("header") || $(event.target).hasClass("icon")) {
            DivToggle_Execute($(this).parent());
        }
    });

    // Interpretazione dei barcode 
    $(".barcode").find("input").on("keydown", function (e) {
        if (e.keyCode == '13') {    //INVIO
            Barcode_Enter(this, $(this.parentElement).find("select"));
        }
    });

    // Invio nel campo QtaRilevata
    $("#pgINRig .div-detail input[name='QtaRilevata']").keypress(function (e) {
        if (e.which == 13)  // INVIO
        {
            // Gestisce l'invio nel campo QtaRilevata
            Detail_pgINRig_AR_Confirm();
        }
    });

    // Click keys arrow per lo scorrimento tra gli articoli da inventariare nel detail
    $("#pgINRig .div-detail").keydown(function (e) {
        if (fU.IsChecked($("#pgINRig .div-detail .ck-sequenziale"))) {
            switch (e.which) {
                case 37: // arrow left
                    IN_SlideShow(-1);
                    break;
                case 39: // arrow right
                    IN_SlideShow(1);
                    break;
            }
        }
    });

    // All'invio sul btn-confirm di pgRLRig confermo la lettura
    $("#pgRLRig .btn-confirm").keydown(function (btn) {
        if (btn.which == 13) // INVIO
        {
            Confirm_Read(oPrg.drDO.EseguiControlli);
            onRowCountChange();
        }
    });

    //// Al click del ESC torna alla HOME ### va impostato nelle sezioni giuste!!
    //$(document).keypress(function (e) {
    //    if (e.which == 27) // ESC
    //    {
    //        $(".mo-btn-home").click();
    //    }
    //});

    // Check nella ricerca dei lotti che li filtra per giacenza
    $("#SearchARLotto .ck-giacpositiva").on("click", function () {
        Search_Ajax_xmofn_ARLotto();
    });

    // Check nella ricerca degli articoli che permette di nascondere o mostrare gli ar fittizi 1 = visibili 0 = nascosti
    $("#SearchAR .ck-fittizi").on("click", function () {
        Search_Ajax_xmofn_AR();
    });

    $("#pgINRig .div-in-ar-new input[name='Cd_AR']").on("keypress", function (e) {
        if (e.which == 13) {
            Ajax_xmofn_Get_AR_From_AAA($(this).val());
        }
    });

    // In fase di selezione per l'aggiunta di un ar all'inventario verifico la giacenza e carico la tabella che la mostra all'operatore
    $("#pgINRig .div-in-ar-new input").on("input", function () {
        setTimeout(function () {
            Ajax_xmofn_xMOGiacenza_IN_SelAr();
        }, 1000);
    });

    $("#pgRLRig input[name='Cd_AR']").on("keydown", function (e) {
        if (e.keyCode == '13') {
            // Sull invio del campo articolo svuoto la label contenente alias alternativo o cd ar per ricalcolare il tutto (Ar, um, ecc)
            $("#pgRLRig .ar-aa").text("");
        }
    });

    $("input[name='Cd_AR']").on("change", function () {
        //L'articolo è cambiato: svuoto l'alias
        $("#" + oPrg.ActivePageId + " .ar-aa").text("");
        // Pulisce il select delle UM
        $("#" + oPrg.ActivePageId + " select[name='Cd_ARMisura'] .op-um").remove();
        //Dopo aver cambiato il cd_ar gestisce quantità e um
        AR_Set_Qta_UM();
    });

    $("input[name='Cd_AR']").keydown(function () {
        $(".div-giac").css("display", "none")
    });

    // Compila il campo CF e cerca il codice corrispondente
    $("input[name='Cd_CF']").on("keypress keydown", function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) // TAB or INVIO
        {
            var cfval = $("#" + oPrg.ActivePageId + " input[name='Cd_CF']").val();
            var codcf = cfval.substr(1);

            if (codcf.length < 6) {
                for (var i = 0; codcf.length < 6; i++) {
                    codcf = '0' + codcf;
                }
            }
            codcf = cfval.substring(0, 1).concat(codcf);
            var CF = Ajax_xmofn_CF(codcf);
            if (!fU.IsEmpty(CF)) {
                $("#" + oPrg.ActivePageId + " input[name = 'Cd_CF']").val(CF.Cd_CF);
                $("#" + oPrg.ActivePageId + " label[name='CF_Descrizione']").text(CF.Descrizione);
            } else {
                $("#" + oPrg.ActivePageId + " label[name='CF_Descrizione']").text("");
            }
        }
    });

    // Evento che apre l'elenco dei documenti per selezionare gli articoli da stoccare
    $(".detail-smdocs").on("click", function () {
        Detail_Ajax_xmofn_xMOTRDoc4Stoccaggio();
    });

    // Click keys arrow per lo scorrimento tra gli articoli da inventariare nel detail
    //$("#pgSMRig_T").keydown(function (e) {
    //    switch (e.which) {
    //        case 37: // arrow left
    //            SM_SlideShow(true);
    //            break;
    //        case 39: // arrow right
    //            SM_SlideShow(false);
    //            break;
    //    }
    //});

    // Se deseleziono il check caria ar da stoccare da elenco documenti elimino i riferimenti ai documenti selezionati
    $("#pgSMLoad .ck-smdocs").on("click", function () {
        if (!fU.IsChecked($(this))) {
            $(this).attr("Id_DOTess", "");
            $("#pgSMLoad .docs").text("");
        }
    });

    // Se cambia il contenuto del campo mg arrivo nel flusso sm allora svuoto il campo ubi di arrivo
    $("#pgSMRig_T input[name='Cd_MG_A']").on("change", function () {
        $("#pgSMRig_T input[name='Cd_MGUbicazione_P']").val("");
    });

    $("#pgSMRig_T input[name='Cd_MGUbicazione_A']").on("focus change lostfocus", function () {
        if (!fU.IsEmpty($(this).val())) {
            var statogiac = Ajax_xmofn_StatoGiac($(this).val());
            var border = statogiac > 0 ? "orange" : "green";
            $("#" + oPrg.ActivePageId + " .detail-giacubi").css("color", border);
        } else {
            $("#" + oPrg.ActivePageId + " .detail-giacubi").css("color", "black");
        }
    });

    // ---------------------------------------------------------------------
    // ATTENZIONE: Questo evento deve essere assegnato come ultimo !!!!!! 
    // ---------------------------------------------------------------------
    $("[tabindex]").keydown(function (e) {
        $("#lblmsg").text(e.which);
        if (e.which == 13) {
            Find_Next_Tabindex();
        }
    });

    // ASSEGNAZIONE EVENTI End

    // Gestione del menù
    Menu_Init();

    // Gestione del sotto menu
    SottoMenu_Init();

    // Vado alla home page
    GoHome();


}


function onRowCountChange() {
    var el = $("#pgRLRig").find(".div-letture").find(".mo-ofy-auto");
    el.attr("style", "height: " + oLocalStorage.get("altezzaLetture") + "px;");
    if ($('#pgRLRig tbody tr').length <= 3) {
        el.attr("style", "height: 45px;");
    }
}

function setDisplayHeight() {
    $("#pgRLRig :input").focusout(function () {
        settingsModal.lastFocusedInput = $(this);
    })
    onRowCountChange();
};

/*
    Diverse pers.
 */


// pers. per Varsya 20220426
function showFor_W44716() {
    var W44716 = 44716; // per fare le prove sostituire con il proprio nuero di licenza
    if (oApp.LicF_Id == W44716 && (ActivePage().attr('id') == "pgRLRig")) {
        ActivePage().find("th.Cd_MGUbicazione, td.Cd_MGUbicazione").removeClass("display-none");
    }
}

// pers. per IT Consulting (SEM)
function checkMATBarcode(barcode) {

    switch (Number(oApp.LicF_Id)) {
        case 61812: // (Gruppo Sem, sono attive 4 ditte)
        case 81047: // (Water Time, 1 ditta)
        case 33076:
            if (oPrg.BC.CurrentBC && oPrg.BC.CurrentBC.Cd_xMOBC == "MAT" && barcode.length > 18) {
                var msg = 'Troppi caratteri nel barcode letto. \n';
                msg += 'Il barcode del tipo ' + oPrg.BC.CurrentBC.Descrizione + ' non può superare 18 caratteri!';

                alert(msg);

                return false;
            }
            return true;
            break;
        default:
            return true;
    }
    return false;

}

/*
    END Diverse pers.
 */

// Logout
function LogOff() {
    oApp.Logon = false;
    //fU.SetSession(oApp);
    oSessionStorage.set("oApp", oApp);
    location.assign("default.htm");
}

// Torna alla home page e ripulisce le variabili
function GoHome(force) {

    if (fU.ToBool(force)) {
        oApp.SottoMenuAttivo = null;
    }

    // Reset della variabile oPrg
    oPrg.Reset();
    // Pulisco tutte le pagine
    oPrg.ResetPages();

    // Hide della navigazione
    $(".nav-next").hide();
    $(".nav-back").hide();

    // Pulisco le info nell'header
    $("#header .info").html("");

    // Verifico se devo andare al sotto menu (solo se la direzione è indietro)
    if (!fU.IsNull(oApp.SottoMenuAttivo)) {
        // Show della pagina sotto menu
        fPage.Show("pgSottoMenu");
    } else {

        Ajax_xmofn_DOAperti()

        // Se ci sono doc. aperti mostro il numero sulla voce di menu
        if (!oPrg || oPrg.DA.length == 0)
            $("#pgHome #ulMenu li#menu-da .mo-tag").hide();
        else {
            $("#pgHome #ulMenu li#menu-da .mo-tag").text(oPrg.DA.length);
            $("#pgHome #ulMenu li#menu-da .mo-tag").show();
        }

        // Show della home page
        fPage.Show("pgHome");
    }
}

// Gestisce il sotto menu
function GoToSottoMenu(c) {
    // Memorizzo il sotto menu corretto
    oApp.SottoMenuAttivo = c;
    // Show del sotto menu
    $("#ulSottoMenu li.menu-doc").hide();
    $("#ulSottoMenu li." + c).show();
    // Visualizzo il sotto menu corretto
    GoHome();
}

// Inizializzazione del Menù 
function Menu_Init() {

    //rimuove gli eventuali menù personalizzati
    $("#pgHome li.menu-us").remove();

    //Se esistono menù personalizzati li genera dal template
    if (!fU.IsNull(oApp.dtxMOMenu)) {
        // clono il li di template
        var li = $("#menu-us-template").clone().removeAttr("id").removeAttr("style").addClass("menu-us");

        $.each(oApp.dtxMOMenu, function (key, dr) {
            $(Menu_Template(li.clone(), dr, key)).insertAfter("#menu-us-template");
        });
    }

    //Nasconde il template
    $("#menu-us-template").hide();
}

// Creo un elemento del menu
function Menu_Template(li, item, key) {

    li.attr("key", key).attr("onclick", "oPrg.Load('" + item.xCd_xMOProgramma + "', '" + fU.ToString(item.Cd_DO) + "')");
    li.addClass("menu-us");
    li.attr("id", "menu-us-" + item.xCd_xMOProgramma.toLowerCase());
    if (!fU.IsEmpty(item.Icona)) {
        li.find("i").text(item.Icona);
    }
    if (!fU.IsEmpty(item.Colore)) {
        li.find("i").css("background-color", "#" + item.Colore);
    } else {
        li.find("i").addClass("mo-teal");
    }
    li.find("span").text(item.Descrizione);
    return li;
}

// Inizializzazione dei documenti nel sottomenu
function SottoMenu_Init() {
    // clono il li di template
    var li = $("#SottomenuTemplate").clone().removeAttr("id").removeAttr("style").addClass("menu-doc");

    if (!fU.IsNull(oApp.dtDO)) {

        //Aggiunge TUTTI I DOC CONFIGURATI IN ARCA 
        $.each(oApp.dtDO, function (key, dr) {
            $("#ulSottoMenu").append(Sottomenu_Template(li.clone(), dr, key));
        });

        // Se i trasf. interni sono abilitati aggiungo un doc fasullo nel sottomenu 
        if (oApp.xMOImpostazioni.MovTraAbilita) {
            li = li.clone();
            li.addClass("menu-doc, menu-tr menu-mi");

            //// --?? Eliminare l'attributo Cd_DO e utilizzare la classe menu-mi
            //li.attr("Cd_DO", "Movimenti-Interni");
            li.find(".doc-nome").text("Trasferimenti Interni");
            $("#ulSottoMenu").append(li);
        }

        // Se l'inventario è disabilitato nascondo la voce di menu
        if (!fU.ToBool(oApp.xMOImpostazioni.MovInvAbilita)) {
            $("#menu-in").hide();
            //li = li.clone();
            //li.addClass("menu-doc, menu-in menu-mi");

            //// --?? Eliminare l'attributo Cd_DO e utilizzare la classe menu-mi
            //li.attr("Cd_DO", "Movimenti-Interni");
            //li.find(".doc-nome").text("Inventario");
            //$("#ulSottoMenu").append(li);
        }

        // Se l'acquisizione alias non è abilitata nascondo la voce di menu
        if (!oApp.xMOImpostazioni.AcqAliasAbilita) {
            $("#menu-aa").hide();
        }
    }

    //Aggiunge le voci di inventario massivo e puntuale (fisse)
    $("#ulSottoMenu").append(Sottomenu_Template(li.clone(), Sottomenu_IN_Massivo(), -1));
    $("#ulSottoMenu").append(Sottomenu_Template(li.clone(), Sottomenu_IN_Puntuale(), -2));

    //Gestione voci di menù principali 

    //1) I doc con programma PR attivano il menù principale dei Prelievi
    if ($("#ulSottoMenu [xCd_xMOProgramma='PR']").length == 0) { $("#menu-pr").hide(); }

    //1.1) I doc con programma PR vengono nascosti
    //$("#ulSottoMenu [xCd_xMOProgramma='PR']").remove(); 

    //2.0) I doc con programma SP attivano il menù principale delle spedizioni se l'impostazione spedizione è abilitata
    if ($("#ulSottoMenu [xCd_xMOProgramma='SP']").length == 0 || !oApp.xMOImpostazioni.SpeAbilita) {
        //Non sono presenti Doc con Programma SP: nasconde la voce di menù
        $("#menu-sp").hide();
    }

    //2.1) I doc con programma SP attivano il menù principale delle spedizioni
    //e vengono quindi eliminati come programmi del ciclo attivo, passio o altro
    $("#ulSottoMenu [xCd_xMOProgramma='SP']").remove();

    //3.0) I doc con programma LC attivano il menù principale delle liste di carico
    if ($("#ulSottoMenu [xCd_xMOProgramma='LC']").length == 0) {
        //Non sono presenti Doc con Programma LC: nasconde la voce di menù
        $("#menu-us-lc").hide();
    }
    //3.1) I doc con programma LC attivano il menù principale delle liste di carico
    //e vengono quindi eliminati come programmi del ciclo attivo, passio o altro
    $("#ulSottoMenu [xCd_xMOProgramma='LC']").remove();

    // Se è presente il modulo produzione avanzata attivo il menu
    if (oApp.MRP_Advanced) {
        $("#ulSottoMenu").append(Sottomenu_Template(li.clone(), Sottomenu_PRTR(), -1));
        $("#ulSottoMenu").append(Sottomenu_Template(li.clone(), Sottomenu_PRMP(), -1));
    } else {
        $("#menu-prav").hide();
    }




    //3) Disattiva le voci di menù principali se non hanno doc all'interno
    if ($("#ulSottoMenu .menu-cp").length == 0) { $("#menu-cp").hide(); }
    if ($("#ulSottoMenu .menu-ca").length == 0) { $("#menu-ca").hide(); }
    if ($("#ulSottoMenu .menu-ad").length == 0) { $("#menu-ad").hide(); }
    if ($("#ulSottoMenu .menu-tr").length == 0) { $("#menu-tr").hide(); }
    if ($("#ulSottoMenu .menu-in").length == 0) { $("#menu-in").hide(); }
}

// Creo un elemento del sotto menu
function Sottomenu_Template(li, item, key) {

    li.attr("key", key).attr("onclick", "oPrg.Load('" + item.xCd_xMOProgramma + "', '" + item.Cd_DO + "')");
    li.attr("xCd_xMOProgramma", item.xCd_xMOProgramma);
    li.addClass("menu-" + item.Ciclo + " menu-doc");
    li.find(".doc-nome").text(item.Cd_DO);
    li.find(".doc-desc").text(item.DO_Descrizione.length > 35 ? item.DO_Descrizione.substring(0, 30) + '...' : item.DO_Descrizione);
    // Imposta l'icona del padre
    li.find("i").html($("#menu-" + item.Ciclo).find("i").html());

    return li;
}

function Sottomenu_PRTR() {
    return {
        "xCd_xMOProgramma": "PRTR"
        , "Cd_DO": "TRASFERIMENTO"
        , "Ciclo": "prav"
        , "DO_Descrizione": "Trasfer. mat. per Bolla"
    }
}

function Sottomenu_PRMP() {
    return {
        "xCd_xMOProgramma": "PRMP"
        , "Cd_DO": "RIENTRO"
        , "Ciclo": "prav"
        , "DO_Descrizione": "Rientro. mat. da prod."
    }
}

// Dr per Template Inventario Massivo
function Sottomenu_IN_Massivo() {
    var drInMas = {
        "xCd_xMOProgramma": "INM"
        , "Cd_DO": "MASSIVO"
        , "Ciclo": "in"
        , "DO_Descrizione": "Inventario Massivo"
    }
    return drInMas;
}

// Dr per Template Inventario Puntuale
function Sottomenu_IN_Puntuale() {
    var drInPun = {
        "xCd_xMOProgramma": "INP"
        , "Cd_DO": "PUNTUALE"
        , "Ciclo": "in"
        , "DO_Descrizione": "Inventario Puntuale"
    }
    return drInPun;
}


// Apertura del programma Documenti Aperti
function DocAperti_Apri(li) {
    // Load del programma
    oPrg.Load(li.attr('keyprg'));

}

// Carica la ricerca in base all'icona cliccata 
function Search_Open(icon) {

    //Svuoto tutti i campi filtro dei modal di ricerca
    $(".filtro").text("");

    //Chiave di ricerca 
    var searchkey = icon.attr("searchkey");
    oPrg.ActiveSearchOutField = searchkey; //Memorizzo la serchkey del campo

    //Valore presente nel campo di output di ricerca
    var searchvalue = fU.ToString($("#" + oPrg.ActivePageId).find("input[name='" + searchkey + "']").val()).trim()
    //Se il campo di ricerca è pieno lo inserisce in modo da scatenare la selezione del valore
    oPrg.ActiveSearchValue = searchvalue;

    //Titolo della ricerca
    var searchtitle = fU.ToString(icon.attr("searchtitle"));

    switch (searchkey) {
        case "Cd_CF":
            // Imposta il titolo del modal di ricerca come cliente o fornitore
            if (fU.IsNull(oPrg.drDO)) $("#SearchCF .title").text("CLIENTI / FORNITORI");
            else if (oPrg.drDO.CliFor == 'C') $("#SearchCF .title").text("CLIENTI");
            else if (oPrg.drDO.CliFor == 'F') $("#SearchCF .title").text("FORNITORI");
            else $("#SearchCF .title").text("?? CF ??");
            if (oPrg.Key != 'AA' && oPrg.drDO) {
                switch (oPrg.drDO.xMOPrelievo) {
                    case 0:
                        $("#SearchCF .title").append(" (senza Prelievo)");
                        break;
                    case 1:
                        $("#SearchCF .title").append(" (con " + (oPrg.drDO.xMOPrelievoObb ? " obbligo di " : " possibile ") + "Prelievo)");
                        break;
                    case 2:
                        $("#SearchCF .title").append(" (con " + (oPrg.drDO.xMOPrelievoObb ? " obbligo di " : " possibile ") + "Copia Righe)");
                        break;
                }
            }
            oPrg.ActiveSearchId = "SearchCF";   //Memorizza la ricerca corrente
            Search_Ajax_xmofn_CF();
            break;
        case "Cd_CFDest":
            oPrg.ActiveSearchId = "SearchCFDest";   //Memorizza la ricerca corrente
            Search_Ajax_xmofn_CFDest();
            break;
        case "Cd_AR":
            //Memorizza la ricerca corrente
            oPrg.ActiveSearchId = "SearchAR";   //Memorizza la ricerca corrente
            Search_Ajax_xmofn_AR();
            break;
        case "Cd_MG":
        case "Cd_MG_P":
        case "Cd_MG_A":
            oPrg.ActiveSearchId = "SearchMG";   //Memorizza la ricerca corrente
            $("#SearchMG .title").text(searchtitle);
            Search_Ajax_xmofn_MG();
            break;
        case "Cd_MGUbicazione":
        case "Cd_MGUbicazione_P":
        case "Cd_MGUbicazione_A":
            $("#SearchMGUbicazione .title").text(searchtitle);
            //ATTENZIONE la ricerca funziona sia per Partenza, Arrivo che spersonalizzato! Sarà Search_Close ad assegnare il campo corretto
            oPrg.ActiveSearchId = "SearchMGUbicazione"; //Memorizza la ricerca corrente
            Search_Ajax_xmofn_MGUbicazione();
            break;
        case "Cd_ARLotto":
            oPrg.ActiveSearchId = "SearchARLotto";  //Memorizza la ricerca corrente
            Search_Ajax_xmofn_ARLotto();
            break;
        case "Cd_DOSottoCommessa":
            oPrg.ActiveSearchId = "SearchDOSottoCommessa";
            Search_Ajax_xmofn_xMODOSottoCommessa();
            break;
        case "Cd_DOCaricatore":
            oPrg.ActiveSearchId = "SearchDOCaricatore";
            Search_Ajax_xmofn_DOCaricatore();
            break;
        case "Cd_xMOCodSpe":
            oPrg.ActiveSearchId = "SearchxMOCodSpe"; //Memorizza la ricerca corrente
            Search_Ajax_xmofn_Spedizione();
            break;
        case "xListaCarico":
            oPrg.ActiveSearchId = "SearchxListaCarico"; //Memorizza la ricerca corrente
            Search_Ajax_xmofn_xListaCarico();
            break;
        case "Cd_ARMisura":
            oPrg.ActiveSearchId = "SearchARARMisura"; //Memorizza la ricerca corrente
            Search_Ajax_xmofn_ARARMisura();
            break;
        default:
            PopupMsg_Show("ERRORE", "1", "Errore di gestione del Search_Open() del campo " + searchkey);
            break;
    }

    if (oPrg.ActiveSearchId != "") {
        $("#" + oPrg.ActiveSearchId).show();
        $("#" + oPrg.ActiveSearchId + " .filtro").focus().select();
        $("#" + oPrg.ActiveSearchId + " .filtro").val(oPrg.ActiveSearchValue);
    }
}

// Chiude il modal della ricerca e riempe i campi nella pg corrente
function Search_Close(itemsel) {

    if (!fU.IsNull(itemsel)) {
        //La ricerca si è conclusa con un elemento da assegnare
        switch (oPrg.ActiveSearchId) {
            case 'SearchCF':
                //Assegna il CF
                $("#" + oPrg.ActivePageId + " input[name='" + oPrg.ActiveSearchOutField + "']").val(itemsel.attr("Cd_CF")).focus().select();
                $("#" + oPrg.ActivePageId + " label[name='CF_Descrizione']").text(itemsel.attr("Descrizione"));
                //Gestione del CFDest
                // Show del campo SO se ci sono destinazioni per il cliente selezionato
                fU.ShowIf($("#" + oPrg.ActivePageId + " .div-dest"), fU.ToBool(itemsel.attr("Destinazioni")));
                // Se esiste destinazione di default la inserisce nel campo SO
                $("#" + oPrg.ActivePageId + " input[name='Cd_CFDest']").val(fU.ToString(itemsel.attr("CFDest_Default")));
                $("#" + oPrg.ActivePageId + " label[name='CFDest_Descrizione']").text(fU.ToString(itemsel.attr("CFDest_Descrizione")));
                break;
            case 'SearchCFDest':
                $("#" + oPrg.ActivePageId + " input[name='" + oPrg.ActiveSearchOutField + "']").val(fU.ToString(itemsel.attr("Cd_CFDest"))).focus().select();
                $("#" + oPrg.ActivePageId + " label[name='CFDest_Descrizione']").text(fU.ToString(itemsel.attr("Descrizione")));
                $("#" + oPrg.ActivePageId + " input[name='Cd_CF']").val(fU.ToString(fU.ToString(itemsel.attr("Cd_CF"))));
                $("#" + oPrg.ActivePageId + " label[name='CF_Descrizione']").text(fU.ToString(itemsel.attr("CF_Descrizione")));
                break;
            case 'SearchAR':
                $("#" + oPrg.ActivePageId + " select[name='Cd_ARMisura'] .op-um").remove();
                $("#" + oPrg.ActivePageId + " input[name='" + oPrg.ActiveSearchOutField + "']").val(itemsel.attr("Cd_AR")).focus().select();
                $("#" + oPrg.ActivePageId + " input[name='" + oPrg.ActiveSearchOutField + "']").attr("AR_Desc", itemsel.attr("AR_Desc"));
                $("#" + oPrg.ActivePageId + " input[name='Quantita']").focus().select();
                break;
            case 'SearchMG':
                //Assegna il valore del magazzino selezionato
                $("#" + oPrg.ActivePageId + " input[name='" + oPrg.ActiveSearchOutField + "']").val(itemsel.attr("Cd_MG")).focus().select();
                //Assegna l'etichetta come il valore del magazzino selezionato 
                $("#" + oPrg.ActivePageId + " ." + oPrg.ActiveSearchOutField.toLowerCase()).text(itemsel.attr("Cd_MG"));
                break;
            case 'SearchMGUbicazione':
                $("#" + oPrg.ActivePageId + " input[name='" + oPrg.ActiveSearchOutField + "']").val(itemsel.attr("Cd_MGUbicazione")).focus().select();
                //Discrimina se il magazzino è quello di partenza, di arrivo o un codice Cd_MG per assegnare il valore corretto
                var mgPA = fMG.Mg4PA(oPrg.ActiveSearchOutField);
                $("#" + oPrg.ActivePageId + " input[name='Cd_MG" + mgPA + "']").val(itemsel.attr("Cd_MG"));
                break;
            case 'SearchARLotto':
                $("#" + oPrg.ActivePageId + " input[name='" + oPrg.ActiveSearchOutField + "']").val(itemsel.attr("Cd_ARLotto")).focus().select();
                $("#" + oPrg.ActivePageId + " input[name='Cd_AR']").val(itemsel.attr("Cd_AR")).change();
                if ($("#" + oPrg.ActivePageId + " input[name='Cd_MG_P']").is(":visible") && fU.IsEmpty($("#" + oPrg.ActivePageId + " input[name='Cd_MG_P']").val())) {
                    $("#" + oPrg.ActivePageId + " input[name='Cd_MG_P']").val(itemsel.attr("Cd_MG"));
                    $("#" + oPrg.ActivePageId + " input[name='Cd_MGUbicazione_P']").val(itemsel.attr("Cd_MGUbicazione"));
                }
                else if ($("#" + oPrg.ActivePageId + " input[name='Cd_MG_A']").is(":visible") && fU.IsEmpty($("#" + oPrg.ActivePageId + " input[name='Cd_MG_A']").val())) {
                    $("#" + oPrg.ActivePageId + " input[name='Cd_MG_A']").val(itemsel.attr("Cd_MG"));
                    $("#" + oPrg.ActivePageId + " input[name='Cd_MGUbicazione_A']").val(itemsel.attr("Cd_MGUbicazione"));
                }
                break;
            case 'SearchDOSottoCommessa':
                $("#" + oPrg.ActivePageId + " input[name='" + oPrg.ActiveSearchOutField + "']").val(itemsel.attr("Cd_DOSottoCommessa")).focus().select();
                break;
            case 'SearchDOCaricatore':
                $("#" + oPrg.ActivePageId + " input[name='" + oPrg.ActiveSearchOutField + "']").val(itemsel.attr("Cd_DOCaricatore")).focus().select();
                $("#" + oPrg.ActivePageId + " label[name='CRDescrizione']").text(fU.ToString(itemsel.attr("Desc")));
                break;
            case "SearchxMOCodSpe":
                $("#" + oPrg.ActivePageId + " input[name='" + oPrg.ActiveSearchOutField + "']").val(itemsel.attr("Cd_xMOCodSpe")).focus().select();
                Spedizione_Filter(itemsel.attr("Cd_xMOCodSpe"));
                break;
            case "SearchxListaCarico":
                $("#" + oPrg.ActivePageId + " input[name='" + oPrg.ActiveSearchOutField + "']").val(itemsel.attr("xListaCarico"));
                xListaCarico_Filter(itemsel.attr("xListaCarico"));
                break;
            case "SearchARARMisura":
                $("#" + oPrg.ActivePageId + " input[name='" + oPrg.ActiveSearchOutField + "']").val(itemsel.attr("Cd_ARMisura"));
                break;
            default:
                PopupMsg_Show("ERRORE", "1", "Errore di gestione del Search_Close() del modal " + oPrg.ActiveSearchId);
                break;
        }
        //Scateno l'onkeyup
        $("#" + oPrg.ActivePageId + " input[name='" + oPrg.ActiveSearchOutField + "']").keyup().change();
    }

    //Chiudo la ricerca e svuoto la lista
    $("#" + oPrg.ActiveSearchId).hide();
    $("#" + oPrg.ActiveSearchId + " .li-search").remove();
    //SetFocus();
    if (oPrg.ActiveSearchId !== "SearchAR") // da rivedere con Marco
        Find_Next_Tabindex();
}

// -------------------------------------------------
// ENDREGION: FUNZIONI BASE
// -------------------------------------------------
// -------------------------------------------------
// #1.10 REGION: CHIAMATE AJAX
// -------------------------------------------------

// Elenco Documenti Aperti 
function Ajax_xmofn_DOAperti() {

    var out = false;

    $("#pgDocAperti .li-doc").remove();

    ajaxCallSync(
        "/xmofn_DOAperti",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Filtro: $("#pgDocAperti .filtro").val()
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            oPrg.DA = dt;
            DOAperti_Load(dt);
            out = true;
        }
    );

    return out;
}

// Elenco Documenti Stampabili
function Ajax_xmofn_DORistampa() {

    var out = false;

    $("#pgDocRistampa .li-doc").remove();

    ajaxCallSync(
        "/xmofn_DORistampa",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Filtro: $("#pgDocRistampa .filtro").val()
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            DORistampa_Load(dt);

            out = true;
        }
    );

    return out;
}

// Validazione e Salvataggio di xMOConsumo
function Ajax_xmosp_xMOConsumo_Save() {

    var out = false;

    ajaxCallSync(
        "/xmosp_xMOConsumo_Save",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_xMOLinea: $("#pgAvviaConsumo select[name='Cd_xMOLinea'] option:selected").val(),
            DataOra: fU.DateTimeToSql($("#pgAvviaConsumo input[name='DataOra']").val()),
            Cd_AR: $("#pgAvviaConsumo input[name='Cd_AR']").val(),
            Cd_ARLotto: $("#pgAvviaConsumo input[name='Cd_ARLotto']").val()
        },
        function (mydata) {
            if (mydata.d != '') {
                var r = $.parseJSON(mydata.d);
                if (r[0].Result < 0)
                    PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
                else {
                    //Tutto ok: svuota gli inpuit di avvio consumo
                    $("#pgAvviaConsumo input").val("");
                    PopupMsg_Show("Info", r[0].Messaggio, "ID " + r[0].Id_xMOConsumo);
                    out = true;
                }
            }
        }
    );

    return out;
}

// Validazione e Salvataggio di xMOConsumo per tutti gli articoli del documento che si sta creando (shortcut)
function Ajax_xmosp_xMOConsumoFromRL_Save() {
    var out = false;

    ajaxCallSync(
        "/xmosp_xMOConsumoFromRL_Save",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMORL: oPrg.Id_xMORL_Edit
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result < 0)
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            else
                out = true;
        }
    );

    return out;
}

// Validazione e Salvataggio della testa della rilevazione
function Ajax_xmosp_xMORL_Save() {

    var out = false;

    //Reset della riga di testa delle rilevazioni
    oPrg.drRL = null;

    ajaxCallSync(
        "/xmosp_xMORL_Save",
        {
            Cd_Operatore: oApp.Cd_Operatore,
            Terminale: oApp.Terminale,
            Cd_DO: oPrg.drDO.Cd_DO,
            DataDoc: fU.DateToSql($("#pgRL [name='DataDoc']").val()),
            Cd_CF: $("#pgRL [name='Cd_CF']").val(),
            Cd_CFDest: $("#pgRL [name='Cd_CFDest']").val(),
            Cd_xMOLinea: ($("#pgRL [name='Cd_xMOLinea']").is(":visible") == true ? $("#pgRL [name='Cd_xMOLinea'] option:selected").val() : ''),
            NumeroDocRif: $("#pgRL [name='NumeroDocRif']").val(),
            DataDocRif: fU.DateToSql($("#pgRL [name='DataDocRif']").val()),
            Cd_MG_P: fU.ToString($("#pgRL [name='Cd_MG_P']").val()),
            Cd_MG_A: fU.ToString($("#pgRL [name='Cd_MG_A']").val()),
            Cd_DOSottoCommessa: fU.ToString($("#pgRL input[name='Cd_DOSottoCommessa']").val()),
            Id_xMORL: fU.ToInt32(oPrg.Id_xMORL_Edit)
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result > 0) {
                //Memorizzo l'id in edit
                oPrg.Id_xMORL_Edit = r[0].Id_xMORL;
                // Visualizzo l'id di testa
                $("#pgRL .lb-doc-id").text(oPrg.Id_xMORL_Edit);
                //Carico i dati di drRL
                out = Ajax_xmovs_xMORL();
            }
            else {
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            }
        }
    );

    return out;
}

// Carica la testa del documento
function Ajax_xmovs_xMORL() {
    var out = false;

    ajaxCallSync(
        "/xmovs_xMORL",
        {
            Id_xMORL: fU.ToInt32(oPrg.Id_xMORL_Edit)
        },
        function (mydata) {
            //Memorizzo il record di testa RL
            var r = $.parseJSON(mydata.d);
            //console.log("r[0] ", r[0])
            oPrg.drRL = r[0];
            out = true;
        }
    );

    return out;
}

// Elenco dei Documenti Prelevabili a partire da un Id_DOTes
function Ajax_xmofn_DOTes_Prel() {

    var out = false;

    $("#pgDOPrelievi .tr-prel").remove();

    ajaxCallSync(
        "/xmofn_DOTes_Prel",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_DO: oPrg.drDO.Cd_DO,
            Cd_CF: oPrg.drRL.Cd_CF,
            Cd_CFDest: oPrg.drRL.Cd_CFDest,
            Id_xMORL: oPrg.drRL.Id_xMORL
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            DOPrel_Load(dt);
            out = true;
        }
    );

    return out;
}

// Elenco di Tutti i Documenti Prelevabili
function Ajax_xmofn_DOTes_Prel_4PR() {

    var out = false;

    $("#pgPrelievi .li-prel").remove();

    ajaxCallSync(
        "/xmofn_DOTes_Prel_4PR",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_DO: fU.ToString($("#pgPrelievi input[name='Cd_DO']").val()),
            Cd_CF: fU.ToString($("#pgPrelievi input[name='Cd_CF']").val()),
            Cd_CFDest: fU.ToString($("#pgPrelievi input[name='Cd_CFDest']").val()),
            Cd_DOSottoCommessa: fU.ToString($("#pgPrelievi input[name='Cd_DOSottoCommessa']").val()),
            DataConsegna: fU.ToString($("#pgPrelievi input[name='DataConsegna']").val()),
            Id_DOTes: $("#pgPrelievi input[name='Id_DOTes']").val(),
            Id_xMORL: fU.ToString(oPrg.Id_xMORL_Edit)
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            DOPrel_All_Load(dt);
            out = true;
        }
    );

    return out;
}

// Salva le teste dei documenti prelevabili selezionati
function Ajax_xmosp_xMORLPrelievo_Save(Id_DOTess) {

    var out = false;

    ajaxCallSync(
        "/xmosp_xMORLPrelievo_Save",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMORL: fU.ToInt32(oPrg.Id_xMORL_Edit),
            Id_DOTess: Id_DOTess
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result < 0)
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            else {
                out = true;
            }
        }
    );

    return out;
}

// Salvataggio di xMORL e xMORLPrelievo da Spedizione
function Ajax_xmosp_xMOSpedizione_SaveRL(Id_DOTess, Cd_DO) {

    var out = false;

    ajaxCallSync(
        "/xmosp_xMOSpedizione_SaveRL",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_DOTess: Id_DOTess,
            Cd_DO: Cd_DO
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result < 0)
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            else {
                //Carico i dati per la generazione del documento
                oPrg.LoadDO(Cd_DO);
                //Memorizzo l'id in edit
                oPrg.Id_xMORL_Edit = r[0].Id_xMORL;
                //Carico i dati di drRL
                out = Ajax_xmovs_xMORL();
            }
        }
    );

    return out;

}

// Pers: Salvataggio di xMORL e xMORLPrelievo da LdC 
function Ajax_xmosp_xListaCarico_SaveRL(Id_DOTes, Cd_DO) {

    var out = false;

    ajaxCallSync(
        "/xmosp_xListaCarico_SaveRL",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_DOTes: fU.ToInt32(Id_DOTes),
            Cd_DO: Cd_DO
        },
        function (mydata) {
            if (mydata.d != '') {
                var r = $.parseJSON(mydata.d);
                if (r[0].Result < 0)
                    PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
                else {
                    //Carico i dati per le generazione del documento
                    oPrg.LoadDO(Cd_DO);
                    //Memorizzo l'id in edit
                    oPrg.Id_xMORL_Edit = r[0].Id_xMORL;
                    //Carico i dati di drRL
                    out = Ajax_xmovs_xMORL();
                }
            }
        }
    );

    return out;

}

// Update Documenti Aperti
function Ajax_delete_DocAperto(idxmorl) {
    ajaxCallSync(
        "/delete_DocAperto",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMORL: idxmorl
        },
        function (mydata) {
            //Aggiorno la lista dei doc aperti
            Ajax_xmofn_DOAperti();
        }
    );
}

// Delete trasferimento aperto
function Ajax_delete_TRAperto(idxmotr) {

    ajaxCallSync(
        "/delete_TRAperto",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMOTR: idxmotr
        },
        function (mydata) {
            //Aggiorno la lista dei doc aperti
            Ajax_xmofn_DOAperti();
        }
    );
}

// Elenco Spedizioni 
function Ajax_xmofn_xMOCodSpe() {

    var out = false;

    $("#pgSP .tr-sp").remove();

    ajaxCallSync(
        "/xmofn_xMOCodSpe",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Ordinamento: parseInt(localStorage.getItem("SPFiltro"))
        },
        function (mydata) {
            Spedizione_Load($.parseJSON(mydata.d));
            out = true;
        }
    );

    return out;
}

// Elenco Liste Carico 
function Ajax_xmofn_xListaCarico() {

    var out = false;

    $("#pgxListaCarico .tr-ldc").remove();

    ajaxCallSync(
        "/xmofn_xListaCarico",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore
        },
        function (mydata) {
            xListaCarico_Load($.parseJSON(mydata.d));
            out = true;
        }
    );

    return out;
}

//Recupera il fattore di conversione dalla UI
function UMFatt_FromUI() {
    var out = 1;
    // In base all'impostazione seleziona l'UMFatt
    //console.warn("oPrg.drDO.xMOUMFatt ", oPrg.drDO.xMOUMFatt);
    switch (oPrg.drDO.xMOUMFatt) {
        case 0:
            //Nessuno --> FattoreToUM1 preso dal select delle UM
            out = fU.ToDecimal(ActivePage().find("select[name='Cd_ARMisura'] :selected").attr('umfatt'), 1);
            break;
        case 1:
            //Standard --> FattoreToUM1 se vuoto lo valorizza con 1 
            out = fU.ToDecimal(ActivePage().find("input[name='UMFatt']").val(), 1);
            break;
        case 2:
            //se non ho selezionato l'UM principale 
            if (ActivePage().find("select[name='Cd_ARMisura'] :selected").attr('umdef') == 0) {
                //Qta Dell'UM principale --> FattoreToUM1 = Qta / UMFatt se vuoto lo valorizza con 1
                var Qta = fU.ToDecimal(ActivePage().find("input[name='Quantita']").val(), 0);
                var Fat = fU.ToDecimal(ActivePage().find("input[name='UMFatt']").val(), 1);
                //out = 1 / (Qta / Fat); Non andava bene a CASH
                out = Qta / Fat;
            } else
                out = fU.ToDecimal(ActivePage().find("select[name='Cd_ARMisura'] :selected").attr('umfatt'), 1);
            break;
        default:
            break;
    }
    /*console.warn("out", out)*/
    return out;


}


// Salvataggio Righe Documento
function Ajax_xmosp_xMORLRig_Save(EseguiControlli, extdfld) {

    var out = false;

    var Barcode = (!fU.IsNull(oPrg.BC) ? fU.ToString(oPrg.BC.BarcodeXml()) : "");
    ajaxCallSync(
        "/xmosp_xMORLRig_Save",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMORL: oPrg.Id_xMORL_Edit,
            Cd_AR: fU.ToString(ActivePage().find("input[name='Cd_AR']").val()),
            Cd_MG_P: fU.ToString(ActivePage().find("input[name='Cd_MG_P']").val().trim()),
            Cd_MGUbicazione_P: fU.ToString(ActivePage().find("input[name='Cd_MGUbicazione_P']").val().trim()),
            Cd_MG_A: fU.ToString(ActivePage().find("input[name='Cd_MG_A']").val().trim()),
            Cd_MGUbicazione_A: fU.IfEmpty(ActivePage().find("input[name='Cd_MGUbicazione_A']").val().trim()),
            Cd_ARLotto: fU.ToString(ActivePage().find("input[name='Cd_ARLotto']").val()),
            DataScadenza: fU.DateToSql(ActivePage().find("input[name='DataScadenza']").val()),
            Matricola: fU.ToString(ActivePage().find("input[name='Matricola']").val()),
            Cd_ARMisura: fU.ToString(ActivePage().find("select[name='Cd_ARMisura'] :selected").val()),
            UMFatt: UMFatt_FromUI(),
            Quantita: fU.ToString(parseFloat(ActivePage().find("input[name='Quantita']").val())),
            Barcode: Barcode,
            Cd_DOSottoCommessa: fU.ToString(ActivePage().find("input[name='Cd_DOSottoCommessa']").val()),
            EseguiControlli: fU.ToBool(EseguiControlli),
            PackListRef: oPrg.drDO.PkLstEnabled ? ActivePage().find("select[name='PackListRef']").val() : "",
            Id_DORig: oPrg.Id_DORig,
            ExtFld: fU.IfEmpty(extdfld, "")
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);

            // (2):richiesto intervento dell'operatore
            if (r[0].Result == 2) {
                $("#Popup_Button_OpConfirm").show().find(".msg").text(r[0].Result + ": " + r[0].Messaggio);
            } else {
                // (1):tutto ok
                if (r[0].Result == 1) {
                    out = true;
                } else {
                    PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
                }
                //Aggiorno le righe lette
                Ajax_xmofn_xMORLRig_AR();
            }
        }
    );

    return out;
}

//Propone una ubicazione per l'articolo
function Ajax_xmofn_xMORLRig_GetUbicazione(mg_pa) {
    // Pulisce le righe della tabella
    var posizione;
    posizione = ActivePage().find("input[name='Cd_MGUbicazione_" + mg_pa + "']").attr("posizione") ? fU.ToInt32(ActivePage().find("input[name='Cd_MGUbicazione_" + mg_pa + "']").attr("posizione")) + 1 : 1;

    ajaxCallSync(
        "/xmofn_xMORLRig_GetUbicazione",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMORL: oPrg.Id_xMORL_Edit,
            Cd_MG: fU.ToString(ActivePage().find("input[name='Cd_MG_" + mg_pa + "']").val().trim()),
            Cd_AR: fU.ToString(ActivePage().find("input[name='Cd_AR']").val().trim()),
            Posizione: posizione
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r.length > 0) {
                // Setto l'ubicazione trovata
                ActivePage().find("input[name='Cd_MGUbicazione_" + mg_pa + "']").val(r[0].Cd_MGUbicazione);
                // Setto la posizione corrente
                ActivePage().find("input[name='Cd_MGUbicazione_" + mg_pa + "']").attr("posizione", r[0].Posizione);
                // Sposto il focus
                ActivePage().find("input[name='Quantita']").focus().select();
            } else {
                // Ubicazione non trovata: la svuoto
                ActivePage().find("input[name='Cd_MGUbicazione_" + mg_pa + "']").val("");
                // Setto la poszione a 1
                ActivePage().find("input[name='Cd_MGUbicazione_" + mg_pa + "']").attr("posizione", 0);
            }
        }
    );
}

// Elenco Righe Lette raggruppate per Articolo
function Ajax_xmofn_xMORLRig_AR() {

    // Pulisce le righe della tabella
    ActivePage().find("tr.tr-rigprel").remove();
    oPrg.RL.dtRLRig_AR = [];

    ajaxCallSync(
        "/xmofn_xMORLRig_AR",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMORL: oPrg.Id_xMORL_Edit,
        },
        function (mydata) {
            // Refresh delle righe
            oPrg.RL.dtRLRig_AR = JSON.parse(mydata.d);
            pgRLRig_AR_Load();
            // Refresh del numero di righe lette
            Ajax_select_xMORLRig_NRows();
        }
    );

}

// Elenco righe lette nei trasferimenti di partenza
function Ajax_xmofn_xMOTRRig_P_AR() {

    // Pulisce le righe della tabella
    //$(p).find("table .tr-rigp").remove();
    ActivePage().find("table .tr-rigp").remove();

    ajaxCallSync(
        "/xmofn_xMOTRRig_P_AR",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMOTR: oPrg.Id_xMOTR_Edit,
        },
        function (mydata) {
            // Refresh delle righe
            pgTRRig_P_AR_Load($.parseJSON(mydata.d));
            // Refresh del numero di righe lette
            Ajax_select_xMOTRRig_P_NRows();
        }
    );

}

// Elenco righe lette nei trasferimenti di arrivo
function Ajax_xmofn_xMOTRRig_A_AR() {

    var p = "#pgTRRig_A";
    ActivePage().find(".tr-riga").remove();

    ajaxCallSync(
        "/xmofn_xMOTRRig_A_AR",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMOTR: oPrg.Id_xMOTR_Edit,
        },
        function (mydata) {
            // Refresh delle righe
            var dt = $.parseJSON(mydata.d)
            pgTRRig_A_AR_Load(dt);
            // Refresh del numero di righe lette
            Ajax_select_xMOTRRig_A_NRows();
        }
    );
}

// Elenco UM dell 'ARTICOLO selezionato
function Ajax_xmofn_ARARMisura(TipoARMisura, xMOUmDef) {

    var out = false;

    // Pulisce il select
    $("#" + oPrg.ActivePageId + " select[name='Cd_ARMisura'] .op-um").remove();

    ajaxCallSync(
        "/xmofn_ARARMisura",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_AR: fU.ToString($("#" + oPrg.ActivePageId + " input[name='Cd_AR']").val()),
            TipoARMisura: TipoARMisura,
            xMOUmDef: xMOUmDef
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            ARARMisura_Load(dt);
            out = true;
        }
    );

    return out;
}

// Elenco UM dell 'ARTICOLO selezionato
function Ajax_xmofn_ARARMisura2(Cd_AR, Cd_ARMisura) {
    var out = false;

    // Pulisce il select
    $("#" + oPrg.ActivePageId + " select[name='Cd_ARMisura'] .op-um").remove();

    ajaxCallSync(
        "/xmofn_ARARMisura2",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_AR: fU.ToString(Cd_AR),
            Cd_ARMisuraDef: fU.ToString(Cd_ARMisura)
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            ARARMisura_Load(dt);
            out = true;
        }
    );

    return out;
}

// Recupera l'um dell'alias letto e la seleziona
function Ajax_xmofn_ARAlias_ARMisura() {

    ajaxCallSync(
        "/xmofn_ARAlias_ARMisura",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_AR: fU.ToString($("#" + oPrg.ActivePageId + " input[name='Cd_AR']").val()),
            Alias: fU.ToString($("#" + oPrg.ActivePageId + " .ar-aa").text()),
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (!fU.IsEmpty(r[0].Cd_ARMisura)) {
                $("#" + oPrg.ActivePageId + " select[name='Cd_ARMisura']").val(r[0].Cd_ARMisura.toUpperCase());
            }
        }
    );

}

// Delete ultima Lettura del DO in pgRLRig
function Ajax_xmosp_xMORLLast_Del() {

    ajaxCallSync(
        "/xmosp_xMORLLast_Del",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMORL_Del: fU.ToInt32(oPrg.Id_xMORL_Edit)
        },
        function (mydata) {
            // Ricarica le letture della pagina da DB e refresh della tabella
            Ajax_xmofn_xMORLRig_AR();
        }
    );

}

// Numero di Letture effettuate  in pgRLRig
function Ajax_select_xMORLRig_NRows() {
    var out = false;

    ajaxCallSync(
        "/xmofn_xMORLRig_Info_Letture_AR",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMORL: oPrg.Id_xMORL_Edit
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            if (dt.length > 0) {
                oPrg.RL.ARIncompleti = dt[0].ArticoliIncompleti;
                oPrg.RL.ARCompleti = dt[0].ArticoliCompleti;
                oPrg.RL.Letture = dt[0].Letture;
            }
            // Gestione icon delete e dettagglio in base alla presenza di letture
            pgRLRig_Letture_UI();
            out = true;
        }
    );

    return out;
}

// Numero di Letture effettuate in pgTRRig_P
function Ajax_select_xMOTRRig_P_NRows() {
    var out = false;

    ajaxCallSync(
        "/select_xMOTRRig_P_NRows",
        {
            Id_xMOTR: oPrg.Id_xMOTR_Edit
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            // Gestione icon delete e dettaglio in base alla presenza di letture
            if (r[0].NRows == 0) {
                $("#pgTRRig_P .div-letture .delete").hide();
                $("#pgTRRig_P .div-letture .detail-letture").hide();
            }
            else {
                $("#pgTRRig_P .div-letture .delete").show();
                $("#pgTRRig_P .div-letture .detail-letture").show();
            }
            $("#pgTRRig_P .letture").text(r[0].NRows);
            out = true;
        }
    );

    return out;
}

// Numero di Letture effettuate in pgTRRig_A
function Ajax_select_xMOTRRig_A_NRows() {
    var out = false;

    ajaxCallSync(
        "/select_xMOTRRig_A_NRows",
        {
            Id_xMOTR: oPrg.Id_xMOTR_Edit,
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            // Gestione icon delete e dettaglio in base alla presenza di letture
            if (r[0].NRows == 0) {
                $("#pgTRRig_A .div-letture .delete").hide();
                $("#pgTRRig_A .div-letture .detail-letture").hide();
            }
            else {
                $("#pgTRRig_A .div-letture .delete").show();
                $("#pgTRRig_A .div-letture .detail-letture").show();
            }
            $("#pgTRRig_A .letture").text(r[0].NRows);
            out = true;
        }
    );

    return out;
}

// Chiude la spedizione 
function Ajax_xmosp_xMORLPiede_ChiudiSpedizione() {
    var out = false;

    ajaxCallSync(
        "/xmosp_xMORLPiede_ChiudiSpedizione",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMORL: oPrg.Id_xMORL_Edit,
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result == 1) {
                out = true;
            }
            else {
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            }
        }
    );

    return out;

}
// Salvataggio Piede  Documento
function Ajax_xmosp_xMORLPiede_Save() {

    var out = false;

    ajaxCallSync(
        "/xmosp_xMORLPiede_Save",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMORL: oPrg.Id_xMORL_Edit,
            Targa: ActivePage().find("input[name='Targa']").val(),
            Cd_DOCaricatore: ActivePage().find("input[name='Cd_DOCaricatore']").val(),
            PesoExtraMks: fU.IfEmpty(ActivePage().find("input[name='PesoExtraMks']").val(), 0),
            VolumeExtraMks: fU.IfEmpty(ActivePage().find("input[name='VolumeExtraMks']").val(), 0),
            NotePiede: ActivePage().find("textarea[name='NotePiede']").val()
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result == 1) {
                /* Se l'operatore ha chiesto di salvare il documento (senza stampare)
                o se non sono presenti moduli di stampa
                salva il documento e torna alla Home*/
                if (!fU.ToBool(ActivePage().find(".ck-print").prop("checked")) || (oPrg.drDO.Moduli <= 0)) {
                    // se richiesto chiude la spedizione
                    if (fU.IsChecked($("#" + oPrg.ActivePageId).find("input[name='ChiudiSpedizione']")))
                        Ajax_xmosp_xMORLPiede_ChiudiSpedizione();

                    //Salvo lo stato del documento accodandolo al listener
                    var cmd = Listener_RLSave(oPrg.Id_xMORL_Edit);
                    Ajax_ListenerCoda_Add(cmd, oPrg.Id_xMORL_Edit);
                    oPrg.Pages[oPrg.ActivePageIdx].GoHome = true;
                }
                else {
                    oPrg.Pages[oPrg.ActivePageIdx].GoHome = false;
                    //Carico i dati di drRL
                    oPrg.drRL = null;
                    out = Ajax_xmovs_xMORL();
                }
                out = true;
            }
            else {
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            }
        }
    );

    return out;
}

// Elenco Devices 
function Ajax_xmofn_xMOListenerDevice() {

    // Svuota il select dei device 
    $("#pgStampaDocumento .op-lsdevice").remove();

    ajaxCallSync(
        "/xmofn_xMOListenerDevice",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_xMOListener: $("#pgStampaDocumento select[name='Listener']").val()
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            ListenerDevice_Load(dt);
            Ajax_xmofn_xMOListener_Moduli();
        }
    );

}

// Elenco Moduli Stampa
function Ajax_xmofn_xMOListener_Moduli() {

    // Svuoto la lista dei moduli
    $("#pgStampaDocumento .li-modulo").remove();

    ajaxCallSync(
        "/xmofn_xMOListener_Moduli",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            ComputerName: $("#pgStampaDocumento select[name='Listener']").val(),
            Cd_DO: oPrg.drDO.Cd_DO
        },
        function (mydata) {
            dt = $.parseJSON(mydata.d);
            Listener_Moduli_Load(dt);
        }
    );

}

// Informazioni sulle Letture visibili in pgRLPiede
function Ajax_xmofn_xMORLRig_Totali() {

    ajaxCallSync(
        "/xmofn_xMORLRig_Totali",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMORL: oPrg.Id_xMORL_Edit
        },
        function (mydata) {
            var row = $.parseJSON(mydata.d);
            // Carica i dati nella pagina
            xMORLRig_Totali_Template(row[0]);
        }
    );

}

// Delete Lettura del DO
function Ajax_xmosp_xMORLRig_Del(Id_xMORLRig_Del) {

    ajaxCallSync(
        "/xmosp_xMORLRig_Del",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMORLRig_Del: Id_xMORLRig_Del
        },
        function (mydata) {
            var result = $.parseJSON(mydata.d);
            if (result[0].Result > 0)
                // Aggiorno le letture sulla tabella 
                Ajax_xmofn_xMORLRig_AR();
            //Aggiorno la lista del dettaglio delle letture
            Detail_Ajax_xmovs_xMORLRig();
        }
    );

}

// Verifica e valida la coerenza dei documenti da prelevare selezionati in pgPrelievi
function Ajax_xmosp_xMORLPrelievo_Validate(Id_DOTess, Cd_DO) {

    var out = false;

    ajaxCallSync(
        "/xmosp_xMORLPrelievo_Validate",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_DO: fU.ToString(Cd_DO),
            Id_DOTess: fU.ToString(Id_DOTess)
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            // ### Sviluppare il caso in cui il result == 2 in cui si richiede l'intervento dell'operatore 
            //per la scelta dei dati di testa del documento che risultano incorenti tra quelli selezionati per il prelievo 
            if (r[0].Result != 1)
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            else {
                out = true;
            }
        }
    );

    return out;
}

// Salva la RL dei prelievi validati precedentemente da  'Ajax_xmosp_xMORLPrelievo_Validate'
function Ajax_xmosp_xMORLPrelievo_SaveRL(Id_DOTess, Cd_DO, Cd_CF) {

    var out = false;

    ajaxCallSync(
        "/xmosp_xMORLPrelievo_SaveRL",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_DO: fU.ToString(Cd_DO),
            Id_DOTess: fU.ToString(Id_DOTess),
            Id_xMORL: fU.ToString(oPrg.Id_xMORL_Edit)
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result < 0)
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            else {
                // Carico i parametri del tipo di DO da creare
                oPrg.LoadDO(Cd_DO);
                // Memorizzo in edit l'id della testa appena creata
                oPrg.Id_xMORL_Edit = r[0].Id_xMORL;
                out = true;
            }
        }
    );

    return out;
}

// Salva la TR del trasferimento interno
function Ajax_xmosp_xMOTR_Save() {

    var out = false;

    ajaxCallSync(
        "/xmosp_xMOTR_Save",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Descrizione: fU.ToString($("#pgTR input[name='Descrizione']").val()),
            DataMov: fU.DateToSql(ActivePage().find("input[name='DataMov']").val()),
            //DataMov: fU.DateToSql(fU.LocalDateStringToDate($("#pgTR input[name='DataMov']").val())),
            //DataMov: fU.DateToSql($("#pgTR input[name='DataMov']").val()),
            Cd_MG_P: fU.ToString($("#pgTR input[name='Cd_MG_P']").val()),
            Cd_MGUbicazione_P: fU.ToString($("#pgTR input[name='Cd_MGUbicazione_P']").val()),
            Cd_MG_A: fU.ToString($("#pgTR input[name='Cd_MG_A']").val()),
            Cd_MGUbicazione_A: fU.ToString($("#pgTR input[name='Cd_MGUbicazione_A']").val()),
            Cd_DOSottoCommessa: fU.ToString($("#pgTR input[name='Cd_DOSottoCommessa']").val()),
            Id_xMOTR: fU.ToString(oPrg.Id_xMOTR_Edit),
            Cd_xMOProgramma: oApp.dtPrograms[oPrg.Key].Key
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result < 0)
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            else {
                // Memorizzo in edit l'id della testa del TI appena creata
                oPrg.Id_xMOTR_Edit = r[0].Id_xMOTR;
                // Visualizzo l'id in pgTR
                $("#pgTR .lb-doc-id").text(fU.ToString(oPrg.Id_xMOTR_Edit))
                out = true;
            }
        }
    );

    return out;

}

// Salva le Righe del TR di PARTENZA
function Ajax_xmosp_xMOTRRig_P_Save() {
    var out = false;

    ajaxCallSync(
        "/xmosp_xMOTRRig_P_Save",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMOTR: oPrg.Id_xMOTR_Edit,
            Cd_AR: fU.ToString(ActivePage().find("input[name='Cd_AR']").val()),
            Cd_ARLotto: fU.ToString(ActivePage().find("input[name='Cd_ARLotto']").val()),
            Quantita: fU.ToString(parseFloat(ActivePage().find("input[name='Quantita']").val())),
            Cd_ARMisura: fU.ToString(ActivePage().find("select[name='Cd_ARMisura'] :selected").val()),
            Cd_MG_P: fU.ToString(ActivePage().find("input[name='Cd_MG_P']").val()),
            Cd_MGUbicazione_P: fU.ToString(ActivePage().find("input[name='Cd_MGUbicazione_P']").val().trim()),
            Id_xMOTRRig_P: "",
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result == 1) {
                out = true;
            }
            else {
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            }
            //Aggiorno le righe lette
            Ajax_xmofn_xMOTRRig_P_AR();
        }
    );

    return out;
}

// Elimina l'ultima lettura effettuata nei TR di PARTENZA
function Ajax_xmosp_xMOTRRig_P_Last_Del() {

    ajaxCallSync(
        "/xmosp_xMOTRRig_P_Last_Del",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMOTR_Del: fU.ToInt32(oPrg.Id_xMOTR_Edit)
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result != 1) {
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            }
            // Ricarica le letture della pagina da DB e refresh della tabella
            Ajax_xmofn_xMOTRRig_P_AR();
        }
    );

}

function Ajax_xmosp_xMOTRRig_P_Del(Id_xMOTRRig_P_Del) {

    ajaxCallSync(
        "/xmosp_xMOTRRig_P_Del",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMOTRRig_P_Del: Id_xMOTRRig_P_Del
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result != 1)
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            // Aggiorno le letture sulla tabella 
            Ajax_xmofn_xMOTRRig_P_AR();
            //Aggiorno la lista del dettaglio delle letture
            Detail_Ajax_xmovs_xMOTRRig_P();
        }
    );

}

// Salva le Righe del TR di PARTENZA
function Ajax_xmosp_xMOTRRig_A_Save() {
    var out = false;
    var p = "#" + oPrg.ActivePageId;

    ajaxCallSync(
        "/xmosp_xMOTRRig_A_Save",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMOTR: oPrg.Id_xMOTR_Edit,
            Id_xMOTRRig_P: ActivePage().find("input[name='Cd_AR']").attr("Id_xMOTRRig_P"),
            Quantita: parseFloat(ActivePage().find("input[name='Quantita']").val()),
            Cd_ARMisura: fU.ToString(ActivePage().find("select[name='Cd_ARMisura'] :selected").val()),
            Cd_MG_A: fU.ToString(ActivePage().find("input[name='Cd_MG_A']").val()),
            Cd_MGUbicazione_A: fU.ToString(ActivePage().find("input[name='Cd_MGUbicazione_A']").val().trim()),
            Id_xMOTRRig_A: "",
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result == 1) {
                out = true;
            }
            else {
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            }
            //Aggiorno le righe lette
            Ajax_xmofn_xMOTRRig_A_AR();
        }
    );

    return out;
}

// Elimina l'ultima lettura effettuata nei TR di ARRIVO
function Ajax_xmosp_xMOTRRig_A_Last_Del() {

    ajaxCallSync(
        "/xmosp_xMOTRRig_A_Last_Del",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMOTR_Del: fU.ToInt32(oPrg.Id_xMOTR_Edit)
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result != 1) {
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            }
            // Ricarica le letture della pagina da DB e refresh della tabella
            Ajax_xmofn_xMOTRRig_A_AR();
        }
    );

}

function Ajax_xmosp_xMOTRRig_A_Del(Id_xMOTRRig_A_Del) {

    ajaxCallSync(
        "/xmosp_xMOTRRig_A_Del",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMOTRRig_A_Del: Id_xMOTRRig_A_Del
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result != 1)
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            // Aggiorno le letture sulla tabella 
            Ajax_xmofn_xMOTRRig_A_AR();
            //Aggiorno la lista del dettaglio delle letture
            Detail_Ajax_xmovs_xMOTRRig_A();
        }
    );

}

// Se esiste restituisce l'Id_xMOTR di un trasferimento ancora aperto
function Ajax_xmofn_xMOTR_To_Edit() {

    ajaxCallSync(
        "/xmofn_xMOTR_To_Edit",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMOTR: fU.ToInt32(oPrg.Id_xMOTR_Edit)

        },
        function (mydata) {
            var row = $.parseJSON(mydata.d);
            if (!fU.IsEmpty(row[0].Id_xMOTR)) {
                oPrg.Id_xMOTR_Edit = row[0].Id_xMOTR;
                oPrg.drTR = row[0];
            }
        }
    );

}

// Dati riepilogo per pgTRPiede
function Ajax_xmofn_xMOTRRig_Totali() {

    ajaxCallSync(
        "/xmofn_xMOTRRig_Totali",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMOTR: oPrg.Id_xMOTR_Edit
        },
        function (mydata) {
            var row = $.parseJSON(mydata.d);
            // Carica i dati nella pagina
            xMOTRRig_Totali_Template(row[0]);
        }
    );

}

// Salvataggio del piede del trasferimento
function Ajax_xmosp_xMOTRPiede_Save() {

    var out = false;

    ajaxCallSync(
        "/xmosp_xMOTRPiede_Save",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMOTR: oPrg.Id_xMOTR_Edit
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result == 1) {
                //Salvo lo stato del documento accodandolo al listener
                var cmd = Listener_TRSave(oPrg.Id_xMOTR_Edit);
                Ajax_ListenerCoda_Add(cmd, 0, oPrg.Id_xMOTR_Edit);
                //Vado alla Home
                oPrg.Pages[oPrg.ActivePageIdx].GoHome = true;
                out = true;
            }
            else {
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            }
        }
    );

    return out;
}

function Ajax_xmofn_Get_AR_From_AAA(Cd_AR, Cd_CF) {

    ajaxCallSync(
        "/xmofn_Get_AR_From_AAA",
        {
            Cd_AR: Cd_AR,
            Cd_CF: fU.IfEmpty(Cd_CF, "")
        },
        function (mydata) {
            var theCd_AR = mydata.d;
            if (!fU.IsEmpty(theCd_AR)) {
                // Mette il codice immesso dall'op nella label alias/codici alternativi'
                $("#" + oPrg.ActivePageId + " .ar-aa").text(Cd_AR);
                // Sotituisce il valore dell'input con il Cd_AR effettivo restituito dalla funzione
                $("#" + oPrg.ActivePageId + " input[name='Cd_AR']").val(theCd_AR);
            }
            else {
                //Verifico se è stato caricato un documento
                if (oPrg.drDO) {
                    // verifica se è abilitata l'acquisizione alias avvia il popup per l'insert
                    if (oApp.dtDO[oPrg.drDO.Cd_DO].xMOAA) {
                        // Visualizzo il popup per andare alla pagina di inserimento degli alias
                        Popup_ARAlias_Insert_Show(Cd_AR);
                    }
                    else {
                        $("#" + oPrg.ActivePageId + " input[name='Cd_AR']").val("");
                        PopupMsg_Show("ERRORE", "1", "Articolo " + Cd_AR + " non trovato");
                    }
                }
            }
        }
    );

}

// Recupera le pklRef se esistono
function Ajax_xmofn_xMORLRigPackingList() {

    $("#pgRLRig select[name='PackListRef'] .op-pklref").remove();

    ajaxCallSync(
        "/xmofn_xMORLRigPackingList",
        {
            Terminale: oApp.Terminale
            , Cd_Operatore: oApp.Cd_Operatore
            , Id_xMORL: oPrg.Id_xMORL_Edit
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            if (dt.length > 0) {
                PackListRef_Load(dt);
            }
            else {
                // Se non sono stati trovati PackListRef ne propongo uno nuovo
                Popup_PackList_New_Load();
            }
        }
    );
}

// Recupera il codice successivo da proporre come nuovo pklRef
function Ajax_xmofn_xMORLRigPackingList_GetNew() {

    ajaxCallSync(
        "/xmofn_xMORLRigPackingList_GetNew",
        {
            Terminale: oApp.Terminale
            , Cd_Operatore: oApp.Cd_Operatore
            , Id_xMORL: oPrg.Id_xMORL_Edit
        },
        function (mydata) {
            var PK = mydata.d;
            if (!fU.IsEmpty(PK)) {
                // Inserisco il codice restituito dalla sp nell'input del popup
                $("#Popup_PackList_New input[name='PackListRef']").val(PK);
            }
            else {
                PopupMsg_Show("ATTENZIONE", "", "Nessun PackList nuovo è stato generato");
            }
        }
    );

}

function Ajax_xmosp_xMORLRigPackList_Del() {
    var out = false;

    var p = $("#Popup_PKListAR_DelShift");

    ajaxCallSync(
        "/xmosp_xMORLRigPackList_Del",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMORLRigPackList_Del: p.attr("Id_xMORLRigPackList"),
            Qta_Del: p.find("input[name='Qta']").val()
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result == 1) {
                // Refresh del dettaglio e del select dei packlistref
                if (fU.IsChecked($("#Detail_PackingList .ck-visualsing"))) {
                    Detail_Ajax_xmofn_xMORLRigPackingList_AR();
                } else {
                    Detail_Ajax_xmofn_xMORLRigPackingList_AR_GRP();
                }
                Ajax_xmofn_xMORLRigPackingList();
                out = true;
            }
            else {
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            }
        }
    );

    return out;
}

function Ajax_xmosp_xMORLRigPackList_Shift() {

    var out = false;

    var p = $("#Popup_PKListAR_DelShift");

    ajaxCallSync(
        "/xmosp_xMORLRigPackList_Shift",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMORLRigPackList: p.attr("Id_xMORLRigPackList"),
            PackListRef_New: p.find("select[name='PackListRef']").val(),
            Qta_New: p.find("input[name='Qta']").val()
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result == 1) {
                // Refresh del dettaglio e del select dei packlistref
                if (fU.IsChecked($("#Detail_PackingList .ck-visualsing"))) {
                    Detail_Ajax_xmofn_xMORLRigPackingList_AR();
                } else {
                    Detail_Ajax_xmofn_xMORLRigPackingList_AR_GRP();
                }
                Ajax_xmofn_xMORLRigPackingList();
                out = true;
            }
            else {
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            }
        }
    );

    return out;
}

// Elenco tipologie di UL
function Ajax_xmofn_xMOUniLog() {

    ajaxCallSync(
        "/xmofn_xMOUniLog",
        {
            Terminale: oApp.Terminale
            , Cd_Operatore: oApp.Cd_Operatore
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            if (dt.length > 0) {
                xMOUniLog_Load(dt);
            }
        }
    );

}

// Update/Insert di un nuovo PackListRef 
function Ajax_xmosp_xMORLPackListRef_Add() {
    var out = false;

    var PackListRef = $("#Popup_PackList_New input[name='PackListRef']").val();
    var Cd_xMOUniLog = $("#Popup_PackList_New select[name='Cd_xMOUniLog']").val()

    ajaxCallSync(
        "/xmosp_xMORLPackListRef_Add",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMORL: oPrg.Id_xMORL_Edit,
            PackListRef: PackListRef,
            Cd_xMOUniLog: Cd_xMOUniLog
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result == 1) {
                // Aggiunge il pklRef se non è già presente nel select
                xMORLPackListRef_Add_Template(PackListRef);
                out = true;
            }
            else {
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            }
        }
    );

    return out;
}

// Elenco dei PKListRef del doc corrente per la pgRLPK
function Ajax_xmofn_xMORLPackListRef() {

    oPrg.PK.ResetAll();

    ajaxCallSync(
        "/xmofn_xMORLPackListRef",
        {
            Terminale: oApp.Terminale
            , Cd_Operatore: oApp.Cd_Operatore
            , Id_xMORL: oPrg.Id_xMORL_Edit
            , PackListRef: fU.ToString(oPrg.PK.PackListRef)
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            if (dt.length > 0) {
                oPrg.PK.dtxMORLPK = dt;
                oPrg.PK.idx = 0;
            }
            else {
                PopupMsg_Show("ATTENZIONE", "", "Nessun PackListRef trovato");
            }
        }
    );

}

function Ajax_xmosp_xMORLPackListRef_Save() {
    var out = false;
    if (!oPrg.PK.idx)
        return true;

    var p = $("#pgRLPK");
    var Cd_xMOUniLog = p.find(".Cd_xMOUniLog").text() == 'Nessuno' ? "" : fU.ToString(p.find(".Cd_xMOUniLog").text());
    var PesoTaraMks = fU.ToDecimal(p.find("input[name='PesoTaraMks']").val());
    var PesoNettoMks = fU.ToDecimal(p.find("input[name='PesoNettoMks']").val());
    var PesoLordoMks = fU.ToDecimal(p.find("input[name='PesoLordoMks']").val());
    var AltezzaMks = fU.ToDecimal(p.find("input[name='AltezzaMks']").val());
    var LunghezzaMks = fU.ToDecimal(p.find("input[name='LunghezzaMks']").val());
    var LarghezzaMks = fU.ToDecimal(p.find("input[name='LarghezzaMks']").val());

    ajaxCallSync(
        "/xmosp_xMORLPackListRef_Save",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMORLPackListRef: oPrg.PK.dtxMORLPK[oPrg.PK.idx].Id_xMORLPackListRef,
            Cd_xMOUniLog: Cd_xMOUniLog,
            PesoTaraMks: PesoTaraMks,
            PesoNettoMks: PesoNettoMks,
            PesoLordoMks: PesoLordoMks,
            AltezzaMks: AltezzaMks,
            LunghezzaMks: LunghezzaMks,
            LarghezzaMks: LarghezzaMks,
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result == 1) {
                //Aggiorno i dati sul client
                oPrg.PK.dtxMORLPK[oPrg.PK.idx].Cd_xMOUniLog = Cd_xMOUniLog;
                oPrg.PK.dtxMORLPK[oPrg.PK.idx].PesoTaraMks = PesoTaraMks;
                oPrg.PK.dtxMORLPK[oPrg.PK.idx].PesoNettoMks = PesoNettoMks;
                oPrg.PK.dtxMORLPK[oPrg.PK.idx].PesoLordoMks = PesoLordoMks;
                oPrg.PK.dtxMORLPK[oPrg.PK.idx].AltezzaMks = AltezzaMks;
                oPrg.PK.dtxMORLPK[oPrg.PK.idx].LunghezzaMks = LunghezzaMks;
                oPrg.PK.dtxMORLPK[oPrg.PK.idx].LarghezzaMks = LarghezzaMks;

                out = true;
            }
            else {
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            }
        }
    );

    return out;

}

// Salva la TR del trasferimento interno
function Ajax_xmosp_xMOSM_Save() {
    var out = false;

    ajaxCallSync(
        "/xmosp_xMOTR_Save",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Descrizione: fU.ToString($("#pgSM input[name='Descrizione']").val()),
            DataMov: "",         // La passo sempre vuota perchè viene presa getdate la to sql
            Cd_MG_P: fU.ToString($("#pgSM input[name='Cd_MG_P']").val()),
            Cd_MGUbicazione_P: fU.ToString($("#pgSM input[name='Cd_MGUbicazione_P']").val()),
            Cd_MG_A: fU.ToString($("#pgSM input[name='Cd_MG_A']").val()),
            Cd_MGUbicazione_A: "",       // La passo sempre vuota perchè nel caso di SM l'ubicazione di arrivo sarà proposta per riga
            Cd_DOSottoCommessa: "",      // La passo sempre vuota perchè nel caso di SM la commessa non è stata ancora gestita
            Id_xMOTR: fU.ToString(oPrg.Id_xMOTR_Edit),
            Cd_xMOProgramma: oApp.dtPrograms[oPrg.Key].Key,
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result < 0)
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            else {
                // Memorizzo in edit l'id della testa del TI di stoccaggio merce appena creato
                oPrg.Id_xMOTR_Edit = r[0].Id_xMOTR;
                // Visualizzo l'id in pgSM
                $("#pgSM .lb-doc-id").text(fU.ToString(oPrg.Id_xMOTR_Edit));
                Ajax_xmovs_xMOSM();
                out = true;
            }
        }
    );

    return out;

}

// Carica la testa dello stoccaggio
function Ajax_xmovs_xMOSM() {
    var out = false;

    ajaxCallSync(
        "/xmovs_xMOSM",
        {
            Id_xMOTR: fU.ToInt32(oPrg.Id_xMOTR_Edit),
            Cd_xMOProgramma: oPrg.Key
        },
        function (mydata) {
            //Memorizzo il record di testa SM
            var r = $.parseJSON(mydata.d);
            oPrg.drTR = r[0];
            out = true;
        }
    );

    return out;
}

// Recupera le note di piede dei documenti che si stanno prelevando nella rilevazione Id_xMORL
function Ajax_xmofn_xMORLPrelievo_NotePiede() {

    // Svuotare il detail 
    $("#Detail_NotePiede li.li-note").remove();

    ajaxCallSync(
        "/xmofn_xMORLPrelievo_NotePiede",
        {
            Id_xMORL: oPrg.Id_xMORL_Edit
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            Detail_NotePiede_Load(dt);
        }
    );

    $("#Detail_NotePiede").show();
}

// -------------------------------------------------
// #1.11 AJAX SEARCH
// -------------------------------------------------

// Elenco Articoli
function Search_Ajax_xmofn_AR() {

    var out = false;

    //Svuota la lista degli articoli
    $("#SearchAR .li-search").remove();
    $("#SearchAR .mo-msg").text("Ricerca...").show();

    ajaxCallSync(
        "/xmofn_AR",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMORL: fU.ToInt32(oPrg.Id_xMORL_Edit),        // Utile per la selezione degli articoli in fase di prelievo
            Filtro: fU.ToString(oPrg.ActiveSearchValue),
            Fittizio: fU.IsChecked($("#" + oPrg.ActiveSearchId + " .ck-fittizi"))  // Se selezionato visualizzo anche gli ar fittizi
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            Search_Articolo_Load(dt);
            out = true;
        }
    );

    return out;
}

// Elenco Spedizioni
function Search_Ajax_xmofn_Spedizione() {
    var out = false;

    $("#SearchxMOCodSpe .li-search").remove();

    ajaxCallSync(
        "/xmofn_xMOCodSpe_Search",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Filtro: fU.ToString(oPrg.ActiveSearchValue)
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            Search_Spedizione_Load(dt);
            out = true;
        }
    );

    return out;
}

// Elenco liste di carico
function Search_Ajax_xmofn_xListaCarico() {
    var out = false;

    $("#SearchxListaCarico .li-search").remove();

    ajaxCallSync(
        "/xmofn_xListaCarico_Search",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Filtro: fU.ToString(oPrg.ActiveSearchValue)
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            Search_xListaCarico_Load(dt);
            out = true;
        }
    );

    return out;
}

// Elenco Lotti
function Search_Ajax_xmofn_ARLotto() {

    var out = false;

    $("#SearchARLotto .li-search").remove();

    ajaxCallSync(
        "/xmofn_ARLotto",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMORL: fU.ToInt32(oPrg.Id_xMORL_Edit),
            Cd_AR: fU.ToString($("#" + oPrg.ActivePageId + " input[name='Cd_AR']").val()),
            Cd_MG: fU.ToString(fMG.Mg4Find($("#" + oPrg.ActivePageId + " input[name='Cd_MG_P']").val(), $("#" + oPrg.ActivePageId + " input[name='Cd_MG_A']").val(), $("#" + oPrg.ActivePageId + " input[name='Cd_MG']").val())),
            Cd_MGUbicazione: fU.ToString(fMG.Mg4Find($("#" + oPrg.ActivePageId + " input[name='Cd_MGUbicazione_P']").val(), $("#" + oPrg.ActivePageId + " input[name='Cd_MGUbicazione_A']").val())),
            Filtro: fU.ToString(oPrg.ActiveSearchValue),
            GiacPositiva: fU.IsChecked($("#" + oPrg.ActiveSearchId + " .ck-giacpositiva"))
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            Search_ARLotto_Load(dt);
            out = true;
        }
    );

    return out;
}

// Elenco Clienti/Fornitori
function Search_Ajax_xmofn_CF() {

    var out = false;

    $("#SearchCF .li-search").remove();

    //oPrg.Programma
    if (oPrg.Key == "AA" || !oPrg.drDO) {
        Params = {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            TipoCF: '',
            Cd_DO: '',
            TipoPrelievo: 0,
            Filtro: fU.ToString(oPrg.ActiveSearchValue)
        };
    } else {
        Params = {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            TipoCF: fU.ToString(oPrg.drDO.CliFor),      // Potrei non avere nessun programma // fU.ToString(oPrg.drDO.CliFor),
            Cd_DO: oPrg.drDO.Cd_DO,
            TipoPrelievo: oPrg.drDO.xMOTipoPrelievo,    // 0 = Nessun prelievo; 1 = Prelievo non obbligatorio; 2 = Prelievo obbligatorio;
            Filtro: fU.ToString(oPrg.ActiveSearchValue)
        };
    }

    ajaxCallSync(
        "/xmofn_CF",
        Params,
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            Search_CF_Load(dt);
            out = true;
        }
    );

    return out;
}

// Ricerca CF in base al filtro passato (usato per la ricerca quando viene utilizzato lo shortcut nel campo CF)
function Ajax_xmofn_CF(filtro) {

    var dt;

    ajaxCallSync(
        "/xmofn_CF",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            TipoCF: '',     // Potrei non avere nessun programma
            Cd_DO: '',
            TipoPrelievo: 0,    // 0 = Nessun prelievo; 1 = Prelievo non obbligatorio; 2 = Prelievo obbligatorio;
            Filtro: filtro
        },
        function (mydata) {
            dt = $.parseJSON(mydata.d);
        }
    );

    return dt[0];
}


// Elenco Destinazioni dei CF
function Search_Ajax_xmofn_CFDest() {
    var out = false;

    $("#SearchCFDest .li-search").remove();

    ajaxCallSync(
        "/xmofn_CFDest",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            TipoCF: fU.ToString(oPrg.drDO ? oPrg.drDO.CliFor : ''),
            Cd_CF: fU.ToString($("#" + oPrg.ActivePageId + " input[name='Cd_CF']").val()),
            Cd_DO: oPrg.drDO ? oPrg.drDO.Cd_DO : '',
            TipoPrelievo: 0,      //oPrg.drDO.xMOPrelievo,
            Filtro: fU.ToString(oPrg.ActiveSearchValue)
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            Search_CFDest_Load(dt);
            out = true;
        }
    );

    return out;
}

// Elenco Magazzini
function Search_Ajax_xmofn_MG() {

    var out = false;

    $("#SearchMG .li-search").remove();

    ajaxCallSync(
        "/xmofn_MG",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Filtro: fU.ToString(oPrg.ActiveSearchValue)
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            Search_MG_Load(dt);
            out = true;
        }
    );

    return out;
}

// Elenco Ubicazioni
function Search_Ajax_xmofn_MGUbicazione() {

    var out = false;

    $("#SearchMGUbicazione .li-search").remove();

    //Seleziona il magazzino corrente
    var mgPA = fMG.Mg4PA(oPrg.ActiveSearchOutField);

    ajaxCallSync(
        "/xmofn_MGUbicazione",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_MG: fU.ToString($("#" + oPrg.ActivePageId + " input[name='Cd_MG" + mgPA + "']").val()),
            Cd_AR: fU.ToString($("#" + oPrg.ActivePageId + " input[name='Cd_AR']").val()),
            Filtro: fU.ToString(oPrg.ActiveSearchValue.trim())
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d)
            Search_MGUbicazione_Load(dt);
            MGUbicazione_Giac_Filter();
            out = true;
        }
    );

    return out;
}

// Elenco Sottocommesse
function Search_Ajax_xmofn_xMODOSottoCommessa() {

    var out = false;

    $("#SearchDOSottoCommessa .li-search").remove();

    ajaxCallSync(
        "/xmofn_xMODOSottoCommessa",
        {
            Cd_CF: fU.ToString(ActivePage().find("input[name='Cd_CF']").val()),
            Filtro: fU.ToString(oPrg.ActiveSearchValue)
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d)
            Search_DOSottoCommessa_Load(dt);
            out = true;
        }
    );

    return out;
}

// Elenco caricatori
function Search_Ajax_xmofn_DOCaricatore() {

    var out = false;

    $("#SearchDOCaricatore .li-search").remove();

    ajaxCallSync(
        "/xmofn_DOCaricatore",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Filtro: fU.ToString(oPrg.ActiveSearchValue)
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d)
            Search_DOCaricatore_Load(dt);
            out = true;
        }
    );

    return out;
}

// Elenco UM dell'articolo passato alla funzione
function Search_Ajax_xmofn_ARARMisura() {
    var out = false;

    $("#SearchARARMisura .li-search").remove();

    ajaxCallSync(
        "/xmofn_ARARMisura",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_AR: fU.ToString($("#" + oPrg.ActivePageId + " input[name='Cd_AR']").val()),
            TipoARMisura: "",
            xMOUmDef: "",
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d)
            Search_ARARMisura_Load(dt);
            out = true;
        }
    );

    return out;
}

// -------------------------------------------------
// #1.12 AJAX DETAILS
// -------------------------------------------------

// Dettaglio elenco Ubicazioni Giacenze dell'AR
function Detail_Ajax_xmofn_ARMGUbicazione_Giac(inputubi, mg) {

    // Preparazione UI del dettaglio 
    $("#DetailARGiacenza .tr-giac").remove();
    var title = $("#" + oPrg.ActivePageId + " .detail-giacar").attr("title");
    var ar = $("#" + oPrg.ActivePageId + " input[name='Cd_AR']").val();
    var um = $("#" + oPrg.ActivePageId + " select[name='Cd_ARMisura'] option[UmFatt='1']").text();
    $("#DetailARGiacenza h6").text(title + " " + ar + " [" + um + "]");
    $("#DetailARGiacenza").attr("data-inputubi", inputubi);
    $("#DetailARGiacenza").attr("data-mg", mg);

    ajaxCallSync(
        "/xmofn_ARMGUbicazione_Giac",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_AR: $("#" + oPrg.ActivePageId + " input[name='Cd_AR']").val(),
            Cd_MG: fU.ToString(fMG.Mg4Find($("#" + oPrg.ActivePageId + " input[name='Cd_MG_P']").val(), $("#" + oPrg.ActivePageId + " input[name='Cd_MG_A']").val())),
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            if (dt != '') {
                Detail_ARGiacenza_Load(dt);
                Articolo_Giac_Filter();
            }
            else { PopupMsg_Show("Messaggio", "1", "L'articolo non è presente in nessun magazzino"); }
        }
    );

}

// Dettaglio elenco AR giacenze dell'ubicazione
function Detail_Ajax_xmofn_MGUbicazioneAR_Giac(Cd_MGUbi) {

    // Preparazione UI del dettaglio 
    $("#DetailUBIGiacenza .tr-giac").remove();
    $("#DetailUBIGiacenza h4").text($("#" + oPrg.ActivePageId + " .detail-giacubi").attr("title"));

    ajaxCallSync(
        "/xmofn_MGUbicazioneAR_Giac",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_MGUbicazione: Cd_MGUbi,
            Cd_MG: fU.ToString(fMG.Mg4Find($("#" + oPrg.ActivePageId + " input[name='Cd_MG_P']").val(), $("#" + oPrg.ActivePageId + " input[name='Cd_MG_A']").val())),
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            if (dt != '') {
                Detail_UBIGiacenza_Load(dt);
            }
            else { PopupMsg_Show("Messaggio", "1", "L'ubicazione " + Cd_MGUbi + " è vuota"); }
        }
    );

}

// Dettaglio del CF 
function Detail_Ajax_xmovs_CF(Cd_CF) {

    // Svuota il detail
    $("#DetailCF label h4").text("");

    ajaxCallSync(
        "/xmovs_CF",
        {
            Cd_CF: Cd_CF
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            // Carica il detail con i dati
            DetailCF_Template(dt[0]);
            $("#DetailCF").show();
        }
    );

}

// Dettaglio della CFDest 
function Detail_Ajax_xmovs_CFDest(Cd_CFDest) {

    // Svuota il detail
    $("#DetailCFDest label h4").text("");

    ajaxCallSync(
        "/xmovs_CFDest",
        {
            Cd_CFDest: Cd_CFDest
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            // Carica il detail con i dati
            DetailCFDest_Template(dt[0]);
            $("#DetailCFDest").show();
        }
    );

}

// Dettaglio del DO: recupera la testa
function Detail_Ajax_xmovs_DOTes(Id_DOTes) {
    // Svuota il detail
    $("#DetailDO label h4").text("");
    $("#DetailDO .tr-dorig").remove();

    ajaxCallSync(
        "/xmovs_DOTes",
        {
            Id_DOTes: Id_DOTes
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            // Carica il detail con i dati
            DetailDOTes_Template(dt[0]);
            // Carica le righe del DO
            Detail_Ajax_xmovs_DORig(Id_DOTes);
        }
    );

}

// Dettaglio del DO: recupera le righe
function Detail_Ajax_xmovs_DORig(Id_DOTes) {

    ajaxCallSync(
        "/xmovs_DORig",
        {
            Id_DOTes: Id_DOTes
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            // Carica il detail con i dati
            DetailDORig_Load(dt);
        }
    );

}

// Dettaglio delle Letture effettuate in RL
function Detail_Ajax_xmovs_xMORLRig() {

    // Svuoto il dettaglio
    $("#Detail_Letture .li-rig").remove();

    ajaxCallSync(
        "/xmovs_xMORLRig",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMORL: oPrg.Id_xMORL_Edit
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            // Carica il detail delle letture effettuate con i dati
            DetailRLRig_Load(dt);
        }
    );

}

// Dettaglio delle letture effettuate in TR di PARTENZA
function Detail_Ajax_xmovs_xMOTRRig_P() {

    // Svuoto il dettaglio
    $("#Detail_Letture .li-rig").remove();

    ajaxCallSync(
        "/xmovs_xMOTRRig_P",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMOTR: oPrg.Id_xMOTR_Edit
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            // Carica il detail delle letture effettuate con i dati
            DetailTRRig_P_Load(dt);
        }
    );

}

// Dettaglio delle letture effettuate in TR di ARRIVO
function Detail_Ajax_xmovs_xMOTRRig_A() {

    // Svuoto il dettaglio
    $("#Detail_Letture .li-rig").remove();

    ajaxCallSync(
        "/xmovs_xMOTRRig_A",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMOTR: oPrg.Id_xMOTR_Edit
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            // Carica il detail delle letture effettuate con i dati
            DetailTRRig_A_Load(dt);
        }
    );

}


// Elenco degli ar in ciascun pacco suddivisi per singola lettura
function Detail_Ajax_xmofn_xMORLRigPackingList_AR() {
    // Svuoto il dettaglio
    $("#Detail_PackingList .pk-dati").remove();
    // Svuoto i totali dei pesi
    $("#Detail_PackingList .tr-pktotali td").text("");

    ajaxCallSync(
        "/xmofn_xMORLRigPackingList_AR",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMORL: oPrg.Id_xMORL_Edit
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            // Carica il detail della packing, il secondo parametro indica la modalità di visualizzazione
            DetailPackingList_Load(dt, 0);
        }
    );

}

// Elenco degli ar raggruppati in ciascun pacco 
function Detail_Ajax_xmofn_xMORLRigPackingList_AR_GRP() {
    // Svuoto il dettaglio
    $("#Detail_PackingList .pk-dati").remove();
    // Svuoto i totali dei pesi
    $("#Detail_PackingList .tr-pktotali td").text("");

    ajaxCallSync(
        "/xmofn_xMORLRigPackingList_AR_GRP",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMORL: oPrg.Id_xMORL_Edit
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            // Carica il detail della packing, il secondo parametro indica la modalità di visualizzazione
            DetailPackingList_Load(dt, 1);
        }
    );

}

function Detail_Ajax_xmofn_xMOTRDoc4Stoccaggio() {
    // Svuoto il dettaglio
    $("#Detail_SMDocs .li-do").remove();

    ajaxCallSync(
        "/xmofn_xMOTRDoc4Stoccaggio",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_MG_P: $("#pgSM [name='Cd_MG_P']").val(),
            Cd_MGUbicazione_P: $("#pgSM [name='Cd_MGUbicazione_P']").val(),
        },
        function (mydata) {
            var dt = $.parseJSON(mydata.d);
            // Carica il detail con l'elenco dei documenti
            DetailSMDocs_Load(dt);
        }
    );

    $("#Detail_SMDocs").show();
}

function Ajax_xmofn_xMOTRRig_TA() {

    // Svuoto la lista della pagina
    $("#pgSMRig .tr-rig").remove();

    ajaxCallSync(
        "/xmofn_xMOTRRig_TA",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMOTR: oPrg.Id_xMOTR_Edit,
        },
        function (mydata) {
            oPrg.SM.dtxMOTRRig_T = $.parseJSON(mydata.d);
            // Carica la lista di tutte le righe PTA della rievazione di stoccaggio aperta
            SMRig_TA_Load();
        }
    );

}

function Ajax_xmofn_xMOPRBLAttivita() {

    var out = false;

    oPrg.PRAV.dtBLA = {};

    ajaxCallSync(
        "/xmofn_xMOPRBLAttivita",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
        },
        function (mydata) {
            oPrg.PRAV.dtBLA = $.parseJSON(mydata.d);
            PRTRAttivita_Load();
            out = true;
        }
    );

    return out;
}


// Mostra la lista dei materiali nella quantità richiesta dall'operatore
function PRBLMaterialiUsr() {
    var qtausrum1;
    var qtausr = $(ActivePage()).find('[data-key="QtaUsr"] input[data-bind="QtaUsrP"]').val();
    var fattore = $(ActivePage()).find('[data-key="QtaUsr"] input[type="hidden"][data-bind="FattoreToUM1"]').val();
    qtausrum1 = qtausr * fattore;
    Ajax_xmofn_xMOPRBLMateriali(qtausrum1);
}

function Ajax_xmofn_xMOPRBLMateriali(qtausrum1) {
    if (oPrg.PRAV.keyBLA >= 0) {

        ajaxCallSync(
            "/xmofn_xMOPRBLMateriali",
            {
                Terminale: oApp.Terminale,
                Cd_Operatore: oApp.Cd_Operatore,
                Id_PRBLAttivita: oPrg.PRAV.dtBLA[oPrg.PRAV.keyBLA].Id_PrBLAttivita,
                QtaUsrUM1: (qtausrum1 ? qtausrum1 : oPrg.PRAV.dtBLA[oPrg.PRAV.keyBLA].Quantita * oPrg.PRAV.dtBLA[oPrg.PRAV.keyBLA].FattoreToUM1),
            },
            function (mydata) {
                oPrg.PRAV.dtBLM = $.parseJSON(mydata.d);
                PRTRMateriali_Load(qtausrum1 ? true : false);
            }
        );

    }
}

function Ajax_xmosp_xMOPRTRRig_Delete() {
    // Dati statici
    var attivita = oPrg.PRAV.dtBLA[oPrg.PRAV.keyBLA];
    var materiale = oPrg.PRAV.dtBLM[oPrg.PRAV.keyBLM];

    ajaxCallSync(
        "/xmosp_xMOPRTRRig_Delete",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_PrBLAttivita: attivita.Id_PrBLAttivita,
            Id_PrBLMateriale: materiale.Id_PrBLMateriale,
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result > 0) {
                //Ricarica i materiali con le quantità dell'operatore
                PRBLMaterialiUsr();
            } else {
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Msg);
            }
        }
    );
}

function Ajax_xmosp_xMOPRTRRig_Save() {

    //Controlla la linea di produzione
    if (ActivePage().find("input[data-bind='Cd_xMOLinea']").val() != ActivePage().find("label[data-bind='Cd_xMOLinea']").text()) {
        PopupMsg_Show("ERRORE", 0, "La linea di produzione non corrisponde a quella della bolla!");
        return false;
    }

    // Dati statici
    var attivita = oPrg.PRAV.dtBLA[oPrg.PRAV.keyBLA];
    var materiale = oPrg.PRAV.dtBLM[oPrg.PRAV.keyBLM];

    // Recupero i valori della pagina
    var trasferimento = GetBindedValues('[data-key="Trasferimento"]');

    ajaxCallSync(
        "/xmosp_xMOPRTRRig_Save",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_PrBLAttivita: attivita.Id_PrBLAttivita,
            Id_PrBLMateriale: materiale.Id_PrBLMateriale,
            Cd_ARLotto: trasferimento.Cd_ARLotto,
            Quantita: trasferimento.Quantita,
            Cd_ARMisura: trasferimento.Cd_ARMisura,
            FattoreToUM1: fU.ToDecimal(trasferimento.FattoreToUM1),
            Cd_MG_P: trasferimento.Cd_MG_P,
            Cd_MGUbicazione_P: trasferimento.Cd_MGUbicazione_P,
            Note: trasferimento.Note,
            Mancante: trasferimento.Mancante
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result > 0) {
                //Ricarica la pagina con i dati della quantità utente
                PRBLMaterialiUsr();
            } else {
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Msg);
            }
        }
    );

}

//trasferisce i materiali in definitivo
function Ajax_xmosp_xMOPRTR_Close() {

    var PercTrasferita = ActivePage().find("input[data-bind='PercTrasferita']").val();

    if (confirm("Trasferire i materiali al [" + PercTrasferita + "%]?") == false)
        return false;

    var attivita = oPrg.PRAV.dtBLA[oPrg.PRAV.keyBLA];

    ajaxCallSync(
        "/xmosp_xMOPRTR_Close",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_PrBLAttivita: attivita.Id_PrBLAttivita,
            PercTrasferita: PercTrasferita,
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result > 0) {
                Nav.Back();
            } else {
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Msg);
            }
        }
    );
}

function Ajax_xmosp_xMOPRTRMateriale_Back() {
    // Dati di appoggio
    var materiale = oPrg.PRMP.ActiveRecord();

    // Recupero i valori della pagina
    var trasferimento = GetBindedValues('[data-key="Input"]');

    ajaxCallSync(
        "/xmosp_xMOPRTRMateriale_Back",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_MG_P: materiale.Cd_MG_P,
            Cd_MGUbicazione_P: materiale.Cd_MGUbicazione_P,
            Cd_AR: materiale.Cd_AR,
            Cd_ARLotto: materiale.Cd_ARLotto,
            Quantita_P: materiale.Quantita,
            Quantita_A: trasferimento.Quantita_A,
            Cd_ARMisura: trasferimento.Cd_ARMisura,
            FattoreToUM1: fU.ToDecimal(trasferimento.FattoreToUM1),
            Note: trasferimento.Note,
            Cd_MG_A: materiale.Cd_MG_A,
            Cd_MGUbicazione_A: trasferimento.Cd_MGUbicazione_A,
            xMOCompleta: trasferimento.xMOCompleta,
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result > 0) {
                Ajax_xmofn_xMOPRMPLinea();
                PRMPMateriale_Show_Lista();
            } else {
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Msg);
            }
        }
    );

}

function Ajax_xmosp_xMOPRTRMateriale_Drop() {
    // Dati di appoggio
    var materiale = oPrg.PRMP.ActiveRecord();

    // Recupero i valori della pagina
    var trasferimento = GetBindedValues('[data-key="Input"]');

    ajaxCallSync(
        "/xmosp_xMOPRTRMateriale_Drop",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_MG_P: materiale.Cd_MG_P,
            Cd_MGUbicazione_P: materiale.Cd_MGUbicazione_P,
            Cd_AR: materiale.Cd_AR,
            Cd_ARLotto: materiale.Cd_ARLotto,
            Quantita_P: materiale.Quantita,
            Quantita_A: trasferimento.Quantita_A,
            Cd_ARMisura: trasferimento.Cd_ARMisura,
            FattoreToUM1: fU.ToDecimal(trasferimento.FattoreToUM1),
            Note: trasferimento.Note,
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result > 0) {
                Ajax_xmofn_xMOPRMPLinea();
                PRMPMateriale_Show_Lista();
            } else {
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Msg);
            }
        }
    );

}

function Ajax_xmosp_xMOPRTRMateriale_ToBL() {
    // Dati di appoggio
    var materiale = oPrg.PRMP.ActiveRecord();
    var bolla = oPrg.PRMP.ActiveBolla();

    // Recupero i valori della pagina
    var trasferimento = GetBindedValues('[data-key="Input"]');

    ajaxCallSync(
        "/xmosp_xMOPRTRMateriale_ToBL",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_PrRisorsa: bolla.Cd_PrRisorsa,
            Cd_MG_P: materiale.Cd_MG_P,
            Cd_MGUbicazione_P: materiale.Cd_MGUbicazione_P,
            Quantita_P: materiale.Quantita,
            Cd_ARLotto: materiale.Cd_ARLotto,
            Cd_ARMisura: trasferimento.Cd_ARMisura,
            FattoreToUM1: fU.ToDecimal(trasferimento.FattoreToUM1),
            Id_PrBLAttivita_A: bolla.Id_PrBLAttivita,
            Id_PrBLMateriale_A: bolla.Id_PrBLMateriale,
            Quantita_A: trasferimento.Quantita_A,
            Note: trasferimento.Note,
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result > 0) {
                Ajax_xmofn_xMOPRMPLinea();
                PRMPMateriale_Show_Lista();
            } else {
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Msg);
            }
        }
    );

}


function Ajax_xmofn_xMOLinea(callback) {

    ajaxCallSync(
        "/xmofn_xMOLinea",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
        },
        function (mydata) {
            oPrg.PRMP.dtLinea = $.parseJSON(mydata.d);

            if (callback != null)
                callback();
        }
    );

}

function Ajax_xmofn_xMOPRMPLinea() {

    ajaxCallSync(
        "/xmofn_xMOPRMPLinea",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_xMOLinea: $(ActivePage()).find('[data-bind="Cd_xMOLinea"]').val()
        },
        function (mydata) {
            oPrg.PRMP.dt = JSON.parse(mydata.d);
            oPrg.PRMP.keyLinea = oPrg.PRMP.dtLinea.indexOf(oPrg.PRMP.dtLinea.find(function (item) { return item.Cd_xMOLinea == Params.Cd_xMOLinea }));
            PRMPMateriale_Load_Table();
        }
    );
}

function Ajax_xmofn_xMOPRBLMateriali_4BL() {

    ajaxCallSync(
        "/xmofn_xMOPRBLMateriali_4BL",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_AR: oPrg.PRMP.ActiveRecord().Cd_AR
        },
        function (mydata) {
            oPrg.PRMP.dt4BL = JSON.parse(mydata.d);
            PRMPMateriali_Bolle_Load();
        }
    );

}

// -------------------------------------------------
// #1.30 REGION: FUNZIONI UI
// -------------------------------------------------

function pgAvviaConsumo_UI() {
    //Carico le line di produzione
    Linea_Load();

    //Propongo nel campo data la data odierna
    $("#pgAvviaConsumo [name='DataOra']").val(fU.ToDate($.now()));
}

function pgRL_UI() {

    //Pulizia dei campi della pagina corrente
    fPage.Clear();

    // Rendo visibile il campo della destinazione (potrebbe essere stato nascosto in modalità edit)
    $("#pgRL .div-dest").show();

    //Carico la label dell'input cliente/fornitore
    if (oPrg.drDO.CliFor == "F") { $("#pgRL .title").text("FORNITORE"); }
    else if (oPrg.drDO.CliFor == "C") { $("#pgRL .title").text("CLIENTE"); }
    else $("#pgRL .title").text("CLIENTE/FORNITORE");

    //Carico i dati di testa della pagina
    $("#pgRL .lb-doc-id").text(fU.IsEmpty(oPrg.Id_xMORL_Edit) ? "" : oPrg.Id_xMORL_Edit);
    $("#pgRL .lb-doc-name").text(oPrg.drDO.Cd_DO);
    $("#pgRL .lb-doc-desc").text(oPrg.drDO.DO_Descrizione);


    //Visualizza l'icona di ricerca del campo
    $("#pgRL [searchkey='Cd_CF']").show();
    //Carico il CF e la descrizione (se impostato come daufault)
    $("#pgRL [name='Cd_CF']").val(oPrg.drDO.xMOCd_CF);
    $("#pgRL [name='CF_Descrizione']").text(oPrg.drDO.xMOCF_Descrizione);

    // Nascono icona del dettaglio CF
    $("#pgRL .detail").hide();

    // Carico CFDest e la descrizione (se impostata come default)
    $("#pgRL [name='Cd_CFDest']").val(oPrg.drDO.xMOCd_CFDest);
    $("#pgRL [name='CFDest_Descrizione']").text(oPrg.drDO.xMOCFDest_Descrizione);

    //Propongo nel campo data quella odierna
    $("#pgRL [name='DataDoc']").val(fU.DateFormatToBrowserLang(fU.ToDate($.now())));

    //Imposto i Check di Gestione
    fU.CheckIf($("#pgRL .ck-prelievo"), (oPrg.drDO.xMOPrelievo > 0 ? true : false));
    fU.CheckIf($("#pgRL .ck-fuorilista"), oPrg.drDO.xMOFuoriLista);
    fU.CheckIf($("#pgRL .ck-ubicazione"), oPrg.drDO.xMOUbicazione);
    fU.CheckIf($("#pgRL .ck-lotto"), oPrg.drDO.xMOLotto);

    //Mostro il check fuorilista solo se il prelievo è attivo 
    fU.ShowIf($("#pgRL .fuorilista"), fU.IsPrelievoUI(oPrg.drDO.xMOPrelievo));

    //Cambia l'etichetta se il prelievo è obbligatorio
    switch (oPrg.drDO.xMOPrelievo) {
        case 0:
            $("#pgRL .prelievo .etichetta").text("No prelievo");
            break;
        case 1:
            $("#pgRL .prelievo .etichetta").text(oPrg.drDO.xMOPrelievoObb ? "Prelievo Obbligatorio" : "Prelievo");
            break;
        case 2:
            $("#pgRL .prelievo .etichetta").text(oPrg.drDO.xMOPrelievoObb ? "Copia righe Obbligatoria" : "Copia righe");
            break;
        case 3:
            $("#pgRL .prelievo .etichetta").text("Preleva automaticamente dal più vecchio.");
            break;
    }

    //Mostra le linee di produzione se gestite dal doc
    fU.ShowIf($("#pgRL .div-linea"), oPrg.drDO.xMOLinea);
    //Carico le linee di produzione
    Linea_Load();

    // Magazzino di Partenza
    if (oPrg.drDO.MagPFlag) {
        $("#pgRL .div-mgp").show();
        //Carica il magazzino se impostato nel documento dal DB
        $("#pgRL input[name='Cd_MG_P']").val(oPrg.drDO.Cd_MG_P);
        //Se il magazzino è fisso lo blocco e nascondo l'icona di ricerca
        fU.DisableIf($("#pgRL input[name='Cd_MG_P']"), oPrg.drDO.UIMagPFix);
        fU.ShowIf($("#pgRL i[searchkey='Cd_MG_P']"), !oPrg.drDO.UIMagPFix);
    }
    else { $("#pgRL .div-mgp").hide(); }

    // Magazzino di Arrivo
    if (oPrg.drDO.MagAFlag) {
        $("#pgRL .div-mga").show();
        //Carica il magazzino se impostato nel documento dal DB
        $("#pgRL input[name='Cd_MG_A']").val(oPrg.drDO.Cd_MG_A);
        //Se il magazzino è fisso lo blocco e nascondo l'icona di ricerca
        fU.DisableIf($("#pgRL input[name='Cd_MG_A']"), oPrg.drDO.UIMagAFix);
        fU.ShowIf($("#pgRL i[searchkey='Cd_MG_A']"), !oPrg.drDO.UIMagAFix);
    }
    else { $("#pgRL .div-mga").hide(); }

    // Se nessuno dei due mg sono gestiti nascondo anche l'intestazione
    fU.ShowIf($("#pgRL .div-magazzini"), !oPrg.drDO.MagAFlag && !oPrg.drDO.MagPFlag == true ? false : true);

    // Visualizzo il campo Commessa se gestito
    fU.ShowIf($("#pgRL .div-com"), oPrg.drDO.xMODOSottoCommessa);

    // Gestione EDIT della pagina
    pgRL_UI_Edit();

}

function pgRL_UI_Edit() {

    var InEdit = (fU.ToInt32(oPrg.Id_xMORL_Edit) > 0 ? true : false);

    //Visualizza la descrizione del DO che sto creando 
    if (InEdit) {

        // Nascondo l'icona di ricerca del campo CF
        $("#pgRL [searchkey='Cd_CF']").hide();
        // Mostro l'icona del dettaglio CF
        $("#pgRL .detail").show();

        // Show del campo SO se ci sono destinazioni per il cliente selezionato
        fU.ShowIf($("#pgRL .div-dest"), !fU.IsEmpty(oPrg.drRL.Cd_CFDest));

        $("#pgRL .lb-doc-id").text(oPrg.Id_xMORL_Edit);
        $("#pgRL [name='Cd_CF']").val(oPrg.drRL.Cd_CF);
        $("#pgRL [name='CF_Descrizione']").text(oPrg.drRL.CF_Descrizione);
        $("#pgRL [name='Cd_CFDest']").val(oPrg.drRL.Cd_CFDest);
        $("#pgRL [name='CFDest_Descrizione']").text(oPrg.drRL.CFDest_Descrizione);
        $("#pgRL [name='Cd_DOSottoCommessa']").val(oPrg.drRL.Cd_DOSottoCommessa);
        //$("#pgRL [name='DataDoc']").val(fU.DateFormatToBrowserLang(fU.ToDate(oPrg.drRL.DataDoc)));
        $("#pgRL [name='DataDoc']").val(fU.ToStandardDate(oPrg.drRL.DataDoc));
        $("#pgRL [name='NumeroDocRif']").val(oPrg.drRL.NumeroDocRif);
        //$("#pgRL [name='DataDocRif']").val(fU.DateFormatToBrowserLang(fU.ToDate(oPrg.drRL.DataDocRif)));
        $("#pgRL [name='DataDocRif']").val(fU.ToStandardDate(oPrg.drRL.DataDocRif));
        $("#pgRL [name='Cd_MG_P']").val(oPrg.drRL.Cd_MG_P);
        $("#pgRL [name='Cd_MG_A']").val(oPrg.drRL.Cd_MG_A);
        $("#pgRL [name='Cd_xMOLinea']").val(oPrg.drRL.Cd_xMOLinea);
    }

    //Disabilita i campi in edit
    $("#pgRL [name='Cd_CF']").prop('disabled', InEdit);
    $("#pgRL [name='Cd_CF'] .mi").prop('disabled', InEdit);
}

function pgRLRig_UI() {
    // Se non esiste prelievo per la rilevazione nascondo la colonna evadibile
    fU.ShowIf($("#pgRLRig .lg-table .QtaEvadibile"), oPrg.drRL.CountPrelievi <= 0 ? false : true)

    // Visualizzo il div della packing se abilitata per il documento corrente
    fU.ShowIf($("#pgRLRig .div-packinglist"), (oPrg.drDO.PkLstEnabled));

    // Visualizzo il campo Fattore se gestito
    fU.ShowIf($("#pgRLRig .div-umfatt"), oPrg.drDO.xMOUMFatt > 0 ? true : false);
    switch (oPrg.drDO.xMOUMFatt) {
        case 1:
            $("#pgRLRig .div-umfatt").find(".mo-lbl").text("Fattore");
            break;
        case 2:
            $("#pgRLRig .div-umfatt").find(".mo-lbl").text("x Qta UM principale");
            break;
        default:
            break;
    }

    // Visualizzo la commessa se gestita 
    fU.ShowIf($("#pgRLRig .div-com"), oPrg.drDO.xMODOSottoCommessa);

    // Se la commessa è stata inserita sulla testa del DO blocco il campo e ripropongo quella selezionata
    if (!fU.IsEmpty($("#pgRL input[name='Cd_DOSottoCommessa']").val())) {
        $("#pgRLRig input[name='Cd_DOSottoCommessa']").val($("#pgRL input[name='Cd_DOSottoCommessa']").val()).prop("disabled", 'disabled');
        $("#pgRLRig i[searchkey='Cd_DOSottoCommessa']").hide();
    }
    else {
        $("#pgRLRig input[name='Cd_DOSottoCommessa']").val("").prop("disabled", "");
        $("#pgRLRig i[searchkey='Cd_DOSottoCommessa']").show();
    }

    // Mostra il campo barcode se ci sono barcode codificati nel DB
    fU.ShowIf($("#pgRLRig .div-barcode"), !fU.IsEmpty(oPrg.drDO.xMOBarcode));

    // Seleziona unità di misura definita
    $("#pgRLRig select[name='Cd_ARMisura']").val((fU.ToString(oPrg.drDO.xMOUmDef)).toLowerCase());

    // Imposta il check dell'autoconferma in base alla parametrizzazione del documento
    fU.CheckIf($("#pgRLRig .ck-autoconfirm"), oPrg.drDO.xMOAutoConfirm);

    // Svuota la label contenente l'alias/alternativo/AR
    $("#pgRLRig .ar-aa").text("");

    // Mostra il campo lotto se gestito
    fU.ShowIf($("#pgRLRig .div-lotto"), fU.ToBool(oPrg.drDO.xMOLotto));
    //Il lotto gestisce la data scadenza se può essere auto generato
    fU.ShowIf($("#pgRLRig .lotto-scad"), fU.ToBool(oPrg.drDO.xMOLotto) && (oPrg.drDO.ARLottoAuto == 0 ? false : true));

    // Mostra la scadenza del lotto se gestito
    fU.ShowIf($("#pgRLRig .div-lotto"), fU.ToBool(oPrg.drDO.xMOLotto));

    // Mostra il campo matricole se gestite
    fU.ShowIf($("#pgRLRig .div-matricola"), fU.ToBool(oPrg.drDO.MtrEnabled));

    // Mostra il MG PARTENZA se gestito
    if (fU.ToBool(oPrg.drDO.MagPFlag)) {
        // Disabilita l'input del mgp se fisso
        fU.DisableIf($("#pgRLRig input[name='Cd_MG_P']"), fU.ToBool(oPrg.drDO.UIMagPFix));

        // Carico mgp dal default della testa
        $("#pgRLRig input[name='Cd_MG_P']").val($("#pgRL input[name='Cd_MG_P']").val());

        // Se il magazzino di p è ancora vuoto imposto quello di default del documento da creare 
        if (fU.IsEmpty($("#pgRLRig input[name='Cd_MG_P']").val())) {
            $("#pgRLRig input[name='Cd_MG_P']").val(oPrg.drDO.Cd_MG_P);
        }

        // Scrive nella lbl del header il contenuto dell'input Cd_MG_P
        $("#pgRLRig .cd_mg_p").text($("#pgRLRig input[name='Cd_MG_P']").val());
        // Mostro l'icona di ricerca del campo se mgp non è fisso
        fU.ShowIf($("#pgRLRig i[searchkey='Cd_MG_P']"), !fU.ToBool(oPrg.drDO.UIMagPFix));
        // Se il magazzino è stato indicato racchiudo l'accordion
        DivToggle_Execute($("#pgRLRig .div-mgp"), fU.IsEmpty($("#pgRLRig input[name='Cd_MG_P']").val()));

        $("#pgRLRig .div-mgp").show();
    }
    else { $("#pgRLRig .div-mgp").hide(); }

    // Mostra il MG ARRIVO se gestito
    if (fU.ToBool(oPrg.drDO.MagAFlag)) {

        // Disabilita l'input del mga se fisso
        fU.DisableIf($("#pgRLRig input[name='Cd_MG_A']"), fU.ToBool(oPrg.drDO.UIMagAFix));
        // Carico mga dal default della testa
        $("#pgRLRig input[name='Cd_MG_A']").val($("#pgRL input[name='Cd_MG_A']").val());

        // Se il magazzino di a è ancora vuoto imposto quello di default del documento da creare 
        if (fU.IsEmpty($("#pgRLRig input[name='Cd_MG_A']").val())) {
            $("#pgRLRig input[name='Cd_MG_A']").val(oPrg.drDO.Cd_MG_A);
        }

        // Scrive nella lbl del header il contenuto dell'input
        $("#pgRLRig .cd_mg_a").text($("#pgRLRig input[name='Cd_MG_A']").val());
        // Mostro l'icona di ricerca del campo se mga non è fisso 
        fU.ShowIf($("#pgRLRig i[searchkey='Cd_MG_A']"), !fU.ToBool(oPrg.drDO.UIMagAFix));
        // Forzo lo show o l'hide dell'accordion in base al bit mga fisso
        DivToggle_Execute($("#pgRLRig .div-mga"), fU.IsEmpty($("#pgRLRig input[name='Cd_MG_A']").val()));

        // Mostra l'ubicazione se gestita
        fU.ShowIf($("#pgRLRig .div-mgubia"), fU.ToBool(oPrg.drDO.xMOUbicazione));

        $("#pgRLRig .div-mga").show();
    }
    else { $("#pgRLRig .div-mga").hide(); }

    // Mostro le ubicazioni se gestite
    fU.ShowIf($("#pgRLRig .div-mgubip .div-mgubia"), fU.ToBool(oPrg.drDO.xMOUbicazione));

    // Crea e Visualizza i campi personalizzati configurati nel documento secondo la struttura presente nell'xml
    if (!fU.IsEmpty(oPrg.drDO.xMOExtFld)) {
        ExtFld_Load();
    }

    onRowCountChange();
}

// Gestione icon delete e dettagglio in base alla presenza di letture
function pgRLRig_Letture_UI() {
    $("#pgRLRig .letture").text(oPrg.RL.Letture);
    if (oPrg.RL.Letture == 0) {
        $("#pgRLRig .div-letture .delete").hide();
        $("#pgRLRig .div-letture .detail-letture").hide();
    }
    else {
        $("#pgRLRig .div-letture .delete").show();
        $("#pgRLRig .div-letture .detail-letture").show();
    }
}

function pgRLPiede_UI() {

    // Se non esistono moduli per il tipo di doc nascondo lo stampa
    fU.ShowIf($("#pgRLPiede .btn-stampa"), oPrg.drDO.Moduli > 0 ? true : false);

    // Se non esiste prelievo per la rilevazione nascondo le card di riepilogo
    fU.ShowIf($("#pgRLPiede .mo-card"), oPrg.drRL.CountPrelievi <= 0 ? false : true)

    //Se è presente un codice spedizione visualizza la possibilità di chiusura
    if (oPrg.Key == "SP" || oPrg.Key == "SPA")
        $("#pgRLPiede div .spedizione").show();
    else $("#pgRLPiede div .spedizione").hide();


    $("#pgRLPiede .desc-doc").text(oPrg.drDO.Cd_DO + ' - ' + oPrg.drDO.DO_Descrizione);
    $("#pgRLPiede .id-doc").text(oPrg.Id_xMORL_Edit);
    $("#pgRLPiede .cliente").html(oPrg.drRL.Cd_CF + '&nbsp;' + fU.ToString(oPrg.drRL.CF_Descrizione));
    $("#pgRLPiede .data-doc").text(fU.formatDateDDMMYYYY(oPrg.drRL.DataDoc));
    //$("#pgRLPiede .data-doc").text(fU.DateJsonToDate(oPrg.drRL.DataDoc));

    //Mostra la Targa e il Caricatore se gestiti dal doc
    fU.ShowIf($("#pgRLPiede .div-trcr"), oPrg.drDO.xMOTarga);
    $("#pgRLPiede input[name='Targa']").val(oPrg.drRL.Targa);
    $("#pgRLPiede input[name='Cd_DOCaricatore']").val(oPrg.drRL.Cd_DOCaricatore);

    // Mostra i campi per peso e volume di UL aggiuntivi se gestita la PK nel documento
    fU.ShowIf($("#pgRLPiede .div-pkpv"), oPrg.drDO.PkLstEnabled);
    $("#pgRLPiede input[name='PesoExtraMks']").val(oPrg.drRL.PesoExtraMks);
    $("#pgRLPiede input[name='VolumeExtraMks']").val(oPrg.drRL.VolumeExtraMks);

    // Mostra il bottone per Avvio Consumo se gestite le linee nel documento
    fU.ShowIf($("#pgRLPiede .div-avvioconsumo"), oPrg.drDO.xMOLinea);
    $("#pgRLPiede .div-avvioconsumo button").removeAttr("disabled");

    // Se la linea non è stata selezionata nella testa (nel caso in cui è gestita) mostro il bottone avvio consumo in grigio
    if (oPrg.drDO.xMOLinea && fU.IsEmpty($("#pgRL select[name='Cd_xMOLinea'] option:selected").val()))
        $("#pgRLPiede .div-avvioconsumo button").attr("disabled", true);

    // Carica i tutti i listener (anche senza devices config.) e seleziona quello corrente 
    Listener_Load(false);

    // Controlla se ci sono devices configurati per il listener selezionato senno nascondo il btn di stampa
    $("#pgRLPiede select[name='Listener']").on("change", function () {
        fU.ShowIf($("#pgRLPiede .btn-stampa"), $(this).find("option:selected").attr("devices") > 0 ? true : false);
        $("#pgRLPiede .ck-print").prop("checked", $(this).attr("devices") > 0 ? true : false);
    });

}

function pgStampaDocumento_UI() {
    // Carica i Listener (con devices configurati) nel select e seleziona il primo option
    Listener_Load(true);
    // Carica i devices e i moduli del listener selezionato
    Ajax_xmofn_xMOListenerDevice();
}

function pgPrelievi_UI_Edit() {

    var InEdit = (fU.ToInt32(oPrg.Id_xMORL_Edit) > 0 ? true : false);

    //Visualizza la descrizione del DO che sto creando 
    if (InEdit) {
        $("#pgPrelievi select[name='Cd_DO']").prop("disabled", "disabled").append($('<option>', {
            value: oPrg.drDO.Cd_DO,
            text: oPrg.drDO.Cd_DO,
            class: "op-cddo"
        }));
    }
}

function pgTR_UI() {

    // Imposto i check delle impostazioni generali dei movimenti interni
    $("#pgTR .ck-lotto").prop("checked", oApp.xMOImpostazioni.MovTraLotto);
    $("#pgTR .ck-ubicazione").prop("checked", oApp.xMOImpostazioni.MovTraUbicazione);
    $("#pgTR .ck-sottocommessa").prop("checked", oApp.xMOImpostazioni.MovTraCommessa);

    // Carico la descrizione di default impostata in arca
    $("#pgTR input[name='Descrizione']").val(oApp.xMOImpostazioni.MovTraDescrizione);

    // Mostro la data odierna nel campo 
    $("#pgTR input[name='DataMov']").val(fU.DateFormatToBrowserLang(fU.ToDate($.now())));

    // Mostro i campi Ubicazione se gestita 
    fU.ShowIf($("#pgTR .div-mgubip"), oApp.xMOImpostazioni.MovTraUbicazione);
    fU.ShowIf($("#pgTR .div-mgubia"), oApp.xMOImpostazioni.MovTraUbicazione);
    fU.ShowIf($("#pgTR .div-com"), oApp.xMOImpostazioni.MovTraCommessa);

    pgTR_Edit_UI();

}

function pgTR_Edit_UI() {

    var InEdit = (fU.ToInt32(oPrg.Id_xMOTR_Edit) > 0 ? true : false);

    if (InEdit) {
        // Visualizzo l'id in pgTR
        $("#pgTR .lb-doc-id").text(fU.ToString(oPrg.Id_xMOTR_Edit));

        $("#pgTR input[name='Descrizione']").val(oPrg.drTR.Descrizione);
        $("#pgTR input[name='DataMov']").val(fU.ToStandardDate(oPrg.drTR.DataMov));


        $("#pgTR input[name='Cd_DOSottoCommessa']").val(oPrg.drTR.Cd_DOSottoCommessa);

        $("#pgTR input[name='Cd_MG_P']").val(oPrg.drTR.Cd_MG_P);
        $("#pgTR input[name='Cd_MGUbicazione_P']").val(oPrg.drTR.Cd_MGUbicazione_P);
        $("#pgTR .cd_mg_p").text($("#pgTR input[name='Cd_MG_P']").val());


        $("#pgTR input[name='Cd_MG_A']").val(oPrg.drTR.Cd_MG_A);
        $("#pgTR input[name='Cd_MGUbicazione_A']").val(oPrg.drTR.Cd_MGUbicazione_A);
        $("#pgTR .cd_mg_a").text($("#pgTR input[name='Cd_MG_A']").val());

    }
}

function pgTRRig_P_UI() {

    // Mostro il campo lotto se è gestito 
    fU.ShowIf($("#pgTRRig_P .div-lotto"), oApp.xMOImpostazioni.MovTraLotto);
    // Mostro la colonna lotto della tabella se gestita 
    fU.ShowIf($("#pgTRRig_P table .Cd_ARLotto"), oApp.xMOImpostazioni.MovTraLotto);

    // Mostro l'Ubicazione se gestita
    fU.ShowIf($("#pgTRRig_P .div-mgubip"), oApp.xMOImpostazioni.MovTraUbicazione);

    // Compilo il campo mgp se riempito nella testa
    $("#pgTRRig_P input[name='Cd_MG_P']").val($("#pgTR input[name='Cd_MG_P']").val());
    // Visualizzo nella lbl il contenuto del campo magazzino
    $("#pgTRRig_P .cd_mg_p").text($("#pgTRRig_P input[name='Cd_MG_P']").val());

    // Nascondo il div del magazzino se scelto nella testa del trasferimento
    DivToggle_Execute($("#pgTRRig_P .div-mgp"), !fU.IsEmpty($("#pgTRRig_P input[name='Cd_MG_P']").val()) ? false : true)

    // Compilo il campo ubip se riempito nella testa
    $("#pgTRRig_P input[name='Cd_MGUbicazione_P']").val($("#pgTR input[name='Cd_MGUbicazione_P']").val());
}

function pgTRRig_A_UI() {

    // Mostro la colonna lotto della tabella se gestita 
    fU.ShowIf($("#pgTRRig_A table .Cd_ARLotto"), oApp.xMOImpostazioni.MovTraLotto);

    // Mostro l'Ubicazione se gestita
    fU.ShowIf($("#pgTRRig_A .div-mgubia"), oApp.xMOImpostazioni.MovTraUbicazione);

    // Compilo il campo mga se riempito nella testa
    $("#pgTRRig_A input[name='Cd_MG_A']").val($("#pgTR input[name='Cd_MG_A']").val());
    // Visualizzo nella lbl il contenuto del campo magazzino
    $("#pgTRRig_A .cd_mg_a").text($("#pgTRRig_A input[name='Cd_MG_A']").val());

    // Nascondo il div del magazzino se scelto nella testa del trasferimento
    DivToggle_Execute($("#pgTRRig_A .div-mga"), !fU.IsEmpty($("#pgTRRig_A input[name='Cd_MG_A']").val()) ? false : true)

    // Compilo il campo ubia se riempito nella testa
    $("#pgTRRig_A input[name='Cd_MGUbicazione_A']").val($("#pgTR input[name='Cd_MGUbicazione_A']").val());
}

function pgTRPiede_UI() {

    $("#pgTRPiede .desc-doc").text($("#pgTR input[name='Descrizione']").val());
    $("#pgTRPiede .id-doc").text(oPrg.Id_xMOTR_Edit);
    $("#pgTRPiede .data-doc").text(fU.formatDateDDMMYYYY($("#pgTR input[name='DataMov']").val()));
    //$("#pgTRPiede .data-doc").text($("#pgTR input[name='DataMov']").val());

    // Carica tutti i listener (anche senza devices config.) e seleziona quello corrente 
    Listener_Load(false);
}

function pgSMPiede_UI() {

    $("#pgSMPiede .desc-doc").text($("#pgSM input[name='Descrizione']").val());
    $("#pgSMPiede .id-doc").text(oPrg.Id_xMOTR_Edit);
    $("#pgSMPiede .data-doc").text(fU.ToStandardDate(oPrg.drTR.DataMov));
    //$("#pgSMPiede .data-doc").text(fU.DateJsonToDate(oPrg.drTR.DataMov));

    // Carica tutti i listener (anche senza devices config.) e seleziona quello corrente 
    Listener_Load(false);
}

function pgSP_UI() {

    $("#pgSP .i").hide();
    $("#pgSP .sp-no").show();
    //Pulizia dei campi della pagina corrente 
    $("#pgSP input[name='Cd_xMOCodSpe']").val("");
    $("#pgSP select option").remove();
}

function pgxListaCarico_UI() {
    //Pulizia dei campi della pagina corrente 
    $("#pgxListaCarico input[name='xListaCarico']").val("");
    $("#pgxListaCarico input[name='Id_DOTes']").val("");
    $("#pgxListaCarico select option").remove();
}

// Carica la lista della messaggistica
function pgLog_UI() {

    // Elimina tutti i messaggi
    $("#pgLog li.msg").remove();

    //Mostra i messaggi
    var li = $("#pgLog li.template").clone().removeClass("template").removeAttr("style").addClass("msg");
    $.each(oApp.Messages, function (key, msg) {
        var newli = li.clone()
        $(newli).find(".datetime").html(msg.DateTime);
        $(newli).find(".title").text(msg.Title.toUpperCase() + ":");
        $(newli).find(".message").html(msg.Message);
        $("#pgLog ul").append(newli);
    });

}

function pgINPiede_UI() {
    // Verifico se ci sono righe nella lista ar 
    if (!fU.IsEmpty(oPrg.IN.dtxMOINRig)) {
        // Imposto il numero di letture eseguite
        var nEle = fU.ToInt32(oPrg.IN.dtxMOINRig.filter(function (el) {
            return el.QtaRettifica != null;
        }).length);
        $("#pgINPiede .lbl-inm-let").text(nEle);
    }
    else {
        $("#pgINPiede .lbl-inm-let").text("Nessuna");
    }
}

function pgIN_UI() {

    // Svuoto la label dell'Id_xMOIN
    $("#pgIN .lb-doc-id").text("");

    // Imposto la data 
    $("#pgIN input[name='DataOra']").val(fU.DateFormatToBrowserLang(fU.ToDate($.now())));

    // Imposto il Top delle righe a 100 (valore di default)
    $("#pgIN input[name='Top']").val(100);

    // Imposto i check dei campi gestiti per l'inventario
    fU.CheckIf($("#pgIN .ck-ubicazione"), oApp.xMOImpostazioni.MovInvUbicazione);
    fU.CheckIf($("#pgIN .ck-lotto"), oApp.xMOImpostazioni.MovInvLotto);
    fU.CheckIf($("#pgIN .ck-commessa"), oApp.xMOImpostazioni.MovInvCommessa);

    // Visualizzo il cmapo UBI se gestita
    fU.ShowIf($("#pgIN .div-mgubi"), oApp.xMOImpostazioni.MovInvUbicazione);

    // Carico la descrizione se impostata in Arca
    $("#pgIN input[name='Descrizione']").val(fU.ToString(oApp.xMOImpostazioni.MovInvDescrizione));

    // Visualizzo il campo per il top delle righe nel caso di IN MASSIVO
    fU.ShowIf($("#pgIN .div-rig"), oPrg.IN.Tipo == 'M' ? true : false);

    // Pulisco la variabile globale contenente le info dell'inventario attivo 
    oPrg.IN.ResetAll(true);

}

function pgINRig_UI() {

    $("#pgINRig .mo-msg").hide();
    $("#pgINRig .mo-msg-argiac").hide();

    // Svuoto la tabella contenente le giacenze dell'articolo filtrato in New ar
    $("#pgINRig .tr-rig-argiac").remove();

    // Visualizzo il mg selezionato nella testa 
    $("#pgINRig .cd_mg").text(oPrg.IN.drIN.Cd_MG);

    // Nascondo la quantita Rettificata 
    $("#pgINRig .tbl-arlist .col-qtarilevata").show();
    $("#pgINRig .tbl-arlist .col-qtarettifica").hide();

    // Imposto nel relativo input il magazzino selezionato sulla testa
    $("#pgINRig input[name='Cd_MG']").val(fU.ToString(oPrg.IN.drIN.Cd_MG));

    var MGUBIVisible = false;

    // Controllo se UBI è gestita
    if (oApp.xMOImpostazioni.MovInvUbicazione) {

        // Show dei campi ubicazione
        $("#pgINRig .div-mgubi, #pgINRig .Cd_MGUbicazione").show();

        // Se l'UBI è stata selezionata sulla testa blocco il campo di ricerca nelle rig
        if (!fU.IsEmpty(oPrg.IN.drIN.Cd_MGUbicazione)) {
            $("#pgINRig input[name='Cd_MGUbicazione']").val(fU.ToString(oPrg.IN.drIN.Cd_MGUbicazione));
            $("#pgINRig input[name='Cd_MGUbicazione']").attr('disabled', true);
            $("#pgINRig .div-mgubi i").hide();
            $("#pgINRig .tbl-arlist .Cd_MGUbicazione").hide();
            MGUBIVisible = false;
        }
        else {
            $("#pgINRig input[name='Cd_MGUbicazione']").val("");
            $("#pgINRig input[name='Cd_MGUbicazione']").attr('disabled', false);
            $("#pgINRig .div-mgubi i").show();
            $("#pgINRig .tbl-arlist .Cd_MGUbicazione").show();
            MGUBIVisible = true;
        }
    }
    else {
        // Hide dei campi ubicazione
        $("#pgINRig .div-mgubi, #pgINRig .Cd_MGUbicazione").hide();
    }

    // Visualizza il lotto se abilitato
    fU.ShowIf($("#pgINRig .div-lotto, #pgINRig .Cd_ARLotto"), oApp.xMOImpostazioni.MovInvLotto);
    // Visualizza la commessa se abilitata
    fU.ShowIf($("#pgINRig .div-com, #pgINRig .Cd_DOSottoCommessa"), oApp.xMOImpostazioni.MovInvCommessa);

    // Se è gestita sia l'ubi che la commessa e l'ubi è visibile rendo le colonne scambiabili
    if (oApp.xMOImpostazioni.MovInvCommessa && oApp.xMOImpostazioni.MovInvUbicazione && MGUBIVisible) {
        $("#pgINRig th.Cd_DOSottoCommessa ").html("<button class='w3-button w3-blue'>COM</button>").on("click", function () {
            $('#pgINRig .tbl-arlist .Cd_DOSottoCommessa').hide();
            $('#pgINRig .tbl-arlist .Cd_MGUbicazione').show();
        });

        $("#pgINRig th.Cd_MGUbicazione").html("<button class='w3-button w3-blue'>UBI</button>").on("click", function () {
            $('#pgINRig .tbl-arlist .Cd_MGUbicazione').hide();
            $('#pgINRig .tbl-arlist .Cd_DOSottoCommessa').show();
        });

        $("#pgINRig .tbl-arlist .Cd_DOSottoCommessa").hide();
    }
    else {
        $("#pgINRig .tbl-arlist th.Cd_DOSottoCommessa ").html("COM");
        $("#pgINRig .tbl-arlist th.Cd_MGUbicazione").html("UBI");
    }

    // Nascondo i pulsanti 
    $("#pgINRig .btn-inp").hide();
    // Nascondo le frecce per lo slideshow
    $("#pgINRig .btn-slideshow").hide();
    // Nascondo il numero di riga (viene visualizzato solo in caso di IN massivo)
    $("#pgINRig .NRow").hide();

    switch (oPrg.IN.Tipo) {
        case 'M':
            // Se il ck sequenziale è attivo mostro le frecce
            fU.ShowIf($("#pgINRig .btn-slideshow"), fU.IsChecked($("#pgINRig .ck-sequenziale")));
            // Nascondo la section detail della pagina
            $("#pgINRig .div-detail").hide();
            // Mostro la section grid della pagina
            $("#pgINRig .div-grid").show();
            DivToggle_Execute($("#pgINRig .div-filtri"), false);
            break;
        case 'P':
            oPrg.IN.AddNew = true;
            Detail_pgINRig_Load();
            break;
    }
}

function pgRLPK_UI() {

    // Mostro il btn CHIUDI se è in modalità detail
    fU.ShowIf($("#pgRLPK .btn-pkref-save"), oPrg.PK.RLPKDetail);

    // Nascondo il collegamento con il dettaglio se è in modalità detail
    fU.ShowIf($("#pgRLPK .detail-pklist"), !oPrg.PK.RLPKDetail);

    // Mostro le frecce se non sono in modalità detail 
    fU.ShowIf($("#pgRLPK .div-arrow"), !oPrg.PK.RLPKDetail);
    // Mostro la label degli elementi se non sono in modalità detail
    fU.ShowIf($("#pgRLPK .NRow"), !oPrg.PK.RLPKDetail);

    if (!fU.IsEmpty(oPrg.PK.idx)) {
        // Carica i dati dell' oggetto del dt nella pagina
        pgRLPK_Template();
    }
}

function pgAA_UI() {
    switch (oApp.TipoAA.toUpperCase()) {
        case "ALI":
            // Nascondo tutti i campi che hanno la classe codalt
            $("#pgAA .codalt").hide();
            // Visualizzo tutti i campi che hanno la classe alias
            $("#pgAA .alias").show();
            break;
        case "ALT":
            // Nascondo tutti i campi che hanno la classe alias
            $("#pgAA .alias").hide();
            // Visualizzo tutti i campi che hanno la classe codalt
            $("#pgAA .codalt").show();
            $("#pgAA input[name='Cd_CF']").attr("disabled", false);
            break;
    }
    $("#pgAA .barcode").show();
    $("#pgAA .switch").show();
    $("#pgAA .first-focus:visible").first().focus().select().addClass("mo-br-orange");
}


function onSetResultsStatus(e) {
    setResultsStatus(true);
}

function pgMGDisp_UI() {
    DivToggle_Execute($("#pgMGDisp .div-accordion"), true);
    $("#pgMGDisp .div-filtri :input[type='text'], #pgMGDisp .div-filtri :input[type='checkbox']").off("change", onSetResultsStatus);
    $("#pgMGDisp .div-filtri :input[type='text'], #pgMGDisp .div-filtri :input[type='checkbox']").on("change", onSetResultsStatus);
    Clear_MGDisp();
}

function pgSM_UI() {

    var p = $("#pgSM");

    $(p).find("input[name='Descrizione']").val("Trasferimento per stoccaggio");
    $(p).find(".lb-doc-id").text("");

    $(p).find("[name='Cd_MG_P']").val(localStorage.Cd_MG_P);
    $(p).find("[name='Cd_MG_A']").val(localStorage.Cd_MG_A);
    $(p).find(".mo-smload").hide();

    if (fU.ToInt32(oPrg.Id_xMOTR_Edit) > 0) {

        $(p).find(".lb-doc-id").text(oPrg.Id_xMOTR_Edit);
        $(p).find("[name='Descrizione']").val(oPrg.drTR.Descrizione);
        $(p).find("[name='Cd_MG_P']").val(oPrg.drTR.Cd_MG_P);
        $(p).find("[name='Cd_MGUbicazione_P']").val(oPrg.drTR.Cd_MGUbicazione_P);
        $(p).find("[name='Cd_MG_A']").val(oPrg.drTR.Cd_MG_A);
        $(p).find("[name='Cd_MGUbicazione_A']").val(oPrg.drTR.Cd_MGUbicazione_A);
        $(p).find(".mo-smload").show();
    }
}

function pgSMLoad_UI() {

    // Reset della pagina
    $("#pgSMLoad input[type='checkbox']").prop("checked", false);
    $("#pgSMLoad .ck-smdocs").attr("Id_DOTess", "");
    $("#pgSMLoad .docs").text("");

    $("#pgSMLoad .smmgubi .etichetta").text("CARICA ARTICOLI NON UBICATI PRESENTI NEL MAGAZZINO:" + oPrg.drTR.Cd_MG_P);
    if (!fU.IsEmpty(oPrg.drTR.Cd_MGUbicazione_P)) {
        $("#pgSMLoad .smmgubi .etichetta").append(" UBICAZIONE:" + oPrg.drTR.Cd_MGUbicazione_P);
    }
}

function pgSMRig_T_UI() {

    // Si ordinano le righe del dt in base alla mappatura di magazzino per ottimizzare il percorso di stoccaggio
    Order_dtxMOTRRig_T();

    var UbFind = -1;
    // Se non è stata selezionata una riga in particolare si cerca nel dt l'ubicazione in cui si trova l'operatore cioè l'ultima dove ha stoccato la merce
    if (fU.IsEmpty(oPrg.SM.Id_xMOTRRig_T)) {
        $(oPrg.SM.dtxMOTRRig_T).each(function (idx, obj) {
            // Cerca Ubicazione corrente e salvo nella variabile l'idx dell'oggetto
            if (UbFind == -1 && obj.UBCorrente == 1) {
                UbFind = obj.Id_xMOTRRig_T;
            }
            // Ubicazione corrente trovata E A vuota E non esclusa
            if (UbFind >= 0 && fU.IsEmpty(obj.Id_xMOTRRig_A) && obj.Tipo != 'E') {
                oPrg.SM.Id_xMOTRRig_T = obj.Id_xMOTRRig_T;
                return;
            }
        });
    }

    // Se non è stato trovato un articolo da stoccare in tutto il dt carico nella pagina quello con ubicazione corrente a 1 e mostro un messaggio all'operatore
    if (fU.IsEmpty(oPrg.SM.Id_xMOTRRig_T)) {
        oPrg.SM.Id_xMOTRRig_T = UbFind;
        PopupMsg_Show("Messaggio", "", "Stoccaggio completato");
    }

    // Carica i dati nella pagina prendendoli da dt 
    SMRig_T_Load();
}

// -------------------------------------------------
// ENDREGION Funzioni UI
// -------------------------------------------------
// -------------------------------------------------
// #1.40 REGION: FUNZIONI LOAD
// -------------------------------------------------

// Crea i campi input personalizzati in base alla struttura dell'xml presente nella configurazione del documento e li visualizza
function ExtFld_Load() {

    var dt = oPrg.drDO.xMOExtFld; // nella varbile è contenuto un array di oggetti (conversione dell xml in C# in un datatable)

    // Cancello tutti i campi personalizzati già presentinella pagina
    ActivePage().find(".div-extfld-pers").remove();

    // Copio il template
    var input = ActivePage().find(".div-extfld").find(".template_extfld").clone().removeAttr("style").addClass("div-extfld-pers");
    var inp;

    for (var i = 0; i < dt.length; i++) {
        var inp = $(input).clone();
        $(inp).find("input").attr("type", dt[i].tipo);
        $(inp).find("input").attr("name", dt[i].nome);
        $(inp).find("input").attr("requisite", fU.ToBool(dt[i].richiesto));
        $(inp).find("label").text(dt[i].descrizione);
        ActivePage().find(".div-extfld").append(inp);
    }
}

function Linea_Load() {
    $("#" + oPrg.ActivePageId + " .op-linea").remove();
    if (oApp.dtxMOLinea.length > 0) {
        for (var i = 0; i < oApp.dtxMOLinea.length; i++) {
            $("#" + oPrg.ActivePageId + " select[name='Cd_xMOLinea']").append($('<option>', {
                class: "op-linea",
                key: i,
                value: oApp.dtxMOLinea[i].Cd_xMOLinea,
                text: oApp.dtxMOLinea[i].Cd_xMOLinea + " - " + oApp.dtxMOLinea[i].Descrizione
            }));
        }
    }
}

function Search_Articolo_Load(dt) {

    if (dt.length > 0) {
        //Nascono il messaggio 'articoli non trovati'
        $("#" + oPrg.ActiveSearchId + " .mo-msg").hide();

        var li = $("#" + oPrg.ActiveSearchId + " .template").clone().addClass("li-search").removeAttr("style");
        for (var i = 0; i < dt.length; i++) {
            $("#" + oPrg.ActiveSearchId + " ul").append(Search_Articolo_Template(li.clone(), dt[i], i));
        }
    }
    else {
        //Messaggio nel caso non è stato trovato nessun articolo
        $("#" + oPrg.ActiveSearchId + " .mo-msg").text("Nessun record.").show();
    }
}

function Search_ARLotto_Load(dt) {

    if (dt.length > 0) {
        //Nascono il messaggio 'lotti non trovati'
        $("#" + oPrg.ActiveSearchId + " .mo-msg").hide();

        var li = $("#" + oPrg.ActiveSearchId + " .template").clone().addClass("li-search").removeAttr("style");
        for (var i = 0; i < dt.length; i++) {
            $("#" + oPrg.ActiveSearchId + " ul").append(Search_ARLotto_Template(li.clone(), dt[i], i));
        }
    }
    else {
        //Messaggio nel caso non è stato trovato nessun lotto
        $("#" + oPrg.ActiveSearchId + " .mo-msg").text("Nessun lotto.").show();
    }
}

function Search_Spedizione_Load(dt) {
    if (dt.length > 0) {
        //Nascono il messaggio nessun record
        $("#" + oPrg.ActiveSearchId + " .mo-msg").hide();
        var li = $("#" + oPrg.ActiveSearchId + " .template").clone().removeClass("template").addClass("li-search").removeAttr("style");
        for (var i = 0; i < dt.length; i++) {
            $("#" + oPrg.ActiveSearchId + " ul").append(Search_Spedizione_Template(li.clone(), dt[i], i));
        }
    }
    else {
        //Messaggio nel caso non è stato trovata nessuna spedizione
        $("#" + oPrg.ActiveSearchId + " .mo-msg").text("Nessuna spedizione trovata.").show();
    }
}

function Search_xListaCarico_Load(dt) {
    if (dt.length > 0) {
        //Nascono il messaggio nessun record
        $("#" + oPrg.ActiveSearchId + " .mo-msg").hide();

        var li = $("#" + oPrg.ActiveSearchId + " .template").clone().addClass("li-search").removeAttr("style");
        for (var i = 0; i < dt.length; i++) {
            $("#" + oPrg.ActiveSearchId + " ul").append(Search_xListaCarico_Template(li.clone(), dt[i], i));
        }
    }
    else {
        //Messaggio nel caso non è stato trovata nessuna lista carico
        $("#" + oPrg.ActiveSearchId + " .mo-msg").text("Nessuna lista di carico.").show();
    }
}

function Search_CF_Load(dt) {

    if (dt.length > 0) {
        //Nascono il messaggio 'clienti/fornitori non trovati'
        $("#" + oPrg.ActiveSearchId + " .mo-msg").hide();

        var li = $("#" + oPrg.ActiveSearchId + " .template").clone().addClass("li-search").removeAttr("style");
        for (var i = 0; i < dt.length; i++) {
            $("#" + oPrg.ActiveSearchId + " ul").append(Search_CF_Template(li.clone(), dt[i], i));
        }
    }
    else {
        //Messaggio nel caso non è stato trovato nessun cliente/fornitore
        $("#" + oPrg.ActiveSearchId + " .mo-msg").text("Nessun record!").show();
    }
}

function Search_CFDest_Load(dt) {

    if (dt.length > 0) {
        //Nascono il messaggio 'nessuna destinazione trovata'
        $("#" + oPrg.ActiveSearchId + " .mo-msg").hide();

        var li = $("#" + oPrg.ActiveSearchId + " .template").clone().addClass("li-search").removeAttr("style");
        for (var i = 0; i < dt.length; i++) {
            $("#" + oPrg.ActiveSearchId + " ul").append(Search_CFDest_Template(li.clone(), dt[i], i));
        }
    }
    else {
        //Messaggio nel caso non è stata trovata nessuna destinazione
        $("#" + oPrg.ActiveSearchId + " .mo-msg").text("Nessuna destinazione!").show();
    }
}

function Search_MG_Load(dt) {

    if (dt.length > 0) {
        //Nascono il messaggio 'clienti/fornitori non trovati'
        $("#" + oPrg.ActiveSearchId + " .mo-msg").hide();

        var li = $("#" + oPrg.ActiveSearchId + " .template").clone().addClass("li-search").removeAttr("style");
        for (var i = 0; i < dt.length; i++) {
            $("#" + oPrg.ActiveSearchId + " ul").append(Search_MG_Template(li.clone(), dt[i], i));
        }
    }
    else {
        //Messaggio nel caso non è stato trovato nessun magazzino
        $("#" + oPrg.ActiveSearchId + " .mo-msg").text("Nessun magazzino.").show();
    }
}

function Search_MGUbicazione_Load(dt) {
    if (dt.length > 0) {
        //Nascono il messaggio 'Ubicazioni non trovate'
        $("#" + oPrg.ActiveSearchId + " .mo-msg").hide();

        var li = $("#" + oPrg.ActiveSearchId + " .template").clone().addClass("li-search").removeAttr("style");
        for (var i = 0; i < dt.length; i++) {
            $("#" + oPrg.ActiveSearchId + " ul").append(Search_MGUbicazione_Template(li.clone(), dt[i], i));
        }
    }
    else {
        //Messaggio nel caso non è stato trovato nessuna ubicazione
        $("#" + oPrg.ActiveSearchId + " .mo-msg").text("Nessuna ubicazione.").show();
    }
}

function Search_DOSottoCommessa_Load(dt) {
    if (dt.length > 0) {
        //Nascono il messaggio
        $("#" + oPrg.ActiveSearchId + " .mo-msg").hide();

        var li = $("#" + oPrg.ActiveSearchId + " .template").clone().addClass("li-search").removeAttr("style");
        for (var i = 0; i < dt.length; i++) {
            $("#" + oPrg.ActiveSearchId + " ul").append(Search_DOSottoCommessa_Template(li.clone(), dt[i], i));
        }
    }
    else {
        //Messaggio nel caso non è stato trovato nessuna ubicazione
        $("#" + oPrg.ActiveSearchId + " .mo-msg").text("Nessuna sottocommessa.").show();
    }
}

function Search_DOCaricatore_Load(dt) {
    if (dt.length > 0) {
        //Nascono il messaggio
        $("#" + oPrg.ActiveSearchId + " .mo-msg").hide();

        var li = $("#" + oPrg.ActiveSearchId + " .template").clone().addClass("li-search").removeAttr("style");
        for (var i = 0; i < dt.length; i++) {
            $("#" + oPrg.ActiveSearchId + " ul").append(Search_DOCaricatore_Template(li.clone(), dt[i], i));
        }
    }
    else {
        //Messaggio nel caso non è stato trovato nessun caricatore
        $("#" + oPrg.ActiveSearchId + " .mo-msg").text("Nessun Caricatore.").show();
    }
}

function Search_ARARMisura_Load(dt) {
    if (dt.length > 0) {
        //Nascono il messaggio
        $("#" + oPrg.ActiveSearchId + " .mo-msg").hide();

        var li = $("#" + oPrg.ActiveSearchId + " .template").clone().addClass("li-search").removeAttr("style");
        for (var i = 0; i < dt.length; i++) {
            $("#" + oPrg.ActiveSearchId + " ul").append(Search_ARARMisura_Template(li.clone(), dt[i], i));
        }
    }
    else {
        //Messaggio nel caso non è stato trovato nessuna UM
        $("#" + oPrg.ActiveSearchId + " .mo-msg").text("Nessun UM. Selezionare un articolo").show();
    }
}

function DOAperti_Load(dt) {
    $("#pgDocAperti .msg").text("");
    //Verifico che il dt abbia delle righe
    if (dt.length > 0) {
        var li = $("#pgDocAperti .template").clone().removeAttr("style").addClass("li-doc");
        for (var i = 0; i < dt.length; i++) {
            $("#pgDocAperti ul").append(DOAperti_Template(li.clone(), dt[i], i));
        }
    } else {
        $("#pgDocAperti .msg").text("Nessun documento aperto.");
    }
}

function DORistampa_Load(dt) {
    //Verifico che il dt abbia delle righe
    if (dt.length > 0) {
        if (!oPrg.drDO) {
            oPrg.drDO = oApp.dtDO[dt[0].Cd_DO];
        }

        var li = $("#pgDocRistampa .template").clone().removeAttr("style").addClass("li-doc");
        for (var i = 0; i < dt.length; i++) {
            $("#pgDocRistampa ul").append(DORistampa_Template(li.clone(), dt[i], i));
        }
    }
    else { $("#pgDocRistampa .msg").text('Nessun Documento trovato!') }
}

function DOPrel_Load(dt) {
    var count = 0;
    if (dt.length > 0) {
        var tr = $("#pgDOPrelievi .template").clone().removeAttr("style").addClass("tr-prel");
        for (var i = 0; i < dt.length; i++) {
            $("#pgDOPrelievi table").append(DOPrel_Template(tr.clone(), dt[i], i));
        }

        $("pgDOPrelievi tr-prel").each(function () {
            if (!$(this).hasClass("non-prelevabile"))
                count += 1;
        });
    }
    if (count > 0) {
        $("#pgDOPrelievi .toggle-disabled").show();
        //Nascondo le righe non prelevabili
        $("#pgDOPrelievi table .non-prelevabile").hide();
    }
    else {
        $("#pgDOPrelievi .toggle-disabled").hide();
        //Nascondo le righe non prelevabili
        $("#pgDOPrelievi table .non-prelevabile").show();
    }
}

function DOPrel_All_Load(dt) {
    if (dt.length > 0) {
        $("#pgPrelievi .msg").text("");
        var li = $("#pgPrelievi .template").clone().removeAttr("style").addClass("li-prel");
        for (var i = 0; i < dt.length; i++) {
            $("#pgPrelievi ul").append(DOPrel_All_Template(li.clone(), dt[i], i));
        }
    }
    else
        $("#pgPrelievi .msg").text("Nessun documento prelevabile!");
}

function Spedizione_Load(dt) {
    if (dt.length > 0) {
        var tr = $("#pgSP .template").clone().removeAttr("style").addClass("tr-sp");
        for (var i = 0; i < dt.length; i++) {
            $("#pgSP table").append(Spedizione_Template(tr.clone(), dt[i], i));
        }
    }
}

// Pers
function xListaCarico_Load(dtLdc) {
    if (dtLdc.length > 0) {
        var tr = $("#pgxListaCarico .template").clone().removeAttr("style").addClass("tr-ldc");
        for (var i = 0; i < dtLdc.length; i++) {
            $("#pgxListaCarico table").append(xListaCarico_Template(tr.clone(), dtLdc[i], i));
        }
    }
}

function pgRLRig_AR_Load() {
    //Verifico che il dt abbia delle righe
    var dt = oPrg.RL.dtRLRig_AR;
    if (dt.length > 0) {

        showFor_W44716() // pers

        var tr1 = $("#pgRLRig .template").clone().removeAttr("style").addClass("tr-rigprel");
        var tr2 = $("#pgRLRig .template_ARDesc").clone().removeAttr("style").addClass("tr-rigprel tr-ardesc");


        for (var i = 0; i < dt.length; i++) {
            $("#pgRLRig table").append(pgRLRig_AR_Template(tr1.clone(), dt[i], i));
            $("#pgRLRig table").append(pgRLRig_ARDesc_Template(tr2.clone(), dt[i], i));
        }

        var W44716 = 44716; // per fare le prove sostituire con il proprio nuero di licenza
        if (oApp.LicF_Id == W44716) {
            // Mostro o nascondo la colona Ubicazione in funzione della presenza o l'assenza della colona Cd_MGUbicazione nei dati 
            // ricevuti dal server
            if (dt[0].hasOwnProperty("ExtField")) {
                ActivePage().find("th.Cd_MGUbicazione, td.Cd_MGUbicazione").show()
                ActivePage().find("tr.tr-ardesc").find("td.Descrizione").attr("colspan", "3");
            } else {
                ActivePage().find("th.Cd_MGUbicazione, td.Cd_MGUbicazione").hide().removeClass("cl-ardesc tr-ardesc");
                ActivePage().find("tr.tr-ardesc").find("td.Descrizione").attr("colspan", "4");
            }
        }

        $(window).resize();
    }
}

function pgTRRig_P_AR_Load(dt) {
    //Verifico che il dt abbia delle righe
    if (dt.length > 0) {
        var tr = ActivePage().find(".template").clone().removeAttr("style").addClass("tr-rigp").removeClass("template");
        for (var i = 0; i < dt.length; i++) {
            ActivePage().find("table").append(pgTRRig_P_AR_Template(tr.clone(), dt[i], i));
        }
        //var tr = $("#pgTRRig_P .template").clone().removeAttr("style").addClass("tr-rigp").removeClass("template");
        //for (var i = 0; i < dt.length; i++) {
        //    $("#pgTRRig_P table").append(pgTRRig_P_AR_Template(tr.clone(), dt[i], i));
        //}
    }
}

function pgTRRig_A_AR_Load(dt) {
    //Verifico che il dt abbia delle righe
    if (dt.length > 0) {
        var tr = $("#pgTRRig_A .template").clone().removeAttr("style").addClass("tr-riga").removeClass("template");
        for (var i = 0; i < dt.length; i++) {
            $("#pgTRRig_A table").append(pgTRRig_A_AR_Template(tr.clone(), dt[i], i));
        }
    }
}

function ARARMisura_Load(dt) {
    var p = $("#" + oPrg.ActivePageId);

    // Recupero il select
    var select = $(p).find("select[name='Cd_ARMisura']");


    // Verifico che il dt abbia delle righe
    if (dt.length > 0) {
        for (var i = 0; i < dt.length; i++) {
            $(select).append($('<option>', {
                class: "op-um",
                Cd_ARMisura: dt[i].Cd_ARMisura,
                UMFatt: dt[i].UMFatt,
                umdef: dt[i].DefaultMisura,
                value: dt[i].Cd_ARMisura,
                text: dt[i].Cd_ARMisura
            }));
        }

        // Al cambio di valore
        $(select).change(function () {
            // Recupero il fattore di conversione
            var UMFatt = $(this).find('option:checked').attr('UMFatt');
            // Recupero il campo nascosto più vicino
            var input = $(select).siblings('input[type="hidden"][data-bind="FattoreToUM1"]');
            // Se l'ho trovato
            if ($(input).length > 0)
                input.val(UMFatt);
            //se richiesto dalla confgiurazione del documento imposta il valore
            if (oPrg.drDO) {
                switch (oPrg.drDO.xMOUMFatt) {
                    case 1:
                        ActivePage().find("input[name='UMFatt']").val(UMFatt);
                        break;
                    case 2:
                        ActivePage().find("input[name='UMFatt']").val(1);
                        break;
                    default:
                        break;
                }
            }
        });

        // Assegno il primo valore così da scatenare l'evento
        $(select).val(dt[0].Cd_ARMisura).change();
    }
}

function Detail_ARGiacenza_Load(dt) {
    //Verifico che il dt abbia delle righe
    if (dt.length > 0) {
        var tr = $("#DetailARGiacenza .template").clone().removeAttr("style").addClass("tr-giac").addClass("mo-pointer");
        for (var i = 0; i < dt.length; i++) {
            $("#DetailARGiacenza table").append(Detail_ARGiacenza_Template(tr.clone(), dt[i], i));
        }
    }
    $("#DetailARGiacenza").show();
}

function Detail_UBIGiacenza_Load(dt) {
    //Verifico che il dt abbia delle righe
    if (dt.length > 0) {
        var tr = $("#DetailUBIGiacenza .template").clone().removeAttr("style").addClass("tr-giac");
        var trardesc = $("#DetailUBIGiacenza .template_ARDesc").clone().removeAttr("style").addClass("tr-giac");
        for (var i = 0; i < dt.length; i++) {
            $("#DetailUBIGiacenza table").append(Detail_UBIGiacenza_Template(tr.clone(), dt[i], i));
            $("#DetailUBIGiacenza table").append(Detail_UBIGiacenza_ARDesc_Template(trardesc.clone(), dt[i], i));
        }
    }
    $("#DetailUBIGiacenza").show();
}

function Listener_Load(withdevices) {
    $("#" + oPrg.ActivePageId + " .op-listener").remove();

    //Verifico che il dt abbia delle righe
    if (oApp.dtxMOListener.length > 0) {
        for (var i = 0; i < oApp.dtxMOListener.length; i++) {
            if (withdevices == false || oApp.dtxMOListener[i].Devices > 0) {
                $("#" + oPrg.ActivePageId + " select[name = 'Listener']").append($('<option>', {
                    class: "op-listener",
                    value: oApp.dtxMOListener[i].Cd_xMOListener,
                    text: oApp.dtxMOListener[i].Cd_xMOListener,
                    idx: i,
                    devices: oApp.dtxMOListener[i].Devices
                }));
            }
        }
        // Seleziona il listener corrente (quello salvato nella variabile globale) 
        $("#" + oPrg.ActivePageId + " select[name='Listener']").val(oApp.dtxMOListener[oApp.ActiveListenerIdx].Cd_xMOListener);
    }
}

function ListenerDevice_Load(dt) {
    var ld = $("#pgStampaDocumento select[name='ListenerDevice']");
    //Aggiunge una riga vuota
    ld.append($('<option>', {
        class: "op-lsdevice"
        , value: ""
        , text: "Default Device"
        , copie: ""
    }));
    //Verifico che il dt abbia delle righe
    if (dt.length > 0) {
        for (var i = 0; i < dt.length; i++) {
            ld.append($('<option>', {
                class: "op-lsdevice"
                , value: dt[i].Device.trim()     //Id_xMOListenerDevice
                , text: dt[i].Device.trim()
                , copie: fU.IsEmpty(dt[i].NumeroCopie) ? "" : dt[i].NumeroCopie
            }));
        }
    }
}

function Listener_Moduli_Load(dt) {
    //Verifico che il dt abbia delle righe
    if (dt.length > 0) {
        var li = $("#pgStampaDocumento .template").clone().removeAttr("style").addClass("li-modulo");
        for (var i = 0; i < dt.length; i++) {
            $("#pgStampaDocumento ul").append(Listener_Moduli_Template(li.clone(), dt[i], i));
        }
    }
}

function DetailDORig_Load(dt) {
    $("#DetailDO .tr-dorig").remove();
    //Verifico che il dt abbia delle righe
    if (dt.length > 0) {
        var tr = $("#DetailDO .template").clone().removeAttr("style").addClass("tr-dorig");
        for (var i = 0; i < dt.length; i++) {
            //Riga Codice articolo
            $("#DetailDO table").append(DetailDORig_Template(tr.clone(), dt[i], i, "ROW1"));
            //Riga Descrizione
            $("#DetailDO table").append(DetailDORig_Template(tr.clone(), dt[i], i, "ROW2"));
        }
    }
}

function DetailRLRig_Load(dt) {
    //Verifico che il dt abbia delle righe
    if (dt.length > 0) {
        $("#Detail_Letture .mo-msg").hide();
        var li = $("#Detail_Letture .template").clone().removeAttr("style").addClass("li-rig");
        for (var i = 0; i < dt.length; i++) {
            $("#Detail_Letture ul").append(DetailRLRig_Template(li.clone(), dt[i], i));
        }
    }
    else {
        $("#Detail_Letture .mo-msg").show();
    }
}

function DetailTRRig_P_Load(dt) {
    //Verifico che il dt abbia delle righe
    if (dt.length > 0) {
        $("#Detail_Letture .mo-msg").hide();
        var tr = $("#Detail_Letture .template").clone().removeAttr("style").addClass("li-rig");
        for (var i = 0; i < dt.length; i++) {
            $("#Detail_Letture ul").append(DetailTRRig_P_Template(tr.clone(), dt[i], i));
        }
    }
    else {
        $("#Detail_Letture .mo-msg").show();
    }
}

function DetailTRRig_A_Load(dt) {
    //Verifico che il dt abbia delle righe
    if (dt.length > 0) {
        $("#Detail_Letture .mo-msg").hide();
        var tr = $("#Detail_Letture .template").clone().removeAttr("style").addClass("li-rig");
        for (var i = 0; i < dt.length; i++) {
            $("#Detail_Letture ul").append(DetailTRRig_A_Template(tr.clone(), dt[i], i));
        }
    }
    else {
        $("#Detail_Letture .mo-msg").show();
    }
}

function PackListRef_Load(dt) {

    if (dt.length > 0) {
        for (var i = 0; i < dt.length; i++) {
            $("#pgRLRig select[name='PackListRef']").append($('<option>', {
                class: "op-pklref"
                , value: dt[i].PackListRef
                , text: dt[i].PackListRef
            }));
        }
    }
}

function Popup_PackList_New_Load() {

    // Recupera il codice da proporre per il nuovo pklRef e lo scrive nell'input
    Ajax_xmofn_xMORLRigPackingList_GetNew();

    // Recupera le tipologie di UL e carica il select
    Ajax_xmofn_xMOUniLog();

    // Show del detail
    $("#Popup_PackList_New").show();
}

// Il secondo parametro indica il tipo di visualizzazione 1 = visualizzazione raggruppata 0 = visualizzazione singola
function DetailPackingList_Load(dt, GRP) {
    $("#Detail_PackingList .mo-msg").hide();

    if (dt.length > 0) {

        var PKL_Before = "";

        // Se esiste PackListRef filtro la tabella ricevuta
        if (ActivePage().attr("id") == $("#pgRLPK").attr("id")) {
            var PackListRef = $("#pgRLPK label.PackListRef").text();
            if (PackListRef.length > 0) {
                dt = dt.filter(function (item, index) {
                    return (item.PackListRef === PackListRef);
                });
            }
        }

        //tr: testa UL corrente che contiene 
        var trULHead = $("#Detail_PackingList tr.template-ul-header").clone().removeAttr("style").removeClass("template-ul-header").addClass("pk-dati");
        //tr: tabella della testa delle righe
        var trULHeadRows = $("#Detail_PackingList .template-ul-rows").clone().removeAttr("style").removeClass("template-ul-rows").addClass("pk-dati");
        //tr: delle righe UL
        var trULRow = $("#Detail_PackingList .template-ar").clone().removeAttr("style").removeClass("template-ar");


        //// Articolo per unità logistica
        //var AR = null;

        for (i = 0; i < dt.length; i++) {
            // Se l'unità logica è diversa dalla precedente creo un nuovo li 
            if (PKL_Before != dt[i].PackListRef) {

                //Memorizzo l'UL corrente
                PKL_Before = dt[i].PackListRef;

                //Genero head dell'UL
                _trULHead = DetailPackingList_UL_Template(trULHead.clone(), dt[i], i);
                _trULHeadRows = trULHeadRows.clone();
                //Aggiungo l'Head dell'UL e l'Head delle righe dell'UL
                $("#Detail_PackingList .pk-all").append(_trULHead).append(_trULHeadRows);
            }

            // Articolo dell'unità logistica corrente'
            _trULRow = DetailPackingList_ULAR_Template(trULRow.clone(), dt[i], i, GRP);

            // Append del tr nella tabella della corrispondente UL
            _trULHeadRows.find("table").append(_trULRow);

            //Totali pesi e volumi di UL e di tutta la packing
            Sum_Pesi_Volumi(_trULHead, _trULHeadRows, dt[i]);

        }

        // Nascondo le colonne dati2 che comprende i pesi e i volumi
        if ($("#Detail_PackingList .ck-pkpesi").prop("checked") == true) {
            $("#Detail_PackingList .dati2").show();
            $("#Detail_PackingList .dati1").hide();
        }
        else {
            $("#Detail_PackingList .dati1").show();
            $("#Detail_PackingList .dati2").hide();
        }
        //$("#Detail_PackingList .dati2").hide();

    }
    else { $("#Detail_packingList .mo-msg").show(); }
}

function Popup_PKListAR_DelShift_Load(tr) {

    var p = $('#Popup_PKListAR_DelShift');

    p.attr('Id_xMORLRigPackList', tr.attr('Id_xMORLRigPackList'));

    p.find(".Cd_AR").text(tr.find(".Cd_AR").text());
    p.find("input[name='Qta']").val(tr.find(".Qta").text());
    p.find(".Cd_ARMisura").text(tr.find(".Cd_ARMisura").text());

    p.find("select").remove();
    p.find(".div-container").append($("#pgRLRig select[name='PackListRef']").clone());

    p.show();
}

function xMOMGEsercizio_Load(dt) {
    if (dt.length > 0) {
        for (var i = 0; i < dt.length; i++) {
            $("#pgIN select[name='Cd_MGEsercizio']").append($('<option>', {
                class: "op-mges"
                , value: dt[i].Cd_MGEsercizio
                , text: dt[i].Cd_MGEsercizio + " - " + dt[i].Descrizione
            }));
        }
    }
}

function xMOIN_Aperti_Load(dt) {
    //Verifico che il dt abbia delle righe
    if (dt.length > 0) {
        var li = $("#pgINAperti .template").clone().removeAttr("style").addClass("li-in");
        for (var i = 0; i < dt.length; i++) {
            $("#pgINAperti ul").append(xMOIN_Aperti_Template(li.clone(), dt[i], i));
        }
    }
}

// Load select dei tipi di UL
function xMOUniLog_Load(dt) {

    $("#Popup_PackList_New .op-unilog").remove();

    if (dt.length > 0) {
        for (var i = 0; i < dt.length; i++) {
            $("#Popup_PackList_New select[name='Cd_xMOUniLog']").append($('<option>', {
                class: "op-unilog"
                , value: dt[i].Cd_xMOUniLog
                , text: dt[i].Cd_xMOUniLog + " - " + dt[i].Descrizione
            }));
        }
    }
}

// Load delle giacenze nella tabella
function xMOGiacenza_Load(dt) {
    if (dt.length > 0) {
        var tr = $("#" + oPrg.ActivePageId + " .tbl-argiac .template").clone().removeAttr("style").addClass("tr-rig-argiac");
        for (var i = 0; i < dt.length; i++) {
            $("#" + oPrg.ActivePageId + " .tbl-argiac").append(xMOGiacenza_Template(tr.clone(), dt[i], i));
        }
    }
}

function DetailSMDocs_Load(dt) {
    if (dt.length > 0) {
        var li = $("#Detail_SMDocs ul li.template").clone().removeAttr("style").addClass("li-do");
        for (var i = 0; i < dt.length; i++) {
            $("#Detail_SMDocs ul").append(DetailSMDocs_Template(li.clone(), dt[i], i));
        }
    }
}

function SMRig_TA_Load() {

    Order_dtxMOTRRig_T();

    // Nascondo le sezioni 
    $("#pgSMRig .section").hide();
    // Svuoto la lista della pagina
    $("#pgSMRig .tr-rig").remove();

    var orderby = fU.IsChecked($("#pgSMRig .ck-smart")) ? 'ART' : 'UBI';
    var lastord = "";

    fU.ShowIf($("#pgSMRig table .Cd_AR"), orderby == 'ART' ? false : true);
    fU.ShowIf($("#pgSMRig table .Cd_MGUbicazione"), orderby == 'UBI' ? false : true);

    if (oPrg.SM.dtxMOTRRig_T.length > 0) {

        // Visualizzo la sezione della pagina contenente la tabella
        $("#pgSMRig .div-table").show();

        var trorderby = $("#pgSMRig table tr.template_OrderBy").clone().removeAttr("style").addClass("tr-rig tr-orderby");
        var trar = $("#pgSMRig table tr.template").clone().removeAttr("style").addClass("tr-rig");
        var trardesc = $("#pgSMRig table .template_ARDesc").clone().removeAttr("style").addClass("tr-rig tr-ardesc");

        for (var i = 0; i < oPrg.SM.dtxMOTRRig_T.length; i++) {
            switch (orderby) {
                case 'ART':
                    if (lastord != oPrg.SM.dtxMOTRRig_T[i].Cd_AR) {
                        $("#pgSMRig .mo-table").append(SMRig_TAOrderBy_Template(trorderby.clone(), oPrg.SM.dtxMOTRRig_T[i], i, orderby));
                        lastord = oPrg.SM.dtxMOTRRig_T[i].Cd_AR;
                    }
                    $("#pgSMRig .mo-table").append(SMRig_TA_Template(trar.clone(), oPrg.SM.dtxMOTRRig_T[i], i, true));
                    break;

                case 'UBI':
                    if (lastord != oPrg.SM.dtxMOTRRig_T[i].Cd_MGUbicazione_A) {
                        $("#pgSMRig .mo-table").append(SMRig_TAOrderBy_Template(trorderby.clone(), oPrg.SM.dtxMOTRRig_T[i], i, orderby));
                        lastord = oPrg.SM.dtxMOTRRig_T[i].Cd_MGUbicazione_A;
                    }
                    $("#pgSMRig .mo-table").append(SMRig_TA_Template(trar.clone(), oPrg.SM.dtxMOTRRig_T[i], i, false));
                    $("#pgSMRig .mo-table").append(SMRig_TAARDesc_Template(trardesc.clone(), oPrg.SM.dtxMOTRRig_T[i], i));
                    break;
            }
        }
    }
    else {
        $("#pgSMRig .div-input").show();
    }
}

function PRTRAttivita_Load() {

    // Pagina
    var page = $('#' + oPrg.ActivePageId);

    // Oggetto del combo
    var select = $(page).find("select[data-bind='Cd_xMOLinea']");
    $(select).find("option").remove();

    //Aggiunge l'elemento vuoto
    var o = document.createElement('option');
    $(o).text('Tutte');
    o.setAttribute('value', null);
    $(select).append(o);

    var linee = [];
    // Distinct delle linee di produzione
    oPrg.PRAV.dtBLA.forEach(function (item) {
        if (!linee.includes(item.Cd_xMOLinea)) {
            linee.push(item.Cd_xMOLinea)
            // Creo l'elemento
            var option = document.createElement('option');
            option.setAttribute('value', item.Cd_xMOLinea);
            option.setAttribute('data-interno', item.Interno);
            if (!item.Interno)
                option.setAttribute('class', 'w3-light-gray');
            $(option).text(item.Cd_xMOLinea);
            // Aggiungo l'elemento al combo
            $(select).append(option);
        }
    });

    // Carico gli elementi
    PRTRAttivita_Load_Items();
}

function PRTRAttivita_Load_Items() {
    // Elimina tutti gli elementi
    $(ActivePage()).find("li.attivita").remove();

    // Memorizzo i filtri
    var Cd_xMOLinea = $(ActivePage()).find('select[data-bind="Cd_xMOLinea"]').val();
    if (!fU.IsEmpty(Cd_xMOLinea)) {
        // Imposta Interno/Esterno a seconda della risorsa selezionata 
        $(ActivePage()).find('input[data-bind="Interne"]').prop('checked', $(ActivePage()).find('select[data-bind="Cd_xMOLinea"] option:checked').attr('data-interno') == "true");
    }

    var searchQuery = $(ActivePage()).find('input[data-bind="SearchQuery"]').val();
    var ckInterne = $(ActivePage()).find('input[data-bind="Interne"]').prop('checked');
    var ckDaTrasferire = !$(ActivePage()).find('input[data-bind="DaTrasferire"]').prop('checked');

    // Copio gli elementi per applicare i filtri senza modificare l'originale
    var dt = oPrg.PRAV.dtBLA.slice();

    if (!fU.IsEmpty(searchQuery)) {
        // Nascondo gli altri filtri
        $(ActivePage()).find('[data-key="Filtri"]').hide();

        //Elimina gli eventuali zeri a sinistra
        while (searchQuery.charAt(0) == "0") { searchQuery = searchQuery.slice(1); }

        // Formatto il valore
        searchQuery = searchQuery.toLowerCase().trim();

        // Filtro gli elementi
        dt = dt.filter(function (item) {
            return item.Bolla.toLowerCase().includes(searchQuery)
                || item.Articolo.toLowerCase().includes(searchQuery)
                || item.Descrizione.toLowerCase().includes(searchQuery)
                || item.Id_PrBL.toString() == searchQuery;
        });
    } else {
        // Mostro i filtri
        $(ActivePage()).find('[data-key="Filtri"]').show();

        // Filtro gli elementi
        if (!fU.IsEmpty(Cd_xMOLinea))
            dt = dt.filter(function (item) { return item.Cd_xMOLinea == Cd_xMOLinea; });

        dt = dt.filter(function (item) { return item.Interno == ckInterne; });
        dt = dt.filter(function (item) { return item.Trasferita == ckDaTrasferire; });
    }

    // Template dell'elemento
    var template = $(ActivePage()).find("li.template").clone().removeClass("template").removeAttr("style").addClass("attivita");

    // Lista degli elementi
    var ul = $(ActivePage()).find("ul");

    // Per ogni elemento
    dt.forEach(function (item) {
        // Clono il template
        var li = $(template).clone();
        // Imposto i valori
        $(li).find('[data-bind="Id_PrBL"]').html(item.Id_PrBL);
        $(li).find('[data-bind="Id_PrBLAttivita"]').html(item.Id_PrBLAttivita);
        fU.ShowIf($(li).find('[data-bind="Mancante"]'), item.Mancante);
        if (item.DaTrasferire)
            $(li).find('[data-bind="Id_PrBLAttivita"]').addClass("w3-red");
        else
            $(li).find('[data-bind="Id_PrBLAttivita"]').removeClass("w3-red");
        $(li).find('[data-bind="Bolla"]').html("Bolla " + item.Bolla);
        $(li).find('[data-bind="Articolo"]').html(item.Articolo);
        $(li).find('[data-bind="Cd_xMOLinea"]').html(item.Cd_xMOLinea);
        $(li).find('[data-bind="DataObiettivo"]').html(fU.ToLocaleDate(item.DataObiettivo));
        $(li).find('[data-bind="Descrizione"]').html(item.Descrizione);
        $(li).on('click', function () {
            oPrg.PRAV.keyBLA = oPrg.PRAV.dtBLA.indexOf(item);
            Nav.Next();
        });
        // Aggiungo l'elemento alla lista
        $(ul).append(li);
    });
}

function PRTRMateriali_Load(UsrAssign) {
    // Elemento dell'attività
    var attivita = oPrg.PRAV.dtBLA[oPrg.PRAV.keyBLA];

    // Valorizzo il riepilogo 
    var riepilogo = $(ActivePage()).find('[data-key="Riepilogo"]');
    riepilogo.find('span[data-bind="Id_PrBL"]').text(attivita.Id_PrBL);
    riepilogo.find('label[data-bind="Bolla"]').text("Bolla " + attivita.Bolla);
    riepilogo.find('span[data-bind="Id_PrBLAttivita"]').text(attivita.Id_PrBLAttivita);
    if (attivita.DaTrasferire)
        riepilogo.find('span[data-bind="Id_PrBLAttivita"]').addClass("w3-red");
    else
        riepilogo.find('span[data-bind="Id_PrBLAttivita"]').removeClass("w3-red");
    riepilogo.find('label[data-bind="Fase"]').text(attivita.Descrizione + ' / ' + attivita.Articolo);
    riepilogo.find('label[data-bind="Articolo"]').text(attivita.Articolo);
    riepilogo.find('label[data-bind="Cd_ARLotto"]').text(attivita.Cd_ARLotto);

    var qtausr = $(ActivePage()).find('[data-key="QtaUsr"]');
    if (!UsrAssign) {
        qtausr.find('label[data-bind="QtaUsrP"]').text('QTA per ' + attivita.Cd_AR);
        qtausr.find('input[data-bind="QtaUsrP"]').val(attivita.Quantita);
        // Carico le unità di misura
        Ajax_xmofn_ARARMisura2(attivita.Cd_AR, attivita.Cd_ARMisura);
    }

    qtausr.find('label[data-bind="PercTrasferitaP"]').text('tras. ' + Number(attivita.PercTrasferita).toFixed(1) + '%');
    qtausr.find('label[data-bind="PercTrasferitaP"]').on('click', function () {
        //Ricalcola la quantità di padre da produrre e aggiorna le righe
        var QtaUsrP = Number(attivita.Quantita - (attivita.Quantita * attivita.PercTrasferita / 100)).toFixed(0);
        if (QtaUsrP < 1) QtaUsrP = 1;
        qtausr.find('input[data-bind="QtaUsrP"]').val(QtaUsrP);
        Ajax_xmofn_xMOPRBLMateriali(QtaUsrP);
    });

    var PercTrasferita = 100;
    var Traferisci = false;

    // Memorizzo la tabella
    var table = $(ActivePage()).find('table[data-key="Materiali"]');

    // Elimina tutte le righe
    $(table).find("tr.tr-rig").remove();

    // Template della riga
    var template = $(table).find('tr.template').clone().removeClass("template").removeAttr("style").addClass("tr-rig");

    oPrg.PRAV.dtBLM.forEach(function (item) {
        // Clono il template
        var tr = $(template).clone();
        // Imposto i valori
        $(tr).find('[data-bind="Cd_AR"]').text(item.Cd_AR);
        if (item.QtaTrasferita >= item.Consumo)
            $(tr).find('[data-bind="Cd_AR"]').addClass("w3-green");
        else
            if (item.Mancante)
                $(tr).find('[data-bind="Cd_AR"]').addClass("w3-red");
        //else
        //    $(tr).find('[data-bind="Cd_AR"]').removeClass("w3-green");

        $(tr).find('[data-bind="Cd_ARLotto"]').text(item.Cd_ARLotto);

        var qta = '';
        //Qta rossa se giacenza insufficiente
        if (item.Giacenza < item.Consumo)
            qta = '<span class="w3-text-red">' + Number(item.Consumo).toFixed(2) + '</span>';
        else
            qta = '<span>' + Number(item.Consumo).toFixed(2) + '</span>';

        if (item.Consumo != item.ConsumoUsr)
            qta = Number(item.ConsumoUsr).toFixed(2) + '(' + qta + ')';

        qta = '/' + qta;

        //Quantità da trasferire
        //Eliminabile
        //Trasferibile
        if (item.QtaDaTrasferire != null) {
            qta = '+' + Number(item.QtaTrasferita).toFixed(2) + qta;
            qta = '<span class="w3-text-orange">' + Number(item.QtaDaTrasferire).toFixed(2) + '</span>' + qta;
            $(tr).find('[data-bind="Del"]').html('<i data-action="delete" class="mi s20 red mo-pointer w3-right">delete_forever</i>');
            Traferisci = true;
        } else
            qta = Number(item.QtaTrasferita).toFixed(2) + qta;

        if (item.Mancante) {
            $(tr).find('[data-bind="Del"]').html($(tr).find('[data-bind="Del"]').html() + '<span class="mo-tag w3-red">!</span>');
        }

        $(tr).find('[data-bind="Qta"]').html(qta);

        //calcola la percentuale minima da trasferire
        if (((item.QtaDaTrasferire + item.QtaTrasferita) / item.Consumo * 100) < PercTrasferita)
            PercTrasferita = Number((item.QtaDaTrasferire + item.QtaTrasferita) / item.Consumo * 100).toFixed(1);

        $(tr).find('[data-bind="Cd_ARMisura"]').text(item.Cd_ARMisura);
        $(tr).on('click', function (event) {
            //Punta al materiale corrente
            oPrg.PRAV.keyBLM = oPrg.PRAV.dtBLM.indexOf(item);
            //elimina o apre la riga
            if (event.target.dataset.action && event.target.dataset.action == 'delete') {

                var del = confirm("Eliminare i materiali da trasferire per l'articolo " + oPrg.PRAV.dtBLM[oPrg.PRAV.keyBLM].Cd_AR + "?");
                if (del == true) {
                    Ajax_xmosp_xMOPRTRRig_Delete(oPrg.PRAV.dtBLM[oPrg.PRAV.keyBLM].Id_PrBLMateriale);
                }
            }
            else
                PRTRMateriali_Trasferimento_Load();
        });

        // Trasferimento completato
        if (item.QtaTrasferita >= item.Consumo)
            $(tr).css('color', '#31ab13');

        // Aggiungo la riga alla tabella
        $(table).append(tr);
    });

    //Gestione trasferimento
    fU.ShowIf(ActivePage().find('div[data-bind="Trasferisci"]'), Traferisci)
    ActivePage().find('input[data-bind="PercTrasferita"]').val(PercTrasferita);

    // Switch dei div
    $(ActivePage()).find('[data-key="Trasferimento"]').hide();
    $(ActivePage()).find('[data-key="Lista"]').show();

    setTimeout(function () { $(ActivePage()).find('[data-key="QtaUsr"] input[data-bind="QtaUsrP"]').focus().select(); }, 250);
}

function PRTRMateriali_Trasferimento_Load() {

    // Materiale
    var materiale = oPrg.PRAV.dtBLM[oPrg.PRAV.keyBLM];

    // Mostro i valori sulla pagina
    var trasferimento = $(ActivePage()).find('[data-key="Trasferimento"]');
    // Pulizia degli input della pagina
    // Assegnazione valori
    trasferimento.find('input, textarea').val('');
    trasferimento.find('[data-bind="Cd_AR"]').text(materiale.Cd_AR);
    trasferimento.find('input[name="Cd_AR"]').val(materiale.Cd_AR);
    trasferimento.find('[data-bind="Descrizione"]').text(materiale.Descrizione);
    trasferimento.find('[data-bind="Cd_ARLotto"]').text(materiale.Cd_ARLotto);
    trasferimento.find('[data-bind="Cd_MG_P"]').text(materiale.Cd_MG_P);
    trasferimento.find('[data-bind="Cd_MGUbicazione_P"]').text(materiale.Cd_MGUbicazione_P);
    trasferimento.find('[data-bind="Cd_MG_A"]').text(materiale.Cd_MG_A);
    trasferimento.find('[data-bind="Cd_MGUbicazione_A"]').text(materiale.Cd_MGUbicazione_A);

    // Setto la quantità
    if (materiale.ConsumoUsr != materiale.Consumo)
        trasferimento.find('[name="QtaRilevata"]').val(Number((materiale.ConsumoUsr > materiale.QtaDaTrasferire ? materiale.ConsumoUsr - materiale.QtaDaTrasferire : 0).toFixed(2)));
    else
        trasferimento.find('[name="QtaRilevata"]').val(Number((materiale.Consumo > (materiale.QtaTrasferita + materiale.QtaDaTrasferire) ? materiale.Consumo - (materiale.QtaTrasferita + materiale.QtaDaTrasferire) : 0).toFixed(2)));

    //Reset mancante
    ActivePageDOM().querySelector("input[data-bind='Mancante']").checked = false;

    // Label della linea
    // Ubind e bind del click
    var lblCd_xMOLinea = trasferimento.find('label[data-bind="Cd_xMOLinea"]');
    $(lblCd_xMOLinea).text(materiale.Cd_xMOLinea);
    $(lblCd_xMOLinea).unbind('click');
    $(lblCd_xMOLinea).click(function () {
        trasferimento.find('input[data-bind="Cd_xMOLinea"]').val(materiale.Cd_xMOLinea);
    });

    // Carico le unità di misura
    Ajax_xmofn_ARARMisura('', '');

    // Switch dei div
    $(ActivePage()).find('[data-key="Lista"]').hide();
    $(ActivePage()).find('[data-key="Trasferimento"]').show();

    // Focus
    if (materiale.Consumo > materiale.QtaTrasferita)
        SetFocus();
    else
        $(ActivePage()).find('[name="QtaRilevata"]').focus().select();
}

function PRMPMateriale_Load() {
    // Select delle linee di produzione
    var select = $(ActivePage()).find('select[data-bind="Cd_xMOLinea"]');

    // Rimuovo le linee dal combo
    $(ActivePage()).find('select[data-bind="Cd_xMOLinea"]').find('option[value!=""]').remove();

    // Aggiungo le linee di produzione al combo
    oPrg.PRMP.dtLinea.map(function (item) { return item.Cd_xMOLinea }).forEach(function (item) {
        var option = document.createElement('option');
        option.setAttribute('value', item);
        $(option).text(item);
        $(select).append(option);
    });

    if (oPrg.PRMP.keyLinea != null)
        $(ActivePage()).find('select[data-bind="Cd_xMOLinea"] option').eq(oPrg.PRMP.keyLinea + 1).prop('selected', true);

    // Carico la tabella
    PRMPMateriale_Load_Table();

    // Switch dei div
    PRMPMateriale_Show_Lista();
}

function PRMPMateriale_Show_Lista() {
    $(ActivePage()).find('[data-key="Input"]').hide();
    $(ActivePage()).find('[data-key="Bolle"]').hide();
    $(ActivePage()).find('[data-key="Lista"]').show();
}

function PRMPMateriale_Load_Table() {
    // Tabella dei materiali
    var table = $(ActivePage()).find('table[data-key="Materiali"]');

    // Resetto il rolling
    $(table).setData('data-rolling-active', parseInt($(table).attr('data-rolling-first')));

    // Rimuovo le righe
    $(table).find('tr.tr-rig').remove();

    // Template della riga
    var template = $(table).find('tr.template').clone().removeClass("template").removeAttr("style").addClass("tr-rig");

    // Aggiungo le righe alla tabella
    if (oPrg.PRMP.dt) {
        oPrg.PRMP.dt.forEach(function (item, idx) {
            var tr = $(template).clone();
            $(tr).find('[data-bind="Cd_AR"]').text(item.Cd_AR);
            $(tr).find('[data-bind="Cd_ARLotto"]').text(item.Cd_ARLotto);
            $(tr).find('[data-bind="Cd_DoSottoCommessa"]').text(item.Cd_DoSottoCommessa);

            var link = document.createElement('a');
            link.href = "#";
            link.appendChild(document.createTextNode(item.Quantita + ' ' + item.Cd_ARMisura));

            $(tr).find('[data-bind="Quantita"]').append(link);
            $(tr).find('[data-bind="BL"]').text(item.BL);

            // Binding click: Rettifica
            $(tr).find('[data-bind="Quantita"]').click(function () {
                oPrg.PRMP.key = idx;
                PRMPMateriali_RienRettTras_Load('Rettifica');
            });

            // Binding click: Rientro
            $(tr).find('[data-key="Rientro"]').click(function () {
                oPrg.PRMP.key = idx;
                PRMPMateriali_RienRettTras_Load('Rientro');
            });

            if (item.BL) {
                // Binding click: Trasferimento
                $(tr).find('[data-key="Trasferimento"]').click(function () {
                    oPrg.PRMP.key = idx;
                    Ajax_xmofn_xMOPRBLMateriali_4BL();
                });
            } else {
                $(tr).find('[data-key="Trasferimento"] i.mi').hide();
            }

            $(table).append(tr);
        });
        $(table).show();
    } else {
        $(table).hide();
    }
}

function PRMPMateriali_RienRettTras_Load(mode) {
    // Materiale
    var materiale = oPrg.PRMP.ActiveRecord();

    // Div degli input
    var page = $(ActivePage()).find('[data-key="Input"]');

    // Pulisco tutti gli input
    $(page).find('input, textarea').val('');
    $(page).find('input[type="checkbox"]').prop('checked', false);

    // Assegno la modalità (Rientro, Rettifica, Trasferimento)
    $(page).attr('data-mode', mode);

    // Mostro i valori sulla pagina
    $(page).find('label[data-bind="Cd_AR"]').text(materiale.Cd_AR);
    $(page).find('input[data-bind="Cd_AR"]').val(materiale.Cd_AR);
    $(page).find('[data-bind="Cd_ARLotto"]').text(materiale.Cd_ARLotto);
    $(page).find('[data-bind="Descrizione"]').text(materiale.Descrizione);
    $(page).find('[data-bind="Quantita_A"]').val(materiale.Quantita);
    $(page).find('[data-bind="Cd_MG_P"]').text(materiale.Cd_MG_P);
    $(page).find('[data-bind="Cd_MGUbicazione_P"]').text(materiale.Cd_MGUbicazione_P);
    $(page).find('[data-bind="Cd_MG_A"]').text(materiale.Cd_MG_A);

    // Carico le unità di misura
    Ajax_xmofn_ARARMisura('', '');

    switch (mode) {
        case 'Rientro':
            // Intestazione
            $(page).find('.mo-intestazione label').text("RIENTRO IN MAGAZZINO");

            // Mostro i campi
            $(page).find('[data-key="MG_P"], [data-key="MG_A"], [data-key="MGUbicazione_A"], .ckCompleta').show();
            $(page).find('[data-key="xMOLinea"]').hide();

            // Recupero l'ubicazione proposta
            var ubicazione = Ajax_xmosp_xMOMGUbicazione_Ricerca(materiale.Cd_AR, 0, materiale.Cd_MG_A, null);

            // Label della linea
            var lblCd_MGUbicazione_A = $(page).find('label[data-bind="Cd_MGUbicazione_A"]');
            $(lblCd_MGUbicazione_A).text(ubicazione.Cd_MGUbicazione);
            $(lblCd_MGUbicazione_A).unbind('click');
            $(lblCd_MGUbicazione_A).click(function () {
                $(page).find('input[data-bind="Cd_MGUbicazione_A"]').val(ubicazione.Cd_MGUbicazione);
            });

            // Bind e Unbind sul Conferma
            $(page).find('button.btn-confirm').unbind('click');
            $(page).find('button.btn-confirm').click(function () {
                Ajax_xmosp_xMOPRTRMateriale_Back();
            });
            break;
        case 'Rettifica':
            // Intestazione
            $(page).find('.mo-intestazione label').text("RETTIFICA QUANTITÀ");

            // Nascondo i campi
            $(page).find('[data-key="MG_P"], [data-key="MG_A"], [data-key="MGUbicazione_A"], [data-key="xMOLinea"], .ckCompleta').hide();

            // Bind e Unbind sul Conferma
            $(page).find('button.btn-confirm').unbind('click');
            $(page).find('button.btn-confirm').click(function () {
                Ajax_xmosp_xMOPRTRMateriale_Drop();
            });
            break;
        case 'Trasferimento':
            // Bolla su cui trasferire
            var bolla = oPrg.PRMP.ActiveBolla();

            // Intestazione
            $(page).find('.mo-intestazione label').text("TRAFERIMENTO PER BOLLA " + bolla.Bolla);

            // Quantita_A
            $(page).find('[data-bind="Quantita_A"]').val(bolla.Quantita < materiale.Quantita ? bolla.Quantita : materiale.Quantita);

            // Mostro i campi
            $(page).find('[data-key="MG_P"], [data-key="MG_A"], [data-key="xMOLinea"]').show();
            $(page).find('[data-key="MGUbicazione_A"], .ckCompleta').hide();

            // Label della linea
            var lblCd_xMOLinea = $(page).find('label[data-bind="Cd_xMOLinea"]');
            $(lblCd_xMOLinea).text(oPrg.PRMP.ActiveBolla().Cd_xMOLinea);
            $(lblCd_xMOLinea).unbind('click');
            $(lblCd_xMOLinea).click(function () {
                $(page).find('input[data-bind="Cd_xMOLinea"]').val(oPrg.PRMP.ActiveBolla().Cd_xMOLinea);
            });

            // Bind e Unbind sul Conferma
            $(page).find('button.btn-confirm').unbind('click');
            $(page).find('button.btn-confirm').click(function () {
                Ajax_xmosp_xMOPRTRMateriale_ToBL();
            });
            break;
    }

    // Switch dei div
    $(ActivePage()).find('[data-key="Lista"]').hide();
    $(ActivePage()).find('[data-key="Bolle"]').hide();
    $(ActivePage()).find('[data-key="Input"]').show();

    // Focus
    SetFocus();
}

function PRMPMateriali_Bolle_Load() {
    // Intestazione
    $(ActivePage()).find('[data-key="Bolle"] .mo-intestazione label').text("BOLLE UTILI PER " + oPrg.PRMP.ActiveRecord().Cd_AR);

    // Lista degli elementi
    var ul = $(ActivePage()).find("[data-key='Bolle'] ul");

    // Rimuovo gli elementi
    $(ul).find("li.bolla").remove();

    // Template dell'elemento
    var template = $(ul).find("li.template").clone().removeClass("template").removeAttr("style").addClass("bolla");

    // Copia del dt
    var dt = oPrg.PRMP.dt4BL.slice();

    // Ricerca
    var searchQuery = $(ActivePage()).find('[data-key="Bolle"] input[data-bind="SearchQuery"]').val();

    // Filtro il dt
    if (!fU.IsEmpty(searchQuery)) {
        // Formatto il valore
        searchQuery = searchQuery.toLowerCase();
        // Filtro gli elementi
        dt = dt.filter(function (item) {
            return item.Bolla.toLowerCase().includes(searchQuery)
                || item.Cd_xMOLinea.toLowerCase().includes(searchQuery)
                || item.Descrizione.toLowerCase().includes(searchQuery);
        });
    }

    // Per ogni elemento
    dt.forEach(function (item, idx) {
        // Clono il template
        var li = $(template).clone();
        // Imposto i valori
        $(li).find('[data-bind="Id_PrBL"]').html(item.Id_PrBL);
        $(li).find('[data-bind="Bolla"]').html("Bolla " + item.Bolla);
        $(li).find('[data-bind="Quantita"]').html(item.Quantita + " " + item.Cd_ARMisura);
        $(li).find('[data-bind="Cd_xMOLinea"]').html(item.Cd_xMOLinea);
        $(li).find('[data-bind="DataObiettivo"]').html(fU.ToLocaleDate(item.DataObiettivo));
        $(li).find('[data-bind="Descrizione"]').html(item.Descrizione);
        $(li).on('click', function () {
            oPrg.PRMP.keyBolla = idx;
            PRMPMateriali_RienRettTras_Load('Trasferimento');
        });
        // Aggiungo l'elemento alla lista
        $(ul).append(li);
    });

    // Switch dei div
    $(ActivePage()).find('[data-key="Lista"]').hide();
    $(ActivePage()).find('[data-key="Bolle"]').show();
}

function Detail_NotePiede_Load(dt) {

    if (dt.length > 0) {
        $("#Detail_NotePiede .mo-msg").hide();
        var li = $("#Detail_NotePiede .template").clone().removeAttr("style").addClass("li-note");
        for (var i = 0; i < dt.length; i++) {
            $("#Detail_NotePiede ul").append(Detail_NotePiede_Template(li.clone(), dt[i], i));
        }
    }
    else {
        $("#Detail_NotePiede .mo-msg").text("Nessuna nota presente").show();
    }
}

// -------------------------------------------------
// ENDREGION: Funzioni Load
// -------------------------------------------------
// -------------------------------------------------
// #1.50 REGION: TEMPLATE
// -------------------------------------------------

function ARDesc_Template(obj, AR, ARDesc) {
    obj.attr("Cd_AR", AR);
    obj.find(".Descrizione").text(ARDesc);

    return obj;
}

function Search_Articolo_Template(li, item, key) {
    li.attr("Cd_AR", item.Cd_AR);
    li.attr("Cd_ARMisura", item.Cd_ARMisura);
    li.attr("AR_Desc", item.Descrizione);
    li.find("label").html(item.Cd_AR + "&nbsp;-&nbsp;" + item.Descrizione);

    return li;
}

function Search_ARLotto_Template(li, item, key) {

    li.attr("Cd_AR", item.Cd_AR);
    li.attr("Cd_ARLotto", item.Cd_ARLotto);
    li.attr("Cd_MG", item.Cd_MG);
    li.attr("Cd_MGUbicazione", item.Cd_MGUbicazione);

    fU.ShowIf(li.find(".qta-lotto"), !fU.IsEmpty(item.Quantita));
    fU.ShowIf(li.find(".cdubi-lotto"), !fU.IsEmpty(item.Cd_MGUbicazione));

    li.find(".cd-lotto").text(item.Cd_ARLotto);
    li.find(".desc-lotto").text(item.Descrizione);
    li.find(".ar-lotto").text(item.Cd_AR);
    li.find(".qta-lotto").html("GIACENZA:&nbsp;" + item.Quantita + "&nbsp;" + item.Cd_ARMisura);
    li.find(".cdubi-lotto").html("UBICAZIONE:&nbsp;" + item.Cd_MGUbicazione);

    return li;

}

function Search_Spedizione_Template(li, item, key) {
    li.attr("Cd_xMOCodSpe", item.Cd_xMOCodSpe);

    li.find(".sp").html(item.Cd_xMOCodSpe + '&nbsp;-&nbsp;' + item.Descrizione);
    li.find(".sp-ndocs").text("Num. Doc.: " + item.NDocs);

    return li;
}

function Search_xListaCarico_Template(li, item, key) {
    li.attr("xListaCarico", item.xListaCarico);

    li.find(".ldc").text(item.xListaCarico);
    li.find(".ldc-ndocs").text("Num. Doc.: " + item.NDocs);

    return li;
}

function Search_CF_Template(li, item, key) {

    li.attr("Cd_CF", item.Cd_CF);
    li.attr("Destinazioni", item.Destinazioni);
    li.attr("CFDest_Default", item.CFDest_Default);
    li.attr("Descrizione", item.Descrizione);
    li.attr("CFDest_Descrizione", item.CFDest_Descrizione);
    li.attr("HaPrelievi", item.HaPrelievi);

    li.find(".cd-cf").html(item.Cd_CF + "&nbsp;-&nbsp;");
    if (item.HaPrelievi == true) {
        li.addClass("w3-text-black");
    }
    li.find(".desc-cf").text(item.Descrizione); //(item.Descrizione).length > 40 ? item.Descrizione.substring(0, 35) + '...' : item.Descrizione);

    li.find(".detail").attr("Cd_CF", item.Cd_CF);

    li.find(".detail").on("click", function () {
        Detail_Ajax_xmovs_CF($(this).attr("Cd_CF"));
    });

    li.on("click", function (event) {
        //Verifico che l'elemento che ha scatenato il click sia il li e non un'icona
        if (!$(event.target).hasClass("detail")) {
            Search_Close($(this));
        }
    });

    return li;
}

function Search_CFDest_Template(li, item, key) {

    li.attr("Cd_CFDest", item.Cd_CFDest);
    li.attr("Descrizione", item.Descrizione);
    li.attr("Cd_CF", item.Cd_CF);
    li.attr("CF_Descrizione", item.CF_Descrizione);

    li.find(".cd-cfdest").text(item.Cd_CFDest);
    li.find(".desc-cfdest").text(item.Descrizione);
    li.find(".cd-cf").text(item.Cd_CF + '-' + item.CF_Descrizione);

    li.find(".detail").attr("Cd_CFDest", item.Cd_CFDest);

    li.find(".detail").on("click", function () {
        Detail_Ajax_xmovs_CFDest($(this).attr("Cd_CFDest"));
    });

    li.on("click", function (event) {
        //Verifico che l'elemento che ha scatenato il click sia il li e non un'icona
        if (!$(event.target).hasClass("detail")) {
            Search_Close($(this));
        }
    });

    return li;
}

function Search_MG_Template(li, item, key) {

    li.attr("Cd_MG", item.Cd_MG);
    li.find("label").html(item.Cd_MG + "&nbsp;-&nbsp;" + item.Descrizione);

    return li;
}

function Search_MGUbicazione_Template(li, item, key) {

    li.attr("Cd_MGUbicazione", item.Cd_MGUbicazione);
    li.attr("StatoGiac", item.StatoGiac);
    li.attr("Cd_MG", item.Cd_MG);
    li.find("i").attr("Cd_MGUbicazione", item.Cd_MGUbicazione);

    li.find(".cd_mgubicazione").html(item.Cd_MGUbicazione + '&nbsp;-&nbsp;' + item.Cd_MG);
    li.find(".statogiac").css("background-color", item.StatoGiac == 1 ? "orange" : "green");
    // "&nbsp;-&nbsp;" + item.Descrizione

    li.find("i").on("click", function () {
        event.stopPropagation();
        Detail_Ajax_xmofn_MGUbicazioneAR_Giac($(this).attr("Cd_MGUbicazione"));
    });

    if (fU.ToBool(item.DefaultMGUbicazione) == true) {
        li.append("<i class='w3-right w3-margin-right mi s20' title='Default ubicazione'>star</i>");
    }
    return li;
}

function Search_DOSottoCommessa_Template(li, item, key) {

    li.attr("Cd_DOSottoCommessa", item.Cd_DOSottoCommessa);
    var sCd_DOCommessa = "";
    if (item.Cd_DOCommessa && (item.Cd_DOCommessa).trim().length > 0) {
        sCd_DOCommessa = "&nbsp;<small>[" + (item.Cd_DOCommessa).trim() + "]</small>";
    }

    li.find("label").html(item.Cd_DOSottoCommessa + "&nbsp;-&nbsp;" + item.Descrizione + sCd_DOCommessa);

    return li;
}

function Search_DOCaricatore_Template(li, item, key) {

    li.attr("Cd_DOCaricatore", item.Cd_DOCaricatore);
    li.attr("Desc", item.Descrizione);

    li.find("label").html(item.Cd_DOCaricatore + "&nbsp;-&nbsp;" + item.Descrizione);

    return li;
}

function Search_ARARMisura_Template(li, item, key) {

    li.attr("Cd_ARMisura", item.Cd_ARMisura);

    li.find("label").html(item.Cd_ARMisura);

    return li;
}

function DOAperti_Template(li, item, key) {

    //assegno il programma alla varibile corretta di Id_xMO -- RL o TR
    switch (item.Tipo) {
        case 'TR':
            li.attr('prgexe', item.xCd_xMOProgramma).attr('cd_do', "").attr("prgid", item.Id_xMOTR);
            li.find(".id").text(item.Id_xMOTR);
            if (item.xCd_xMOProgramma == 'TI')
                li.find(".cd-do").text("Tra.Int.");
            else
                li.find(".cd-do").text("Stoccaggio");
            break;
        case 'RL':
            li.attr('prgexe', item.xCd_xMOProgramma).attr('cd_do', item.Cd_DO).attr("prgid", item.Id_xMORL);
            li.find(".cd-do").text(item.Cd_DO);
            li.find(".id").text(item.Id_xMORL);
    }

    var do_info = "";
    //do_info = " del " + fU.DateJsonToDate(item.DataDoc).substring(0, 10)
    do_info = " del " + fU.DateToLocalDateString(item.DataDoc).substring(0, 10)
    if (item.P_DoN > 0) do_info += " (con prelievo)";
    li.find(".do-info").text($.trim(do_info));

    var cf_desc = "";
    cf_desc = "Cliente: " + item.Cd_CF + " - " + item.CF_Descrizione;
    li.find(".cf-info").text($.trim(cf_desc));

    var do_exte = "";
    if (!fU.IsEmpty(item.NumeroDocRif)) do_exte = do_exte.concat(" Rif. Doc. " + item.NumeroDocRif);
    if (!fU.IsEmpty(item.DataDocRif)) do_exte = do_exte.concat(" Del " + fU.DateToLocalDateString(item.DataDocRif));
    //if (!fU.IsEmpty(fU.DateToLocalDateString(item.DataDocRif))) do_exte = do_exte.concat(" Del " + fU.DateToLocalDateString(item.DataDocRif));
    //if (!fU.IsEmpty(fU.DateJsonToDate(item.DataDocRif))) do_exte = do_exte.concat(" Del " + fU.DateJsonToDate(item.DataDocRif).substring(0, 10));
    if (!fU.IsEmpty(item.Cd_xMOCodSpe)) do_exte = do_exte.concat(" - Spedizione " + item.Cd_xMOCodSpe);
    if (!fU.IsEmpty(item.Targa)) do_exte = do_exte.concat(" - Targa " + item.Targa);
    if (!fU.IsEmpty(item.Cd_DOCaricatore)) do_exte = do_exte.concat(" - Caricatore " + item.Cd_DOCaricatore);
    do_exte = do_exte.concat(" N° letture " + item.R_Tot);
    if (!fU.IsEmpty(item.ListenerErrore)) {
        do_exte = do_exte.concat('<br /><span class="w3-text-red">' + item.ListenerErrore + '</span>');
    }
    li.find(".do-rows-info").html($.trim(do_exte));

    if (item.Stato == 1) {
        //Documento chiuso ma non ancora creato (non può essere modificato ne eliminato)
        li.addClass("mo-yellow").removeClass("mo-pointer w3-hover-light-gray").find("i").hide();
    }
    else {
        // Se cd_do è vuoto è un trasferimento
        if (fU.IsEmpty(item.Cd_DO)) {
            li.on("click", function () {
                DocAperti_TRClickIt($(this));
            });
        }
        else {
            li.on("click", function () {
                DocAperti_RLClickIt($(this));
            });
        }
    }

    return li;
}

function DORistampa_Template(li, item, key) {

    fU.ShowIf($(li).find(".div-dest"), !fU.IsEmpty(item.Cd_CFDest));

    li.find(".id-dotes").text(item.Id_DOTes);
    li.find(".cd-do").text(item.Cd_DO);
    li.find(".do-info").text(item.DO_Descrizione);
    li.find(".cf-info").text(fU.IfEmpty(item.Cd_CF) + " - " + fU.IfEmpty(item.CF_Descrizione));
    li.find(".cd-cfdest").text(item.Cd_CFDest + " - " + item.CFDest_Descrizione);
    li.find(".datadoc").text(fU.formatDateDDMMYYYY(item.DataDoc));
    //li.find(".datadoc").text(fU.DateJsonToDate(item.DataDoc));

    li.on("click", function () {
        $("#pgDocRistampa label[name='Cd_DO']").text(item.Cd_DO);
        $("#pgDocRistampa label[name='Id_DOTes']").text(item.Id_DOTes);
        $("#pgDocRistampa label[name='Id_xMORL_Edit']").text(item.Id_xMORL);
        Nav.Next();
    });

    return li;
}

// Template doc prelevabili partendo da una DOTes
function DOPrel_Template(tr, item, key) {

    tr.attr("key", item.Id_DOTes)

    //Assegna i filtri alla riga UPPERCASE
    tr.attr("F_Doc", item.F_Doc.toUpperCase()).attr("F_Cd_ARs", item.F_Cd_ARs.toUpperCase());
    //Assegna i valori dei doc 
    tr.find(".ck-documenti").prop("checked", false);
    tr.find(".ck-documento").attr("Id_DOTes", item.Id_DOTes).prop("checked", item.Selezionato);
    tr.find(".Cd_DO").text(item.Cd_DO);
    tr.find(".N_DORig").text(item.N_DORig);
    tr.find(".NumeroDoc").text(item.NumeroDoc);
    tr.find(".DataDoc").text(fU.DateToLocalDateString(item.DataDoc));
    //tr.find(".DataDoc").text(fU.DateJsonToDate(item.DataDoc));
    tr.find(".Cd_MGEsercizio").text(item.Cd_MGEsercizio);
    //tr.find(".Cd_DOSottoCommessa").text(item.Cd_DOSottoCommessa);

    tr.find(".Cd_DO").on("click", function () {
        // Carica i dati del detail
        Detail_Ajax_xmovs_DOTes(item.Id_DOTes);
        $("#DetailDO").show();
    });

    //Se il documento è già stato prelevato disabilito la riga
    if (!fU.IsNull(item.PrelevatoDa)) {
        tr.css("background-color", "#E0E0E0").find(".ck-documento").removeClass("mo-pointer").prop("disabled", "disabled");
        //Se il documento non è stato prelevato da me è NON PRELEVABILE
        if (item.Selezionato == false) {
            tr.addClass("non-prelevabile");
        }
    }
    return tr;
}

// Template di tutti i documenti prelevabili 
function DOPrel_All_Template(li, item, key) {

    fU.ShowIf(li.find(".numerodoc"), !fU.IsEmpty(item.NumeroDoc));
    fU.ShowIf(li.find(".datadoc"), !fU.IsEmpty(item.DataDoc));
    fU.ShowIf(li.find(".dataconsegna"), !fU.IsEmpty(item.DataConsegna));

    li.find(".ck-documento").attr("Id_DOTes", item.Id_DOTes).attr("Cd_DOs", item.Cd_DOs).prop("checked", item.Selezionato);;

    li.find(".id-dotes").text(item.Id_DOTes);
    li.find(".cd-do").text(item.Cd_DO);
    li.find(".do-desc").text(item.DO_Descrizione);
    li.find(".cd-cf").text(item.Cd_CF + " - " + item.CF_Descrizione);
    li.find(".numerodoc").html("N.Documento: " + item.NumeroDoc + "&nbsp;&nbsp;&nbsp;");
    li.find(".datadoc").text("DEL: " + fU.DateToLocalDateString(item.DataDoc));


    // do_sottocommessa_descrizione DOSottoCommessa_Descrizione
    if (item.DOSottoCommessa_Descrizione) {
        li.find(".do_sottocommessa_descrizione").text('SOTTOCOMMESSA: ' + item.Cd_DOSottoCommessa + ' - ' + item.DOSottoCommessa_Descrizione).show().prev().show();
    } else {
        li.find(".do_sottocommessa_descrizione").hide().prev().hide();
    }

    //li.find(".datadoc").text("DEL: " + fU.DateJsonToDate(item.DataDoc));
    li.find(".dataconsegna").text("CONSEGNA IL: " + fU.DateToLocalDateString(item.DataConsegna));
    //li.find(".dataconsegna").text("CONSEGNA IL: " + fU.DateJsonToDate(item.DataConsegna));

    li.find(".cd-do").on("click", function () {
        // Carica i dati del detail
        Detail_Ajax_xmovs_DOTes(item.Id_DOTes);
        $("#DetailDO").show();
    });

    //Se il documento è già stato prelevato disabilito la riga
    if (!fU.IsNull(item.PrelevatoDa)) {
        li.css("background-color", "#E0E0E0").find(".ck-documento").removeClass("mo-pointer").prop("disabled", "disabled");
        //Se il documento non è stato prelevato da me è NON PRELEVABILE
        if (item.Selezionato == false) {
            li.addClass("non-prelevabile");
        }
    }

    return li;
}

// Template della Spedizione
function Spedizione_Template(tr, item, key) {

    tr.attr("Id_DOTes", item.Id_DOTes);
    tr.attr("Cd_xMOCodSpe", item.xCd_xMOCodSpe);

    tr.find(".Cd_xMOCodSpe").text(item.xCd_xMOCodSpe);
    tr.find(".Cd_DO").text(item.Cd_DO);
    tr.find(".Cd_DO").on("click", function () {
        Detail_Ajax_xmovs_DOTes(item.Id_DOTes);
        $("#DetailDO").show();
    });

    tr.find(".Cd_CF").text(item.Cd_CF);
    tr.find(".NumeroDoc").text(item.NumeroDoc);
    //DEPRECATA tr.find(".DataDoc").text(fU.DateJsonToDate(item.DataDoc));
    tr.find(".DataSpedizione").text(fU.ToStandardDate(item.DataSpedizione));
    //tr.find(".DataSpedizione").text(fU.DateJsonToDate(item.DataSpedizione));
    tr.find(".Cd_MGEsercizio").text(item.Cd_MGEsercizio);
    //Imposta l'attributo identificativo del doc e della lista di carico
    tr.find(".ck-sp").attr("Id_DOTes", item.Id_DOTes);
    tr.find(".ck-sp").attr("Cd_xMOCodSpe", item.xCd_xMOCodSpe);
    //Imposta l'attributo documenti generabili dalla ldc
    tr.find(".ck-sp").attr("Cd_DOs", item.Cd_DOs);
    tr.attr("title", item.Id_DOTes);

    //Gestione errori prelevabilità
    var err_msg = "";
    //1) La riga è prelevata da altri doc
    if (!fU.IsEmpty(item.PrelevatoDa)) err_msg += "Documento prelevato da:<br />" + item.PrelevatoDa + "<br />";
    //2) La riga non ha documenti definiti in arca per il prelievo
    if (fU.IsEmpty(item.Cd_DOs)) err_msg += "Documento non correttamente configurato con i documenti di prelievo di Arca!<br />";

    if (!fU.IsEmpty(err_msg)) {
        tr.find("i").on("click", function () {
            PopupMsg_Show("info", "1", err_msg);
        });
    }
    fU.ShowIf(tr.find("i"), !fU.IsEmpty(err_msg));
    fU.ShowIf(tr.find("input"), fU.IsEmpty(err_msg));

    return tr;
}

// Pers: Template delle liste di carico 
function xListaCarico_Template(tr, item, key) {

    tr.attr("Id_DOTes", item.Id_DOTes);
    tr.attr("xListaCarico", item.xListaCarico);

    tr.find(".xListaCarico").text(item.xListaCarico);
    tr.find(".Cd_DO").text(item.Cd_DO);
    tr.find(".Cd_DO").on("click", function () {
        Detail_Ajax_xmovs_DOTes(item.Id_DOTes);
        $("#DetailDO").show();
    });

    tr.find(".Cd_CF").text(item.Cd_CF);
    tr.find(".NumeroDoc").text(item.NumeroDoc);
    tr.find(".DataDoc").text(fU.ToStandardDate(item.DataDoc));
    //tr.find(".DataDoc").text(fU.DateJsonToDate(item.DataDoc));
    tr.find(".Cd_MGEsercizio").text(item.Cd_MGEsercizio);
    //Imposta l'attributo identificativo del doc e della lista di carico
    tr.find(".ck-ldc").attr("Id_DOTes", item.Id_DOTes);
    tr.find(".ck-ldc").attr("xListaCarico", item.xListaCarico);
    //Imposta l'attributo documenti generabili dalla ldc
    tr.find(".ck-ldc").attr("Cd_DOs", item.Cd_DOs);
    tr.attr("title", item.Id_DOTes);

    //Gestione errori prelevabilità
    var err_msg = "";
    //1) La riga è prelevata da altri doc
    if (!fU.IsEmpty(item.PrelevatoDa)) err_msg += "Documento prelevato da:<br />" + item.PrelevatoDa + "<br />";
    //2) La riga non ha documenti definiti in arca per il prelievo
    if (fU.IsEmpty(item.Cd_DOs)) err_msg += "Documento non correttamente configurato con i documenti di prelievo di Arca!<br />";

    if (!fU.IsEmpty(err_msg)) {
        tr.find("i").on("click", function () {
            PopupMsg_Show("info", "1", err_msg);
        });
    }
    fU.ShowIf(tr.find("i"), !fU.IsEmpty(err_msg));
    fU.ShowIf(tr.find("input"), fU.IsEmpty(err_msg));

    return tr;
}

function pgRLRig_AR_Template(tr, item, key) {
    var W44716 = 44716; // per fare le prove sostituire con il proprio nuero di licenza

    //Al click del bottone UM della lista delle letture/prelievi imposto il codice articolo e l'UM della riga corrente nei campi imput della pagina
    tr.find('.Cd_ARMisura').on("click", function () {
        // UM da assegnare: sarà il change di AR a prendere il default
        $("#" + oPrg.ActivePageId + " select[name='Cd_ARMisura']").attr("um2set", tr.find(".Cd_ARMisura").text());
        //Articolo
        $("#pgRLRig input[name='Cd_AR']").val(tr.find(".Cd_AR").text()).change();


        if (oApp.LicF_Id == W44716) {
            if (oApp.dtDO[oPrg.drRL.Cd_DO].MagPFlag == true) {
                $("#pgRLRig input[name='Cd_MGUbicazione_P']").val(tr.find(".Cd_MGUbicazione").text()).change();
            } else if (oApp.dtDO[oPrg.drRL.Cd_DO].MagAFlag == true) {
                $("#pgRLRig input[name='Cd_MGUbicazione_A']").val(tr.find(".Cd_MGUbicazione").text()).change();
            }
        }

    });

    tr.attr("key", key);
    tr.find(".Cd_AR").text(item.Cd_AR);
    if (item.Quantita >= item.QtaEvadibile) {
        tr.find(".Cd_ARMisura").attr("style", "background-color: lightgrey");
    }
    tr.find(".Descrizione").text(item.Descrizione);
    if (oApp.LicF_Id == W44716) {
        tr.find(".Cd_MGUbicazione").text(item.ExtField);
    }

    //tr.find(".Cd_ARLotto").text(fU.ToString(item.Cd_ARLotto));
    tr.find(".Cd_ARMisura").text(item.Cd_ARMisura);
    //if 
    tr.find(".Quantita").text(item.Quantita);

    tr.find(".QtaEvadibile").text(item.QtaEvadibile);

    return tr;
}

function pgRLRig_ARDesc_Template(tr, item, key) {
    tr.attr("key", key);
    tr.attr("Cd_AR", item.Cd_AR);
    if (item.Quantita >= item.QtaEvadibile) {
        tr.find(".Cd_ARMisura").attr("style", "background-color: lightgrey");
    }
    tr.find(".Descrizione").text(item.Descrizione);

    var W44716 = 44716; // per fare le prove sostituire con il proprio nuero di licenza
    if (oApp.LicF_Id == W44716) {
        tr.find(".Cd_MGUbicazione").text(item.ExtField);
    }

    return tr;
}

function SMRig_TAARDesc_Template(tr, item, key) {
    tr.attr("Id_xMOTRRig_T", item.Id_xMOTRRig_T);
    tr.attr("Cd_AR", item.Cd_AR);
    tr.find(".Descrizione").text(item.Descrizione);

    tr.on("click", function () {
        oPrg.SM.Id_xMOTRRig_T = $(this).attr("Id_xMOTRRig_T");
        Nav.Next();
    });

    return tr;
}

function pgTRRig_P_AR_Template(tr, item, key) {
    tr.find('.Cd_ARMisura').on("click", function () {
        // UM da assegnare: sarà il change di AR a prendere il default
        $("#" + oPrg.ActivePageId + " select[name='Cd_ARMisura']").attr("um2set", tr.find(".Cd_ARMisura").text());
        //Articolo
        ActivePage().find("input[name='Cd_AR']").val(tr.find(".Cd_AR").text()).change();
    });

    tr.find(".Cd_AR").text(item.Cd_AR);
    tr.find(".Cd_ARLotto").text(fU.ToString(item.Cd_ARLotto));
    tr.find(".Cd_ARMisura").text(item.Cd_ARMisura);
    tr.find(".Quantita").text(item.Quantita);
    tr.find(".Cd_MG_P").text(item.Cd_MG_P);
    return tr;
}

function pgTRRig_A_AR_Template(tr, item, key) {

    tr.find('.Cd_ARMisura').on("click", function () {
        // UM da assegnare: sarà il change di AR a prendere il default
        $("#" + oPrg.ActivePageId + " select[name='Cd_ARMisura']").attr("um2set", item.Cd_ARMisura);
        //Articolo
        ActivePage().find("input[name='Cd_AR']").attr("Id_xMOTRRig_P", item.Id_xMOTRRig_P).val(item.Cd_AR).change();
    });

    tr.find(".Cd_AR").text(item.Cd_AR);
    tr.find(".Cd_ARLotto").text(fU.ToString(item.Cd_ARLotto));
    tr.find(".Cd_ARMisura").text(item.Cd_ARMisura);
    tr.find(".Quantita").text(item.Quantita_A);
    tr.find(".Residua").text(item.Quantita_R)
    tr.find(".Cd_MG_P").text(item.Cd_MG_P);

    return tr;
}

function Detail_ARGiacenza_Template(tr, item, key) {

    tr.attr("StatoGiac", item.Quantita > 0 ? 1 : 0);
    tr.attr("Cd_MGUbicazione", item.Cd_MGUbicazione);

    tr.find(".Cd_MG").text(item.Cd_MG);
    tr.find(".Cd_ARLotto").text(item.Cd_ARLotto);
    tr.find(".Cd_DOSottoCommessa").text(item.Cd_DOSottoCommessa);
    //tr.find(".Descrizione").text(item.Descrizione);
    tr.find(".Cd_MGUbicazione").text(item.Cd_MGUbicazione);
    tr.find(".Quantita").text(item.Quantita);
    tr.find(".QuantitaDImm").text(item.QuantitaDImm);
    tr.find(".QuantitaDisp").text(item.QuantitaDisp);

    // Colora l'UBI di default 
    if (item.DefaultMGUbicazione)
        tr.css("background-color", "#E5FF67");

    tr.click(function () {
        // Retrocompatibilità
        var inputubi = $("#DetailARGiacenza").attr("data-inputubi");
        if (inputubi) {
            // Setto il valore sul DOM
            $(ActivePage()).find('input[name="' + inputubi + '"]').val(item.Cd_MGUbicazione);
            // Chiudo il detail
            $("#DetailARGiacenza").hide();
        } else {
            // Recupero il tipo di magazzino
            var MG = $("#DetailARGiacenza").attr("data-mg");

            MG = MG ? '_' + MG : '';

            // Elemento del DOM
            var targetDOM = null;

            // Setta i valori sul DOM
            targetDOM = $(ActivePage()).find('[data-bind="Cd_ARLotto"]');
            if ($(targetDOM).length > 0)
                setTargetVal(targetDOM, item.Cd_ARLotto);

            targetDOM = $(ActivePage()).find('[data-bind="Cd_MG' + MG + '"]');
            if ($(targetDOM).length > 0)
                setTargetVal(targetDOM, item.Cd_MG);

            targetDOM = $(ActivePage()).find('[data-bind="Cd_MGUbicazione' + MG + '"]');
            if ($(targetDOM).length > 0)
                setTargetVal(targetDOM, item.Cd_MGUbicazione);

            $("#DetailARGiacenza").hide();

            SetFocus();
        }
    });

    /*
    // Se l'icona che ha aperto il detail ha l'attributo data-inputubi allora assegno il click alle tr in modo da permettere la selezione dell'ubi direttamente dal detail
    if (!fU.IsEmpty($("#DetailARGiacenza").attr("data-inputubi")) || !fU.IsEmpty($("#DetailARGiacenza").attr("data-target"))) {
        tr.addClass("mo-pointer");
        tr.on("click", function () {
            var input = $("#DetailARGiacenza").attr("data-inputubi");
            $("#" + oPrg.ActivePageId + " input[name='" + input + "']").val($(this).attr("Cd_MGUbicazione")).focus();

            $("#DetailARGiacenza").hide();
        });
    }
    */

    // Setta il valore dell'elemento del DOM
    var setTargetVal = function (targetDOM, value) {
        switch ($(targetDOM).prop('tagName').toLowerCase()) {
            case 'input':
                $(targetDOM).val(value);
                break;
            default:
                $(targetDOM).text(value);
                break;
        }
    }

    return tr;
}

function Detail_UBIGiacenza_Template(tr, item) {

    tr.find(".Cd_MG").text(item.Cd_MG);
    tr.find(".Cd_AR").text(item.Cd_AR);
    tr.find(".Cd_ARMisura").text(item.Cd_ARMisura);
    tr.find(".Quantita").text(item.Quantita);
    tr.find(".QuantitaDImm").text(item.QuantitaDimm);
    tr.find(".QuantitaDisp").text(item.QuantitaDisp);

    return tr;
}

function Listener_Moduli_Template(li, item, key) {

    li.attr("RptDocName", item.RptDocName);

    // se check vien selezionato allora si imposta il numero di copie = 1
    li.find(".ck-stampa").on("click", function () {
        if (fU.IsChecked($(this))) {
            var copie = li.find("input[name='NumeroCopie']").val();
            fU.IsEmpty(copie) || fU.ToInt32(copie) == 0 ? li.find("input[name='NumeroCopie']").val("1") : "";
        }
        else
            li.find("input[name='NumeroCopie']").val("");
    });

    li.find("select[name='ListenerDevice']").on("change", function () {
        var copie = $(this).find("option:selected").attr('copie');
        if (fU.IsEmpty(copie)) {
            if (fU.IsChecked(li.find(".ck-stampa")))
                copie = 1;
            else
                copie = '';
        }
        li.find("input[name='NumeroCopie']").val(copie);
    });

    //Imposta la stampante da utilizzare (anche vuoto)
    li.find("select[Name='ListenerDevice']").val(fU.ToString(item.Device));
    //Descrizione del modulo
    li.find(".descrizione").text(item.Descrizione);
    //Copie da eseguire
    li.find("input[name='NumeroCopie']").val(item.NumeroCopie);
    //Attiva/Disattiva la stampa come per il modulo di Arca
    li.find(".ck-stampa").prop("checked", item.NumeroCopie == 0 ? false : true);

    return li;
}

function DetailCF_Template(item) {

    $("#DetailCF .cd-cf").text(item.Cd_CF + ' - ' + item.Descrizione);
    $("#DetailCF .indirizzo").text(fU.ToString(item.Indirizzo));
    $("#DetailCF .localita").text(fU.ToString(item.Localita));
    $("#DetailCF .cap").html(fU.ToString(item.Cap) + "&nbsp;" + fU.ToString(item.Cd_Provincia) + "&nbsp;" + fU.ToString(item.Cd_Nazione));
}

function DetailCFDest_Template(item) {

    fU.ShowIf($("#DetailCFDest .div-indirizzo"), !fU.IsEmpty(item.Indirizzo));
    fU.ShowIf($("#DetailCFDest .div-agente"), !fU.IsEmpty(item.Agente));
    fU.ShowIf($("#DetailCFDest .div-telefono"), !fU.IsEmpty(item.Telefono));

    $("#DetailCFDest .cd-cfdest").text(item.Cd_CFDest + ' - ' + item.Descrizione);
    $("#DetailCFDest .indirizzo").text(fU.ToString(item.Indirizzo));
    $("#DetailCFDest .localita").text(fU.ToString(item.Localita));
    $("#DetailCFDest .cap").html(fU.ToString(item.Cap) + "&nbsp;" + fU.ToString(item.Cd_Provincia) + "&nbsp;" + fU.ToString(item.Cd_Nazione));
    $("#DetailCFDest .agente").text(item.Agente);
    $("#DetailCFDest .telefono").text(item.Telefono);

}

function DetailDOTes_Template(item) {
    var d = $("#DetailDO");

    d.find(".doc-numero").html(item.Cd_DO + "&nbsp;" + item.NumeroDoc + " &nbsp;" + fU.DateToLocalDateString(item.DataDoc) + " &nbsp;[" + item.Id_DOTes + "]");
    //d.find(".doc-numero").html(item.Cd_DO + "&nbsp;" + item.NumeroDoc + " &nbsp;" + fU.DateJsonToDate(item.DataDoc) + " &nbsp;[" + item.Id_DOTes + "]");
    d.find(".cf-descrizione").html(item.Cd_CF + "&nbsp;" + item.CF_Descrizione);

    d.find(".indirizzo").html(fU.ToString(item.Indirizzo) + "&nbsp;" + fU.ToString(item.Localita) + "&nbsp;" + fU.ToString(item.Cap) + "&nbsp;" + fU.ToString(item.Cd_Provincia) + "&nbsp;" + fU.ToString(item.Cd_Nazione));
    d.find(".cd-mgesercizio").text(item.Cd_MGEsercizio);

    fU.ShowIf(d.find(".div-dataconsegna"), !fU.IsEmpty(item.DataConsegna));
    d.find(".dataconsegna").text(fU.ToStandardDate(item.DataConsegna));
    //d.find(".dataconsegna").text(fU.DateJsonToDate(item.DataConsegna));

    fU.ShowIf(d.find(".div-sottocommessa"), !fU.IsEmpty(item.Cd_DOSottoCommessa));
    d.find(".cd-dosottocommessa").text(item.Cd_DOSottoCommessa + ' - ' + item.DOSottoCommessa_Descrizione);

    fU.ShowIf(d.find(".div-riferimento"), !fU.IsEmpty(item.NumeroDocRif));
    d.find(".numerodocrif").text(item.NumeroDocRif);
    d.find(".datadocrif").text(fU.ToStandardDate(item.DataDocRif));
    //d.find(".datadocrif").text(fU.DateJsonToDate(item.DataDocRif));

    fU.ShowIf(d.find(".div-prelevatoda"), !fU.IsEmpty(item.PrelevatoDa));
    d.find(".prelevatoda").text(item.PrelevatoDa);

    fU.ShowIf(d.find(".div-cdpg"), !fU.IsEmpty(item.Cd_PG));
    d.find(".cd-pg").text(item.Cd_PG);

    fU.ShowIf(d.find(".div-notepiede"), !fU.IsEmpty(item.NotePiede));
    d.find(".notepiede").text(item.NotePiede);

    $("#DetailDO").show();

}

function DetailDORig_Template(tr, item, key, rowname) {
    switch (rowname) {
        case "ROW1":
            //Articolo
            tr.find(".Cd_AR").text(item.Cd_AR);
            tr.find(".Cd_ARLotto").text(item.Cd_ARLotto);
            tr.find(".Cd_ARMisura").text(item.Cd_ARMisura);
            tr.find(".QtaEvadibile").text(item.QtaEvadibile);
            break;
        case "ROW2":
            tr = "<tr class = 'tr-dorig'> <td colspan='4'>" + item.Descrizione + "</td></tr > ";
            break;
    }

    return tr;
}

function xMORLRig_Totali_Template(row) {
    var p = $("#" + oPrg.ActivePageId);

    p.find(".ar-totali").text(row.Ar_Totali);
    p.find(".ar-prelievo").text(row.Ar_Prelievo);
    p.find(".ar-noncongrui").text(row.Ar_NonCongrui);
    p.find(".ar-fuorilista").text(row.Ar_Fuorilista);

    p.find(".div-card").removeClass("w3-orange");

    // Se ci sono articoli non congrui la card corrispondente verrà messa in arancione
    if (row.Ar_NonCongrui > 0) { p.find(".div-noncongrui").addClass("w3-orange"); }

}

function DetailRLRig_Template(li, item, key) {

    fU.ShowIf(li.find(".div-operatore"), (item.Cd_Operatore == oApp.Cd_Operatore ? false : true));
    fU.ShowIf(li.find(".div-mgp"), !fU.IsEmpty(item.Cd_MG_P));
    fU.ShowIf(li.find(".ubip"), !fU.IsEmpty(item.Cd_MGUbicazione_P));
    fU.ShowIf(li.find(".div-mga"), !fU.IsEmpty(item.Cd_MG_A));
    fU.ShowIf(li.find(".ubia"), !fU.IsEmpty(item.Cd_MGUbicazione_A));
    fU.ShowIf(li.find(".div-lotto"), !fU.IsEmpty(item.Cd_ARLotto));
    fU.ShowIf(li.find(".div-matricola"), !fU.IsEmpty(item.Matricola));
    fU.ShowIf(li.find(".div-quantita"), !fU.IsEmpty(item.Quantita));
    fU.ShowIf(li.find(".div-barcode"), !fU.IsEmpty(item.Barcode));

    li.find(".id-rig").text(item.Id_xMORLRig);
    li.find(".cd-operatore").text(item.Cd_Operatore);
    li.find(".ar-cddesc").text(item.Cd_AR + " - " + item.Descrizione);

    li.find(".dataora").text(fU.formatDateDDMMYYYY(item.DataOra));
    //li.find(".dataora").text(fU.DateJsonToTime(item.DataOra));

    li.find(".mgp-ubip").text(item.Cd_MG_P);
    li.find(".cd-mgubicazione-p").text(fU.ToString(item.Cd_MGUbicazione_P));
    li.find(".mga-ubia").text(item.Cd_MG_A);
    li.find(".cd-mgubicazione-a").text(fU.ToString(item.Cd_MGUbicazione_A));
    li.find(".cd-arlotto").text(item.Cd_ARLotto);
    li.find(".quantita").html(item.Quantita + "&nbsp;" + item.Cd_ARMisura);
    li.find(".matricola").text(item.Matricola);
    li.find(".barcode").text(item.Barcode);

    li.find(".delete").on("click", function () {
        $("#Popup_Del_Lettura").attr("Id_Del", item.Id_xMORLRig).show();
    });

    return li;
}

function DetailTRRig_P_Template(li, item, key) {

    fU.ShowIf(li.find(".div-operatore"), (item.Cd_Operatore == oApp.Cd_Operatore ? false : true));
    fU.ShowIf(li.find(".div-mgp"), !fU.IsEmpty(item.Cd_MG_P));
    fU.ShowIf(li.find(".ubip"), !fU.IsEmpty(item.Cd_MGUbicazione_P));
    fU.ShowIf(li.find(".div-lotto"), !fU.IsEmpty(item.Cd_ARLotto));
    fU.ShowIf(li.find(".div-quantita"), !fU.IsEmpty(item.Quantita));

    // Nascondo i campi del detail perchè nei trasferimenti di partenza non vengono gestiti
    fU.ShowIf(li.find(".div-mga"), false);
    fU.ShowIf(li.find(".ubia"), false);
    fU.ShowIf(li.find(".div-matricola"), false);
    fU.ShowIf(li.find(".div-barcode"), false);

    li.find(".id-rig").text(item.Id_xMOTRRig_P);
    li.find(".cd-operatore").text(item.Cd_Operatore);
    li.find(".ar-cddesc").text(item.Cd_AR + " - " + item.Descrizione);
    li.find(".dataora").text(fU.DateJsonToTime(item.DataOra));
    li.find(".mgp-ubip").text(item.Cd_MG_P);
    li.find(".cd-mgubicazione-p").text(fU.ToString(item.Cd_MGUbicazione_P));
    li.find(".cd-arlotto").text(item.Cd_ARLotto);
    li.find(".quantita").html(item.Quantita + "&nbsp;" + item.Cd_ARMisura);

    li.find(".delete").on("click", function () {
        $("#Popup_Del_Lettura").attr("Id_Del", item.Id_xMOTRRig_P).show();
    });

    return li;
}

function DetailTRRig_A_Template(li, item, key) {

    fU.ShowIf(li.find(".div-operatore"), (item.Cd_Operatore == oApp.Cd_Operatore ? false : true));
    fU.ShowIf(li.find(".div-mga"), !fU.IsEmpty(item.Cd_MG_A));
    fU.ShowIf(li.find(".ubia"), !fU.IsEmpty(item.Cd_MGUbicazione_A));
    fU.ShowIf(li.find(".div-quantita"), !fU.IsEmpty(item.Quantita));

    // Nascondo i campi del detail perchè nei trasferimenti di partenza non vengono gestiti
    fU.ShowIf(li.find(".div-mgp"), false);
    fU.ShowIf(li.find(".ubip"), false);
    fU.ShowIf(li.find(".div-matricola"), false);
    fU.ShowIf(li.find(".div-barcode"), false);
    fU.ShowIf(li.find(".div-lotto"), false);

    li.find(".id-rig").text(item.Id_xMOTRRig_A);
    li.find(".cd-operatore").text(item.Cd_Operatore);
    li.find(".ar-cddesc").text(item.Cd_AR + " - " + item.Descrizione);
    li.find(".dataora").text(fU.DateJsonToTime(item.DataOra));
    li.find(".mgp-ubia").text(item.Cd_MG_A);
    li.find(".cd-mgubicazione-a").text(fU.ToString(item.Cd_MGUbicazione_A));
    li.find(".quantita").html(item.Quantita + "&nbsp;" + item.Cd_ARMisura);

    li.find(".delete").on("click", function () {
        $("#Popup_Del_Lettura").attr("Id_Del", item.Id_xMOTRRig_A).show();
    });

    return li;
}

function xMOTRRig_Totali_Template(row) {

    ActivePage().find(".ar-totali").text(row.Ar_Totali);
    ActivePage().find(".ar-incompleti").text(row.Ar_Incompleti);
}

// Carica nel select di pgPrelievi i tipi di documenti che posso creare 
// in base ai doc selezionati per il prelievo
function Select_Cd_DO_Template(ck) {

    //Caricamento documenti generabili
    var docs = $(ck).attr("Cd_DOs").split(",");
    var find = false;

    if (docs.length > 0) {
        for (var i = 0; i < docs.length; i++) {
            ActivePage().find("select[name='Cd_DO'] option").each(function () {
                if ($(this).val() == docs[i])
                    find = true;
            });

            if (!find) {
                ActivePage().find("select[name='Cd_DO']").append($('<option>', {
                    value: docs[i],
                    text: docs[i],
                    class: "op-cddo"
                }));
            }
        }
    }
}

function DetailPackingList_UL_Template(trHeader, item, key) {

    trHeader.attr("PackListRef", item.PackListRef);
    trHeader.find(".PackListRef").text(item.PackListRef);
    //I pesi e i volumi vengono assegnati al termine della creazione del template del PK

    return trHeader;
}

function DetailPackingList_ULAR_Template(tr, item, key, GRP) {

    tr.attr("Id_xMORLRig", item.Id_xMORLRig);
    tr.attr("Id_xMORLRigPackList", item.Id_xMORLRigPackList);

    tr.find(".Cd_AR").text(item.Cd_AR);
    tr.find(".Qta").text(item.Qta);
    tr.find(".Cd_ARMisura").text(item.Cd_ARMisura);
    tr.find(".PesoNettoKg").text(item.PesoNettoKg);
    tr.find(".PesoLordoKg").text(item.PesoLordoKg);
    tr.find(".VolumeM3").text(item.VolumeM3);

    if (GRP == 1) {
        tr.find("i").css("color", "#DBDBDB").on("click", function () {
            PopupMsg_Show("ATTENZIONE", '', 'La funzionalità di spostamento o elimina quantità è attiva solo con la modifica attiva!', '');
        });
    } else {
        tr.find("i").on("click", function () {
            Popup_PKListAR_DelShift_Load(tr);
        });
    }
    return tr;
}

function xMOIN_Aperti_Template(li, item, key) {

    li.attr("Id_xMOIN", item.Id_xMOIN);

    li.find(".id").text(item.Id_xMOIN);
    li.find(".cd_mgesercizio").text(item.Cd_MGEsercizio);
    li.find(".mges_descrizione").text(item.MGES_Descrizione);
    li.find(".cd_mg").text("Magazzino: " + item.Cd_MG);
    li.find(".cd_mgubicazione").text("Ubicazione: " + fU.ToString(item.Cd_MGUbicazione));
    li.find(".dataora").text(fU.DateJsonToTime(item.DataOra));

    li.on("click", function () {
        INAperti_ClickIt($(this));
    });

    return li;
}

// Aggiunge il nuovo packlistref creato al select in pgRLRig
function xMORLPackListRef_Add_Template(pklRef) {

    var find = false;

    // Verifica se il pklRef esiste già nel select
    $("#pgRLRig select[name='PackListRef']").find('option').each(function () {
        if ($(this).val() == pklRef) {
            find = true;
            return find;
        }
    });

    // Se non esiste lo aggiungo
    if (!find) {
        $("#pgRLRig select[name='PackListRef']").prepend($('<option>', {
            class: "op-pklref"
            , value: pklRef
            , text: pklRef
        }));
    }

    // Seleziona il pklRef modificato o aggiunto e nasconde il popup
    $("#pgRLRig select[name='PackListRef']").val(pklRef);
    HideAndFocus('Popup_PackList_New');
}

function pgRLPK_Template() {

    var pklref = oPrg.PK.dtxMORLPK[oPrg.PK.idx];
    var key = oPrg.PK.idx;
    var length = oPrg.PK.dtxMORLPK.length;


    var p = $("#pgRLPK");

    p.find(".NRow").text((key + 1) + "/" + length);

    p.find(".PackListRef").text(pklref.PackListRef);
    p.find(".Cd_xMOUniLog").text(!fU.IsEmpty(pklref.Cd_xMOUniLog) ? pklref.Cd_xMOUniLog : 'Nessuno');
    p.find("input[name='PesoTaraMks']").val(pklref.PesoTaraMks);
    p.find("input[name='PesoNettoMks']").val(pklref.PesoNettoMks);
    p.find("input[name='PesoLordoMks']").val(pklref.PesoLordoMks);
    p.find("input[name='AltezzaMks']").val(pklref.AltezzaMks);
    p.find("input[name='LunghezzaMks']").val(pklref.LunghezzaMks);
    p.find("input[name='LarghezzaMks']").val(pklref.LarghezzaMks);


    // first-focus
    $("input[name='PesoNettoMks']").removeClass("first-focus");
    $("input[name='PesoLordoMks']").removeClass("first-focus");
    var input2Focus = oLocalStorage.get("pgRLPK_lastPesoInput");
    if (input2Focus) {
        $("input[name='" + input2Focus + "']").addClass("first-focus");
    } else {
        $("input[name='PesoNettoMks']").addClass("first-focus");
    }

}

function xMOGiacenza_Template(tr, item, key) {

    tr.find(".argiac-dosottocommessa").text(fU.ToString(item.Cd_DOSottoCommessa));
    tr.find(".argiac-arlotto").text(fU.ToString(item.Cd_ARLotto));
    tr.find(".argiac-mgubicazione").text(fU.ToString(item.Cd_MGUbicazione));
    tr.find(".argiac-quantita").text(fU.IfEmpty(item.Quantita, 0));
    tr.find(".argiac-armisura").text(fU.ToString(item.Cd_ARMisura));

    tr.on("click", function () {
        // Inserisce i dati della riga selezionata nei campi di input
        pgINRig_RigDataIntoInput($(this));

        Detail_pgINRig_AR_New();
    });

    return tr;
}

function DetailSMDocs_Template(li, item, key) {

    li.find(".ck-documento").attr("Id_DOTes", item.Id_DOTes);
    li.find(".ck-documento").attr("Doc", item.Cd_DO + " nr" + item.NumeroDoc + " Righe:" + item.N_DORig);

    fU.ShowIf(li.find(".numerodoc"), !fU.IsEmpty(item.NumeroDoc));
    fU.ShowIf(li.find(".datadoc"), !fU.IsEmpty(item.DataDoc));

    li.find(".id-dotes").text(item.Id_DOTes);
    li.find(".cd-do").text(item.Cd_DO);
    //li.find(".do-desc").text(item.DO_Descrizione);
    li.find(".cd-cf").text(item.Cd_CF + " - " + item.CF_Descrizione);
    li.find(".numerodoc").html("N.Documento: " + item.NumeroDoc + "&nbsp;&nbsp;&nbsp;");
    li.find(".datadoc").text("DEL: " + fU.DateToLocalDateString(item.DataDoc));
    //li.find(".datadoc").text("DEL: " + fU.DateJsonToDate(item.DataDoc));
    li.find(".ndorig").text("N.Righe: " + item.N_DORig);

    //li.find(".cd-do").on("click", function () {
    //    // Carica i dati del detail
    //    Detail_Ajax_xmovs_DOTes(item.Id_DOTes);
    //    $("#DetailDO").show();
    //});

    return li;
}

function SMRig_TA_Template(tr, item, key, ordar) {

    tr.attr("Id_xMOTRRig_T", item.Id_xMOTRRig_T);

    tr.find(".Cd_AR").text(item.Cd_AR);
    tr.find(".Quantita").text(item.Quantita);
    tr.find(".Cd_ARMisura").text(item.Cd_ARMisura);
    tr.find(".Cd_MGUbicazione").text(item.Cd_MGUbicazione_A);
    // Se la lista è ordinata per ar il numero ordine ub lo metto nella riga articolo senno andrà nella riga ubi
    if (ordar) {
        tr.find(".tblOrdine").text(item.Ordine_Ub);
    }

    switch (item.Stato) {
        case 'S':
            tr.find(".delete").removeClass("w3-hide");
            tr.attr("Id_xMOTRRig_A", item.Id_xMOTRRig_A);
            break;
    }

    tr.on("click", function () {
        if (fU.ToBool($(this).find(".delete").attr("data-delete"))) {
            //Ho cliccato su DELETE e devo eseguire l'eliminazione del trasferimento di stoccaggio
            $(this).find(".delete").attr("data-delete", false);
            //Apre il popup per la conferma
            $("#Popup_SMRig_A_Del").attr("Id_xMOTRRig_A", $(this).attr("Id_xMOTRRig_A")).show();
        } else {
            oPrg.SM.Id_xMOTRRig_T = $(this).attr("Id_xMOTRRig_T");
            Nav.Next();
        }
    });

    //tr.find(".Stato").text(item.Stato);

    return tr;
}

function SMRig_TAOrderBy_Template(tr, item, key, orderby) {
    tr.attr("key", key);

    if (orderby == 'ART') {
        tr.attr("ordine", item.Ordine_Ar);
        tr.find(".Ordine").html(item.Cd_AR + " " + item.Descrizione);
        if (!fU.IsEmpty(item.Id_xMOTRRig_A)) {
            tr.find(".Ordine").append("<i class='mi s18 green w3-right'>done</i >");
        }
    } else {
        tr.attr("ordine", fU.IsEmpty(item.Ordine_Ub) ? "" : item.Ordine_Ub);
        tr.find(".Ordine").html(fU.IsEmpty(item.Cd_MGUbicazione_A) ? "Nessuna ubicazione proposta" : item.Cd_MGUbicazione_A + "<i class='mi s18 green w3-right' style='visibility:hidden'>done</i ><label class='w3-right w3-margin-right'>" + item.Ordine_Ub + "</label>");
        if (!fU.IsEmpty(item.Id_xMOTRRig_A)) {
            tr.find(".Ordine i").css("visibility", "visible");
        }

    }

    return tr;
}

function Detail_UBIGiacenza_ARDesc_Template(tr, item, key) {

    tr.attr("key", key);
    tr.attr("Cd_AR", item.Cd_AR);
    tr.find(".Descrizione").text(item.Descrizione);

    return tr;
}

function Detail_NotePiede_Template(li, item, key) {

    li.find(".do-info").html(item.Cd_DO + "&nbsp;" + item.NumeroDoc);
    li.find(".notepiede").text(item.NotePiede);

    return li;
}

// -------------------------------------------------
// ENDREGION: TEMPLATE
// -------------------------------------------------

// -------------------------------------------------
// #1.60 REGION: CLEAR PAGE
// -------------------------------------------------

function pgRLRig_Clear() {
    var p = "#pgRLRig";

    // Reset valori dei campi ||| ATTENZIONE --> uno alla volta perché alcuni non vanno svuotati!!
    $(p).find("input[name='Cd_AR']").val("");
    $(p).find("input[name='Quantita']").val("");
    $(p).find("input[name='Cd_ARLotto']").val("");
    $(p).find("input[name='DataScadenza']").val("");
    $(p).find("input[name='Matricola']").val("");
    $(p).find("input[name='UMFatt']").val("");
    $(p).find("input[name='Cd_DOSottoCommessa']").val(fU.IsEmpty(oPrg.drRL.Cd_DOSottoCommessa) ? "" : oPrg.drRL.Cd_DOSottoCommessa);
    //$(p).find("input[name='Cd_DOSottoCommessa']").val("");
    $(p).find(".op-um").remove();
    $(p).find(".ar-aa").text("");
    $(p).find("select[name='Cd_ARMisura'] .op-um").remove();
    oPrg.Id_DORig = 0;
    // Svuota i campi personalizzati
    $(p).find(".div-extfld-pers input").val("");

    // Se c'è il barcode (e vi sono bc da ciclare) seleziona il primo secondo la codifica
    Barcode_SelByPos("1", "1");

    SetFocus();
}

function pgTRRig_PA_Clear(p) {
    p = "#" + p;

    // Reset valori dei campi ||| ATTENZIONE --> uno alla volta perché alcuni non vanno svuotati!!
    $(p).find("input[name='Cd_AR']").val("");
    $(p).find("input[name='Quantita']").val("");
    $(p).find("input[name='Cd_ARLotto']").val("");
    $(p).find("input[name='DataScadenza']").val("");
    $(p).find(".op-um").remove();
    $(p).find(".ar-aa").text("");
    $(p).find("select[name='Cd_ARMisura'] .op-um").remove();
}


// -------------------------------------------------
// ENDREGION: CLEAR PAGE
// -------------------------------------------------

// -------------------------------------------------
// #1.70 REGION: xListaCarico
// -------------------------------------------------

// Filtra da un elenco le liste di carico 
function xListaCarico_Filter(ldc) {
    if (!fU.IsEmpty(ldc)) {
        //Mostra/Nasconde tutte le righe che non fanno parte della Ldc
        ActivePage().find("tr.tr-ldc").filter("[xListaCarico!='" + ldc + "']").hide();
        ActivePage().find("tr.tr-ldc").filter("[xListaCarico='" + ldc + "']").show();
        //Verifica della presenza di righe visibili
        if (ActivePage().find("tr.tr-ldc:visible").length == 0) PopupMsg_Show("LdC", "L1", "Lista di carico " + ldc + " non presente nella lista!");
        //Mostra sempre le righe selezionate (recupero l'id di testa e mostro la riga)
        ActivePage().find("tr.tr-ldc").filter("[Id_DOTes='" + ActivePage().find(".ck-ldc:checked").attr("Id_DOTes") + "']").show();
    } else {
        //Mostra tutto
        ActivePage().find("tr.tr-ldc").show();
    }
}

// Seleziona la lista di carico da un valore simulando il click sul check  
function xListaCarico_SelById_DOTes(Id_DOTes) {
    //Imposta il campo selezionato e lo mostra se nascosto
    var chk = ActivePage().find(".ck-ldc[Id_DOTes='" + Id_DOTes + "']");
    chk.prop("checked", true);
    //Filtra la lista di carico corrispondente
    xListaCarico_Filter(chk.attr("xListaCarico"));
    //Simula il click
    xListaCarico_Check_LdC(chk);
}

// Seleziona la lista di carico 
function xListaCarico_Check_LdC(chk) {
    //Elimina i documenti selezionabili
    ActivePage().find("select option").remove();

    var Id_DOTes = fU.ToString($(chk).attr("Id_DOTes"));

    //Deseleziono tutti i check 
    ActivePage().find(".ck-ldc[Id_DOTes!='" + Id_DOTes + "']").prop("checked", false);
    //Seleziono il documento corrente
    ActivePage().find(".ck-ldc[Id_DOTes='" + Id_DOTes + "']").prop("checked", $(chk).prop("checked"));

    var nsel = fU.ToInt32(ActivePage().find("input:visible:checked").length);

    if (!fU.IsEmpty(Id_DOTes) && nsel > 0 && !fU.IsEmpty($(chk).attr("Cd_DOs"))) {

        //Caricamento documenti generabili
        var docs = $(chk).attr("Cd_DOs").split(",");
        if (docs.length > 0) {
            for (var i = 0; i < docs.length; i++) {
                ActivePage().find("select").append($('<option>', {
                    value: docs[i],
                    text: docs[i]
                }));
            }
        }
        //Riassegna il numero di doc selezionato nel campo! 
        ActivePage().find("input[name='Id_DOTes']").val(Id_DOTes);
    } else {
        //nonostante la presenza di righe non si può selezionare nulla (forse errori in cfg doc in Arca?)
        nsel = 0;
    }

    //Restituisce il numero di elementi selezionati
    return nsel;
}

// -------------------------------------------------
// ENDREGION: xListaCarico
// -------------------------------------------------
// -------------------------------------------------
// #1.80 REGION: EVENTI KEYPRESS
// -------------------------------------------------

function KeyPress_Execute(keycode, input) {
    if (keycode == '13') {    //INVIO
        var err = false;
        switch (oPrg.ActivePageValue) {
            case enumPagine.pgxListaCarico:
                switch (input.attr("name")) {
                    case "xListaCarico":
                        //Filtra la lista di carico
                        xListaCarico_Filter($(input).val());
                        break;
                    case "Id_DOTes":
                        //Seleziona in automatico la lista di carico 
                        if (!fU.IsEmpty($(input).val())) {
                            xListaCarico_SelById_DOTes($(input).val());
                        }
                        break;
                    default:
                        err = true;
                        break;
                }
                break;
            case enumPagine.pgSP:
                switch (input.attr("name")) {
                    case "Cd_xMOCodSpe":
                        //Filtra la spedizione
                        Spedizione_Filter($(input).val());
                        break;
                    case "Id_DOTes":
                        //Seleziona in automatico la lista di carico 
                        if (!fU.IsEmpty($(input).val())) {
                            Spedizione_SelById_DOTes($(input).val());
                        }
                        break;
                    default:
                        err = true;
                        break;
                }
                break;
            default:
                //evento invio non gestito per la pagina
                err = true;
                break;
        }
        if (err) PopupMsg_Show("ERRORE", "1", "Errore di gestione del KeyPress_Execute() del campo " + input.attr("name"));
    }
}

// -------------------------------------------------
// ENDREGION: Eventi KeyPress
// -------------------------------------------------
// -------------------------------------------------
// #1.90 REGION: EXECUTE
// -------------------------------------------------

function Filtro_Execute(input, val, select_first) {

    //Il val passato alla funzione è quello di 500 millisecondi fa...
    //JQuery recupera il val attuale dell'imput e viene confrontato con iol vecchio...
    // SEEE I VALORI COINCIDONO significa che l'operatore si è fermato a digitare: filtro
    if (val == $(input).val()) {

        var filterkey = input.attr('filterkey');

        //Assegno alla varibile filtro corrente il valore in modo da utilizzarlo in tutte le ricerche lato server
        oPrg.ActiveSearchValue = val;
        //Filtri lato Server
        switch (filterkey) {
            case 'DocAperti_DO':
                Ajax_xmofn_DOAperti();
                break;
            case 'DocRistampa_DO':
                Ajax_xmofn_DORistampa();
                break;
            case 'Search_AR':
                Search_Ajax_xmofn_AR();
                break;
            case 'Search_ARLotto':
                Search_Ajax_xmofn_ARLotto();
                break;
            case 'Search_CF':
                Search_Ajax_xmofn_CF();
                break;
            case 'Search_CFDest':
                Search_Ajax_xmofn_CFDest();
                break;
            case 'Search_MG':
                Search_Ajax_xmofn_MG();
                break;
            case 'Search_MGUbi':
                Search_Ajax_xmofn_MGUbicazione();
                break;
            case 'Search_DOCaricatore':
                Search_Ajax_xmofn_DOCaricatore();
                break;
            case 'Search_DOSC':
                Search_Ajax_xmofn_xMODOSottoCommessa();
                break;
            case 'Search_xMOCodSpe':
                Search_Ajax_xmofn_Spedizione();
                break;
            case 'Search_ARARMisura':
                Search_Ajax_xmofn_ARARMisura();
                break;
            case 'Search_xListaCarico':
                Search_Ajax_xmofn_xListaCarico();
                break;
        }

        //Filtri lato client
        var filterval = input.val().toUpperCase();    //Il valore da ricercare deve essere sempre in maiuscolo lato client!
        var selettore = (fU.IsEmpty(filterval) ? "!=" : "*=");
        switch (filterkey) {
            case 'Prelievi_DO':
                Prelievi_DO_Filtro(selettore, filterval);
                break;
            case 'Prelievi_AR':
                Prelievi_AR_Filtro(selettore, filterval);
                break;
        }

        if (select_first) {
            var li = $("#" + oPrg.ActiveSearchId + " .li-search:first");
            if (!fU.IsEmpty($(input).val()) && !fU.IsEmpty(li.attr(oPrg.ActiveSearchOutField))) {
                Search_Close(li);
            }
        }

    }
}

// -------------------------------------------------
// ENDREGION: Execute
// -------------------------------------------------
// -------------------------------------------------
// #2.00 REGION: COMANDI LISTENER 
// -------------------------------------------------

function Listener_Sel_Idx(select, refresh_devices) {

    //Seleziona il listener corrente dal select
    oApp.ActiveListenerIdx = $(select).find(":selected").attr("idx");

    if (refresh_devices) {
        //Aggiorna la lista dei devices associati al listener
        Ajax_xmofn_xMOListenerDevice();
    }
}

// Aggiunge i comandi alla coda del listener
function Ajax_ListenerCoda_Add(cmd, Id_xMORL2Close, Id_xMOTR2Close) {
    var out = false;
    Params = JSON.stringify({
        Terminale: oApp.Terminale
        , Cd_Operatore: oApp.Cd_Operatore
        , Cd_xMOListener: oApp.dtxMOListener[oApp.ActiveListenerIdx].Cd_xMOListener
        , Comando: cmd //salva //"PM=" + Stato.DO[Stato.idxDO].Cd_DO + ",1,PrimoPDF}",  //salva e stampa documento
        , Id_xMORL2Close: fU.ToInt32(Id_xMORL2Close)
        , Id_xMOTR2Close: fU.ToInt32(Id_xMOTR2Close)
    });
    $.ajax({
        url: "Moovi.aspx/ListenerCoda_Add",
        async: false,
        data: Params,
        type: "POST",
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (mydata) {
            //nel mio array di stato metto tutti i fornitori
            var r = $.parseJSON(mydata.d);
            if (r[0].Result == 1) {
                //Invia il comando al listner per avviare il salvataggio e/o la stampa
                Ajax_Listener_WakeUp(r[0].Id_xMOListenerCoda);
                out = true;
            }
            else
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Message);
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            Ajax_ErrOut(XMLHttpRequest, textStatus, errorThrown);
        }
    });
    return out;
}

// Mette in ascolto il listener
function Ajax_Listener_WakeUp(Id_xMOListenerCoda) {

    Params = JSON.stringify({
        IP: oApp.dtxMOListener[oApp.ActiveListenerIdx].IP,
        Port: oApp.dtxMOListener[oApp.ActiveListenerIdx].ListenPort,
        Id_xMOListenerCoda: Id_xMOListenerCoda
    });
    $.ajax({
        url: "Moovi.aspx/ListenerCoda_WakeUp",
        async: false,
        data: Params,
        type: "POST",
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            return true;
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            Ajax_ErrOut(XMLHttpRequest, textStatus, errorThrown);
        }
    });
}

// Creazione del comando di Salvataggio
function Listener_TRSave(Id_xMOTR) {
    var cmd = '{CT=' + Id_xMOTR + ';}';
    return cmd;
}

// Creazione del comando di Salvataggio
function Listener_RLSave(Id_xMORL) {
    var cmd = '{CD=' + Id_xMORL + ';}';
    return cmd;
}

// Creazione del comando di Stampa  
function Listener_RLRePrint(Id_DOTes, ulModuli) {
    //comando da eseguire
    var cmd = ''
    ulModuli = $(ulModuli).find(".li-modulo");
    $(ulModuli).each(function (i, li) {
        //Se il modulo è da stampare
        if ($(li).find(".ck-stampa").is(":checked") && $(this).find("input[name='NumeroCopie']").val() > 0) {
            cmd += "PD=" + Id_DOTes + ","   //Print Document CON Id_DOTes
            cmd += $(li).attr("RptDocName") + ","    //Modulo di stampa
            cmd += $(this).find("input[name='NumeroCopie']").val() + ","       //Numero copie
            //se la stampante è definita aggiungo il comando, altrimenti errore
            if (!fU.IsEmpty($(li).find("select[name='ListenerDevice']").val())) {
                cmd += $(this).find("select[name='ListenerDevice']").val() //Device di stampa
            } else {
                //Stampante di DEFAULT!!
            }
            cmd += ";";
        }
    });
    //Completo il comando se valido
    cmd = (!fU.IsEmpty(cmd) ? '{' + cmd + '}' : '');
    return cmd;
}

// Creazione del comando di Salva e Stampa
function Listener_RLSaveAndPrint(Id_xMORL, liModuli) {
    //comando da eseguire 
    //CREAZIONE
    var cmd = '{CD=' + Id_xMORL + ';';
    //STAMPA
    $(liModuli).each(function (idx, li) {
        //Se il modulo è da stampare
        if (fU.ToBool($(li).find(".ck-stampa").is(":checked")) && fU.ToInt32($(li).find("input[name='NumeroCopie']").val()) > 0) {
            cmd += "PD=,"   //Print Document SENZA Id_DOTes
            cmd += $(li).attr("RptDocName") + ","    //Modulo di stampa
            cmd += $(li).find("input[name='NumeroCopie']").val() + ","       //Numero copie
            //se la stampante è definita aggiungo il comando, altrimenti errore
            if (!fU.IsEmpty($(li).find("select[name='ListenerDevice']").val())) {
                cmd += $(this).find("select[name='ListenerDevice']").val() //Device di stampa
            } else {
                //Stampante di DEFAULT!!
                cmd += ''
            }
            cmd += ";";
        }
    });
    //chiudo il comando
    cmd += '}';
    return cmd;
}

// -------------------------------------------------
// ENDREGION: COMANDI LISTENER 
// -------------------------------------------------

// -------------------------------------------------
// #2.10 REGION: FUNZIONALITA' GENERICHE
// -------------------------------------------------

function Prelievi_DO_Filtro(selettore, filterval) {
    //Nascondo tutte le righe della tabella
    $("#pgDOPrelievi table .tr-prel").hide();
    $("#pgDOPrelievi table .tr-prel[F_Doc" + selettore + "'" + filterval + "']").show();
}

function Prelievi_AR_Filtro(selettore, filterval) {
    //Nascondo tutte le righe della tabella
    $("#pgDOPrelievi table .tr-prel").hide();
    $("#pgDOPrelievi table .tr-prel[F_Cd_ARs" + selettore + "'" + filterval + "']").show();
}

// Apre/Chiude un div toggle 
// Se passato alla funzione "force_open" (bool) forza l'apertura (true) o la chiusura (false)
function DivToggle_Execute(div, force_open) {
    //Verifica l'apertura o la chiusura forzosa del div
    if (fU.IsEmpty(force_open)) {
        //Imposto il force_open a rovescio dello stato corrente del div
        force_open = ($(div).find(".icon").text() == "keyboard_arrow_down" ? true : false)
    }

    if (force_open == true) {
        $(div).find(".icon").text("keyboard_arrow_up");
        $(div).find(".content").show();

        if ($(div).hasClass("div-letture")) $("#pgRLRig").find(".div-letture").find(".mo-ofy-auto").show();
        if ($(div).hasClass("div-mga")) $("#pgRLRig").find(".div-mga").find(".mo-ofy-auto").show();

    } else {
        $(div).find(".icon").text('keyboard_arrow_down');
        $(div).find(".content").hide();

        if ($(div).hasClass("div-letture")) $("#pgRLRig").find(".div-letture").find(".mo-ofy-auto").hide();
        if ($(div).hasClass("div-mga")) $("#pgRLRig").find(".div-mga").find(".mo-ofy-auto").hide();
    }


}


// Esegue il click sul li dei documenti aperti
// ATENZIONE il click sulle icone del li simulano il click del li!
function DocAperti_RLClickIt(li) {
    // Controlla se il click si avvenuto effettivamente sul li e non sull'icona del delete
    switch (li.find("i").attr('delete')) {
        case "true":
            //Ho cliccato su DELETE e devo eseguire l'eliminazione del doc
            li.find("i").attr('delete', 'false');
            //Apre il popup per la conferma
            $("#Popup_DocAperti_Del").attr("iddoc", li.attr("prgid")).show();
            break;
        case "false":
            switch (li.attr('prgexe')) {
                case 'SP':
                case 'LC':
                    // Load del programma CSA (doc di lista carico aperto)
                    oPrg.Load('SPA', li.attr('cd_do'), li.attr('prgid'), 'RL');
                    break;
                default:
                    //Ho cliccato su ESEGUI e devo avviare il programma
                    oPrg.Id_xMORL_Edit = li.attr('prgid');
                    oPrg.Load(li.attr('prgexe'), li.attr('cd_do'), li.attr('prgid'), 'RL');
                    break;
            }
            break;
    }
}

function DocAperti_TRClickIt(li) {
    // Controlla se il click si avvenuto effettivamente sul li e non sull'icona del delete
    switch (li.find("i").attr('delete')) {
        case "true":
            //Ho cliccato su DELETE e devo eseguire l'eliminazione del doc
            li.find("i").attr('delete', 'false');
            //Apre il popup per la conferma
            $("#Popup_TRAperti_Del").attr("idtr", li.attr("prgid")).show();
            break;
        case "false":
            oPrg.Load(li.attr('prgexe'), li.attr('cd_do'), li.attr('prgid'), 'TR');
            break;
    }

}

// Richiama l'ajax per eliminare il TR
function TRAperti_DeleteIt(id_tr) {
    if (!fU.IsEmpty(id_tr)) {
        Ajax_delete_TRAperto(id_tr);
    }
    HideAndFocus("Popup_TRAperti_Del");
}

// Richiama l'ajax per eliminare il doc
function DocAperti_DeleteIt(id_doc) {
    if (!fU.IsEmpty(id_doc)) {
        Ajax_delete_DocAperto(id_doc);
    }
    HideAndFocus("Popup_DocAperti_Del");
}

// Esegue il click sul li degli inventari aperti
// ATENZIONE il click sulle icone del li simulano il click del li!
function INAperti_ClickIt(li) {
    switch (li.find("i").attr('delete')) {
        case 'true':
            //Ho cliccato su DELETE e devo eseguire l'eliminazione del'IN
            li.find("i").attr('delete', 'false');
            //Apre il popup per la conferma
            $("#Popup_INAperti_Del").attr("id_xmoin", li.attr("id_xmoin")).show();
            break;
        case 'false':
            // Disabilito la pagina di testa del prg
            oPrg.Pages[oPrg.PageIdx(enumPagine.pgIN)].Enabled = false;
            oPrg.Id_xMOIN_Edit = li.attr("id_xmoin");
            // Carica in drIN la testa dell' inventario selezionato        
            Ajax_xmofn_xMOIN();
            Nav.Next();
            break;
    }
}

// Richiama l'ajax per eliminare l'inventario
function INAperti_DeleteIt(id_xmoin) {
    if (!fU.IsEmpty(id_xmoin)) {
        Ajax_xmosp_xMOIN_Delete(id_xmoin);
    }
    $("#Popup_INAperti_Del").hide();
}

function ARARMisura_Build() {
    // Controllo che sia stato selezionato un articolo e che la lista um è vuota
    if (!fU.IsEmpty($("#" + oPrg.ActivePageId + " input[name='Cd_AR']").val()) && $("#" + oPrg.ActivePageId + " select[name='Cd_ARMisura'] option").length == 0) {
        var TipoARMisura = "";
        var xMOUmDef = "";

        // Solo se sto eseguendo le letture di un documento passo i parametri alla ricerca (altrimenti drDO non esiste)
        if (oPrg.ActivePageId == 'pgRLRig') {
            TipoARMisura = oPrg.drDO.TipoARMisura;
            xMOUmDef = oPrg.drDO.xMOUmDef;
        }
        Ajax_xmofn_ARARMisura(TipoARMisura, xMOUmDef);

        // Se um2set non è vuoto seleziona l'um predeterminata
        var um;
        um = $("#" + oPrg.ActivePageId + " select[name='Cd_ARMisura']").attr("um2set");
        if (!fU.IsEmpty(um))
            $("#" + oPrg.ActivePageId + " select[name='Cd_ARMisura']").setVal(um);

        $("#" + oPrg.ActivePageId + " select[name='Cd_ARMisura']").attr("um2set", "");

        // Se l'operatore ha letto un alias o alternativo seleziona l'UM di riferimento
        if ($("#" + oPrg.ActivePageId + " input[name='Cd_AR']").val().trim() != $("#" + oPrg.ActivePageId + " .ar-aa").text().trim()) {
            Ajax_xmofn_ARAlias_ARMisura();
        }
    }
}

// Elimina l'ultima lettura effettuata in base alla pagina in cui mi trovo
function Delete_Last_Read() {

    switch (oPrg.ActivePageValue) {
        case enumPagine.pgRLRig:
            Ajax_xmosp_xMORLLast_Del();
            onRowCountChange();
            break;

        case enumPagine.pgTRRig_P:
            Ajax_xmosp_xMOTRRig_P_Last_Del();
            break;

        case enumPagine.pgTRRig_A:
            Ajax_xmosp_xMOTRRig_A_Last_Del();
            break;
    }

    HideAndFocus("Popup_Delete_Last_Read");
}

// Elimina la lettura selezionata dal dettaglio delle letture
function Delete_Lettura(Id_Del) {

    switch (oPrg.ActivePageValue) {
        case enumPagine.pgRLRig:
            Ajax_xmosp_xMORLRig_Del(Id_Del);
            break;
        case enumPagine.pgTRRig_P:
            Ajax_xmosp_xMOTRRig_P_Del(Id_Del);
            break;
        case enumPagine.pgTRRig_A:
            Ajax_xmosp_xMOTRRig_A_Del(Id_Del);
            break;
    }

    $('#Popup_Del_Lettura').hide();
}

// Getione del bottone conferma in base alla pagina
// ATTENZIONE EseguiControlli serve solo per RLRig e viene passato alla funzione nel seguente modo:
//              1) Dal pulsante conferma della pagina tramite la variabile EseguiControlli che si trova nelle impostazioni del DO
//              2) Dal popup Popup_Button_OpConfirm sempre a false
function Confirm_Read(EseguiControlli) {

    // Validazione dei campi necessari per validare la lettura
    if (fU.IsEmpty($("#" + oPrg.ActivePageId + " [name='Cd_AR']").val())) {
        PopupMsg_Show("Errore", "", "Articolo errato o mancante.", $("#" + oPrg.ActivePageId + " [name='Cd_AR']"));
        return false;
    }
    if (fU.IsZeroVal($("#" + oPrg.ActivePageId + " [name='Quantita']").val())) {
        PopupMsg_Show("Errore", "", "Quantità errata o mancante.", $("#" + oPrg.ActivePageId + " [name='Quantita']"));
        return false;
    }
    if (fU.IsEmpty($("#" + oPrg.ActivePageId + " [name='Cd_ARMisura'] :selected").text())) {
        PopupMsg_Show("Errore", "", "Unità di misura errata.", $("#" + oPrg.ActivePageId + " [name='Cd_ARMisura']"));
        return false;
    }

    var xml;
    // Costruisce xml campi personalizzati per il salvataggio e verifica se i campo obbligatori sono stati valorizzati altrimenti esce e visualizza il messaggio
    if (!fU.IsEmpty(oPrg.drDO) && !fU.IsEmpty(oPrg.drDO.xMOExtFld)) {
        xml = "<rows>";
        var res = true;
        $("#" + oPrg.ActivePageId + " .div-extfld-pers").each(function (idx, obj) {
            if (fU.ToBool($(obj).find("input").attr("requisite")) && fU.IsEmpty($(obj).find("input").val())) {
                PopupMsg_Show("Errore", "Confirm_Read", "Specificare un valore per " + $(obj).find("label").text());
                res = false;
            }
            xml += "<row nome='" + $(obj).find("input").attr("name") + "' valore='" + $(obj).find("input").val() + "' />";
        });
        xml += "</rows>";
        // Se si è scatenato un messaggio esce
        if (!res)
            return false;
    }

    var r = "";
    switch (oPrg.ActivePageValue) {
        case enumPagine.pgRLRig:
            if (fU.ToBool(oPrg.drDO.MagPFlag) && fU.IsEmpty($("#" + oPrg.ActivePageId + " input[name='Cd_MG_P']").val())) {
                PopupMsg_Show("Errore", "", "Nessun magazzino di partenza selezionato.");
                return false;
            }
            if (fU.ToBool(oPrg.drDO.MagAFlag) && fU.IsEmpty($("#" + oPrg.ActivePageId + " input[name='Cd_MG_A']").val())) {
                PopupMsg_Show("Errore", "", "Nessun magazzino di arrivo selezionato.");
                return false;
            }
            r = Ajax_xmosp_xMORLRig_Save(EseguiControlli, xml);
            break;

        case enumPagine.pgTRRig_P:
            if (fU.IsEmpty($("#" + oPrg.ActivePageId + " input[name='Cd_MG_P']").val())) {
                PopupMsg_Show("Errore", "", "Nessun magazzino di partenza selezionato.");
                return false;
            }
            r = Ajax_xmosp_xMOTRRig_P_Save();
            break;

        case enumPagine.pgTRRig_A:
            if (fU.IsEmpty($("#" + oPrg.ActivePageId + " input[name='Cd_MG_A']").val())) {
                PopupMsg_Show("Errore", "", "Nessun magazzino di arrivo selezionato.");
                return false;
            }
            if (fU.IsEmpty($("#" + oPrg.ActivePageId + " input[name='Quantita']").val())) {
                PopupMsg_Show("Errore", "", "Quantità errata o mancante.");
                return false;
            }
            r = Ajax_xmosp_xMOTRRig_A_Save();
            break;
    }


    if (r) {
        // Azzero i campi e imposto il focus sul campo
        switch (oPrg.ActivePageValue) {
            case enumPagine.pgRLRig:
                pgRLRig_Clear();
                break;

            case enumPagine.pgTRRig_P:
            case enumPagine.pgTRRig_A:
                pgTRRig_PA_Clear(oPrg.ActivePageId);
                SetFocus();
                break;
            default:
                SetFocus();
                break;
        }
    }

    // scrolla la pagina al top 
    window.scrollTo(0, 0);
    // Chiamo la funzione setfocus in modo da riportare il focus nel primo campo con la classe first-focus 
    //SetFocus();

    return r;
}

// Al focus nel campo quantità recupera il cd_Ar da alias o cod alt. e carica le um (se non sono già state caricate) 
function AR_Set_Qta_UM() {
    var Cd_CF = "";
    var Cd_AR = "";
    var find_aa = true;
    switch (oPrg.ActivePageValue) {
        case enumPagine.pgRLRig:
            Cd_CF = $("#pgRL input[name='Cd_CF']").val();
            Cd_AR = $("#" + oPrg.ActivePageId + " input[name='Cd_AR']").val();
            find_aa = fU.IsEmpty($("#" + oPrg.ActivePageId + " .ar-aa").text());       // imposto il semaforo a false se non ho cambiato articolo
            break;
        case enumPagine.pgINRig:
            Cd_AR = $("#pgINRig .div-detail input[name='Cd_AR']").val();
            Cd_CF = "";
            break;
        default:
            Cd_AR = $("#" + oPrg.ActivePageId + " input[name='Cd_AR']").val();
            Cd_CF = "";
            break;
    }


    // Semaforo per ricalcolare l'alias alternativo e le unità di misura
    if (find_aa) {

        if (!fU.IsEmpty(Cd_AR)) {
            // Recupera il Cd_AR corrispondente all'eventuale alias o codice alternativo passato alla funzione
            Ajax_xmofn_Get_AR_From_AAA(Cd_AR, Cd_CF);
        }

        //Ricarica l'elenco delle unità di misura dell'articolo corrente
        ARARMisura_Build();

        var inp_qta = ActivePage().find("input[name='Quantita']");
        switch (oPrg.ActivePageId) {
            case 'pgRLRig':
                //Se la quantità è vuota imposta i valori
                if (fU.IsEmpty(inp_qta.val())) {
                    //Imposta i default dalla parametrizzazione del DOC
                    switch (oPrg.drDO.xMOQuantitaDef) {
                        case 0: //nessuno 
                            break;
                        case 1: //Una unita
                            inp_qta.val("1");
                            break;
                        case 2: //Totale prelevabile;
                            var q = 0;
                            //Cerca il totale prelevabile
                            var ar = oPrg.RL.getARItemByAR(Cd_AR);
                            if (ar && ar.QtaResidua)
                                q = ar.QtaResidua;
                            inp_qta.val(q);
                            break;
                    }
                }
                break;

        }
        //Seleziona il contenuto di tutto il campo
        inp_qta.select();
    }
}

// Calcola i totali dei pesi e dei volumi per ogni unità logistica e per tutta la packing
function Sum_Pesi_Volumi(UL, AR, item) {

    // Tot Peso Netto
    UL.find(".pnul").text((Number(UL.find(".pnul").text()) + item.PesoNettoKg).toFixed(3));

    // Tot Peso Lordo
    UL.find(".plul").text((Number(UL.find(".plul").text()) + item.PesoLordoKg).toFixed(3));

    // Tot Volume
    UL.find(".vul").text((Number(UL.find(".vul").text()) + item.VolumeM3).toFixed(3));

    // Totale pezzi presenti nel pacco
    UL.find(".qtaul").text((Number(UL.find(".qtaul").text()) + item.Qta));

    // TOTALI PESI E VOLUME PER PACKING LIST
    var p = $("#Detail_PackingList");

    p.find(".netto").text((Number(p.find(".netto").text()) + item.PesoNettoKg).toFixed(3));
    p.find(".lordo").text((Number(p.find(".lordo").text()) + item.PesoLordoKg).toFixed(3));
    p.find(".volume").text((Number(p.find(".volume").text()) + item.VolumeM3).toFixed(3));
}

// Attiva e disattiva la visualizzazione dei pesi nel detail della packing list
function DetailPackinList_OnOffPesi(check) {

    if (check.attr("checked") == "checked") {
        check.removeAttr("checked");
        $("#Detail_PackingList .dati1").show();
        $("#Detail_PackingList .dati2").hide();
    } else {
        check.attr("checked", "checked");
        $("#Detail_PackingList .dati1").hide();
        $("#Detail_PackingList .dati2").show();
    }
}

// Attiva e disattiva la visualizzazione per singolo ar nel detail packing list
function DetailPackinList_Visualizzazione(check) {
    if (check.attr("checked") == "checked") {
        check.removeAttr("checked");
        Detail_Ajax_xmofn_xMORLRigPackingList_AR_GRP();
        //$(".pk-dati").find("td i").hide()
        $(".pk-dati table.dati-ar tbody tr ").find("th:nth-child(1), td:nth-child(1)").hide()
    } else {
        check.attr("checked", "checked");
        Detail_Ajax_xmofn_xMORLRigPackingList_AR();
        //$(".pk-dati").find("td i").show()
        $(".pk-dati table.dati-ar tbody tr ").find("th:nth-child(1), td:nth-child(1)").show()
    }
}

// Allo scroll della pagina viene visualizato il button
function When_PageScroll() {
    switch (oPrg.ActivePageValue) {
        case enumPagine.pgINRig:
            if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20) {
                $("#" + oPrg.ActivePageId + " .btn-top").css("display", "block");
            } else {
                $("#" + oPrg.ActivePageId + " .btn-top").css("display", "none");
            }
            break;
    }
}

// Al click del button lo scroll torna al top
function GoTo_TopPage() {
    document.body.scrollTop = 0;
    document.documentElement.scrollTop = 0;
}

function INRig_Client_Filter() {
    var rows, col, ar, ubi;

    // elenco delle righe
    rows = $("#pgINRig table tr.tr-inar");
    // Valore codice articolo
    ar = $("#pgINRig .div-grid .Cd_AR").val();
    ubi = $("#pgINRig .div-grid input[name='Cd_MGUbicazione']").val();

    // mostro tutte le righe
    rows.hide();

    $.each(rows, function (idx, row) {
        var show_ar, show_ubi = false;

        // filtro per Cd_AR
        show_ar = ($(row).find(".Cd_AR").text().toUpperCase().indexOf(ar.toUpperCase()) >= 0);
        // filtro per Cd_MGUbicazione
        show_ubi = ($(row).find(".Cd_MGUbicazione").text().toUpperCase().indexOf(ubi.toUpperCase()) >= 0);

        // Se non è una riga appartenente alla condizione di filtro la nascondo
        if (show_ar == true && show_ubi == true) $(row).show();
    });
}

// Scorre i PcakListRef nella pagina pgRLPK
function Slideshow_PKRef(n) {
    var i;
    var index = n + fU.ToInt32(oPrg.PK.idx);
    if (index > oPrg.PK.dtxMORLPK.length - 1) {
        index = oPrg.PK.dtxMORLPK.length - 1;
    }
    if (index < 0) { index = 0; }
    // Salvo le modifiche effettuate al packlistref prima di scorrere la lista
    Ajax_xmosp_xMORLPackListRef_Save();
    oPrg.PK.idx = index;
    pgRLPK_Template();
    SetFocus();
}

function PackListRef_Save() {
    Ajax_xmosp_xMORLPackListRef_Save();
    // Rimetto mode detail a false 
    oPrg.PK.RLPKDetail = false;
    oPrg.PK.PackListRef = "";
    // Simulo il back della pagina
    Nav.Back();
    //SetFocus();
}

function PKPesi_Calcola(input) {

    // Prendo i valori dai campi
    PN = fU.ToDecimal($("#" + oPrg.ActivePageId + " input[name='PesoNettoMks']").val());
    PL = fU.ToDecimal($("#" + oPrg.ActivePageId + " input[name='PesoLordoMks']").val());
    PT = fU.ToDecimal($("#" + oPrg.ActivePageId + " input[name='PesoTaraMks']").val());

    // In base al valore cambiato effettuo i calcoli
    switch (input.attr("name")) {
        case 'PesoTaraMks':
        case 'PesoNettoMks':
            PL = PT + PN;
            break;
        case 'PesoLordoMks':
            PN = PL - PT;
            break;
    }

    // Inserisco i nuovi valori nei campi
    $("#" + oPrg.ActivePageId + " input[name='PesoNettoMks']").val(PN);
    $("#" + oPrg.ActivePageId + " input[name='PesoLordoMks']").val(PL);
    $("#" + oPrg.ActivePageId + " input[name='PesoTaraMks']").val(PT);
}

function MGUbicazione_Giac_Filter() {
    var p = $("#SearchMGUbicazione");

    $(p).find("li[StatoGiac]").hide();

    switch ($(p).find("select option:selected").val()) {
        case "":
            $(p).find("li[StatoGiac]").show();
            break;
        case "0":
            $(p).find("li[StatoGiac='0']").show();
            break;
        case "1":
            $(p).find("li[StatoGiac='1']").show();
            break;
    }
}

function Articolo_Giac_Filter() {
    var p = $("#DetailARGiacenza");

    $(p).find("tr[StatoGiac]").hide();

    switch ($(p).find("select option:selected").val()) {
        case "":
            $(p).find("tr[StatoGiac]").show();
            break;
        case "0":
            $(p).find("tr[StatoGiac='0']").show();
            break;
        case "1":
            $(p).find("tr[StatoGiac='1']").show();
            break;
    }
}
// -------------------------------------------------
// ENDREGION: FUNZIONALITA' GENERICHE
// -------------------------------------------------

// -------------------------------------------------
// #2.20 REGION: SPEDIZIONE
// -------------------------------------------------

// Filtra da un elenco le spedizioni
function Spedizione_Filter(sp) {
    if (!fU.IsEmpty(sp)) {
        //Mostra/Nasconde tutte le righe che non fanno parte della Spedizione
        ActivePage().find("tr.tr-sp").filter("[Cd_xMOCodSpe!='" + sp + "']").hide();
        ActivePage().find("tr.tr-sp").filter("[Cd_xMOCodSpe='" + sp + "']").show();
        //Verifica della presenza di righe visibili
        if (ActivePage().find("tr.tr-sp:visible").length == 0) PopupMsg_Show("SP", "S1", "Spedizione " + sp + " non presente nella lista!");
    } else {
        //Mostra tutto
        ActivePage().find("tr.tr-sp").show();
    }
}

// Seleziona la spedizione da un valore simulando il click sul check  
function Spedizione_SelById_DOTes(Id_DOTes) {
    //Imposta il campo selezionato e lo mostra se nascosto
    var chk = ActivePage().find(".ck-sp[Id_DOTes='" + Id_DOTes + "']");
    chk.prop("checked", true);
    //Filtra la lista di carico corrispondente
    Spedizione_Filter(chk.attr("Cd_xMOCodSpe"));
    //Simula il click
    Spedizione_Check_SP(chk);
}

// Seleziona la spedizione
function Spedizione_Check_SP(chk) {

    //Elimina i documenti selezionabili
    ActivePage().find("select option").remove();
    ActivePage().find(".i").hide();

    var Cd_xMOCodSpe = fU.ToString($(chk).attr("Cd_xMOCodSpe"));

    //Deseleziono tutti i check 
    ActivePage().find(".ck-sp[Cd_xMOCodSpe!='" + Cd_xMOCodSpe + "']").prop("checked", false);
    //Seleziono il documento corrente
    //$(p).find(".ck-sp[Cd_xMOCodSpe='" + Cd_xMOCodSpe + "']").prop("checked", $(chk).prop("checked"));

    var nsel = fU.ToInt32(ActivePage().find("input:visible:checked").length);

    if (!fU.IsEmpty(Cd_xMOCodSpe) && nsel > 0 && !fU.IsEmpty($(chk).attr("Cd_DOs"))) {

        //Caricamento documenti generabili
        var docs = $(chk).attr("Cd_DOs").split(",");
        if (docs.length > 0) {
            for (var i = 0; i < docs.length; i++) {
                ActivePage().find("select").append($('<option>', {
                    value: docs[i],
                    text: docs[i]
                }));
            }
        }
        //Riassegna il numero di doc selezionato nel campo! 
        ActivePage().find("input[name='Cd_xMOCodSpe']").val(Cd_xMOCodSpe);
        ActivePage().find(".sp-ok").show();
    } else {
        //nonostante la presenza di righe non si può selezionare nulla (forse errori in cfg doc in Arca?)
        nsel = 0;
        ActivePage().find(".sp-no").show();
    }

    //Restituisce il numero di elementi selezionati
    return nsel;
}

function pgSP_OrderTable(order) {
    // Imposto la variabile di sessione con l'ordinamento scelto dall'utente
    localStorage.setItem('SPFiltro', order);
    // Carico la lista delle SP ordinate con l'order selezionato
    Ajax_xmofn_xMOCodSpe();
    // Evidenzia la colonna di ordinamento
    $("#pgSP table").first("tr").find("th.w3-orange").removeClass("w3-orange");
    $("#pgSP table").first("tr").find("th.order-" + order).addClass("w3-orange");
}

// -------------------------------------------------
// ENDREGION: SPEDIZIONE
// -------------------------------------------------

// -------------------------------------------------
// #2.30 REGION: ACQUISIZIONE ALIAS
// -------------------------------------------------

function Popup_ARAlias_Insert_Show(Alias) {

    $("#Popup_ARAlias_Insert .msg").html("Nessuna corrispondenza trovata per il codice:&nbsp;" + Alias);
    $("#Popup_ARAlias_Insert").show();
}

// Avvia il programma AA dalla pagina delle letture 
function GoTo_Prg_AA(TipoAA) {

    // Prendo il valore nel campo Cd_AR della pagina corrente
    var cd_ar = $("#" + oPrg.ActivePageId).find("input[name='Cd_AR']").val();
    var cd_cf = oPrg.drRL.Cd_CF;
    var cf_desc = oPrg.drRL.CF_Descrizione;

    // Nascondo il popup
    $("#Popup_ARAlias_Insert").hide();

    oApp.TipoAA = TipoAA;
    // Carica momentaneamente il programma AA
    oPrg.LoadTemporaryPrg("AA");

    $("#pgAA .barcode").hide();
    $("#pgAA .switch").hide();
    $("#pgAA input[name='" + oApp.TipoAA + "']").val(cd_ar);

    if (oApp.TipoAA.toUpperCase() == 'ALT') {
        $("#pgAA input[name='Cd_CF']").val(cd_cf).attr("disabled", true);
        $("#pgAA label[name='CF_Descrizione']").text(cf_desc);
        $("#pgAA img[searchkey='Cd_CF']").hide();
    }

    $("#pgAA .first-focus:visible").first().focus().select().addClass("mo-br-orange");
}

// Inserisce il nuovo alias per l'articolo 
// il parametro p se pieno indica la pagina o il popup dalla quale prendere i dati nei campi
function Ajax_xmosp_ARAlias_Save() {
    var out = false;

    ajaxCallSync(
        "/xmosp_ARAlias_Save",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_AR: ActivePage().find("input[name='Cd_AR']").val(),
            Cd_ARMisura: ActivePage().find("input[name='Cd_ARMisura']").val(),
            Alias: ActivePage().find("input[name='ALI']").val(),
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result == 1) {
                // Svuota i campi della pagina
                ActivePage().find("input").val("");
                ActivePage().find(".descrizione").text("");
                ActivePage().find(".msg").text("Alias Inserito");
                setTimeout(function () {
                    ActivePage().find(".msg").text("");
                }, 1500);
                SetFocus();
                out = true;
            }
            else {
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            }
        }
    );

    return out;
}

// Inserisce il nuovo alias per l'articolo 
function Ajax_xmosp_ARCodCF_Save() {
    var out = false;

    ajaxCallSync(
        "/xmosp_ARCodCF_Save",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_AR: ActivePage().find("input[name='Cd_AR']").val(),
            Cd_CF: ActivePage().find("input[name='Cd_CF']").val(),
            ARCodCF: ActivePage().find("input[name='ALT']").val(),
            Descrizione: ActivePage().find("input[name='Descrizione']").val(),
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result == 1) {
                // Svuota i campi della pagina
                ActivePage().find("input").val("");
                ActivePage().find(".descrizione").text("");
                ActivePage().find(".msg").text("Codice Alternativo Inserito");
                setTimeout(function () {
                    ActivePage().find(".msg").text("");
                }, 1500);
                SetFocus();
                out = true;
            }
            else {
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            }
        }
    );

    return out;
}

// Cambia la visualizzazione della pagina al click sul bottone slide
function pgAA_Change_TipoAA(codalt) {
    if (codalt) {
        oApp.TipoAA = 'ALT';
    } else {
        oApp.TipoAA = 'ALI';
    }
    pgAA_UI();
}

// -------------------------------------------------
// ENDREGION: ACQUISIZIONE ALIAS
// -------------------------------------------------

// -------------------------------------------------
// #2.40 REGION: INTERROGAZIONE MAGAZZINO
// -------------------------------------------------
var mooviLottoCommessa = null

function Init_SettingsTAG() {

    $(".pgMGDisp-header").on("click", function (event) {
        $("input[name='Cd_AR']").focus().select();
    });

    //Switch per solo quantità positive
    function mooviChkQtaPosSetState() {
        if ($(".switch-container .switch input").is(":checked")) {
            $(".switch-container .switch ").addClass("chacked")
        } else {
            $(".switch-container .switch").removeClass("chacked")
        }
    }

    $(".switch-container .switch input").on("click", function () {
        mooviChkQtaPosSetState()
        oLocalStorage.set("SoloQtaPos", $(".pgMGDisp-Cruscotto.chk-qtapos").is(':checked') ? "1" : "0")
    })

    var lsMooviChkQtaPos = null;

    try {
        lsMooviChkQtaPos = Number(oLocalStorage.get("SoloQtaPos"))
    } catch {
        lsMooviChkQtaPos = 0
    }
    if (lsMooviChkQtaPos > 0) {
        $(".switch-container .switch input").prop("checked", true);
        mooviChkQtaPosSetState();
    }

    //end Switch per solo quantità positive

    //Selezione tra LOTTO e COMMESSA

    window.lottoCommessaRoller = {
        data: {
            localStorageItemName: "LottoCommessa",
            default: "LOTTO",
        },
        init() {
            $(".lotto-commessa label").on("click", function (event) {
                $(".lotto-commessa label").toggleClass("hide")
                lottoCommessaRoller.SetLottoCommessaLabel();
                lottoCommessaRoller.set(mooviLottoCommessa)
                Confirm_MGDisp();
            })

            try {
                mooviLottoCommessa = lottoCommessaRoller.get();
            } catch (e) {
                mooviLottoCommessa = "LOTTO"
            }

            if (mooviLottoCommessa === "LOTTO") {
                $(".lotto-commessa label[name='Cd_ARLotto']").removeClass('hide')
                $(".lotto-commessa label[name='Cd_DOSottoCommessa']").addClass('hide')
            } else {
                $(".lotto-commessa label[name='Cd_ARLotto']").addClass('hide')
                $(".lotto-commessa label[name='Cd_DOSottoCommessa']").removeClass('hide')
            }

            this.set(mooviLottoCommessa);

            this.SetLottoCommessaLabel();

        },
        SetLottoCommessaLabel() {
            if ($(".lotto-commessa label[name='Cd_ARLotto']").hasClass('hide')) {
                mooviLottoCommessa = "COMMESSA";
            } else if ($(".lotto-commessa label[name='Cd_DOSottoCommessa']").hasClass('hide')) {
                mooviLottoCommessa = "LOTTO";
            }
        },
        set(value) {
            oLocalStorage.set(this.data.localStorageItemName, value);
        },
        get() {
            var itemVal = oLocalStorage.get(this.data.localStorageItemName);
            if (itemVal == null || itemVal == undefined || itemVal === "undefined") {
                this.set(this.data.default);
                return this.get()
            }
            return itemVal;
        },
    };

    lottoCommessaRoller.init();

    //end Selezione tra LOTTO e COMMESSA

    // Selezione QTA DIS. D.IMM
    window.allQtaRoller = {
        // data
        data: {
            localStorageItemName: "QtaDisDimm",
            default: "QTA",
            tr: { name: "all-QTA", className: ".all-QTA" },
            container: { name: "all-qta-roller", className: "all-qta-roller" },
            items: [
                { name: "QTA", labelName: "label_qta", className: "label_qta", label: "QTA" },
                { name: "DIS", labelName: "label_dis", className: "label_dis", label: "DIS." },
                { name: "DIMM", labelName: "label_d_imm", className: "label_d_imm", label: "D.IMM" },
            ]
        },
        // methods
        init() {
            var ct = this.getContainer();
            /*ct.on("click", this.rollItem); // set the click event*/
            var crtItem = this.get(); // getting the saved item

            // set the items visibility
            this.data.items.forEach(function (item, index) {
                crtElement = ct.find("[name='" + item.labelName + "']");
                crtElement.on("click", allQtaRoller.onClick);
                crtElement.addClass("hide");
                if (item.name === crtItem) crtElement.removeClass("hide");
            })
        },
        getContainer() {
            return $("." + this.data.container.className);
        },
        onClickCallback: function () {
            console.warn("No onClickCallback was set!");
        },
        onClick(e) {
            ct = allQtaRoller.getContainer();
            name = $(e.target).attr("name");
            allQtaRoller.hideAll();
            crtName = allQtaRoller.get();
            items = allQtaRoller.data.items;
            items.forEach(function (item, index) {
                if (item.name === crtName) {
                    nextItem = items[(index < (items.length - 1)) ? index + 1 : 0]
                    nextElem = ct.find("[name='" + nextItem.labelName + "']");
                    nextElem.removeClass("hide");
                    allQtaRoller.set(nextItem.name);
                }
            });
            allQtaRoller.onClickCallback();
        },
        hideAll() {
            allQtaRoller.getContainer().find("div").addClass("hide");
        },
        // save item name on the local storage
        set(itemName) {
            oLocalStorage.set(this.data.localStorageItemName, itemName);
        },
        // get the item name from the local storage
        get() {
            var itemVal = oLocalStorage.get(this.data.localStorageItemName);
            if (itemVal == null || itemVal == undefined || itemVal === "undefined") {
                this.set(this.data.default);
                return this.get()
            }
            return itemVal;
        },
    };

    allQtaRoller.onClickCallback = Confirm_MGDisp;

    allQtaRoller.init();
    // END Selezione QTA DIS. D.IMM

    setResultsStatus(true);
    ImpostaTotali();
};

//Imposta i totali

function ImpostaTotali(tqta = 0, tdis = 0, tdimm = 0, um = "") {
    if ($(".div-cdar  input[name='Cd_AR']").val().length > 0) {
        $(".pgMGDisp-Cruscotto .contenitore-totali").removeClass("hide");
        $("filtri.mo-bold.w3-large.w3-text-blue").removeClass("hide");
    } else {
        $(".pgMGDisp-Cruscotto .contenitore-totali").addClass("hide")
        $("filtri.mo-bold.w3-large.w3-text-blue").addClass("hide");
    }

    //console.log("pgMGDisp-Cruscotto", $(".pgMGDisp-Cruscotto").attr("class"))

    $(".tot-qta .valoreTot").html(tqta.toLocaleString(undefined, {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
    }));
    $(".tot-dis .valoreTot").html(tdis.toLocaleString(undefined, {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
    }));
    $(".tot-dimm .valoreTot").html(tdimm.toLocaleString(undefined, {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
    }));
    $(".um").html(um);
}
//End Imposta i totali

function setResultsStatus(hide = true) {
    classHide = "hide";
    if (hide) {
        $('label[data-key="ARDescrizione"]').addClass(classHide);
        $('table[data-key="giacenze"]').addClass(classHide);
        $(".div-giac").addClass(classHide);
        $('div[data-key="pgMGDisp-Cruscotto"]').addClass(classHide);
    } else {
        $('label[data-key="ARDescrizione"]').removeClass(classHide);
        $('table[data-key="giacenze"]').removeClass(classHide);
        $(".div-giac").removeClass(classHide);
        $('div[data-key="pgMGDisp-Cruscotto"]').removeClass(classHide);
    }
    $("label.msg").html("")

}

function Clear_MGDisp() {
    $("input[name='Cd_AR']").val("");
    $("input[name='Cd_MG']").val("");
    $("input[name='Cd_MGUbicazione']").val("");
    $("input[name='Cd_DOSottoCommessa']").val("");
    $("input[name='Cd_ARLotto']").val("");
    setResultsStatus(true)
}



function Confirm_MGDisp() {


    $("#pgMGDisp tr").remove(".tr-mgdisp");
    $("#pgMGDisp .filtri").text("");

    // Verifica che sia stato inserito almeno un filtro
    if (fU.IsEmpty($("#pgMGDisp [name='Cd_AR']").val()) && fU.IsEmpty($("#pgMGDisp [name='Cd_MG']").val()) && fU.IsEmpty($("#pgMGDisp [name='Cd_MGUbicazione']").val())
        && fU.IsEmpty($("#pgMGDisp [name='Cd_DOSottoCommessa']").val()) && fU.IsEmpty($("#pgMGDisp [name='Cd_ARLotto']").val())) {
        PopupMsg_Show("Errore", "", "Impostare almeno un filtro");
    } else {
        fU.ShowIf($("#pgMGDisp .AR"), fU.IsEmpty($("#pgMGDisp [name='Cd_AR']").val()));
        DivToggle_Execute($("#pgMGDisp .div-accordion"), false);
        $("#pgMGDisp .div-giac").show();
        Ajax_xmofn_xMOMGDisp();
    }
}

function Ajax_xmofn_xMOMGDisp() {

    $("#pgMGDisp .msg").text("");
    $("#pgMGDisp tr").remove(".tr-mgdisp");

    setResultsStatus(false)
    ImpostaTotali();

    ajaxCallSync(
        "/xmofn_xMOMGDisp",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_MG: $("#pgMGDisp input[name='Cd_MG']").val(),
            Cd_MGUbicazione: $("#pgMGDisp input[name='Cd_MGUbicazione']").val(),
            Cd_AR: $("#pgMGDisp input[name='Cd_AR']").val(),
            Cd_DOSottoCommessa: $("#pgMGDisp input[name='Cd_DOSottoCommessa']").val(),
            Cd_ARLotto: $("#pgMGDisp input[name='Cd_ARLotto']").val(),
            QtaPositiva: $(".pgMGDisp-Cruscotto.chk-qtapos").is(':checked') ? 1 : 0
        },
        function (data) {
            var dt = JSON.parse(data.d);
            //console.log("Valore dt = ", dt);
            if (dt.length > 0) {
                MGDisp_Load(dt);
                var tqta = dt.reduce(function (_this, val) {
                    return _this + val.Quantita
                }, 0);
                var tdis = dt.reduce(function (_this, val) {
                    return _this + val.QuantitaDisp
                }, 0);
                var tdimm = dt.reduce(function (_this, val) {
                    return _this + val.QuantitaDimm
                }, 0);

                ImpostaTotali(tqta, tdis, tdimm, dt.length > 0 ? dt[0].Cd_ARMisura : "pz");
            }
            else {
                ajaxCall(
                    "/xmofn_AR_Descrizione",
                    {
                        "Cd_AR": $("#pgMGDisp [name='Cd_AR']").val()
                    },
                    function (data) {
                        if (data.d !== null) $("#pgMGDisp .filtri").text($("#pgMGDisp [name='Cd_AR']").val() + " - " + data.d);
                        $("#pgMGDisp .msg").text("Nessuna giacenza trovata");
                    }
                );
            }
        }
    );
}

function MGDisp_Load(dt) {
    if (!fU.IsEmpty($("#pgMGDisp [name='Cd_AR']").val())) {
        $("#pgMGDisp .filtri").text($("#pgMGDisp [name='Cd_AR']").val() + " - " + dt[0].Descrizione);
    }
    var tr_ar = $("#pgMGDisp .template_ar").clone().removeAttr("style").addClass("tr-mgdisp");
    var tr_ardesc = $("#pgMGDisp .template_ardesc").clone().removeAttr("style").addClass("tr-mgdisp");
    var tr_mgubi = $("#pgMGDisp .template_mgubi").clone().removeAttr("style").addClass("tr-mgdisp");


    var last_cd_ar = '';
    for (var i = 0; i < dt.length; i++) {
        if (dt[i].Ordinamento == 1) {
            $("#pgMGDisp table").append(MGDispMGUbi_Template(tr_mgubi.clone(), dt[i]));
        }
        $("#pgMGDisp table").append(MGDisp_Template(tr_ar.clone(), dt[i], (last_cd_ar != dt[i].Cd_AR ? true : false)));

        if (last_cd_ar != dt[i].Cd_AR) {
            if (fU.IsEmpty($("#pgMGDisp [name='Cd_AR']").val())) {
                $("#pgMGDisp table").append(MGDispARDesc_Template(tr_ardesc.clone(), dt[i]));
            }
        }
        last_cd_ar = dt[i].Cd_AR;
    }
}

function MGDispARDesc_Template(tr, item) {

    tr.find(".Descrizione").text(item.Descrizione);

    if (item.Cd_MGUbicazione == null) {
        tr.find(".tr-MGUbi").addClass("hide");
    } else {
        tr.find(".tr-MGUbi").removeClass("hide");
    }

    if (mooviLottoCommessa == "LOTTO") {
        if (item.Cd_ARLotto == null) {
            tr.find(".tr-LottoCommessa").addClass("hide")
            tr.find(".LottoCommessa").addClass("hide")
        } else {
            tr.find(".LottoCommessa").text("LOTTO: " + item.Cd_ARLotto);
        }
    } else if (mooviLottoCommessa == "COMMESSA") {
        if (item.Cd_DoSottoCommessa == null) {
            tr.find(".tr-LottoCommessa").addClass("hide")
            tr.find(".LottoCommessa").addClass("hide")
        } else {
            tr.find(".LottoCommessa").text("COMMESSA: " + item.Cd_DoSottoCommessa);
        }
    }


    return tr;
}

function MGDispMGUbi_Template(tr, item) {
    tr.find(".MGUbi").text(fU.IfEmpty(item.Cd_MG, "") + fU.IfEmpty(item.Cd_MGUbicazione, ""));
    return tr;
}

function MGDisp_Template(tr, item, show_ar) {

    tr.find(".MGUbi").text("");
    if (show_ar) tr.find(".Cd_AR").text(item.Cd_AR);
    tr.find(".Cd_ARMisura").text(item.Cd_ARMisura);

    lottoCommessa = tr.find(".td-lotto-commessa");
    if (lottoCommessaRoller.get() === "LOTTO") {
        lottoCommessa.text(item.Cd_ARLotto)
    } else {
        lottoCommessa.text(item.Cd_DOSottoCommessa)
    }

    tdQta = tr.find(".td-quantita");
    switch (allQtaRoller.get()) {
        case "DIS":
            tdQta.text(item.QuantitaDisp)
            break;
        case "DIMM":
            tdQta.text(item.QuantitaDimm)
            break;
        default:
            tdQta.text(item.Quantita)
    }

    //tr.find(".Quantita").text(item.Quantita);
    //tr.find(".QuantitaDisp").text(item.QuantitaDisp);
    //tr.find(".QuantitaDimm").text(item.QuantitaDimm);

    return tr;
}
// -------------------------------------------------
// ENDREGION: INTERROGAZIONE MAGAZZINO
// -------------------------------------------------

// -------------------------------------------------
// #2.50 REGION: STOCCAGGIO MERCE
// -------------------------------------------------

function SMRig_P_FromDocs_Load() {

    // Se è già stato selezionato qualche documento inserisco nelle variabile l'id e il riferimento in modo da accodarvi si successivi
    var Id_DOTess = fU.IsEmpty($("#" + oPrg.ActivePageId + " .ck-smdocs").attr("Id_DOTess")) ? "" : $("#" + oPrg.ActivePageId + " .ck-smdocs").attr("Id_DOTess");
    var Docs = $("#" + oPrg.ActivePageId + " .docs").html();
    //Genera una stringa di id dei documenti selezionati
    $("#Detail_SMDocs .li-do").find(":checkbox:not(disabled)").each(function () {
        if ($(this).prop("checked") == true) {
            // Salva in una stringa l'id dei doc selezionati
            Id_DOTess += $(this).attr("Id_DOTes") + ',';
            Docs += $(this).attr("Doc") + '<br/>';
        }
    });

    $("#" + oPrg.ActivePageId + " .ck-smdocs").attr("Id_DOTess", Id_DOTess).prop("checked", true);
    $("#" + oPrg.ActivePageId + " .docs").html(Docs);

    $("#Detail_SMDocs").hide();
}

// Inserisce le righe P prendendo gli AR dalle righe dei documenti selezionati
function Ajax_xmosp_xMOTRRig_P_FromDocs() {
    res = false;

    ajaxCallSync(
        "/xmosp_xMOTRRig_P_FromDocs",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_MG_P: $("#pgSM [name='Cd_MG_P']").val(),
            Cd_MGUbicazione_P: $("#pgSM [name='Cd_MGUbicazione_P']").val(),
            Id_xMOTR: fU.ToString(oPrg.Id_xMOTR_Edit),
            Id_DOTess: $("#" + oPrg.ActivePageId + " .ck-smdocs").attr("Id_DOTess")
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result > 0) {
                res = true;
            }
            else {
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            }
        }
    );

    return res;
}

// Inserisce le righe P prendendo gli AR in giac nel MG e UBI indicati nella testa del TR
function Ajax_xmosp_xMOTRRig_P_FromMGUBI() {
    res = false;

    ajaxCallSync(
        "/xmosp_xMOTRRig_P_FromMGUBI",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_MG_P: $("#pgSM [name='Cd_MG_P']").val(),
            Cd_MGUbicazione_P: $("#pgSM [name='Cd_MGUbicazione_P']").val(),
            Id_xMOTR: fU.ToString(oPrg.Id_xMOTR_Edit),
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result > 0) {
                res = true;
            }
            else {
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            }
        }
    );

    return res;
}

// Inserisce le righe P nella tabella T assegnandogli una ubicazione
function Ajax_xmosp_xMOTRRig_T_Save() {
    res = false;

    ajaxCallSync(
        "/xmosp_xMOTRRig_T_Save",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Mode: 0, // ### Parametro al momento fisso.. andrà gestito
            Id_xMOTR: fU.ToString(oPrg.Id_xMOTR_Edit),
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result > 0) {
                res = true;
            }
            else {
                PopupMsg_Show("ERRORE", '', 'nella procedura di assegnazione ubicazioni');
            }
        }
    );

    return res;
}

// Cicla gli articoli da stoccare 
function SM_SlideShow(back) {

    var id = 0;

    if (back) {
        //indietro: 
        if (fU.ToInt32(oPrg.SM.key) > 0)
            // seleziono l'id precedente
            id = oPrg.SM.dtxMOTRRig_T[fU.ToInt32(oPrg.SM.key) - 1].Id_xMOTRRig_T;
    }
    else {
        //avanti: ricerca dal successivo del primo con qta da stoccare
        var i = fU.ToInt32(oPrg.SM.key) + 1; //Successivo al corrente
        for (i; i < oPrg.SM.dtxMOTRRig_T.length; i++) {
            if (oPrg.SM.dtxMOTRRig_T[i].QtaDaStoccare > 0) {
                id = oPrg.SM.dtxMOTRRig_T[i].Id_xMOTRRig_T;
                break;
            }
        }
        //Se non ho trovato un id valido ricomincio dal primo
        if (id == 0) {
            i = 0;
            // ciclo dal primo fino al corrente: se non trovo nulla ho finito
            for (i; i <= fU.ToInt32(oPrg.SM.key); i++) {
                if (oPrg.SM.dtxMOTRRig_T[i].QtaDaStoccare > 0) {
                    id = oPrg.SM.dtxMOTRRig_T[i].Id_xMOTRRig_T;
                    break;
                }
            }
        }
    }

    if (id > 0) {
        // posso spostarmi sull'elemento
        oPrg.SM.Id_xMOTRRig_T = id;
        SMRig_T_Load();
    } else {
        // Ho completato tutte le letture
        Nav.Next();
    }

}

function SMRig_T_Load() {

    // Mi muovo sull'id selezionato
    $(oPrg.SM.dtxMOTRRig_T).each(function (idx, obj) {
        obj.Id_xMOTRRig_T == oPrg.SM.Id_xMOTRRig_T ? oPrg.SM.key = idx : "";
    });

    var item = oPrg.SM.dtxMOTRRig_T[oPrg.SM.key];

    var p = $("#pgSMRig_T");

    $(p).find(".Id_xMOTRRig_T").text(item.Id_xMOTRRig_T);
    $(p).find(".nrar").text((fU.ToInt32(oPrg.SM.key) + 1) + "/" + oPrg.SM.dtxMOTRRig_T.length);

    $(p).find("input[name='Cd_MG_A']").val(item.Cd_MG_A);
    $(p).find("input[name='Cd_MGUbicazione_A']").val(item.Cd_MGUbicazione_A).change();
    $(p).find("input[name='Cd_AR']").val(item.Cd_AR);
    $(p).find("input[name='Quantita']").val(fU.ToString(item.Quantita));
    $(p).find("select[name='Cd_ARMisura'] .op-um").remove();
    AR_Set_Qta_UM();

    $(p).find("select[name='Cd_ARMisura']").val(fU.ToString(item.Cd_ARMisura).toUpperCase());

    $(p).find(".Cd_MGUbicazione_A").text(item.Cd_MGUbicazione_A);
    $(p).find(".Cd_AR").text(item.Cd_AR);
    $(p).find(".Quantita").text(item.Quantita);
    $(p).find(".Cd_ARMisura").text(item.Cd_ARMisura);
    $(p).find(".lbl-qta").text("Qta massima da stoccare: " + fU.ToString(item.Quantita));

    $(p).find(".AR_Descrizione").text(item.Descrizione);

    $(p).find(".div-input").hide();
    $(p).find(".div-label").show();

    if (item.QtaDaStoccare == 0) {
        // Gestione dettaglio non modificabile (perché stoccato)
        $(p).find(".smrigt-delete").attr("Id_xMOTRRig_A", item.Id_xMOTRRig_A).removeClass("w3-hide");
        $(p).find(".smrigt-edit").addClass("w3-hide");
    } else {
        $(p).find(".smrigt-edit").removeClass("w3-hide");
        $(p).find(".smrigt-delete").addClass("w3-hide");
    }

    $(p).find(".smrigt-edit").text("Modifica").attr("Modifica", "0");

    // gestione pulsanti avanti e indietro
    $("#pgSMRig_T .btn-slideshow").removeAttr("disabled").css("background-color", "#2196F3 !important");

    // il primo elemento ha il pulsante indietro disabilitato
    if (oPrg.SM.key == 0)
        $("#pgSMRig_T .arrow-left").attr("disabled", true).css("background-color", "#EEEEEE !important");

}

// Salva la riga di stoccaggio come articolo stoccato nella tabella trasferimento arrivo
function Ajax_xmosp_xMOTRRig_TA_Save() {

    // Se la riga risulta già stoccata va al prossimo articolo da stoccare senza salvare
    if (fU.IsEmpty(oPrg.SM.dtxMOTRRig_T[oPrg.SM.key].Id_xMOTRRig_A)) {

        ajaxCallSync(
            "/xmosp_xMOTRRig_TA_Save",
            {
                Terminale: oApp.Terminale,
                Cd_Operatore: oApp.Cd_Operatore,
                Id_xMOTR: fU.ToInt32(oPrg.Id_xMOTR_Edit),
                Quantita: parseFloat(ActivePage().find("[name='Quantita']").val()),
                Cd_ARMisura: fU.ToString(ActivePage().find("select[name='Cd_ARMisura'] :selected").val()),
                Cd_MG_A: fU.ToString(ActivePage().find("[name='Cd_MG_A']").val()),
                Cd_MGUbicazione_A: fU.ToString(ActivePage().find("[name='Cd_MGUbicazione_A']").val()),
                Id_xMOTRRig_P: fU.ToInt32(oPrg.SM.dtxMOTRRig_T[oPrg.SM.key].Id_xMOTRRig_P),
                Id_xMOTRRig_T: fU.ToInt32(oPrg.SM.dtxMOTRRig_T[oPrg.SM.key].Id_xMOTRRig_T),
            },
            function (mydata) {
                var r = $.parseJSON(mydata.d);
                if (r[0].Result > 0) {
                    oPrg.SM.dtxMOTRRig_T[oPrg.SM.key].Id_xMOTRRig_A = r[0].Id_xMOTRRig_A
                    //### Ottimizzare: ricaricare la lista solo se l'operatore ha modificato qualche campo della riga T 
                    Ajax_xmofn_xMOTRRig_TA();
                    SM_SlideShow(false);
                }
                else {
                    PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
                }
            }
        );

    }
}

function SMRig_T_Edit() {


    var p = $("#pgSMRig_T");

    // Modalità modifica da attivare
    if ($(p).find(".smrigt-edit").attr("Modifica") == "0") {

        $(p).find(".smrigt-edit").text("Annulla");
        $(p).find(".smrigt-edit").attr("Modifica", "1");
        $(p).find(".div-label").hide();
        $(p).find(".div-input").show();
        $(p).find(".div-input [name='Quantita']").focus().select();
        //$(p).find("input, select").attr("disabled", false);

    }
    // Modalità modifica da disattivare
    else {
        $(p).find(".smrigt-edit").text("Modifica");
        $(p).find(".smrigt-edit").attr("Modifica", "0");
        $(p).find("input[name='Cd_MGUbicazione_A']").val($(p).find(".div-label .Cd_MGUbicazione_A").text());
        $(p).find(".div-input").hide();
        $(p).find(".div-label").show();
        //$(p).find("input, select").attr("disabled", true);
    }
}

// Ordina il dt contenente le righe temporanee in base all'ordinamento richiesto:
// 1 Per mappatura magazzino
// 2 Per AR
function Order_dtxMOTRRig_T() {
    for (var i = 0; i < oPrg.SM.dtxMOTRRig_T.length; i++) {
        oPrg.SM.dtxMOTRRig_T.sort(function (a, b) {
            switch (oPrg.ActivePageValue) {
                case enumPagine.pgSMRig:
                    fU.IsChecked($("#pgSMRig .ck-smart")) ? $("#pgSMRig .etichetta").text("Ordine per articolo") : $("#pgSMRig .etichetta").text("Ordine per ubicazione");
                    return fU.IsChecked($("#pgSMRig .ck-smart")) ? a.Ordine_Ar - b.Ordine_Ar : a.Ordine_Ub - b.Ordine_Ub;
                    break;
                case enumPagine.pgSMRig_T:
                    return a.Ordine_Ub - b.Ordine_Ub;
                    break;
            }
        });
    }
}

function Ajax_xmosp_xMOTRRig_T_RicercaUbicazione_Escludi() {

    ajaxCallSync(
        "/xmosp_xMOTRRig_T_RicercaUbicazione_Escludi",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMOTRRig_P: fU.ToInt32(oPrg.SM.dtxMOTRRig_T[oPrg.SM.key].Id_xMOTRRig_P),
            Quantita: oPrg.SM.dtxMOTRRig_T[oPrg.SM.key].Quantita,
            Cd_MG_A: $("#" + oPrg.ActivePageId + " [name='Cd_MG_A']").val(),
            Cd_MGUbicazione_Escludi: $("#" + oPrg.ActivePageId + " [name='Cd_MGUbicazione_A']").val()
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (!fU.IsEmpty(r[0].Cd_MGUbicazione)) {
                $("#" + oPrg.ActivePageId + " input[name='Cd_MGUbicazione_A']").val(r[0].Cd_MGUbicazione).change();
                $("#" + oPrg.ActivePageId + " input[name='Quantita']").val(r[0].QtaAssegnabile).focus().select();
            }
            else {
                PopupMsg_Show("ERRORE", r[0].Result, "Nessuna ubicazione trovata");
            }
        }
    );

}

function SMRig_A_DeleteIt(idxmotrriga) {
    if (!fU.IsEmpty(idxmotrriga)) {
        Ajax_xmosp_SMRig_A_Del(idxmotrriga);
        // Se mi trovo nella pagina di dettaglio ricarico il record corrente che è stato eliminato da quelli stoccati e quindi tronato stoccabile
        if (oPrg.ActivePageValue = enumPagine.pgSMRig_T) {
            SMRig_T_Load();
        }
    }
    HideAndFocus("Popup_SMRig_A_Del");
}

function Ajax_xmosp_SMRig_A_Del(idxmotrriga) {

    ajaxCallSync(
        "/xmosp_SMRig_A_Del",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMOTRRig_A: fU.ToInt32(idxmotrriga)
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result > 0) {
                // Ricaricare la lista aggiornata
                Ajax_xmofn_xMOTRRig_TA();
            }
            else {
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            }
        }
    );
}

function Ajax_xmofn_StatoGiac(Cd_MGUbi) {

    var r

    ajaxCallSync(
        "/xmofn_StatoGiac",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_MG: fU.ToString(fMG.Mg4Find($("#" + oPrg.ActivePageId + " input[name='Cd_MG_P']").val(), $("#" + oPrg.ActivePageId + " input[name='Cd_MG_A']").val())),
            Cd_MGUbicazione: Cd_MGUbi,
        },
        function (mydata) {
            r = $.parseJSON(mydata.d);
            //$("#" + oPrg.ActivePageId + " .statogiac").css("background-color", r[0].StatoGiac > 0 ? "orange" : "green", "height", $("#" + oPrg.ActivePageId + " input[name='Cd_MGUbicazione']"));
            r = r[0].StatoGiac;
        }
    );

    return r;
}

function Ajax_xmosp_xMOTRRig_P_AddAR() {

    ajaxCallSync(
        "/xmosp_xMOTRRig_P_AddAR",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMOTR: oPrg.Id_xMOTR_Edit,
            Cd_AR: $("#pgSMRig input[name='Cd_AR']").val(),
            Quantita: $("#pgSMRig input[name='Quantita']").val(),
            Cd_ARMisura: $("#pgSMRig select[name='Cd_ARMisura']").val(),
            Cd_MG_P: oPrg.drTR.Cd_MG_P,
            Cd_MGUbicazione_P: $("#pgSMRig input[name='Cd_MGUbicazione_P']").val(),
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result > 0) {
                Ajax_xmofn_xMOTRRig_TA();
                $('#pgSMRig .section').hide();
                $('#pgSMRig .div-table').show();
            }
        }
    );

}

function Ajax_xmosp_xMOMGUbicazione_Ricerca(Cd_AR, Quantita, Cd_MG, Esclusioni) {

    ajaxCallSync(
        "/xmosp_xMOMGUbicazione_Ricerca",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Cd_AR: Cd_AR,
            Quantita: Quantita,
            Cd_MG: Cd_MG,
            Esclusioni: Esclusioni
        },
        function (mydata) {
            var data = JSON.parse(mydata.d);

            if (data && data.length > 0)
                MGUbicazione = data[0];
        }
    );

    return MGUbicazione;
}

function SMRig_NewAR() {
    $("#pgSMRig .div-input input[name='Cd_AR']").val("");
    $("#pgSMRig .div-input input[name='Quantita']").val("");
    $("#pgSMRig .div-input select[name='Cd_ARMisura'] .op-um").remove();
    $("#pgSMRig .section").hide();
    $("#pgSMRig .div-input").show();
    $("#pgSMRig .div-input input[name='Cd_AR']").focus().select();
}

// -------------------------------------------------
// ENDREGION: STOCCAGGIO MERCE
// -------------------------------------------------


function GestioneFocusPK() {

    if ($("#pgRLRig input[name='xMOBarcode']").is(":visible")) {
        SetFocus();
    }
    else {
        HideAndFocus('Popup_PackList_New');
    }
}

function Ajax_xmofn_xMORLPrelievo_Azzera() {
    // Pulisce le righe della tabella
    ActivePage().find(".ar-ele").remove();

    ajaxCallSync(
        "/xmofn_xMORLPrelievo_Azzera",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMORL: oPrg.Id_xMORL_Edit
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r.length > 0) {

                var last_ar = '';
                var last_id_dotes = 0;
                var ar;
                var ar_ele = '';
                var ar_footer = '';
                var ar_qta = 0;
                var card = ActivePage().find(".template").clone().addClass("ar-ele").removeAttr("style");

                for (i = 0; i < r.length; i++) {
                    if (last_ar != r[i].Cd_AR + r[i].Descrizione) {
                        //Carica l'ultimo articolo se presente
                        if (ar)
                            ActivePage().find(".articoli").append(ar);
                        //Nuovo articolo
                        last_ar = r[i].Cd_AR + r[i].Descrizione;
                        ar_qta = 0;
                        ar = card.clone();
                        $(ar).find(".w3-card-header").html(r[i].Cd_AR + r[i].Descrizione);
                        $(ar).find(".w3-card-ele").html("");
                        last_id_dotes = 0;
                    }
                    //Carica l'elemento
                    if (last_id_dotes != r[i].Id_DOTes) {
                        last_id_dotes = r[i].Id_DOTes;
                        $(ar).find(".w3-card-ele").html($(ar).find(".w3-card-ele").html() + '<b>' + r[i].NumeroDoc + '</b><br />');
                    }
                    ar_ele = '<input type="checkbox" id_dorig="' + r[i].Id_DORig + '"  ' + (r[i].QtaLetta > 0 ? 'checked = "checked"' : '') + ' />&nbsp;Riga [' + r[i].Riga + '] Qta Ev.: ' + r[i].QtaEvadibile + " " + r[i].Cd_ARMisura + (r[i].DataConsegna ? '<br /><b>Consegnare il</b> ' + fU.DateToLocalDateString(r[i].DataConsegna) : '') + (r[i].NoteRiga ? '<br /><b>Note</b> ' + r[i].NoteRiga : '<br />')
                    //ar_ele = '<input type="checkbox" id_dorig="' + r[i].Id_DORig + '"  ' + (r[i].QtaLetta > 0 ? 'checked = "checked"' : '') + ' />&nbsp;Riga [' + r[i].Riga + '] Qta Ev.: ' + r[i].QtaEvadibile + " " + r[i].Cd_ARMisura + (r[i].DataConsegna ? '<br /><b>Consegnare il</b> ' + fU.DateJsonToDate(r[i].DataConsegna) : '') + (r[i].NoteRiga ? '<br /><b>Note</b> ' + r[i].NoteRiga : '<br />')
                    $(ar).find(".w3-card-ele").html($(ar).find(".w3-card-ele").html() + ar_ele);
                    ar_qta = ar_qta + r[i].QtaEvadibile;
                    //aggiorna il footer
                    ar_footer = "Totale prelievo/letture = " + ar_qta + "/" + r[i].QtaLetta + " " + r[i].Cd_ARMisura;
                    if (ar_qta == r[i].QtaLetta)
                        ar_footer = "<span class='w3-green'>" + ar_footer + "</span>";
                    if (ar_qta > r[i].QtaLetta)
                        ar_footer = "<span class='w3-blue'>" + ar_footer + "</span>";
                    if (ar_qta < r[i].QtaLetta)
                        ar_footer = "<span class='w3-orange'>" + ar_footer + "</span>";
                    $(ar).find(".w3-card-footer").html(ar_footer);
                }
                //Carica l'ultimo articolo se presente
                if (ar)
                    ActivePage().find(".articoli").append(ar);
            }
        }
    );

}

function pgRLPrelievo_UI() {
    // Gestione della pagina di prelievo
    if (oPrg.drDO.xMOResiduoInPrelievo != 2) {
        $("#pgRLPrelievo input:checkbox").attr("disabled", true);
        $("#pgRLPrelievo .selall").hide();
    } else {
        $("#pgRLPrelievo input:checkbox").attr("disabled", false);
        $("#pgRLPrelievo .selall").show();
    }
}

function pgRLPrelievo_CheckAll() {
    ActivePage().find(".articoli input:checkbox").prop("checked", fU.IsChecked(ActivePage().find(".ck-all")));
}

// Salvataggio delle righe da azzerare
function Ajax_xmosp_xMORLPrelievo_AzzeraSave() {
    var out = false;

    ajaxCallSync(
        "/xmosp_xMORLPiede_Save",
        {
            Terminale: oApp.Terminale,
            Cd_Operatore: oApp.Cd_Operatore,
            Id_xMORL: oPrg.Id_xMORL_Edit,
        },
        function (mydata) {
            var r = $.parseJSON(mydata.d);
            if (r[0].Result == 1) {
                /* Se l'operatore ha chiesto di salvare il documento (senza stampare)
                o se non sono presenti moduli di stampa
                salva il documento e torna alla Home*/
                if (!fU.ToBool(ActivePage().find(".ck-print").prop("checked")) || (oPrg.drDO.Moduli <= 0)) {
                    //Salvo lo stato del documento accodandolo al listener
                    var cmd = Listener_RLSave(oPrg.Id_xMORL_Edit);
                    Ajax_ListenerCoda_Add(cmd, oPrg.Id_xMORL_Edit);
                    oPrg.Pages[oPrg.ActivePageIdx].GoHome = true;
                }
                else {
                    oPrg.Pages[oPrg.ActivePageIdx].GoHome = false;
                    //Carico i dati di drRL
                    oPrg.drRL = null;
                    out = Ajax_xmovs_xMORL();
                }
                out = true;
            }
            else {
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            }
        }
    );

    return out;

}


// User pref imposta la maschera
function UserPref_Load() {
    var popup = $("#Popup_UserPref");
    // Carica tutte le preferenze
    popup.find("[data-up='altezzaLetture']").val(+oLocalStorage.get("altezzaLetture", 150));
    // Show del detail
    popup.show();

    popup.find("[data-up='altezzaLetture']").focus().select();
    popup.find("[data-up='altezzaLetture']").on('keydown', UserPref_KeyDown);
}

// User pref keypress
function UserPref_KeyDown(event) {
    // keydown
    var keycode = (event.keyCode ? event.keyCode : event.which);
    if (keycode === 13 && event.ctrlKey) {
        UserPref_Save();
    } else if (keycode === 27) {
        HideAndFocus('Popup_UserPref');
    }
}

// User pref validazione
function UserPref_Validate(sErr) {
    var popup = $("#Popup_UserPref");
    var altezzaLetture = +popup.find("[data-up='altezzaLetture']").val();
    if (altezzaLetture < 100 || altezzaLetture > 600) {
        sErr.number = -98;
        sErr.message = 'Il valore deve essere compreso tra 100 e 600.';
        return false;
    }
    return true;
}

// User pref salva
function UserPref_Save() {
    var sErr = {
        number: -99,
        message: ''
    };
    var popup = $("#Popup_UserPref");
    //Validare i campi
    if (UserPref_Validate(sErr)) {
        // Salva tutte le preferenze
        oLocalStorage.set("altezzaLetture", +popup.find("[data-up='altezzaLetture']").val());
        // Chiamo la funzione che imposta l'altezza del container delle letture
        onRowCountChange();
        // Hide del detail
        HideAndFocus('Popup_UserPref');
        popup.find("[data-up='altezzaLetture']").off('keydown', UserPref_KeyDown);
    } else
        PopupMsg_Show("ERRORE", sErr.number, sErr.message);
}
