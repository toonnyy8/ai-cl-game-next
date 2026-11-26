# Divergences

BEVY_PORT §2: "A Lisp bug is ported as a bug and listed in `docs/bevy/DIVERGENCES.md` for the user to rule on after parity." This file
lists those bugs, and separately the places where the port knowingly differs from the Lisp on paths no trace reaches.

## 1. Lisp bugs ported as bugs

**None found in M1** (the sim core, Kenpachi, Ichigo; checked 2026-11-27 against the Task 1-14 reports and reviews, and the port's
comments). Every quirk the M1 tasks met is either intended by the Lisp or invisible to play. They are kept bit for bit and listed here
so nobody "fixes" them by accident:

| Where | What the Lisp does | Why it is kept, not a bug |
|---|---|---|
| rules.lisp DIR-YAW vs engine YAW-TO (`math::dir_yaw` / `yaw_to`) | two yaw functions: CL ATAN (a double atan2 rounded to single) and atan2f; they differ in the last bit | DIR-YAW's docstring: the seeded replays were recorded with it, "so the sim keeps it" |
| hazards.lisp HAZARD-CONNECTED during HIT-APPLY (`Match.hz_dead`, hazards.rs 289) | writes a hazard's struct after DESTROY-ENTITY took it (PENDING holds the struct) | the struct is unreachable after its hit; nothing reads the write |
| tools/simgate/trial.lisp `:p2-reishi` / `:p1-reishi` (`cl::Num`) | writes `(f32 x)` into the fixnum Reishi slot, so Reishi becomes a float and flows through CL contagion | the trial runner's, not the game's; a real match never has a float Reishi. The port carries `Num` so trial traces replay. A float damage / time-up under a float Reishi is `unported!` (unreached) |
| tuning.lisp `*stun-blow-away*` NIL | the hidden stun still adds and decays but never blows anyone away | the user's ruling (DEVLOG §173); the docstring says so |
| dead branches (RUN-STEP's guard branch, TSUKI-STEP's `(dash :tsuki-step)` clause, MOVE-COMMANDS' `:kikon` / `:f` / `:sig` / `:sp1` / `:sp2` clauses, the echo window's test for an existing `:blade`) | code no live data reaches | ported where cheap, or dropped with a comment; no behaviour either way |

## 2. Port differences on paths no trace reaches

Not Lisp bugs. These are spots where the Rust stops (a panic, `unreachable!`) or reads differently, only on a path no live data or gate
trace reaches today. Fix each before the milestone that reaches it.

| Where | Lisp | Port | Reached by |
|---|---|---|---|
| `kit::find_move` | FIND-MOVE returns the registry's move (`*moves*`) | the first name match in moves.json: the kit's copy (KE-Z-N2A hs 10 vs the registry's 8); 7 Yamamoto names have a `var/` entry first | M4 (Hisagi / Yamamoto); no M1 caller differs |
| `ken/hooks.rs` `as_pick`'s `nth_as` | `(nth i as)` past the end is NIL, so the pointer's default AS | `expect` panics | a kit with a short `:as` (none) |
| `ichigo/clones.rs` `flag_sym` | an echo window keeps any flag (a keyword) | panics on a flag outside its 19 | a new window flag |
| `combat.rs` `HwRef::Perfect` | `*perfect-hw*` built once at load | read from the knobs live | a debug command changing knobs mid-run |
| `debug::force_form` | ignores SET-FORM's result | `&&`s it (false only on an unported hook) | an unported form hook |
| `flow.rs` TIME-UP under a float Reishi | compares Konpaku, then Reishi | bails (`unported!`) before the Konpaku compare | a trial at the bell with a float Reishi |
| `core_sim::core_next_as` | any length of `:as-by-press` | widens on the stack, up to 16 entries, and panics past that | a kit with more than 16 |
| `fighter/moves.rs` `HookFn::Cine` | a cinematic name in a hook slot | `unreachable!` | none in the data |
