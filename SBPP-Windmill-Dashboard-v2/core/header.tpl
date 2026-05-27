{*
    SBPP Windmill Dashboard v2 — chrome / core/header.tpl

    Renders <!DOCTYPE>, <head>, and the opening <body><div class="app">.

    Variable contract (assigned by web/pages/core/header.php and web/init.php):
        $title       — page title string
        $logo        — logo path relative to theme directory
        $theme       — theme directory name
        $theme_url   — absolute URL to theme directory (assigned by init.php)
        $csrf_token  — CSRF token string (assigned by init.php)

    Load order (order matters):
        1. Anti-FOUC bootloader inline script   — must precede the CSS link
        2. theme.css                            — base design system
        3. windmill-*.css                       — brand colour override
        4. api-contract.js, sb.js, api.js       — core panel scripts

    NOT loaded here (loaded by core/footer.tpl):
        lucide.min.js, theme.js, palette actions JSON blob

    Removed from v1.8.x:
        - mootools.js, sourcebans.js (removed in SBPP v2.0.0)
        - Alpine.js + init-alpine.js (dark mode now handled by theme.js)
        - tailwind.output.css (replaced by theme.css)
        - sbpp-windmill-dashboard.css (replaced by theme.css)
        - Google Fonts CDN link (Inter vendored in theme.css @font-face)
        - FontAwesome (replaced by Lucide icons via footer.tpl)
        - {$xajax} (xajax removed in SBPP v2.0.0)
*}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="csrf-token" content="{$csrf_token}">
    {*
        Opt the document out of phone/date/address auto-detection.
        SteamIDs and IP:port strings trigger false positives in Mobile
        Safari and Chrome, overlaying tap-to-dial links in the wrong
        accent colour over the text.
    *}
    <meta name="format-detection" content="telephone=no,date=no,address=no,email=no">
    <meta name="x-apple-data-detectors" content="false">
    <title>{$title}</title>

    {*
        Favicon set. Files live in the images/ directory of this theme.
        Replace the contents of images/ with your own artwork if desired;
        the filenames must stay the same as the links below reference them
        by name.
        Recommended sizes: favicon.svg (any), favicon.ico (48/32/16px),
        favicon-96x96.png, apple-touch-icon-180.png, and the two
        web-app-manifest PNGs (192×192, 512×512).
    *}
    <link rel="icon" type="image/svg+xml" href="{$theme_url}/images/favicon.svg">
    <link rel="icon" type="image/png" sizes="96x96" href="{$theme_url}/images/favicon-96x96.png">
    <link rel="alternate icon" type="image/x-icon" href="{$theme_url}/images/favicon.ico">
    <link rel="apple-touch-icon" sizes="180x180" href="{$theme_url}/images/apple-touch-icon-180.png">
    <link rel="manifest" href="{$theme_url}/images/site.webmanifest">

    {*
        Browser chrome bar colour (Android Chrome, Safari pinned tabs).
        Keep this in sync with --brand-600 in your active colour variant.
        Purple variant: #7c3aed
        Dark red variant: #4c1a1a
        Custom variant: set to your --brand-600 value
    *}
    <meta name="theme-color" content="#7c3aed">
    <meta name="theme-color" content="#09090b" media="(prefers-color-scheme: dark)">

    {*
        Anti-FOUC dark-mode bootloader.

        This MUST appear before the <link rel="stylesheet"> below.
        It reads the user's persisted theme preference from localStorage
        and adds class="dark" to <html> synchronously, before the
        browser parses <body>. Without it, every page load flashes white
        before dark mode is applied by theme.js.

        localStorage key 'sbpp-theme' accepts: 'light' | 'dark' | 'system'
        Default is 'system' (follows OS preference).

        Do NOT move this script to the footer or add defer/async —
        the network round-trip would defeat the purpose.
    *}
    <script>
    (function () {
        try {
            var m = localStorage.getItem('sbpp-theme') || 'system';
            var d = m === 'dark' || (m === 'system' && window.matchMedia
                && matchMedia('(prefers-color-scheme: dark)').matches);
            if (d) document.documentElement.classList.add('dark');
        } catch (e) { /* localStorage / matchMedia unavailable; default to light */ }
    })();
    </script>

    {* Base design system — layout, typography, components, dark mode tokens *}
    <link rel="stylesheet" href="{$theme_url}/css/theme.css">

    {* Windmill theme components — title bar, search inputs, links dropdown *}
    <link rel="stylesheet" href="{$theme_url}/css/windmill-base.css">

    {*
        Windmill colour variant — overrides brand token scale only.
        Ensure only ONE of these lines is uncommented at a time.
        See css/windmill-custom.css.template to create your own variant.
    *}
    <link rel="stylesheet" href="{$theme_url}/css/windmill-purple.css">
    {* <link rel="stylesheet" href="{$theme_url}/css/windmill-dark-red.css"> *}
    {* <link rel="stylesheet" href="{$theme_url}/css/windmill-custom.css"> *}

    {*
        Core panel scripts. These must be present on every page.
        api-contract.js  — autogenerated Actions.* and Perms.* constants
        sb.js            — DOM helpers and sb.api namespace
        api.js           — sb.api.call() JSON API client with CSRF header
    *}
    <script src="./scripts/api-contract.js"></script>
    <script src="./scripts/sb.js"></script>
    <script src="./scripts/api.js"></script>
</head>
<body>
<div class="app">
