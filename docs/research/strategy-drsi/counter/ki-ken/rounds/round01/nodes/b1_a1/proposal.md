# b1_a1: ored-cash
Slice (:own): Ichigo is red (his Konpaku gauge broken, :ored :yes). Strategy: the incumbent's style CPU (:fn ken-ki-style) with the
generic fallback's resource scales up: :kikon 2.5, :cont 1.5, :awaken 2.0 (cash in on a broken opponent: Kikon, go on after a hit).
History: b0_a0 (behind + Reishi high, awaken/kikon/cont up): search 0.76 (+0.005, noise). b1_a0 (ahead, hoho/turn up): 0.705 (-0.05).
b2_a0 (ahead, awaken 0.4): 0.745 (-0.01). All three are lead-based; this one keys on his red state instead (b0_a0 also kept :fn).
Dev (seed0 800, 50 seeds), all keep :fn ken-ki-style, baseline 0.75:
 ored cash (this): 0.76, b10/c9, own 36%.   opp Reishi low + mine high, awaken3/cont1.5/kikon1.5/hoho0.5: 0.73.
 opp Reishi low, similar: 0.76 (b12/c11, own 42%).   opp low + (behind|even): 0.75.   awk + (even|behind), cont1.4 hoho0.6: 0.74.
 ored + mr high, kikon 3.0 cont 1.6 turn 0.7: 0.58 (b12/c29, z -2.7: too much Kikon/less turn hurts).
 Inverse (kikon 0.4 cont 0.8 awaken 0.5 turn 1.4): 0.71; turn 1.5 alone 0.74; kikon 0.4 alone 0.75.
Finding: the style CPU decides most things before the generic layer, so scales barely move the result; only an over-aggressive Kikon
setting is clearly harmful. Expected benefit ~0 to +0.01 (noise); risk low.
