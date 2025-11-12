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
// This code is now live and points to your API!
const counters = document.querySelectorAll(".counter-number");

async function updateCounter() {

    // --- PASTE YOUR API URL HERE ---
    // Make sure to include the /views part!
    const apiUrl = "https://dwl6op0815.execute-api.us-east-1.amazonaws.com/views";
    // ---------------------------------

    try {
        let response = await fetch(apiUrl);
        let data = await response.json();

        // This 'data.views' must match the JSON key from your Lambda function
        // (which was json.dumps({'views': int(new_view_count)}))
        counters.forEach(counter => {
            counter.innerHTML = `👀 Views: ${data.views}`;
        });

    } catch (error) {
        console.error("Error fetching visitor count:", error);
        // If the API fails, just show a dash
        counters.forEach(counter => {
            counter.innerHTML = `👀 Views: -`;
        });
    }
}

// Call the function to update the counter
updateCounter();