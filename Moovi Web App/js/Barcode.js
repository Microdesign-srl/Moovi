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
    this.Results = [];              // Letture interpretata
    this.ResultList = null          // Array contenente tutte le stringhe interpretate dalla classe
    this.ResultIsValid = false;     // True se sono riuscito ad interpretare la stringa
    this.DetailOn = false;
}


// Pulisce tutte le variabili globali della classe
Barcode.prototype.Clear = function () {
    this.Result = null;
    this.Results = [];
    this.CurrentBC = null;
    this.CurrentStr = null;
    this.ResultList = [];
    this.ResultIsValid = false;
    this.DetailOn = false;
}

//Gestione UI dei barcode ------------------------------
Barcode.prototype.Detail_Open = function () {
    if (this.CurrentBC && this.CurrentBC.Detail) {
        //Imposta la descrizione corrente del Bc
        $("#DetailBarcode .barcode").find("label").text(this.CurrentBC.Descrizione);
        $("#DetailBarcode").show();
        $("#DetailBarcode input").focus();
        this.DetailOn = true;
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
    var res;

    this.Results = [];

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
                switch (true) {
                    // Per il GS1 vanno gestite le date
                    case key.toLowerCase() == "datascadenza":
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
            this.Results.push(this.Result);
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

    this.decodeResults();

    return this.ResultIsValid = checkresult(this);
}


Barcode.prototype.Read_SSCC = function () {

    var struttura = this.CurrentBC.Struttura;

    this.ResultIsValid = false;

    //Toglie i caratteri iniziali se presenti
    if (this.CurrentStr.substr(0, 2) == "00") {
        this.ResultIsValid = true;

        this.CurrentStr = this.CurrentStr.substr(2);
    }
    //Cancella i caratteri eccedenti
    if (struttura.hasOwnProperty("X00")) {
        this.CurrentStr = this.CurrentStr.substr(0, struttura.X00.Len[1]);
    }

    // DECOMMENTARE QUANDO SI GESTIRà L'SSCC COME GS1 E STD
    // this.Results.push(this.CurrentStr);

    return this.ResultIsValid;
}

Barcode.prototype.decodestr = function (str) {
    this.Result = [];
    var struttura = this.CurrentBC.Struttura;

    var tmp = str;
    var result = {};

    Object.keys(struttura).forEach(function (key) {
        var ai_len = struttura[key].AI ? struttura[key].AI.length : 0;
        var len = struttura[key].Len[0];
        result[struttura[key].Column] = tmp.substr(ai_len, len);
        tmp = tmp.substr(len + ai_len);
    });

    this.Result = result;
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
        // PER EVITARE ERRORI DI CODIFICA JSON VIENE VERIFICATO COME XAI --> in code non viene memorizzata la X
        i < str.length && (ai = (struct['X' + str.substr(0, i)] != undefined ? struct['X' + (code = str.substr(0, i))].Len : undefined)) === undefined;
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
        //} else {
        //    var key = Object.keys(struct)[0];
        //    var fakeAI = key.replace('X', '');
        //    struct[key].AI = fakeAI;
        //    res.push("".concat('(', fakeAI, ')', str));
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
        //console.log("[(]" + r.replace("X", "") + "[)]");
        var exp = res.match(new RegExp("[(]" + r.replace("X", "") + "[)]", "g"));
        // Non trovato
        if (exp == null || exp.length != 1) {
            ret = false;
            return;
        }
    });

    return ret;
}


Barcode.prototype.decodeResults = function () {
    var self = this;
    this.Results = this.ResultList.map(function (result) {
        return self.decodeBarcode(result)
    });
}

Barcode.prototype.decodeBarcode = function (barcode) {
    var self = this;
    if (!barcode) return undefined;
    // Risultato della decodifica
    var result = {};
    // Struttura del barcode nel formato AI - Column
    var structure = [];
    Object.keys(self.CurrentBC.Struttura).forEach(function (key) {
        structure.push({
            AI: key.replace('X', ''),
            Column: self.CurrentBC.Struttura[key].Column
        })
    });
    // Per ogni elemento della struttura
    // Memorizzo gli indici di inizio e fine (elemento successivo) nella stringa del risultato del BC
    // Aggiungo la property all'oggetto di ritorno
    structure.forEach(function (currentItem, index, array) {
        //var nextItem = array[index + 1];
        //var startIndex = barcode.indexOf("".concat("(", currentItem.AI, ")"));
        //var length = nextItem ? barcode.indexOf("".concat("(", nextItem.AI, ")")) - startIndex : undefined;
        //var value = barcode.substr(startIndex, length).replace("".concat("(", currentItem.AI, ")"), "");

        var startIndex = barcode.indexOf("".concat("(", currentItem.AI, ")")) + currentItem.AI.length + 2;      // toglie le () + la lunghezza AI
        var length = barcode.substr(startIndex).replace("".concat("(", currentItem.AI, ")"), "").indexOf("(");
        var value = barcode.substr(startIndex, length > 0 ? length : undefined);
        // Se l'AI è della serie 300y ed ha lunghezza 4
        // La y indica la potenza a cui elevare per ricavare i decimali
        if (currentItem.AI[0] == '3' && currentItem.AI.length == 4) {
            var power = Math.pow(10, parseInt(currentItem.AI.substr(3, 1)));
            var num = parseInt(value);
            value = (num / power).toString();
        }
        result[currentItem.Column] = value;
    });
    return result;
}

/**
 * Crea e verifica la validità del Result
 */
function checkresult(barcode) {
    var ar = [];
    var res = barcode.ResultList[0];
    barcode.Result = null;

    if (res != null) {

        barcode.Result = {}; // Init

        var s = barcode.CurrentBC.Struttura

        $.each(s, function (key, val) {
            ar.push({ 'AI': key, 'Column': val.Column });
        });

        var obj, obj1, ai, ai1
        for (var i = 0; i < ar.length; i++) {

            obj = ar[i];
            obj1 = ar[i + 1];

            ai = obj.AI.replace("X", ""); //Rimuove la X aggiunta per normalizzare gli AI (errori con [15]!!)
            ai1 = (obj1 != undefined ? obj1.AI.replace("X", "") : undefined); //Rimuove la X aggiunta per normalizzare gli AI (errori con [15]!!)
            var sIdx = res.indexOf("(" + ai + ")");
            var eIdx = (obj1 != undefined ? res.indexOf("(" + ai1 + ")") : undefined);

            barcode.Result[obj.Column] = res.substr(sIdx, eIdx).replace("(" + ai + ")", "");

            // Se l'AI è della serie 300y ed ha lunghezza 4
            // La y indica la potenza a cui elevare per ricavare i decimali
            if (ai[0] == '3' && ai.length == 4) {
                var power = Math.pow(10, parseInt(ai.substr(3, 1)));
                var num = parseInt(barcode.Result[obj.Column]);
                barcode.Result[obj.Column] = (num / power).toString();
            }

            res = res.substr(eIdx);
        }
    }

    return (barcode.Result != null);
}
