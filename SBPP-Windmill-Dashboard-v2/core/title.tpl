{*
    SBPP Windmill Dashboard v2 — chrome / core/title.tpl

    Renders the sticky topbar (mobile menu + links dropdown + palette
    trigger + theme toggle), the brand-colour page title bar, then
    opens <main class="page"> for the page content.

    Variable contract (assigned by web/pages/core/title.php):
        $title  — page title string
        $theme  — theme directory name (used for navbar_links.conf include)

    Also loaded here:
        assets/navbar_links.conf — assigns $link_array for the Links dropdown.
        Edit that file to customise the dropdown links.

    NOTE: <div class="main"> is opened at the end of core/navbar.tpl.
    <main class="page"> opened here is closed in core/footer.tpl.

    Removed from v1.8.x:
        - Dual search forms     (replaced by Ctrl+K command palette)
        - Breadcrumbs           (removed per v2 design)
        - Alpine.js modal backdrop (drawer scaffold in footer.tpl replaces it)
        - @click / x-if / x-show directives (replaced by data-* + theme.js)
*}

{* Load external links array into $link_array — no output *}
{include file="themes/{$theme}/assets/navbar_links.conf" scope="parent"}

    <header class="topbar" data-testid="topbar">

        {* Mobile hamburger — theme.js toggles data-mobile-open on #sidebar *}
        <button type="button"
                class="btn btn--ghost btn--icon"
                data-mobile-menu
                data-testid="mobile-menu-toggle"
                aria-label="Open navigation menu"
                aria-controls="sidebar">
            <i data-lucide="menu" aria-hidden="true"></i>
        </button>

        <div style="flex:1"></div>

        {*
            Command palette trigger — icon-only at all viewports.
            theme.js listens for data-palette-open clicks.
        *}
        <button type="button"
                class="btn btn--ghost btn--icon"
                data-palette-open
                data-testid="palette-trigger"
                aria-label="Open command palette (Ctrl+K)">
            <i data-lucide="search" aria-hidden="true"></i>
            <span class="topbar__search-label" aria-hidden="true">Search</span>
            <kbd class="topbar__search-kbd" aria-hidden="true" data-modkey>Ctrl+K</kbd>
        </button>

        {*
            Theme toggle — cycles light → dark → system.
            theme.js listens for data-theme-toggle clicks.
            Icon and tooltip are updated by the sync script below.
        *}
        <button type="button"
                class="btn btn--ghost btn--icon"
                data-theme-toggle
                id="windmill-theme-btn"
                data-testid="theme-toggle"
                aria-label="System">
            <i data-lucide="monitor" aria-hidden="true" id="windmill-theme-icon"></i>
        </button>

        {*
            Links dropdown — external links from assets/navbar_links.conf.
            Sits to the right of the theme toggle.
            Uses native <details>/<summary> for open/close behaviour.
            A small inline script (below the header) closes it on outside click.
            CSS for positioning and styling lives in windmill-base.css.
        *}
        {if $link_array}
            <details class="links-dropdown" id="links-dropdown" data-testid="links-dropdown">
                <summary class="btn btn--ghost" aria-label="External links menu">
                    Links
                    <i data-lucide="chevron-down" aria-hidden="true" style="width:14px;height:14px"></i>
                </summary>
                <div class="links-dropdown__menu">
                    {foreach from=$link_array item=link_item}
                        <a class="links-dropdown__item"
                           href="{$link_item.1}"
                           target="_blank"
                           rel="noopener noreferrer">
                            <i data-lucide="external-link" aria-hidden="true" style="width:13px;height:13px;color:var(--text-faint)"></i>
                            {$link_item.0}
                        </a>
                    {/foreach}
                </div>
            </details>
        {/if}

    </header>

    {*
        Close the links dropdown when the user clicks anywhere outside it.
        Native <details> does not do this on its own.
        Scoped to #links-dropdown only — no global state touched.
    *}
    {if $link_array}
        <script>
        (function () {
            var d = document.getElementById('links-dropdown');
            if (!d) return;
            document.addEventListener('click', function (e) {
                if (d.open && !d.contains(e.target)) {
                    d.open = false;
                }
            }, true);
        })();
        </script>
    {/if}

    {*
        Theme toggle icon + tooltip sync.
        Updates the button icon and title attribute to reflect the
        current mode (light/dark/system) on page load and after each
        click. theme.js owns the actual toggle logic; this script only
        reads localStorage and updates the visual state.
        setTimeout(0) defers the post-click read until after theme.js
        has written the new value to localStorage.
    *}
    <script>
    (function () {
        var icons  = { light: 'sun', dark: 'moon', system: 'monitor' };
        var labels = { light: 'Light', dark: 'Dark', system: 'System' };

        function syncBtn() {
            var mode = 'system';
            try { mode = localStorage.getItem('sbpp-theme') || 'system'; } catch (e) {}
            var btn  = document.getElementById('windmill-theme-btn');
            var icon = document.getElementById('windmill-theme-icon');
            if (!btn || !icon) return;
            var label = labels[mode] || mode;
            btn.setAttribute('aria-label', label);
            btn.setAttribute('title', label);
            icon.setAttribute('data-lucide', icons[mode] || 'monitor');
            if (window.lucide) window.lucide.createIcons({ nodes: [icon] });
        }

        syncBtn();
        document.addEventListener('click', function (e) {
            if (e.target && e.target.closest('[data-theme-toggle]')) {
                setTimeout(syncBtn, 0);
            }
        });
    })();
    </script>

    {*
        Brand-colour page title bar.
        Rounded, padded, not full-width — styled in windmill-base.css.
    *}
    <div class="windmill-title-bar" data-testid="page-title-bar">
        {$title}
    </div>

    <main class="page">
