
# ナンプレ難易度算出システム

## 概要
ナンプレの難易度を定量的に評価するための詳細な仕様です。

## 基本難易度計算式

### 1. 基本難易度（初期値）
```
基本難易度 = 1000 + (空きマス数 * 25)
```

### 2. 解法技術による難易度係数
各セルを埋める際に必要な技術レベルに応じて係数を適用：

| 技術レベル | 名称 | 係数 | 説明 |
|-----------|------|------|------|
| 1 | 裸のシングル | 1.0 | セルに1つの数字しか入らない |
| 2 | 隠れたシングル | 1.5 | 行・列・ブロック内で1つの場所にしか入らない |
| 3 | 裸のペア | 2.0 | 2つのセルに同じ2つの候補がある |
| 4 | 隠れたペア | 2.5 | 2つの数字が2つのセルにしかない |
| 5 | 裸のトリプル | 3.0 | 3つのセルに同じ3つの候補がある |
| 6 | 隠れたトリプル | 3.5 | 3つの数字が3つのセルにしかない |
| 7 | ポインティングペア | 4.0 | ブロック内の候補が一直線上に並ぶ |
| 8 | ボックス/ライン削減 | 4.5 | 行・列の候補がブロック内に限定される |
| 9 | X-Wing | 5.0 | 2つの行・列で同じパターンが現れる |
| 10 | 推測・試行錯誤 | 10.0 | 論理的解法では解けない |

### 3. 最終難易度計算
```
最終難易度 = 基本難易度 + Σ(技術レベル係数 * 使用回数)
```

## 難易度ランク分類

| ランク | 難易度範囲 | 名称 | 説明 |
|--------|-----------|------|------|
| 1 | 1000-1499 | 初級 | 基本的な解法のみ |
| 2 | 1500-1999 | 中級 | ペア・トリプル技術が必要 |
| 3 | 2000-2499 | 上級 | 高度な論理技術が必要 |
| 4 | 2500-2999 | エキスパート | 複雑な解法パターンが必要 |
| 5 | 3000+ | マスター | 推測・試行錯誤が必要 |

## 実装用の詳細仕様

### 1. 候補数による基本判定
```swift
// セルの候補数による技術判定
func getTechniqueLevel(candidateCount: Int, context: SolvingContext) -> Int {
    switch candidateCount {
    case 1: return 1  // 裸のシングル
    case 2: return checkPairTechnique(context)  // 2-4
    case 3: return checkTripleTechnique(context)  // 3-6
    default: return checkAdvancedTechnique(context)  // 7+
    }
}
```

### 2. 解法プロセスの記録
```swift
struct SolvingStep {
    let cellIndex: Int
    let techniqueLevel: Int
    let candidatesBefore: Set<Int>
    let candidatesAfter: Set<Int>
    let eliminatedCandidates: Set<Int>
}
```

### 3. 動的難易度調整
プレイヤーの解答時間に基づく調整：

```swift
// 解答時間による難易度調整
func adjustDifficulty(currentDifficulty: Int, solvingTime: TimeInterval, expectedTime: TimeInterval) -> Int {
    let ratio = solvingTime / expectedTime
    let adjustment = Int((ratio - 1.0) * 100)
    return max(1000, min(5000, currentDifficulty + adjustment))
}
```

### 4. 期待解答時間の計算
```swift
// 難易度から期待解答時間を計算（秒）
func expectedSolvingTime(difficulty: Int) -> TimeInterval {
    switch difficulty {
    case 1000..<1500: return 300   // 5分
    case 1500..<2000: return 600   // 10分
    case 2000..<2500: return 1200  // 20分
    case 2500..<3000: return 1800  // 30分
    default: return 2400           // 40分
    }
}
```

## 検証用テストケース

### 初級レベル（1000-1499）
- 空きマス: 40-45
- 使用技術: 裸のシングル + 隠れたシングル
- 期待解答時間: 5-10分

### 中級レベル（1500-1999）
- 空きマス: 46-50
- 使用技術: ペア・トリプル技術
- 期待解答時間: 10-15分

### 上級レベル（2000-2499）
- 空きマス: 51-55
- 使用技術: 高度な論理技術
- 期待解答時間: 15-25分

### エキスパートレベル（2500+）
- 空きマス: 56+
- 使用技術: 推測・試行錯誤
- 期待解答時間: 25分以上

