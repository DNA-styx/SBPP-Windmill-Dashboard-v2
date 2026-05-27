{*
    SBPP Windmill Dashboard v2 — page_dashboard.tpl

    Customised from the v2 default:
      - Stat cards use v1 Windmill-style coloured circular icon badges
        instead of the default minimal flat cards
      - Server tiles in the Servers widget are split: server name + IP
        link to the servers list page; a separate purple Connect button
        launches the steam:// URI. The external-link icon is removed.

    All testid hooks, variable contracts, and the server-tile hydration
    helper wiring are preserved unchanged from the v2 default.

    Variable contract (Sbpp\View\HomeDashboardView):
        $dashboard_title      — site name / intro heading
        $dashboard_text       — optional admin-authored intro (Markdown)
        $total_bans           — total bans all time
        $active_bans          — active bans currently in force
        $total_comms          — total comm blocks (mutes + gags)
        $total_servers        — total configured servers
        $total_blocked        — total blocked join attempts
        $players_banned       — array of recent ban objects
        $players_commed       — array of recent comm block objects
        $players_blocked      — array of recent blocked attempt objects
        $server_list          — array of server objects
        $announcement         — optional admin announcement object
        $dashboard_lognopopup — bool, suppress popup on blocked row click
        $can_add_ban          — bool, permission to add bans/comms
        $can_add_server       — bool, permission to add servers
        $access_bans          — bool, admin-level access (shows info bar)
        $IN_SERVERS_PAGE      — always false on dashboard (parity prop)
*}
<div class="p-6 space-y-6" style="max-width:1400px;margin:0 auto;width:100%">

    {* -- Page header -------------------------------------------------- *}
    <header data-testid="dashboard-header">
        <h1 style="font-size:var(--fs-2xl);font-weight:600;margin:0">
            {if $dashboard_title}{$dashboard_title}{else}Dashboard{/if}
        </h1>
    </header>

    {* -- Optional admin-authored intro -------------------------------- *}
    {if $dashboard_text}
    <section class="card" data-testid="dashboard-intro">
        <div class="card__body">
            {* nofilter: rendered by IntroRenderer (CommonMark, html_input=escape, allow_unsafe_links=false) *}
            {$dashboard_text nofilter}
        </div>
    </section>
    {/if}

    {* -- Stat cards: Windmill v1-style coloured circular icon badges --- *}
    <div class="grid gap-4" style="grid-template-columns:repeat(auto-fit,minmax(180px,1fr))">

        <div class="card" data-testid="dashboard-stat-servers">
            <div class="card__body flex items-center gap-4">
                <div style="width:3rem;height:3rem;border-radius:50%;background:#10b981;color:#fff;display:flex;align-items:center;justify-content:center;flex-shrink:0">
                    <i data-lucide="server" style="width:1.25rem;height:1.25rem"></i>
                </div>
                <div>
                    <div class="text-xs font-medium text-muted" style="text-transform:uppercase;letter-spacing:0.06em">Total Servers Protected</div>
                    <div class="tabular-nums font-semibold" style="font-size:1.25rem">{$total_servers|number_format}</div>
                </div>
            </div>
        </div>

        <div class="card" data-testid="dashboard-stat-total-bans">
            <div class="card__body flex items-center gap-4">
                <div style="width:3rem;height:3rem;border-radius:50%;background:#f97316;color:#fff;display:flex;align-items:center;justify-content:center;flex-shrink:0">
                    <i data-lucide="ban" style="width:1.25rem;height:1.25rem"></i>
                </div>
                <div>
                    <div class="text-xs font-medium text-muted" style="text-transform:uppercase;letter-spacing:0.06em">Total Players Banned</div>
                    <div class="tabular-nums font-semibold" style="font-size:1.25rem">{$total_bans|number_format}</div>
                </div>
            </div>
        </div>

        <div class="card" data-testid="dashboard-stat-comm-blocks">
            <div class="card__body flex items-center gap-4">
                <div style="width:3rem;height:3rem;border-radius:50%;background:#3b82f6;color:#fff;display:flex;align-items:center;justify-content:center;flex-shrink:0">
                    <i data-lucide="mic-off" style="width:1.25rem;height:1.25rem"></i>
                </div>
                <div>
                    <div class="text-xs font-medium text-muted" style="text-transform:uppercase;letter-spacing:0.06em">Total Comms Blocks</div>
                    <div class="tabular-nums font-semibold" style="font-size:1.25rem">{$total_comms|number_format}</div>
                </div>
            </div>
        </div>

        <div class="card" data-testid="dashboard-stat-blocked">
            <div class="card__body flex items-center gap-4">
                <div style="width:3rem;height:3rem;border-radius:50%;background:#14b8a6;color:#fff;display:flex;align-items:center;justify-content:center;flex-shrink:0">
                    <i data-lucide="hand" style="width:1.25rem;height:1.25rem"></i>
                </div>
                <div>
                    <div class="text-xs font-medium text-muted" style="text-transform:uppercase;letter-spacing:0.06em">Banned Players Blocked</div>
                    <div class="tabular-nums font-semibold" style="font-size:1.25rem">{$total_blocked|number_format}</div>
                </div>
            </div>
        </div>

    </div>

    {* -- Admins-only announcement strip ------------------------------- *}
    {if $announcement}
    <aside class="announcement-strip" data-testid="dashboard-announcement" aria-label="Latest announcement">
        <details>
            <summary>
                <i data-lucide="megaphone" aria-hidden="true" style="width:14px;height:14px;flex-shrink:0"></i>
                <span class="announcement-strip__title">{$announcement.title}</span>
                {if $announcement.published_human}
                <span class="announcement-strip__date text-faint" data-testid="dashboard-announcement-date">{$announcement.published_human}</span>
                {/if}
            </summary>
            {if $announcement.body_html}
            <div class="announcement-strip__body" data-testid="dashboard-announcement-body">
                {* nofilter: rendered by IntroRenderer *}
                {$announcement.body_html nofilter}
            </div>
            {/if}
            {if $announcement.url}
            <a class="announcement-strip__link" data-testid="dashboard-announcement-link"
               href="{$announcement.url}" target="_blank" rel="noopener noreferrer">
                Read more <i data-lucide="external-link" aria-hidden="true" style="width:13px;height:13px"></i>
            </a>
            {/if}
        </details>
    </aside>
    {/if}

    {* -- Recent bans + Servers (2-col) -------------------------------- *}
    <div class="grid gap-4" style="grid-template-columns:repeat(auto-fit,minmax(min(100%,320px),1fr))">

        <section class="card" data-testid="dashboard-recent-bans">
            <div class="card__header">
                <div>
                    <h3>Latest bans</h3>
                </div>
                <a class="btn btn--ghost btn--sm" href="?p=banlist">
                    View all <i data-lucide="arrow-right" style="width:14px;height:14px"></i>
                </a>
            </div>
            <div>
                {foreach $players_banned as $b}
                <a class="flex items-center gap-3 windmill-row"
                   style="border-bottom:1px solid var(--border);text-decoration:none;color:var(--text)"
                   href="{$b.search_link}"
                   data-testid="dashboard-ban-row"
                   data-id="{$b.bid}">
                    <div class="flex-1" style="min-width:0">
                        <div class="flex items-center gap-2">
                            <span class="font-medium text-sm truncate">
                                {if $b.short_name}{$b.short_name}{else}<span class="text-faint">no nickname</span>{/if}
                            </span>
                            <span class="pill pill--{$b.state}">{$b.state}</span>
                        </div>
                        <div class="text-xs text-muted truncate" style="margin-top:0.125rem">
                            {$b.length_human}{if $b.sname} · {$b.sname}{/if}{if $b.reason} · {$b.reason}{/if}
                        </div>
                    </div>
                    <div class="text-xs text-muted text-right" style="white-space:nowrap">{$b.banned_human}</div>
                </a>
                {foreachelse}
                <div class="empty-state" data-testid="dashboard-recent-bans-empty">
                    <span class="empty-state__icon" aria-hidden="true">
                        <i data-lucide="ban" style="width:18px;height:18px"></i>
                    </span>
                    <h4 class="empty-state__title">No bans yet</h4>
                    <p class="empty-state__body">Enforcement actions will show up here as soon as admins start moderating.</p>
                    {if $can_add_ban}
                        <div class="empty-state__actions">
                            <a class="btn btn--primary btn--sm"
                               href="?p=admin&amp;c=bans"
                               data-testid="dashboard-recent-bans-empty-add">
                                <i data-lucide="plus" style="width:13px;height:13px"></i>
                                Add a ban
                            </a>
                        </div>
                    {/if}
                </div>
                {/foreach}
            </div>
            <div class="windmill-card-footer" aria-hidden="true"></div>
        </section>

        {*
            Servers widget — customised from v2 default:
            - Outer row changed from <a> to <div> so only the server
              name/IP is a clickable link (not the entire row)
            - External-link icon removed
            - Purple Connect button added (steam:// URI)
            data-testid="server-tile" and data-id kept on the outer
            container so server-tile-hydrate.js still works correctly.
        *}
        <section class="card" data-testid="dashboard-servers">
            <div class="card__header">
                <div>
                    <h3>Servers</h3>
                </div>
                <a class="btn btn--ghost btn--sm" href="?p=servers">
                    View all <i data-lucide="arrow-right" style="width:14px;height:14px"></i>
                </a>
            </div>
            {if $access_bans}
            <div class="text-xs text-muted" style="border-bottom:1px solid var(--border);padding:0.625rem 1.25rem">
                <i data-lucide="info" style="width:12px;height:12px;vertical-align:-2px"></i>
                Open the servers page to manage players in real time.
            </div>
            {/if}
            <div data-server-hydrate="auto"
                 data-trunchostname="40">
                {foreach $server_list as $server}
                <div class="flex items-center gap-3 windmill-row"
                     style="border-bottom:1px solid var(--border)"
                     data-testid="server-tile"
                     data-id="{$server.sid}">
                    <span style="width:28px;height:28px;border-radius:var(--radius-sm);background:var(--bg-muted);display:grid;place-items:center;flex-shrink:0">
                        <img src="images/games/{$server.icon}" alt="" width="20" height="20">
                    </span>
                    <a class="flex-1"
                       style="min-width:0;text-decoration:none;color:var(--text)"
                       href="?p=servers&s={$server.index}">
                        <div class="font-medium text-sm truncate"
                             data-testid="server-host"
                             data-fallback="{$server.ip}:{$server.port}">{$server.ip}:{$server.port}</div>
                        <div class="text-xs text-muted truncate">{$server.ip}:{$server.port}</div>
                    </a>
                    <a class="btn btn--primary btn--sm windmill-connect-btn"
                       href="steam://connect/{$server.ip}:{$server.port}"
                       data-testid="server-connect"
                       style="flex-shrink:0">
                        <i data-lucide="play"></i>
                        Connect
                    </a>
                </div>
                {foreachelse}
                <div class="empty-state" data-testid="dashboard-servers-empty">
                    <span class="empty-state__icon" aria-hidden="true">
                        <i data-lucide="server" style="width:18px;height:18px"></i>
                    </span>
                    <h4 class="empty-state__title">No servers configured</h4>
                    <p class="empty-state__body">Add a server so visitors can see live status and connect from the panel.</p>
                    {if $can_add_server}
                        <div class="empty-state__actions">
                            <a class="btn btn--primary btn--sm"
                               href="?p=admin&amp;c=servers"
                               data-testid="dashboard-servers-empty-add">
                                <i data-lucide="plus" style="width:13px;height:13px"></i>
                                Add a server
                            </a>
                        </div>
                    {/if}
                </div>
                {/foreach}
            </div>
            <div class="windmill-card-footer" aria-hidden="true"></div>
        </section>

    </div>

    {* -- Blocked attempts + Recent comm blocks (2-col) ---------------- *}
    <div class="grid gap-4" style="grid-template-columns:repeat(auto-fit,minmax(360px,1fr))">

        <section class="card" data-testid="dashboard-blocked-attempts" data-lognopopup="{if $dashboard_lognopopup}1{else}0{/if}">
            <div class="card__header">
                <div>
                    <h3>Latest blocked attempts</h3>
                </div>
            </div>
            <div>
                {foreach $players_blocked as $p}
                <a class="flex items-center gap-3 windmill-row"
                   style="border-bottom:1px solid var(--border);text-decoration:none;color:var(--text)"
                   href="{$p.search_link}"
                   data-testid="dashboard-blocked-row" data-id="{$p.bid}">
                    <i data-lucide="hand" style="color:var(--text-muted);flex-shrink:0" class="windmill-row__icon-lg"></i>
                    <div class="flex-1" style="min-width:0">
                        <div class="font-medium text-sm truncate">
                            {if $p.short_name}{$p.short_name}{else}<span class="text-faint">no nickname</span>{/if}
                        </div>
                        <div class="text-xs text-muted truncate">{if $p.sname}{$p.sname}{else}—{/if}</div>
                    </div>
                    <div class="text-xs text-muted text-right" style="white-space:nowrap">{$p.blocked_human}</div>
                </a>
                {foreachelse}
                <div class="empty-state" data-testid="dashboard-blocked-attempts-empty">
                    <span class="empty-state__icon" aria-hidden="true">
                        <i data-lucide="hand" style="width:18px;height:18px"></i>
                    </span>
                    <h4 class="empty-state__title">No blocked attempts yet</h4>
                    <p class="empty-state__body">Once banned players try to rejoin, the SourceMod plugin will log every intercept here.</p>
                </div>
                {/foreach}
            </div>
            <div class="windmill-card-footer" aria-hidden="true"></div>
        </section>

        <section class="card" data-testid="dashboard-recent-comms">
            <div class="card__header">
                <div>
                    <h3>Latest comm blocks</h3>
                </div>
                <a class="btn btn--ghost btn--sm" href="?p=commslist">
                    View all <i data-lucide="arrow-right" style="width:14px;height:14px"></i>
                </a>
            </div>
            <div>
                {foreach $players_commed as $c}
                <a class="flex items-center gap-3 windmill-row"
                   style="border-bottom:1px solid var(--border);text-decoration:none;color:var(--text)"
                   href="{$c.search_link}"
                   data-testid="dashboard-comm-row" data-id="{$c.bid}">
                    <i data-lucide="{$c.lucide_icon}" style="color:var(--text-muted);flex-shrink:0" class="windmill-row__icon-lg"></i>
                    <div class="flex-1" style="min-width:0">
                        <div class="flex items-center gap-2">
                            <span class="font-medium text-sm truncate">
                                {if $c.short_name}{$c.short_name}{else}<span class="text-faint">no nickname</span>{/if}
                            </span>
                            <span class="pill pill--{$c.state}">{$c.state}</span>
                        </div>
                        <div class="text-xs text-muted truncate" style="margin-top:0.125rem">
                            {$c.length_human}{if $c.sname} · {$c.sname}{/if}{if $c.reason} · {$c.reason}{/if}
                        </div>
                    </div>
                    <div class="text-xs text-muted text-right" style="white-space:nowrap">{$c.banned_human}</div>
                </a>
                {foreachelse}
                <div class="empty-state" data-testid="dashboard-recent-comms-empty">
                    <span class="empty-state__icon" aria-hidden="true">
                        <i data-lucide="mic-off" style="width:18px;height:18px"></i>
                    </span>
                    <h4 class="empty-state__title">No comm blocks yet</h4>
                    <p class="empty-state__body">Mutes and gags issued from the panel or in-game will appear here.</p>
                    {if $can_add_ban}
                        <div class="empty-state__actions">
                            <a class="btn btn--primary btn--sm"
                               href="?p=admin&amp;c=comms"
                               data-testid="dashboard-recent-comms-empty-add">
                                <i data-lucide="plus" style="width:13px;height:13px"></i>
                                Add a comm block
                            </a>
                        </div>
                    {/if}
                </div>
                {/foreach}
            </div>
            <div class="windmill-card-footer" aria-hidden="true"></div>
        </section>

    {if $IN_SERVERS_PAGE}{* unreachable on dashboard — parity prop *}{/if}

</div>

{* A2S hydration for server tiles — must be deferred, after DOM is ready *}
<script src="./scripts/server-tile-hydrate.js" defer></script>
