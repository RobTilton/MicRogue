# ArtworkRoom Removal Request Flag
Updated: 2026-10-01
Checkpoint: `[ArtworkRoom]+[AtlasCatalogTable]+[SemanticNamingFullPass]+[RemovalRequestFlag]`
Implementation baseline/evidence: The semantic naming tool's non-destructive `Request Remove` checkbox is human-validated through completed Full Pass 1 snapshot `024`, which reloads with 13 exact Boolean requests.

## Contract

- `remove_requested` is an optional Boolean semantic-record field.
- Missing values in earlier snapshots mean `false`.
- A new save writes an explicit Boolean value for every retained semantic record.
- `true` means Robert requests later catalog-removal review. It does not delete or detach anything.
- Selection snapshots, the 499-entry accepted catalog, static lookup, coordinate identity, atlas pixels, and Production remain unchanged.
- Actual removal requires a later reconciliation checkpoint after the full review.

## F6 Behavior

- `Request Remove` appears below the note editor.
- Requested records display `[REMOVE]` in the list.
- Filtering `remove_requested` isolates requested records.
- The footer reports the current remove-request count.
- A request may exist even when an alias is blank, avoiding the prior friction of inventing a disposable semantic name.
- Clearing the checkbox withdraws the request only in the next append-only snapshot; older evidence remains preserved.

## Validation And Human Gate

- Snapshot `006`, SHA-256 `480aec14d3a2d597118a17506bc501c49df9d193083e6873fb3ea5340f64dcec`, preserves 499 aliases and 20 human-edited records relative to draft snapshot `005`.
- It predates the field and contains no `remove_requested` keys. Validation treats all 499 as Boolean `false` and proves explicit-false JSON round-trip normalization.
- The updated tool loads snapshot `006` without parse or runtime errors.
- Snapshot `024` contains 13 `true` requests and explicit Boolean values for all 499 records. Godot validation and tool reload passed.
- The flag workflow is complete. Actual removal remains separately unauthorized.
