# AFRd2 - AV1 LayerFast test build

Private experiment for the Tanix W2 Ultra (Amlogic S905W2, Android 11, ARMv7 userspace, Magisk 24.3).

The build is based on public AFRd2 upstream commit `edcd8ab48be83dc4d22ac248d08f2bf314095206`, then applies the Resolution Match and experimental SurfaceFlinger AV1 fast-path patches from `patches/AFRd2-AV1-Patches.tar.gz`, followed by `patches/03-layer-recheck-720p-test.patch`.

## What the test changes

- For 4K AV1 on the ATV11 vendor-mode path, the initial FPS decision may use SurfaceFlinger present-time intervals instead of the unreliable AV1 decoder `frame dur` value.
- It requires at least 100 usable intervals, zero outliers, a classifiable cadence, and no detected cadence transition between the two halves of the sample.
- If the layer sample is missing or ambiguous, the original envelope measurement remains in charge.
- Post-switch verification and correction remain enabled.
- Resolution Match remains enabled.
- Decoder width/height select the smallest supported progressive HDMI geometry; the 720p decoder-dimension path has an explicit regression test.
- After the refresh rate is pinned, layer sampling checks cadence transitions without redundantly classifying a layer already synchronized to the display.

The fast path polls every 800 ms. The expected first decision around 3.4 seconds for 29.97 fps is an estimate, not a measured guarantee.

## Build

GitHub Actions builds the ARMv7 Magisk package with Android NDK r26d. Run the **Build Magisk 24.3 module** workflow manually.

The workflow checks out the pinned upstream revision, applies all three patches, runs host checks, builds the ARMv7 daemon and SystemControl DEX helper, packages a Magisk 24.3-compatible ZIP, and uploads it as a workflow artifact.

## Device installation

Download the artifact named `AFRd2-AV1-LayerFast-Test-Magisk-24.3`. In Magisk 24.3 choose **Modules -> Install from storage**, select the ZIP and reboot. The module ID remains `afrd2`, so it upgrades the existing AFRd2 module. Keep the rollback ZIP available.

## Acceptance test

Play a 4K AV1 29.97 fps video in SmartTube and inspect `/data/local/afrd.log`:

- look for `быстрое AV1-решение по слою` before the normal envelope decision;
- verify 3840x2160 geometry and `2160p30hz`;
- confirm the actual display rate is 29.97 Hz;
- stop playback and confirm the original desktop mode is restored.

Host tests do not replace testing on the Tanix W2 Ultra.
