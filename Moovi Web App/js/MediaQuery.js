function Media_Query() {

    var height = $(window).height();
    var width = $(window).width();

    // Width per device 3,5 pollici
    if (width <= 400) {

        // Cambio le dimensioni dei container dell'header
        $("#header .c1").css("width", "23.33%");
        $("#header .c3").css("width", "73.33%");

        // Il bottone per la home diventa M e non MOOVI
        $(".mo-btn-home").text("M");

        $("#pgPrelievi input[name='DataConsegna']").css("width", "150px");

        $("#pgRLRig .div-letture .tr-ardesc").show();
        $("#pgRLRig .div-letture .cl-ardesc").hide();
    }

    // Standard
    else {

        $("#header .c1").css("width", "33.33%");
        $("#header .c3").css("width", "63.33%");
        //$("#pgRLPiede .mo-card").last("div").css("width", "24%");
        $(".mo-btn-home").text("MOOVI");

        $("#pgPrelievi input[name='DataConsegna']").css("width", "200px");
        //alert("Largo " + width.toString());

        if (width > 800) {
            // ATTENZIONE per la riga uso la classe w3-hide perchè nel momento in qui viene lanciata la media query le righe non esistono
            $("#pgRLRig .div-letture .tr-ardesc").addClass("w3-hide");
            // ATTENZIONE per la colonna uso i metodi show e hide perchè la colonna nel momento in qui viene lanciata la media query è presente nella tabella
            $("#pgRLRig .div-letture .cl-ardesc").show();
        }
        else {
            $("#pgRLRig .div-letture .tr-ardesc").removeClass("w3-hide");
            $("#pgRLRig .div-letture .cl-ardesc").hide();
        }
    }
}


function Login_Media_Query() {

    var height = $(window).height();
    var width = $(window).width();

    // Width per device 3,5 pollici
    if (width <= 400) {
        $("#loginmain .div-input").removeClass("w3-margin-top");
        $("#loginmain .div-op").removeClass("w3-margin-bottom");
        $("#loginmain .div-btn").removeClass("w3-margin-bottom");
        $("#loginmain .div-btn button").removeClass("w3-margin-top");
        $("#loginmain i").removeClass("s30").addClass("s15");
    }

    //else {
    //    $("#loginmain .div-input").addClass("w3-margin-top");
    //    $("#loginmain .div-op").addClass("w3-margin-bottom");
    //    $("#loginmain .div-btn").addClass("w3-margin-bottom");
    //}

}