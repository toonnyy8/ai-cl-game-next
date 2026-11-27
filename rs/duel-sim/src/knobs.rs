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
    // the MCTS's search, its full sim and the strategy layer's rollouts (mcts-lite.lisp, cpu-mcts.lisp, strategy-glue.lisp; M2 Task 8)
    mc_full: bool, // cpu-mcts.lisp
    mc_full_lite: KwInts, // cpu-mcts.lisp
    mc_full_h: i64, // cpu-mcts.lisp
    mc_iters: KwInts, // cpu-mcts.lisp
    mc_select_by: Names, // cpu-mcts.lisp (a plist of keywords: GETF)
    mc_sure: KwFloats, // cpu-mcts.lisp
    mc_horizon: i64, // mcts-lite.lisp
    mc_horizon_max: i64, // mcts-lite.lisp
    mc_wait_busy: bool, // mcts-lite.lisp
    mc_ucb_c: f32, // mcts-lite.lisp
    mc_react_p: KwFloats, // mcts-lite.lisp
    mc_prior: Ints, // mcts-lite.lisp
    mc_opp_search: bool, // mcts-lite.lisp
    mc_opp_delay: KwInts, // mcts-lite.lisp
    mc_outcomes: McOutcomes, // mcts-lite.lisp
    mc_outcomes_hard: McOutcomes, // mcts-lite.lisp
    strat_bias_keys: OptNames, // strategy.lisp (MC-EST's bias key per action code)
    cai_cont_p: KwFloats, // tuning.lisp (MC-SETUP's NS going on)
    cai_turn_p: KwFloats, // tuning.lisp (MC-SETUP's turn into the SA)
    strat_c: f32, // strategy.lisp
    strat_h: i64, // strategy.lisp
    strat_swing: f32, // strategy.lisp
    strat_rolls: i64, // strategy.lisp
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
    // the online learner (fq-online.lisp, strategy.lisp; M2 Task 9)
    fq_online_eps: f32, // strategy.lisp
    fq_online_eta: f32, // strategy.lisp
    fq_online_gamma: f32, // strategy.lisp
    fq_online_scale: f32, // strategy.lisp
    fq_online_cap: OptF32, // strategy.lisp (NIL: unclamped)
    retired: Names, // kit.lisp (PLAYABLE-ROSTER's: FQ-RESET-ALL)
    cai_dswitch_dif: KwFloats, // core-ai.lisp
    cai_dswitch_slack: f32, // core-ai.lisp
    cai_styles: crate::cpu::style::CaiStyles, // core-ai.lisp (CAI-DEFSTYLE at load)
    // Kenpachi's matchup styles (cpu-ki-ken.lisp, cpu-kh-ken.lisp; M2 Task 6): chance plists as KwNums (STYLE-DIF's Num)
    kk_brawl_p: KwNums, // cpu-ki-ken.lisp
    kk_read_range: f32, // cpu-ki-ken.lisp
    kk_reach_p: KwNums, // cpu-ki-ken.lisp
    kk_reach_margin: f32, // cpu-ki-ken.lisp
    kk_reach_retry: i64, // cpu-ki-ken.lisp
    kk_ns_stop_p: KwNums, // cpu-ki-ken.lisp
    kk_link_p: KwNums, // cpu-ki-ken.lisp
    kk_as_on_p: KwNums, // cpu-ki-ken.lisp
    kk_link_margin: f32, // cpu-ki-ken.lisp
    kk_dodge_p: KwNums, // cpu-ki-ken.lisp
    kk_step_p: KwNums, // cpu-ki-ken.lisp
    kk_step_lead: i64, // cpu-ki-ken.lisp
    kk_step_max: f32, // cpu-ki-ken.lisp
    kk_clone_strike: i64, // cpu-ki-ken.lisp
    kk_hin_fs: f32, // cpu-ki-ken.lisp
    kk_dodge_lead: i64, // cpu-ki-ken.lisp
    kk_dodge_reach: f32, // cpu-ki-ken.lisp
    kk_kikon_red_p: KwNums, // cpu-ki-ken.lisp
    kk_hoho_in_p: KwNums, // cpu-ki-ken.lisp
    kk_hoho_in_max: f32, // cpu-ki-ken.lisp
    kk_clone_reach: f32, // cpu-ki-ken.lisp
    kk_as_read_p: KwNums, // cpu-ki-ken.lisp
    kk_meaty_p: KwNums, // cpu-ki-ken.lisp
    kk_meaty_lead: i64, // cpu-ki-ken.lisp
    kk_meaty_near: f32, // cpu-ki-ken.lisp
    kk_meaty_min: f32, // cpu-ki-ken.lisp
    kk_meaty_back: i64, // cpu-ki-ken.lisp
    kk_chase_hoho: f32, // cpu-ki-ken.lisp
    kk_awaken_p: KwNums, // cpu-ki-ken.lisp
    kk_climb_p: KwNums, // cpu-ki-ken.lisp
    kk_lunge_p: KwNums, // cpu-ki-ken.lisp
    kk_lunge_band: F2, // cpu-ki-ken.lisp
    kk_l3_range: f32, // cpu-ki-ken.lisp
    kk_bankai_p: KwNums, // cpu-ki-ken.lisp
    kk_l3_sa_p: KwNums, // cpu-ki-ken.lisp
    kk_l3_sa_range: f32, // cpu-ki-ken.lisp
    kk_kikon_ptr_p: KwNums, // cpu-ki-ken.lisp
    kk_special_n: i64, // cpu-ki-ken.lisp
    kk_bk_cashouts: i64, // cpu-ki-ken.lisp
    kk_bk_floor: f32, // cpu-ki-ken.lisp
    kk_bk_ns_p: KwNums, // cpu-ki-ken.lisp
    kk_bk_ns_spare: f32, // cpu-ki-ken.lisp
    kk_bk_ns_range: f32, // cpu-ki-ken.lisp
    kk_bk_walk_range: f32, // cpu-ki-ken.lisp
    kk_wave_p: KwNums, // cpu-ki-ken.lisp
    kk_wave_band: F2, // cpu-ki-ken.lisp
    kk_wave_far: f32, // cpu-ki-ken.lisp
    kk_wave_close_max: f32, // cpu-ki-ken.lisp
    kk_wave_margin: f32, // cpu-ki-ken.lisp
    kk_wave_carry: f32, // cpu-ki-ken.lisp
    kk_chase_frames: i64, // cpu-ki-ken.lisp
    kk_chase_dash: f32, // cpu-ki-ken.lisp
    kk_wave_timeout: i64, // cpu-ki-ken.lisp
    kk_wave_mix: KwNums, // cpu-ki-ken.lisp
    kk_cut_lead: i64, // cpu-ki-ken.lisp
    kk_late_lead: i64, // cpu-ki-ken.lisp
    kk_wave_step_lead: i64, // cpu-ki-ken.lisp
    kk_ns_safe_p: KwNums, // cpu-ki-ken.lisp
    kk_pf_p: KwNums, // cpu-ki-ken.lisp
    kk_wake_hoho_p: KwNums, // cpu-ki-ken.lisp
    kk_wake_hoho_near: f32, // cpu-ki-ken.lisp
    kk_hoho_blind: i64, // cpu-ki-ken.lisp
    kk_pf_window: i64, // cpu-ki-ken.lisp
    kk_step_in_p: KwNums, // cpu-ki-ken.lisp
    kk_hoho_lockout: i64, // cpu-ki-ken.lisp
    kk_hend_p: KwNums, // cpu-ki-ken.lisp
    kk_hend_lead: i64, // cpu-ki-ken.lisp
    kk_cine_wait: KwBools, // cpu-ki-ken.lisp
    kk_cine_gap: i64, // cpu-ki-ken.lisp
    kk_repel_wait: i64, // cpu-ki-ken.lisp
    kk_face_max: f32, // cpu-ki-ken.lisp
    kk_step_in_band: F2, // cpu-ki-ken.lisp
    khf_bait_p: KwNums, // cpu-kh-ken.lisp
    khf_bait_d: f32, // cpu-kh-ken.lisp
    khf_bait_after: i64, // cpu-kh-ken.lisp
    kso_stale: KwNums, // cpu-kh-ken.lisp
    kso_lead: f32, // cpu-kh-ken.lisp
    cai_hoho_p: KwFloats, // core-ai.lisp (read by ICHIGO-KI-STYLE's neutral)
    // Ichigo's matchup styles (cpu-ki-ichigo.lisp, cpu-ki-ichigo-r2b2a1.lisp; M2 Task 7)
    iks_mix: Plist<KwFloats>,
    iks_punish_p: KwNums,
    iks_his_reach: Plist<KwFloats>,
    iks_punish_reach: Nums,
    iks_punish_ns_reach: bool,
    iks_confirm_p: KwNums,
    iks_confirm_slack: i64,
    iks_punishers: Plist<crate::cpu::ichigo_ki::Punishers>,
    iks_confirm_walk: f32,
    iks_ns_wait: KwNums,
    iks_hover: Plist<F2>,
    iks_hover_p1: Plist<F2>,
    iks_bait_hover: Plist<F2>,
    iks_bait_modes: Plist<Names>,
    iks_lunge_band: Plist<F2>,
    iks_patient_forms: Names,
    iks_patient_lunge: bool,
    iks_patient_p: KwBools,
    iks_ns_stop: KwBools,
    iks_walkin_band: Nums,
    iks_wait_max: KwNums,
    iks_ns2_min: f32,
    iks_getsuga_min: f32,
    iks_retreat_to: f32,
    iks_retreat_p: KwNums,
    iks_retreat_rearm: bool,
    iks_p2_wait: KwBools,
    iks_getsuga_his_forms: Names,
    iks_j_reach: f32,
    iks_shot_gap: i64,
    iks_steer_to: i64,
    iks_steer_p: KwNums,
    iks_read_p: KwNums,
    iks_kessa_read_min: KwInts,
    iks_kessa_as: Ints,
    iks_kikon_p: KwNums,
    iks_generic_kikon: KwBools,
    iks_kikon_costly_p: KwNums,
    iks_finish_steer: bool,
    iks_awaken_p: KwNums,
    iks_awaken_modes: Names,
    iks_kessa_chain_band: Nums,
    iks_kessa_lunge_band: F2,
    iks_kessa_space_modes: Plist<Names>,
    iks_kessa_near_band: F2,
    iks_k_sa_reach: f32,
    iks_k_sa_perceived: bool,
    iks_k_sa_dodge_stop: bool,
    iks_k_sa_min: f32,
    iks_close_j_chars: Names,
    iks_lead_vmax: f32,
    iks_burst_no_hoho: KwBools,
    iks_break_p: KwNums,
    iks_break_awaken: bool,
    iks_hoho_p: KwNums,
    iks_hoho_forms: Names,
    iks_untimed_hoho: bool,
    iks_hoho_lead: Window,
    iks_hoho_slide: bool,
    iks_hoho_follow: i64,
    iks_follow_any_perfect: KwBools,
    iks_wake_hoho_p: KwNums,
    iks_wake_hoho_near: f32,
    iks_wake_hoho_forms: Names,
    iks_meaty_p: KwNums,
    iks_meaty_forms: Names,
    iks_meaty_lead: i64,
    iks_meaty_near: f32,
    iks_meaty_space_skip: bool,
    iks_meaty_far: f32,
    iks_hoho_j_reach: f32,
    iks_gap_p: KwNums,
    iks_gap_band: Plist<Nums>,
    iks_gap_cmin: f32,
    iks_gap_wait: f32,
    iks_gap_dash_over: f32,
    iks_gap_max: i64,
    iks_gap_fs: f32,
    iks_gap_lockout: i64,
    iks_gap_dash_need: i64,
    iks_gap_dash_dt: i64,
    iks_gap_dash_his_forms: Plist<Names>,
    iks_mix_keys: Names,
    iks_hisagi_keys: Names,
    iks_finish_even: bool,
    iks_move_band_chars: Names,
    iks_move_band_margin: f32,
    iks_gap_lockout_only: Names,
    iks_cross_band: Plist<Nums>,
    iks_cross_p: KwNums,
    iks_cross_hoho_p: KwNums,
    iks_cross_dt: i64,
    ikw_roll_p: KwNums,
    ikw_roll_x: f32,
    ikw_roll_y: f32,
    ikw_gap_far: f32,
    ikw_gap_watch: i64,
    ikw_gap_off_n: i64,
    ikw_stale: i64,
}

/// A keyword -> number plist knob whose values keep their token's type (`*kso-stale*` `(:easy 900 …)` integers, a chance plist's
/// singles): a style's per-difficulty knob, read through STYLE-DIF / BRAIN-CHANCE as a `cl::Num`.
#[derive(Debug, Clone, Default)]
pub struct KwNums(pub Vec<(String, crate::cl::Num)>);

impl KwNums {
    /// port: GETF with a default.
    pub fn get_or(&self, key: &str, default: crate::cl::Num) -> crate::cl::Num {
        self.0.iter().find(|(k, _)| k.eq_ignore_ascii_case(key)).map_or(default, |&(_, v)| v)
    }
    /// port: components.lisp BRAIN-CHANCE — the plist's value at DIF (a missing key: NORMAL's, else 0.0).
    pub fn chance(&self, dif: crate::components::Difficulty) -> crate::cl::Num {
        self.get_or(dif.name(), self.get_or("normal", crate::cl::Num::F(0.0)))
    }
}

impl duel_data::tuning::Knob for KwNums {
    const KIND: &'static str = "a plist of keyword / number pairs";
    fn from_value(v: &duel_data::tuning::Value) -> Option<KwNums> {
        let num = |x: &duel_data::tuning::Value| match x.as_number()? {
            n if n.is_f64() => n.as_f64().map(|f| crate::cl::Num::F(f as f32)),
            n => n.as_i64().map(crate::cl::Num::I),
        };
        let a = v.as_array()?;
        if a.len() % 2 != 0 {
            return None;
        }
        a.chunks(2).map(|c| Some((c[0].as_str()?.to_string(), num(&c[1])?))).collect::<Option<Vec<_>>>().map(KwNums)
    }
}

/// A keyword -> value plist knob whose values may be NIL (`*iks-hover*` `(:base (3.7 4.2) …)`, `*iks-bait-modes*` `(:easy nil … :hard
/// (:whiff …))`), in its order.
#[derive(Debug, Clone)]
pub struct Plist<T>(pub Vec<(String, Option<T>)>);

impl<T> Plist<T> {
    /// port: GETF — None when KEY is absent, `Some(None)` for a present NIL.
    pub fn getf(&self, key: &str) -> Option<&Option<T>> {
        self.0.iter().find(|(k, _)| k.eq_ignore_ascii_case(key)).map(|(_, v)| v)
    }
    /// GETF of KEY, a present NIL and an absent key both None.
    pub fn get(&self, key: &str) -> Option<&T> {
        self.getf(key).and_then(Option::as_ref)
    }
    /// port: components.lisp BRAIN-CHANCE — DIF's value, else NORMAL's (every such knob has all three keys).
    pub fn chance(&self, dif: crate::components::Difficulty) -> Option<&T> {
        match self.getf(dif.name()) {
            Some(v) => v.as_ref(),
            None => self.get("normal"),
        }
    }
}

impl<T: duel_data::tuning::Knob> duel_data::tuning::Knob for Plist<T> {
    const KIND: &'static str = "a plist of keyword / value-or-NIL pairs";
    fn from_value(v: &duel_data::tuning::Value) -> Option<Plist<T>> {
        let a = v.as_array()?;
        if a.len() % 2 != 0 {
            return None;
        }
        let val = |x: &duel_data::tuning::Value| if x.is_null() { Some(None) } else { T::from_value(x).map(Some) };
        a.chunks(2).map(|c| Some((c[0].as_str()?.to_string(), val(&c[1])?))).collect::<Option<Vec<_>>>().map(Plist)
    }
}

/// A list knob of numbers, each keeping its token's type (`*iks-punish-reach*` `(3.4 0.0 5.0)`, `*iks-gap-band*`'s `(5.25 5.1 18)`);
/// NIL is the empty list.
#[derive(Debug, Clone, Default)]
pub struct Nums(pub Vec<crate::cl::Num>);

impl duel_data::tuning::Knob for Nums {
    const KIND: &'static str = "a list of numbers, or NIL";
    fn from_value(v: &duel_data::tuning::Value) -> Option<Nums> {
        if v.is_null() {
            return Some(Nums(vec![]));
        }
        let num = |x: &duel_data::tuning::Value| match x.as_number()? {
            n if n.is_f64() => n.as_f64().map(|f| crate::cl::Num::F(f as f32)),
            n => n.as_i64().map(crate::cl::Num::I),
        };
        v.as_array()?.iter().map(num).collect::<Option<Vec<_>>>().map(Nums)
    }
}

/// A keyword -> T / NIL plist knob (`*kk-cine-wait*` `(:easy nil :normal nil :hard t)`).
#[derive(Debug, Clone, Default)]
pub struct KwBools(pub Vec<(String, bool)>);

impl KwBools {
    /// port: BRAIN-CHANCE of a T / NIL plist: DIF's value (a present NIL stays NIL), else NORMAL's, else the Lisp's 0.0 (true).
    pub fn chance(&self, dif: crate::components::Difficulty) -> bool {
        let get = |k: &str| self.0.iter().find(|(x, _)| x.eq_ignore_ascii_case(k)).map(|&(_, v)| v);
        get(dif.name()).or_else(|| get("normal")).unwrap_or(true)
    }
}

impl duel_data::tuning::Knob for KwBools {
    const KIND: &'static str = "a plist of keyword / T-NIL pairs";
    fn from_value(v: &duel_data::tuning::Value) -> Option<KwBools> {
        let a = v.as_array()?;
        if a.len() % 2 != 0 {
            return None;
        }
        a.chunks(2).map(|c| Some((c[0].as_str()?.to_string(), <bool as duel_data::tuning::Knob>::from_value(&c[1])?))).collect::<Option<Vec<_>>>().map(KwBools)
    }
}

/// A list knob of symbol names (`*mc-actions*` `(:j1 :sp …)`), lower case as the data.
#[derive(Debug, Clone, Default)]
pub struct Names(pub Vec<String>);

impl Names {
    /// `(member x list)` of a keyword's name (any case, no colon).
    pub fn has(&self, x: &str) -> bool {
        self.0.iter().any(|n| n.eq_ignore_ascii_case(x))
    }
    /// GETF over the list as a plist of keywords (`*iks-hisagi-keys*`).
    pub fn getf(&self, key: &str) -> Option<&str> {
        self.0.chunks(2).find(|c| c[0].eq_ignore_ascii_case(key)).and_then(|c| c.get(1)).map(String::as_str)
    }
}

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

/// A float knob that may be NIL (`*fq-online-cap*`).
#[derive(Debug, Clone, Copy, Default)]
pub struct OptF32(pub Option<f32>);

impl duel_data::tuning::Knob for OptF32 {
    const KIND: &'static str = "a float token or null (NIL)";
    fn from_value(v: &duel_data::tuning::Value) -> Option<OptF32> {
        match v {
            duel_data::tuning::Value::Null => Some(OptF32(None)),
            v => <f32 as duel_data::tuning::Knob>::from_value(v).map(|x| OptF32(Some(x))),
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

/// `*mc-outcomes*` / `*mc-outcomes-hard*`: rows ((character form) 7 values), T written `true` (None here), in their order (ASSOC's
/// first match).
#[derive(Debug, Clone, Default)]
pub struct McOutcomes(pub Vec<(Option<String>, Option<String>, [f32; 7])>);

impl McOutcomes {
    /// port: mcts-lite.lisp MC-OUTCOMES-OF's lookup in this table: (CHARACTER FORM), else (CHARACTER T), else (T T).
    pub fn row(&self, character: &str, form: &str) -> [f32; 7] {
        let is = |x: &Option<String>, n: Option<&str>| match (x, n) {
            (Some(x), Some(n)) => x.eq_ignore_ascii_case(n),
            (None, None) => true,
            _ => false,
        };
        let find = |c: Option<&str>, f: Option<&str>| self.0.iter().find(|(a, b, _)| is(a, c) && is(b, f)).map(|r| r.2);
        find(Some(character), Some(form)).or_else(|| find(Some(character), None)).or_else(|| find(None, None)).expect("a (t t) row")
    }
}

impl duel_data::tuning::Knob for McOutcomes {
    const KIND: &'static str = "a list of ((character form) 7 floats) rows";
    fn from_value(v: &duel_data::tuning::Value) -> Option<McOutcomes> {
        let key = |x: &duel_data::tuning::Value| if x.as_bool() == Some(true) { Some(None) } else { x.as_str().map(|s| Some(s.to_string())) };
        let row = |r: &duel_data::tuning::Value| {
            let r = r.as_array()?;
            let (k, vs) = r.split_first()?;
            let [c, f] = k.as_array()?.as_slice() else { return None };
            let vs: Vec<f32> = vs.iter().map(|x| x.as_f64().map(|f| f as f32)).collect::<Option<_>>()?;
            Some((key(c)?, key(f)?, <[f32; 7]>::try_from(vs).ok()?))
        };
        v.as_array()?.iter().map(row).collect::<Option<Vec<_>>>().map(McOutcomes)
    }
}

/// A list knob of keyword-or-NIL names (`*strat-bias-keys*` `(:b-j1 … nil …)`), lower case as the data.
#[derive(Debug, Clone, Default)]
pub struct OptNames(pub Vec<Option<String>>);

impl duel_data::tuning::Knob for OptNames {
    const KIND: &'static str = "a list of keywords or NIL";
    fn from_value(v: &duel_data::tuning::Value) -> Option<OptNames> {
        let name = |x: &duel_data::tuning::Value| if x.is_null() { Some(None) } else { x.as_str().map(|s| Some(s.to_string())) };
        v.as_array()?.iter().map(name).collect::<Option<Vec<_>>>().map(OptNames)
    }
}
