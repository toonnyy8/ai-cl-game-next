//! port: duel/lisp/components.lisp (+ engine/lisp/ecs.lisp TRANSFORM, duel/lisp/ichigo.lisp ICS): every slot of each
//! DEFCOMPONENT the sim reads, same order, snake case. Fixnums are i64, single-floats f32, T / NIL slots bool, keyword slots
//! enums whose `Display` is the Lisp name (upper case, no colon). `model` / `blade` are looks (M3); `brain` is
//! `Fighter.has_brain` (decision 3).
use crate::ecs::Entity;
use crate::knobs::Knobs;
use crate::vpad::Vpad;
use std::fmt;

macro_rules! kw_enum {
    ($(#[$m:meta])* $name:ident { $($v:ident = $s:literal),* $(,)? }) => {
        $(#[$m])*
        #[derive(Clone, Copy, Debug, PartialEq, Eq)]
        pub enum $name { $($v),* }
        impl $name {
            pub const ALL: &'static [$name] = &[$($name::$v),*];
            pub fn name(self) -> &'static str { match self { $($name::$v => $s),* } }
            /// The variant named S (any case, no colon), e.g. a data string "kenpachi" or a trace's ":KENPACHI" minus the colon.
            pub fn from_name(s: &str) -> Option<$name> { Self::ALL.iter().copied().find(|v| v.name().eq_ignore_ascii_case(s)) }
        }
        impl fmt::Display for $name {
            fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result { f.write_str(self.name()) }
        }
    };
}

kw_enum!(State { Idle = "IDLE", Guard = "GUARD", GuardHit = "GUARD-HIT", Step = "STEP", Run = "RUN", Hoho = "HOHO", Move = "MOVE",
    Stun = "STUN", Air = "AIR", Down = "DOWN", Wakeup = "WAKEUP", Cine = "CINE", Intro = "INTRO", Win = "WIN", Lose = "LOSE" });
kw_enum!(
    /// FIGHTER-PHASE: a move's pre-strike phase, the run's, or the stun's reaction kind (also a hitwin's REACT).
    Phase { Hold = "HOLD", Aura = "AURA", Dash = "DASH", Follow = "FOLLOW", Main = "MAIN", Run = "RUN", Brake = "BRAKE", Roll = "ROLL",
    Bind = "BIND", Flinch = "FLINCH", Stagger = "STAGGER", Knockback = "KNOCKBACK", Launch = "LAUNCH", Knockdown = "KNOCKDOWN",
    GuardBreak = "GUARD-BREAK", Crumple = "CRUMPLE", Clash = "CLASH",
    // (a value of BREAKER-NEXT-PHASE / KIKON-RUSH-NEXT-PHASE, never stored)
    Strike = "STRIKE" });
kw_enum!(Cls { Na = "NA", Ns = "NS", As = "AS", Sa = "SA" });

impl From<duel_data::MoveClass> for Cls {
    fn from(c: duel_data::MoveClass) -> Cls {
        use duel_data::MoveClass as M;
        match c {
            M::Na => Cls::Na,
            M::Ns => Cls::Ns,
            M::As => Cls::As,
            M::Sa => Cls::Sa,
        }
    }
}

impl From<Cls> for duel_data::MoveClass {
    fn from(c: Cls) -> duel_data::MoveClass {
        use duel_data::MoveClass as M;
        match c {
            Cls::Na => M::Na,
            Cls::Ns => M::Ns,
            Cls::As => M::As,
            Cls::Sa => M::Sa,
        }
    }
}
kw_enum!(Form { Base = "BASE", Nozarashi = "NOZARASHI", Bankai = "BANKAI", Bankai2 = "BANKAI-2", Kessa = "KESSA",
    BankaiBind = "BANKAI-BIND", Blaze = "BLAZE" });
kw_enum!(Character { Yamamoto = "YAMAMOTO", Kenpachi = "KENPACHI", Rukia = "RUKIA", Ichigo = "ICHIGO", Senjumaru = "SENJUMARU",
    Lille = "LILLE", Barro = "BARRO", Hisagi = "HISAGI" });
kw_enum!(HazardKind { Fx = "FX", IcHit = "IC-HIT", Line = "LINE", Wave = "WAVE", YaTower = "YA-TOWER" });
kw_enum!(Contact { Hit = "HIT", Block = "BLOCK" });
kw_enum!(
    /// FIGHTER-QUEUED: the latch.
    Queued { Q = "Q", F = "F", Ns = "NS", Sa = "SA", Sw = "SW", SwNs = "SW-NS", Sp = "SP" });
kw_enum!(Burst { White = "WHITE", Blue = "BLUE", Orange = "ORANGE" });
kw_enum!(
    /// *VPAD-ACTIONS* in order (the index is the vpad button).
    Button { Mod = "MOD", Quick = "QUICK", Flash = "FLASH", Sig = "SIG", Guard = "GUARD", Breaker = "BREAKER", Kikon = "KIKON",
    Step = "STEP", Awaken = "AWAKEN" });
kw_enum!(Flow { Title = "TITLE", Mode = "MODE", Settings = "SETTINGS", Controls = "CONTROLS", Select = "SELECT", Intro = "INTRO",
    Battle = "BATTLE", Finish = "FINISH", Results = "RESULTS" });

/// An index into `Data.moves` (printed `#m::NAME`).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct MoveId(pub u16);

/// FIGHTER-KIT: the kit of a character and form (printed `#k::CHARACTER/:FORM`).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct KitId {
    pub character: Character,
    pub form: Form,
}

/// A symbol slot printed as it is (a hook / look function name `ICHIGO-CLONE-HZ`, or a keyword with its colon `:CRACK`).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Sym(pub &'static str);

/// A Lisp string slot (FIGHTER-CALLOUT): printed with quotes, spaces as `_`.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Str(pub &'static str);

/// A slot that holds either a fixnum or a single-float (a runtime hitwin's GUARD: 22 or 4.2).
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum Num {
    I(i64),
    F(f32),
}

/// port: engine/lisp/ecs.lisp TRANSFORM.
#[derive(Clone, Debug, Default, PartialEq)]
pub struct Transform {
    pub pos: [f32; 3],
    pub yaw: f32,
}

#[derive(Clone, Debug, PartialEq)]
pub struct Motion {
    pub vel: [f32; 3],
    pub kb: [f32; 3],
    pub kb_left: i64,
    pub grounded: bool,
}

impl Default for Motion {
    fn default() -> Self {
        Motion {
            vel: [0.0; 3],
            kb: [0.0; 3],
            kb_left: 0,
            grounded: true,
        }
    }
}

/// FIGHTER-KIKON-UNDO (combat.lisp APPLY-HIT): (def react stun sx sz kb wave react stun).
#[derive(Clone, Debug, PartialEq)]
pub struct KikonUndo {
    pub def: Entity,
    pub react: Phase,
    pub stun: i64,
    pub sx: f32,
    pub sz: f32,
    pub kb: f32,
    pub wave: bool,
    pub kreact: Option<Phase>,
    pub kstun: i64,
}

#[derive(Clone, Debug, PartialEq)]
pub struct Fighter {
    pub side: i64,
    pub opp: Entity,
    pub character: Option<Character>,
    pub form: Form,
    pub kit: Option<KitId>,
    pub state: State,
    pub sf: i64,
    pub phase: Option<Phase>,
    pub mv: Option<MoveId>,
    pub button: Option<Button>,
    pub hold: i64,
    pub follow: bool,
    pub armor_left: i64,
    pub kikon_n: i64,
    pub cd: [i64; 7],
    pub hits: i64,
    pub contact: Option<Contact>,
    pub hz_hit: bool,
    pub queued: Option<Queued>,
    pub chained: bool,
    pub land_sf: i64,
    pub dmg_bonus: i64,
    pub crush: bool,
    pub stun: i64,
    pub glock: bool,
    pub freeze: i64,
    pub lock: i64,
    pub freeze_next: i64,
    pub lock_next: i64,
    pub hoho_lock: i64,
    pub hoho_from: Option<MoveId>,
    pub hoho_cls: Option<Cls>,
    pub hoho_presses: i64,
    pub hoho_mult: f32,
    pub hoho_left: i64,
    pub hoho_hold: bool,
    pub guard_t: i64,
    pub state_t: i64,
    pub ward_until: i64,
    pub stored: i64,
    pub charge: i64,
    pub perfect: bool,
    pub end_chase: bool,
    pub gc_left: i64,
    pub guard_exit: i64,
    pub cls: Option<Cls>,
    pub cls_t: i64,
    pub dead_mv: Option<MoveId>,
    pub dead_t: i64,
    pub pre: i64,
    pub presses: i64,
    pub ptr: i64,
    pub sp_ptr: i64,
    pub tmp: i64,
    pub csa: Option<MoveId>,
    pub sw: i64,
    pub as_done: bool,
    pub sp_held: bool,
    pub bk_out: bool,
    pub charge_mult: f32,
    pub sp_paid: f32,
    pub sp_cost: f32,
    pub sp_back: bool,
    pub sp_gain_t: i64,
    pub xch: i64,
    pub xch_done: bool,
    pub clash_t: i64,
    pub clash_n: i64,
    pub lv_cap: i64,
    pub lv_got: bool,
    pub kikon_lock: i64,
    pub kikon_undo: Option<KikonUndo>,
    pub burst: Option<Burst>,
    pub chain: i64,
    pub invuln: i64,
    pub ox: f32,
    pub oz: f32,
    pub dist: f32,
    pub run_yaw: f32,
    pub combo_hits: i64,
    pub combo_launches: i64,
    pub combo_air: i64,
    pub combo_from: i64,
    pub combo_dmg: i64,
    pub callout: Option<Str>,
    pub callout_t: i64,
    /// Not a slot: the BRAIN component's presence (decision 3; not in the B line).
    pub has_brain: bool,
}

impl Default for Fighter {
    fn default() -> Self {
        Fighter {
            side: 0,
            opp: Entity::NIL,
            character: None,
            form: Form::Base,
            kit: None,
            state: State::Idle,
            sf: 0,
            phase: None,
            mv: None,
            button: None,
            hold: 0,
            follow: false,
            armor_left: 0,
            kikon_n: 2,
            cd: [0; 7],
            hits: 0,
            contact: None,
            hz_hit: false,
            queued: None,
            chained: false,
            land_sf: -1,
            dmg_bonus: 0,
            crush: false,
            stun: 0,
            glock: false,
            freeze: 0,
            lock: 0,
            freeze_next: 0,
            lock_next: 0,
            hoho_lock: 0,
            hoho_from: None,
            hoho_cls: None,
            hoho_presses: 0,
            hoho_mult: 1.0,
            hoho_left: 0,
            hoho_hold: false,
            guard_t: 0,
            state_t: -1,
            ward_until: 0,
            stored: 0,
            charge: 0,
            perfect: false,
            end_chase: false,
            gc_left: 0,
            guard_exit: 0,
            cls: None,
            cls_t: 0,
            dead_mv: None,
            dead_t: -1,
            pre: 0,
            presses: 0,
            ptr: 1,
            sp_ptr: 1,
            tmp: 0,
            csa: None,
            sw: 0,
            as_done: false,
            sp_held: false,
            bk_out: false,
            charge_mult: 1.0,
            sp_paid: 0.0,
            sp_cost: 0.0,
            sp_back: false,
            sp_gain_t: -1,
            xch: -1,
            xch_done: false,
            clash_t: -1,
            clash_n: 0,
            lv_cap: 99,
            lv_got: false,
            kikon_lock: 0,
            kikon_undo: None,
            burst: None,
            chain: 0,
            invuln: 0,
            ox: 0.0,
            oz: 0.0,
            dist: 0.0,
            run_yaw: 0.0,
            combo_hits: 0,
            combo_launches: 0,
            combo_air: 0,
            combo_from: 0,
            combo_dmg: 0,
            callout: None,
            callout_t: 0,
            has_brain: false,
        }
    }
}

#[derive(Clone, Debug, PartialEq)]
pub struct Gauges {
    /// ponytail: i64. The trials' `E set … GAUGES-REISHI 300.0` stores a single-float here (B prints its bits, H `r300.0`);
    /// Task 13 decides how a replay carries that (the cvc traces never do it).
    pub reishi: i64,
    pub reishi_max: i64,
    pub konpaku: i64,
    pub fs: f32,
    pub fs_idle: i64,
    pub burst: Option<Burst>,
    pub burst_t: i64,
    pub burn: f32,
    pub awake_regen: i64,
    pub awake_t: i64,
    pub gg: f32,
    pub gg_idle: i64,
    pub guardless: bool,
    pub awaken: f32,
    pub awakened: bool,
    pub aw_full: bool,
    pub sub: f32,
    pub sub_s: f32,
    pub drive: f32,
    pub evolution: bool,
    pub meter: f32,
    pub meter_idle: i64,
    pub form_left: i64,
    pub burn_step: i64,
    pub taken_melee: i64,
    pub taken_ranged: i64,
    pub stun: f32,
    pub stun_idle: i64,
    pub dealt: i64,
    pub kikons: i64,
    pub perfects: i64,
    pub best_combo: i64,
    pub grey: i64,
    pub evo_t: i64,
}

impl Gauges {
    /// MAKE-GAUGES with its defaults (the maxima are knobs read at construction, as the Lisp's slot initforms).
    pub fn new(k: &Knobs) -> Gauges {
        Gauges {
            reishi: k.reishi_max,
            reishi_max: k.reishi_max,
            konpaku: k.konpaku_max,
            fs: k.fs_max,
            fs_idle: 0,
            burst: None,
            burst_t: 0,
            burn: 0.0,
            awake_regen: 0,
            awake_t: 0,
            gg: k.gg_max,
            gg_idle: 0,
            guardless: false,
            awaken: 0.0,
            awakened: false,
            aw_full: false,
            sub: 0.0,
            sub_s: 0.0,
            drive: 0.0,
            evolution: false,
            meter: 0.0,
            meter_idle: 0,
            form_left: 0,
            burn_step: 0,
            taken_melee: 0,
            taken_ranged: 0,
            stun: 0.0,
            stun_idle: 0,
            dealt: 0,
            kikons: 0,
            perfects: 0,
            best_combo: 0,
            grey: 0,
            evo_t: -1,
        }
    }
}

#[derive(Clone, Debug, PartialEq)]
pub struct Pilot {
    pub vpad: Vpad,
    pub cam_relative: bool,
}

/// A hazard's runtime HITWIN (kit.lisp, slot order): built by the sim, so GUARD may be a float.
#[derive(Clone, Debug, PartialEq)]
pub struct HitWin {
    pub from: i64,
    pub to: i64,
    pub dmg: i64,
    pub vols: Vec<[f32; 6]>,
    pub react: Phase,
    pub kb: f32,
    pub hs: i64,
    pub chip: Option<f32>,
    pub stun: Option<i64>,
    pub guard: Option<Num>,
    pub seg: Option<Sym>,
    pub min: Option<f32>,
    pub steal: Option<i64>,
    pub flags: Vec<Sym>,
}

/// HAZARD-DATA. Seen in the gate: NIL, Ichigo's clone `#ICC{…}` (Task 12), DELAY-HIT's list (combat.rs).
#[derive(Clone, Debug, PartialEq, Default)]
pub enum HzData {
    #[default]
    Nil,
    /// DELAY-HIT's `(def dmg n react stun sx sz kb mv red)`.
    DelayHit { def: Entity, dmg: i64, n: i64, react: Phase, stun: i64, sx: f32, sz: f32, kb: f32, mv: MoveId, red: bool },
}

#[derive(Clone, Debug, PartialEq)]
pub struct Hazard {
    pub kind: Option<HazardKind>,
    pub owner: Entity,
    pub x: f32,
    pub y: f32,
    pub z: f32,
    pub px: f32,
    pub pz: f32,
    pub yaw: f32,
    pub speed: f32,
    pub size: f32,
    pub age: i64,
    pub life: i64,
    pub delay: i64,
    pub hits_left: i64,
    pub rehit: i64,
    pub hw: Option<HitWin>,
    pub src: bool,
    pub hook: Option<Sym>,
    pub data: HzData,
    pub sp: bool,
    pub sp_mv: Option<MoveId>,
    pub cls: Option<Cls>,
    pub sp_paid: f32,
    pub sp_scale: f32,
    pub sp_src: i64,
    pub look: Option<Sym>,
}

impl Default for Hazard {
    fn default() -> Self {
        Hazard {
            kind: None,
            owner: Entity::NIL,
            x: 0.0,
            y: 0.0,
            z: 0.0,
            px: 0.0,
            pz: 0.0,
            yaw: 0.0,
            speed: 0.0,
            size: 0.0,
            age: 0,
            life: 0,
            delay: 0,
            hits_left: 1,
            rehit: 0,
            hw: None,
            src: false,
            hook: None,
            data: HzData::Nil,
            sp: false,
            sp_mv: None,
            cls: None,
            sp_paid: 0.0,
            sp_scale: 1.0,
            sp_src: -1,
            look: None,
        }
    }
}

/// port: duel/lisp/ichigo.lisp ICS (Ichigo's state; attached on first use). Task 12 ports its readers.
#[derive(Clone, Debug, PartialEq)]
pub struct Ics {
    pub dashed: bool,
    pub o_live: bool,
    pub seen: Option<MoveId>,
    pub seen_main: bool,
    pub rseen: i64,
    pub hist: [f32; 48],
    pub hist_i: i64,
    /// ponytail: model-rim's colour (a look); NIL in every gate trace.
    pub rim: Option<[f32; 4]>,
    pub rim_saved: bool,
    pub parry_sf: i64,
    pub bs_key: i64,
    pub bs_at: i64,
    pub o_at: i64,
    pub o_n: i64,
    pub acc_mv: Option<MoveId>,
    pub acc_sf: i64,
    pub acc_hit: Option<Contact>,
    pub acc_kikons: i64,
}

impl Default for Ics {
    fn default() -> Self {
        Ics {
            dashed: false,
            o_live: false,
            seen: None,
            seen_main: false,
            rseen: -1,
            hist: [0.0; 48],
            hist_i: 0,
            rim: None,
            rim_saved: false,
            parry_sf: -1,
            bs_key: -1,
            bs_at: -1,
            o_at: -9999,
            o_n: 0,
            acc_mv: None,
            acc_sf: 0,
            acc_hit: None,
            acc_kikons: 0,
        }
    }
}
