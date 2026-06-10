{*
    SBPP Windmill Dashboard v2 — page_submitban.tpl

    Customised from web/themes/default/page_submitban.tpl:
      - <header> block (h1 + subtitle) removed — purple title bar carries it
      - Title bar text overridden to "Report a Player" via inline JS
      - Form centred via margin:0 auto on the outer <section>

    All form field name= keys (SteamID, BanIP, PlayerName, BanReason,
    SubmitName, EmailAddr, server, demo_file), subban=1 marker, CSRF field,
    testid hooks, and validation script preserved exactly from default.
*}

{* Override title bar text — $title is set by PHP, can't be changed in template *}
<script>
(function () {
    var bar = document.querySelector('[data-testid="page-title-bar"]');
    if (bar) bar.textContent = 'Report a Player';
}());
</script>

<section class="p-6" style="max-width:48rem;margin:0 auto">

    <form class="card"
          method="post"
          enctype="multipart/form-data"
          action="index.php?p=submit"
          aria-labelledby="submitban-heading">
        {csrf_field}
        <input type="hidden" name="subban" value="1">

        <div class="card__body space-y-4">
            <div data-testid="submitban-id-or-ip"
                 data-required-group="steamid-or-ip"
                 data-error="false"
                 class="space-y-4">
                <div>
                    <label class="label" for="submitban-steam">
                        Player&rsquo;s Steam ID
                        <span class="text-muted text-xs" style="font-weight:400">(or use the IP below)</span>
                    </label>
                    <input type="text"
                           class="input font-mono"
                           id="submitban-steam"
                           name="SteamID"
                           maxlength="64"
                           value="{$STEAMID}"
                           placeholder="STEAM_0:1:23498765"
                           pattern="STEAM_[01]:[01]:\d+|\[U:1:\d+\]|\d{17}"
                           title="Enter a Steam ID (STEAM_0:1:23498765), Steam3 ID ([U:1:23498765]), or 17-digit SteamID64."
                           autocomplete="off"
                           data-testid="submitban-steam">
                </div>

                <div>
                    <label class="label" for="submitban-ip">
                        Player&rsquo;s IP address
                        <span class="text-muted text-xs" style="font-weight:400">(or use the Steam ID above)</span>
                    </label>
                    <input type="text"
                           class="input font-mono"
                           id="submitban-ip"
                           name="BanIP"
                           maxlength="64"
                           value="{$ban_ip}"
                           placeholder="203.0.113.42"
                           autocomplete="off"
                           data-testid="submitban-ip">
                </div>
            </div>

            <div>
                <label class="label" for="submitban-name">
                    Player&rsquo;s nickname <span style="color:var(--danger)" aria-hidden="true">*</span>
                </label>
                <input type="text"
                       class="input"
                       id="submitban-name"
                       name="PlayerName"
                       maxlength="70"
                       value="{$player_name}"
                       required
                       aria-required="true"
                       data-testid="submitban-name">
            </div>

            <div>
                <label class="label" for="submitban-reason">
                    Comments <span style="color:var(--danger)" aria-hidden="true">*</span>
                </label>
                <textarea class="textarea"
                          id="submitban-reason"
                          name="BanReason"
                          rows="5"
                          required
                          aria-required="true"
                          aria-describedby="submitban-reason-help"
                          data-testid="submitban-reason">{$ban_reason}</textarea>
                <p id="submitban-reason-help" class="text-xs text-muted m-0 mt-2">
                    Be specific. &ldquo;hacking&rdquo; is not enough &mdash; describe what you saw,
                    when, and on which server.
                </p>
            </div>
        </div>

        <div class="card__body space-y-4" style="border-top:1px solid var(--border)">
            <div>
                <h2 class="m-0" style="font-size:var(--fs-base);font-weight:600">
                    Your details
                </h2>
                <p class="text-xs text-muted m-0 mt-2">
                    So an admin can reach out for follow-up questions.
                </p>
            </div>

            <div class="grid gap-4" style="grid-template-columns:1fr 1fr">
                <div>
                    <label class="label" for="submitban-reporter-name">Your name</label>
                    <input type="text"
                           class="input"
                           id="submitban-reporter-name"
                           name="SubmitName"
                           maxlength="70"
                           value="{$subplayer_name}"
                           autocomplete="name"
                           data-testid="submitban-reporter-name">
                </div>
                <div>
                    <label class="label" for="submitban-reporter-email">
                        Your email <span style="color:var(--danger)" aria-hidden="true">*</span>
                    </label>
                    <input type="email"
                           class="input"
                           id="submitban-reporter-email"
                           name="EmailAddr"
                           maxlength="70"
                           value="{$player_email}"
                           required
                           aria-required="true"
                           autocomplete="email"
                           data-testid="submitban-reporter-email">
                </div>
            </div>

            <div>
                <label class="label" for="submitban-server">
                    Server <span style="color:var(--danger)" aria-hidden="true">*</span>
                </label>
                <select class="select"
                        id="submitban-server"
                        name="server"
                        required
                        aria-required="true"
                        data-testid="submitban-server">
                    <option value="-1">&mdash; Select server &mdash;</option>
                    {foreach from=$server_list item="server"}
                        <option value="{$server.sid}"{if $server_selected == $server.sid} selected{/if}>{$server.hostname}</option>
                    {/foreach}
                    <option value="0"{if $server_selected == 0} selected{/if}>Other server / Not listed here</option>
                </select>
            </div>

            <div>
                <label class="label" for="submitban-demo">Upload demo or evidence</label>
                <div class="file-input">
                    <label class="btn btn--secondary">
                        <input type="file"
                               id="submitban-demo"
                               name="demo_file"
                               accept=".dem,.zip,.rar,.7z,.bz2,.gz"
                               data-testid="submitban-demo"
                               data-file-input
                               hidden>
                        <i data-lucide="upload" style="width:14px;height:14px"></i>
                        Choose file&hellip;
                    </label>
                    <span class="text-muted text-sm" data-file-name>No file chosen</span>
                </div>
                <p class="text-xs text-muted m-0 mt-2">
                    Optional. Allowed formats: <code class="font-mono">.dem</code>,
                    <code class="font-mono">.zip</code>, <code class="font-mono">.rar</code>,
                    <code class="font-mono">.7z</code>, <code class="font-mono">.bz2</code>,
                    <code class="font-mono">.gz</code>.
                </p>
            </div>
        </div>

        <div class="card__body flex items-center justify-between gap-2"
             style="border-top:1px solid var(--border)">
            <p class="text-xs text-muted m-0">
                <span style="color:var(--danger)" aria-hidden="true">*</span> Required field
            </p>
            <div class="flex gap-2">
                <button class="btn btn--primary"
                        type="submit"
                        data-testid="submitban-submit">
                    <i data-lucide="send-horizontal" aria-hidden="true"></i>
                    Submit report
                </button>
            </div>
        </div>
    </form>

</section>

{literal}
<script>
(function () {
    'use strict';

    var form   = document.querySelector('form[action="index.php?p=submit"]');
    var steam  = document.getElementById('submitban-steam');
    var ip     = document.getElementById('submitban-ip');
    var group  = document.querySelector('[data-required-group="steamid-or-ip"]');
    var help   = document.getElementById('submitban-id-or-ip-help');
    var helpTxt = help ? help.querySelector('[data-id-or-ip-text]') : null;
    var submit = document.querySelector('[data-testid="submitban-submit"]');
    var fileInput = document.querySelector('[data-file-input]');
    var fileName  = document.querySelector('[data-file-name]');

    if (fileInput && fileName) {
        fileInput.addEventListener('change', function () {
            fileName.textContent = fileInput.files.length
                ? fileInput.files[0].name
                : 'No file chosen';
        });
    }

    if (!form || !steam || !ip) return;

    function clearError() {
        if (group) group.dataset.error = 'false';
        if (help)  help.dataset.state  = 'info';
        if (helpTxt) helpTxt.textContent = 'Provide either a Steam ID or an IP address (or both).';
        if (steam) steam.removeAttribute('aria-invalid');
        if (ip)    ip.removeAttribute('aria-invalid');
    }

    function showError() {
        if (group) group.dataset.error = 'true';
        if (help)  help.dataset.state  = 'error';
        if (helpTxt) helpTxt.textContent = 'At least one of Steam ID or IP address is required.';
        if (steam) steam.setAttribute('aria-invalid', 'true');
        if (ip)    ip.setAttribute('aria-invalid', 'true');
    }

    [steam, ip].forEach(function (el) {
        el.addEventListener('input', clearError);
    });

    var S = window.SBPP;
    function setBusy(btn, busy) {
        if (S && typeof S.setBusy === 'function') S.setBusy(btn, busy);
        else if (btn) btn.disabled = !!busy;
    }

    form.addEventListener('submit', function (e) {
        if (!steam.value.trim() && !ip.value.trim()) {
            e.preventDefault();
            showError();
            steam.focus();
            return;
        }
        if (submit) setBusy(submit, true);
    });
}());
</script>
{/literal}
