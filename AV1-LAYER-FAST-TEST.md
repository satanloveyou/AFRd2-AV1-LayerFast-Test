# Experimental 4K AV1 fast-switch path

## Scope

This test adds an early first-switch path only for 4K AV1 playback on the Amlogic vendor-mode backend used by the Tanix W2 Ultra (Android 11).

## Detection

- Does not trust AV1 `frame rate` or `frame dur` fields from `vdec_status`.
- Reads actual SurfaceFlinger present-time history before changing HDMI mode.
- Requires at least 100 usable intervals, zero outliers, a classifiable average cadence, and no detected change of cadence between the two halves of the history buffer.
- If the layer history is absent, too short, noisy, or mixed, the fast path does nothing and the existing envelope measurement selects the mode.
- The existing post-switch envelope verification and correction remain enabled.
- Other codecs and Resolution Match geometry selection are unchanged.

The AV1 fast path polls every 800 ms. For a 128-entry SurfaceFlinger history, the estimated history fill is about 3.4 seconds at 29.97 fps and a little over 4 seconds at 23.976 fps. These are estimates, not measured results.

## Device profile

- `mode.prefer.exact=1`
- `mode.use.fract=1`
- `fps.measure.envelope.ms=10000`
- `fps.measure.envelope.early.ms=8000`
- `fps.measure.envelope.max.ms=15000`
- `fps.measure.envelope.sub.ms=2500`
- `fps.measure.envelope.skip.ms=1000`
- `fps.correct.enable=1`
- `fps.correct.av1=off`

## Acceptance

On the Tanix W2 Ultra, play 4K AV1 29.97 fps in SmartTube. Confirm the layer-fast log entry appears before the normal envelope decision, the mode is `2160p30hz`, the actual display rate is 29.97 Hz, and the original desktop mode is restored after playback stops.

If layer data cannot be classified, the old envelope path must continue working. Do not relax the 100-interval, zero-outlier, or two-half transition checks merely to force a quicker switch.
