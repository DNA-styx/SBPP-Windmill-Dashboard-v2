{*
    SBPP Windmill Dashboard v2 — chrome / core/navbar.tpl

    Renders the sticky sidebar <aside> and opens <div class="main">.
    <div class="main"> is closed in core/footer.tpl.

    Variable contract (assigned by web/pages/core/navbar.php):
        $navbar    — array of public nav items with keys:
                     endpoint, title, description, state ('active'|'')
        $adminbar  — array of admin nav items with keys:
                     endpoint, title, state ('active'|'')
        $isAdmin   — bool, true if current user has any admin access
        $login     — bool, true if user is logged in
        $username  — string, current admin username (empty if not logged in)

    Also in scope from core/header.php and init.php:
        $logo      — logo path relative to theme URL (default: images/favicon.svg)
        $theme_url — absolute URL to this theme directory

    Endpoint → Lucide icon mapping is inline (the navbar.php variable
    contract does not include an icon field; adding one would require
    a core change outside the scope of a theme fork).

    Mobile sidebar: the hamburger button lives in core/title.tpl
    (data-mobile-menu). theme.js toggles data-mobile-open on this
    <aside> in response. No Alpine.js or custom JS required here.

    Removed from v1.8.x:
        - Duplicate <body> open tag (header.tpl owns it)
        - Alpine.js directives (@click, x-if, x-show, :class, x-data)
        - FontAwesome icons (fa fa-caret-right, fas fa-search)
        - Top bar search form (replaced by Ctrl+K command palette)
        - Profile dropdown menu (replaced by account/logout links below)
        - Theme toggle button (data-theme-toggle handled by theme.js)
        - Mobile menu overlay driven by Alpine isSideMenuOpen
*}
<aside class="sidebar" id="sidebar" data-mobile-open="false">

    {*
        Brand row — logo + site name.
        $logo is the operator-configurable logo path set in
        Admin → Settings → General → Logo path, resolved relative
        to this theme's directory. Defaults to images/favicon.svg.
        data-testid="sidebar-brand" is used by the sidebar-sticky
        regression spec to confirm the brand is visible at scroll bottom.
    *}
    <div class="sidebar__brand" data-testid="sidebar-brand">
        {*
            On desktop: logo links to home.
            On mobile: logo is hidden, hamburger button takes its place.
            The hamburger uses data-mobile-menu so theme.js closes the
            sidebar on click — same attribute as the topbar hamburger.
        *}
        <a href="index.php?p=home" class="sidebar__brand-home" aria-label="Go to dashboard">
            <img class="sidebar__brand-mark" src="{$theme_url}/{$logo}" alt="Site logo">
        </a>
        <button type="button"
                class="btn btn--ghost btn--icon sidebar-close-btn"
                data-mobile-menu
                data-testid="sidebar-close"
                aria-label="Close navigation menu"
                aria-controls="sidebar">
            <i data-lucide="menu" aria-hidden="true"></i>
        </button>
        <div>
            <div class="font-semibold text-sm">SourceBans++</div>
            <div style="font-size:0.6rem;color:var(--text-faint)">Windmill Dashboard</div>
        </div>
    </div>

    <nav class="sidebar__nav" role="navigation" aria-label="Primary">

        {* ---- Public pages ---- *}
        <div class="sidebar__section">
            {foreach from=$navbar item=nav}
                {if $nav.endpoint != 'admin'}
                    <a class="sidebar__link"
                       href="index.php?p={$nav.endpoint}"
                       data-testid="nav-{$nav.endpoint}"
                       title="{if $nav.endpoint == 'home'}This page shows an overview of the bans and servers.{elseif $nav.endpoint == 'servers'}All the servers and their status can be viewed here.{else}{$nav.description}{/if}"
                       {if $nav.state == 'active'}aria-current="page"{/if}>
                        <i data-lucide="{if $nav.endpoint == 'home'}layout-dashboard{elseif $nav.endpoint == 'banlist'}ban{elseif $nav.endpoint == 'commslist'}mic-off{elseif $nav.endpoint == 'submit'}flag{elseif $nav.endpoint == 'protest'}megaphone{elseif $nav.endpoint == 'servers'}server{else}circle{/if}" aria-hidden="true"></i>
                        {$nav.title}
                    </a>
                {/if}
            {/foreach}
        </div>

        {* ---- Admin pages (only shown to admins) ---- *}
        {if $isAdmin}
            <div class="sidebar__section">
                <div class="sidebar__section-label">Admin</div>
                {foreach from=$navbar item=nav}
                    {if $nav.endpoint == 'admin'}
                        <a class="sidebar__link"
                           href="index.php?p={$nav.endpoint}"
                           data-testid="nav-{$nav.endpoint}"
                           title="{$nav.description}"
                           {if $nav.state == 'active'}aria-current="page"{/if}>
                            <i data-lucide="shield" aria-hidden="true"></i>
                            {$nav.title}
                        </a>
                    {/if}
                {/foreach}
                {foreach from=$adminbar item=admin}
                    <a class="sidebar__link"
                       href="index.php?p=admin&c={$admin.endpoint}"
                       data-testid="nav-admin-{$admin.endpoint}"
                       {if $admin.state == 'active'}aria-current="page"{/if}>
                        <i data-lucide="{if $admin.endpoint == 'admins'}users{elseif $admin.endpoint == 'bans'}ban{elseif $admin.endpoint == 'comms'}mic-off{elseif $admin.endpoint == 'servers'}server{elseif $admin.endpoint == 'groups'}shield-check{elseif $admin.endpoint == 'settings'}settings{elseif $admin.endpoint == 'mods'}puzzle{else}circle{/if}" aria-hidden="true"></i>
                        {$admin.title}
                    </a>
                {/foreach}
            </div>
        {/if}

    </nav>

    {*
        Account section — pinned to the bottom of the sidebar.
        Shows username + logout when logged in, login link otherwise.
        The separator border mirrors the section-label treatment above.
    *}
    <div style="border-top:1px solid var(--border);padding:0.5rem;display:flex;flex-direction:column;gap:0.125rem;">
        {if $login}
            <a class="sidebar__link"
               href="index.php?p=account"
               data-testid="nav-account">
                <i data-lucide="user" aria-hidden="true"></i>
                <span style="flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{$username}</span>
            </a>
            <a class="sidebar__link"
               href="index.php?p=logout"
               data-testid="nav-logout">
                <i data-lucide="log-out" aria-hidden="true"></i>
                Logout
            </a>
        {else}
            <a class="sidebar__link"
               href="index.php?p=login"
               data-testid="nav-login">
                <i data-lucide="log-in" aria-hidden="true"></i>
                Login
            </a>
        {/if}

    </div>

</aside>

{* Opens the main content column — closed by core/footer.tpl *}
<div class="main">
