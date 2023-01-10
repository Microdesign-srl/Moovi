<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Info.aspx.cs" Inherits="MooviWeb.Info" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta name="viewport" content="width=device-width, initial-scale=1" />
    <script src="js/jquery-3.2.0.min.js"></script>
    <link href="style/w3.css" rel="stylesheet" />
    <title></title>
</head>
<script>
    function refresh() {
        $(document).ready(function () {
            $(".width").text($(window).width());
            $(".height").text($(window).height());
        });
    }
</script>
<body>
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <div class="w3-center w3-large">
        <button onclick="refresh();" class="w3-button">Ricarica</button>
        <label>Larghezza:&nbsp;</label><label class="width"></label>
        <label>Altezza:&nbsp;</label><label class="height"></label>
    </div>
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <br />
    <label>End</label>
</body>
</html>
