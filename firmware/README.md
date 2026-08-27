# Firmware

The firmware tree mirrors the hardware product-line split:

- [WULPUS v1 firmware](wulpus-v1): MSP430 acquisition firmware and nRF52
  probe/dongle firmware, with the official flash and toolchain notes beside
  each target.
- [WULPUS PRO firmware](wulpus-pro): ESP32-C6 acquisition firmware plus the
  MSP430 and nRF52 targets used by the PRO system.

Build and flash from the target directory using the vendor toolchain versions
documented there. Firmware revisions must match the board revision and the
host GUI workflow selected under [`software/`](../software/).
