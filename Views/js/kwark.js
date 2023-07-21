$(document).ready(function(){
    // $(".kwark-footer-pillow").height( $(".kwark-footer").height() );
    $(window).resize(function(){

        $("#main").height( $("#window").height() - $(".kwark-footer").height() - $(".kwark-header").height() );
        $(".kwark-footer-pillow").height( $(".kwark-footer").height() );
        $(".kwark-header-pillow").height( $(".kwark-header").height() );
        $("#kwark-sidebar").height( $("#window").height() - $(".kwark-footer").height() - $(".kwark-header").height()  );
        $("#kwark-sidebar-pillow").width( $("#kwark-sidebar").width() );
    });
});