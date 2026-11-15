#!/usr/bin/env python3
"""gen.py WS — the cells-k briefs of WS's next batch (template.md filled from drsi next-batch); writes briefs/<WS>-r<round>-<cell>.md and
prints their paths."""
import importlib.util, json, os, subprocess, sys
sys.dont_write_bytecode = True
C = os.path.dirname(os.path.abspath(__file__))
A4 = os.path.dirname(C)
SP = os.path.dirname(A4)
R = os.path.abspath(os.path.join(SP, '../../../..'))
D = '/home/toonnyy8/.claude/skills/synced/7f737b32-2195-42cb-9ed8-f258b4adfc44_6dea4635-794e-428f-ad78-e0970a6148e7/dream-rsi/scripts/drsi.py'

KCODE = '`duel/lisp/cpu-ki-ken.lisp` (`ken-ki-style`, the `*kk-*` specials), `duel/lisp/cpu-kh-ken.lisp` (`ken-kh-standoff-style`, `*kso-*`)'
KSHEET = '`A4/kenpachi.md` (the arms, their proof results, and "Re-registered for the cells")'
KVS = ("Ichigo's groups for the KI table (her `none`, her T0 `A4/t0/t0-ki-ichigo.lisp`) and Hisagi's for the KH table (his `none`, his T0 "
       "`A4/t0/t0-kh-hisagi.lisp`); pop files `C/pop-ki-I.json`, `C/pop-kh-H.json` (groups: anchor = none, mix = none and T0 by seed, "
       "rest = T0)")
KPARTS = ("the score is the mean of the KI and KH parts. Baseline (the assembled draft): KI 0.3234 (vs her none 109-77-14, mix 63-130-7, vs "
          "her T0 21-179-0 of 200: K.O. wins-losses-time-outs), KH 0.967 (near its ceiling). The KI part is where the room is; do not "
          "lose the KH part")
KDESC = ('cd ' + A4 + ' && python3 proof.py desc --me kenpachi --vs ichigo --arms {NODE}/scratch/desc-arms.lisp --with x-units/d-x-ki-k.lisp '
         '--seed0 300 --seeds 20 --out {NODE}/scratch/desc-vs-ichigo.json -j 4` (against Hisagi: `--vs hisagi --with x-units/d-x-kh-k.lisp '
         '--out {NODE}/scratch/desc-vs-hisagi.json`)')


def rules_text():
    s = importlib.util.spec_from_file_location('sw', os.path.join(SP, '../fq/switch/sw.py'))
    sw = importlib.util.module_from_spec(s); s.loader.exec_module(sw)
    sw.set_rule_base(':rb-sp2')
    out = ['G0 (36 rules): `(:lead :behind|:even|:ahead) (:ored :no|:yes) (:awst :no|:yes|:k2) (:oawk :no|:yes)` (lead = my Konpaku minus '
           'his; ored = he is red; awst = my awakening not ready / ready / awakened; oawk = he is awakened)']
    g = {}
    for a, gg in sw.RULES:
        if gg:
            g.setdefault(gg, []).append(a)
    for gg, al in g.items():
        out.append(f'G{gg}: ' + '; '.join(f'`{x}`' for x in al))
    return '\n'.join('- ' + x for x in out)


CONF = {
    'k-rush': dict(
        TASK="Tune Kenpachi's general arm **`rush`** (job: close in, PLAN4 §3) so that his table plays better while rush owns its job rules. "
             "Start from BASELINE_DIR's arm.lisp (the assembled draft: Step in, a 6 m Hoho in, the Hoho-safety and the back Step off) or your "
             "parent's; change values and add style keys, do not rewrite the arm. KNOBS §6.1-§6.2 list his 29 style keys and ranges.",
        SHEET=KSHEET, CODE=KCODE, SLOT='a4-k-rush', me='kenpachi', FN='ken-kh-standoff-style', ARMSFILE='kenpachi.lisp',
        JOBNOTE="rush's job rules: in the KI table G3 his cells 0, G2 he is down, G8 the late clock; in the KH table G3 his cells 0 and G8 "
                "late. The other arms (all, guard, spend, climb; wave in KI, bait in KH) stay as assembled",
        VSDESC=KVS, SCOREPARTS=KPARTS, NSCORE=4, EVALCOST='each run = 2 eval.py calls, KI and KH: the cap is 8 eval.py calls',
        DESCBAR="`nstart_r` (his move starts while the opponent is idle or running, per 1000 steps, pooled) >= arm 0's x 1.25, against "
                "Ichigo's `none` AND Hisagi's `none` (pre-registered in kenpachi.md)",
        DESC=KDESC, EXTRAFILES=''),
    'k-guard': dict(
        TASK="Tune Kenpachi's general arm **`guard`** (job: hold and answer, PLAN4 §3) so that his table plays better while guard owns its "
             "job rules. Start from BASELINE_DIR's arm.lisp (the assembled draft: the brawl read from 4 m, the dodge, the back Step to 7 m, "
             "no lunge, no Step / Hoho in) or your parent's; change values and add style keys, do not rewrite the arm. Played whole the draft "
             "is weak against Ichigo (K.O. wins .37) and is almost arm 0 against Hisagi (mean distance +0.09 m). KNOBS §6.1-§6.2 list his "
             "29 style keys and ranges.",
        SHEET=KSHEET, CODE=KCODE, SLOT='a4-k-guard', me='kenpachi', FN='ken-kh-standoff-style', ARMSFILE='kenpachi.lisp',
        JOBNOTE="guard's job rules (both tables): G0 he leads (my Konpaku ahead) and G4 the opponent's Burst ready. The other arms stay as "
                "assembled",
        VSDESC=KVS, SCOREPARTS=KPARTS, NSCORE=4, EVALCOST='each run = 2 eval.py calls, KI and KH: the cap is 8 eval.py calls',
        DESCBAR="`mean_d` (mean distance) >= arm 0's + 0.30 m, against Ichigo's `none` AND Hisagi's `none` (pre-registered in kenpachi.md)",
        DESC=KDESC, EXTRAFILES=''),
    'k-wave': dict(
        TASK="Tune Kenpachi's targeted arm against Ichigo, **`wave`**: the answer to her pointer-2 Getsuga route (`:kk-wave-p`, PLAN4 §3) "
             "and the keys that shape what he does around it. Start from BASELINE_DIR's arm.lisp (arm 0 with `:kk-wave-p 0.9`; arm 0 has 0) "
             "or your parent's. The answer's plan (cpu-ki-ken.lisp `kk-wave-plan`, `kk-wave-step`: :close / :cut / :late / :step by "
             "`*kk-wave-mix*`, a list, not a key) uses his Hoho, his Step and his NS reach: `:kk-hin-fs`, `:kk-step-*`, `:kk-reach-*`, "
             "`:kk-ns-safe-p`, `:range` etc. are in play. KNOBS §6.1-§6.2.",
        SHEET=KSHEET, CODE=KCODE, SLOT='a4-k-wave', me='kenpachi', FN='ken-kh-standoff-style', ARMSFILE='kenpachi.lisp',
        JOBNOTE="wave's job rules: G10 her SP pointer 2 (all three distances; her pointer 2 is the Getsuga's) in the KI table. The other arms "
                "stay as assembled",
        VSDESC="Ichigo's groups (her `none`, her T0 `A4/t0/t0-ki-ichigo.lisp`, whose arm `keep` runs the pointer-2 Getsuga at range; pop "
               "`C/pop-ki-I.json`: anchor = none, mix = none and T0 by seed, rest = T0)",
        SCOREPARTS="one part (KI). Baseline (the assembled draft) 0.3234: vs her none 109-77-14, mix 63-130-7, vs her T0 21-179-0 of 200 "
                   "(K.O. wins-losses-time-outs)",
        NSCORE=8, EVALCOST='each run = 1 eval.py call',
        DESCBAR="`evade` (Steps + Hohos a match) >= arm 0's x 1.2 against Ichigo's `a4-i-keep` played whole (her arm that runs the Getsuga "
                "route); K.O. >= 50 % and distinctness against her `none` (pre-registered in kenpachi.md)",
        DESC='cd ' + A4 + ' && python3 proof.py desc --me kenpachi --vs ichigo --arms {NODE}/scratch/desc-arms.lisp --with '
             'x-units/d-x-ki-k.lisp --opp cells-k/opp-ki-ichigo-keep.lisp --seed0 300 --seeds 20 --out {NODE}/scratch/desc-vs-keep.json -j 4`',
        EXTRAFILES=''),
    'i-vsh': dict(
        TASK="Find and build **Ichigo's targeted arm against Hisagi** (PLAN4 §3: 1-2 targeted arms a pairing, \"vs H: found by the search\"): "
             "a job her four general arms do not cover, in a situation Hisagi creates, that wins it. Her general arms (A4/ichigo.lisp): "
             "`all` (arm 0, the patient hover-and-punish), `brawl` (close pressure; job G2 he is free), `keep` (the pointer-2 Getsuga at "
             "range, distance held; job G8 she leads), `kessa2` (awakened KESSA pressure; job G0 awakened, G1 form 1). You choose BOTH the "
             "job rules (where your arm plays) and the arm's keys (KNOBS §6.3, §6.7; arm `:rules` on strat-feats cues allowed). Read what "
             "Hisagi does (A4/hisagi.md: his five arms and their jobs; his T0 `A4/t0/t0-ih-hisagi.lisp`; his ranged Bankai mode, the kite, "
             "the press while her Reishi is low) before choosing.",
        SHEET='`A4/ichigo.md` (her arms and their proofs), `A4/hisagi.md` (his arms), `SP/diag/all-tiers-table.md` (IH is a hard cell)',
        CODE='`duel/lisp/cpu-ki-ichigo.lisp`, `duel/lisp/cpu-ki-ichigo-r2b2a1.lisp` (her style); Hisagi: `duel/lisp/cpu-hk-hisagi.lisp`, '
             '`duel/lisp/cpu-hisagi-range.lisp`, `duel/lisp/cpu-ih-hisagi-ihr1b2a0.lisp`',
        SLOT='a4-i-vsh', me='ichigo', FN='ichigo-ki-r2b2a1-style (keep it: one style function, so a switch keeps her state)',
        ARMSFILE='ichigo.lisp',
        JOBNOTE="your arm joins her IH T0 (`A4/t0/ih-ichigo.json`'s four arms, `:with d-x-ih-i`) as a fifth arm with the job rules of "
                "`{NODE}/job.json`: +0.06 in the job rules, -0.06 / n in the rest of the n groups the job names, n <= 2 (score.py's table "
                "writer refuses 3: 0.02 = the margin). A job entry `[G, [\"(:cue :set)\", ...]]` selects the rules of group G whose "
                "antecedent contains every listed string; several entries OR. The :rb-sp2 rules:\n" + rules_text(),
        VSDESC="Hisagi's groups (his `none`, his T0 `A4/t0/t0-ih-hisagi.lisp`; pop `C/pop-ih-H.json`: anchor = none, mix = none and T0 by "
               "seed, rest = T0)",
        SCOREPARTS="one part. Baseline (her four-arm IH T0 without your arm) 0.8267: vs his none 159-32-9, mix 166-30-4, vs his T0 173-27-0 "
                   "of 200 (K.O. wins-losses-time-outs)",
        NSCORE=8, EVALCOST='each run = 1 eval.py call',
        DESCBAR="the descriptor and bar YOU pre-register before your first score.py run (in `job.json` and in proposal.md's first section): "
                "one of proof.py's TOL descriptors (`mean_d close mid far awk p2 p3 sp burst kikon spend wake_kd evade acts clash nstart "
                "nstart_r k_sp k_d`), against arm 0 `a4-i-all`, an op (`+` / `-` / `x` / `x<`) and an amount, measured against Hisagi's "
                "`none` (or, if your job only shows against one of his arms, that arm from `A4/hisagi/` played whole, named in job.json's "
                "\"opp\"); plus distinct from all four general arms (proof.py's `~` mark). A later attempt of your branch may keep or change "
                "the job; it re-registers before its own first run",
        DESC='cd ' + A4 + ' && python3 proof.py desc --me ichigo --vs hisagi --arms {NODE}/scratch/desc-arms.lisp --with '
             'x-units/d-x-ih-i.lisp --seed0 300 --seeds 20 --out {NODE}/scratch/desc-vs-hisagi.json -j 4` (put the four general arms of '
             '`A4/ichigo.lisp` first, `a4-i-all` first, then yours: proof.py marks with `~` an arm not distinct from another)',
        EXTRAFILES=', `{NODE}/job.json` (`{"job": [[G, ["(:cue :set)", ...]], ...], "descriptor": "...", "op": "+", "amount": 0.3, "opp": '
                   '"none"}`, written BEFORE your first score.py run)'),
}


def main():
    ws = sys.argv[1]
    W = os.path.join(C, ws)
    cfg = json.load(open(os.path.join(W, 'config.json')))
    d = json.loads(subprocess.run([sys.executable, D, '-w', W, 'next-batch'], capture_output=True, text=True).stdout)
    tpl = open(os.path.join(C, 'template.md')).read()
    os.makedirs(os.path.join(C, 'briefs'), exist_ok=True)
    for w in d.get('work', []):
        f = dict(CONF[ws], R=R, WS=ws, CELL=w['cell'], ROUND=d['round'], NODE=w['node_dir'], BR=w['branch'],
                 NODES=os.path.join(W, f"rounds/round{d['round']:02d}/nodes"), PARENT=w['parent_dir'] or 'none (a new direction)',
                 HIST=', '.join(w['history_dirs']) or 'none', BASE=os.path.join(W, 'baseline'), BSC=cfg['baseline_score'],
                 DIRECTION=w.get('direction') or '(none: the whole arm)', EVAL=d['eval_command'].replace('{node_dir}', w['node_dir']))
        out = tpl
        for _ in range(2):                                   # (a field may hold {NODE})
            for k, v in f.items():
                out = out.replace('{' + k + '}', str(v))
        p = os.path.join(C, 'briefs', f"{ws}-r{d['round']}-{w['cell']}.md")
        open(p, 'w').write(out)
        os.makedirs(os.path.join(w['node_dir'], 'scratch'), exist_ok=True)
        print(p)


if __name__ == '__main__':
    main()
