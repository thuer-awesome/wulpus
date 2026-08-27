# Errata and design cautions

The PRO acquisition board has four released cautions that affect manufacturing
and bring-up:

1. U16 needs at least 1 uF input capacitance.
2. The HV2707 bleed network changes the effective TX/RX bias; review R23/RGND
   before assembly.
3. PJ1 is symmetrically mirrored relative to the v1 programming adapter; use a
   cable that swaps the pins or the correct PRO programming fixture.
4. J1/J2 connector height is close to the HV2707 height; select the specified
   stack height and verify mechanical clearance.

The official English and Chinese files are preserved as
[`wulpus-pro-acquisition-ERRATA.MD`](wulpus-pro-acquisition-ERRATA.MD) and
[`wulpus-pro-acquisition-ERRATA_ACTIONS_CN.md`](wulpus-pro-acquisition-ERRATA_ACTIONS_CN.md).
The board source also contains `source/docs/ERRATA.MD`.

