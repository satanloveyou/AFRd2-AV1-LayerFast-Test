# AFRd2 - experimental 4K AV1 fast-switch test

## Change

This test adds an early first-switch path only for 4K AV1 playback on the Amlogic vendor-mode backend (the ATV11 path used by the Tanix W2 Ultra).

- It does **not** trust AV1 `frame rate` or `frame dur` fields from `vdec_status`.
- It reads the actual SurfaceFlinger present-time history before changing HDMI mode.
- It requires at least 100 usable intervals, no outliers, a classifiable average cadence, and no detected change of cadence between the two halves of the history buffer.
- If the layer history is absent, too short, noisy, or mixed, the new path does nothing and the existing envelope measurement remains responsible for mode selection.
- The existing post-switch envelope verification and correction remain enabled.
- Other codecs and the existing Resolution Match geometry selection are unchanged.

The AV1 fast path polls at intervals of 800 ms. SurfaceFlinger normally retains up to 128 present-time entries, so the first decision is expected only after enough new frames have filled the history buffer. For 29.97 fps this is roughly 3.4 seconds of frame history; this is a design estimate, not a measured guarantee. On 23.976 fps the history can take a little over 4 seconds to fill.

## Profile included

- `mode.prefer.exact=1`
- `mode.use.fract=1`
- `fps.measure.envelope.ms=10000`
- `fps.measure.envelope.early.ms=8000`
- `fps.measure.envelope.max.ms=15000`
- `fps.measure.envelope.sub.ms=2500`
- `fps.measure.envelope.skip.ms=1000`
- `fps.correct.enable=1`
- `fps.correct.av1=off`

## Build ARMv7 Magisk ZIP

Requires Android NDK r26d:

```sh
AFRD_ABIS=armeabi-v7a ./mka
sh install/magisk/build-module.sh armeabi-v7a
```

Or run `./build-av1-layer-fast.sh`. Output ZIP: `out/AFRd2-AV1-LayerFast-Test-Magisk-24.3.zip`. Build only; it does not install on a device.

## Validation

Host validation was reported as passing:
- `gcc -std=gnu11 -fsyntax-only -Wall -Icfg_parse afrd.c`
- `sh tests/run_tests.sh`

Android ARMv7 binary is not included. NDK r26d was unavailable in the prior build environment.

## Device acceptance test

1. Play a 4K AV1 29.97 fps clip in SmartTube.
2. Capture `/data/local/afrd.log` from the first `видео ведёт` line.
3. Confirm `быстрое AV1-решение по слою` appears before the normal 8-second envelope decision.
4. Confirm 3840x2160 geometry and `2160p30hz`.
5. Confirm actual display frequency is 29.97 Hz and envelope does not correct to another rate.
6. Stop playback and confirm desktop mode is restored.

If the early layer classification is rejected, the old envelope path remains responsible. Do not loosen the 100-interval, zero-outlier, or two-half transition checks just to force a fast switch.
