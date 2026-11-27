//! The defparameters the sim reads, typed once from tuning.json (`Knobs::from(&Data)`). A field is the Lisp symbol without
//! stars in snake case (`*hoho-resume-frames*` → `hoho_resume_frames`); its type is the JSON token's (float f32, `{"f64"}`
//! f64, integer i64, T / NIL bool). A missing or wrongly typed key is an `Err` naming it.
//! The list: every scalar defparameter defined in a sim file (tuning, rules, core, sp, control, kit, cinema, ken, ichigo,
//! fighter, gauges, combat, round, core-sim, hazards, scripted, flow, gate, debug, main, sim-state) and read by one
//! (listed by a one-off script in Task 3; later tasks add list / plist knobs as they port their readers).
use duel_data::Data;
use duel_data::tuning::knob;

macro_rules! knobs {
    ($($f:ident: $t:ty,)*) => {
        #[derive(Debug, Clone)]
        pub struct Knobs { $(pub $f: $t,)* }

        impl Knobs {
            #[allow(clippy::should_implement_trait)]
            pub fn from(d: &Data) -> Result<Knobs, String> {
                Ok(Knobs { $($f: knob(&d.tuning, &key(stringify!($f)))?,)* })
            }
        }
    };
}

/// `hoho_resume_frames` → `*HOHO-RESUME-FRAMES*`.
fn key(field: &str) -> String {
    format!("*{}*", field.replace('_', "-").to_uppercase())
}

knobs! {
    dummy_guard_hold: i64, // control.lisp
    dummy_cancel_lead: i64, // control.lisp
    pt_close_shot: f32, // cinema.lisp
    ken_bk_cost: i64, // ken.lisp
    ken_chigiri_stop: i64, // ken.lisp
    ken_tategoto_stop: i64, // ken.lisp
    ke_glass_rays: i64, // ken.lisp
    ken_lv_max: i64, // ken.lisp
    chigiri_burst: i64, // ken-art.lisp (KEN-CHIGIRI-OPEN's look life)
    tategoto_cut: i64, // ken-art.lisp (KEN-TATEGOTO-SPLIT's look life)
    tategoto_wave_len: f32, // ken-art.lisp (KEN-TATEGOTO-SPLIT's ground line)
    walk_ichigo: f32, // ichigo.lisp
    run_ichigo: f32, // ichigo.lisp
    walk_kessa: f32, // ichigo.lisp
    run_kessa: f32, // ichigo.lisp
    ichigo_mult: f32, // ichigo.lisp
    ichigo_taken: f32, // ichigo.lisp
    kessa_mult: f32, // ichigo.lisp
    kessa_taken: f32, // ichigo.lisp
    tsuki_up: i64, // ichigo.lisp
    tsuki_tap: i64, // ichigo.lisp
    tsuki_max: i64, // ichigo.lisp
    tsuki_dash_fs: f32, // ichigo.lisp
    kessa_parry_cost: f32, // ichigo.lisp
    kessa_parry_catch: f32, // ichigo.lisp
    kessa_parry_stun: i64, // ichigo.lisp
    clone_max: i64, // ichigo.lisp
    clone_life: i64, // ichigo.lisp
    clone_lag: i64, // ichigo.lisp
    clone_scale: f32, // ichigo.lisp
    clone_replay_scale: f32, // ichigo.lisp
    clone_burst_dmg: i64, // ichigo.lisp
    zanzo_life: i64, // ichigo.lisp
    zanzo_lag: i64, // ichigo.lisp
    zanzo_mult: f32, // ichigo.lisp
    ai_ic_parry_p: f32, // ichigo.lisp
    ai_ic_parry_bs_p: f32, // ichigo.lisp
    trial_give_up: i64, // scripted.lisp
    reishi_max: i64, // tuning.lisp
    konpaku_max: i64, // tuning.lisp
    red_threshold: f32, // tuning.lisp
    kikon_konpaku: i64, // tuning.lisp
    kikon_konpaku_awakened: i64, // tuning.lisp
    soul_break_extra: i64, // tuning.lisp
    kikon_max_event: i64, // tuning.lisp
    soul_break_max_event: i64, // tuning.lisp
    kikon_trigger: f32, // tuning.lisp
    kikon_follow_kb: f32, // tuning.lisp
    kikon_follow_stun: i64, // tuning.lisp
    kikon_follow_gap: i64, // tuning.lisp
    kikon_track: f32, // tuning.lisp
    armor_from: i64, // tuning.lisp
    reset_distance: f32, // tuning.lisp
    reset_neutral: i64, // tuning.lisp
    match_seconds: i64, // tuning.lisp
    input_buffer: i64, // tuning.lisp
    behind_turn: f32, // tuning.lisp
    face_rate: f32, // tuning.lisp
    track_quick: f32, // tuning.lisp
    track_heavy: f32, // tuning.lisp
    track_breaker: f32, // tuning.lisp
    walk_kenpachi: f32, // tuning.lisp
    step_distance: f32, // tuning.lisp
    step_frames: i64, // tuning.lisp
    step_j_cancel: i64, // tuning.lisp
    run_kenpachi: f32, // tuning.lisp
    run_turn: f32, // tuning.lisp
    run_stop: f32, // tuning.lisp
    run_brake: i64, // tuning.lisp
    run_carry: f32, // tuning.lisp
    run_carry_frames: i64, // tuning.lisp
    guard_raise: i64, // tuning.lisp
    guard_exit: i64, // tuning.lisp
    guard_arc: f32, // tuning.lisp
    block_pushback: f32, // tuning.lisp
    whiff_extra: i64, // tuning.lisp
    whiff_extra_j: i64, // tuning.lisp
    whiff_extra_k: i64, // tuning.lisp
    hazard_blockstun: i64, // tuning.lisp
    chain_lead: i64, // tuning.lisp
    guard_cancel: f32, // tuning.lisp
    ender_push: f32, // tuning.lisp
    ender_push_frames: i64, // tuning.lisp
    ender_o_dash: i64, // tuning.lisp
    ender_o_speed: f32, // tuning.lisp
    ender_chase_max: f32, // tuning.lisp
    string_pull_to: f32, // tuning.lisp
    string_pull_frames: i64, // tuning.lisp
    quick_block_adv: i64, // tuning.lisp
    counter_mult: f32, // tuning.lisp
    counter_stun: i64, // tuning.lisp
    breaker_aura: i64, // tuning.lisp
    breaker_dash_min: i64, // tuning.lisp
    breaker_dash_max: i64, // tuning.lisp
    breaker_speed_min: f32, // tuning.lisp
    breaker_speed_max: f32, // tuning.lisp
    breaker_trigger: f32, // tuning.lisp
    breaker_startup: i64, // tuning.lisp
    breaker_active: i64, // tuning.lisp
    breaker_recovery: i64, // tuning.lisp
    breaker_whiff: i64, // tuning.lisp
    breaker_damage: i64, // tuning.lisp
    breaker_reach: f32, // tuning.lisp
    j_reach_min: f32, // tuning.lisp
    breaker_knockback: f32, // tuning.lisp
    guard_break_stun: i64, // tuning.lisp
    stance_break_stun: i64, // tuning.lisp
    clash_range: f32, // tuning.lisp
    clash_push: f32, // tuning.lisp
    clash_stun: i64, // tuning.lisp
    guard_break_kb: f32, // tuning.lisp
    stance_break_kb: f32, // tuning.lisp
    combo_gain_step: f32, // tuning.lisp
    combo_gain_max: f32, // tuning.lisp
    fs_max: f32, // tuning.lisp
    fs_hoho: f32, // tuning.lisp
    steal_fs_gain: f32, // tuning.lisp
    fs_cell: f32, // tuning.lisp
    sp_cost_rate: f32, // tuning.lisp
    sp_cost_min: f32, // tuning.lisp
    sp_cost_max: f32, // tuning.lisp
    sp_gain_j: f32, // tuning.lisp
    sp_gain_sa: f32, // tuning.lisp
    sp_gain_cancel: f32, // tuning.lisp
    sp_cancel_gain_once: bool, // tuning.lisp
    core_as_sa_out: bool, // tuning.lisp
    core_cancel_dead: bool, // tuning.lisp
    sp_recancel_no_refund: bool, // tuning.lisp
    sp_break_share: f32, // tuning.lisp
    sp_break_gain: f32, // tuning.lisp
    sp_break_flat: f32, // tuning.lisp
    fs_burst: f32, // tuning.lisp
    fs_regen: f32, // tuning.lisp
    fs_delay: i64, // tuning.lisp
    fs_taken: f32, // tuning.lisp
    gg_max: f32, // tuning.lisp
    gg_hazard: i64, // tuning.lisp
    gg_ender: i64, // tuning.lisp
    gg_ender_adv: i64, // tuning.lisp
    gg_breaker: i64, // tuning.lisp
    gg_delay: i64, // tuning.lisp
    gg_regen: f32, // tuning.lisp
    gg_regen_guardless: f32, // tuning.lisp
    guard_crush_stun: i64, // tuning.lisp
    hoho_distance: f32, // tuning.lisp
    hoho_frames: i64, // tuning.lisp
    hoho_lockout: i64, // tuning.lisp
    hoho_resume_frames: i64, // tuning.lisp
    perfect_lead: i64, // tuning.lisp
    perfect_inflate: f32, // tuning.lisp
    perfect_slowmo_seconds: f32, // tuning.lisp
    perfect_slowmo_scale: f32, // tuning.lisp
    perfect_counter_damage: i64, // tuning.lisp
    perfect_counter_stun: i64, // tuning.lisp
    perfect_lock: i64, // tuning.lisp
    hoho_appear: i64, // tuning.lisp
    hoho_counter_pose: i64, // tuning.lisp
    hoho_counter_strike: i64, // tuning.lisp
    awaken_max: f32, // tuning.lisp
    awaken_dealt: f32, // tuning.lisp
    awaken_taken: f32, // tuning.lisp
    awaken_per_konpaku: f32, // tuning.lisp
    awaken_heal: f32, // tuning.lisp
    sub_max: f32, // tuning.lisp
    sub_attack_mult: f32, // tuning.lisp
    sub_gain: f32, // tuning.lisp
    drive_max: f32, // tuning.lisp
    sub_dmg: f32, // tuning.lisp
    sub_taken: f32, // tuning.lisp
    sub_speed: f32, // tuning.lisp
    sub_fs: f32, // tuning.lisp
    sub_keep: f32, // tuning.lisp
    drive_add: f32, // tuning.lisp
    roll_distance: f32, // tuning.lisp
    roll_frames: i64, // tuning.lisp
    knockback_slide_frames: i64, // tuning.lisp
    air_slide: f32, // tuning.lisp
    air_slide_frames: i64, // tuning.lisp
    gravity: f32, // tuning.lisp
    lunge_stop: f32, // tuning.lisp
    chase_max: f32, // tuning.lisp
    chase_margin: f32, // tuning.lisp
    chase_track: f32, // tuning.lisp
    callout_frames: i64, // tuning.lisp
    combo_launches: i64, // tuning.lisp
    combo_air_hits: i64, // tuning.lisp
    combo_full_hits: i64, // tuning.lisp
    combo_decay: f32, // tuning.lisp
    combo_floor: f32, // tuning.lisp
    orange_combo_decay: f32, // tuning.lisp
    orange_combo_floor: f32, // tuning.lisp
    stun_blow_away: bool, // tuning.lisp
    stun_tolerance: f32, // tuning.lisp
    stun_delay: i64, // tuning.lisp
    stun_decay: f32, // tuning.lisp
    stun_blow_kb: f32, // tuning.lisp
    hitstop_light: i64, // tuning.lisp
    hitstop_heavy: i64, // tuning.lisp
    hitstop_breaker: i64, // tuning.lisp
    hitstop_block: i64, // tuning.lisp
    super_freeze: i64, // tuning.lisp
    delay_hit_hold: i64, // tuning.lisp
    arena_radius: f32, // tuning.lisp
    burst_min_hits: i64, // tuning.lisp
    burst_invuln: i64, // tuning.lisp
    burst_push: f32, // tuning.lisp
    burst_push_frames: i64, // tuning.lisp
    burst_hitstop: i64, // tuning.lisp
    burst_drain: f32, // tuning.lisp
    blue_burn: f32, // tuning.lisp
    white_reishi: f32, // tuning.lisp
    white_awaken: f32, // tuning.lisp
    blue_gg_mult: f32, // tuning.lisp
    blue_gg_guarding: f32, // tuning.lisp
    chain_window: i64, // tuning.lisp
    chain_cut: f32, // tuning.lisp
    orange_gain: f32, // tuning.lisp
    kikon_fs_refund: f32, // tuning.lisp
    nozarashi_mult: f32, // tuning.lisp
    cornered_per_konpaku: f32, // tuning.lisp
    cornered_max: f32, // tuning.lisp
    parry_stun: i64, // tuning.lisp
    parry_slide: f32, // tuning.lisp
    stance_in: i64, // tuning.lisp
    stance_hold_max: i64, // tuning.lisp
    stance_store_rate: f32, // tuning.lisp
    stance_store_cap: i64, // tuning.lisp
    stance_base_damage: i64, // tuning.lisp
    stance_crush_at: i64, // tuning.lisp
    bankai_ken_mult: f32, // tuning.lisp
    bankai_konpaku: i64, // tuning.lisp
    hazard_rehit: i64, // tuning.lisp
    ai_burst_low: f32, // tuning.lisp
    cai_finish_at: f32, // tuning.lisp
    core_clash_slowmo_scale: f32, // tuning.lisp
    core_clash_slowmo_seconds: f32, // tuning.lisp
    core_xch_as_delay: i64, // tuning.lisp
    core_kikon_confirm: i64, // tuning.lisp
    kikon_air_hold: i64, // tuning.lisp
    core_damage: f32, // tuning.lisp
    core_pointer_max: i64, // tuning.lisp
    core_kikon_max: i64, // tuning.lisp
    core_soul_break_max: i64, // tuning.lisp
    // keyword -> integer plists (Task 5: rules.lisp's readers)
    reaction_frames: KwInts, // tuning.lisp
    block_add: KwInts, // tuning.lisp
    whiff_add: KwInts, // tuning.lisp
    gg_kind: KwInts, // tuning.lisp
    stun_weights: KwInts, // tuning.lisp
    parry_window: Window, // tuning.lisp
    // frame windows DEFENDER-STATE reads (Task 7: in tuning.json all along; Task 3 listed scalar keys only)
    step_iframes: Window, // tuning.lisp
    hoho_iframes: Window, // tuning.lisp
    air_vy: KwFloats, // tuning.lisp (SET-REACTION, Task 8)
    wave_box: F2, // tuning.lisp (HAZARD-TOUCHES-P, Task 10)
    clone_konpaku: Ints, // ichigo.lisp (CLONE-KONPAKU)
    clone_replay_lags: KwInts, // ichigo.lisp (CLONE-REPLAY-LAG)
    ai_delay: KwInts, // tuning.lisp (SPAWN-FIGHTER's brain, M2)
    ai_dash_frames: i64, // tuning.lisp (AI-DASH, M2)
    ai_mash_starts: i64, // tuning.lisp (AI-MASH-P, M2)
    ai_mash_window: i64, // tuning.lisp (BRAIN-PERCEIVE's JSTARTS, M2)
    ai_strafe_time: Window, // tuning.lisp (AI-STRAFE, M2)
    // the core CPU (core-ai.lisp, xch-ai.lisp, fuzzy.lisp, cpu-mcts.lisp; M2 Task 4)
    cai_think: KwInts, // core-ai.lisp
    cai_range: F2, // core-ai.lisp
    cai_ns_near: f32, // core-ai.lisp
    cai_ns_far: f32, // core-ai.lisp
    cai_ranged_p: f32, // core-ai.lisp
    cai_ranged_gap: i64, // core-ai.lisp
    cai_awaken_p: f32, // core-ai.lisp
    cai_xch_j: crate::cpu::xch_ai::XchJ, // tuning.lisp
    cai_xch_sa_p: KwFloats, // tuning.lisp
    cai_xch_early_p: KwFloats, // tuning.lisp
    cai_xch_early_his_p: KwFloats, // tuning.lisp
    cai_xch_carry_p: KwFloats, // tuning.lisp
    cai_xch_carry_watch_p: KwFloats, // tuning.lisp
    cai_xch_sa_wait: i64, // tuning.lisp
    cai_clash_p: KwFloats, // tuning.lisp
    cai_clash_delay: KwInts, // tuning.lisp
    cai_clash_margin: f32, // tuning.lisp
    cai_awaken_break_p: KwFloats, // tuning.lisp
    cai_awaken_kikon_p: KwFloats, // tuning.lisp
    fz_skill: KwFloats, // fuzzy.lisp
    fz_sets: crate::cpu::fuzzy::FzSets, // fuzzy.lisp
    fz_as_now: crate::cpu::fuzzy::FzRules, // fuzzy.lisp
    fz_ns_turn: crate::cpu::fuzzy::FzRules, // fuzzy.lisp
    fz_ns_cont: crate::cpu::fuzzy::FzRules, // fuzzy.lisp
    fz_kikon: crate::cpu::fuzzy::FzRules, // fuzzy.lisp
    fz_hoho: crate::cpu::fuzzy::FzRules, // fuzzy.lisp
    fz_cancel: crate::cpu::fuzzy::FzRules, // fuzzy.lisp
    fz_burst: crate::cpu::fuzzy::FzRules, // fuzzy.lisp
    mc_on: bool, // cpu-mcts.lisp (T; a list of characters would fail the load)
    mc_off_at: Pairs, // cpu-mcts.lisp
    mc_far: f32, // cpu-mcts.lisp
    mc_defer_gap: i64, // cpu-mcts.lisp
    mc_budget: KwFloats, // cpu-mcts.lisp
    mc_tau: KwFloats, // cpu-mcts.lisp
    mc_actions: Names, // mcts-lite.lisp
    strat_layer: bool, // strategy.lisp (NIL; T or a list / seat would fail the load: STRAT-LAYER-P reads it as T)
    // the strategies and their glue (strategy.lisp, strategy-glue.lisp, core-ai.lisp; M2 Task 5)
    strat_table_chance: KwFloats, // tuning.lisp
    strat_table_window: i64, // tuning.lisp
    strat_switch_period: i64, // strategy.lisp
    strat_event_grace: i64, // strategy.lisp
    strat_period: i64, // strategy.lisp
    strat_regain: i64, // strategy.lisp
    strat_n0: i64, // strategy.lisp
    strat_lambda: KwFloats, // strategy.lisp
    fq_unit: i64, // strategy.lisp
    cai_dswitch_dif: KwFloats, // core-ai.lisp
    cai_dswitch_slack: f32, // core-ai.lisp
    cai_styles: crate::cpu::style::CaiStyles, // core-ai.lisp (CAI-DEFSTYLE at load)
}

/// A list knob of symbol names (`*mc-actions*` `(:j1 :sp …)`), lower case as the data.
#[derive(Debug, Clone, Default)]
pub struct Names(pub Vec<String>);

impl duel_data::tuning::Knob for Names {
    const KIND: &'static str = "a list of keywords";
    fn from_value(v: &duel_data::tuning::Value) -> Option<Names> {
        v.as_array()?.iter().map(|x| x.as_str().map(str::to_string)).collect::<Option<Vec<_>>>().map(Names)
    }
}

/// A list knob of keyword pairs (`*mc-off-at*` `((:ichigo :hard))`).
#[derive(Debug, Clone, Default)]
pub struct Pairs(pub Vec<(String, String)>);

impl Pairs {
    /// `(member (list a b) pairs :test #'equal)`.
    pub fn has(&self, a: &str, b: &str) -> bool {
        self.0.iter().any(|(x, y)| x.eq_ignore_ascii_case(a) && y.eq_ignore_ascii_case(b))
    }
}

impl duel_data::tuning::Knob for Pairs {
    const KIND: &'static str = "a list of keyword pairs";
    fn from_value(v: &duel_data::tuning::Value) -> Option<Pairs> {
        let pair = |p: &duel_data::tuning::Value| match p.as_array()?.as_slice() {
            [a, b] => Some((a.as_str()?.to_string(), b.as_str()?.to_string())),
            _ => None,
        };
        v.as_array()?.iter().map(pair).collect::<Option<Vec<_>>>().map(Pairs)
    }
}

/// A list knob of integers (`*clone-konpaku*` `(2 2 3 4)`).
#[derive(Debug, Clone, Default)]
pub struct Ints(pub Vec<i64>);

impl duel_data::tuning::Knob for Ints {
    const KIND: &'static str = "a list of integers";
    fn from_value(v: &duel_data::tuning::Value) -> Option<Ints> {
        v.as_array()?.iter().map(|x| x.as_i64()).collect::<Option<Vec<_>>>().map(Ints)
    }
}

/// A frame window knob `(from to)`.
#[derive(Debug, Clone, Copy, Default)]
pub struct Window(pub i64, pub i64);

impl duel_data::tuning::Knob for Window {
    const KIND: &'static str = "a list of two integers";
    fn from_value(v: &duel_data::tuning::Value) -> Option<Window> {
        match v.as_array()?.as_slice() {
            [a, b] => Some(Window(a.as_i64()?, b.as_i64()?)),
            _ => None,
        }
    }
}

/// A list knob of two single-floats (`*wave-box*` `(1.2 0.5)`).
#[derive(Debug, Clone, Copy, Default)]
pub struct F2(pub f32, pub f32);

impl duel_data::tuning::Knob for F2 {
    const KIND: &'static str = "a list of two floats";
    fn from_value(v: &duel_data::tuning::Value) -> Option<F2> {
        match v.as_array()?.as_slice() {
            [a, b] => Some(F2(a.as_f64()? as f32, b.as_f64()? as f32)),
            _ => None,
        }
    }
}

/// A keyword -> integer plist knob (`(:flinch 18 :stagger 26 …)`), read with `get` = `(getf plist key default)`.
#[derive(Debug, Clone, Default)]
pub struct KwInts(pub Vec<(String, i64)>);

impl KwInts {
    /// port: GETF over the plist; KEY is the keyword's name in any case, without the colon.
    pub fn get(&self, key: &str, default: i64) -> i64 {
        self.0.iter().find(|(k, _)| k.eq_ignore_ascii_case(key)).map_or(default, |&(_, v)| v)
    }
    /// port: BRAIN-CHANCE over an integer plist (`*cai-clash-delay*`): DIF's, else NORMAL's (the Lisp's 0.0 default is never reached).
    pub fn chance(&self, dif: crate::components::Difficulty) -> i64 {
        self.get(dif.name(), self.get("normal", 0))
    }
}

impl duel_data::tuning::Knob for KwInts {
    const KIND: &'static str = "a plist of keyword / integer pairs";
    fn from_value(v: &duel_data::tuning::Value) -> Option<KwInts> {
        let a = v.as_array()?;
        if a.len() % 2 != 0 {
            return None;
        }
        a.chunks(2).map(|c| Some((c[0].as_str()?.to_string(), c[1].as_i64()?))).collect::<Option<Vec<_>>>().map(KwInts)
    }
}

/// A keyword -> single-float plist knob (`*air-vy*`: `(:launch 7.5 :knockdown 3.5 :air 4.0)`), read with `get` = GETF.
#[derive(Debug, Clone, Default)]
pub struct KwFloats(pub Vec<(String, f32)>);

impl KwFloats {
    /// port: GETF over the plist (KEY in any case, without the colon); a missing key panics (the Lisp's F32 of NIL errors).
    pub fn get(&self, key: &str) -> f32 {
        self.0.iter().find(|(k, _)| k.eq_ignore_ascii_case(key)).map(|&(_, v)| v).unwrap_or_else(|| panic!("no key {key}"))
    }
    /// port: GETF with a default.
    pub fn get_or(&self, key: &str, default: f32) -> f32 {
        self.0.iter().find(|(k, _)| k.eq_ignore_ascii_case(key)).map_or(default, |&(_, v)| v)
    }
    /// port: components.lisp BRAIN-CHANCE — the plist's chance at DIF (a missing key: NORMAL's, else 0).
    pub fn chance(&self, dif: crate::components::Difficulty) -> f32 {
        self.get_or(dif.name(), self.get_or("normal", 0.0))
    }
}

impl duel_data::tuning::Knob for KwFloats {
    const KIND: &'static str = "a plist of keyword / float pairs";
    fn from_value(v: &duel_data::tuning::Value) -> Option<KwFloats> {
        // (a *STRAT-* plist is an object: extract.lisp X-STRAT; its keys are unique, so GETF's order does not matter)
        if let Some(o) = v.as_object() {
            return o.iter().map(|(k, x)| Some((k.clone(), x.as_f64()? as f32))).collect::<Option<Vec<_>>>().map(KwFloats);
        }
        let a = v.as_array()?;
        if a.len() % 2 != 0 {
            return None;
        }
        a.chunks(2).map(|c| Some((c[0].as_str()?.to_string(), c[1].as_f64()? as f32))).collect::<Option<Vec<_>>>().map(KwFloats)
    }
}
