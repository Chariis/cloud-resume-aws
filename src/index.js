$(document).ready(function (e) {
    $win = $(window);
    $navbar = $('#header');
    $toggle = $('.toggle-button');
    var width = $navbar.width();
    toggle_onclick($win, $navbar, width);

    // resize event
    $win.resize(function () {
        toggle_onclick($win, $navbar, width);
    });

    $toggle.click(function (e) {
        $navbar.toggleClass("toggle-left");
    })

});

function toggle_onclick($win, $navbar, width) {
    if ($win.width() <= 768) {
        $navbar.css({ left: `-${width}px` });
    } else {
        $navbar.css({ left: '0px' });
    }
}

// Updated strings to match your CV
var typed = new Typed('#typed', {
    strings: [
        'DevOps Engineer',
        'Cloud Engineer',
    ],
    typeSpeed: 50,
    backSpeed: 50,
    loop: true
});

var typed_2 = new Typed('#typed_2', {
    strings: [
        'DevOps Engineer',
        'Cloud Engineer',
    ],
    typeSpeed: 50,
    backSpeed: 50,
    loop: true
});

document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();

        document.querySelector(this.getAttribute('href')).scrollIntoView({
            behavior: 'smooth'
        });
    });
});

// --- Visitor Counter ---
const counters = document.querySelectorAll(".counter-number");

async function updateCounter() {

    // --- DYNAMICALLY GET API URL ---
    // This 'window.config.apiUrl' variable will come from the 'config.js'
    // file that our pipeline creates.
    // Note: The '/views' path is added here.
    const apiUrl = window.config.apiUrl + "/views";
    // ---------------------------------

    try {
        let response = await fetch(apiUrl);
        let data = await response.json();

        counters.forEach(counter => {
            counter.innerHTML = `👀 Views: ${data.views}`;
        });

    } catch (error) {
        console.error("Error fetching visitor count:", error);
        counters.forEach(counter => {
            counter.innerHTML = `👀 Views: -`;
        });
    }
}

// Call the function to update the counter
updateCounter();