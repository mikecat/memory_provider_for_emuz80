Memory Provider for EMUZ80
==========================

PIC18F47Q43 用の、[EMUZ80](https://vintagechips.wordpress.com/2022/03/05/emuz80_reference/) 対応のファームウェアです。

以下の特徴があります。

* デフォルトのクロック出力は 2.5MHz (LH0080 の定格)
* 標準プログラムより約 70% 高速 ([EMUBASIC](https://github.com/vintagechips/emuz80/tree/6caf74b4cbbd2683d698ca7ee5abfcd35cfa09f1/examples/EMUBASIC) での [ASCIIART.BAS](https://github.com/vintagechips/emuz80/blob/6caf74b4cbbd2683d698ca7ee5abfcd35cfa09f1/ASCIIART.BAS) の実行による実験結果)
* メモリだけでなく I/O 空間へのアクセスにも対応 (現在は空)
* オープンソースライセンス (MIT)

以下の機能の実装を予定しています。

* Z80 をリセットした状態で止める (ファームウェアの更新がアドレスと衝突しない)
* UART 経由でのクロック出力周波数の設定
* UART 経由での ROM データの書き換え

## ピンアサイン

本家 EMUZ80 と同じです。

|PIC|方向 (PIC 視点)|Z80|その他|
|---|---|---|---|
|RD0-RD7|入力|A8-A15|-|
|RB0-RB7|入力|A0-A7|-|
|RC0-RC7|入出力|D0-D7|-|
|RA0|入力|IOREQ|-|
|RA1|入力|MREQ|-|
|RA2|入力|RFSH|-|
|RA3|出力|CLK|-|
|RA4|出力|WAIT|-|
|RA5|入力|RD|-|
|RE0|入力|WR|-|
|RE2|出力|INT|-|
|RE1|入力|-|RESET|
|RA6|出力|-|UART TX|
|RA7|入力|-|UART RX|

RA7 (UART RX) 以外の入力ピンは内部でプルアップしています。  
(RA7 は EMUZ80 側にプルアップがあるため除外しました)

## メモリマップ

標準プログラムと互換ですが、ROM を 16KiB ではなく 32KiB にしました。

|メモリアドレス|役割|
|---|---|
|0xC000 - 0xFFFF|周辺機器 I/O|
|0x9000 - 0xBFFF|-|
|0x8000 - 0x8FFF|RAM (4KiB)|
|0x0000 - 0x7FFF|ROM (32KiB)|

以下の周辺機器が実装されています。

|メモリアドレス|読み出し|書き込み|
|---|---|---|
|0xE001|UART 状態 (`PIR9`)|-|
|0xE000|UART 受信 (`U3RXB`)|UART 送信 (`U3TXB`)|

## ビルド方法

[GPUTILS - GNU PIC Utilities](https://gputils.sourceforge.io/) を用います。

`make` コマンドにより、ファームウェア `memory_provider.hex` およびその他の情報ファイルを生成できます。

## ROMのデータの差し替え方法

Z80 に見せる ROM のデータは、プログラムメモリのアドレス 0x10000 以降に置かれています。

`memory_provider.hex` をテキストエディタで開き、

```
:020000040001F9
```

という行を探します。(以降のデータをアドレス 0x10000 - 0x1FFFF に配置することを表す行です)

この行の次にある行

```
:0200000018FEE8
```

を削除し、かわりに ROM のデータの HEX ファイルの内容を貼り付けます。

ただし、データの終わりを表す行

```
:00000001FF
```

はここに貼り付けてはいけません。

※貼り付ける HEX ファイルの表現方法によっては、もしかしたらうまくいかないかもしれません。

## 関連リンク

* 本家様
  * [EMUZ80が完成 | 電脳伝説](https://vintagechips.wordpress.com/2022/03/05/emuz80_reference/)
  * [GitHub - vintagechips/emuz80: The computer with only Z80 and PIC18F47Q43](https://github.com/vintagechips/emuz80)
* 他の作者様の対応ファームウェア
  * [GitHub - tendai22/emuz80_kuma: A Z80 drove by PIC18F47Q43, original by @vintagechips.](https://github.com/tendai22/emuz80_kuma)
  * [GitHub - yyhayami/emuz80_hayami: The computer with only Z80 and PIC18F47Q43](https://github.com/yyhayami/emuz80_hayami)
