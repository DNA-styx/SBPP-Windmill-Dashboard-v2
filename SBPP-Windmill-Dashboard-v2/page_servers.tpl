{*
    SBPP Windmill Dashboard v2 — page_servers.tpl

    Customised from v2 default. Changes from default:
      - Page h1 "Servers" heading removed
      - Summary rewritten to "Y of X online" via inline script
      - Action row reordered: Players | Refresh | Connect
      - Refresh promoted from icon-only ghost to btn--secondary btn--sm
        with icon + "Refresh" label
      - Connect pushed right via margin-left:auto
      - Connect hidden on mobile via .windmill-connect-btn

    Structure preserved EXACTLY from v2 default:
      - data-player-list ul inside server-players-panel (hydrator writes <li> here)
      - data-empty-message p inside server-players-panel
      - server-tile__mapimg class on map image
      - map image style matches AGENTS.md spec exactly
      - data-testid="servers-list" on grid container
      - data-opened-index="{$opened_server}"

    Variable contract (Sbpp\View\ServersView):
        $server_list          — array of server objects
        $can_add_server       — bool
        $can_use_context_menu — bool
        $opened_server        — int|null (deep-link auto-expand)
*}
<div class="p-6 space-y-6" style="max-width:1400px;margin:0 auto;width:100%">

    <header class="flex items-end justify-between gap-3" style="flex-wrap:wrap">
    {if $can_use_context_menu}
            <p class="servers-rcon-hint text-xs text-muted m-0" aria-hidden="true">
                <i data-lucide="mouse-pointer-2" style="width:11px;height:11px;vertical-align:-1px"></i>
                Right-click a player row for moderation actions
            </p>
        {/if}
    </header>

    {if !$server_list}
        <div class="card" data-testid="servers-empty">
            <div class="empty-state">
                <span class="empty-state__icon" aria-hidden="true">
                    <i data-lucide="server" style="width:18px;height:18px"></i>
                </span>
                <h2 class="empty-state__title">No servers configured yet</h2>
                <p class="empty-state__body">
                    Once you add a server, players, status, and live
                    counts will appear here for visitors.
                </p>
                {if $can_add_server}
                    <div class="empty-state__actions">
                        <a class="btn btn--primary btn--sm"
                           href="?p=admin&amp;c=servers"
                           data-testid="servers-empty-add">
                            <i data-lucide="plus" style="width:13px;height:13px"></i>
                            Add a server
                        </a>
                    </div>
                {/if}
            </div>
        </div>
    {else}
    <div class="servers-grid"
         data-testid="servers-list"
         data-server-hydrate="auto"
         data-opened-index="{$opened_server}"
         data-trunchostname="70">

        {foreach $server_list as $server}
        <article class="card"
                 data-testid="server-tile"
                 data-id="{$server.sid}"
                 data-index="{$server.index}"
                 data-status="loading"
                 data-expanded="false">
            <div class="card__body">
                <div class="flex items-start gap-3">
                    <span class="server-tile__mod"
                          aria-hidden="true"
                          style="width:36px;height:36px;border-radius:var(--radius-sm);background:var(--bg-muted);display:grid;place-items:center;flex-shrink:0;overflow:hidden">
                        {if $server.icon}
                            <img src="images/games/{$server.icon}"
                                 alt=""
                                 width="20"
                                 height="20"
                                 style="display:block">
                        {else}
                            <i data-lucide="server" style="width:18px;height:18px;color:var(--text-muted)"></i>
                        {/if}
                    </span>
                    <div style="flex:1;min-width:0">
                        <div class="font-semibold truncate"
                             data-testid="server-host"
                             data-fallback="{$server.ip}:{$server.port}"
                             title="{$server.ip}:{$server.port}">
                            {$server.ip}:{$server.port}
                        </div>
                        <div class="text-xs text-muted truncate" style="margin-top:0.125rem">
                            {if $server.mod}{$server.mod} &middot; {/if}<span class="windmill-copy-host"
                                data-copy="{$server.ip}:{$server.port}"
                                title="Click to copy">{$server.ip}:{$server.port}</span>
                        </div>
                    </div>
                    <span class="pill pill--offline"
                          data-testid="server-status"
                          aria-live="polite">
                        <i data-lucide="loader" style="width:10px;height:10px"></i>
                        <span data-status-label>Loading</span>
                    </span>
                </div>

                <dl class="grid gap-2 text-xs"
                    style="grid-template-columns:auto 1fr;align-items:center;margin-top:1rem;margin-bottom:0">
                    <dt class="text-muted flex items-center gap-1" style="margin:0">
                        <i data-lucide="map" style="width:13px;height:13px"></i> Map
                    </dt>
                    <dd class="text-muted" data-testid="server-map" style="margin:0">&mdash;</dd>

                    <dt class="text-muted flex items-center gap-1" style="margin:0">
                        <i data-lucide="users" style="width:13px;height:13px"></i> Players
                    </dt>
                    <dd class="tabular-nums font-medium"
                        data-testid="server-players"
                        style="margin:0;color:var(--text)">&mdash;</dd>
                </dl>

                <div class="server-tile__bar"
                     aria-hidden="true"
                     style="margin-top:0.5rem;height:6px;border-radius:var(--radius-full);background:var(--bg-muted);overflow:hidden">
                    <div data-players-bar
                         style="height:100%;background:var(--brand-600);width:0%;transition:width .25s ease"></div>
                </div>

                {* -- Action row: Players | Refresh | Connect (Connect rightmost) *}
                <div class="flex gap-2"
                     style="margin-top:1rem;border-top:1px solid var(--border);padding-top:0.75rem">
                    <button type="button"
                            class="btn btn--secondary btn--sm"
                            data-testid="server-toggle"
                            data-action="toggle-players"
                            aria-expanded="false"
                            aria-controls="server-players-{$server.sid}"
                            disabled>
                        <i data-lucide="chevron-down" style="width:13px;height:13px"></i>
                        Players
                    </button>
                    <button type="button"
                            class="btn btn--secondary btn--sm"
                            data-testid="server-refresh"
                            data-action="refresh"
                            aria-label="Refresh server status"
                            disabled>
                        <i data-lucide="refresh-cw" style="width:13px;height:13px"></i>
                        Refresh
                    </button>
                    <a class="btn btn--primary btn--sm windmill-connect-btn"
                       data-testid="server-connect"
                       data-connect-href="steam://connect/{$server.dns}:{$server.port}"
                       href="steam://connect/{$server.dns}:{$server.port}"
                       style="margin-left:auto">
                        <i data-lucide="play" style="width:13px;height:13px"></i>
                        Connect
                    </a>
                </div>

            </div>{* /.card__body *}

            {*
                Players panel — sibling of card__body, inside <article>.
                The hydrator writes player <li> rows into [data-player-list].
                Without data-player-list, renderPlayers() silently no-ops.
                data-empty-message is shown when server has 0 players.
                server-tile__mapimg class and exact inline style are
                required by AGENTS.md spec — do not change.
            *}
            <div id="server-players-{$server.sid}"
                 class="server-tile__players"
                 data-testid="server-players-panel"
                 hidden
                 style="border-top:1px solid var(--border);padding:0.75rem 1.25rem">
                <img src=""
                     alt=""
                     data-testid="server-map-img"
                     class="server-tile__mapimg"
                     hidden
                     style="display:block;width:100%;max-width:340px;height:auto;border-radius:var(--radius-sm);margin:0 auto 0.5rem;background:var(--bg-muted)">
                <p class="text-xs text-muted m-0" data-empty-message>No players currently connected.</p>
                <ul class="m-0" data-player-list style="list-style:none;padding:0;display:none"></ul>
            </div>

        </article>
        {/foreach}

    </div>
    {/if}

</div>

<script src="./scripts/server-tile-hydrate.js" defer></script>
{if $can_use_context_menu}
<script src="./scripts/server-context-menu.js" defer></script>
{/if}

{*
    Offline state handler.
    Watches data-status on each tile. When offline:
      - Replaces Connect <a> with disabled <span> (square/stop icon)
      - Keeps Players button disabled (hydrator already does this, but
        we also apply aria-disabled styling so it reads as visually
        disabled consistently)
    When online: restores Connect <a> if it was previously replaced.
*}
<script>
(function () {
    var CONNECT_WIDTH = null;

    function getConnectWidth() {
        if (CONNECT_WIDTH) return CONNECT_WIDTH;
        var online = document.querySelector('[data-testid="server-connect"]:not([aria-disabled])');
        if (online) CONNECT_WIDTH = Math.round(online.getBoundingClientRect().width) + 'px';
        return CONNECT_WIDTH || 'auto';
    }

    function updateTile(tile) {
        var status = tile.dataset.status;
        var connect = tile.querySelector('[data-testid="server-connect"]');
        var toggle  = tile.querySelector('[data-testid="server-toggle"]');
        if (!connect) return;

        if (status === 'offline') {
            if (connect.tagName === 'A') {
                var w = getConnectWidth();
                var span = document.createElement('span');
                span.className = connect.className;
                span.setAttribute('aria-disabled', 'true');
                span.setAttribute('data-testid', 'server-connect');
                span.style.cssText = 'margin-left:auto;opacity:0.5;pointer-events:none;cursor:default;flex-shrink:0;min-width:' + w + ';justify-content:center';
                span.innerHTML = '<i data-lucide="square" style="width:13px;height:13px"></i> Offline';
                connect.parentNode.replaceChild(span, connect);
                if (window.lucide) window.lucide.createIcons({ nodes: [span] });
            }
            if (toggle) {
                toggle.style.opacity = '0.5';
                toggle.style.pointerEvents = 'none';
                toggle.setAttribute('aria-disabled', 'true');
            }
        } else if (status === 'online') {
            if (connect.tagName === 'SPAN') {
                var href = tile.dataset.connectHref || connect.dataset.connectHref;
                var a = document.createElement('a');
                a.className = connect.className;
                a.setAttribute('data-testid', 'server-connect');
                a.setAttribute('href', href || '#');
                a.style.cssText = 'margin-left:auto;flex-shrink:0';
                a.innerHTML = '<i data-lucide="play" style="width:13px;height:13px"></i> Connect';
                connect.parentNode.replaceChild(a, connect);
                if (window.lucide) window.lucide.createIcons({ nodes: [a] });
            }
            if (toggle) {
                toggle.style.opacity = '';
                toggle.style.pointerEvents = '';
                toggle.removeAttribute('aria-disabled');
            }
        }
    }

    document.querySelectorAll('[data-testid="server-tile"]').forEach(function (tile) {
        new MutationObserver(function () { updateTile(tile); })
            .observe(tile, { attributes: true, attributeFilter: ['data-status'] });
        updateTile(tile);
    });
}());
</script>

{*
    Click-to-copy for server address.
    Document-level delegate on [data-copy] — never use stopPropagation.
    Falls back to execCommand if clipboard API unavailable.
    Shows a brief "Copied!" label in place of the address then restores.
*}
<script>
(function () {
    function copyText(text) {
        if (navigator.clipboard && navigator.clipboard.writeText) {
            return navigator.clipboard.writeText(text);
        }
        var ta = document.createElement('textarea');
        ta.value = text;
        ta.style.cssText = 'position:fixed;opacity:0';
        document.body.appendChild(ta);
        ta.select();
        try { document.execCommand('copy'); } catch (e) {}
        document.body.removeChild(ta);
        return Promise.resolve();
    }

    document.addEventListener('click', function (e) {
        var el = e.target && e.target.closest('[data-copy]');
        if (!el) return;
        var text = el.dataset.copy;
        if (!text) return;
        copyText(text).then(function () {
            var prev = el.textContent;
            el.textContent = 'Copied!';
            el.dataset.copied = 'true';
            setTimeout(function () {
                el.textContent = prev;
                delete el.dataset.copied;
            }, 1500);
        });
    });
}());
</script>

{*
    Player time formatter.
    The hydrator writes time_f values like "26:56" (MM:SS) or "1:26:56"
    (H:MM:SS). This normalises every cell to HH:MM:SS so the score
    column aligns regardless of session length.
    Watches each players panel via MutationObserver so it fires
    after the hydrator inserts rows.
*}
<script>
(function () {
    function padTime(raw) {
        if (!raw || typeof raw !== 'string') return raw;
        var parts = raw.trim().split(':');
        while (parts.length < 3) parts.unshift('00');
        return parts.map(function (p) { return p.padStart(2, '0'); }).join(':');
    }

    function formatPanel(panel) {
        panel.querySelectorAll('[data-testid="player-time"]').forEach(function (c) {
            if (!c.dataset.timeFormatted) {
                c.textContent = padTime(c.textContent);
                c.dataset.timeFormatted = '1';
            }
        });
    }

    document.querySelectorAll('[data-testid="server-players-panel"]').forEach(function (panel) {
        new MutationObserver(function () { formatPanel(panel); })
            .observe(panel, { childList: true, subtree: true });
    });
}());
</script>
