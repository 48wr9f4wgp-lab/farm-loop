# Farm Loop Godot v0.3.2 — Smartphone-First CI

Target: Godot 4.7.2 stable

## 目的
PCを通常開発フローから外し、GitHub Actionsで test → Web export → GitHub Pages を自動化する。

## v0.3.2
- GitHub Actions CI/CD
- Godot 4.7.2自動セットアップ
- Core loop test
- Boot/UI smoke test
- Web release export
- GitHub Pages自動公開
- Web build artifact保存
- build manifest / SHA-256

## 検証状態
ローカル環境ではGodot実行バイナリがないため、実Godot parse/exportはGitHub Actionsが最初の権威ある実行Gateになる。
CIが緑になるまでは起動確認済み扱いにしない。
