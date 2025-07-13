# TODO

## プロジェクト全体改善タスク

### 🔥 最優先（Critical）

- [ ] **Position構造体の移動**: ValidationService.swift内の`Position`構造体をModel/Common/Position.swiftに移動
  - 影響: GameBoardViewModel、ValidationServiceの依存関係を整理
  - 理由: データモデルがサービス層に混在している設計上の問題

- [ ] **UndoStack の実装**: CLAUDE.md仕様に記載されているUndoStackクラスを実装
  - 場所: Services/UndoStack.swift
  - 機能: push, undo, redo。ジェネリック型でMoveを扱う
  - 理由: 仕様書に明記されているが未実装

- [ ] **基本的なユニットテスト の実装**: 現在はサンプルテストのみ
  - Board、Cell、Moveのユニットテスト
  - ValidationServiceの境界値テスト
  - TimerServiceの状態遷移テスト
  - 理由: 品質保証の基盤が不足

### 🔶 高優先（High）

- [ ] **GameBoardViewModel の責務分離**: 250行近くの巨大クラスを分割
  - GameTimerManager: タイマー機能専用
  - GameValidationManager: バリデーション機能専用
  - GameSolutionManager: ソリューション機能専用
  - 理由: 単一責任原則に違反、テストが困難

- [ ] **依存注入の導入**: ViewModelでのサービス直接インスタンス化を修正
  - プロトコルベースの依存注入パターンの導入
  - TimerServiceProtocol、ValidationServiceProtocolの作成
  - 理由: テスタビリティ向上、疎結合化

- [ ] **エラーハンドリングの統一**: 異なるサービス間でのエラー処理方式を統一
  - 共通のAppErrorenum作成
  - 統一されたエラー表示UI
  - 理由: ユーザー体験とコード保守性の向上

- [ ] **認証機能の分離**: LoginViewModelをHome配下から独立
  - ViewModel/Auth/LoginViewModel.swiftに移動
  - View/Auth/LoginView.swiftも対応
  - 理由: 機能境界の明確化

### 🔸 中優先（Medium）

- [ ] **PersistenceService の実装**: CLAUDE.md仕様のSwiftDataによるローカル保存
  - プレイ途中の状態保存
  - 戦績データの永続化
  - 理由: 仕様書に明記されているが未実装

- [ ] **ThemeService の実装**: CLAUDE.md仕様のテーマ管理機能
  - ダーク/ライトモード切替
  - カラースキーム管理
  - 理由: アクセシビリティとユーザー体験向上

- [ ] **ディレクトリ構成の整理**:
  ```
  Model/
  ├─ GameBoard/ (既存)
  ├─ Common/ (新規)
  │  ├─ Position.swift
  │  └─ ValidationResult.swift
  └─ Network/ (新規)
     └─ SupabaseResponse.swift
  ```

### 🔹 低優先（Low）

- [ ] **定数の整理**: ハードコーディングされた数値を定数化
  - GameConstants構造体の作成（boardSize=9, totalCells=81等）
  - 理由: コードの可読性と保守性向上

- [ ] **HTTPリクエストの共通化**: SupabaseService内の重複コード削減
  - 共通のリクエスト構築メソッド作成
  - 理由: DRY原則、保守性向上

- [ ] **パフォーマンス最適化**:
  - GameBoardViewModelの差分更新システム導入
  - 全81セル再計算の最適化
  - 理由: ユーザー体験の微調整

### 既存TODO
- [ ] difficulty の動的変化

## 改善実施順序の推奨

1. Position構造体移動 → UndoStack実装 → 基本テスト実装
2. GameBoardViewModel分離 → 依存注入導入
3. エラーハンドリング統一 → 認証機能分離
4. PersistenceService → ThemeService実装
5. 細かい最適化項目

この順序で進めることで、アーキテクチャの基盤を固めてから機能拡張に進むことができます。
