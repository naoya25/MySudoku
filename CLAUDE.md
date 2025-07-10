# 機能単位 MVVM 仕様書 – ナンプレ iOS アプリ

本ドキュメントは **機能単位 MVVM** を採用した実装指針を Markdown 形式でまとめたものです。

---

## 1. ゴール & 前提

* **Swift 5.10 / iOS 18 SDK / SwiftUI** を使用。
* **Feature ごと** に View, ViewModel, Model を物理フォルダでまとめ、**カプセル化**と**疎結合**を維持。
* コアロジックは **単体テスト可能** な形で分離（特に Generator）。

---

## 2. ディレクトリ構成（例）

```text
MySudoku/
├─ App/                       # エントリポイント & 環境設定
│  ├─ MySudokuApp.swift      # @main
│  └─ AppDelegate.swift
├─ Features/
│  ├─ GameBoard/              # プレイ画面
│  │   ├─ Views/
│  │   ├─ ViewModels/
│  │   └─ Models/
│  ├─ Generator/              # 問題生成
│  │   ├─ Algorithms/
│  │   ├─ ViewModels/         # 設定 UI など（将来）
│  │   └─ Tests/
│  ├─ Statistics/             # 戦績・タイム
│  └─ Settings/               # 設定画面
├─ Shared/
│  ├─ Services/               # TimerService, PersistenceService 等
│  ├─ Extensions/             # 汎用 View / Collection 拡張
│  └─ Resources/              # Assets, Localizable.strings
└─ SupportingFiles/
    └─ Assets.xcassets
```

> **Swift Package 分割**: `Generator`, `PersistenceService` は `Packages/` 配下の独立モジュールにしても良い。

---

## 3. Coding Guidelines

| 項目     | 規約                                                                |
| ------ | ----------------------------------------------------------------- |
| 命名     | UpperCamelCase（型）, lowerCamelCase（変数/関数）                          |
| アクセス制御 | 可能な限り `internal` → `private` / `fileprivate` で絞る                  |
| 依存注入   | ViewModel には Service のプロトコルを注入 (`@Environment(\.timerService)`)   |
| 非同期処理  | `async/await` + `Task {}`、Combine は補助的に使用                         |
| UI レイヤ | Logic を持たず、状態は ViewModel 経由でバインド (`@Observable` / `@StateObject`) |
| テスト    | `XCTest`、Generator と ValidationService は 90%+ カバレッジを目標            |

---

## 4. Feature ごとの責務

### 4.1 GameBoard

* 盤面 UI、数字入力、ノートモード切替。
* **ViewModel**: `@Published board`、`selectCell(_:)`, `enterNumber(_:)`, `toggleNoteMode()`。
* **モデル**: `Board`, `Cell`。

### 4.2 Generator

* 難易度別パズル生成（バックトラッキング + difficulty heuristic）。
* 公開 API: `func generate(level: Difficulty) async throws -> Board`。

### 4.3 Statistics

* プレイ履歴保存、ベストタイム集計。
* SwiftData エンティティ：`GameRecord` (`duration`, `finishedAt`, `difficulty`).

### 4.4 Settings

* 効果音/BGM オンオフ、テーマ切替、データリセット。

---

## 5. 共通サービス

| Service                | 役割                                                              |
| ---------------------- | --------------------------------------------------------------- |
| **TimerService**       | 経過秒を `@Published` し、バックグラウンドで自動 pause/resume                    |
| **ValidationService**  | 行・列・ブロックの重複判定、エラー座標を返却                                          |
| **UndoStack**          | `push(move)`, `undo()`, `redo()` – `Observable` で ViewModel と連携 |
| **PersistenceService** | ゲーム中断データの保存/復元、戦績保存                                             |
| **ThemeService**       | ダーク/ライト、カラースキーム管理                                               |

---

## 6. データモデル（例）

```swift
struct Cell: Identifiable, Codable {
    let id: UUID = UUID()
    var value: Int?          // 入力値
    var given: Int?          // 初期値
    var pencilMarks: Set<Int> = []
}

struct Board: Codable {
    var cells: [Cell]        // 81 マス
    var startDate: Date      // ゲーム開始時刻
    var moves: [Move] = []   // Undo/Redo 用履歴
}

struct Move: Codable {
    let cellID: UUID
    let previousValue: Int?
    let newValue: Int?
    let previousMarks: Set<Int>
    let newMarks: Set<Int>
}
```

---

## 7. ビルド手順 & TODO

1. **Xcode プロジェクト作成** → 上記フォルダを物理的に用意。
2. `Board` & `ValidationService` 実装 → `GameBoardView` でプレビュー。
3. `TimerService`, `UndoStack` を実装し ViewModel に統合。
4. `PersistenceService` で途中保存 → アプリ再開時復元を確認。
5. `Generator` を SwiftPackage で実装 & ユニットテスト。難易度パラメータを調整。
6. UI 仕上げ & アクセシビリティ対応。

---

> 🚀 **次のアクション**: まずは `Features/GameBoard` の ViewModel と UI を実装し、数字入力とノートモードを動かしてみましょう。
