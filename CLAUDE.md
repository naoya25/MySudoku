# MVVM 仕様書 – MySudoku（ナンプレ iOS アプリ）

本ドキュメントは **クラシック MVVM**（Model / View / ViewModel をレイヤーごとに分割）を採用した実装指針です。SwiftUI 未経験の開発者でも迷わずに実装できるよう、ディレクトリ構成と各レイヤーの責務を整理しています。

---

## 1. ゴール & 前提

* **Swift 5.10 / iOS 18 SDK / SwiftUI** 使用。
* 盤面ロジック・UI・状態管理を **MVVM の 3 レイヤー**に分離し、**疎結合**と**テスト容易性**を高める。
* コアロジック（問題生成・検証）はユニットテストにより品質保証。

---

## 2. ディレクトリ構成（例）

```text
./MySudoku/
MySudoku/
├─ MySudokuApp.swift          # @main エントリポイント
├─ Assets.xcassets/           # アセット
├─ Model/                     # モデル
│  └─ Home/
├─ View/                      # ビュー
│  └─ Home/
│      └─ HomeView.swift
├─ ViewModel/                 # ビューモデル
│  └─ Home/
│      └─ HomeViewModel.swift
└─ Preview Content/
    └─ Preview Assets.xcassets/
```

> **ポイント**
>
> * `Model`, `View`, `ViewModel` を **トップレベルで明確に分離**。
> * 各レイヤー内を **機能（Home など）サブフォルダ** でまとめ、将来機能追加時に拡張しやすい構成。
> * アセットは `Assets.xcassets`、プレビュー専用は `Preview Content/` に分離して管理。
> * 必要に応じて `Services/` や `Resources/` ディレクトリを後から追加し、プロジェクト拡大に合わせてモジュール化可能。

---

## 3. Coding Guidelines

| 項目         | 規約                                                               |
| ------------ | ------------------------------------------------------------------ |
| 命名         | UpperCamelCase（型）, lowerCamelCase（変数/関数）                  |
| アクセス制御 | 可能な限り `internal` → `private` / `fileprivate` に絞る           |
| 依存注入     | ViewModel に Service プロトコルをコンストラクタ/Environment で注入 |
| 非同期処理   | `async/await` + `@MainActor`。Combine は補助的に使用               |
| UI レイヤ    | ビジネスロジックを持たず、状態は ViewModel へ委譲 (`@StateObject`) |
| テスト       | `XCTest`。Model & Services は 90%+ カバレッジを目標                |

---

## 4. レイヤーごとの責務

### 4.1 Model

* **純粋データ構造** (`Board`, `Cell`, `Move`) と **ドメインロジック**（バリデーション、生成）。
* Swift Package 化すれば iPadOS/macOS でも再利用可。

### 4.2 ViewModel

* View からのユーザー操作を受け、Model/Service へ伝達。
* `@Published` プロパティで View へ状態を公開。
* 例: `GameBoardViewModel` に `selectCell(_:)`, `enterNumber(_:)`, `toggleNoteMode()`。

### 4.3 View

* `GameBoardView` など SwiftUI 構成要素。`@StateObject var vm: GameBoardViewModel` を保持。
* すべてのロジックは ViewModel に委譲し、UI は宣言的にレンダリングのみ。

---

## 5. 共通サービス概要

| Service                | 役割                                                                            |
| ---------------------- | ------------------------------------------------------------------------------- |
| **TimerService**       | 経過秒を `AsyncStream` + `@Published` で配信し、バックグラウンドで pause/resume |
| **ValidationService**  | 行・列・ブロックの重複判定とエラー座標返却                                      |
| **UndoStack**          | `push`, `undo`, `redo`。ジェネリック型で任意の `Move` を扱う                    |
| **PersistenceService** | SwiftData でプレイ途中／戦績を保存                                              |
| **ThemeService**       | ダーク / ライト、カラースキーム切替を管理                                       |

---

## 5.1 データベーススキーマ

### Supabase テーブル定義

```sql
create table public.admin_users (
  user_id uuid primary key references auth.users (id) on delete cascade
);


create table public.sudoku (
  id CHAR(26) primary key, -- ULIDは26文字の英数字
  given_data VARCHAR(81) not null, -- 81文字の問題データ
  solution_data VARCHAR(81) not null, -- 81文字の解答データ
  difficulty SMALLINT not null default 1500, -- 難易度（初期値1500）
  created_at TIMESTAMP default CURRENT_TIMESTAMP
);
```

**フィールド説明:**
- `id`: ULID形式のプライマリキー（26文字の英数字）
- `given_data`: 初期盤面データ（81文字の文字列、空マスは0で表現）
- `solution_data`: 完全解答データ（81文字の文字列）
- `difficulty`: 難易度スコア（デフォルト1500）
- `created_at`: レコード作成日時

---

## 6. データモデル例

```swift
struct Cell: Identifiable, Codable {
    let id: UUID = UUID()
    var value: Int?          // ユーザー入力値
    var given: Int?          // あらかじめ埋められた数字
    var pencilMarks: Set<Int> = []
}

struct Board: Codable {
    var cells: [Cell]        // 81 マス
    var startDate: Date      // ゲーム開始時刻
    var moves: [Move] = []   // Undo/Redo 用
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

## 7. ドキュメント

docsディレクトリに主要機能のドキュメントが書かれています。
機能ごとに追記、修正を行ってください。

修正すべきタスクや今後のタスクは、docs/todo/CLAUDE.mdに記載してください。
