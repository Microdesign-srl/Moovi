<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="testbc.aspx.cs" Inherits="MooviWeb.testbc" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <script src="js/jquery-3.2.0.min.js"></script>
    <script src="js/Barcode.js"></script>
    <script src="js/Global.js"></script>
    <link href="style/w3.css" rel="stylesheet" />
    <link href="style/Style.css" rel="stylesheet" />
    <title>Test Barcode</title>
</head>
<body class="mo-darkblue">
    <script>
        $(document).ready(function () {

            $("#txtBC").focus();

            $("#btnTest").on("click", function () {
                TestBarcode();
            });

            $("#btnClear").on("click", function () {
                $("#txtBC").val("");
                $(".output").text("");
            });
        });

        // PRende il parametro Cd dal path 
        function getParameterByName(name) {
            var url = window.location.href;
            name = name.replace(/[\[\]]/g, "\\$&");
            var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
                results = regex.exec(url);
            if (!results) return null;
            if (!results[2]) return '';
            return decodeURIComponent(results[2].replace(/\+/g, " "));
        }

        function TestBarcode() {
            var cd_bc = getParameterByName("Cd");
            //Svuoto il risultato
            $(".output").text("");
            //Se il campo txt è pieno
            if (!fU.IsEmpty($("#txtBC").val())) {
                //Chiamata lato server per scaricare la cfg del bc
                Ajax_xMOBCCampo(cd_bc);
            }
            else
                alert("Codice BC non presente nel query-string (CASE SENSITIVE--> testbc.aspx?Cd=???)");
        }

        function Ajax_xMOBCCampo(cd_bc) {

            Params = JSON.stringify({
                Codice: cd_bc
            });
            $.ajax({
                url: "testbc.aspx/xmofn_xMOBarcode",
                async: false,
                data: Params,
                type: "POST",
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function (mydata) {
                    try {
                        var BC = new Barcode($.parseJSON(mydata.d));
                        //BC.Detail_Clear();         //Prima di annullare il BC pulisco il detail -*-
                        BC.SetCurrentBC(cd_bc);
                        //Testo il barcode
                        BC.Read($("#txtBC").val());
                        // A seconda del tipo mostro il risultato
                        switch (BC.CurrentBC.Tipo) {
                            case SSCC:
                                $(".output").text(BC.CurrentStr);
                                break;
                            case GS1:
                                var res = "";
                                //lettura effettuata a buon fine
                                $.each(BC.ResultList, function (key, val) {
                                    //dentro la mia variabile result è prensente:
                                    //key = nome della colonna intepretata, val = valore intepretata
                                    res += val + '<br />';
                                });

                                if (res == "")
                                    res = "Nessuna interpretazione valida per il barcode!";

                                $(".output").html(res);
                                break;
                            case STD:
                                //$(".output").text("Non implementato!");
                                var res = "";
                                var nRows = 0;
                                //Aggiunge la riga letta dal template
                                $.each(BC.Result, function (key, val) {
                                    nRows++;
                                    res += "(" + nRows + ")[" + key + "=]" + val + "; ";
                                });
                                $(".output").text(res);
                                break;
                            default:
                                $(".output").text("Non ho ENUM di interpretazione del Barcode!");
                        }
                    }
                    catch (err) {
                        alert(err.message);
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    Ajax_ErrOut(XMLHttpRequest, textStatus, errorThrown);
                }
            });
        }

    </script>
    <div class="w3-round-medium mo-foggy w3-display-middle w3-center" style="padding: 20px 20px;">
        <div class="w3-container w3-center">
            <label class="mo-title w3-centered w3-text-white">MOOVI</label>
        </div>
        <div class="w3-container w3-row mo-mt-8 w3-centered">
            <h4 class="w3-text-white mo-bold">BARCODE</h4>
            <input type="text" id="txtBC" class="w3-input w3-border w3-large" style="padding: 10px !important" />
            <button id="btnTest" class="w3-button w3-green w3-margin-top w3-center mo-padding-20-34">TEST</button>
            <button id="btnClear" class="w3-button w3-green w3-margin-top w3-center mo-padding-20-34">Clear</button>
        </div>
        <div class="w3-row w3-margin-top w3-center">
            <label class="output w3-text-white w3-large"></label>
        </div>
    </div>
</body>
</html>
