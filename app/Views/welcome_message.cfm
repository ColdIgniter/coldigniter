<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Welcome to ColdIgniter!</title>
    <meta name="description" content="The small framework with powerful features">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="shortcut icon" type="image/png" href="/favicon.ico">

    <!-- STYLES -->

    <style {csp-style-nonce}>
        * {
            transition: background-color 300ms ease, color 300ms ease;
        }
        *:focus {
            background-color: rgba(51, 102, 204, .2);
            outline: none;
        }
        html, body {
            color: rgba(33, 37, 41, 1);
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji";
            font-size: 16px;
            margin: 0;
            padding: 0;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
            text-rendering: optimizeLegibility;
        }
        header {
            background-color: rgba(247, 248, 249, 1);
            padding: .4rem 0 0;
        }
        .menu {
            padding: .4rem 2rem;
        }
        header ul {
            border-bottom: 1px solid rgba(242, 242, 242, 1);
            list-style-type: none;
            margin: 0;
            overflow: hidden;
            padding: 0;
            text-align: right;
        }
        header li {
            display: inline-block;
        }
        header li a {
            border-radius: 5px;
            color: rgba(0, 0, 0, .5);
            display: block;
            height: 44px;
            text-decoration: none;
        }
        header li.menu-item a {
            border-radius: 5px;
            margin: 5px 0;
            height: 38px;
            line-height: 36px;
            padding: .4rem .65rem;
            text-align: center;
        }
        header li.menu-item a:hover,
        header li.menu-item a:focus {
            background-color: rgba(51, 102, 204, .2);
            color: rgba(51, 102, 204, 1);
        }
        header .logo {
            float: left;
            height: 44px;
            padding: .4rem .5rem;
        }
        header .menu-toggle {
            display: none;
            float: right;
            font-size: 2rem;
            font-weight: bold;
        }
        header .menu-toggle button {
            background-color: rgba(51, 102, 204, .6);
            border: none;
            border-radius: 3px;
            color: rgba(255, 255, 255, 1);
            cursor: pointer;
            font: inherit;
            font-size: 1.3rem;
            height: 36px;
            padding: 0;
            margin: 11px 0;
            overflow: visible;
            width: 40px;
        }
        header .menu-toggle button:hover,
        header .menu-toggle button:focus {
            background-color: rgba(51, 102, 204, .8);
            color: rgba(255, 255, 255, .8);
        }
        header .heroe {
            margin: 0 auto;
            max-width: 1100px;
            padding: 1rem 1.75rem 1.75rem 1.75rem;
        }
        header .heroe h1 {
            font-size: 2.5rem;
            font-weight: 500;
        }
        header .heroe h2 {
            font-size: 1.5rem;
            font-weight: 300;
        }
        section {
            margin: 0 auto;
            max-width: 1100px;
            padding: 2.5rem 1.75rem 3.5rem 1.75rem;
        }
        section h1 {
            margin-bottom: 2.5rem;
        }
        section h2 {
            font-size: 120%;
            line-height: 2.5rem;
            padding-top: 1.5rem;
        }
        section pre {
            background-color: rgba(247, 248, 249, 1);
            border: 1px solid rgba(242, 242, 242, 1);
            display: block;
            font-size: .9rem;
            margin: 2rem 0;
            padding: 1rem 1.5rem;
            white-space: pre-wrap;
            word-break: break-all;
        }
        section code {
            display: block;
        }
        section a {
            color: rgba(51, 102, 204, 1);
        }
        section svg {
            margin-bottom: -5px;
            margin-right: 5px;
            width: 25px;
        }
        .further {
            background-color: rgba(247, 248, 249, 1);
            border-bottom: 1px solid rgba(242, 242, 242, 1);
            border-top: 1px solid rgba(242, 242, 242, 1);
        }
        .further h2:first-of-type {
            padding-top: 0;
        }
        .svg-stroke {
            fill: none;
            stroke: #000;
            stroke-width: 32px;
        }
        footer {
            background-color: rgba(51, 102, 204, .8);
            text-align: center;
        }
        footer .environment {
            color: rgba(255, 255, 255, 1);
            padding: 2rem 1.75rem;
        }
        footer .copyrights {
            background-color: rgba(62, 62, 62, 1);
            color: rgba(200, 200, 200, 1);
            padding: .25rem 1.75rem;
        }
        @media (max-width: 629px) {
            header ul {
                padding: 0;
            }
            header .menu-toggle {
                padding: 0 1rem;
            }
            header .menu-item {
                background-color: rgba(244, 245, 246, 1);
                border-top: 1px solid rgba(242, 242, 242, 1);
                margin: 0 15px;
                width: calc(100% - 30px);
            }
            header .menu-toggle {
                display: block;
            }
            header .hidden {
                display: none;
            }
            header li.menu-item a {
                background-color: rgba(51, 102, 204, .1);
            }
            header li.menu-item a:hover,
            header li.menu-item a:focus {
                background-color: rgba(51, 102, 204, .7);
                color: rgba(255, 255, 255, .8);
            }
        }
    </style>
</head>
<body>

<!-- HEADER: MENU + HEROE SECTION -->
<header>

    <div class="menu">
        <ul>
            <li class="logo">
                <a href="#">
                    <svg role="img" aria-label="ColdIgniter" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 120" height="44"><path fill="none" stroke="#3366cc" stroke-width="6" stroke-linecap="round" d="M52 60L52 13M52 32.7L40.2 23.5M52 32.7L63.8 23.5M52 45.9L44.9 40.4M52 45.9L59.1 40.4M52 60L92.7 36.5M75.6 46.4L77.7 31.5M75.6 46.4L89.5 52M64.2 52.9L65.5 44M64.2 52.9L72.6 56.3M52 60L92.7 83.5M75.6 73.6L89.5 68M75.6 73.6L77.7 88.5M64.2 67L72.6 63.7M64.2 67L65.5 76M52 60L52 107M52 87.3L63.8 96.5M52 87.3L40.2 96.5M52 74.1L59.1 79.6M52 74.1L44.9 79.6M52 60L11.3 83.5M28.4 73.6L26.3 88.5M28.4 73.6L14.5 68M39.8 67.1L38.5 76M39.8 67.1L31.4 63.7M52 60L11.3 36.5M28.4 46.4L14.5 52M28.4 46.4L26.3 31.5M39.8 52.9L31.4 56.3M39.8 52.9L38.5 44"/><text x="112" y="84" font-family="-apple-system,BlinkMacSystemFont,'Segoe UI',Helvetica,Arial,sans-serif" font-size="68" fill="#3366cc"><tspan font-weight="700">Cold</tspan><tspan font-weight="300">Igniter</tspan></text></svg>
                </a>
            </li>
            <li class="menu-toggle">
                <button id="menuToggle">&#9776;</button>
            </li>
            <li class="menu-item hidden"><a href="#">Home</a></li>
            <li class="menu-item hidden"><a href="https://github.com/ColdIgniter/coldigniter" target="_blank">GitHub</a></li>
        </ul>
    </div>

    <div class="heroe">

        <h1>Welcome to ColdIgniter <cfoutput>#static_("ColdIgniter\ColdIgniter").CI_VERSION#</cfoutput></h1>

        <h2>The small framework with powerful features</h2>

    </div>

</header>

<!-- CONTENT -->

<section>

    <h1>About this page</h1>

    <p>The page you are looking at is being generated dynamically by ColdIgniter.</p>

    <p>If you would like to edit this page you will find it located at:</p>

    <pre><code>app/Views/welcome_message.cfm</code></pre>

    <p>The corresponding controller for this page can be found at:</p>

    <pre><code>app/Controllers/Home.cfc</code></pre>

</section>

<div class="further">

    <section>

        <h1>Go further</h1>

        <h2>
            <svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 512 512'><line x1='176' y1='48' x2='336' y2='48' class="svg-stroke" /><line x1='118' y1='304' x2='394' y2='304' class="svg-stroke" /><path d='M208,48v93.48a64.09,64.09,0,0,1-9.88,34.18L73.21,373.49C48.4,412.78,76.63,464,123.08,464H388.92c46.45,0,74.68-51.22,49.87-90.51L313.87,175.66A64.09,64.09,0,0,1,304,141.48V48' class="svg-stroke" /></svg>
            GitHub
        </h2>

        <p>ColdIgniter is a CFML port of CodeIgniter 4. The source code, the
            issues and the pull requests are in the
            <a href="https://github.com/ColdIgniter/coldigniter" target="_blank">GitHub repository</a>.</p>

    </section>

</div>

<!-- FOOTER: DEBUG INFO + COPYRIGHTS -->

<footer>
    <div class="environment">

        <p>Page rendered in {elapsed_time} seconds using {memory_usage} MB of memory.</p>

        <p>Environment: <cfoutput>#request.ENVIRONMENT#</cfoutput></p>

    </div>

    <div class="copyrights">

        <p>&copy; <cfoutput>#Year(Now())#</cfoutput> ColdIgniter. ColdIgniter is an open source project
            released under the MIT open source licence.</p>

    </div>

</footer>

<!-- SCRIPTS -->

<script {csp-script-nonce}>
    document.getElementById("menuToggle").addEventListener('click', toggleMenu);
    function toggleMenu() {
        var menuItems = document.getElementsByClassName('menu-item');
        for (var i = 0; i < menuItems.length; i++) {
            var menuItem = menuItems[i];
            menuItem.classList.toggle("hidden");
        }
    }
</script>

<!-- -->

</body>
</html>
