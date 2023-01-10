function readAllBarcodes(BC, value) {
    // Memorizzo la lista dei barcode in un array
    // Filtro solo i barcode con Posizione = 0
    var barcodes = [];
    Object.keys(BC.BarcodeList).forEach(function (key) {
        if (BC.BarcodeList[key].Posizione == 0)
            barcodes.push(BC.BarcodeList[key]);
    });
    // Per ogni barcode
    // Imposto il barcode
    // Interpreto il valore
    // Storicizzo i risultati
    var results = [];
    barcodes.forEach(function (barcode) {
        BC.Clear();
        BC.CurrentBC = barcode;
        BC.Read(value);
        //console.log(BC);
        //console.log(barcode);
        //console.log(BC.Result);
        //console.log(BC.Results);
        if (BC.Results.length > 0)
            BC.Results.forEach(function (result) {
                results.push({
                    value: BC.CurrentStr,
                    barcode: barcode,
                    result: result,
                    resultText: barcodeResultToString(result, barcode),
                    detailOn: BC.DetailOn,
                    resultIsValid: BC.ResultIsValid
                });
            });
    });
    return results;
}

function barcodeResultToString(result, barcode) {
    var decoded = [];
    Object.keys(result).forEach(function (key) {
        decoded.push("".concat(key, ": ", result[key]));
    });
    return "".concat("[", barcode.Cd_Tipo, "] ", decoded.join(", "));
}

function handleBarcodeSet(barcode) {
    oPrg.BC.CurrentBC = barcode.barcode;
    oPrg.BC.CurrentStr = barcode.value;
    oPrg.BC.Result = barcode.result;
    oPrg.BC.DetailOn = barcode.detailOn;
    oPrg.BC.ResultIsValid = barcode.resultIsValid;
}

function handleBarcode(id_lettura) {
    var handlers = {
        SSCC: handleBarcodeSSCC,
        GS1: handleBarcodeGS1,
        STD: handleBarcodeSTD
    }
    var handler = handlers[oPrg.BC.CurrentBC.Cd_Tipo];
    if (!handler) throw new Error("Non ho ENUM di interpretazione del Barcode!!");
    handler(id_lettura);
}

function handleBarcodeSSCC(id_lettura) {
    // INVENTARIO
    if (oPrg.ActivePageValue == enumPagine.pgINM2Rig) {
        var BCRes = Ajax_Sscc_Validate(oPrg.BC.CurrentStr);
        if (!fU.IsEmpty(BCRes)) {
            // Assegno subito nel campo la matricola letta
            // VA FATTO PER PRIMO PER MEMORIZZARE LA MATRICOLA UTILIZZATA POI in Change dell'articolo per la Giacenza, ecc...
            ActivePage().find("input[name='Cd_xMOMatricola']").val(oPrg.BC.CurrentStr).attr("disabled", true);
            Object.keys(BCRes).forEach(function (key) {
                var value = BCRes[key];
                //ASSEGNA il valore e il focus del campo (in modo da scatenarne i refresh)
                // La QtaEvadibile della matricola va assegnata al campo QtaRilevata
                ActivePage().find("[name='" + (key == "QtaEvadibile" ? "QtaRilevata" : key) + "']").val(value);
                //Scateno gli on-focus post assegnazione valore (esempio il GS1 contiene la lettura di Cd_AR ma non quello della quantità)
                switch (key.toLowerCase()) {
                    case "cd_ar":
                        // Scateno il change nel campo articolo in modo da attiare i controlli legati all'evento
                        ActivePage().find("input[name='Cd_AR']").change();
                        // ho inserito il codice articolo: devo in modo manuale settare il focus sulla quantità
                        ActivePage().find("input[name='QtaRilevata']").focus();
                        break;
                    case "qtaevadibile":
                        // non devo fare nulla
                        break;
                    default:
                        if (ActivePage().find("input[name='" + key + "']"))
                            ActivePage().find("input[name='" + key + "']").focus().attr("disabled", true);
                        break;
                }
            });
            // L'unita di misura la seleziono dopo il timer perchè prima ci sono i meccanismi standard in esecuzione che si attivando al focus sul campo qta
            setTimeout(function () {
                ActivePage().find("select[name='Cd_ARMisura']").val(BCRes.Cd_ARMisura.toUpperCase());
                ActivePage().find("input[name='QtaRilevata']").focus().select();
            }, 250);
        }
    } else {
        // Verifica il barcode letto e salva i dati come rilevazione letta
        // La funzione restituisce un messaggio di conferma per il detail
        Ajax_Sscc_Validate(oPrg.BC.CurrentStr, id_lettura, true);
        // Se non è visibile il dettaglio imposta il focus sul campo SSCC
        if (!oPrg.BC.DetailOn)
            ActivePage().find(".div-barcode").find("input:first").focus().select();
    }
}

function handleBarcodeGS1(id_lettura) {
    // INVENTARIO
    if (oPrg.ActivePageValue == enumPagine.pgINM2Rig) {
        // Lettura effettuata a buon fine
        Object.keys(oPrg.BC.Result).forEach(function (key) {
            var value = oPrg.BC.Result[key];
            //Scateno gli on-focus post assegnazione valore (esempio il GS1 contiene la lettura di Cd_AR ma non quello della quantità)
            switch (true) {
                case key.toLowerCase() == "cd_ar":
                    // Scateno il change nel campo articolo in modo da attiare i controlli legati all'evento
                    // ho inserito il codice articolo: devo in modo manuale settare il focus sulla quantità
                    ActivePage().find("input[name='Cd_AR']").val(value).focus().change();
                    setTimeout(function () { ActivePage().find("input[name='QtaRilevata']").focus().select(); }, 250);
                    break;
                case key.toLowerCase() == "quantita":
                case key.toLowerCase().indexOf('quantita') > -1:
                    var decimali = key.substr(key.toLowerCase().indexOf('quantita') + 'quantita'.length);
                    if (decimali.length() > 0) // Il campo quantità definito nel BC possiede decimali 
                        value = "" + (value / (10 ** +decimali));
                    // se il key ha i decimali li tronco
                    key = key.substr(0, 'quantita'.length);
                    ActivePage().find("input[name='QtaRilevata']").val(value).focus();
                    break;
                default:
                    //ASSEGNA il valore e il focus del campo (in modo da scatenarne i refresh)
                    if (ActivePage().find("input[name='" + key + "']"))
                        ActivePage().find("input[name='" + key + "']").val(value).focus();
                    break;
            }
        });
    } else {
        for (var key in oPrg.BC.Result) {
            // Memorizzo il valore della property
            var value = oPrg.BC.Result[key];
            // Verifica dei valori da Assegnare
            switch (true) {
                case key.toLowerCase() == "cd_xmomatricola":
                    // Recupero i valori dalla matricola
                    var matricola = Ajax_xmofn_xMOMatricola_Info(value)[0];
                    if (matricola) {
                        ActivePage().find(".Cd_AR").text(matricola.Cd_AR);
                        ActivePage().find(".AR_Descrizione").text(matricola.AR_Descrizione);
                        ActivePage().find("input[name='Cd_AR']").val(matricola.Cd_AR);
                        ActivePage().find("input[name='Cd_ARLotto']").val(matricola.Cd_ARLotto);
                        ActivePage().find("input[name='DataScadenza']").val(fU.DateJsonToDate(matricola.DataScadenza));
                        ARARMisura_Set(matricola.Cd_ARMisura.toUpperCase());
                        ActivePage().find("input[name='Quantita']").val(matricola.QtaEvadibile);
                        ActivePage().find("input[name='Matricola']").val(matricola.Cd_xMOMatricola);
                        Quantita_Onfocus();
                        ActivePage().find("input[name='Cd_AR']").focus().select();
                    }
                    break;
                case key.toLowerCase() == "quantita":
                case key.toLowerCase().indexOf('quantita') > -1:
                    // Imposta i default dalla parametrizzazione del DOC
                    switch (oPrg.drDO.xMOQuantitaDef) {
                        case 0:
                            var decimali = key.substr(key.toLowerCase().indexOf('quantita') + 'quantita'.length);
                            if (decimali.length > 0) // Il campo quantità definito nel BC possiede decimali 
                                value = "" + (value / (10 ** +decimali));
                            if (value.toLowerCase() === 'nan') value = "0";
                            // se il key ha i decimali li tronco
                            key = key.substr(0, 'quantita'.length);
                            // Sostituisce l'eventuale virgola in separatore di decimali
                            value = value.replace(",", ".");
                            break;
                        case 1: // Una unita: sovrascrivo il valore letto
                            value = "1";
                            break;
                        case 2: // Totale prelevabile;
                            value = QtaTotalePrelevabile();
                            break;
                    }
                    break;
                case key.toLowerCase() == "datascadenza":
                case key.toLowerCase() == "datascadenzayymmdd":
                    key = "DataScadenza";
                    var yyyy = "20" + value[0] + value[1];
                    var mm = value[2] + value[3];
                    var dd = value[4] + value[5];
                    value = yyyy + "-" + mm + "-" + dd;
                    break;
                case key.toLowerCase() == "datascadenzaddmmyy":
                    key = "DataScadenza";
                    var yyyy = "20" + value[4] + value[5];
                    var mm = value[2] + value[3];
                    var dd = value[0] + value[1];
                    value = yyyy + "-" + mm + "-" + dd;
                    break;
            }
            //ASSEGNA il valore e il focus del campo (in modo da scatenarne i refresh)
            ActivePage().find("input[name='" + key + "']").val(value);
            //Scateno gli on-focus post assegnazione valore (esempio il GS1 contiene la lettura di Cd_AR ma non quello della quantità)
            switch (key.toLowerCase()) {
                case "cd_ar":
                    // ho inserito il codice articolo: devo in modo manuale settare il focus sulla quantità
                    ActivePage().find("input[name='Quantita']").focus();
                    break;
                // In datascadenza non va fatto il focus per evitare che in android venga aperto il datapicker
                case "datascadenza":
                    break;
                default:
                    if (ActivePage().find("input[name='" + key + "']"))
                        ActivePage().find("input[name='" + key + "']").focus();
            }
        }
    }
}

function handleBarcodeSTD(id_lettura) {
    // INVENTARIO
    if (oPrg.ActivePageValue == enumPagine.pgINM2Rig) {
        //lettura effettuata a buon fine
        Object.keys(oPrg.BC.Result).forEach(function (key) {
            var value = oPrg.BC.Result[key];
            //Verifica dei valori da Assegnare
            switch (true) {
                case key.toLowerCase() == "quantita":
                case key.toLowerCase().indexOf('quantita') > -1:
                    var decimali = key.substr(key.toLowerCase().indexOf('quantita') + 'quantita'.length);
                    if (decimali.length > 0) // Il campo quantità definito nel BC possiede decimali 
                        value = "" + (value / (10 ** +decimali));
                    if (value.toLowerCase() === 'nan') value = "0";
                    // se il key ha i decimali li tronco
                    key = key.substr(0, 'quantita'.length);
                    //Sostituisce l'eventuale virgola in separatore di decimali
                    value = value.replace(",", ".");
            }
            //Imposta il valore e il focus del campo (in modo da scatenarne i refresh)
            ActivePage().find("input[name='" + (key == "Quantita" ? "QtaRilevata" : key) + "']").val(value).focus();
            switch (key.toLowerCase()) {
                case "cd_ar":
                    // Scateno il change nel campo articolo in modo da attiare i controlli legati all'evento
                    ActivePage().find("input[name='Cd_AR']").change();
                    // ho inserito il codice articolo: devo in modo manuale settare il focus sulla quantità
                    ActivePage().find("input[name='QtaRilevata']").focus();
                    break;
                case "id_dorig":
                    break;
            }
        });
    } else {
        Object.keys(oPrg.BC.Result).forEach(function (key) {
            // Memorizzo il valore della property
            var value = oPrg.BC.Result[key];
            //Verifica dei valori da Assegnare
            switch (true) {
                case key.toLowerCase() == "quantita":
                case key.toLowerCase().indexOf('quantita') > -1:
                    var decimali = key.substr(key.toLowerCase().indexOf('quantita') + 'quantita'.length);
                    if (decimali.length > 0) // Il campo quantità definito nel BC possiede decimali 
                        value = "" + (value / (10 ** +decimali));
                    // se il key ha i decimali li tronco
                    key = key.substr(0, 'quantita'.length);
                    //Sostituisce l'eventuale virgola in separatore di decimali
                    value = value.replace(",", ".");
            }
            // Imposta il valore e il focus del campo (in modo da scatenarne i refresh)
            ActivePage().find("input[name='" + key + "']").val(value).focus();
            // Gestisco i campi
            switch (key.toLowerCase()) {
                case "cd_ar":
                    // Se inserisco il codice articolo, devo in modo manuale settare il focus sulla quantità
                    ActivePage().find("input[name='Quantita']").focus();
                    break;
                case "id_dorig":
                    // Scateno il change sul campo per recuperare i dati della riga 
                    ActivePage().find("input[name='Id_DORig']").change();
                    break;
            }
        });
    }
}