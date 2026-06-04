---
name: nicegui-quirks
description: |
  Pitfalls and workarounds when writing NiceGUI / Quasar code — layout centering, input prop forwarding, event-handler value/closure traps, dialog/upload/table/select gotchas, drag-and-drop, per-tab/user storage timing, browser-side JS interop, and cookie/auth flows. Apply these when writing or reviewing NiceGUI page code so you don't rediscover the same bugs.

  TRIGGER when: editing or writing Python that imports `nicegui` or calls `ui.*` / `app.*` from NiceGUI; user asks about NiceGUI, Quasar, or any of `ui.dialog` / `ui.upload` / `ui.table` / `ui.select` / `ui.input` / `ui.html` / `ui.add_body_html` / `ui.run_javascript` / `ui.navigate` / `app.storage` / `on_change` / drag-and-drop; user is debugging a NiceGUI page that "looks wrong", loses state, or behaves unexpectedly in the browser.

  SKIP: non-Python files; Python without NiceGUI imports; general web/frontend questions unrelated to NiceGUI.
---

# NiceGUI / Quasar quirks

These are not in the NiceGUI docs (or are easy to miss). Apply them proactively when writing NiceGUI code — don't wait to be bitten.

## Layout

- **Page content is a flex column with `items-start`.** `margin: auto` on a child won't horizontally center it. To center, run `ui.query(".nicegui-content").classes("items-center")` at the top of the page.

## Inputs & forms

- **`.props("id=...")` on `ui.input` lands on the Quasar wrapper, not the inner `<input>`.** So `document.getElementById(...).value` returns `undefined`. To get values from browser-side JS, prefer `input.value` via NiceGUI's binding; if you must query the DOM, use `name=` or `input-class=` (Quasar forwards both to the inner native input).
- **`ui.input` does not debounce by default** — every keystroke fires `on_change`. Pass `debounce=N` (ms) as a prop to throttle.

## Event handlers

- **`on_change` / `on_click` handlers receive an event-arguments object, not the value.** A `ui.select(on_change=...)` handler gets a `ValueChangeEventArguments` — read `e.value`. Annotating the param as `str` doesn't change what's passed; you still get the event object, and forwarding it where a value is expected fails downstream (e.g. a DB write raising a serialization error rather than at the call site).
- **Handlers defined inside a build loop need a closure-factory to capture loop variables.** NiceGUI's idiom is to build many components in a `for` loop, which makes Python's late-binding closures bite constantly — every handler ends up seeing the last iteration's values. Wrap creation in a factory (`def make_cb(eid, ...): async def handler(e): ...; return handler`) or bind via default args (`lambda e, x=x: ...`).
- **A handler that `.clear()`s the container holding the element that fired it breaks `context.client` for the rest of that handler.** Pattern: a `ui.select` on a "source" card fires `on_change`; the handler rebuilds the source container with `container.clear()` (deleting the select) then calls a build function that reads `app.storage.tab` / `app.storage.client`. NiceGUI resolves `context.client` through the *current slot* — the slot of the just-deleted trigger element — and raises `RuntimeError: The parent element this slot belongs to has been deleted`. The container is left cleared-but-not-rebuilt, so it appears to vanish. Fix: re-enter the still-attached container's slot before rebuilding — `container.clear(); with container: build(...)` — so the client resolves via the container, not the dead element.

## Component quirks

- **`ui.dialog` is hidden, not removed, on close.** Repeated open/create leaks DOM. Either create the dialog once and reuse it, or call `.clear()` after dismissal.
- **`ui.upload` buffers the entire file before invoking the handler** — it is not streaming. For large files, mount a raw FastAPI route on `app` (NiceGUI's `app` *is* a FastAPI instance) and iterate `request.stream()`.
- **`ui.table` doesn't auto-forward custom slot `$emit` events to Python.** Vue events emitted inside slot templates don't bubble up to NiceGUI. Use the table's built-in row/selection events, or invoke a callback via JS.
- **`ui.select` async search doesn't work via `bind_options_from`.** For server-side filtering (e.g. ES autocomplete), listen for Quasar's `filter` event directly. Initial dict values can also break `option-label`/`option-value` rendering — prefer plain strings or map manually.
- **Native HTML5 drag-and-drop does not map to NiceGUI element `.on()` handlers.** `dragstart`/`dragover`/`drop` fire on the document, not on the Vue component, and `dataTransfer` isn't reliably readable from a NiceGUI event. The working pattern is document-level listeners injected via `add_body_html("<script>…</script>")` that stash drag state on `window` and POST to a custom FastAPI route (`fetch('/api/...')`) on drop. It's heavy enough that a `ui.select` "move to shelf" picker is often the better trade — reach for DnD only when the gesture is the point.
- **`ui.keyboard` ignores key events while focus is in an input/select/textarea/button by default.** The `ignore=` parameter defaults to `['input', 'select', 'button', 'textarea']`, so a page-level Ctrl+Enter shortcut won't fire while the user is typing in a `ui.input`. Pass `ignore=[]` to capture keys regardless of focus.


## Browser-side JS interop

- **`ui.html()` content has Vue's `v-html` sanitization applied** — inline event handlers (`onclick=`, `onchange=`, etc.) in raw HTML strings get stripped for XSS protection. Either use NiceGUI components or attach listeners via a separate `<script>` block.
- **`ui.add_body_html` content lives outside NiceGUI's Vue component tree** — visible elements injected this way can end up hidden or unstyled. Use `ui.html()` for visible content (lives in the component tree); reserve `ui.add_body_html()` for `<script>` blocks.
- **`ui.run_javascript`'s default timeout is 1.0s** — too short for any `fetch()`-based snippet. Bump to ~10s.

## State & storage

- **`app.storage.tab` is empty until the browser's websocket has connected.** Reading it at the top of an `@ui.page` handler (which runs on the initial HTTP request, before the socket is up) gets you nothing. `await ui.context.client.connected()` before the first access. `app.storage.client` has the same requirement; `app.storage.user` additionally needs a `storage_secret=` passed to `ui.run`.
- **Pick the right storage scope.** `app.storage.tab` is isolated per browser tab (survives reloads, separate per tab) — right for view/filter state. `app.storage.user` is shared across a user's tabs (cookie-backed). For shareable/bookmarkable state, drive it off URL query params and sync those into `storage.tab` on page load instead.

## Cookies & auth

- **Browser cookies can't be set via the NiceGUI WebSocket.** Any flow that needs to set a session cookie (login is the canonical example) must originate from a real browser HTTP request — typically a `fetch()` invoked from `ui.run_javascript`.
- **`ui.navigate.to()` is SPA navigation** — it won't pick up fresh auth/server state. Use `ui.navigate.reload()` or set `window.location.href` when you need a full reload.

## Maintenance

When you discover a new quirk in any project, append it here (and prune entries that newer NiceGUI versions have fixed).

