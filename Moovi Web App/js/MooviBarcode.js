// Elenco barcode utilizzabili nel documento
function Ajax_xmofn_DOBarcode() {

    //Detail: elimina l'elenco dei bc letti
    $("#DetailBarcode li.bc").remove();
    oPrg.BC = null;

    //cerca la gestione BC nella pagina corrente
    var bc = $("#" + oPrg.ActivePageId).find(".barcode");
    if (!fU.IsEmpty(bc)) {

        //Reset BC 
        $(bc).find("option").remove();

        ajaxCallSync(
            "/xmofn_DOBarcode",
            {
                Terminale: oApp.Terminale,
                Cd_Operatore: oApp.Cd_Operatore,
                Cd_DO: oPrg.drDO.Cd_DO
            },
            function (mydata) {
                var dtBc = JSON.parse(mydata.d); //$.parseJSON(mydata.d);

                oPrg.BC = new Barcode(dtBc);
                oPrg.BC.Detail_Clear();         //Prima di annullare il BC pulisco il detail 
                // Carica i barcode 
                Barcode_Load(bc);
                //Se il combo possiede bc automatizza la gestione
                if ($(bc).find("option").length > 0) {
                    // Codice 
                    Barcode_SelType();
                } else {
                    //Nessun bc definito: rimuove la gestione del bc
                    $("#" + oPrg.ActivePageId).find(".div-barcode").hide();
                }
            }
        );
    }
}

// Elenco di tutti i BC codificati in LWA esclusi i tipi SSCC
function Ajax_xmofn_xMOBarcode() {
    var bc = $("#" + oPrg.ActivePageId).find(".barcode");
    if (!fU.IsEmpty(bc)) {
        //Reset BC 
        $(bc).find("option").remove();
        ajaxCallSync(
            "/xmofn_xMOBarcode",
            {
                Codice: ''
            },
            function (mydata) {
                var dtBc = $.parseJSON(mydata.d);
                // Carico i BC nella struttura globale
                oPrg.BC = new Barcode(dtBc);
                // Carica i barcode  nel select
                Barcode_Load(bc);
                //Se il combo possiede bc automatizza la gestione
                if ($(bc).find("option").length > 0) {
                    // Codice 
                    Barcode_SelType();
                } else {
                    //Nessun bc definito: rimuove la gestione del bc
                    $("#" + oPrg.ActivePageId).find(".barcode").hide();
                }
            });
    }
}

// BC codificati in LWA per il trasferimento di partenza
function Ajax_xmofn_MovTraBarcode_P() { Ajax_xmofn_MovTraBarcode("P"); }
function Ajax_xmofn_MovTraBarcode_A() { Ajax_xmofn_MovTraBarcode("A"); }
function Ajax_xmofn_MovTraBarcode(PA) {
    var bc = $("#" + oPrg.ActivePageId).find(".barcode");
    if (!fU.IsEmpty(bc)) {
        //Reset BC 
        $(bc).find("option").remove();
        ajaxCallSync(
            "/xmofn_MovTraBarcode_" + PA,
            {
                Terminale: oApp.Terminale,
                Cd_Operatore: oApp.Cd_Operatore
            },
            function (mydata) {
                var dtBc = $.parseJSON(mydata.d);
                if (Object.keys(dtBc).length) {
                    // Carico i BC nella struttura globale
                    oPrg.BC = new Barcode(dtBc);
                    // Carica i barcode  nel select
                    Barcode_Load(bc);
                }
                //Se il combo possiede bc automatizza la gestione
                if ($(bc).find("option").length > 0) {
                    // Codice 
                    Barcode_SelType();
                } else {
                    //Nessun bc definito: rimuove la gestione del bc
                    $("#" + oPrg.ActivePageId).find(".barcode").hide();
                }
            }
        );
    }
}

// Validazione di un codice BC di tipo SSCC 
function Ajax_Sscc_Validate(bc_val, id_lettura, eseguiControlli) {

    var onSuccess = function (mydata) {
        var r = $.parseJSON(mydata.d);

        // (2):richiesto intervento dell'operatore
        if (r[0].Result > 1) {
            oPrg.RL.StepCtrl = fU.ToInt32(r[0].StepCtrl);
            //Memorizza gli attributi pa ripassare alla funzione xmosp_Sscc_Validate
            $("#Popup_Sscc_OpConfirm .sscc-ok").attr("bc_val", bc_val).attr("id_lettura", id_lettura);
            //Apre il popup per la conferma operatore
            $("#Popup_Sscc_OpConfirm").show().find(".msg").text(r[0].Result + ": " + r[0].Messaggio);
        } else {
            //Aggiorna il detail 
            if (oPrg.BC.CurrentBC.Detail) {
                BarcodeDetail_Update(id_lettura, r[0].Result, r[0].Messaggio)
            }
            //Se il detail non è aperto ed è presente un errore lo mostra
            if (!oPrg.BC.DetailOn && r[0].Result <= 0) {
                //Mostra l'errore
                PopupMsg_Show("ERRORE", r[0].Result, r[0].Messaggio);
            }
            //Aggiorna le righe delle letture
            Ajax_xmofn_xMORLRig_AR();
        }
    };
    var params = {

        Terminale: oApp.Terminale,
        Cd_Operatore: oApp.Cd_Operatore,
        Id_xMORL: fU.ToInt32(oPrg.Id_xMORL_Edit),
        Cd_xMOBC: oPrg.BC.CurrentBC.Cd_xMOBC,
        Sscc: bc_val,
        EseguiControlli: fU.ToBool(eseguiControlli),
        id_lettura: id_lettura
    };
    //------------------------------------------------------------
    // ATTENZIONE! La funzione è sincrona se il Detail è chiuso!!!
    //------------------------------------------------------------
    if (oPrg.BC.DetailOn)
        ajaxCall("/xmosp_Sscc_Validate", params, onSuccess);
    else
        ajaxCallSync("/xmosp_Sscc_Validate", params, onSuccess);
}

// Carica i tipi di Barcode
function Barcode_Load(div_bc) {
    var i = 0;
    var s = $(div_bc).find("select");

    //aggiunge un elemento vuoto
    s.append($('<option>', {
        value: "",
        text: "",
        pos: 0,
        tipo: "",
        num: 0
    }));

    //aggiunge tutti i bc alla lista 
    $.each(oPrg.BC.BarcodeList, function (key, obj) {
        s.append($('<option>', {
            value: obj.Cd_xMOBC,
            text: obj.Descrizione,
            pos: obj.Posizione,
            tipo: obj.Tipo,
            num: (i += 1)
        }));
    });
    //Seleziona il primo elemento con posizione più bassa
    $(s).val($(s).find("[pos='1']:first").val());

    if ($(div_bc).find("option:first").attr("Tipo") == 2) {
        $(div_bc).find(".ck-autoconfirm").attr("disabled", "disabled").attr("checked", false);
    }
    else {
        $(div_bc).find(".ck-autoconfirm").removeAttr("disabled").attr("checked", true);
    }
}

function BarcodeDetail_Update(id_lettura, Result, Messaggio) {
    //Salva la lettura letta
    if (Result == 1) {
        //Tutto ok DetailBarcode
        // fnl i -> img and change the attribute src
        //$("#DetailBarcode li[lettura=" + id_lettura + "]").find("img").attr("src", "/icon/Valido.svg");
        $("#DetailBarcode li[lettura=" + id_lettura + "]").find("i").html("launch").css({ color: "green", "margin-top": "-5px" });
    } else {
        //Errore
        // fnl i -> img and change the attribute src
        $("#DetailBarcode li[lettura=" + id_lettura + "]").find(".messaggio").html(Messaggio);
        //$("#DetailBarcode li[lettura=" + id_lettura + "]").find("img").attr("src", "/icon/NonValido.svg");
        $("#DetailBarcode li[lettura=" + id_lettura + "]").find("i").html("cancel").css("color", "red");
        var nErr = fU.ToInt32($("#DetailBarcode label.err").text());
        $("#DetailBarcode label.err").text(nErr + 1);
    }

}

// Creazione SSCC
function Barcode_Detail_AddBc(bc_val) {
    //Restituisce la posizione inserita del Bc
    return oPrg.BC.Detail_BcAdd(bc_val);
}

//Seleziona il barcode da posizione e numero
function Barcode_SelByPos(pos, num) {
    var p = $("#" + oPrg.ActivePageId);

    var bc_next = $(p).find(".barcode select").find("[pos='" + pos + "'][num='" + num + "']").val();
    var setIt = !fU.IsEmpty(bc_next);
    if (setIt) {
        //Imposta il bc
        $(p).find(".barcode select").val(bc_next);
        //Riposizione la classe BC alla selezione
        Barcode_SelType();
    }

    return (setIt);
}

// Gestisce la selezione del barcode per automatizzare l'interfaccia 
function Barcode_SelType() {
    //Memorizza l'idx corrente
    oPrg.BC.SetCurrentBC(fU.ToString($("#" + oPrg.ActivePageId).find(".barcode option:selected").val()));
    //Se il BC corrente possiede il detail mostra l'incona per l'inserimento
    if ($("#" + oPrg.ActivePageId).find(".barcode .detail-bc").val() != "")
        if (oPrg.BC.CurrentBC && oPrg.BC.CurrentBC.Detail)
            fU.ShowIf($("#" + oPrg.ActivePageId).find(".barcode .detail-bc"), oPrg.BC.CurrentBC.Detail);
    $("#" + oPrg.ActivePageId).find("input[name='xMOBarcode']").focus().select();
}

// Apre il detail dell'inserimento dei Bc 
function Detail_Barcode() {
    //Richiama la funzione centralizzata del detail del barcode
    oPrg.BC.Detail_Open()
}

// Lettura dei barcode 
function Barcode_Interpreter(bc_val, id_lettura, callback) {
    // Recupero il barcode selezionato
    var barcodeSelect = ActivePage().find(".barcode select");

    // Handler per la gestione del PopUp
    var handleBarcodePupup = function (barcodes) {
        var popupBC = $('#Popup_BC_Select');
        popupBC.find('button').unbind('click');
        var popupBC_Close = function () {
            popupBC.hide();
            barcodeList.empty();
            barcodeSelect.val('');
        }
        var barcodeList = popupBC.find('ol[data-key="BarcodeList"]');
        barcodeList.empty();
        barcodes.forEach(function (barcode) {
            barcodeList.append($('<li>')
                .text(barcode.resultText)
                .click(function () {
                    handleBarcodeSet(barcode);
                    handleBarcode(id_lettura);
                    popupBC_Close();
                    if (callback) callback();
                }));
        });
        popupBC.find('button').click(function () {
            popupBC_Close();
            ActivePage().find('input[name="xMOBarcode"]').focus().select();
        });
        popupBC.show();
    }

    try {
        // Se il barcode non è selezionato, verifico tutti quelli con Posizione = 0
        if (barcodeSelect.val().trim() == '') {
            // Interpreto il barcode con tutte le tipologie
            var barcodes = readAllBarcodes(oPrg.BC, bc_val);
            // Verifico che ci siano risultati
            if (barcodes.length == 0)
                throw new Error("Barcode non interpretato. Selezionare manualmente un barcode!!");
            // Se c'è un solo barcode, lo seleziono
            if (barcodes.length == 1) {
                handleBarcodeSet(barcodes[0]);
                handleBarcode(id_lettura);
                if (callback) callback();
                return;
            }
            // Mostro il PopUp di selezione
            handleBarcodePupup(barcodes);
        } else {
            if (!oPrg.BC.Read(bc_val))
                throw new Error("Barcode non interpretato!!");
            if (oPrg.BC.Results.length > 1) {
                var barcodes = [];
                oPrg.BC.Results.forEach(function (result) {
                    barcodes.push({
                        value: oPrg.BC.CurrentStr,
                        barcode: oPrg.BC.CurrentBC,
                        result: result,
                        resultText: barcodeResultToString(result),
                        detailOn: oPrg.BC.DetailOn,
                        resultIsValid: oPrg.BC.ResultIsValid
                    });
                });
                handleBarcodePupup(barcodes);
            } else {
                handleBarcode(id_lettura);
                if (callback) callback();
            }
        }
    } catch (err) {
        console.log(err);
        // Mostra l'errore nel dettaglio (se gestito dal BC)
        if (id_lettura)
            BarcodeDetail_Update(id_lettura, -999, err);
        // Mostra l'errore se il dettaglio è chiuso
        if (!$("#DetailBarcode").is(":visible"))
            PopupMsg_Show("Errore Barcode", 1, err.message);
    }
}

// Interpreta l'alias nel barcode letto  
function Barcode_Interpreter_Alias(bc_val) {
    var err = "";
    var p = $("#" + oPrg.ActivePageId);
    // verifica se la struttura del BC è codificata e quindi risulta interpretabile
    if (oPrg.BC.Read(bc_val)) {
        //Interpreta il tipo di barcode
        switch (oPrg.BC.CurrentBC.Tipo) {
            case SSCC:
                break;
            case STD:
            case GS1:
                //lettura effettuata a buon fine
                for (var key in oPrg.BC.Result) {
                    if (key.toLowerCase() == 'cd_ar') {
                        //ASSEGNA il valore al cmapo ALI o ALT contenuto in oApp.TipoAA.toUpperCase()
                        $(p).find("input[name='" + oApp.TipoAA.toUpperCase() + "']").val(oPrg.BC.Result[key]);
                        return;
                    }
                }
                break;
            default:
                err = "ENUM di interpretazione del Barcode inesistente!!";
        }
    } else {
        err = 'Barcode non interpretabile!';
    }

    return (fU.IsEmpty(err));
}

//  Gestione keypress su Barcode
//  e = keycode
//  imp = imput barcode
//  sel = select del tipo di barcode
function Barcode_Enter(inp, sel) {

    //Memorizza il barcode letto
    var barcode = $(inp).val().trim();

    if (!fU.IsEmpty(barcode)) {
        // Se il bc interpretato corrisponde alla stringa |CONF| abilito o disabilito il check di autoconferma
        if (barcode.toUpperCase() == "CONF") {
            $(".ck-autoconfirm").prop("checked") == true ? $(".ck-autoconfirm").prop("checked", false) : $(".ck-autoconfirm").prop("checked", true);
            SetFocus("xMOBarcode");
            return;
        }
        // Se il bc interpretato corrisponde alla stringa |SAVE| abilito o disabilito il check di autoconferma
        if (barcode.toUpperCase() == "SAVE") {
            setTimeout(function () { ActivePage().find(".btn-confirm").click(); }, 450);
            return;
        }

        var interpreterCallback = function () {
            var confirm = false;
            confirm = fU.IsChecked(("#" + oPrg.ActivePageId + " .ck-autoconfirm"));

            // Reset del valore del campo BC
            $(inp).val("");

            // Esegue i focus solo se non è stato interpretato l'articolo
            if (fU.IsEmpty($("#" + oPrg.ActivePageId + " .ar-aa").text())) {
                //se la l'articolo non è vuoto
                if (!fU.IsEmpty(ActivePage().find("input[name='Cd_AR']").val()))
                    setTimeout(function () { ActivePage().find("input[name='Cd_AR']").focus().change(); }
                        , 150);
                //se la quantità è vuota si ferma sul campo
                if (fU.IsEmpty(ActivePage().find("input[name='Quantita']").val()))
                    setTimeout(function () { ActivePage().find("input[name='Quantita']").focus(); }
                        , 250);
            }
            var pos = $(sel).find("option:selected").attr("pos"); //posizione attuale del bc
            var num = $(sel).find("option:selected").attr("num"); //numero corrente bc
            //Verifica se esistono altri Bc (maggiori di ZERO) con la stessa posizione (cicla tra i bc configurati)
            if (fU.ToInt32(pos) > 0 && Barcode_SelByPos(pos, fU.ToInt32(num) + 1)) {
                //Focus sul bc
                setTimeout($(inp).focus().select(), 350);
            }
            // Terminati i barcode da ciclare se ho il check confirm automatico attivo effettuo il click del conferma
            else {
                //Conferma automatica
                if (confirm && !fU.IsEmpty(ActivePage().find("input[name='Quantita']").val())) {
                    setTimeout(ActivePage().find(".btn-confirm").click(), 350);
                }
            }
        }

        var bc_ok = false;
        switch (oPrg.ActivePageValue) {
            case enumPagine.pgRLRig:
            case enumPagine.pgRLRigID:
            case enumPagine.pgTRRig_P:
            case enumPagine.pgTRRig_A:
            case enumPagine.pgINM2Rig:
                var id_lettura = -1;
                //Se il barcode è di tipo Detail lo aggiunge alla lista e ne gestisce l'UI
                if (oPrg.BC.CurrentBC && oPrg.BC.CurrentBC.Detail) {
                    id_lettura = Barcode_Detail_AddBc(barcode);
                }
                //Interpreta il barcode letto
                Barcode_Interpreter(barcode, id_lettura, function () {
                    interpreterCallback();
                });
                break;
            case enumPagine.pgAA:
                //Interpreta il barcode letto
                bc_ok = Barcode_Interpreter_Alias(barcode);
                // Imposto il focus sul bottone inserisci
                $("#pgAA").find("button").focus().select();
                break;
            default:
                //evento invio non gestito!
                break;
        }

        //Gestione del focus after lettura bc ..........................................
        if (bc_ok) {
            // Chiamo la call back
            interpreterCallback();
        }
    }
}


