$(document).ready(function(){
    $(".container").hide();
    $(".bought").hide();

    window.addEventListener("message", function(event){
        var data = event.data
        result = data.result
        if (data.type == "open") {
            $(".container").fadeIn(500);
            document.getElementById("name").innerHTML = data.name
            document.getElementById("id").innerHTML = data.id
            $('#img1').attr('src',data.image);
            document.getElementById("price").innerHTML = data.price
        }
        if (data.type == "bought") {
            $(".bought").fadeIn(500);
            document.getElementById("warehouse-name").innerHTML = data.name
            $('#warehouse-img1').attr('src',data.image);
            document.getElementById("id2").innerHTML = data.id
            document.getElementById("price-wh").innerHTML = data.price
        }
    });

    $(document).on("click", "#close", function () {
        close()
    });

    $(document).on("click", "#warehouse-open", function () {
        var name = document.getElementById('warehouse-name').innerHTML;
        $.post('https://magni-warehouse/open', JSON.stringify({name: name}));
        $(".bought").fadeOut(500);
    });

    $(document).on("click", "#warehouse-buy", function () {
        var img1 = ($('#img1').attr('src'))
        var name = document.getElementById('name').innerHTML;
        var price = document.getElementById('price').innerHTML;
        var id = document.getElementById('id').innerHTML;
        $.post('https://magni-warehouse/buy', JSON.stringify({img1: img1, id: id, name: name, price: price}));
        $(".container").fadeOut(500);
    });

    $(document).on("click", "#warehouse-sell", function () {
        var name = document.getElementById('warehouse-name').innerHTML;
        var price = document.getElementById('price-wh').innerHTML;
        var id = document.getElementById('id2').innerHTML;

        $.post('https://magni-warehouse/sell', JSON.stringify({id: id, price: price,name: name}));
        $(".bought").fadeOut(500);
    });

    document.onkeydown = function (data) {
        if (data.which == 27) { 
            close()
            return
        } 
    };

    function close() { 
        $.post('https://magni-warehouse/close', JSON.stringify({display: false}));
        $(".container").fadeOut(500);
        $(".bought").fadeOut(500);
    }
})