{*
    SBPP Windmill Dashboard v2 — page_protestban.tpl

    Customised from web/themes/default/page_protestban.tpl:
      - <header> block (h1 + intro text) removed — purple bar carries title
      - Title bar overridden to "Appeal a ban" via inline JS
      - Intro text ("Think a ban...") moved to top of right aside card
      - "You'll receive a reply by email" removed — no $smtp_enabled
        variable available in ProtestBanView to gate it conditionally
      - Form section centred via margin:0 auto
      - Cancel button removed — browser back handles navigation

    Form field name= attributes (Type, SteamID, IP, PlayerName,
    BanReason, EmailAddr, subprotest), CSRF field, and all
    data-testid hooks preserved exactly from default.
*}

{assign var="ip_first" value=($ip != '')}

{* Override title bar — $title is set by PHP *}
<script>
(function () {
    var bar = document.querySelector('[data-testid="page-title-bar"]');
    if (bar) bar.textContent = 'Appeal a Ban';
}());
</script>

<section class="p-6 space-y-6" style="max-width:64rem;margin:0 auto">

    <div class="grid gap-4" style="grid-template-columns:minmax(0,2fr) minmax(0,1fr)">

        {* -- Left: appeal form ---------------------------------------- *}
        <form class="card"
              method="post"
              action="index.php?p=protest"
              data-testid="protest-form"
              data-protest-form>
            <div class="card__header">
                <div>
                    <h3>Your details</h3>
                    <p>Fields marked <span style="color:var(--danger)">*</span> are required.</p>
                </div>
            </div>
            <div class="card__body space-y-4">
                {csrf_field}
                <input type="hidden" name="subprotest" value="1">

                <div>
                    <label class="label" for="protest-type">Ban type</label>
                    <select id="protest-type"
                            name="Type"
                            class="select"
                            data-testid="protest-type"
                            data-protest-type>
                        <option value="0" {if !$ip_first}selected{/if}>Steam ID</option>
                        <option value="1" {if $ip_first}selected{/if}>IP Address</option>
                    </select>
                </div>

                <div data-protest-row="steam" {if $ip_first}hidden{/if}>
                    <label class="label" for="protest-steam">
                        Your SteamID <span style="color:var(--danger)">*</span>
                    </label>
                    <input id="protest-steam"
                           type="text"
                           name="SteamID"
                           maxlength="64"
                           value="{$steam_id|escape}"
                           class="input font-mono"
                           placeholder="STEAM_0:1:23498765"
                           autocomplete="off"
                           data-testid="protest-steam"
                           {if !$ip_first}required{/if}>
                </div>

                <div data-protest-row="ip" {if !$ip_first}hidden{/if}>
                    <label class="label" for="protest-ip">
                        Your IP <span style="color:var(--danger)">*</span>
                    </label>
                    <input id="protest-ip"
                           type="text"
                           name="IP"
                           maxlength="64"
                           value="{$ip|escape}"
                           class="input font-mono"
                           placeholder="192.0.2.1"
                           autocomplete="off"
                           data-testid="protest-ip"
                           {if $ip_first}required{/if}>
                </div>

                <div class="grid gap-4" style="grid-template-columns:1fr 1fr">
                    <div>
                        <label class="label" for="protest-name">
                            In-game name <span style="color:var(--danger)">*</span>
                        </label>
                        <input id="protest-name"
                               type="text"
                               name="PlayerName"
                               maxlength="70"
                               value="{$player_name|escape}"
                               class="input"
                               required
                               data-testid="protest-name">
                    </div>
                    <div>
                        <label class="label" for="protest-email">
                            Your email <span style="color:var(--danger)">*</span>
                        </label>
                        <input id="protest-email"
                               type="email"
                               name="EmailAddr"
                               maxlength="70"
                               value="{$player_email|escape}"
                               class="input"
                               required
                               data-testid="protest-email">
                    </div>
                </div>

                <div>
                    <label class="label" for="protest-reason">
                        Why should you be unbanned? <span style="color:var(--danger)">*</span>
                    </label>
                    <textarea id="protest-reason"
                              name="BanReason"
                              rows="6"
                              class="textarea"
                              required
                              data-testid="protest-reason"
                              placeholder="Be as descriptive as possible. The more context staff have, the faster your appeal can be reviewed.">{$reason|escape}</textarea>
                </div>
            </div>
            <div class="card__header" style="justify-content:flex-end;border-top:1px solid var(--border);border-bottom:0">
                <button type="submit"
                        class="btn btn--primary"
                        data-testid="protest-submit">
                    <i data-lucide="send-horizontal"></i> Submit appeal
                </button>
            </div>
        </form>

        {* -- Right: info aside ---------------------------------------- *}
        <aside class="card">
            <div class="card__header">
                <div>
                    <h3>Appeal a Ban</h3>
                </div>
            </div>
            <div class="card__body space-y-4 text-sm">
                <p class="m-0 text-muted">
                    Think a ban on your account is a mistake? Submit an appeal
                    and the staff team will review it. Confirm the ban first
                    on the <a href="index.php?p=banlist" style="color:var(--accent)">ban list</a>.
                </p>
                <div style="border-top:1px solid var(--border);padding-top:1rem">
                    <h3 style="font-size:var(--fs-sm);font-weight:600;margin:0 0 0.5rem">What happens next?</h3>
                    <p class="m-0 text-muted">
                        The staff team is notified the moment you submit.
                        They review the original ban evidence and the context
                        you provide here.
                    </p>
                </div>
                <div class="space-y-3"
                     style="border-top:1px solid var(--border);padding-top:1rem">
                    <div class="flex gap-2 items-start">
                        <i data-lucide="alert-triangle" style="color:var(--warning);flex-shrink:0;width:16px;height:16px;margin-top:2px"></i>
                        <p class="m-0 text-xs text-muted">
                            Threats, harassment, or abuse aimed at the
                            staff will not get you unbanned and will get
                            you permanently banned.
                        </p>
                    </div>
                </div>
            </div>
        </aside>

    </div>
</section>

<script>
(function () {
    var form = document.querySelector('[data-protest-form]');
    if (!form) { return; }
    var typeSelect = form.querySelector('[data-protest-type]');
    var steamRow = form.querySelector('[data-protest-row="steam"]');
    var ipRow = form.querySelector('[data-protest-row="ip"]');
    var steamInput = steamRow ? steamRow.querySelector('input') : null;
    var ipInput = ipRow ? ipRow.querySelector('input') : null;
    if (!typeSelect || !steamRow || !ipRow || !steamInput || !ipInput) { return; }
    function sync() {
        var ipPicked = typeSelect.value === '1';
        steamRow.hidden = ipPicked;
        ipRow.hidden = !ipPicked;
        steamInput.required = !ipPicked;
        ipInput.required = ipPicked;
    }
    typeSelect.addEventListener('change', sync);
    sync();
}());
</script>
