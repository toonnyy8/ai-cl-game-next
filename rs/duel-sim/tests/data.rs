//! Task 3: typed knobs and hand-ported constants over the embedded data.
use duel_data::Data;
use duel_sim::{consts, knobs::Knobs, vpad::Vpad};

#[test]
fn knobs_load() {
    let k = Knobs::from(&Data::embedded()).unwrap();
    assert_eq!(k.input_buffer, 10);
    assert_eq!(k.hoho_resume_frames, 12);
    assert_eq!(k.kikon_trigger, 1.6f32);
    assert!(!k.stun_blow_away && !k.core_cancel_dead); // bool knobs (NIL today)
}

#[test]
fn knob_type_error_names_key() {
    let mut d = Data::embedded();
    let float = d.tuning["*KIKON-TRIGGER*"].clone();
    d.tuning.insert("*HOHO-RESUME-FRAMES*".into(), float); // a float where an integer is read
    let e = Knobs::from(&d).unwrap_err();
    assert!(e.contains("*HOHO-RESUME-FRAMES*"), "{e}");
    d.tuning.remove("*HOHO-RESUME-FRAMES*");
    assert!(Knobs::from(&d).unwrap_err().contains("*HOHO-RESUME-FRAMES*"));
}

#[test]
fn pi_is_single() {
    assert_eq!(consts::PI.to_bits(), 0x40490FDB);
    assert_eq!(consts::TWO_PI.to_bits(), 0x40C90FDB);
    assert_eq!(consts::NO_PRESS, -1_000_000);
}

#[test]
fn duel_vpad_from_data() {
    let d = Data::embedded();
    let vp = Vpad::duel(&d, &Knobs::from(&d).unwrap()).unwrap();
    assert_eq!(vp.actions, ["mod", "quick", "flash", "sig", "guard", "breaker", "kikon", "step", "awaken"]);
    assert_eq!((vp.mod_index, vp.buffer), (Some(0), 10));
}
