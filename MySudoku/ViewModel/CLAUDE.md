# 問題生成
1. 真っ白の盤面に左上3x3、真ん中3x3、右下3x3にランダムに1〜9の数字を入れる\
3 * 9! ~ 10^6 通りくらい
```txt
+-------+-------+-------+
| 5 2 8 | . . . | . . . |
| 6 4 1 | . . . | . . . |
| 7 3 9 | . . . | . . . |
+-------+-------+-------+
| . . . | 3 2 7 | . . . |
| . . . | 8 9 5 | . . . |
| . . . | 6 4 1 | . . . |
+-------+-------+-------+
| . . . | . . . | 3 5 7 |
| . . . | . . . | 2 1 8 |
| . . . | . . . | 9 6 4 |
+-------+-------+-------+
```

2. 1で作成した盤面の解答を作成\
v4のアルゴリズムで0部分を埋める\
解答はめちゃめちゃいっぱい出てくるので最初の1つを使用する\
これで模範解答となる盤面ができる

3. 2で作成した盤面を元に穴を開けていく\
ランダムで穴を開ける場所を選択 → 解答が一意に定まるか判定(v4を使用)\
一意になるとき → また次の穴を開ける\
一意にならないとき(解答が複数存在するとき or 解答がないとき、矛盾) → 一個前(解答が一意に定まる、穴の数が最大の時)の盤面

これで可能な限り穴が多い(おそらく一番難しい)ナンプレが完成する\


# v4のアルゴリズム

```python
from question import Question
import time


def main():
    q = Question(
        s="800000000003600000070090200050007000000045700000100030001000068008500010090000400"
    )
    q_str = q.q_str

    if not check_all(q_str):
        print("正しいナンプレを入力してね")
        return

    # dfs
    s_t = time.time()
    stack = [(0, q_str)]
    while stack:
        i, t = stack.pop()

        if i == q_str.count("0"):
            print(t)
            print("正解" if t in q.get_ans() else "不正解")
            continue

        k, next_options = find_next(t)
        for j in next_options:
            new_t = t[:k] + j + t[k + 1 :]
            stack.append((i + 1, new_t))

    e_t = time.time()
    print(f"タイム: {e_t - s_t}s")


# 全マスチェック
def check_all(s):
    # 横
    for i in range(9):
        ss = s[i * 9 : (i + 1) * 9]
        for j in range(1, 10):
            if ss.count(str(j)) > 1:
                return False
    # 縦
    for i in range(9):
        ss = [s[i % 9 + 9 * j] for j in range(9)]
        for j in range(1, 10):
            if ss.count(str(j)) > 1:
                return False
    # 3 x 3
    for i in range(9):
        ss = [s[i // 3 * 27 + i % 3 * 3 + j // 3 * 9 + j % 3] for j in range(9)]
        for j in range(1, 10):
            if ss.count(str(j)) > 1:
                return False
    return True


def check_i(s, i):
    # 横
    r = i // 9
    ss = s[r * 9 : (r + 1) * 9]
    for j in range(1, 10):
        if ss.count(str(j)) > 1:
            return False
    # 縦
    ss = [s[i % 9 + 9 * j] for j in range(9)]
    for j in range(1, 10):
        if ss.count(str(j)) > 1:
            return False
    # 3 x 3
    ss = [s[i // 27 * 27 + i % 9 // 3 * 3 + j // 3 * 9 + j % 3] for j in range(9)]
    for j in range(1, 10):
        if ss.count(str(j)) > 1:
            return False
    return True


def find_next(s):
    i, max_n, cannot_set = 0, 0, set()
    for k in range(81):
        if s[k] != "0":
            continue

        r_arr = list(s[k // 9 * 9 : k // 9 * 9 + 9])  # 横
        c_arr = [s[k % 9 + 9 * j] for j in range(9)]  # 縦
        b_arr = [s[k // 27 * 27 + k % 9 // 3 * 3 + j // 3 * 9 + j % 3] for j in range(9)]  # 3x3

        now_set = set(r_arr + c_arr + b_arr)
        n = len(now_set)
        if max_n < n:
            max_n = n
            i = k
            cannot_set = now_set
    return i, set(map(str, range(1, 10))) - cannot_set


if __name__ == "__main__":
    main()
```
