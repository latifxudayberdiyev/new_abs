# PF module (Fabrika produktov / Product Factory) — working notes

Scope of this file: only the PF module (`core/pf/` + `jsp/pf/`). For repo-wide conventions
(PL/SQL formatting, general sqlplus/CP1251 mechanics that apply outside PF), see project memory
or ask — this file is intentionally PF-only.

## Naming conventions (mandatory, applies to every future module too)

- **Every table name is plural**: `PF_PRODUCT` is wrong, `PF_PRODUCTS` is right.
- **Every reference/lookup (spravochnik) table is prefixed `PF_R_`**, still plural:
  `PF_R_CATEGORIES`, `PF_R_ATTRIBUTES`, `PF_R_PARAMETERS`, `PF_R_VALIDATION_FUNCTIONS`,
  `PF_R_PARAMETER_VALIDATIONS`, `PF_R_ATTRIBUTE_CATEGORIES`, `PF_R_PRODUCT_DELIVERY_TYPES`.
  A "reference table" here means a catalog/definition table (what categories/attributes/
  parameters/validation-functions *can* exist), as opposed to actual transactional/business data.
  Junction (M:N) tables between two reference tables are reference tables too.
- **Main/transactional tables** (not a spravochnik) keep the plain `PF_` prefix, still plural:
  `PF_PRODUCTS`, `PF_PRODUCT_VERSIONS`, `PF_PRODUCT_PARAMETER_VALUES`, `PF_APPROVAL_REQUESTS`,
  `PF_VERSION_RULES`, `PF_PRODUCT_EVENT_OUTBOXES`.
- **Views are named `<table>_V`**: `PF_R_CATEGORIES_V`, `PF_PRODUCTS_V`.
- **History tables are named `<table>_H`**: `PF_R_CATEGORIES_H` (see below) — the `_H` suffix
  comes after any `_V`-style naming would, i.e. it's always the base table name + `_H`, never
  applied to a view.
- **Sequences are not renamed when a table is renamed** — `PF_CATEGORY_SQ` kept its name across
  the `PF_CATEGORY` → `PF_R_CATEGORIES` rename, and `PF_CATEGORY_H_SQ` similarly serves
  `PF_R_CATEGORIES_H`. Only tables and views follow the naming rules above.
- Constraint/index names are **not** required to match a renamed table (low value, high risk to
  rename retroactively) — e.g. `PF_R_CATEGORIES` still has a constraint literally named
  `PF_CATEGORY_PK`. Exception: for brand-new tables (like the `_H` tables), name constraints to
  match from the start.

## Mandatory audit columns (main tables only, not reference tables)

**Every main/transactional table (i.e., every table NOT prefixed `PF_R_`) has
`CREATED_BY`, `CREATED_ON`, `MODIFIED_BY`, `MODIFIED_ON`.** Reference tables (`PF_R_*`) are
exempt — a category/attribute/parameter/validation-function definition doesn't need per-row
audit trail the same way (its own `_H` history table already covers changes to it).

- `CREATED_BY`/`MODIFIED_BY` are `NUMBER`, sourced from `Core.User_Env.Get_User_Id` (reads the
  `UAPP` session context the live app sets per-request — see the "Testing a PF process without
  the browser" note below for why this is null in a raw SQL*Plus session).
- `CREATED_ON`/`MODIFIED_ON` are `DATE DEFAULT SYSDATE NOT NULL`.
- These 4 columns exist on `PF_PRODUCTS`, `PF_PRODUCT_VERSIONS`, `PF_PRODUCT_PARAMETER_VALUES`,
  `PF_APPROVAL_REQUESTS`, `PF_VERSION_RULES`, `PF_PRODUCT_EVENT_OUTBOXES`. `PF_PRODUCTS`/
  `PF_PRODUCT_VERSIONS` have working CRUD now (see "Entity ownership" below) — the rest are still
  empty scaffolding; whoever builds their CRUD next must populate these 4 columns from
  `User_Env.Get_User_Id`/`sysdate`, not leave them as an afterthought.
- **Do not accept a client-supplied `user_id` for these columns.** A colleague's first cut of
  `Pf_Dml.Add_Product`/`Update_Product` (etc.) took an explicit `i_User_Id` parameter, populated in
  `Pf_Kernel` from `Io_Hash.Get_Optional_Varchar2('user_id')` — i.e. trusting whatever the JSP's
  hidden `user_id` form field carried. Fixed (2026-07-27) by dropping that parameter entirely and
  reading `Core.User_Env.Get_User_Id` straight inside `Pf_Dml`, matching every other entity.

## Mandatory history (`_H`) tables

**Every writable PF table has a matching `<TABLE>_H` history table, and every insert/update/
delete goes through `Pf_Dml` and writes a corresponding row to it.** Currently built for the 3
tables with working CRUD: `PF_R_CATEGORIES` → `PF_R_CATEGORIES_H`, `PF_R_ATTRIBUTES` →
`PF_R_ATTRIBUTES_H`, `PF_R_PARAMETERS` → `PF_R_PARAMETERS_H`. This is a standing convention for
every PF table going forward (and for any future module in this repo, not just PF) — mirrors the
pre-existing (if underused) pattern already seen in `core_users_h`/`mlt_templates_h`.

**Shape**: `<TABLE>_H` has `LOG_ID` (PK, own `<TABLE>_H_SQ` sequence) + every business column from
the base table (same types, all nullable-or-not exactly as the base table, since a deleted row's
last state must still round-trip) + `ACTION VARCHAR2(1) NOT NULL CHECK (ACTION IN ('I','U','D'))`
+ `ACTION_DATE DATE NOT NULL`. No FK from `_H` back to the base table — the base row can be
deleted; the id is a plain informational column, indexed but not constrained.

**Population**: procedural, inside `Pf_Dml`, not a DB trigger (no trigger-based precedent found
anywhere in this codebase despite the `_H` naming convention existing elsewhere — `mlt_templates_h`
isn't even deployed to the live DB). Each `Add_X`/`Update_X`/`Delete_X` in `Pf_Dml` does the
history insert itself:
- On insert: after the `insert into <table>`, insert into `<table>_h` with the same values,
  `ACTION => 'I'`.
- On update: after the `update <table>`, `insert into <table>_h select <cols>, 'U', sysdate from
  <table> where id = ...` — captures the *post*-update state.
- On delete: *before* the `delete from <table>`, `insert into <table>_h select <cols>, 'D',
  sysdate from <table> where id = ...` — captures the state just before it's removed (there's
  nothing left to select afterward).

**Gotcha for entities without a dedicated `Update_X` DML procedure**: `PF_R_ATTRIBUTES`' own row
only changes via `Add_Attribute` (create) — editing an existing attribute's name/categories
never touches the row's own columns through a `Pf_Dml` update call. For that case, `Pf_Dml`
exposes a standalone `Log_Attribute_History(i_Id, i_Action)` that `Pf_Kernel.Save_Attribute`
calls directly with `'U'` in its update branch — use the same pattern (a public `Log_X_History`
helper) for any future entity whose "update" doesn't map to a single obvious DML call.

**Not every `PF_R_*` reference table gets an `_H` table.** Only the 3 with actual create/edit/
delete UI exposed to users have one: `PF_R_CATEGORIES`, `PF_R_ATTRIBUTES`, `PF_R_PARAMETERS`.
Pure lookup/seed tables with no dedicated CRUD screen — `PF_R_VALIDATION_FUNCTIONS`,
`PF_R_PARAMETER_VALIDATIONS`, `PF_R_PRODUCT_DELIVERY_TYPES`, `PF_R_PRODUCT_STATES` — don't have
one; they're populated once via an `inserts/*_SEED.sql` script and rarely touched again. If one of
these ever grows a real admin CRUD screen, give it an `_H` table at that point, matching the
pattern above.

## Architecture

Module code: `PF`. Lives at `core/pf/` (tables/sequences/packages/views/inserts) and `jsp/pf/`.

**Layered package convention** (mirrors the ML modules' MLE/MLL/MLT pattern):
- `Pf_Const` — constants (`c_Module_Code := 'PF'`).
- `Pf_Util` — selects/read functions only.
- `Pf_Dml` — raw insert/update/delete on PF tables, plus the `_H` history writes described above
  (label/template writes still go through `Mll_Dev_Api`, never direct — see below).
- `Pf_Kernel` — business logic/orchestration, `Io_Hash`/`o_Code`/`o_Msg`/`o_Ora_Msg` signature.
- `Pf_Sm_Api` — the *only* thing `SM_R_PROCEDURES.PROCEDURE_NAME` points to; each procedure is a
  one-line passthrough to the matching `Pf_Kernel` procedure. SM never calls `Pf_Kernel` directly.

JSPs call `stored.execJsonRequestProcedure("Core_Api.Execute_Process_Clob", request)` /
`execJsonRequestFunction("Core_Api.Get_Model_Clob", request)` — never a PF-specific dispatcher.

**Design source of truth** (only on one machine, not in this repo): the ER dictionary
(`product-factory-er-dictionary-v3_1.html`) and the `fabrika-produktov (30).html` prototype
define the full 12-table schema and the intended card-style UI. Note the table names in that ER
dictionary predate the naming convention above (singular, no `PF_R_` prefix) — treat this file's
naming rules as authoritative over the ER dictionary's literal table names.

**UI approach — mandatory pattern from 2026-07-28 onward, every PF list/form screen must follow
it, no exceptions without being asked**:
- `<t:dynamicGrid gridId="N" />` for the list, `formToolbar` + plain
  `<input type="submit"/"button">` for actions, `.form-group`/`.form-control` (label *after* the
  input) for form fields laid out via a bare `style="display:grid;grid-template-columns:..."`
  wrapper div. No custom CSS file, no `.pf-*` classes.
- **Clone `mlt/labels.jsp`/`mlt/label.jsp` structurally, verbatim** — that pair (not the old
  `.pf-` JSPs, not a hand-rolled layout) is the only template for a new PF list/form screen. See
  "Registering a new `t:dynamicGrid`" below for how the grid itself gets wired up, and "Writing a
  new PF list/form JSP pair" below for the full checklist (several non-obvious, easy-to-repeat
  bugs were found and fixed the hard way building Category/Parameter — follow the checklist rather
  than re-deriving it).
- **A prototype/mockup (Figma export, static HTML design file) is a *functional* reference only —
  never a structural one.** Read it to learn what fields exist, what's required, what the business
  rule/validation is — never copy its markup, CSS, or layout approach. The JSP structure always
  comes from the `mlt/labels.jsp`/`mlt/label.jsp` clone above, regardless of how the prototype
  happens to be laid out.
- `attribute.jsp`/`attributes.jsp`/`product.jsp`/`products.jsp` are already on this same
  `t:dynamicGrid` pattern (colleague's screens, migrated independently) — the older `.pf-` card
  design (`jsp/pf/css/pf.css`) is retired project-wide, not just for Category/Parameter.

### Registering a new `t:dynamicGrid`

A grid needs two tables populated *before* `<t:dynamicGrid gridId="N" />` will render anything —
this is UI-rendering configuration, not business logic, so populating it doesn't conflict with a
"backend stays untouched" instruction:
1. **`CORE_GRIDS`** — one row per grid: `GRID_ID` (pick the next unused one), `GRID_CODE`,
   `GRID_NAME`, `VIEW_NAME` (the view the grid queries directly — e.g. `PF_R_CATEGORIES_V`),
   `FILTER_CLAUSE` (a static `WHERE`-clause fragment, `'1=1'` if none), plus the `*_BUTTON`/
   `NUMBERING`/etc. Y/N display flags (copy `mlt`'s grid_id=5 values as sane defaults).
2. **`CORE_GRID_FIELDS`** — one row per visible column, keyed by `(GRID_ID, FIELD_ORDER)`.
   `FIELD_ORDER` is what the JSP's own `getData(N)` reads by position — **not** the same number as
   any `t:field id` elsewhere; always re-derive it from `select field_order, field_name from
   core_grid_fields where grid_id = N order by field_order` rather than assuming. Each field needs
   its own **numeric** `COLUMN_LABEL_ID` (from `MLL_LABEL_CODES.LABEL_ID`, resolved via
   `Mll_Core_Api.Get_Label_By_Id`) for the column header — this is a *different* mechanism from
   the rest of PF's own `Mll_Core_Api.Get_Label(i_Module_Code, i_Message_Code)` string-keyed
   lookups; register the label the same way (`Mll_Dev_Api.Save_Label_With_Template_Dev`), then
   `select label_id from mll_label_codes where module_code=... and message_code=...` to get the
   numeric id `CORE_GRID_FIELDS.COLUMN_LABEL_ID` actually wants. A filterable column additionally
   needs `IS_FILTER='Y'`, `FILTER_OPERATOR`, and (for a dropdown filter) `FILTER_OPTION_SQL`
   returning literal `<option>` HTML.
3. See `core/pf/inserts/PF_GRIDS_SEED.sql` for the full worked example (grid_id 6 = categories,
   7 = parameters) — copy its `Add_Label` helper pattern for any new grid.

**`FILTER_SHOW_IN_GRID='Y'` is REQUIRED to get an actual `<select>` dropdown filter** (not just a
free-text input) for a filterable column — but it crashes the page with
`alert("filterControls is not found")` unless the JSP *also* has a `<span id="filterControls">`
somewhere in the DOM (`table_cross.js` builds filter-control HTML for every field with this flag
set, then does `getDOM("filterControls").innerHTML = ...` unconditionally — no such span, no
catch, hard crash on page load, not just on interacting with the filter). **Both pieces are
mandatory together**: `FILTER_SHOW_IN_GRID='Y'` on the `CORE_GRID_FIELDS` row *and* a hidden
`<tr style="display:none"><td colspan="2"><b>Search:</b><span id="filterControls"></span></td>
</tr>` row inside the `formToolbar` table (copy verbatim from `mlt/labels.jsp`). An earlier version
of this note said to leave the flag unset — that was wrong (a first-pass misdiagnosis that treated
the *symptom* as the cause); the flag is what makes the dropdown render at all, confirmed by an
exhaustive diff against `mlt/labels.jsp` grid_id=5/`MODULE_CODE` and the colleague's `attributes.jsp`
grid_id=8. If a column filter shows only a plain text input where a dropdown was expected, check
for the missing span first, not the filter type.

`FILTER_OPTION_SQL` must produce `<option value=X>Text</option>`-shaped fragments (no closing tag
needed) — e.g. `select '<option value=' || NAME || '>' || NAME from R_STATE_V`. Its `value=` must
match the exact value/text stored in the column actually being *filtered* (if the displayed column
is a translated label like `STATE_LABEL`, the option value must be that same label text, not the
underlying raw code, or the generated `WHERE` clause never matches). `R_STATE_V` is a pre-existing,
generic (non-module-prefixed) view for Active/Passive (`'A'→'Активен'`, `'P'→'Пассивен'`) — reuse
it (or any other existing generic `R_*` view) instead of inventing a new PF-specific one for a
purely cosmetic label lookup.

### Writing a new PF list/form JSP pair (mandatory checklist, 2026-07-28)

Building Category/Parameter's screens on this pattern surfaced several bugs that have nothing to
do with PF business logic and everything to do with this CMS framework's own conventions — follow
this checklist for any new/rebuilt PF screen rather than rediscovering each one:

1. **The save form's `<form>` tag needs an explicit `action` attribute carrying the right
   `process_code`** — e.g.
   `action="category.jsp?process_code=<%=is_edit?"EDIT_PF_CATEGORY":"CREATE_PF_CATEGORY"%>"`.
   Without it, the POST reaches `Execute_Process_Clob` with no `process_code` at all and nothing
   happens server-side (no error surfaces to the user beyond a generic failure — no new row in
   `SM_PROCESSES` either, which is the tell that this is the bug, not something deeper).
   `mlt/label.jsp`'s own save form has this same explicit `action` — don't skip it just because a
   quick copy-paste of the surrounding markup still "looks" complete without it.

2. **The relation-id hidden field's `name` must be the entity's own natural id key — never the
   generic literal `sm_relation_id`.** See "`SM_R_PROCESSES.RELATION_KEY` must match the entity's
   own id field name" below for why; in short, `Model_X`'s JSON response names its id key
   `category_id`/`parameter_id`/`attribute_id`/`product_id`, and the client-side `fillForm(data)`
   auto-population only fills a field whose `id`/`name` matches a `data` key exactly.

3. **`fillForm(data)` (in `form_cross.js`) has a load-order race for hidden fields and
   `readonly`+masked visible fields specifically** — `code` (readonly on edit) and the relation-id
   hidden field reliably fail to populate from `fillForm`'s generic pass, even though ordinary
   visible fields (`name`, selects, etc.) populate fine. Symptom: those two fields show empty in
   the edit modal while everything else is correct; if you manually call `document.getElementById(
   'code').setValue('x')` in the console it works fine, and manually re-invoking `fillForm(data)`
   throws `Cannot read properties of null (reading 'setValue')` — proving `getDOM()` (a thin
   `getElementById` wrapper) returns `null` for that field at the time `fillForm` actually runs,
   even though the element unquestionably exists in the DOM a moment later. Root cause not fully
   pinned down (framework-internal timing, not a PF bug) — the reliable fix is to **not rely on
   the generic mechanism for these two fields**: explicitly set them inside the page's own
   `onLoad()`/`pfInit()`, guarded by `<% if (is_edit) { %>`:
   ```js
   document.fm.code.value = data.code;
   document.fm.category_id.value = data.category_id; // or parameter_id / attribute_id / product_id
   ```
   (`is_required`-style boolean coercion already followed this same "don't trust the generic
   binder, set it explicitly in `onLoad()`" pattern before this was fully understood — that's why
   it worked from the start.)

4. **Any `Model_X` procedure in `Pf_Kernel` must never `v_Data.Put(key, <a possibly-NULL NUMBER>)`
   unconditionally.** `Core.Hash_t`'s JSON serialization renders a NULL number as a bare empty
   value (`"key":,`), which is invalid JSON — the JSP's inline `<script>var data=...;</script>`
   then throws a `SyntaxError` and `data` silently falls back to `{}`, meaning **every** field in
   the form stays empty/default, not just the one with the null value (this is far more damaging
   than the single-field failures in point 3, and much easier to miss, since nothing in the UI
   points at the real cause — it just looks like "the whole form is broken"). Guard every
   optionally-null NUMBER put: `If v_X.Y_Id Is Not Null Then v_Data.Put('y_id', v_X.Y_Id); End If;`
   — `Model_Product`'s `start_date`/`end_date` puts already followed this pattern; `Model_Parameter`
   didn't (fixed 2026-07-28 for `reference_id`, which is NULL for every non-`REFERENCE` parameter —
   i.e. almost all of them, so this bug was live for the entire Parameter screen from the start).
   Audit every `Model_X` for this before considering a new entity's edit screen "done", not just
   the field that happened to get reported.

5. A `<select>` for a conditionally-relevant, normally-hidden field (e.g. `reference_id`, only
   meaningful when `input_type = 'REFERENCE'`) still gets submitted with whatever stale/default
   value it holds even while its wrapping row is `display:none` — `display:none` hides an element,
   it does not exclude it from form submission (only `disabled` does that). If `Pf_Kernel`'s
   `Save_X` passes that value straight to `Pf_Dml` regardless of the other field's state, it will
   get stored even when meaningless. Null it out server-side when not applicable:
   `Else v_Reference_Id := Null; End If;` in the branch that isn't `REFERENCE`.

### `SM_R_PROCESSES.RELATION_KEY` must match the entity's own id field name

Every PF process row in `SM_R_PROCESSES` (`CREATE_PF_X`/`EDIT_PF_X`/`DELETE_PF_X`/`MODEL_PF_X`) has
a `RELATION_KEY` column naming which JSON key in the request/response carries the entity's own id.
**This must be the entity's natural id name — `category_id`, `parameter_id`, `attribute_id`,
`product_id` — never the generic literal `sm_relation_id`** that PF originally used uniformly
across all four entities (a mistake made when these processes were first registered, corrected
2026-07-28). Two independent things break if this isn't followed:

- **Client-side**: `Model_X`'s JSON response already names its id key `category_id`/etc (that part
  was never configurable) — the generic `fillForm(data)` client mechanism only populates a form
  field whose name matches a `data` key *exactly*. A mismatched `RELATION_KEY`/hidden-field-name
  means the id never round-trips into the save request (see checklist item 2 above).
- **Server-side (`Pf_Kernel`)**: every `Model_X`/`Save_X`/`Delete_X` procedure reads the incoming
  relation id via `Io_Hash.Get_Optional_Number('<literal key>')` and (for create) via
  `v_Sm_Cache.Get_Optional_Number('<literal key>')` (the SM-allocated id, put into `sm_cache` by
  `Sm_Kernel.Set_Cache` under the SAME `RELATION_KEY` name). **These literals must exactly match
  the entity's `RELATION_KEY`, not each other's** — `Pf_Kernel` originally hardcoded the literal
  `'sm_relation_id'` in all 13 of these call sites (across all 4 entities' `Model_`/`Save_`/
  `Delete_` procedures), which broke silently the moment `RELATION_KEY` was corrected to
  entity-specific names, since nothing there read `RELATION_KEY` dynamically. Fixed 2026-07-28 by
  renaming each literal to match its own entity. **When adding a 5th PF entity, use its own natural
  id name from the very start on both sides — don't reintroduce the generic literal.**

### SM object lifecycle: `NEW_OBJECT_STATE` + `SM_R_TRANZITIONS`

`SM_OBJECTS.STATE` is not populated automatically just because a row exists — it requires explicit
configuration, and PF's four entities never had this configured at all until 2026-07-28 (every PF
`SM_OBJECTS` row had a permanently blank `STATE`). The mechanism (`Sm_Kernel.Set_Object`):

- `SM_R_PROCESSES.NEW_OBJECT_STATE` is the state a process transitions the object *to*. Convention
  observed across every other module in this system: `CREATE_X` sets it to a real value (`'A'` for
  most modules; PF instead uses **`CREATED`**), `EDIT_X`/`DELETE_X` leave it blank (edits/deletes
  never overwrite state with a different literal — `Sm_Kernel` just carries the *current* state
  forward when `NEW_OBJECT_STATE` is null). PF's convention (2026-07-28): `CREATE_PF_X →
  'CREATED'`, `EDIT_PF_X → 'EDITED'`, `DELETE_PF_X → 'DELETED'`.
- **A `NEW_OBJECT_STATE` value is inert without a matching row in `SM_R_TRANZITIONS`**
  (`OBJECT_CODE`, `PROCESS_CODE`, `CURRENT_STATE`, `NEW_STATE`, `IS_APPROVE`) describing exactly
  which state transitions are allowed for that process. Setting `NEW_OBJECT_STATE` alone, without
  the matching transition row, makes every call to that process fail with
  `SM_TRANSITION_NOT_FOUND` — confirmed by tracing `Sm_Kernel.Check_Tranzition`/
  `Check_Tranzition_State` and cross-checking against every other module's registered transitions,
  which always come in matched pairs.
- PF's registered transitions per entity (`X` = `PF_CATEGORY`/`PF_PARAMETER`/`PF_ATTRIBUTE`/
  `PF_PRODUCT`): `(X, CREATE_X, 'START', 'CREATED')`, `(X, EDIT_X, 'CREATED', 'EDITED')`,
  `(X, EDIT_X, 'EDITED', 'EDITED')` (a same-state self-loop — needed because
  `Check_Tranzition_State` validates that the object's *current* state is a registered
  `CURRENT_STATE` for that process, so a *second* edit — where current state is already `EDITED`,
  not `CREATED` — would otherwise be rejected), `(X, DELETE_X, 'CREATED', 'DELETED')`,
  `(X, DELETE_X, 'EDITED', 'DELETED')`. Deliberately **not** registered: any transition back out of
  `DELETED` — this is the actual enforcement mechanism for "an object, once deleted, can never be
  recreated/edited back to life" as a real guarded state machine, not just a UI convention.
- Existing rows created *before* this was configured have a blank `STATE` and must be backfilled —
  `CREATED` for rows whose business-table counterpart still exists, `DELETED` for orphaned
  `SM_OBJECTS` rows whose relation id no longer has a matching business row (done 2026-07-28 for
  all 4 entities). Any future PF entity must get its `NEW_OBJECT_STATE`/`SM_R_TRANZITIONS` rows
  registered *at the same time* its `SM_R_PROCESSES` rows are, not as a follow-up — this is exactly
  the gap that caused this whole cleanup.

**Entity ownership**: `PF_R_CATEGORIES`, `PF_R_PARAMETERS`, `PF_R_ATTRIBUTES`, and now `PF_PRODUCTS`/
`PF_PRODUCT_VERSIONS` are all fully mine (backend and frontend both). `PF_R_ATTRIBUTES` was
originally a colleague's, handed over 2026-07-27 (see git history for that transfer). `PF_PRODUCTS`/
`PF_PRODUCT_VERSIONS` were a colleague's first cut (shell create/edit only — category, name,
delivery type, dates, `continue_on_expiry`; `jsp/pf/product.jsp`/`products.jsp`, live but never
committed) — audited against convention 2026-07-27 and absorbed the same way: free to fix/extend
directly. The colleague is now building the per-attribute-tab dynamic parameter-value screen (paused
on my side per explicit instruction, "sherigim qilayapdi" — do not resume without being asked again);
the backend contract it needs is done (2026-07-29, see "Version rules" below and "Product parameter
API contract"). Not yet built: `PF_APPROVAL_REQUESTS`.

**Version rules (`PF_VERSION_RULES`)** — a cross-parameter business rule engine, fully built
2026-07-29 (`Pf_Util.Evaluate_Version_Rules`/`Get_Rule_Derived_Value`, `Pf_Kernel`/`Pf_Dml`/
`Pf_Sm_Api` CRUD, `jsp/pf/version_rule.jsp` + `parameter_rules.jsp`). Key design points:
- `RULE_TYPE`: `REQUIRED_IF` (target parameter must be non-null), `FORBIDDEN_IF` (target's `Compare_
  Value` match is forbidden), `VALUE_CHECK_IF` (target's value must satisfy the condition — dual use,
  see below). `CONDITION` is a JSON array of `{parameter_id, op, value, value2}` items, AND'd
  together; `TARGET` is a single JSON object `{op, value, value2}` — the parameter it targets is
  `PARAMETER_ID`, a real column, never embedded in the JSON.
- **`VALUE_CHECK_IF` is dual-purpose by design** (not yet split into a dedicated type — see below):
  for a `MANUAL` parameter it validates the entered value; for a `FUNCTION` parameter with no
  manually-entered value, the *same* rows serve as a decision table — `Get_Rule_Derived_Value` reads
  `TARGET.value` directly (ignoring `TARGET.op`) as the computed value, first `SORT_ORDER` match
  wins. Because of this, `Evaluate_Version_Rules`'s general validation loop explicitly **excludes**
  `VALUE_CHECK_IF` rows whose `PARAMETER_ID` is a `FUNCTION`-type parameter (join to `PF_R_PARAMETERS.
  INPUT_TYPE`) — otherwise a decision-table row with no `op` always evaluates to `Match_Target =
  false` and wrongly blocks the save. Hit this exact bug once already; don't re-introduce it.
  **Planned (not yet done)**: split this into an explicit `DERIVE_VALUE` rule type so the two uses
  aren't silently overloaded on one type — remembered, do next time this area is touched.
- Scope: `CATEGORY_ID` (applies to the whole category) or `PRODUCT_ID` (single product override) —
  `PRODUCT_ID` column exists but the JSP UI deliberately only exposes category (user's explicit
  call, 2026-07-29: picking a product doesn't make sense at the point a rule is being authored for a
  category-wide parameter). Re-add the product option later only if asked.
- SM registration: `PF_VERSION_RULE` is a true SM child of `PF_PARAMETER` (`PARENT_OBJECT_CODE` /
  `PARENT_RELATION_KEY` = `parameter_id`), not a JSON-embedded reference — see `inserts/PF_VERSION_
  RULE_SM_CONFIG.sql`. Reached from the UI via a "Rules" button on `parameters.jsp` → `parameter_
  rules.jsp?parameter_id=X` (list scoped to one parameter) → `version_rule.jsp` (constructor).
- The category-select and condition-parameter-select in `version_rule.jsp` are both scoped through
  `PF_R_ATTRIBUTE_CATEGORIES_V` (parameter → its attribute → the categories that attribute is
  actually linked to) — a parameter's attribute can be shared by several parameters and several
  categories (`PF_R_PARAMETERS.ATTRIBUTE_ID` is not unique), so an unscoped list was actively
  misleading; don't regress this back to an unfiltered `PF_R_CATEGORIES_V`/`PF_R_PARAMETERS_V` list.

**Product parameter API contract** (for whoever builds the tab screen — colleague, 2026-07-29):
writes only through `SAVE_PF_PRODUCT_PARAMS` (`Pf_Kernel.Save_Product_Parameter_Values` — validates
required `MANUAL` fields, computes `FUNCTION` fields via `Get_Rule_Derived_Value`, then runs
`Evaluate_Version_Rules` over the *full* parameter context — values from other already-saved
attributes plus the ones just submitted — before persisting anything); live preview (no persistence)
of `FUNCTION` fields as the user types is `PREVIEW_PF_PRODUCT_PARAMS` (`Pf_Kernel.Preview_Product_
Parameters` — deliberately does *not* also run full rule validation, by explicit user choice
2026-07-29; if that's ever wanted, extend this procedure rather than overloading the save path).
Reads: `PF_R_ATTRIBUTE_CATEGORIES_V` (tabs for a category), `PF_R_PARAMETERS_V` (fields for a tab),
`PF_PRODUCT_PARAMETER_VALUES_V` (current saved values, with `VERSION_NO`), `PF_PRODUCTS_V`. See
`inserts/PF_PRODUCT_PARAMS_SM_CONFIG.sql`.

**JSP/UAPP grants — view-only, no exceptions** (see `grants/PF_UAPP_GRANTS.sql`): `UAPP` must never
hold `SELECT`/DML on a `PF_*` *table* directly, only on `_V` views — this was violated (accidentally
by me, and pre-existing on `PF_PRODUCT_PARAMETER_VALUES` with a full `INSERT`/`UPDATE`/`DELETE` grant
from before this session, source unknown) and fully revoked 2026-07-29. If a screen needs to read
something no view yet exposes, add the view first, grant only that. Writes go exclusively through SM
processes (`Core_Api.Execute_Process_Clob`), never a direct table/view grant with DML.

**Product state model**: the prototype (`fabrika-produktov (30).html`) envisions an 8-state
lifecycle (`created→approval→approved→installing→installed→passive/archived`+`install_error`), but
the colleague built a simpler 5-state one instead — `DRAFT`/`ON_APPROVAL`/`ACTIVE`/`SUSPENDED`/
`ARCHIVED` — already wired into `Pf_Kernel.Save_Product` (new products start `DRAFT`) and enforced
by `PF_PRODUCT_VERSION_UX1`, a function-based unique index (`CASE STATE WHEN 'ACTIVE' THEN
PRODUCT_ID END`) guaranteeing only one `ACTIVE` version per product. **Decision (2026-07-27): keep
the 5-state model**, but it's no longer a hardcoded `CHECK` constraint — it's now `PF_R_PRODUCT_
STATES` (a normal `PF_R_*` reference table: `ID`/`CODE`/`ML_NAME_CODE`/`SORT_ORDER`, seeded via
`inserts/PF_R_PRODUCT_STATES_SEED.sql`, no `_H` table — see the lookup-table exception above), with
`PF_PRODUCT_VERSIONS.STATE` (still `VARCHAR2(20)`, unchanged) FK'd to `PF_R_PRODUCT_STATES.CODE`.
Add new states there when the prototype's fuller lifecycle is actually needed, rather than
re-litigating the whole model — no app code change required to add a state, only a JSP dropdown/
label update wherever a state list is rendered.

**Documents (product-attached files)**: a `core/file/` module now exists for this (ported from
`D:\git\mfi\file`, see its own commit) — files are NOT linked to a product via any column on
`FILES` itself; the parent-child link is purely through the generic SM object hierarchy
(`sm_relation_id`/`sm_cache`, the same mechanism every PF entity's own row already uses). Wiring
an actual "Documents" tab into `product.jsp` (SM registration, upload UI) is not done yet.

**`INPUT_TYPE=REFERENCE`** (2026-07-27): a parameter's value can be picked from any *pre-registered*
DB view — never an arbitrary view name typed by whoever's editing the parameter (that would be a
SQL-injection vector the moment something builds a dynamic `SELECT ... FROM <view>` off it).
`PF_R_REFERENCE_VIEWS` (`ID`/`CODE`/`ML_NAME_CODE`/`VIEW_NAME`/`MODULE_CODE`/`SORT_ORDER`, no `_H` —
pure lookup table, see the exception above) is the whitelist: only an admin inserts a row here
(currently via `inserts/PF_R_REFERENCE_VIEWS_SEED.sql`, no JSP CRUD yet), and only *then* can a
parameter reference it. `PF_R_PARAMETERS.REFERENCE_ID` is an FK to this registry's `ID` — never the
raw view name — with `PF_PARAMETER_C6` enforcing `INPUT_TYPE != 'REFERENCE' OR REFERENCE_ID IS NOT
NULL` (same shape as the existing `FUNCTION`/`VALUE_FUNCTION` pair). Any view registered here must
expose `CODE` and `NAME` columns — this is the contract a generic "populate a dropdown from
whichever reference this parameter points to" reader can rely on, matching every existing
`PF_R_*_V` view's shape. `MODULE_CODE` on the registry row records which module the view actually
belongs to (mirrors `PF_R_ATTRIBUTES.MODULE_CODE`) — most entries will be `'PF'`, but a view
registered from another module records that module's code instead.

**`PF_PRODUCT_DELIVERY_TYPE`/`PF_PRODUCTS_V` were found live but undocumented in git** (colleague
work, 2026-07-24) — pulled into git and renamed to match convention
(`PF_R_PRODUCT_DELIVERY_TYPES` + `PF_R_PRODUCT_DELIVERY_TYPES_V`; `PF_PRODUCTS_V` already matched
the naming convention, just needed its dependency on the renamed delivery-type view fixed).
**Lesson**: after renaming/dropping any PF view, always sweep
`SELECT object_name, object_type, status FROM user_objects WHERE status = 'INVALID'` before
declaring the rename done — dropping/renaming an object silently invalidates any other view that
depends on it, and that won't surface until something tries to query it.

**`attribute.jsp`/`attributes.jsp` were found live but undocumented in git** (colleague work,
same discovery as the delivery-type table above) — pulled into git after a user-reported
`ORA-00980` (`attributes.jsp` queried the pre-rename view name `PF_ATTRIBUTES_V`, which had
resolved through a now-target-less stale synonym `UAPP.PF_ATTRIBUTES_V` that couldn't be cleanly
dropped — `ORA-01434`/Oracle Editions visibility quirk, unresolved but harmless once nothing
references it). Fixed by pointing the JSP's raw SQL at `PF_R_ATTRIBUTES_V` directly. While
verifying the fix, found a second, unrelated bug the same way: `attributes.jsp`'s list query
selects `v.CATEGORY_COUNT, v.PARAM_COUNT`, but `PF_R_ATTRIBUTES_V` never had those columns
(`ORA-00904`) — the JSP was written against a view shape that never actually existed live. Fixed
by adding both as correlated-subquery columns to the view (`COUNT(*) FROM
PF_R_ATTRIBUTE_CATEGORIES`/`PF_R_PARAMETERS WHERE ATTRIBUTE_ID = t.ID`). **Lesson**: when
auditing an undocumented JSP against "does it run," don't stop at fixing the symptom that was
reported — run the *exact* query the JSP issues (all columns, not a subset) against the live view
before declaring it fixed; a partial test can pass while the real query still fails.

**`PF_PRODUCTS`/`PF_PRODUCT_VERSIONS` full CRUD (`Pf_Kernel`/`Pf_Dml`/`Pf_Util` Product procedures,
`jsp/pf/product.jsp`/`products.jsp`) were found live but entirely undocumented in git** (colleague
work, discovered 2026-07-27 from a screenshot of a working Products screen — CLAUDE.md still said
"not yet built" at the time). Same lesson as the delivery-type/attribute discoveries above, plus
two new ones this round:
- `PF_PRODUCT_VERSIONS` itself had drifted from git (`VALID_FROM`/`VALID_TO`/`CONTINUE_ON_EXPIRY`
  columns, the `UX1` index) even though nothing in this file's history mentioned adding them —
  always diff the *actual* live `DBMS_METADATA.GET_DDL('TABLE', ...)` against the git file, don't
  trust "I checked this before" from an earlier point in the same session.
- `PF_PRODUCTS_V` had a column silently renamed (`p.CREATED_ON` → `p.CREATED_ON AS CREATED_AT`) to
  match what `products.jsp`'s `ORDER BY CREATED_AT` expected — a view's exposed column names are
  part of its contract just as much as a table's; check the view DDL itself, not just "does the
  query run," when auditing a JSP against a view it queries.

**`PF_R_PARAMETERS.CODE` is unique per `ATTRIBUTE_ID`, not globally** (`PF_PARAMETER_UK1` is a
composite unique constraint on `(ATTRIBUTE_ID, CODE)`) — the same code can be reused across
different attributes. Because of this, `ML_NAME_CODE` for a new parameter is generated from the
row's own numeric ID (`'PF_PARAMETER_' || id`), not from `CODE`, since ML label codes still need
to be globally unique. When editing a parameter, the row being edited is looked up by its true
ID (from `sm_relation_id`), not by `(attribute_id, code)` — the attribute can change during an
edit, and a collision check against the *new* target attribute is done separately.

**ML labels**: `Pf_Kernel` never inserts into `Mlt_Templates`/`Mll_Label_Codes` directly — it
calls `Mll_Dev_Api.Save_Label_With_Template_Dev(...)`, which handles create-vs-update
automatically. Its `o_Code` is **not** a 0=success convention — on success it always returns a
positive informational code (e.g. `TEMPLATE_CREATED`, `TEMPLATE_UPDATED`). The only genuine
failure signal is `o_Code` being NULL — check `if v_Ml_Code is null then -- error`, never `!= 0`.

## Shared packages — re-fetch live state before editing

`Pf_Kernel`/`Pf_Util`/`Pf_Dml`/`Pf_Sm_Api` are edited by more than one developer. **Before
editing any of them**, re-fetch the current live definition first —
`SELECT DBMS_METADATA.GET_DDL('PACKAGE_BODY', 'PF_KERNEL') FROM DUAL;` (etc.) — and diff it
against what you're about to write, rather than blindly overwriting with a cached/remembered or
git-committed version. **This is not hypothetical**: a colleague deployed
`Model_Attribute`/`Save_Attribute`/`Delete_Attribute` directly to the DB, built on top of an
*older* copy of `Pf_Kernel`, silently reverting several already-committed `Save_Parameter` fixes.
Recovering required fetching the full live body of every `Pf_*` package and manually re-merging
both sides' work. `git pull` first, then diff against live DB state, before assuming either side
is current. Also true for tables/views — a colleague added `PF_PRODUCT_DELIVERY_TYPE` and
`PF_PRODUCTS_V` straight to the DB without a git commit (see above); check
`SELECT object_type, object_name FROM user_objects WHERE object_name LIKE 'PF%'` against what's
in `core/pf/` periodically, not just packages.

Packages outside `core/pf/` (`Core_Api`, `Sm_Kernel`, `Sm_Dml`, etc.) are out of scope for PF work
entirely — don't touch them without explicit confirmation, even for an apparent bug fix.

## Deploying changes

- PL/SQL packages/views/SM config inserts: run the `.sql`/`.pck` file directly against the live
  DB via sqlplus — that's the real server, no separate copy step.
- **JSPs and `jsp/pf/css/pf.css` are different**: `D:\git\new_abs\jsp\pf\...` is only the local
  git working copy. The live Tomcat server reads from a separate UNC share:
  `\\172.20.6.157\tomcat9_ABS\webapps\ROOT\ibs\pf\...` (works directly as
  `//172.20.6.157/tomcat9_ABS/webapps/ROOT/ibs/pf/...` from Bash/PowerShell — it's a UNC path,
  not a mapped drive, so `Get-PSDrive`/`net use` won't show it). No automatic sync — every
  change needs an explicit second `cp` to the UNC path, byte-verified with `wc -c` on both
  sides, before saying a screen is ready to test.

### Testing a PF process without the browser

`Core_Api.Execute_Process_Clob`/`Get_Model_Clob` can be called directly from SQL*Plus with the
exact flat JSON the JSP sends — useful when browser access needs a login you don't have. Call
`Auth_Session.Open_Debug_Session(i_Local_Code => '...', i_Reason => '...')` once first, or
`Sm_Dml` fails with a misleading `ORA-01400: cannot insert NULL into
("CORE"."SM_OBJECTS"."CREATED_BY")` (those audit columns come from the `UAPP` session context the
live app sets per-request but a raw session never does):

```sql
DECLARE
  v_Json clob;
BEGIN
  Auth_Session.Open_Debug_Session(i_Local_Code => '01000', i_Reason => 'manual PF test');
  v_Json := '{"process_code":"CREATE_PF_PARAMETER","request":"save","user_id":-1,"code":"X",...}';
  Core_Api.Execute_Process_Clob(v_Json);
END;
/
```

When a real user id is needed for the new `CREATED_BY`/`MODIFIED_BY` audit columns on main
tables, `Core.User_Env.Get_User_Id` is what to read after `Open_Debug_Session` — same source,
same caveat.

## CP1251 encoding for `jsp/pf/*.jsp`

These files are CP1251 with CRLF line endings, mixing Cyrillic and ASCII. **Never edit one of
these files in place, even for a pure-ASCII change** — an in-place edit typically decodes the
file assuming a default encoding before rewriting it, and against a CP1251 file that silently
turns every Cyrillic byte sequence into the U+FFFD replacement character on save, destroying all
Cyrillic text — even in lines you never touched. Confirmed twice: once from copying mojibake
Cyrillic as literal edit text, once from a 100%-ASCII diff (`throws Exception` added to a method
signature) that still corrupted every other Cyrillic string in the file.

**Safe workflow:**
1. Keep/recreate the entire file as proper UTF-8 in a scratch location; edit freely there.
2. Before converting: `file scratch.jsp` → `UTF-8 text`; `grep -c $'\xef\xbf\xbd' scratch.jsp` →
   must be `0`; under `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8`,
   `grep -noP '[ЎҚҒҲўқғҳЎҚҒҲ]' scratch.jsp` → must find nothing (these four Uzbek-only Cyrillic
   letters don't exist in CP1251 — write them as HTML numeric entities instead: lowercase
   ў→`&#1118;`, қ→`&#1179;`, ғ→`&#1171;`, ҳ→`&#1203;`; uppercase Ў→`&#1038;`, Қ→`&#1178;`,
   Ғ→`&#1170;`, Ҳ→`&#1202;`).
3. Convert: `iconv -f UTF-8 -t CP1251//TRANSLIT scratch.jsp | sed 's/$/\r/' > target.jsp`. Check
   the exit code and compare `wc -l`/`wc -c` scratch vs. output — a naive pipeline can silently
   deploy a truncated file if `iconv` errors mid-stream and the exit code isn't checked.
4. Deploy to both the git path and the live UNC share. Never edit `target.jsp` directly again —
   go back to the scratch copy.

## CMS JSP framework (`form_cross.js`) gotchas hit while building PF screens

1. **Save/Cancel controls must be `<input type="submit">` / `<input type="button">`, never
   `<button>`.** A `<button type="submit">` compiles fine, looks identical (same CSS classes
   work on `<input>`), but produces zero reaction on click.

2. **`model_process_code` only gets remapped to `process_code` inside `Get_Model_Clob` —
   `Execute_Process_Clob` does not.** Any field going through `Execute_Process_Clob` (save,
   delete) must be named `process_code` directly.

3. **A static `r="1"` attribute is checked by the framework independently of any JS-driven
   `.required` property.** If a field's requiredness is conditional (e.g. `element.required =
   show;` toggled by another field's value), do not also put `r="1"` on it — the framework reads
   the raw attribute and blocks the whole form's submit whenever that field is empty, regardless
   of your JS. Completely silent failure (only a console warning, no alert). Leave `r` off for
   conditionally-required fields; enforce that rule server-side instead.
   - A checkbox was initially suspected as a related but *different* cause (the framework never
     wires `.check()` onto checkboxes); swapping it for a two-option `Ha`/`Yo'q` `<select>`
     turned out not to be the actual fix for that particular bug — the `r="1"` issue above was.
     Still a reasonable simplification to keep, but check the console before assuming a checkbox
     itself is the problem next time.

4. **After a modal closes and calls `go({})` to refresh a list page, freshly-added CSS rules in
   `pf.css` don't reliably reapply**, even with a cache-busting query string on the `<link>` tag.
   A fresh direct navigation renders correctly; only the post-save `go({})` refresh path doesn't.
   JS logic (`onLoad()`, custom init functions) does still run correctly on that path — only the
   external stylesheet is unreliable there. Fix: duplicate the small set of affected rules inline
   via a `<style>` block directly in the JSP (no separate cache layer to go wrong), rather than
   continuing to chase cache-busting theories. No need to do this preemptively for rules that
   already worked before this pattern was noticed.
