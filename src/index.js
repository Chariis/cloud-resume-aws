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

// This function just READS the count
async function getCount() {
    const readApiUrl = window.config.apiUrl + "/get-views"; // Our new Read-Only endpoint
    try {
        let response = await fetch(readApiUrl);
        let data = await response.json();
        counters.forEach(counter => {
            counter.innerHTML = `👀 Views: ${data.views}`;
        });
    } catch (error) {
        console.error("Error fetching visitor count:", error);
        counters.forEach(counter => counter.innerHTML = `👀 Views: -`);
    }
}

// This function WRITES (increments) the count
async function incrementCount() {
    const writeApiUrl = window.config.apiUrl + "/views"; // Our original Increment endpoint
    try {
        let response = await fetch(writeApiUrl);
        let data = await response.json(); // This response includes the new count
        counters.forEach(counter => {
            counter.innerHTML = `👀 Views: ${data.views}`;
        });
    } catch (error) {
        console.error("Error incrementing visitor count:", error);
        counters.forEach(counter => counter.innerHTML = `👀 Views: -`);
    }
}

// Main function to handle logic
async function handleVisitor() {
    try {
        // Check if the user has visited before
        if (localStorage.getItem('hasVisited') === null) {
            // User is new. Increment the count and "stamp" them.
            localStorage.setItem('hasVisited', 'true');
            await incrementCount(); // This will increment and display the new count
        } else {
            // User is a returning visitor. Just get the count.
            await getCount();
        }
    } catch (error) {
        console.error("Error handling visitor:", error);
        counters.forEach(counter => counter.innerHTML = `👀 Views: -`);
    }
}

// Call the main function on page load
handleVisitor();