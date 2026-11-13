#!/usr/bin/env bash
# Друкує поточні значення датчиків і результати обробки через REST API openHAB.
# Запуск: bash scripts/check.sh            — показати стан
#         bash scripts/check.sh anomaly-on  — увімкнути демо-стрибок на кухні
#         bash scripts/check.sh anomaly-off — вимкнути демо
set -euo pipefail
B="${OPENHAB_URL:-http://127.0.0.1:8083}/rest/items"

case "${1:-}" in
  anomaly-on)  curl -s -X POST -H "Content-Type: text/plain" -d ON  "$B/Demo_Anomaly"; echo "Демо-стрибок увімкнено"; exit ;;
  anomaly-off) curl -s -X POST -H "Content-Type: text/plain" -d OFF "$B/Demo_Anomaly"; echo "Демо-стрибок вимкнено"; exit ;;
esac

show() { printf "%-24s %s\n" "$1" "$(curl -s "$B/$1/state")"; }

echo "== Віртуальні датчики =="
for r in Living Bedroom Kitchen; do show "Temp_$r"; show "Hum_$r"; done
echo "== Обробка: ковзне вікно 1 год =="
for r in Living Bedroom Kitchen; do show "Temp_${r}_Avg1h"; show "Temp_${r}_Min1h"; show "Temp_${r}_Max1h"; show "Hum_${r}_Avg1h"; done
echo "== Будинок зараз =="
for i in House_Temp_Avg House_Temp_Min House_Temp_Max House_Temp_Spread House_Hum_Avg Stats_Updated; do show $i; done
echo "== Агрегована середня за годину =="
for i in HourAgg_Period Temp_Living_HourAgg Temp_Bedroom_HourAgg Temp_Kitchen_HourAgg House_Temp_HourAgg; do show $i; done
echo "== Аномалії =="
for i in Anomaly_Living Anomaly_Bedroom Anomaly_Kitchen Anomaly_Spread Anomaly_Count Anomaly_Last Demo_Anomaly; do show $i; done
