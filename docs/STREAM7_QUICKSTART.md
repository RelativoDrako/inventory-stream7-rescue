# Stream 7 Quick Start

## 1. Mount the USB device

```bash
sudo mkdir -p /mnt/usb
sudo mount /dev/sda1 /mnt/usb
cd /mnt/usb/inventory-stream7-rescue
```

## 2. Run inventory first

```bash
sudo bash ./stream7/stream7-linux-specialized/run_stream7_final.sh probe
```

## 3. Review reports before optimization

```bash
sudo bash ./stream7/stream7-linux-specialized/run_stream7_final.sh reports
sudo bash ./stream7/stream7-linux-specialized/run_stream7_final.sh status
```

## 4. Optional constrained actions

```bash
sudo bash ./stream7/stream7-linux-specialized/run_stream7_final.sh firmware
sudo bash ./stream7/stream7-linux-specialized/run_stream7_final.sh update
sudo bash ./stream7/stream7-linux-specialized/run_stream7_final.sh optimize
sudo bash ./stream7/stream7-linux-specialized/run_stream7_final.sh ui
```

## Menu hints
At launcher start, read the hints:
- inventory first
- use `help`
- review output paths
- do not freeze or optimize before evidence exists
