{*
    SBPP Windmill Dashboard v2 — page_bans.tpl

    Customised from v2 default. Changes from default:
      - max-width: 1700px → 1400px (matches dashboard/servers)
      - h1 subtitle ("X of Y bans") removed
      - Hide inactive button: btn--ghost → btn--secondary
      - Copy SteamID button removed (desktop + mobile)
      - SteamID column: font-mono class removed

    All JS wiring, testids, unban dialog, pagination, mobile cards,
    advanced search, chip strip, and variable contract preserved exactly.

    Variable contract (Sbpp\View\BanListView) — unchanged from default.
*}

{* -- Comment edit mode -------------------------------------------- *}
{if $comment}
<div class="card" style="max-width:42rem;margin:1.5rem auto">
  <div class="card__header">
    <div>
      <h3>{$commenttype} comment</h3>
      <p>Visible to admins; commented threads also surface to the public when public comments are enabled.</p>
    </div>
  </div>
  <div class="card__body">
    <form id="banlist-comment-form" data-bid="{$comment}" data-ctype="{$ctype}" data-cid="{$cid}" data-page="{$page}">
      <label class="label" for="banlist-comment-text">Comment</label>
      <textarea class="textarea" id="banlist-comment-text" name="commenttext" rows="6" {if !$canedit}disabled{/if}>{$commenttext}</textarea>
      <div class="flex gap-2 mt-4">
        {if $canedit}
        <button class="btn btn--primary" type="submit">{$commenttype} comment</button>
        {/if}
        <button class="btn btn--secondary" type="button" onclick="history.back()">Back</button>
      </div>
    </form>
    <div class="mt-6">
      {foreach from=$othercomments item=com name=othercomments}
        {if $smarty.foreach.othercomments.first}<h3 style="font-size:var(--fs-base);font-weight:600;margin:0 0 0.5rem">Other comments</h3>{/if}
        <div class="mt-4" style="border-top:1px solid var(--border);padding-top:0.75rem">
          <div class="flex items-center justify-between">
            <strong>{$com.comname|escape}</strong>
            <span class="text-xs text-muted">{$com.added}</span>
          </div>
          {* nofilter: server-built HTML — encodePreservingBr + URL-wrap *}
          <div class="text-sm mt-2">{$com.commenttxt nofilter}</div>
          {if $com.editname != ''}
          <div class="text-xs text-faint mt-2">last edit {$com.edittime} by {$com.editname|escape}</div>
          {/if}
        </div>
      {/foreach}
    </div>
  </div>
</div>
{else}

{* -- max-width reduced to 1400px (default: 1700px) -- *}
<div id="banlist-root" class="p-6 space-y-4" style="max-width:1400px;margin:0 auto" data-loading="false">

  {* -- Page header: export buttons only, no h1, no hide inactive *}
  {if $can_export}
  <div class="flex gap-2 items-center">
    <a class="btn btn--secondary btn--sm" href="exportbans.php?type=steam" title="Export permanent SteamID bans">Export Steam</a>
    <a class="btn btn--secondary btn--sm" href="exportbans.php?type=ip" title="Export permanent IP bans">Export IP</a>
  </div>
  {/if}

  {* -- Sticky filter bar ------------------------------------------- *}
  <form method="get" action="index.php" id="banlist-filters" style="position:sticky;top:3.5rem;z-index:20;background:var(--bg-page);padding:0.75rem 0;border-bottom:1px solid var(--border)">
    <input type="hidden" name="p" value="banlist">
    <div class="flex gap-3" style="flex-wrap:wrap">
      <div style="flex:1;min-width:14rem;max-width:24rem;position:relative">
        <input class="input" type="search" name="searchText" data-testid="bans-search"
          value="{$filters.search|escape}"
          placeholder="Player, SteamID, or IP&hellip;" aria-label="Search bans">
      </div>
      <select class="select" name="server" style="width:auto;max-width:18rem" data-testid="bans-server-filter" aria-label="Filter by server">
        <option value="">All servers</option>
        {foreach $server_list as $s}
          <option value="{$s.sid}"
                  data-sid="{$s.sid}"
                  {if $filters.server == $s.sid}selected{/if}>{$s.name|escape}</option>
        {/foreach}
      </select>
      <select class="select" name="time" style="width:auto" data-testid="bans-time-filter" aria-label="Filter by time range">
        <option value="">All time</option>
        <option value="1d"  {if $filters.time == '1d'}selected{/if}>Today</option>
        <option value="7d"  {if $filters.time == '7d'}selected{/if}>Last 7 days</option>
        <option value="30d" {if $filters.time == '30d'}selected{/if}>Last 30 days</option>
      </select>
      <button class="btn btn--secondary btn--sm" type="submit" data-testid="bans-filter-apply">
        <i data-lucide="filter"></i> Apply
      </button>
    </div>

    {* Chip strip *}
    <div class="flex items-center gap-2 mt-2 scroll-x" role="group" aria-label="Filter by status">
      <a class="chip"
         href="index.php?p=banlist{$chip_base_link}"
         data-state-filter=""
         data-testid="filter-chip-all"
         data-active="{if $active_state == ''}true{else}false{/if}"
         aria-current="{if $active_state == ''}true{else}false{/if}">All</a>
      <a class="chip"
         href="index.php?p=banlist{$chip_base_link}&state=permanent"
         data-state-filter="permanent"
         data-testid="filter-chip-permanent"
         data-active="{if $active_state == 'permanent'}true{else}false{/if}"
         aria-current="{if $active_state == 'permanent'}true{else}false{/if}">
        <span class="chip__dot" style="background:#ef4444"></span>Permanent
      </a>
      <a class="chip"
         href="index.php?p=banlist{$chip_base_link}&state=active"
         data-state-filter="active"
         data-testid="filter-chip-active"
         data-active="{if $active_state == 'active'}true{else}false{/if}"
         aria-current="{if $active_state == 'active'}true{else}false{/if}">
        <span class="chip__dot" style="background:#f59e0b"></span>Active
      </a>
      <a class="chip"
         href="index.php?p=banlist{$chip_base_link}&state=expired"
         data-state-filter="expired"
         data-testid="filter-chip-expired"
         data-active="{if $active_state == 'expired'}true{else}false{/if}"
         aria-current="{if $active_state == 'expired'}true{else}false{/if}">
        <span class="chip__dot" style="background:var(--zinc-300)"></span>Expired
      </a>
      <a class="chip"
         href="index.php?p=banlist{$chip_base_link}&state=unbanned"
         data-state-filter="unbanned"
         data-testid="filter-chip-unbanned"
         data-active="{if $active_state == 'unbanned'}true{else}false{/if}"
         aria-current="{if $active_state == 'unbanned'}true{else}false{/if}">
        <span class="chip__dot" style="background:#10b981"></span>Unbanned
      </a>
    </div>
  </form>

  {* -- Advanced search disclosure ---------------------------------- *}
  <details class="card filters-details"
           data-testid="banlist-advsearch-disclosure"
           {if $is_advanced_search_open}open{/if}>
    <summary class="filters-details__summary"
             data-testid="banlist-advsearch-toggle"
             aria-controls="banlist-advsearch-body">
      <span class="filters-details__summary-label">
        <i data-lucide="filter" style="width:14px;height:14px"></i>
        <span>Advanced search</span>
        {if $is_advanced_search_open}
          <span class="filters-details__count" data-testid="banlist-advsearch-active">
            &middot; 1 active
          </span>
        {/if}
      </span>
      <i data-lucide="chevron-down" class="filters-details__chevron" style="width:14px;height:14px"></i>
    </summary>
    <div id="banlist-advsearch-body" class="filters-details__body">
      {load_template file="admin.bans.search"}
    </div>
  </details>

  {* -- Desktop table (>=769px) ------------------------------------- *}
  <div class="card" style="overflow:hidden">
    <div class="table-scroll">
    <table class="table">
      <thead>
        <tr>
          <th scope="col">Player</th>
          {* SteamID — font-mono removed for visual consistency *}
          <th scope="col">SteamID</th>
          {if !$hideplayerips}<th scope="col" class="col-ip col-tier-3">IP</th>{/if}
          <th scope="col">Reason</th>
          <th scope="col" class="col-tier-2">Server</th>
          {if !$hideadminname}<th scope="col" class="col-admin col-tier-2">Admin</th>{/if}
          <th scope="col" class="col-length col-tier-3">Length</th>
          <th scope="col" class="col-banned col-tier-3">Banned</th>
          <th scope="col" class="col-status">Status</th>
          <th scope="col" class="col-actions" aria-label="Row actions"></th>
        </tr>
      </thead>
      <tbody>
        {foreach from=$ban_list item=ban}
        <tr class="ban-row ban-row--{$ban.state}" data-state="{$ban.state}" data-id="{$ban.bid}" data-testid="ban-row">
          <td>
            <div class="flex items-center gap-3" style="min-width:0">
              <i data-lucide="{if $ban.state == 'permanent'}shield-ban{elseif $ban.state == 'active'}shield-alert{elseif $ban.state == 'expired'}shield-off{elseif $ban.state == 'unbanned'}shield-x{else}shield-ban{/if}"
                 style="color:var(--text-muted);flex-shrink:0"
                 class="windmill-row__icon-lg"
                 aria-hidden="true"></i>
              <div style="min-width:0">
                <a class="font-medium truncate"
                   style="display:block;max-width:14rem;text-decoration:none;color:var(--text)"
                   href="index.php?p=banlist&searchText={$ban.steam|escape:'url'}"
                   data-drawer-bid="{$ban.bid}"
                   data-testid="ban-player-link">{$ban.name|escape}</a>
                {if $ban.state == 'unbanned' && !$hideadminname && (!empty($ban.ureason) || !empty($ban.removedby))}
                <div class="text-xs text-faint truncate ban-unban-meta"
                     style="margin-top:0.125rem"
                     title="{if !empty($ban.removedby)}Unbanned by {$ban.removedby|escape}{if !empty($ban.ureason)}: {/if}{/if}{if !empty($ban.ureason)}{$ban.ureason|escape}{/if}">
                  {if !empty($ban.removedby)}Unbanned by {$ban.removedby|escape}{if !empty($ban.ureason)}: {/if}{/if}
                  {if !empty($ban.ureason)}{$ban.ureason|escape}{/if}
                </div>
                {/if}
                {if $view_comments && $ban.commentdata != "None" && $ban.commentdata|@count > 0}
                <details class="ban-comments-inline"
                         data-testid="ban-comments-inline"
                         data-bid="{$ban.bid}">
                  <summary class="ban-comments-inline__summary"
                           data-testid="ban-comments-toggle"
                           title="{$ban.commentdata|@count} comment{if $ban.commentdata|@count != 1}s{/if} on this ban">
                    <i data-lucide="message-square-text" style="width:11px;height:11px" aria-hidden="true"></i>
                    <span class="tabular-nums">{$ban.commentdata|@count}</span>
                    <span class="ban-comments-inline__label">comment{if $ban.commentdata|@count != 1}s{/if}</span>
                  </summary>
                  <ul class="ban-comments-inline__list" data-testid="ban-comments-list">
                    {foreach from=$ban.commentdata item=com}
                    <li class="ban-comments-inline__item" data-testid="ban-comment-item">
                      <div class="ban-comments-inline__meta">
                        {if !empty($com.comname)}
                          <strong>{$com.comname|escape}</strong>
                        {else}
                          <i class="text-faint">deleted admin</i>
                        {/if}
                        <span class="text-faint">&middot;</span>
                        <span class="text-xs text-faint tabular-nums">{$com.added}</span>
                      </div>
                      {* nofilter: server-built HTML — encodePreservingBr + URL-wrap *}
                      <div class="ban-comments-inline__text" data-testid="ban-comment-text">{$com.commenttxt nofilter}</div>
                      {if !empty($com.edittime)}
                      <div class="ban-comments-inline__edit text-xs text-faint">last edit {$com.edittime} by {if !empty($com.editname)}{$com.editname|escape}{else}<i>deleted admin</i>{/if}</div>
                      {/if}
                    </li>
                    {/foreach}
                  </ul>
                </details>
                {/if}
              </div>
            </div>
          </td>
          {* SteamID cell — font-mono removed *}
          <td class="text-xs text-muted">
            {if empty($ban.steam)}
              <i class="text-faint">none</i>
            {else}
              {$ban.steam|escape}
            {/if}
          </td>
          {if !$hideplayerips}
          <td class="col-ip col-tier-3 text-xs text-muted" data-testid="ban-ip">
            {if $ban.ban_ip_raw == ''}
              <i class="text-faint">none</i>
            {else}
              {$ban.ban_ip_raw|escape}
            {/if}
          </td>
          {/if}
          <td class="text-muted truncate" style="max-width:18rem">
            {if empty($ban.reason)}<i class="text-faint">no reason</i>{else}{$ban.reason|escape}{/if}
            {if $ban.state == 'unbanned' && !$hideadminname && (!empty($ban.ureason) || !empty($ban.removedby))}
            <div class="text-xs text-faint truncate"
                 style="margin-top:0.125rem"
                 title="{if !empty($ban.removedby)}Unbanned by {$ban.removedby|escape}{if !empty($ban.ureason)}: {/if}{/if}{if !empty($ban.ureason)}{$ban.ureason|escape}{/if}">
              {if !empty($ban.removedby)}Unbanned by {$ban.removedby|escape}{if !empty($ban.ureason)}: {/if}{/if}
              {if !empty($ban.ureason)}{$ban.ureason|escape}{/if}
            </div>
            {/if}
          </td>
          <td class="text-muted col-tier-2" data-sip="{$ban.sname|escape}">{if empty($ban.sname)}<i class="text-faint">—</i>{else}{$ban.sname|escape}{/if}</td>
          {if !$hideadminname}<td class="text-muted col-admin col-tier-2">{if empty($ban.adminname)}<i class="text-faint">—</i>{else}{$ban.adminname|escape}{/if}</td>{/if}
          <td class="text-muted col-length col-tier-3">{$ban.length_human|escape}</td>
          <td class="text-muted col-banned col-tier-3">{$ban.banned_human|escape}</td>
          <td class="col-status">
            <span class="pill pill--{$ban.state}">{$ban.state|escape}</span>
          </td>
          <td class="col-actions">
            <div class="row-actions">
              {if $view_bans}
              {if $ban.can_edit_ban && $ban.state != 'unbanned'}
              <a class="btn btn--ghost btn--sm" data-testid="row-action-edit"
                 href="index.php?p=admin&amp;c=bans&amp;o=edit&amp;id={$ban.bid}&amp;key={$admin_postkey|escape}"
                 onclick="event.stopPropagation()">
                  <i data-lucide="pencil" style="width:13px;height:13px"></i>
                  Edit
              </a>
              {/if}
              {if $ban.can_unban && $ban.state != 'unbanned' && $ban.state != 'expired'}
              <button type="button"
                      class="btn btn--secondary btn--sm"
                      data-testid="row-action-unban"
                      data-action="bans-unban"
                      data-bid="{$ban.bid}"
                      data-name="{$ban.name|escape}"
                      data-fallback-href="index.php?p=banlist&amp;a=unban&amp;id={$ban.bid}&amp;key={$admin_postkey|escape}"
                      onclick="event.stopPropagation()">
                  <i data-lucide="check" style="width:13px;height:13px"></i>
                  Unban
              </button>
              {/if}
              {if $can_add_ban && ($ban.state == 'expired' || $ban.state == 'unbanned') && !$ban.has_active_sibling}
              <a class="btn btn--secondary btn--sm" data-testid="row-action-reapply"
                 href="index.php?p=admin&amp;c=bans&amp;section=add-ban&amp;rebanid={$ban.bid}&amp;key={$admin_postkey|escape}"
                 onclick="event.stopPropagation()">
                  <i data-lucide="rotate-ccw" style="width:13px;height:13px"></i>
                  Re-apply
              </a>
              {/if}
              {/if}
              {* Copy SteamID button removed *}
              {if $ban.can_delete_ban}
              <button type="button"
                      class="btn btn--ghost btn--sm"
                      data-testid="row-action-delete"
                      data-action="bans-delete"
                      data-bid="{$ban.bid}"
                      data-name="{$ban.name|escape}"
                      data-fallback-href="index.php?p=banlist&amp;a=delete&amp;id={$ban.bid}&amp;key={$admin_postkey|escape}"
                      style="color:var(--danger)">
                  <i data-lucide="trash-2" style="width:13px;height:13px"></i>
                  Remove
              </button>
              {/if}
            </div>
          </td>
        </tr>
        {foreachelse}
        <tr>
          <td colspan="10" style="padding:0">
            {if $is_filtered}
            <div class="empty-state" data-testid="banlist-empty" data-filtered="true">
              <span class="empty-state__icon" aria-hidden="true">
                <i data-lucide="search-x" style="width:18px;height:18px"></i>
              </span>
              <h2 class="empty-state__title">No bans match those filters</h2>
              <p class="empty-state__body">Try a different search term or clear the active filters to see every recorded ban.</p>
              <div class="empty-state__actions">
                <a class="btn btn--secondary btn--sm" href="?p=banlist" data-testid="banlist-empty-clear">
                  <i data-lucide="x" style="width:13px;height:13px"></i>
                  Clear filters
                </a>
              </div>
            </div>
            {else}
            <div class="empty-state" data-testid="banlist-empty" data-filtered="false">
              <span class="empty-state__icon" aria-hidden="true">
                <i data-lucide="ban" style="width:18px;height:18px"></i>
              </span>
              <h2 class="empty-state__title">No bans recorded yet</h2>
              <p class="empty-state__body">Enforcement actions will show up here as soon as admins start moderating.</p>
              {if $can_add_ban}
              <div class="empty-state__actions">
                <a class="btn btn--primary btn--sm" href="?p=admin&amp;c=bans" data-testid="banlist-empty-add">
                  <i data-lucide="plus" style="width:13px;height:13px"></i>
                  Add a ban
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

    {* -- Mobile card list (<769px) ----------------------------------- *}
    <div class="ban-cards" data-testid="banlist-cards">
      {foreach from=$ban_list item=ban}
      <div class="ban-card ban-card--{$ban.state}" data-id="{$ban.bid}" data-testid="ban-card">
        <a class="ban-card__summary"
           href="index.php?p=banlist&searchText={$ban.steam|escape:'url'}"
           data-drawer-bid="{$ban.bid}"
           data-testid="drawer-trigger">
          <i data-lucide="{if $ban.state == 'permanent'}shield-ban{elseif $ban.state == 'active'}shield-alert{elseif $ban.state == 'expired'}shield-off{elseif $ban.state == 'unbanned'}shield-x{else}shield-ban{/if}"
             style="color:var(--text-muted);flex-shrink:0"
             class="windmill-row__icon-lg"
             aria-hidden="true"></i>
          <div style="min-width:0;flex:1">
            <div class="flex items-center gap-2">
              <span class="font-medium truncate">{$ban.name|escape}</span>
              <span class="pill pill--{$ban.state}" style="flex-shrink:0">{$ban.state|escape}</span>
            </div>
            <div class="text-xs text-muted truncate" style="margin-top:0.125rem">
              {$ban.length_human|escape}{if !empty($ban.sname)} &middot; {$ban.sname|escape}{/if}{if !empty($ban.reason)} &middot; {$ban.reason|escape}{/if}
            </div>
            {if !$hideplayerips && $ban.ban_ip_raw != ''}
            <div class="text-xs text-faint truncate" style="margin-top:0.125rem" data-testid="ban-ip-mobile">{$ban.ban_ip_raw|escape}</div>
            {/if}
            {if $ban.state == 'unbanned' && !$hideadminname && (!empty($ban.ureason) || !empty($ban.removedby))}
              <div class="text-xs text-faint truncate" style="margin-top:0.125rem" data-testid="ban-unban-meta-mobile"
                   title="{if !empty($ban.removedby)}Unbanned by {$ban.removedby|escape}{if !empty($ban.ureason)}: {/if}{/if}{if !empty($ban.ureason)}{$ban.ureason|escape}{/if}">
                {if !empty($ban.removedby)}Unbanned by {$ban.removedby|escape}{if !empty($ban.ureason)}: {/if}{/if}
                {if !empty($ban.ureason)}{$ban.ureason|escape}{/if}
              </div>
            {/if}
            {if $view_comments && $ban.commentdata != "None" && $ban.commentdata|@count > 0}
            <div class="text-xs text-faint truncate" style="margin-top:0.125rem;display:flex;align-items:center;gap:0.25rem" data-testid="ban-comments-count-mobile">
              <i data-lucide="message-square-text" style="width:11px;height:11px" aria-hidden="true"></i>
              <span class="tabular-nums">{$ban.commentdata|@count}</span>
              <span>comment{if $ban.commentdata|@count != 1}s{/if}</span>
            </div>
            {/if}
          </div>
          <span class="text-faint" aria-hidden="true">&rsaquo;</span>
        </a>
        {if $view_bans || $ban.can_delete_ban}
        <div class="row-actions ban-card__actions">
          {if $view_bans}
            {if $ban.can_edit_ban && $ban.state != 'unbanned'}
            <a class="btn btn--ghost btn--sm" data-testid="row-action-edit-mobile"
               href="index.php?p=admin&amp;c=bans&amp;o=edit&amp;id={$ban.bid}&amp;key={$admin_postkey|escape}">
                <i data-lucide="pencil" style="width:13px;height:13px"></i>
                Edit
            </a>
            {/if}
            {if $ban.can_unban && $ban.state != 'unbanned' && $ban.state != 'expired'}
            <button type="button"
                    class="btn btn--secondary btn--sm"
                    data-testid="row-action-unban-mobile"
                    data-action="bans-unban"
                    data-bid="{$ban.bid}"
                    data-name="{$ban.name|escape}"
                    data-fallback-href="index.php?p=banlist&amp;a=unban&amp;id={$ban.bid}&amp;key={$admin_postkey|escape}">
                <i data-lucide="check" style="width:13px;height:13px"></i>
                Unban
            </button>
            {/if}
            {if $can_add_ban && ($ban.state == 'expired' || $ban.state == 'unbanned') && !$ban.has_active_sibling}
            <a class="btn btn--secondary btn--sm" data-testid="row-action-reapply-mobile"
               href="index.php?p=admin&amp;c=bans&amp;section=add-ban&amp;rebanid={$ban.bid}&amp;key={$admin_postkey|escape}">
                <i data-lucide="rotate-ccw" style="width:13px;height:13px"></i>
                Re-apply
            </a>
            {/if}
          {/if}
          {* Copy SteamID button removed (mobile) *}
          {if $ban.can_delete_ban}
          <button type="button"
                  class="btn btn--ghost btn--sm"
                  data-testid="row-action-delete-mobile"
                  data-action="bans-delete"
                  data-bid="{$ban.bid}"
                  data-name="{$ban.name|escape}"
                  data-fallback-href="index.php?p=banlist&amp;a=delete&amp;id={$ban.bid}&amp;key={$admin_postkey|escape}"
                  style="color:var(--danger)">
              <i data-lucide="trash-2" style="width:13px;height:13px"></i>
              Remove
          </button>
          {/if}
        </div>
        {/if}
      </div>
      {foreachelse}
      <div class="ban-card" style="padding:1.5rem;text-align:center">
        {if $is_filtered}
        <p class="text-sm text-muted">No bans match those filters. <a href="?p=banlist">Clear filters</a></p>
        {else}
        <p class="text-sm text-muted">No bans recorded yet.</p>
        {/if}
      </div>
      {/foreach}
    </div>

  </div>{* /.card *}

  {* -- Pagination -------------------------------------------------- *}
  {if !empty($ban_nav)}
  <div class="card">
    <div class="card__body">
      <nav class="text-xs text-muted" aria-label="Ban list pagination">
        {* nofilter: server-built pagination HTML *}
        {$ban_nav nofilter}
      </nav>
    </div>
  </div>
  {/if}

  <div data-skeleton hidden aria-hidden="true">
    <div class="skel" style="height:2.5rem;margin-bottom:0.5rem"></div>
    <div class="skel" style="height:2.5rem;margin-bottom:0.5rem"></div>
    <div class="skel" style="height:2.5rem"></div>
  </div>

{/if}{* end comment/ban-list branch *}

{* -- Unban confirm dialog ---------------------------------------- *}
<dialog id="bans-unban-dialog" hidden aria-labelledby="bans-unban-dialog-title">
  <div class="card" style="min-width:min(24rem,90vw)">
    <div class="card__header">
      <div><h3 id="bans-unban-dialog-title">Unban player</h3></div>
      <button type="button" class="btn btn--ghost btn--icon" data-testid="bans-unban-dialog-close" aria-label="Close">
        <i data-lucide="x" style="width:14px;height:14px"></i>
      </button>
    </div>
    <div class="card__body space-y-4">
      <p class="text-sm text-muted m-0">
        Unbanning <strong data-testid="bans-unban-dialog-name"></strong>. A reason is required.
      </p>
      <div>
        <label class="label" for="bans-unban-reason">Unban reason</label>
        <input class="input" id="bans-unban-reason" type="text" placeholder="Reason for unbanning…" data-testid="bans-unban-reason" autocomplete="off">
        <p class="text-xs" style="color:var(--danger);margin:0.25rem 0 0;display:none" data-testid="bans-unban-error" aria-live="polite"></p>
      </div>
    </div>
    <div class="card__body" style="border-top:1px solid var(--border);display:flex;gap:0.5rem;justify-content:flex-end">
      <button type="button" class="btn btn--secondary btn--sm" data-testid="bans-unban-dialog-cancel">Cancel</button>
      <button type="button" class="btn btn--primary btn--sm" data-testid="bans-unban-dialog-submit">
        <i data-lucide="check" style="width:13px;height:13px"></i>
        Confirm unban
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
  function rowsForBid(bid) {
    return Array.from(document.querySelectorAll('[data-id="' + bid + '"]'));
  }
  function flipRowToUnbanned(row) {
    row.dataset.state = 'unbanned';
    row.querySelectorAll('[data-action="bans-unban"]').forEach(function (b) { b.remove(); });
    row.querySelectorAll('.pill').forEach(function (p) {
      p.className = 'pill pill--unbanned';
      p.textContent = 'unbanned';
    });
  }
  function closeUnbanDialog() {
    var d = document.getElementById('bans-unban-dialog');
    if (d && d.open) d.close();
    pending = null;
    clearError();
  }
  function clearError() {
    var e = document.querySelector('[data-testid="bans-unban-error"]');
    if (e) { e.style.display = 'none'; e.textContent = ''; }
  }
  function showError(msg) {
    var e = document.querySelector('[data-testid="bans-unban-error"]');
    if (e) { e.style.display = ''; e.textContent = msg; }
  }

  var A = typeof sb !== 'undefined' ? sb.api : null;
  var Actions = typeof window.Actions !== 'undefined' ? window.Actions : {};

  document.addEventListener('click', function (e) {
    var t = e.target;
    if (!t) return;

    var unbanBtn = t.closest('[data-action="bans-unban"]');
    if (unbanBtn) {
      e.preventDefault();
      pending = { bid: unbanBtn.dataset.bid, name: unbanBtn.dataset.name, fallback: unbanBtn.dataset.fallbackHref };
      var d = document.getElementById('bans-unban-dialog');
      var nameEl = document.querySelector('[data-testid="bans-unban-dialog-name"]');
      var reasonEl = document.getElementById('bans-unban-reason');
      if (nameEl) nameEl.textContent = pending.name;
      if (reasonEl) reasonEl.value = '';
      clearError();
      if (d) { d.removeAttribute('hidden'); if (d.showModal) d.showModal(); }
      return;
    }

    if (t.closest('[data-testid="bans-unban-dialog-cancel"]') || t.closest('[data-testid="bans-unban-dialog-close"]')) {
      closeUnbanDialog();
      return;
    }

    var submitBtn = t.closest('[data-testid="bans-unban-dialog-submit"]');
    if (submitBtn) {
      var ctx = pending;
      if (!ctx) return;
      var reason = (document.getElementById('bans-unban-reason') || {}).value || '';
      if (!reason.trim()) { showError('Please enter an unban reason.'); return; }
      setBusy(submitBtn, true);
      clearError();
      if (!A || !Actions.BansUnban) {
        var sep = ctx.fallback.indexOf('?') === -1 ? '?' : '&';
        window.location.href = ctx.fallback + sep + 'ureason=' + encodeURIComponent(reason);
        return;
      }
      A.call(Actions.BansUnban, { bid: Number(ctx.bid), ureason: reason }).then(function (r) {
        setBusy(submitBtn, false);
        if (!r || r.ok === false) {
          var msg = (r && r.error && r.error.message) || 'Unknown error';
          showError(msg);
          toast('error', 'Unban failed', msg);
          return;
        }
        rowsForBid(ctx.bid).forEach(flipRowToUnbanned);
        closeUnbanDialog();
        toast('success', 'Player unbanned', ctx.name + ' has been unbanned.');
      });
    }

    var deleteBtn = t.closest('[data-action="bans-delete"]');
    if (deleteBtn) {
      var name = deleteBtn.dataset.name || 'this player';
      if (!confirm('Permanently delete the ban for ' + name + '? This cannot be undone.')) return;
      window.location.href = deleteBtn.dataset.fallbackHref;
    }
  });

  document.addEventListener('cancel', function (e) {
    if (e.target && e.target.id === 'bans-unban-dialog') { pending = null; clearError(); }
  });
}());
</script>
{/literal}

{* PHPStan dual-theme parity manifest — do not remove *}
{if false}{$ban_nav}{$ctype}{$cid}{$page}{$canedit}{$othercomments}{$commenttype}{$commenttext}{$comment}{$friendsban}{$groupban}{$can_delete}{$general_unban}{$hidetext}{$searchlink}{$can_export}{$admin_postkey}{$view_comments}{$view_bans}{$hideadminname}{$total_bans}{/if}

{*
    Server filter dropdown hostname hydration.
    Each <option data-sid> triggers one Actions.ServersHostPlayers call.
    All calls are fired in parallel via Promise.all so the total wait
    time is one round-trip, not N sequential ones.
    The server-side SourceQueryCache (~30s TTL) means if the servers
    page was recently visited no UDP probe fires — responses are served
    from cache instantly.
    Falls back to ip:port if the server is offline or the call fails.
*}
<script>
(function () {
    if (typeof sb === 'undefined' || typeof Actions === 'undefined') return;

    var opts = Array.from(document.querySelectorAll(
        '[data-testid="bans-server-filter"] option[data-sid]'
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
                    return { ip: r.data.ip, port: r.data.port, hostname: r.data.hostname, label: label, opt: opt, fallback: fallback };
                } else if (r && r.data && r.data.error === 'connect') {
                    label = 'Offline (' + r.data.ip + ':' + r.data.port + ')';
                    return { ip: r.data.ip, port: r.data.port, hostname: null, label: label, opt: opt, fallback: fallback };
                }
                return { ip: null, port: null, hostname: null, label: fallback, opt: opt, fallback: fallback };
            })
            .catch(function () {
                return { ip: null, port: null, hostname: null, label: fallback, opt: opt, fallback: fallback };
            });
    })).then(function (results) {
        var ipMap = {};
        results.forEach(function (r) {
            r.opt.textContent = r.label;
            if (r.ip && r.hostname) {
                ipMap[r.ip] = r.hostname;
            }
        });

        document.querySelectorAll('td[data-sip]').forEach(function (td) {
            var sip = td.dataset.sip;
            if (!sip) return;
            var ip = sip.split(':')[0];
            if (ipMap[ip]) {
                td.textContent = ipMap[ip];
            }
        });

        var sel = document.querySelector('[data-testid="bans-server-filter"]');
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
