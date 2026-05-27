{*
    SBPP Windmill Dashboard v2 — chrome / core/footer.tpl

    Closes <main> + the page footer + .main + .app, then mounts the
    drawer + palette scaffolds and loads Lucide + theme.js.

    Variable contract (assigned by web/pages/core/footer.php):
        $version              — panel version string e.g. "2.0.0"
        $git                  — git suffix string e.g. " | Git: abc123" or ""
        $palette_actions_json — server-encoded JSON blob (JSON_HEX_* safe)

    Layout note: <footer class="app-footer"> lives INSIDE <div class="main">
    (as its last flex item, after </main>). The sidebar's sticky containing
    block is .app; if the footer were a sibling of .app, .app's height would
    fall short and the sticky sidebar would release at the bottom of shorter
    pages. Keeping the footer inside .app keeps the containing block at full
    document height. See theme.css .app-footer for the margin-top:auto
    sticky-footer pattern.

    The drawer (#drawer-root) and palette (#palette-root) are intentional
    siblings of .app, NOT nested inside it. They are position:fixed /
    top-layer overlays; nesting them inside .app risks the containing-block
    being re-established by any future transform/filter/contain on .app or
    a descendant, which would break their viewport-relative positioning.

    Removed from v1.8.x:
        - {$query nofilter}: referenced LoadServerHostProperty() from the
          now-deleted sourcebans.js. Dropped in SBPP v2.0.0.
        - MooTools window.addEvent('domready') block (commented out in v1,
          now removed entirely)
        - version.json Smarty include + regex parsing (theme version is
          visible in Admin → Settings → Themes via theme.conf.php)
*}
    </main>{* /.page — opened by core/title.tpl *}

    <footer class="app-footer sbpp-footer" data-version="{$version}" data-testid="app-footer">
        <a href="https://github.com/sbpp/sourcebans-pp" target="_blank" rel="noopener">SourceBans++</a>
        {$version}{$git}
        <span aria-hidden="true">·</span>
        <a href="https://github.com/DNA-styx/SBPP-Windmill-Dashboard-v2" target="_blank" rel="noopener">Windmill Dashboard</a>
        theme by DNA.styx
        <span aria-hidden="true">·</span>
        <a href="https://sbpp.github.io/sponsor/" target="_blank" rel="noopener">
            <i data-lucide="heart" aria-hidden="true" style="width:12px;height:12px"></i>
            Support SourceBans++
        </a>
    </footer>

  </div>{* /.main — opened by core/navbar.tpl *}
</div>{* /.app  — opened by core/header.tpl *}

{*
    Drawer scaffold — wired by theme.js to sb.api.call(Actions.BansDetail).
    The inner markup is rendered dynamically by theme.js on first open;
    this element ships empty + hidden as the deterministic initial state.
    Must be a sibling of .app, not nested inside it (see file header).
*}
<aside id="drawer-root"
       role="complementary"
       aria-label="Player details"
       data-drawer-open="false"
       hidden></aside>

{*
    Command palette dialog — wired by theme.js.
    Opened by Ctrl/Cmd+K or the topbar search button.
    data-palette-open mirrors open state for CSS selectors and tests.
    Ships hidden; theme.js calls showModal() to promote to top layer.
    Must be a sibling of .app (see file header).
*}
<dialog id="palette-root"
        class="palette"
        aria-label="Command palette"
        data-palette-open="false"
        hidden>
    <div class="palette__input">
        <i data-lucide="search" aria-hidden="true" style="width:14px;height:14px;color:var(--text-faint)"></i>
        <input id="palette-input"
               type="search"
               autocomplete="off"
               spellcheck="false"
               placeholder="Search players, SteamIDs, pages…"
               aria-label="Search players, SteamIDs, pages"
               data-testid="palette-input">
        <button type="button"
                class="btn btn--ghost btn--icon"
                data-palette-close
                data-testid="palette-close"
                aria-label="Close command palette"
                style="font-size:0.7rem">
            <kbd>Esc</kbd>
        </button>
    </div>
    <div id="palette-results"
         role="listbox"
         aria-label="Search results"
         data-testid="palette-results"
         style="max-height:60vh;overflow-y:auto;padding:0.5rem"></div>
</dialog>

{*
    Palette navigation entries — server-rendered, permission-filtered JSON
    blob consumed by theme.js at boot via loadNavItems(). Built by
    Sbpp\View\PaletteActions::for($userbank) in web/pages/core/footer.php.
    JSON_HEX_TAG|_AMP|_APOS|_QUOT encoding means the blob cannot break out
    of its <script> wrapper. theme.js falls back to an empty list when the
    blob is absent, so the palette degrades gracefully.
    nofilter: server-encoded JSON — all potentially dangerous chars (<>&'")
    are escaped as \uXXXX sequences by JSON_HEX_* flags.
*}
<script type="application/json" id="palette-actions" data-testid="palette-actions">{$palette_actions_json nofilter}</script>

{*
    Lucide must load before theme.js so lucide.createIcons() is available
    when theme.js boots. Both are loaded from this theme's js/ directory.
*}
<script src="{$theme_url}/js/lucide.min.js"></script>
<script src="{$theme_url}/js/theme.js"></script>

{*
    comment-actions.js — document-level delegate for data-action="comment-delete"
    triggers across ban list, comms list, and admin moderation queues.
    Loaded from the panel's scripts/ directory (not theme-specific).
    Feature-detected — no-op on pages with no comment triggers.
*}
<script src="./scripts/comment-actions.js"></script>

</body>
</html>
