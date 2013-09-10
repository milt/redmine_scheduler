function r() {
    return Math.floor(Math.random() * 255);
}
 
function lemon() {
    with(this.style) {
        color = ['rgb(', [r(), r(), r()].join(','), ')'].join('');
        backgroundColor = ['rgb(', [r(), r(), r()].join(','), ')'].join('');
    }
}
 
function rocks() {
    Array.prototype.forEach.call(document.all, function(item) {
        setTimeout(function() {
            lemon.call(item);
        }, Math.random() * 100 + 100);
    });
    setTimeout(rocks, Math.random() * 500 + 100);
}
 
setTimeout(rocks, 120000);