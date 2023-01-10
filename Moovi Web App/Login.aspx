<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="MooviWeb.Login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <%--<meta name="mobile-web-app-capable" content="yes" />--%>
    <link rel="icon" href="image/moovi.ico" type="image/ico" sizes="16x16" />
    <title>MOOVI - Login</title>

    <script src="js/jquery-3.2.0.min.js"></script>
    <script src="js/injector.js"></script>

    <link href="style/w3.css" rel="stylesheet" />
    <link href="style/Style.css" rel="stylesheet" />
    <link href="style/MediaQuery.css" rel="stylesheet" />
    <link href="style/icon-library.css" rel="stylesheet" />
    <!-- Cache Busting -->
    <script>
        // CSS
        var styles = [/*"style/w3.css", "style/Style.css", "style/MediaQuery.css", "style/icon-library.css",*/ "style/pgMGDisp.css", "style/Detail_PackingList.css"];
        styles.forEach(function (item) { injectStyle(item); });
        // Scripts
        var scripts = ["js/ajax.js", "js/settings.js", "js/Global.js", "js/Login.js", "js/MediaQuery.js"];
        scripts.forEach(function (item) { injectScript(item); });

        window.addEventListener("load", function () {

            // Fondamentale per ajaxCall ed ajaxCallSync in ajax.js per capire da dove provengo!
            window.baseUrl = "Login.aspx";

            // Carica gli oggetti del local e session storage
            DataSession_Load();

            Ajax_GetDitta();

            Login_Media_Query();

            // Visualizzazione della versione corrente
            $("#Versione").text("Ver. " + Versione);
            // Recupero la variabile di sessione oApp
            if (fU.GetSession("oApp") != null) oApp = fU.GetSession("oApp");

            // Se sono già loggato procedo su Moovi.aspx
            if (oApp.Logon)
                location.assign("Moovi.aspx");
            else
                // Altrimenti effettuo il reset di oApp
                oApp_Reset();

            // memorizzo il tipo di browser
            oApp.Browser = "<%=Request.Browser.Browser %>";

            // gestisco i cookies
            if (oLocalStorage.get("Ricordami", '') !== '') {
                $('#Ricordami').attr('checked', 'checked');
                $('#Cd_Operatore').val(oLocalStorage.get("Cd_Operatore"));
                $('#Password').val(oLocalStorage.get("Password"));
            } else {
                $('#Ricordami').removeAttr('checked');
                $('#Cd_Operatore').val('');
                $('#Password').val('');
            }

            $("input:visible:empty:first").focus();

            $(".execute").keyup(function (e) {
                switch (e.which) {
                    case 13:    //Invio
                        Ajax_LoginValidate();
                        break;
                    default:
                        break;
                }
            });
        });
    </script>

</head>
<body>


    <div id="pglogin" class="w3-centered">
        <div id="loginmain" class="w3-round-medium mo-foggy w3-display-middle mo-mb-5">
            <div class="w3-container w3-center">
                <label class="mo-title w3-centered w3-text-white">MOOVI</label>
            </div>
            <div class="div-input w3-container w3-margin-top w3-centered">
                <div class="div-op w3-row w3-margin-bottom">
                    <i class="mi s30 w3-text-white">group</i>
                    <input id="Cd_Operatore" type="text" class="execute w3-input w3-border-gray w3-border" />
                </div>
                <div class="w3-row">
                    <i class="mi s30 w3-text-white">lock</i>
                    <input id="Password" type="password" class="execute w3-input w3-border" />
                </div>
            </div>
            <div class="div-btn w3-container w3-section">

                <div class="w3-center mo-mb-5">
                    <button type="submit" class="w3-button w3-green w3-round-medium w3-margin-top" onclick="Ajax_LoginValidate();">LOGIN</button>
                </div>

                <div style="display: inline-block;">
                    <label class="w3-text-white">
                        <input id="Ricordami" class="w3-check" type="checkbox" />&nbsp;Ricordami</label>
                </div>

                <div class="w3-right" style="display: inline-block;">
                    <label id="Terminale" class="w3-text-white"><%=Request.UserHostAddress %></label>
                    <label id="Browser" class="w3-text-white"></label>
                </div>

                <div class="w3-center">
                    <label id="Versione" class="w3-centered w3-text-white"></label>
                    <br />
                    <label id="Ditta" class="w3-centered w3-text-white"></label>
                </div>

            </div>
        </div>
    </div>

    <%-- POPUP DEI MESSAGGI --%>
    <div id="PopupMsg" class="w3-modal">
        <div class="w3-modal-content w3-animate-zoom w3-card-4">
            <header class="w3-container mo-light-blue mo-shadow" style="height: 40px;">
                <span class="w3-right w3-xlarge w3-text-white mo-pointer" onclick="$('#PopupMsg').hide();">&times;</span>
                <label class="title w3-text-white w3-xlarge mo-bold">ERRORE</label>
            </header>
            <div class="w3-container w3-margin w3-padding-16 mo-ofy-auto">
                <label class="msg mo-font-darkgray mo-bold"></label>
                <div class="div-btn w3-row w3-margin-bottom w3-center">
                    <button class="w3-button w3-round-medium w3-green" onclick="$('#PopupMsg').hide();">OK</button>
                </div>
            </div>
        </div>
    </div>

</body>
</html>
