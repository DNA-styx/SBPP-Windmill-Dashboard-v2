<?php
// SourceBans++ (c) 2014-2026 SourceBans++ Dev Team
// Licensed under Creative Commons Attribution-NonCommercial-ShareAlike 3.0.
// See LICENSE.md for the full license text and THIRD-PARTY-NOTICES.txt for attributions.
//
// Theme metadata file. Shape mirrors web/themes/default/theme.conf.php;
// the panel reads these constants out of the global namespace at boot.

declare(strict_types=1);

// Theme display name — shown in the admin Themes picker.
define('theme_name', 'SourceBans++ Windmill Dashboard v2');

// Author byline — shown next to the screenshot in the picker.
define('theme_author', 'DNA.styx');

// Theme version — independent of the panel's `SB_VERSION`. Bump
// when the theme's chrome / tokens change in a way fork maintainers
// should know about.
define('theme_version', '2.0.0');

// Upstream link for the picker's "more info" affordance.
define('theme_link', 'https://github.com/DNA-styx/SBPP-Windmill-Dashboard-v2');

// Preview thumbnail — must live inside this theme's directory and
// render at a 250×170 aspect ratio (e.g. 640×435 at 2× DPI).
define('theme_screenshot', 'screenshot.jpg');