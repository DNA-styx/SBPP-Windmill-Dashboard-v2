{*
    SBPP Windmill Dashboard v2 — page_comms.tpl

    Customised from v2 default (web/themes/default/page_comms.tpl).
    Changes from default:
      - max-width: 1700px → 1400px (matches dashboard/servers/bans)
      - h1 + "X of Y blocks" subtitle removed (purple title bar carries it)
      - Hide inactive toggle removed (cannot combine expired+unmuted
        in one SQL predicate without a backend change; chip strip
        covers per-state filtering individually)
      - Avatar circles replaced with state-based shield icons matching
        the ban list (shield-alert=active, shield-off=expired,
        shield-x=unmuted)
      - font-mono removed from SteamID column for visual consistency
      - Server dropdown hydrated with hostnames via Promise.all
        (same pattern as page_bans.tpl; uses $servers not $server_list)
      - windmill-row / windmill-row__icon-lg / windmill-card-footer
        classes applied for consistent row height and card chrome
      - Reason column title tooltip removed

    Selector / variable contract (Sbpp\View\CommsListView):
        $ban_list               — array of comm block objects
        $total_bans             — total comm blocks matching filters
        $is_active_only         — bool; true when hide-inactive is on
        $hide_inactive_toggle_url — URL to toggle hide-inactive
        $filters                — {search, server, time}
        $servers                — array of {sid, name} server objects
        $active_state           — current chip state slug ('' / 'active' / 'expired' / 'unmuted')
        $chip_base_link         — URL fragment preserving other active filters
        $is_advanced_search_open — bool
        $is_filtered            — bool (search/server/time/state active)
        $pagination             — {from, to, total, prev_url, next_url}
        $searchlink             — URL fragment for parity rule
        $can_add_comm           — bool
        $view_comments          — bool
        $hideadminname          — bool
*}
<div id="commslist-root" class="p-6 space-y-4" style="max-width:1400px;margin:0 auto">

    {* -- Export buttons if available ---------------------------------- *}
    {* No h1/subtitle — title bar carries "Comm Blocks" heading *}

    {* -- Sticky filter bar -------------------------------------------- *}
    <form method="get" action="index.php"
          id="comms-filters"
          style="position:sticky;top:3.5rem;z-index:20;background:var(--bg-page);padding:0.75rem 0">
        <input type="hidden" name="p" value="commslist">
        <div class="flex gap-3" style="flex-wrap:wrap">
            <div style="flex:1;min-width:14rem;max-width:24rem;position:relative">
                <input class="input"
                       type="search"
                       name="searchText"
                       value="{$filters.search|escape}"
                       placeholder="Player, SteamID, or reason&hellip;"
                       data-testid="comms-search"
                       aria-label="Search comm blocks">
            </div>
            <select class="select" name="server" style="width:auto;max-width:18rem" data-testid="comms-server-filter" aria-label="Filter by server">
                <option value="">All servers</option>
                {foreach $servers as $s}
                    <option value="{$s.sid}"
                            data-sid="{$s.sid}"
                            {if $filters.server == $s.sid}selected{/if}>{$s.name|escape}</option>
                {/foreach}
            </select>
            <select class="select" name="time" style="width:auto" data-testid="comms-time-filter" aria-label="Filter by time range">
                <option value="">All time</option>
                <option value="1d"  {if $filters.time == '1d'}selected{/if}>Today</option>
                <option value="7d"  {if $filters.time == '7d'}selected{/if}>Last 7 days</option>
                <option value="30d" {if $filters.time == '30d'}selected{/if}>Last 30 days</option>
            </select>
            <button class="btn btn--secondary btn--sm" type="submit" data-testid="comms-filter-apply">
                <i data-lucide="filter"></i> Apply
            </button>
        </div>

        {* Chip strip — buttons submit the filter form with name="state" *}
        <div class="flex items-center gap-2 mt-2 scroll-x" role="group" aria-label="Filter by status">
            <button type="submit" form="comms-filters" name="state" value=""
                    class="chip"
                    data-chip-state=""
                    data-testid="filter-chip-all"
                    data-active="{if $active_state == ''}true{else}false{/if}"
                    aria-pressed="{if $active_state == ''}true{else}false{/if}">All</button>
            <button type="submit" form="comms-filters" name="state" value="active"
                    class="chip"
                    data-chip-state="active"
                    data-testid="filter-chip-active"
                    data-active="{if $active_state == 'active'}true{else}false{/if}"
                    aria-pressed="{if $active_state == 'active'}true{else}false{/if}">
                <span class="chip__dot" style="background:#f59e0b"></span>Active
            </button>
            <button type="submit" form="comms-filters" name="state" value="expired"
                    class="chip"
                    data-chip-state="expired"
                    data-testid="filter-chip-expired"
                    data-active="{if $active_state == 'expired'}true{else}false{/if}"
                    aria-pressed="{if $active_state == 'expired'}true{else}false{/if}">
                <span class="chip__dot" style="background:var(--zinc-300)"></span>Expired
            </button>
            <button type="submit" form="comms-filters" name="state" value="unmuted"
                    class="chip"
                    data-chip-state="unmuted"
                    data-testid="filter-chip-unmuted"
                    data-active="{if $active_state == 'unmuted'}true{else}false{/if}"
                    aria-pressed="{if $active_state == 'unmuted'}true{else}false{/if}">
                <span class="chip__dot" style="background:#10b981"></span>Unmuted
            </button>
        </div>
    </form>
    <script>
    (function () {
        var state = new URLSearchParams(window.location.search).get('state') || '';
        document.querySelectorAll('[data-chip-state]').forEach(function (chip) {
            var active = chip.dataset.chipState === state;
            chip.dataset.active = active ? 'true' : 'false';
            chip.setAttribute('aria-pressed', active ? 'true' : 'false');
        });
    }());
    </script>

    {* -- Advanced search disclosure ----------------------------------- *}
    <details class="card filters-details"
             data-testid="commslist-advsearch-disclosure"
             {if $is_advanced_search_open}open{/if}>
        <summary class="filters-details__summary"
                 data-testid="commslist-advsearch-toggle"
                 aria-controls="commslist-advsearch-body">
            <span class="filters-details__summary-label">
                <i data-lucide="filter" style="width:14px;height:14px"></i>
                <span>Advanced search</span>
                {if $is_advanced_search_open}
                    <span class="filters-details__count" data-testid="commslist-advsearch-active">
                        &middot; 1 active
                    </span>
                {/if}
            </span>
            <i data-lucide="chevron-down" class="filters-details__chevron" style="width:14px;height:14px"></i>
        </summary>
        <div id="commslist-advsearch-body" class="filters-details__body">
            {load_template file="admin.comms.search"}
        </div>
    </details>

    {* -- Desktop table ------------------------------------------------ *}
    <div class="card" style="overflow:hidden">
        <div class="table-scroll">
        <table class="table">
            <thead>
                <tr>
                    <th scope="col">Player</th>
                    <th scope="col">Type</th>
                    <th scope="col">SteamID</th>
                    <th scope="col">Reason</th>
                    <th scope="col" class="col-tier-2">Server</th>
                    {if !$hideadminname}<th scope="col" class="col-admin col-tier-2">Admin</th>{/if}
                    <th scope="col" class="col-length col-tier-3">Length</th>
                    <th scope="col" class="col-banned col-tier-3">Started</th>
                    <th scope="col" class="col-status">Status</th>
                    <th scope="col" class="col-actions" aria-label="Row actions"></th>
                </tr>
            </thead>
            <tbody>
                {foreach from=$ban_list item=comm}
                <tr class="ban-row ban-row--{$comm.state}"
                    data-state="{$comm.state}"
                    data-id="{$comm.cid}"
                    data-testid="comm-row">
                    <td>
                        <div class="flex items-center gap-3" style="min-width:0">
                            <i data-lucide="{if $comm.state == 'active'}shield-alert{elseif $comm.state == 'expired'}shield-off{elseif $comm.state == 'unmuted'}shield-x{else}shield-alert{/if}"
                               style="color:var(--text-muted);flex-shrink:0"
                               class="windmill-row__icon-lg"
                               aria-hidden="true"></i>
                            <div style="min-width:0">
                                <a class="font-medium truncate"
                                   style="display:block;max-width:14rem;text-decoration:none;color:var(--text)"
                                   href="index.php?p=commslist&searchText={$comm.steam|escape:'url'}"
                                   data-drawer-cid="{$comm.cid}"
                                   data-testid="drawer-trigger">{$comm.name|escape}</a>
                                {if $comm.state == 'unmuted' && !$hideadminname && (!empty($comm.ureason) || !empty($comm.removedby))}
                                <div class="text-xs text-faint truncate"
                                     style="margin-top:0.125rem"
                                     title="{if !empty($comm.removedby)}Unmuted by {$comm.removedby|escape}{if !empty($comm.ureason)}: {/if}{/if}{if !empty($comm.ureason)}{$comm.ureason|escape}{/if}">
                                    {if !empty($comm.removedby)}Unmuted by {$comm.removedby|escape}{if !empty($comm.ureason)}: {/if}{/if}
                                    {if !empty($comm.ureason)}{$comm.ureason|escape}{/if}
                                </div>
                                {/if}
                                {if $view_comments && $comm.commentdata != "None" && $comm.commentdata|@count > 0}
                                <a class="ban-comments-inline__summary"
                                   style="display:inline-flex;align-items:center;gap:0.25rem;margin-top:0.125rem;font-size:0.75rem;color:var(--text-muted);text-decoration:none;cursor:pointer"
                                   data-drawer-cid="{$comm.cid}"
                                   data-testid="comm-comments-drawer-trigger"
                                   href="index.php?p=commslist&searchText={$comm.steam|escape:'url'}">
                                    <i data-lucide="message-square-text" style="width:11px;height:11px" aria-hidden="true"></i>
                                    <span class="tabular-nums">{$comm.commentdata|@count}</span>
                                    <span class="ban-comments-inline__label">comment{if $comm.commentdata|@count != 1}s{/if}</span>
                                </a>
                                {/if}
                            </div>
                        </div>
                    </td>
                    <td class="text-muted">
                        <div class="flex items-center gap-2">
                            <i data-lucide="{if $comm.type == 'mute'}mic-off{elseif $comm.type == 'gag'}message-square-off{else}volume-x{/if}" style="width:14px;height:14px;flex-shrink:0" aria-hidden="true"></i>
                            {if $comm.type == 'mute'}Mute{elseif $comm.type == 'gag'}Gag{elseif $comm.type == 'silence'}Silence{else}{$comm.type|escape}{/if}
                        </div>
                    </td>
                    <td class="text-xs text-muted">
                        {if empty($comm.steam)}<i class="text-faint">none</i>{else}{$comm.steam|escape}{/if}
                    </td>
                    <td class="text-muted truncate" style="max-width:18rem">
                        {if empty($comm.reason)}<i class="text-faint">no reason</i>{else}{$comm.reason|escape}{/if}
                    </td>
                    <td class="text-muted col-tier-2" data-sip="{$comm.sname|escape}">
                        {if empty($comm.sname)}<i class="text-faint">—</i>{else}{$comm.sname|escape}{/if}
                    </td>
                    {if !$hideadminname}
                    <td class="text-muted col-admin col-tier-2">
                        {if empty($comm.admin)}<i class="text-faint">—</i>{else}{$comm.admin|escape}{/if}
                    </td>
                    {/if}
                    <td class="text-muted col-length col-tier-3">{$comm.length_human|escape}</td>
                    <td class="text-muted col-banned col-tier-3">{$comm.started_human|escape}</td>
                    <td class="col-status">
                        <span class="pill pill--{$comm.state}">{$comm.state|escape}</span>
                    </td>
                    <td class="col-actions">
                        <div class="row-actions">
                            {if $can_unmute_gag && $comm.unmute_url}
                            <button type="button"
                                    class="btn btn--primary btn--sm"
                                    data-testid="row-action-unblock"
                                    data-action="comms-unblock"
                                    data-bid="{$comm.cid}"
                                    data-name="{$comm.name|escape}"
                                    data-fallback-href="{$comm.unmute_url|escape}"
                                    onclick="event.stopPropagation()">
                                <i data-lucide="check" style="width:13px;height:13px"></i>
                                {if $comm.type == 'mute'}Unmute{elseif $comm.type == 'gag'}Ungag{else}Lift block{/if}
                            </button>
                            {/if}
                        </div>
                    </td>
                </tr>
                {foreachelse}
                <tr>
                    <td colspan="10" style="padding:0">
                        {if $is_filtered}
                        <div class="empty-state" data-testid="comms-empty" data-filtered="true">
                            <span class="empty-state__icon" aria-hidden="true">
                                <i data-lucide="search-x" style="width:18px;height:18px"></i>
                            </span>
                            <h2 class="empty-state__title">No comm blocks match those filters</h2>
                            <p class="empty-state__body">Try a different search term or clear the active filters.</p>
                            <div class="empty-state__actions">
                                <a class="btn btn--secondary btn--sm" href="?p=commslist">
                                    <i data-lucide="x" style="width:13px;height:13px"></i>
                                    Clear filters
                                </a>
                            </div>
                        </div>
                        {else}
                        <div class="empty-state" data-testid="comms-empty" data-filtered="false">
                            <span class="empty-state__icon" aria-hidden="true">
                                <i data-lucide="mic-off" style="width:18px;height:18px"></i>
                            </span>
                            <h2 class="empty-state__title">No comm blocks recorded yet</h2>
                            <p class="empty-state__body">Mutes and gags issued from the panel or in-game will appear here.</p>
                            {if $can_add_comm}
                            <div class="empty-state__actions">
                                <a class="btn btn--primary btn--sm" href="?p=admin&amp;c=comms">
                                    <i data-lucide="plus" style="width:13px;height:13px"></i>
                                    Add a comm block
                                </a>
                            </div>
                            {/if}
                        </div>
                        {/if}
                    </td>
                </tr>
                {/foreach}
            </tbody>
        </table>
        </div>

        {* -- Mobile card list ----------------------------------------- *}
        <div class="ban-cards" data-testid="commslist-cards">
            {foreach from=$ban_list item=comm}
            <div class="ban-card ban-card--{$comm.state}" data-id="{$comm.cid}" data-testid="comm-card">
                <a class="ban-card__summary"
                   href="index.php?p=commslist&searchText={$comm.steam|escape:'url'}"
                   data-drawer-cid="{$comm.cid}"
                   data-testid="drawer-trigger">
                    <i data-lucide="{if $comm.state == 'active'}shield-alert{elseif $comm.state == 'expired'}shield-off{elseif $comm.state == 'unmuted'}shield-x{else}shield-alert{/if}"
                       style="color:var(--text-muted);flex-shrink:0"
                       class="windmill-row__icon-lg"
                       aria-hidden="true"></i>
                    <div style="min-width:0;flex:1">
                        <div class="flex items-center gap-2">
                            <span class="font-medium truncate">{$comm.name|escape}</span>
                            <span class="pill pill--{$comm.state}" style="flex-shrink:0">{$comm.state|escape}</span>
                        </div>
                        <div class="text-xs text-muted truncate" style="margin-top:0.125rem">
                            <i data-lucide="{if $comm.type == 'mute'}mic-off{elseif $comm.type == 'gag'}message-square-off{else}volume-x{/if}" style="width:11px;height:11px;flex-shrink:0" aria-hidden="true"></i>
                            {$comm.type_human|escape}{if !empty($comm.sname)} &middot; {$comm.sname|escape}{/if}{if !empty($comm.reason)} &middot; {$comm.reason|escape}{/if}
                        </div>
                        {if $comm.state == 'unmuted' && !$hideadminname && (!empty($comm.ureason) || !empty($comm.removedby))}
                        <div class="text-xs text-faint truncate" style="margin-top:0.125rem">
                            {if !empty($comm.removedby)}Unmuted by {$comm.removedby|escape}{if !empty($comm.ureason)}: {/if}{/if}
                            {if !empty($comm.ureason)}{$comm.ureason|escape}{/if}
                        </div>
                        {/if}
                        {if $view_comments && $comm.commentdata != "None" && $comm.commentdata|@count > 0}
                        <div class="text-xs text-faint truncate" style="margin-top:0.125rem;display:flex;align-items:center;gap:0.25rem" data-testid="comm-comments-count-mobile">
                            <i data-lucide="message-square-text" style="width:11px;height:11px" aria-hidden="true"></i>
                            <span class="tabular-nums">{$comm.commentdata|@count}</span>
                            <span>comment{if $comm.commentdata|@count != 1}s{/if}</span>
                        </div>
                        {/if}
                    </div>
                    <span class="text-faint" aria-hidden="true">&rsaquo;</span>
                </a>
                {if $can_unmute_gag && $comm.unmute_url}
                <div class="row-actions ban-card__actions">
                    <button type="button"
                            class="btn btn--primary btn--sm"
                            data-testid="row-action-unblock-mobile"
                            data-action="comms-unblock"
                            data-bid="{$comm.cid}"
                            data-name="{$comm.name|escape}"
                            data-fallback-href="{$comm.unmute_url|escape}">
                        <i data-lucide="check" style="width:13px;height:13px"></i>
                        {if $comm.type == 'mute'}Unmute{elseif $comm.type == 'gag'}Ungag{else}Lift block{/if}
                    </button>
                </div>
                {/if}
            </div>
            {foreachelse}
            <div class="ban-card" style="padding:1.5rem;text-align:center">
                {if $is_filtered}
                <p class="text-sm text-muted">No comm blocks match those filters. <a href="?p=commslist">Clear filters</a></p>
                {else}
                <p class="text-sm text-muted">No comm blocks recorded yet.</p>
                {/if}
            </div>
            {/foreach}
        </div>

        <div class="windmill-card-footer" aria-hidden="true"></div>
    </div>{* /.card *}

    {* -- Pagination --------------------------------------------------- *}
    {if $pagination.total > 0}
    <div class="flex items-center justify-between text-xs text-muted" data-testid="comms-pagination">
        <div>
            Showing
            <span class="font-medium tabular-nums" style="color:var(--text)">{$pagination.from|number_format}–{$pagination.to|number_format}</span>
            of
            <span class="font-medium tabular-nums" style="color:var(--text)">{$pagination.total|number_format}</span>
        </div>
        <div class="flex gap-1">
            {if $pagination.prev_url}
                <a class="btn btn--secondary btn--sm" href="{$pagination.prev_url|escape}" data-testid="page-prev">
                    <i data-lucide="chevron-left"></i> Prev
                </a>
            {else}
                <span class="btn btn--secondary btn--sm" aria-disabled="true" style="opacity:0.5;pointer-events:none" data-testid="page-prev">
                    <i data-lucide="chevron-left"></i> Prev
                </span>
            {/if}
            {if $pagination.next_url}
                <a class="btn btn--secondary btn--sm" href="{$pagination.next_url|escape}" data-testid="page-next">
                    Next <i data-lucide="chevron-right"></i>
                </a>
            {else}
                <span class="btn btn--secondary btn--sm" aria-disabled="true" style="opacity:0.5;pointer-events:none" data-testid="page-next">
                    Next <i data-lucide="chevron-right"></i>
                </span>
            {/if}
        </div>
    </div>
    {/if}

    {* Parity shadow — SmartyTemplateRule requires at least one reference *}
    <input type="hidden" form="comms-filters" name="_searchlink" value="{$searchlink|escape}" data-testid="comms-searchlink-shadow">

</div>

{* -- Unblock confirm dialog ------------------------------------------ *}
<dialog id="comms-unblock-dialog" hidden aria-labelledby="comms-unblock-dialog-title">
    <div class="card" style="min-width:min(24rem,90vw)">
        <div class="card__header">
            <div><h3 id="comms-unblock-dialog-title">Unblock player</h3></div>
            <button type="button" class="btn btn--ghost btn--icon" data-testid="comms-unblock-dialog-close" aria-label="Close">
                <i data-lucide="x" style="width:14px;height:14px"></i>
            </button>
        </div>
        <div class="card__body space-y-4">
            <p class="text-sm text-muted m-0">
                Unblocking <strong data-testid="comms-unblock-dialog-name"></strong>. A reason is required.
            </p>
            <div>
                <label class="label" for="comms-unblock-reason">Unblock reason</label>
                <input class="input" id="comms-unblock-reason" type="text" placeholder="Reason for unblocking…" data-testid="comms-unblock-reason" autocomplete="off">
                <p class="text-xs" style="color:var(--danger);margin:0.25rem 0 0;display:none" data-testid="comms-unblock-error" aria-live="polite"></p>
            </div>
        </div>
        <div class="card__body" style="border-top:1px solid var(--border);display:flex;gap:0.5rem;justify-content:flex-end">
            <button type="button" class="btn btn--secondary btn--sm" data-testid="comms-unblock-dialog-cancel">Cancel</button>
            <button type="button" class="btn btn--primary btn--sm" data-testid="comms-unblock-dialog-submit">
                <i data-lucide="check" style="width:13px;height:13px"></i>
                Confirm unblock
            </button>
        </div>
    </div>
</dialog>

{literal}
<script>
(function () {
    'use strict';
    var pending = null;

    function setBusy(btn, busy) {
        if (!btn) return;
        var S = window.SBPP;
        if (S && typeof S.setBusy === 'function') S.setBusy(btn, busy);
        else btn.disabled = !!busy;
    }
    function toast(kind, title, body) {
        var S = window.SBPP;
        if (S && typeof S.showToast === 'function') S.showToast({ kind: kind, title: title, body: body });
    }
    function rowsForCid(cid) {
        return Array.from(document.querySelectorAll('[data-id="' + cid + '"]'));
    }
    function flipRowToUnmuted(row) {
        row.dataset.state = 'unmuted';
        row.querySelectorAll('[data-action="comms-unblock"]').forEach(function (b) { b.remove(); });
        row.querySelectorAll('.pill').forEach(function (p) {
            p.className = 'pill pill--unmuted';
            p.textContent = 'unmuted';
        });
    }
    function closeDialog() {
        var d = document.getElementById('comms-unblock-dialog');
        if (d && d.open) d.close();
        pending = null;
        clearError();
    }
    function clearError() {
        var e = document.querySelector('[data-testid="comms-unblock-error"]');
        if (e) { e.style.display = 'none'; e.textContent = ''; }
    }
    function showError(msg) {
        var e = document.querySelector('[data-testid="comms-unblock-error"]');
        if (e) { e.style.display = ''; e.textContent = msg; }
    }

    var A = typeof sb !== 'undefined' ? sb.api : null;
    var Actions = typeof window.Actions !== 'undefined' ? window.Actions : {};

    document.addEventListener('click', function (e) {
        var t = e.target;
        if (!t) return;

        var unblockBtn = t.closest('[data-action="comms-unblock"]');
        if (unblockBtn) {
            e.preventDefault();
            pending = { cid: unblockBtn.dataset.cid, name: unblockBtn.dataset.name };
            var d = document.getElementById('comms-unblock-dialog');
            var nameEl = document.querySelector('[data-testid="comms-unblock-dialog-name"]');
            var reasonEl = document.getElementById('comms-unblock-reason');
            if (nameEl) nameEl.textContent = pending.name;
            if (reasonEl) reasonEl.value = '';
            clearError();
            if (d) { d.removeAttribute('hidden'); if (d.showModal) d.showModal(); }
            return;
        }

        if (t.closest('[data-testid="comms-unblock-dialog-cancel"]') || t.closest('[data-testid="comms-unblock-dialog-close"]')) {
            closeDialog();
            return;
        }

        var submitBtn = t.closest('[data-testid="comms-unblock-dialog-submit"]');
        if (submitBtn) {
            var ctx = pending;
            if (!ctx) return;
            var reason = (document.getElementById('comms-unblock-reason') || {}).value || '';
            if (!reason.trim()) { showError('Please enter an unblock reason.'); return; }
            setBusy(submitBtn, true);
            clearError();
            if (!A || !Actions.CommsUnblock) return;
            A.call(Actions.CommsUnblock, { cid: Number(ctx.cid), ureason: reason }).then(function (r) {
                setBusy(submitBtn, false);
                if (!r || r.ok === false) {
                    var msg = (r && r.error && r.error.message) || 'Unknown error';
                    showError(msg);
                    toast('error', 'Unblock failed', msg);
                    return;
                }
                rowsForCid(ctx.cid).forEach(flipRowToUnmuted);
                closeDialog();
                toast('success', 'Player unblocked', ctx.name + ' has been unblocked.');
            });
        }
    });

    document.addEventListener('cancel', function (e) {
        if (e.target && e.target.id === 'comms-unblock-dialog') { pending = null; clearError(); }
    });
}());
</script>
{/literal}

{*
    Server filter dropdown hostname hydration.
    Same Promise.all pattern as page_bans.tpl.
    Uses $servers (not $server_list) — CommsListView variable name.
*}
<script>
(function () {
    if (typeof sb === 'undefined' || typeof Actions === 'undefined') return;

    var opts = Array.from(document.querySelectorAll(
        '[data-testid="comms-server-filter"] option[data-sid]'
    ));
    if (!opts.length) return;

    Promise.all(opts.map(function (opt) {
        var sid = parseInt(opt.dataset.sid, 10);
        var fallback = opt.textContent.trim();
        return sb.api.call(Actions.ServersHostPlayers, { sid: sid })
            .then(function (r) {
                var label;
                if (r && r.data && r.data.error !== 'connect' && r.data.hostname) {
                    label = r.data.hostname + ' (' + r.data.ip + ':' + r.data.port + ')';
                    return { ip: r.data.ip, hostname: r.data.hostname, label: label, opt: opt, fallback: fallback };
                } else if (r && r.data && r.data.error === 'connect') {
                    label = 'Offline (' + r.data.ip + ':' + r.data.port + ')';
                    return { ip: r.data.ip, hostname: null, label: label, opt: opt, fallback: fallback };
                }
                return { ip: null, hostname: null, label: fallback, opt: opt, fallback: fallback };
            })
            .catch(function () {
                return { ip: null, hostname: null, label: fallback, opt: opt, fallback: fallback };
            });
    })).then(function (results) {
        var ipMap = {};
        results.forEach(function (r) {
            r.opt.textContent = r.label;
            if (r.ip && r.hostname) ipMap[r.ip] = r.hostname;
        });

        document.querySelectorAll('td[data-sip]').forEach(function (td) {
            var ip = (td.dataset.sip || '').split(':')[0];
            if (ip && ipMap[ip]) td.textContent = ipMap[ip];
        });

        var sel = document.querySelector('[data-testid="comms-server-filter"]');
        if (!sel) return;
        var cs = getComputedStyle(sel);
        var probe = document.createElement('span');
        probe.style.cssText = 'position:absolute;visibility:hidden;white-space:nowrap;font-size:' +
            cs.fontSize + ';font-family:' + cs.fontFamily +
            ';padding-left:' + cs.paddingLeft +
            ';padding-right:calc(' + cs.paddingRight + ' + 40px)';
        document.body.appendChild(probe);
        var maxW = 0;
        Array.from(sel.options).forEach(function (o) {
            probe.textContent = o.textContent;
            if (probe.offsetWidth > maxW) maxW = probe.offsetWidth;
        });
        document.body.removeChild(probe);
        if (maxW > 0) sel.style.width = maxW + 'px';
    });
}());
</script>

{* PHPStan dual-theme parity manifest — do not remove *}
{if false}{$ban_list}{$total_bans}{$is_active_only}{$hide_inactive_toggle_url}{$filters}{$servers}{$active_state}{$chip_base_link}{$is_advanced_search_open}{$is_filtered}{$pagination}{$searchlink}{$can_add_comm}{$view_comments}{$hideadminname}{$can_unmute_gag}{/if}
