//-----------------------------------
//-- Login.js          
//-----------------------------------
//-- ultimo aggiornamento 20-10-2017
//-----------------------------------


function Ajax_GetDitta() {

    Params = JSON.stringify({
        Terminale: $("#Terminale").text(),
        Cd_Operatore: $("#Cd_Operatore").val(),
        Password: $("#Password").val()
    });

    $.ajax({
        url: "Login.aspx/GetDitta",
        async: false,
        data: Params,
        type: "POST",
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (mydata) {
            var myditta = $.parseJSON(mydata.d);
            if (!fU.IsEmpty(myditta)) {
                $("#Ditta").text("Ditta: " + myditta);
            }
            else
                alert("Errore nella connessione con il server. Verificare la stringa di connessione.");
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            //Ajax_ErrOut(XMLHttpRequest, textStatus, errorThrown);
            PopupMsg_Show("Errore", "ERR", "Errore nella connessione con il server. Verificare la stringa di connessione.");
        }
    }); //Ajax
}


//Chiamata ajax per validare ed effettuare il login e caricare le IMPOSTAZIONI GENERALI
function Ajax_LoginValidate() {

    //Gestione del "Ricordami"
    if ($('#Ricordami').is(':checked')) {
        localStorage.Cd_Operatore = $('#Cd_Operatore').val();
        localStorage.Password = $('#Password').val();
        localStorage.Ricordami = $('#Ricordami').val();
    }
    else {
        localStorage.Cd_Operatore = '';
        localStorage.Password = '';
        localStorage.Ricordami = '';
    }

    $(".msg").text("");

    Params = JSON.stringify({
        Terminale: $("#Terminale").text(),
        Cd_Operatore: $("#Cd_Operatore").val(),
        Password: $("#Password").val()
    });

    $.ajax({
        url: "Login.aspx/LoginValidate",
        async: false,
        data: Params,
        type: "POST",
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (mydata) {
            if (!fU.IsNull(mydata.d)) {
                var res = $.parseJSON(mydata.d);
                if (res[0].Result == 1) {
                    oApp.Logon = true;
                    oApp.Cd_Operatore = $("#Cd_Operatore").val();
                    oApp.Terminale = $("#Terminale").text();
                    oApp.ListenerIP = res[0].ListenerIP;
                    oApp.LicF_Id = res[0].LicF_Id;
                    oApp.MRP_Advanced = res[0].MRP_Advanced;
                    switch (oApp.Browser.toLowerCase()) {
                        case "edge":
                        case "internetexplorer":
                            oApp.BrowserType = enumBrowser.Explorer;
                            break;
                        case "mozilla":
                        case "firefox":
                            oApp.BrowserType = enumBrowser.Mozilla;
                            break;
                        case "chrome":
                            oApp.BrowserType = enumBrowser.Chrome;
                            break;
                        default:
                            oApp.BrowserType = enumBrowser.Unknow;
                            break;
                    }
                    //oApp.Browser = 
                    oApp.SetFocus = res[0].SetFocus;
                    // Setta le impostazioni della variabile xMOImpostazioni di oApp
                    Set_xMOImpostazioni(res[0]);
                    Messages_Add("Log-in", "Operatore " + oApp.Cd_Operatore + " - Terminale " + oApp.Terminale)
                    // Success della chiamata, gestisco le altre funzioni Ajax
                    Ajax_LoginValidate_Success();
                }
                else {
                    $("#PopupMsg .msg").text((DEBUG ? res[0].Result + " - " : "") + res[0].Messaggio);
                    $("#PopupMsg").show();
                }
                switch (res[0].Result) {
                    case -30:
                        //Password errata
                        $("#Password").focus().select();
                        break;
                    default:
                        break;
                }
            }
            else
                $(".msg").text("Errore sconosciuto... contattare il fornitore di sistema!!");
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            Ajax_ErrOut(XMLHttpRequest, textStatus, errorThrown);
        }
    }); //Ajax
}

function Set_xMOImpostazioni(r) {
    // Trasferimenti
    oApp.xMOImpostazioni.MovTraAbilita = r.MovTraAbilita;
    oApp.xMOImpostazioni.MovTraDescrizione = r.MovTraDescrizione;
    oApp.xMOImpostazioni.MovTraUbicazione = r.MovTraUbicazione;
    oApp.xMOImpostazioni.MovTraLotto = r.MovTraLotto;
    oApp.xMOImpostazioni.MovTraCommessa = r.MovTraCommessa;
    // Inventario
    oApp.xMOImpostazioni.MovInvAbilita = r.MovInvAbilita;
    oApp.xMOImpostazioni.MovInvDescrizione = r.MovInvDescrizione;
    oApp.xMOImpostazioni.MovInvUbicazione = r.MovInvUbicazione;
    oApp.xMOImpostazioni.MovInvLotto = r.MovInvLotto;
    oApp.xMOImpostazioni.MovInvCommessa = r.MovInvCommessa;
    // Spedizione
    oApp.xMOImpostazioni.SpeAbilita = r.SpeAbilita;
}


function Ajax_LoginValidate_Success() {

    // Carico i parametri globali della tabella xMOImpostazioniWeb
    if (!Ajax_xMOImpostazioniWeb()) return;
    // Recupero i programmi
    if (!Ajax_xMOProgramma()) return;
    // Recupero i DO del sotto menu
    if (!Ajax_DO()) return;
    // Recupero le linee di produzione
    if (!Ajax_xMOLinea()) return;
    // Recupero i listener
    if (!Ajax_xMOListener()) return;
    // Recupera il menù personalizzato
    if (!Ajax_xMOMenu()) return;

    // DEPRECATA !!!!
    // Recupera le unita di misura da ARMisura
    //if (!Ajax_xmovs_ARMisura()) return;

    // Memorizzo l'oggetto oApp
    fU.SetSession(oApp);

    // Vado al main
    location.assign("Moovi.aspx");
}

function Ajax_xMOImpostazioniWeb() {
    var out = false;

    $.ajax({
        url: "Login.aspx/xMOImpostazioniWeb_Load",
        async: false,
        type: "POST",
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (mydata) {
            if (!fU.IsEmpty(mydata.d)) {
                var dt = $.parseJSON(mydata.d);
                oApp.xMOImpostazioniWeb.PackingList = dt[0].PackingList
                out = true;
            }
            else
                PopupMsg_Show("ERRORE", "1", "Parametri web non trovati");
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            Ajax_ErrOut(XMLHttpRequest, textStatus, errorThrown);
        }
    });

    return out;

}


function Ajax_DO() {

    var out = false;

    oApp.dtDO = {};

    Params = JSON.stringify({
        Terminale: oApp.Terminale,
        Cd_Operatore: oApp.Cd_Operatore,
        PackingList: oApp.xMOImpostazioniWeb.PackingList
    });

    $.ajax({
        url: "Login.aspx/DO",
        async: false,
        data: Params,
        type: "POST",
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (mydata) {
            if (!fU.IsEmpty(mydata.d)) {
                var dt = $.parseJSON(mydata.d);
                $.each(dt, function (idx, dr) {
                    oApp.dtDO[dr.Cd_DO] = dr;
                    // Converto il json presente nel campo in un array di oggetti
                    dr.xMOExtFld = $.parseJSON(dr.xMOExtFld);
                });

                out = true;
            }
            else
                PopupMsg_Show("ERRORE", "1", "Nessun documento attivo per Moovi!");
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            Ajax_ErrOut(XMLHttpRequest, textStatus, errorThrown);
        }
    });

    return out;
}

function Ajax_xMOProgramma() {

    var out = false;

    oApp.dtPrograms = null;

    $.ajax({
        url: "Login.aspx/xMOProgramma",
        async: false,
        type: "POST",
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (mydata) {
            if (!fU.IsEmpty(mydata.d)) {
                var dt = $.parseJSON(mydata.d);
                // Creo i programmi
                $.each(dt, function (idx, dr) {
                    //Aggiunge i programmi a oApp.dtPrograms
                    oApp_AddProg(dr.key);
                    //Aggiunge le pagine al programma
                    var pages = dr.pages.split(',');
                    for (var i = 0; i < pages.length; i++) {
                        oApp_AddPage2Prog(dr.key, pages[i], true);
                    }
                });

                out = true;
            }
            else
                PopupMsg_Show("ATTENZIONE", "1", "Nessun programma attivo per Moovi!");
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            Ajax_ErrOut(XMLHttpRequest, textStatus, errorThrown);
        }
    });

    return out;
}

function Ajax_xMOLinea() {

    var out = false;

    oApp.dtxMOLinea = null;

    Params = JSON.stringify({
        Terminale: oApp.Terminale,
        Cd_Operatore: oApp.Cd_Operatore
    });

    $.ajax({
        url: "Login.aspx/xMOLinea",
        async: false,
        type: "POST",
        data: Params,
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (mydata) {
            if (!fU.IsEmpty(mydata.d)) {
                oApp.dtxMOLinea = $.parseJSON(mydata.d);
                out = true;
            }
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            Ajax_ErrOut(XMLHttpRequest, textStatus, errorThrown);
        }
    });

    return out;
}

function Ajax_xMOListener() {

    var out = false;

    Params = JSON.stringify({
        Terminale: oApp.Terminale,
        Cd_Operatore: oApp.Cd_Operatore
    });

    $.ajax({
        url: "Login.aspx/xMOListener",
        async: false,
        data: Params,
        type: "POST",
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (mydata) {
            if (!fU.IsEmpty(mydata.d)) {
                oApp.dtxMOListener = $.parseJSON(mydata.d);
                //Se il terminale ha un listener di default lo seleziono
                $.each(oApp.dtxMOListener, function (idx, dr) {
                    if (oApp.ListenerIP == dr.IP) {
                        oApp.ActiveListenerIdx = idx;
                    }
                });

                //Se non è stasto associato nessun listener al terminale prende il primo
                if (fU.IsEmpty(oApp.ActiveListenerIdx))
                    oApp.ActiveListenerIdx = 0

                out = true;
            } else
                //Nessun listener definito: errore
                PopupMsg_Show("ATTENZIONE", "1", "Nessun listener attivo per Moovi!");
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            Ajax_ErrOut(XMLHttpRequest, textStatus, errorThrown);
        }
    });

    return out;
}

//Menù personalizzato di Moovi
function Ajax_xMOMenu() {

    var out = false;

    Params = JSON.stringify({
        Terminale: oApp.Terminale,
        Cd_Operatore: oApp.Cd_Operatore
    });

    $.ajax({
        url: "Login.aspx/xMOMenu",
        async: false,
        data: Params,
        type: "POST",
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (mydata) {
            if (!fU.IsEmpty(mydata.d)) {
                oApp.dtxMOMenu = $.parseJSON(mydata.d);
                out = true;
            }
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            Ajax_ErrOut(XMLHttpRequest, textStatus, errorThrown);
        }
    });

    return out;
}

// DEPRECATA !!!
// Elenco di tutte le unità di misura 
//function Ajax_xmovs_ARMisura() {

//    var out = false;

//    // Pulisce il select
//    $("#" + oPrg.ActivePageId + " select[name='Cd_ARMisura'] .op-um").remove();

//    Params = JSON.stringify({
//    });
//    $.ajax({
//        url: "Moovi.aspx/xmovs_ARMisura",
//        async: false,
//        data: Params,
//        type: "POST",
//        dataType: "json",
//        contentType: "application/json; charset=utf-8",
//        success: function (mydata) {
//            var dt = $.parseJSON(mydata.d);
//            oApp.dtxMOARMisura = dt;

//            out = true;
//        },
//        error: function (XMLHttpRequest, textStatus, errorThrown) {
//            Ajax_ErrOut(XMLHttpRequest, textStatus, errorThrown);
//        }
//    });

//    return out;
//}
