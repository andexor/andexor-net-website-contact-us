<!--
SPDX-License-Identifier: Apache-2.0
Copyright 2026 Andexor Network, Inc.
Author: Ed Jenkins
-->

# Feature Specification: Strict type checking with Pyright

**Feature Branch**: `28-pyright-strict`

**Created**: 2026-11-27

**Status**: Implemented. Pyright reports 0 errors.

**Input**: Issue #28. Asked for on 2026-11-27: the editor (Pylance) showed errors across the code, 80 in all under strict checking, because nothing was annotated and the modules of the Workers runtime have no types. The code is to pass strict type checking with Pyright, the checker that Pylance runs, in the way `andexor-carmen-api` does. This is the first spec in this repo.

## Why

Pylance and the command line must agree, or the editor shows errors that nobody can reproduce or fix once. One configuration file gives both the same rules, and the pipeline keeps the count at zero.

## User Scenarios and Testing

### User Story 1 - The editor shows no type errors (Priority: P1)

A developer opens any Python file of this repo in the editor and sees no errors from Pylance.

**Independent Test**: `./type-check.sh` prints `0 errors`.

**Acceptance Scenarios**:

1. **Given** the repo after `uv sync`,\
   **When** `./type-check.sh` is run,\
   **Then** Pyright checks `src` and `scripts` in strict mode and reports 0 errors.
2. **Given** a function with a parameter that has no annotation,\
   **When** the type check runs,\
   **Then** it fails and names the parameter.

### User Story 2 - A type error does not reach a deployment (Priority: P1)

**Acceptance Scenarios**:

1. **Given** a pull request with a type error,\
   **When** the pipeline runs,\
   **Then** the job `Preview and smoke test` fails at the step `Type check`, before the preview is deployed.
2. **Given** a push to `main` with a type error,\
   **When** the pipeline runs,\
   **Then** production is not deployed.

### User Story 3 - The Worker behaves as before (Priority: P1)

**Acceptance Scenarios**:

1. **Given** the deployed preview,\
   **When** a form is posted,\
   **Then** the answer is `{"ok": true, "id": ...}` with status 200, as before.
2. **Given** a stored row,\
   **When** the Worker tells Carmen,\
   **Then** the log holds `carmen lead ok` for that row, as before.

### Edge Cases

- The modules `js` and `asgi` exist only inside a Worker. An `import` of them cannot be resolved by the checker, so they are loaded by name at the moment of use and typed `Any`.
- The base class of the entry point gives `env` no type. It is read through a cast to `Any`.
- A JSON body that is not an object is treated as an empty form, as before.

## Requirements

### Functional Requirements

- **FR-001**: `pyrightconfig.json` in the repo root sets `typeCheckingMode` to `strict`, includes `src` and `scripts`, and points at `.venv`. Pylance reads the same file.
- **FR-002**: Every parameter and every return value in `src` and `scripts` is annotated.
- **FR-003**: JavaScript objects from the Workers runtime (the environment, a binding, the answer of a binding, a request of the runtime) are typed `Any`.
- **FR-004**: The modules of the Workers runtime that have no types are reached through one function, `_runtime_module`, and not through an `import` statement.
- **FR-005**: `type-check.sh` runs Pyright at a pinned version. The version changes only by a change to that file.
- **FR-006**: The pipeline runs `type-check.sh` after the dependencies are installed and before the preview is deployed.
- **FR-007**: No rule is turned off, and no line is excused with an ignore comment.
- **FR-008**: `create_contact` answers with a `JSONResponse` on every path. The status and the body of a stored row are unchanged: 200 and `{"ok": true, "id": ...}`.

### Not in this feature

- Unit tests. The repo has none.
- Types for the Workers runtime itself.
- A type check of the shell scripts or of the workflow.

## Success Criteria

- **SC-001**: `./type-check.sh` reports 0 errors, 0 warnings.
- **SC-002**: The pipeline's `Preview and smoke test` passes with the step `Type check` in it.
- **SC-003**: On the preview, a posted form answers ok and its lead reaches Carmen.

## Manual steps

None.
