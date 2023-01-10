<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="testbc.aspx.cs" Inherits="MooviWeb.testbc" %>
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

            $("#txtBC").keyup(function (e) {
                switch (e.which) {
                    case 13:    //Invio
                        TestBarcode();
                        break;
                    default:
                        break;
                }
            });

            $("#btnTest").on("click", function () {
                TestBarcode();
            });

            $("#btnClear").on("click", function () {
                $("#txtBC").val("");
                $(".output").text("");
            });

            $("#txtBC").focus();

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
            $("#DetailBarcode .barcode").find("label").text("");
            $("#DetailBarcode .tot").text("0");
            $("#DetailBarcode .err").text("0");
            $("#DetailBarcode li.li-bc").remove();

            if (!fU.IsEmpty(cd_bc)) {
                //Se il campo txt è pieno
                if (!fU.IsEmpty($("#txtBC").val())) {
                    //Chiamata lato server per scaricare la cfg del bc
                    Ajax_xMOBCCampo(cd_bc);
                } else {
                    $(".output").text("Inserire un valore nel testo Barcode!");
                }
            } else {
                $(".output").text("Codice BC non presente nel query-string (ATTENZIONE CASE SENSITIVE--> testbc.aspx?Cd=???)");
            }
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
                    console.log($.parseJSON(mydata.d));
                    try {
                        var BC = new Barcode($.parseJSON(mydata.d));
                        console.log(BC);
                        //BC.Detail_Clear();         //Prima di annullare il BC pulisco il detail -*-
                        BC.SetCurrentBC(cd_bc);
                        //Testo il barcode
                        //Testo il barcode
                        var codice = $("#txtBC").val();
                        //Normalizza i dati letti
                        if (fU.IsChecked($("#chkNormalizza"))) {
                            codice = codice.replace(/\(/g, "").replace(/\)/g, "");
                        }
                        BC.Read(codice);
                        if (!fU.IsEmpty(BC.CurrentBC)) {
                            console.log(BC);
                            // A seconda del tipo mostro il risultato
                            switch (BC.CurrentBC.Tipo) {
                                case SSCC:
                                    $(".output").text(BC.CurrentStr);
                                    break;
                                case GS1:
                                    var res = "";
                                    var nRows = 0;
                                    //lettura effettuata a buon fine
                                    console.log(BC.Result);
                                    $.each(BC.ResultList, function (key, bc_val) {
                                        //dentro la mia variabile result è prensente:
                                        //key = nome della colonna intepretata, val = valore intepretata

                                        //Aggiunge la riga letta dal template
                                        var li = $("#DetailBarcode li.template").clone().removeClass("template").removeAttr("style").addClass("li-bc")
                                        nRows++;
                                        li.attr("lettura", nRows)
                                        li.find(".numero").html(nRows + ".&nbsp;&nbsp;");
                                        li.find(".codice").text(bc_val);

                                        $("#DetailBarcode ul").append(li);

                                    });

                                    if (BC.ResultIsValid == false)
                                        res = "Nessuna interpretazione valida per il barcode!";

                                    $(".output").text(res);
                                    break;
                                case STD:
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
                        } else {
                            $(".output").text("Impossibile interpretare il Barcode!");
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
    <div style="width: 100%">
        <div style="width: 60%" class="w3-round-medium mo-foggy w3-display-middle w3-center">
            <div class="w3-container w3-center">
                <label class="mo-title w3-centered w3-text-white">MOOVI</label>
            </div>
            <div class="lg-divinput">
                <label class="lg-loginfont w3-center">BARCODE</label><br />
                <input type="text" id="txtBC" style="width: 80%" class="lg-input" style="padding: 10px !important" value="" />
                <br />
                <br />
                <label class="w3-center">
                    <input id="chkNormalizza" value="true" type="checkbox" checked="checked" />
                    Normalizza</label>
                <br />
                <button id="btnTest" class="w3-button w3-green w3-margin-top w3-center mo-padding-20-34">Test</button>
                <button id="btnClear" class="w3-button w3-green w3-margin-top w3-center mo-padding-20-34">Clear</button>
            </div>
            <div class="w3-row w3-margin-top w3-center">
                <div id="DetailBarcode" class="lg-modal lg-gray lg-zindex-200 w3-margin-bottom">
                    <%-- Elenco bc interpretati --%>
                    <ul class="w3-ul lg-ul lg-gray">
                        <li class="template w3-white" style="display: none;">
                            <span class="numero mo-display-inlineblock w3-left lg-fontblue"></span>
                            <span class="codice mo-display-inlineblock w3-margin-right"></span>
                        </li>
                    </ul>
                </div>
                <label class="output w3-large"></label>
            </div>
        </div>
    </div>
</body>
</html>
