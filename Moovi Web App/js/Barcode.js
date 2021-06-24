// Costanti globali 
var GS1 = 1;
var SSCC = 2;
var STD = 3;

// Definizione classe Barcode
function Barcode(dtBarcode) {
    this.BarcodeList = dtBarcode;   // Elenco barcode definiti
    this.CurrentBC = null;          // Barcode corrente selezionato
    this.CurrentStr = null;         // Stringa corrente da interpretare
    this.Result = null;             // Lettura interpretata
    this.ResultList = null          // Array contenente tutte le stringhe interpretate dalla classe
    this.ResultIsValid = false;     // True se sono riuscito ad interpretare la stringa
    this.DetailOn = false;
}


// Pulisce tutte le variabili globali della classe
Barcode.prototype.Clear = function () {
    this.Result = null;
    this.CurrentBC = null;
    this.CurrentStr = null;
    this.ResultList = [];
    this.ResultIsValid = false;
    this.DetailOn = false;
}

// Assegna il risultato corrente
Barcode.prototype.AssignFrom = function (Id_ResultList) {
    //la funzione checkresult verifica il barcode specificato da "Id_ResultList" e lo assegna come corrente
    checkresult(this, Id_ResultList);
}

//Gestione UI dei barcode ------------------------------
Barcode.prototype.Detail_Open = function () {
    if (this.CurrentBC.Detail) {
        //Imposta la descrizione corrente del Bc
        $("#DetailBarcode .barcode").find("label").text(this.CurrentBC.Descrizione);
        $("#DetailBarcode").show();
        $("#DetailBarcode input").focus();
        this.DetailOn = true;
    } else {
        PopupMsg_Show("Errore", "B1", "Nessun Barcode definito nel programma corrente. [xCd_xMOProgramma=" + fU.ToString(oPrg.dtDO.xCd_xMOProgramma) + "]");
    }
}

Barcode.prototype.Detail_Close = function () {
    $('#DetailBarcode').hide();
    this.DetailOn = false;
    SetFocus();
    //Find_Next_Tabindex();
}

Barcode.prototype.Detail_Clear = function () {
    $("#DetailBarcode .barcode").find("label").text("");
    $("#DetailBarcode .tot").text("0");
    $("#DetailBarcode .err").text("0");
    $("#DetailBarcode li.li-bc").remove();
    this.DetailOn = false;
}

//Restituisce la stringa XML del barcode correntemente letto
Barcode.prototype.BarcodeXml = function () {
    //Esempio <rows><row codice="GS1" valore="3499ABBB76494994" /><row codice="SSCC" valore="3437843348990480934803489340" /></rows>
    var res = "";
    if (this.CurrentBC != null && this.CurrentBC.Cd_xMOBC != null && this.CurrentStr != null) {
        res = '<rows><row codice="' + this.CurrentBC.Cd_xMOBC + '" valore="' + this.CurrentStr + '" /></rows>';
    }
    return res;
}

Barcode.prototype.Detail_BcAdd = function (bc_val) {

    //Calcola il totale delle letture
    var nRows = fU.ToInt32($("#DetailBarcode label.tot").text());

    //Aggiunge la riga letta dal template
    var li = $("#DetailBarcode li.template").clone().removeClass("template").removeAttr("style").addClass("li-bc")

    li.attr("lettura", nRows + 1)
    li.find(".numero").html(nRows + 1 + ".&nbsp;&nbsp;");
    li.find(".codice").text(bc_val);
    //L'icona è per default non verificata
    li.find(".icon").text('done').css("color", 'green');

    $("#DetailBarcode ul").prepend(li);

    //Assegna il totale delle letture
    $("#DetailBarcode label.tot").text(nRows + 1);

    //Svuota l'input e ne reimposta il fuoco
    $("#DetailBarcode input").val("").focus();

    return (nRows + 1);
}

// -----------------------------------------------------

// Restituisce le informazioni del barcode per l'interfaccia
Barcode.prototype.GetInfoUI = function () {
    var options = '';

    $.each(this.BarcodeList, function (key, val) {
        options += '<option value="' + key + '">' + val.Descrizione + '</option>';
    });

    // Verifico la variabile html
    return (options == '' ? '<option value="null"></option>' : options);
}

// Interpreta la stringa (str) nel formato richiesto (key)
Barcode.prototype.SetCurrentBC = function (key) {
    // Pulisco le variabili globali
    this.Clear();
    // Recupero l'oggetto barcode
    this.CurrentBC = this.BarcodeList[key];
}

// Interpreta la stringa (str) nel formato richiesto (key)
Barcode.prototype.Read = function (str) {
    var res

    // Memorizzo la lettura corrente
    this.CurrentStr = str;

    // Interpreto la stringa in base al tipo di barcode
    switch (this.CurrentBC.Tipo) {
        case SSCC:
            res = this.Read_SSCC();
            break;
        case GS1:
            res = this.Read_GS1();

            var o = this.Result;
            //Normalizza i dati
            $.each(o, function (key, val) {
                switch (key.toLowerCase()) {
                    // Per il GS1 vanno gestite le date
                    case "datascadenza":
                        if (oApp.BrowserType == enumBrowser.Chrome) {
                            // Aggiunge le prime due cifre dell'anno corrente alla data (string data completa è lunga 8)
                            if (val.length == 6) {
                                var n = new Date;
                                val = ("" + n.getFullYear() + "").substr(0, 2) + val;
                            }
                            // Inserisco i meno nella data
                            o.DataScadenza = val.substr(0, 4) + "-" + val.substr(4, 2) + "-" + val.substr(6, 2);
                        }
                        else {
                            // Data YYMMDD -> DD/MM/YYYY
                            o.DataScadenza = val.substr(4, 2) + "/" + val.substr(2, 2) + "/" + val.substr(0, 2);
                        }
                        break;
                }
            });
            break;
        case STD:
            res = this.decodestr(this.CurrentStr);
            break;
        default:
            res = false; // non so che devo fare
            break;
    }
    return res;
}

// Interpreta la stringa nel formato GS1
Barcode.prototype.Read_GS1 = function () {

    // path e result

    var path = "";

    // ripulisco la resultlist
    this.ResultList = [];

    var ValidResultList = [];

    // Interpreto la stringa 
    this.decode(this.CurrentStr, path, this.ResultList, this.CurrentBC.Struttura);

    for (var i = 0; i < this.ResultList.length; i++) {
        if (this.isvalid(this.ResultList[i])) {
            ValidResultList.push(this.ResultList[i]);
        }
    }

    // Sostituisco ResultList con ValidResultList
    this.ResultList = ValidResultList;

    //verifico il primo barcode interpretato (lo zeresimo)
    return this.ResultIsValid = checkresult(this, 0);
}

Barcode.prototype.Read_SSCC = function () {

    this.ResultIsValid = false;

    if (this.CurrentStr.substr(0, 2) == "00") {
        this.ResultIsValid = true;

        this.CurrentStr = this.CurrentStr.substr(2);
    }

    return this.ResultIsValid;
}

Barcode.prototype.decodestr = function (str) {
    var ar = [];
    var x = {};
    this.Result = [];
    var struttura = this.CurrentBC.Struttura;

    $.each(struttura, function (key, val) {
        ar[val.Idx - 1] = { 'Column': val.Column, 'Len': val.Len };
    });

    for (var i = 0; i < ar.length; i++) {
        obj = ar[i];
        x[obj.Column] = str.substr(0, obj.Len[0]);
        str = str.substr(obj.Len[0]);
    }

    this.Result = x;

    this.ResultIsValid = true;

    return true;

}


/*
 * Interpreta il GS1 in base alla struttura
 * @param {String} str
 * @param {String} path
 * @param {String} res
 * @param {Array} struct
 */
Barcode.prototype.decode = function (str, path, res, struct) {
    // push solution path if we've successfully
    // made it to the end of the string
    if (str == '') {
        res.push(path);
        return;
    }

    var i, j, ai, code;

    // find next AI code
    for (
        i = 0, ai = void (0);
        i < str.length && (ai = (struct[code = str.substr(0, i)] != undefined ? struct[code = str.substr(0, i)].Len : undefined)) === undefined;
        i++
    ) { }


    if (ai !== undefined) {
        // recode AI definition to unique format [ MIN, MAX ]
        ai = typeof ai == 'object' ? ai : [ai, ai];
        // iterate on all possible lengths and perform recursive call
        for (j = ai[0]; j <= ai[1]; j++) {
            if (i + j <= str.length) {
                this.decode(str.substr(i + j), path + '(' + code + ')' + str.substr(i, j), res, struct);
            }
        }
    }
}

/**
 * Verifica la validità del GS1
 * @param {String} res
 */
Barcode.prototype.isvalid = function (res) {
    var ret = true;

    var s = this.CurrentBC.Struttura;

    $.each(s, function (r, i) {
        //[(]10[)]
        var exp = res.match(new RegExp("[(]" + r + "[)]", "g"));
        // Non trovato
        if (exp == null || exp.length != 1) {
            ret = false;
            return;
        }
    });

    return ret;
}



//function isValido(res, struttura) {
//    var ret = true;

//    $.each(struttura, function (r, i) {
//        //[(]10[)]
//        var exp = res.match(new RegExp("[(]" + r + "[)]", "g"));
//        // Non trovato
//        if (exp == null || exp.length != 1) {
//            ret = false;
//            return;
//        }
//    });

//    return ret;
//}




/**
 * Crea e verifica la validità del Result
 */
function checkresult(barcode, indexof) {
    var ar = [];
    var res = barcode.ResultList[indexof];
    barcode.Result = null;

    if (res != null) {

        barcode.Result = {}; // Init

        var s = barcode.CurrentBC.Struttura

        $.each(s, function (key, val) {
            ar[val.Idx] = { 'AI': key, 'Column': val.Column };
        });

        for (var i = 0; i < ar.length; i++) {

            obj = ar[i];
            obj1 = ar[i + 1];

            var sIdx = res.indexOf("(" + obj.AI + ")");
            var eIdx = (obj1 != undefined ? res.indexOf("(" + obj1.AI + ")") : undefined);

            barcode.Result[obj.Column] = res.substr(sIdx, eIdx).replace("(" + obj.AI + ")", "");

            res = res.substr(eIdx);
        }
    }

    return (barcode.Result != null);
}



/****************** CODIFICA *************************/
/*
var dtBarcode = {
    'GS1': {
        'Descrizione': 'GS1',
        'Tipo': 0,
        'Struttura': {
            '00': {
                'Idx': 0,
                'Column': 'SSCC',
                'Len': 18
            },
            '01': {
                'Idx': 1,
                'Column': 'EAN',
                'Len': 14
            },
            '10': {
                'Idx': 2,
                'Column': 'Cd_ARLotto',
                'Len': [1, 8]
            },
            '15': {
                'Idx': 3,
                'Column': 'DataScadenza',
                'Len': 6
            },
            '20': {
                'Idx': 5,
                'Column': 'Quantita',
                'Len': 2
            },
            '37': {
                'Idx': 4,
                'Column': 'ProcProd',
                'Len': [1, 8]
            }
        }
    },
    'STRUTTURATO': {
        'Descrizione': 'Barcode strutturato',
        'Tipo': 1,
        'Struttura': {
            '0': {
                'Idx': 0,
                'Column': 'EAN',
                'Len': 14
            },
            '1': {
                'Idx': 1,
                'Column': 'Cd_ARLotto',
                'Len': 6
            },
            '2': {
                'Idx': 2,
                'Column': 'DataScadenza',
                'Len': 6
            },
            '3': {
                'Idx': 4,
                'Column': 'Quantita',
                'Len': 3
            },
            '4': {
                'Idx': 3,
                'Column': 'ProcProd',
                'Len': 2
            }
        }
    }
}

// Contiene l'interpretazione del barcode selezionato
var Lettura = null;


function Barcode_Interpreta(str, barcode) {
    var res = [];

    //In base al tipo, gestisco l'interpretazione
    switch (barcode.Tipo) {
        case 0: // GS1 Standard
            Interpreta_GS1(str, '', res, barcode.Struttura);
            //Se la lettura non è valida la rimuovo dall'array
            $.each(res, function (idx, item) {
                if (!IsValid(item, barcode.Struttura)) {
                    res.pop(item);
                }
            });

            // ATTENZIONE, Se res.length > 1 (HO TROVATO + VALORI VALIDI), altrimenti creo la lettura
            Lettura = (res.length == 1 ? CreaLettura(res[0], barcode.Struttura) : null);
            if (Lettura != null) {
                var bar = new Barcode;
                bar.add(barcode.Descrizione, barcode.Tipo, str, Lettura, 1);
                dtBarcodeLetti.push(bar);
            }

            break;
        case 1: // Barcode strutturato
            res.push(str);
            Interpreta_STRUTTURATO(str);
            var bar = new Barcode;
            bar.add(barcode.Descrizione, barcode.Tipo, str, Lettura, 1);
            dtBarcodeLetti.push(bar);
        default:
            res = null;
            break;
    }

    return res;
}

function Interpreta_GS1(str, path, res, struttura) {
    // push solution path if we've successfully
    // made it to the end of the string
    if (str == '') {
        res.push(path);
        return;
    }

    var i, j, ai, code;

    // find next AI code
    for (
        i = 0, ai = void (0);
        i < str.length && (ai = (struttura[code = str.substr(0, i)] != undefined ? struttura[code = str.substr(0, i)].Len : undefined)) === undefined;
        i++
    ) { }


    if (ai !== undefined) {
        // recode AI definition to unique format [ MIN, MAX ]
        ai = typeof ai == 'object' ? ai : [ai, ai];
        // iterate on all possible lengths and perform recursive call
        for (j = ai[0]; j <= ai[1]; j++) {
            if (i + j <= str.length) {
                Interpreta_GS1(str.substr(i + j), path + '(' + code + ')' + str.substr(i, j), res, struttura);
            }
        }
    }
}

//Interpreta il barcode in base alla struttura
function Interpreta_STRUTTURATO(str) {
    var ar = [];

    $.each(dtAI, function (key, val) {
        ar[val.Idx] = { 'Column': val.Column, 'Len': val.Len };
    });

    for (var i = 0; i < ar.length; i++) {

        obj = ar[i];

        Lettura[obj.Column] = str.substr(0, obj.Len);

        str = str.substr(obj.Len);
    }
}

//Restituisce l'interpretazione correta'
function IsValid(res, struttura) {

    var ret = true;

    $.each(struttura, function (r, i) {
        //[(]10[)]
        var exp = res.match(new RegExp("[(]" + r + "[)]", "g"));
        // Non trovato
        if (exp == null || exp.length != 1) {
            ret = false;
            return;
        }
    });

    return ret;
}


function CreaLettura(res, struttura) {
    Lettura = {};
    var ar = [];

    $.each(struttura, function (key, val) {
        ar[val.Idx] = { 'AI': key, 'Column': val.Column };
    });

    for (var i = 0; i < ar.length; i++) {

        obj = ar[i];
        obj1 = ar[i + 1];

        var sIdx = res.indexOf("(" + obj.AI + ")");
        var eIdx = (obj1 != undefined ? res.indexOf("(" + obj1.AI + ")") : undefined);

        Lettura[obj.Column] = res.substr(sIdx, eIdx).replace("(" + obj.AI + ")", "");

        res = res.substr(eIdx);
    }

    return Lettura;
}
*/


